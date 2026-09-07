import 'package:flutter/foundation.dart';
import '../models/journal_entry.dart';
import '../models/mood.dart';

enum PlanTier { free, monthly, yearly }

class TagDef {
  final String key;
  final String label;
  const TagDef(this.key, this.label);
}

const List<TagDef> kTags = [
  TagDef('cong-viec', 'Công việc'),
  TagDef('gia-dinh', 'Gia đình'),
  TagDef('suc-khoe', 'Sức khoẻ'),
  TagDef('giac-ngu', 'Giấc ngủ'),
  TagDef('tien-bac', 'Tiền bạc'),
  TagDef('ban-be', 'Bạn bè'),
];

const List<String> kIntensityLabels = ['nhẹ', 'hơi nhẹ', 'vừa', 'khá mạnh', 'rất mạnh'];

class AppState extends ChangeNotifier {
  bool hasOnboarded = false;
  bool isLoggedIn = false;
  String userName = 'Linh';
  int streakDays = 12;
  PlanTier plan = PlanTier.free;

  final List<JournalEntry> entries = [
    const JournalEntry(
      id: 'seed-1',
      dateLabel: 'Thứ Ba, 1 tháng 9 · 21:12',
      mood: Mood.loLang,
      intensity: 4,
      tags: ['cong-viec', 'giac-ngu'],
      note: 'Deadline dồn vào cuối tuần, ngủ được có bốn tiếng. Cứ thấy như mình đang chạy mà không tới đâu.',
    ),
  ];

  Mood draftMood = Mood.binhYen;
  int draftIntensity = 3;
  List<String> draftTags = ['cong-viec'];
  String draftNote = '';

  void logIn() {
    isLoggedIn = true;
    notifyListeners();
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
    draftIntensity = i.clamp(1, 5);
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
