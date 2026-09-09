import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/journal_entry.dart';
import '../models/mood.dart';
import '../services/auth_api.dart';
import '../services/auth_service.dart';
import '../services/auth_user.dart';
import '../services/journal_api.dart';

enum PlanTier { free, monthly, yearly }

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
  int streakDays = 12;
  PlanTier plan = PlanTier.free;

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

  static const _kUid = 'auth_uid';
  static const _kEmail = 'auth_email';
  static const _kName = 'auth_name';
  static const _kProvider = 'auth_provider';
  static const _kToken = 'auth_token';

  final List<JournalEntry> entries = [
    JournalEntry(
      id: 'seed-1',
      dateLabel: 'Thứ Ba, 1 tháng 9 · 21:12',
      mood: Mood.loLang,
      intensity: 7,
      tags: const ['cong-viec', 'giac-ngu'],
      note: 'Deadline dồn vào cuối tuần, ngủ được có bốn tiếng. Cứ thấy như mình đang chạy mà không tới đâu.',
      entryDate: DateTime(DateTime.now().year, 9, 1, 21, 12),
    ),
  ];

  Mood draftMood = Mood.binhYen;
  int draftIntensity = 5;
  List<String> draftTags = ['cong-viec'];
  String draftNote = '';

  /// Id of the entry being overwritten, if today already has one — set by
  /// [beginDraftEntry]. Null means the next save creates a new entry.
  String? draftEditingId;

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
    if (existing != null) {
      draftEditingId = existing.id;
      draftMood = existing.mood;
      draftIntensity = existing.intensity;
      draftTags = List.of(existing.tags);
      draftNote = existing.note;
    } else {
      draftEditingId = null;
      draftMood = Mood.binhYen;
      draftIntensity = 5;
      draftTags = ['cong-viec'];
      draftNote = '';
    }
    notifyListeners();
  }

  /// Load the cached signed-in user (fast, offline) then reconcile with
  /// whatever Firebase restored. Call once at startup.
  Future<void> loadSession() async {
    final prefs = await SharedPreferences.getInstance();
    authUid = prefs.getString(_kUid);
    authEmail = prefs.getString(_kEmail);
    authName = prefs.getString(_kName);
    authProvider = prefs.getString(_kProvider);
    authToken = prefs.getString(_kToken);
    notifyListeners();

    final restored = await AuthService.instance.restore();
    if (restored != null) {
      await _apply(restored);
    } else if (AuthService.available && authUid != null) {
      // Firebase says nobody is signed in — drop the stale cache.
      await _clear();
    } else if (authToken != null) {
      // Offline-ish restore from cache — still try a background sync.
      await _syncEntries();
    }
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
      await _syncEntries();
    }
  }

  Future<void> _clear() async {
    authUid = authEmail = authName = authProvider = authToken = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_kUid);
    await prefs.remove(_kEmail);
    await prefs.remove(_kName);
    await prefs.remove(_kProvider);
    await prefs.remove(_kToken);
    notifyListeners();
  }

  /// Pulls the authoritative entry list from the backend. Leaves local
  /// entries untouched on failure (offline, backend down, etc).
  Future<void> _syncEntries() async {
    final token = authToken;
    if (token == null) return;
    try {
      final remote = await JournalApi.instance.fetchAll(token);
      entries
        ..clear()
        ..addAll(remote);
      notifyListeners();
    } catch (e) {
      debugPrint('AppState: entries sync failed: $e');
    }
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
      dateLabel: formatEntryDateLabel(now),
      mood: draftMood,
      intensity: draftIntensity,
      tags: draftTags,
      note: draftNote,
      // Overwriting today's entry keeps its original calendar day; a new
      // entry is dated now.
      entryDate: editingId != null ? entries.firstWhere((e) => e.id == editingId).entryDate : now,
    );

    final existingIndex = editingId != null ? entries.indexWhere((e) => e.id == editingId) : -1;
    if (existingIndex != -1) {
      entries[existingIndex] = entry;
    } else {
      entries.insert(0, entry);
      streakDays += 1;
    }
    notifyListeners();

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
      }
    }).catchError((Object e) {
      debugPrint('AppState: failed to sync entry: $e');
    });
  }

  void setPlan(PlanTier p) {
    plan = p;
    notifyListeners();
  }
}
