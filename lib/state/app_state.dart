import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/journal_entry.dart';
import '../models/mood.dart';
import '../services/auth_api.dart';
import '../services/auth_service.dart';
import '../services/auth_user.dart';

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

  bool get isLoggedIn => authUid != null;

  /// Name to show around the app — the SSO display name, else a default.
  String get userName => authName ?? authEmail?.split('@').first ?? 'bạn';

  static const _kUid = 'auth_uid';
  static const _kEmail = 'auth_email';
  static const _kName = 'auth_name';
  static const _kProvider = 'auth_provider';

  final List<JournalEntry> entries = [
    const JournalEntry(
      id: 'seed-1',
      dateLabel: 'Thứ Ba, 1 tháng 9 · 21:12',
      mood: Mood.loLang,
      intensity: 7,
      tags: ['cong-viec', 'giac-ngu'],
      note: 'Deadline dồn vào cuối tuần, ngủ được có bốn tiếng. Cứ thấy như mình đang chạy mà không tới đâu.',
    ),
  ];

  Mood draftMood = Mood.binhYen;
  int draftIntensity = 5;
  List<String> draftTags = ['cong-viec'];
  String draftNote = '';

  /// Load the cached signed-in user (fast, offline) then reconcile with
  /// whatever Firebase restored. Call once at startup.
  Future<void> loadSession() async {
    final prefs = await SharedPreferences.getInstance();
    authUid = prefs.getString(_kUid);
    authEmail = prefs.getString(_kEmail);
    authName = prefs.getString(_kName);
    authProvider = prefs.getString(_kProvider);
    notifyListeners();

    final restored = await AuthService.instance.restore();
    if (restored != null) {
      await _apply(restored);
    } else if (AuthService.available && authUid != null) {
      // Firebase says nobody is signed in — drop the stale cache.
      await _clear();
    }
  }

  Future<void> signInWith(Future<AuthUser> Function() flow) async {
    final user = await flow();
    await _apply(user);
    await AuthApi.instance.syncSession(user);
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
  }

  Future<void> _clear() async {
    authUid = authEmail = authName = authProvider = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_kUid);
    await prefs.remove(_kEmail);
    await prefs.remove(_kName);
    await prefs.remove(_kProvider);
    notifyListeners();
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
    entries.insert(
      0,
      JournalEntry(
        id: 'e-${DateTime.now().millisecondsSinceEpoch}',
        dateLabel: 'Hôm nay',
        mood: draftMood,
        intensity: draftIntensity,
        tags: draftTags,
        note: draftNote,
      ),
    );
    streakDays += 1;
    notifyListeners();
  }

  void setPlan(PlanTier p) {
    plan = p;
    notifyListeners();
  }
}
