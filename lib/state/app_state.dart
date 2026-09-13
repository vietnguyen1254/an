import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/journal_entry.dart';
import '../models/meditation_log.dart';
import '../models/mood.dart';
import '../services/auth_api.dart';
import '../services/auth_service.dart';
import '../services/auth_user.dart';
import '../services/journal_api.dart';
import '../services/me_api.dart';
import '../services/meditation_api.dart';
import '../services/notifications/notification_service.dart';
import '../services/notifications/reminder_copy.dart';
import '../services/notifications/reminder_scheduler.dart';

enum PlanTier { free, monthly, yearly }

String _planTierWire(PlanTier p) => switch (p) {
      PlanTier.free => 'free',
      PlanTier.monthly => 'monthly',
      PlanTier.yearly => 'yearly',
    };

PlanTier _planTierFromWire(String? s) => switch (s) {
      'monthly' => PlanTier.monthly,
      'yearly' => PlanTier.yearly,
      _ => PlanTier.free,
    };

class TagDef {
  final String key;
  final String label;
  const TagDef(this.key, this.label);
}

const List<TagDef> kTags = [
  TagDef('cong-viec', 'Công việc'),
  TagDef('gia-dinh', 'Gia đình'),
  TagDef('suc-khoe', 'Sức khỏe'),
  TagDef('giac-ngu', 'Giấc ngủ'),
  TagDef('tai-chinh', 'Tài chính'),
  TagDef('moi-quan-he', 'Mối quan hệ'),
  TagDef('ban-than', 'Bản thân'),
];

/// Intensity is a 1–10 scale (1 = nhẹ nhất, 10 = rất mạnh).
const int kIntensityMax = 10;

String intensityLabel(int i) {
  const labels = [
    'rất nhẹ',
    'rất nhẹ',
    'nhẹ',
    'nhẹ',
    'vừa',
    'vừa',
    'khá mạnh',
    'khá mạnh',
    'rất mạnh',
    'rất mạnh',
  ];
  return labels[(i - 1).clamp(0, labels.length - 1)];
}

class AppState extends ChangeNotifier {
  bool hasOnboarded = false;
  PlanTier plan = PlanTier.free;

  /// When the current paid plan next renews. Device-local only — there's no
  /// backend receipt validation yet, so this is derived from the store
  /// transaction date (or "now" as a fallback) plus the plan's interval,
  /// not an authoritative expiry. Null while on the free plan.
  DateTime? planRenewsAt;

  /// Consecutive days (ending today or yesterday) with a recorded entry —
  /// computed from real data, not a counter. Mirrors the backend's own
  /// GET /v1/streak logic so the two never disagree.
  int get streakDays {
    final days = entries.map((e) => DateTime(e.entryDate.year, e.entryDate.month, e.entryDate.day)).toSet().toList()
      ..sort((a, b) => b.compareTo(a));
    if (days.isEmpty) return 0;
    final today = DateTime.now();
    final todayDate = DateTime(today.year, today.month, today.day);
    final yesterday = todayDate.subtract(const Duration(days: 1));
    if (days.first != todayDate && days.first != yesterday) return 0;
    var streak = 0;
    var cursor = days.first;
    for (final d in days) {
      if (d == cursor) {
        streak++;
        cursor = cursor.subtract(const Duration(days: 1));
      } else {
        break;
      }
    }
    return streak;
  }

  // --- auth ---------------------------------------------------------------
  String? authUid;
  String? authEmail;
  String? authName;
  String? authProvider;

  /// App JWT from POST /v1/auth/session — Bearer token for every other
  /// authenticated backend call (journal entries, etc).
  String? authToken;

  bool get isLoggedIn => authUid != null;

  /// Name to show around the app — the SSO display name, else a default.
  String get userName => authName ?? authEmail?.split('@').first ?? 'bạn';

  /// Avatar the user picked from the fixed set (see [kAvatars]). Server-side
  /// (part of the profile), cached locally. Null = the default avatar.
  String? authAvatar;

  /// Biometric app lock (Face ID / vân tay). Device-local only — a security
  /// preference, never synced.
  bool appLockEnabled = false;

  /// Daily reminders (both on by default). Device-local. Timing/copy is
  /// worked out on-device by [ReminderScheduler] — no server, no push.
  bool moodReminderEnabled = true;
  bool meditationReminderEnabled = true;

  /// Whether we've already asked the OS for notification permission once
  /// (so we only prompt proactively a single time, after the first check-in).
  bool notifPrimed = false;

  static const _kUid = 'auth_uid';
  static const _kEmail = 'auth_email';
  static const _kName = 'auth_name';
  static const _kProvider = 'auth_provider';
  static const _kToken = 'auth_token';
  static const _kMeditationLog = 'meditation_log';
  static const _kEntries = 'journal_entries';
  static const _kPlan = 'plan_tier';
  static const _kPlanRenewsAt = 'plan_renews_at';
  static const _kAvatar = 'user_avatar';
  static const _kAvatarDirty = 'user_avatar_dirty';
  static const _kAppLock = 'app_lock_enabled';
  static const _kMoodReminder = 'mood_reminder_enabled';
  static const _kMedReminder = 'meditation_reminder_enabled';
  static const _kNotifPrimed = 'notif_primed';
  static const _kMedSlot = 'med_reminder_slot';
  static const _kMedSlotSince = 'med_reminder_slot_since';

  final List<MeditationLog> meditationLog = [];

  Future<void> _persistMeditationLog() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_kMeditationLog, meditationLog.map((m) => jsonEncode(m.toJson())).toList());
  }

  Future<void> _persistEntries() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_kEntries, entries.map((e) => jsonEncode(e.toCacheJson())).toList());
  }

  /// Records actual listened time (called from PlayerScreen as it plays).
  /// Writes locally first so the UI is immediate and offline-safe, caches to
  /// prefs, then syncs the row to the backend in the background.
  Future<void> addMeditationSeconds(int seconds, {String? sessionId}) async {
    if (seconds <= 0) return;
    final log = MeditationLog(DateTime.now(), seconds, sessionId: sessionId);
    meditationLog.add(log);
    debugPrint('AppState: meditationLog now has ${meditationLog.length} entries, total ${meditationLog.fold(0, (a, b) => a + b.seconds)}s');
    notifyListeners();
    await _persistMeditationLog();
    rescheduleReminders();

    final token = authToken;
    if (token == null) return;
    try {
      final saved = await MeditationApi.instance.create(token, log);
      final i = meditationLog.indexOf(log);
      if (i != -1) {
        meditationLog[i] = saved;
        await _persistMeditationLog();
      }
    } catch (e) {
      debugPrint('AppState: failed to sync meditation log: $e');
    }
  }

  int meditationSecondsInRange(DateTime start, DateTime end) {
    var total = 0;
    for (final m in meditationLog) {
      final d = DateTime(m.date.year, m.date.month, m.date.day);
      if (!d.isBefore(start) && !d.isAfter(end)) total += m.seconds;
    }
    return total;
  }

  /// Journal entries. The backend is authoritative (`GET /v1/entries`); this
  /// list is seeded from the on-device cache at startup so the journal and
  /// the streak render instantly and offline, then reconciled by
  /// [_syncFromBackend].
  final List<JournalEntry> entries = [];

  Mood draftMood = Mood.binhThuong;
  int draftIntensity = 5;
  List<String> draftTags = [];
  String draftNote = '';

  /// Id of the entry being overwritten, if today already has one — set by
  /// [beginDraftEntry]. Null means the next save creates a new entry.
  String? draftEditingId;

  /// Set by [beginDraftEntryForDate] when backfilling a past day that has
  /// no entry yet; null means the next save dates the new entry to now.
  /// Irrelevant once [draftEditingId] is set (an edit always keeps the
  /// entry's existing date).
  DateTime? draftDate;

  /// Call before opening the check-in flow. A day only ever has one entry:
  /// if today already has one, loads it into the draft so the user edits
  /// the existing record instead of creating a duplicate; otherwise resets
  /// the draft to defaults.
  void beginDraftEntry() {
    final now = DateTime.now();
    JournalEntry? existing;
    for (final e in entries) {
      if (e.entryDate.year == now.year && e.entryDate.month == now.month && e.entryDate.day == now.day) {
        existing = e;
        break;
      }
    }
    draftDate = null;
    if (existing != null) {
      draftEditingId = existing.id;
      draftMood = existing.mood;
      draftIntensity = existing.intensity;
      draftTags = List.of(existing.tags);
      draftNote = existing.note;
    } else {
      draftEditingId = null;
      draftMood = Mood.binhThuong;
      draftIntensity = 5;
      draftTags = [];
      draftNote = '';
    }
    notifyListeners();
  }

  /// Call before opening the check-in flow for a past day tapped in the
  /// journal's week/month grid that has no entry yet — resets the draft to
  /// defaults and points [saveDraftEntry] at [date] instead of now. Doesn't
  /// handle the "already has an entry" case; the journal screen routes
  /// those to DayDetailScreen instead of here.
  void beginDraftEntryForDate(DateTime date) {
    draftEditingId = null;
    draftDate = date;
    draftMood = Mood.binhThuong;
    draftIntensity = 5;
    draftTags = ['cong-viec'];
    draftNote = '';
    notifyListeners();
  }

  /// Loads an existing entry from any day into the draft for editing — used
  /// by DayDetailScreen's "Sửa". Unlike [beginDraftEntry] this doesn't care
  /// whether the entry is today's; [saveDraftEntry] already preserves the
  /// original entryDate whenever [draftEditingId] is set.
  void beginEditEntry(JournalEntry entry) {
    draftEditingId = entry.id;
    draftDate = null;
    draftMood = entry.mood;
    draftIntensity = entry.intensity;
    draftTags = List.of(entry.tags);
    draftNote = entry.note;
    notifyListeners();
  }

  /// Deletes an entry — local list + cache immediately, then the backend
  /// row in the background (server is authoritative, syncs across devices).
  Future<void> deleteEntry(String id) async {
    entries.removeWhere((e) => e.id == id);
    notifyListeners();
    await _persistEntries();
    final token = authToken;
    if (token == null) return;
    try {
      await JournalApi.instance.delete(token, id);
    } catch (e) {
      debugPrint('AppState: failed to delete entry on backend: $e');
    }
  }

  /// Loads the cached signed-in user — local prefs only, no network, so this
  /// resolves in a few milliseconds. `main()` awaits only this before
  /// `runApp()`, so the first frame renders from cache immediately; call
  /// [syncSessionInBackground] right after to reconcile with the network
  /// without blocking that first frame on it.
  Future<void> loadSession() async {
    final prefs = await SharedPreferences.getInstance();
    authUid = prefs.getString(_kUid);
    authEmail = prefs.getString(_kEmail);
    authName = prefs.getString(_kName);
    authProvider = prefs.getString(_kProvider);
    authToken = prefs.getString(_kToken);
    plan = _planTierFromWire(prefs.getString(_kPlan));
    final renewsAtWire = prefs.getString(_kPlanRenewsAt);
    planRenewsAt = renewsAtWire != null ? DateTime.tryParse(renewsAtWire) : null;
    authAvatar = prefs.getString(_kAvatar);
    // A pick from a previous session that never confirmed as saved (app
    // closed/killed, offline, request timed out) — persisted so it survives
    // restart and isn't silently overwritten by a stale server read below.
    _avatarDirty = prefs.getBool(_kAvatarDirty) ?? false;
    appLockEnabled = prefs.getBool(_kAppLock) ?? false;
    moodReminderEnabled = prefs.getBool(_kMoodReminder) ?? true;
    meditationReminderEnabled = prefs.getBool(_kMedReminder) ?? true;
    notifPrimed = prefs.getBool(_kNotifPrimed) ?? false;

    final rawLog = prefs.getStringList(_kMeditationLog);
    if (rawLog != null) {
      meditationLog.addAll(rawLog.map((s) => MeditationLog.fromJson(jsonDecode(s) as Map<String, dynamic>)));
    }
    final rawEntries = prefs.getStringList(_kEntries);
    if (rawEntries != null) {
      entries.addAll(rawEntries.map((s) => JournalEntry.fromCacheJson(jsonDecode(s) as Map<String, dynamic>)));
    }
    notifyListeners();
  }

  /// The network half of startup — Firebase restore, then a fresh pull from
  /// the backend. Runs after the UI is already showing the cached state from
  /// [loadSession], so a slow or offline connection never blocks the first
  /// frame (previously this was awaited before `runApp()`, which held the
  /// app on a blank white launch screen for however long the network chain
  /// took — several seconds on a normal connection).
  Future<void> syncSessionInBackground() async {
    final restored = await AuthService.instance.restore();
    if (restored != null) {
      await _apply(restored);
    } else if (authToken != null) {
      // We already have our own backend session (JWT) cached — keep using
      // it even if Firebase's restore came back null right now. That signal
      // is not reliable enough to treat as destructive: `authStateChanges()`
      // can still emit a transient null on a cold start before the real
      // persisted user loads (a known firebase_auth plugin quirk — this bit
      // us even after switching from `.currentUser` to `.first` on the
      // stream). Our own token is the actual source of truth for talking to
      // our backend; only an explicit sign-out or account deletion should
      // ever wipe local session data.
      await _syncFromBackend();
    } else if (AuthService.available && authUid != null) {
      // No cached backend token AND Firebase confirms signed out — nothing
      // usable to restore.
      await _clear();
    }
    rescheduleReminders();
  }

  Future<void> signInWith(Future<AuthUser> Function() flow) async {
    final user = await flow();
    await _apply(user);
  }

  Future<void> signOut() async {
    await AuthService.instance.signOut();
    await _clear();
  }

  Future<void> _apply(AuthUser user) async {
    debugPrint(
      'AUTH: signed in via ${user.provider} '
      '— email=${user.email} name=${user.name} uid=${user.uid}',
    );
    authUid = user.uid;
    authEmail = user.email;
    authName = user.name;
    authProvider = user.provider;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kUid, user.uid);
    await _setOrRemove(prefs, _kEmail, user.email);
    await _setOrRemove(prefs, _kName, user.name);
    await _setOrRemove(prefs, _kProvider, user.provider);
    notifyListeners();

    final token = await AuthApi.instance.syncSession(user);
    if (token != null) {
      authToken = token;
      await prefs.setString(_kToken, token);
      await _syncFromBackend();
    }
  }

  Future<void> _clear() async {
    authUid = authEmail = authName = authProvider = authToken = authAvatar = null;
    _avatarDirty = false;
    plan = PlanTier.free;
    appLockEnabled = false;
    moodReminderEnabled = meditationReminderEnabled = true;
    notifPrimed = false;
    entries.clear();
    meditationLog.clear();
    final prefs = await SharedPreferences.getInstance();
    for (final k in [
      _kUid, _kEmail, _kName, _kProvider, _kToken, _kEntries, _kMeditationLog,
      _kPlan, _kAvatar, _kAvatarDirty, _kAppLock, _kMoodReminder, _kMedReminder, _kNotifPrimed,
      _kMedSlot, _kMedSlotSince,
    ]) {
      await prefs.remove(k);
    }
    await NotificationService.instance.cancelAll();
    notifyListeners();
  }

  /// Pulls the authoritative state (journal entries, meditation-time log,
  /// plan tier) from the backend and refreshes the on-device cache. Each
  /// piece fails independently and leaves its local copy untouched on error
  /// (offline, backend down, etc).
  Future<void> _syncFromBackend() async {
    final token = authToken;
    if (token == null) return;

    try {
      final remote = await JournalApi.instance.fetchAll(token);
      entries
        ..clear()
        ..addAll(remote);
      notifyListeners();
      await _persistEntries();
    } catch (e) {
      debugPrint('AppState: entries sync failed: $e');
    }

    try {
      final remote = await MeditationApi.instance.fetchAll(token);
      // Keep any locally-recorded chunks that haven't reached the backend yet.
      final unsynced = meditationLog.where((m) => m.id == null).toList();
      meditationLog
        ..clear()
        ..addAll(remote)
        ..addAll(unsynced);
      notifyListeners();
      await _persistMeditationLog();
    } catch (e) {
      debugPrint('AppState: meditation log sync failed: $e');
    }

    try {
      final me = await MeApi.instance.fetchMe(token);
      if (me != null) {
        final prefs = await SharedPreferences.getInstance();
        final tier = me['plan_tier'] as String?;
        if (tier != null) {
          plan = _planTierFromWire(tier);
          await prefs.setString(_kPlan, tier);
        }
        // Don't clobber a pick that's still on its way to the server — and
        // if one is still pending (including from a previous session, via
        // the persisted flag loaded in loadSession()), retry sending it
        // instead of just skipping forever.
        if (!_avatarDirty) {
          final avatar = me['avatar'] as String?;
          authAvatar = avatar;
          await _setOrRemove(prefs, _kAvatar, avatar);
        } else if (authAvatar != null) {
          unawaited(_pushAvatar(token, authAvatar!));
        }
        final name = me['name'] as String?;
        if (name != null && name.isNotEmpty) {
          authName = name;
          await prefs.setString(_kName, name);
        }
        notifyListeners();
      }
    } catch (e) {
      debugPrint('AppState: profile sync failed: $e');
    }

    rescheduleReminders();
  }

  Future<void> _setOrRemove(
    SharedPreferences prefs,
    String key,
    String? value,
  ) async {
    if (value == null || value.isEmpty) {
      await prefs.remove(key);
    } else {
      await prefs.setString(key, value);
    }
  }

  void setDraftMood(Mood m) {
    draftMood = m;
    notifyListeners();
  }

  void toggleDraftTag(String key) {
    if (draftTags.contains(key)) {
      draftTags = draftTags.where((t) => t != key).toList();
    } else {
      draftTags = [...draftTags, key];
    }
    notifyListeners();
  }

  void setDraftIntensity(int i) {
    draftIntensity = i.clamp(1, kIntensityMax);
    notifyListeners();
  }

  void setDraftNote(String note) {
    draftNote = note;
    notifyListeners();
  }

  void saveDraftEntry() {
    final now = DateTime.now();
    final editingId = draftEditingId;
    final localId = editingId ?? 'local-${now.millisecondsSinceEpoch}';
    final entry = JournalEntry(
      id: localId,
      mood: draftMood,
      intensity: draftIntensity,
      tags: draftTags,
      note: draftNote,
      // Overwriting an entry keeps its original calendar day; a new entry
      // is dated [draftDate] when backfilling a past day, else now.
      entryDate: editingId != null ? entries.firstWhere((e) => e.id == editingId).entryDate : (draftDate ?? now),
    );

    final existingIndex = editingId != null ? entries.indexWhere((e) => e.id == editingId) : -1;
    if (existingIndex != -1) {
      entries[existingIndex] = entry;
    } else {
      entries.insert(0, entry);
      // Keep entries ordered most-recent-first — a backfilled past day
      // can't just go at the front like a fresh "now" entry always could.
      entries.sort((a, b) => b.entryDate.compareTo(a.entryDate));
    }
    notifyListeners();
    _persistEntries();
    rescheduleReminders();

    // Sync to the backend in the background — the local copy above is
    // already what the UI shows, this just reconciles the id/timestamps.
    final token = authToken;
    if (token == null) return;
    final future = editingId != null && !editingId.startsWith('local-')
        ? JournalApi.instance.update(token, editingId, entry)
        : JournalApi.instance.create(token, entry);
    future.then((saved) {
      final i = entries.indexWhere((e) => e.id == localId);
      if (i != -1) {
        entries[i] = saved;
        notifyListeners();
        _persistEntries();
      }
    }).catchError((Object e) {
      debugPrint('AppState: failed to sync entry: $e');
    });
  }

  /// Sets the plan tier locally (immediate, offline-safe), caches it, then
  /// pushes it to the backend (`PATCH /v1/me`) which is authoritative for
  /// the tier itself (not the renewal date — see [planRenewsAt]).
  ///
  /// [purchasedAt] is the store transaction's own date when known (a real
  /// purchase/restore); defaults to now. The renewal date is that plus one
  /// billing interval, and is cleared entirely when downgrading to free.
  void setPlan(PlanTier p, {DateTime? purchasedAt}) {
    plan = p;
    planRenewsAt = switch (p) {
      PlanTier.free => null,
      PlanTier.monthly => _addMonths(purchasedAt ?? DateTime.now(), 1),
      PlanTier.yearly => _addMonths(purchasedAt ?? DateTime.now(), 12),
    };
    notifyListeners();
    _persistPlan(p);
  }

  static DateTime _addMonths(DateTime d, int months) {
    final totalMonths = d.month - 1 + months;
    final year = d.year + totalMonths ~/ 12;
    final month = totalMonths % 12 + 1;
    final lastDayOfMonth = DateTime(year, month + 1, 0).day;
    return DateTime(year, month, d.day.clamp(1, lastDayOfMonth));
  }

  Future<void> _persistPlan(PlanTier p) async {
    final wire = _planTierWire(p);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kPlan, wire);
    if (planRenewsAt != null) {
      await prefs.setString(_kPlanRenewsAt, planRenewsAt!.toIso8601String());
    } else {
      await prefs.remove(_kPlanRenewsAt);
    }
    final token = authToken;
    if (token == null) return;
    try {
      await MeApi.instance.updateProfile(token, planTier: wire);
    } catch (e) {
      debugPrint('AppState: failed to sync plan tier: $e');
    }
  }

  /// True from the moment [setAvatar] is called until its `PATCH /v1/me`
  /// actually confirms as saved — stops a concurrent (or next-launch, via
  /// the persisted [_kAvatarDirty] flag restored in loadSession())
  /// [_syncFromBackend] from reverting the pick to a stale server value.
  bool _avatarDirty = false;

  /// Picks the profile avatar — local + cache immediately, `PATCH /v1/me` in
  /// the background (server is authoritative, syncs across devices).
  void setAvatar(String id) {
    authAvatar = id;
    _avatarDirty = true;
    notifyListeners();
    () async {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_kAvatar, id);
      await prefs.setBool(_kAvatarDirty, true);
      final token = authToken;
      if (token == null) return;
      await _pushAvatar(token, id);
    }();
  }

  /// Sends [id] to `PATCH /v1/me` and only clears the dirty flag (in memory
  /// and in prefs) once it actually lands — on failure (offline, timeout,
  /// app closed mid-request) both stay set so the next [_syncFromBackend]
  /// retries the push instead of silently accepting a stale server read.
  Future<void> _pushAvatar(String token, String id) async {
    try {
      await MeApi.instance.updateProfile(token, avatar: id);
      _avatarDirty = false;
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_kAvatarDirty, false);
    } catch (e) {
      debugPrint('AppState: failed to sync avatar: $e');
    }
  }

  /// Toggles the biometric app lock. Device-local only — never sent to the
  /// server.
  Future<void> setAppLock(bool enabled) async {
    appLockEnabled = enabled;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_kAppLock, enabled);
  }

  // --- reminders --------------------------------------------------------

  Future<void> setMoodReminder(bool enabled) async {
    moodReminderEnabled = enabled;
    notifyListeners();
    (await SharedPreferences.getInstance()).setBool(_kMoodReminder, enabled);
    rescheduleReminders();
  }

  Future<void> setMeditationReminder(bool enabled) async {
    meditationReminderEnabled = enabled;
    notifyListeners();
    (await SharedPreferences.getInstance()).setBool(_kMedReminder, enabled);
    rescheduleReminders();
  }

  Future<void> markNotifPrimed() async {
    notifPrimed = true;
    (await SharedPreferences.getInstance()).setBool(_kNotifPrimed, true);
  }

  /// Recomputes the next week of reminder times + copy from the recorded
  /// history and hands them to the OS. Fire-and-forget; called on launch,
  /// resume, after a check-in / meditation, and when a toggle changes.
  Future<void> rescheduleReminders() async {
    if (!isLoggedIn) return;
    if (!moodReminderEnabled && !meditationReminderEnabled) {
      await NotificationService.instance.cancelAll();
      return;
    }
    try {
      final prefs = await SharedPreferences.getInstance();
      final storedSlot = MedSlot.values.firstWhere(
        (s) => s.name == prefs.getString(_kMedSlot),
        orElse: () => MedSlot.evening,
      );
      final storedSince = DateTime.tryParse(prefs.getString(_kMedSlotSince) ?? '') ??
          DateTime.now().subtract(const Duration(days: 30));

      final result = ReminderScheduler.build(
        moodEnabled: moodReminderEnabled,
        medEnabled: meditationReminderEnabled,
        entryTimes: entries.map((e) => e.entryDate).toList(),
        recentMoods: entries.map((e) => e.mood).toList(),
        streakDays: streakDays,
        meditationTimes: meditationLog.map((m) => m.date).toList(),
        storedMedSlot: storedSlot,
        storedMedSlotSince: storedSince,
      );

      await prefs.setString(_kMedSlot, result.medSlot.name);
      await prefs.setString(_kMedSlotSince, result.medSlotSince.toIso8601String());
      await NotificationService.instance.replaceAll(result.reminders);
    } catch (e) {
      debugPrint('AppState: rescheduleReminders failed: $e');
    }
  }

  // --- account deletion ------------------------------------------------

  /// Permanently deletes the account: server data first (`DELETE /v1/me`,
  /// cascades entries + meditation logs), then the Firebase auth record if it
  /// still lets us, then every local trace. Throws if the server call fails
  /// (offline / down) so the UI can keep the user on the confirm screen.
  Future<void> deleteAccount() async {
    final token = authToken;
    if (token != null) {
      await MeApi.instance.deleteAccount(token);
    }
    try {
      await AuthService.instance.deleteAccount();
    } catch (e) {
      debugPrint('AppState: firebase account delete skipped: $e');
      await AuthService.instance.signOut();
    }
    await _clear();
  }
}
