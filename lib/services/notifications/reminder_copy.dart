import 'dart:math';

import '../../models/mood.dart';

/// Which part of the day a meditation reminder is aimed at.
enum MedSlot { morning, midday, evening }

const _negativeMoods = {Mood.loLang, Mood.buon, Mood.cangThang, Mood.tucGian};

final _rand = Random();
final List<String> _recentMood = [];
final List<String> _recentMed = [];

String _pick(List<String> pool, List<String> recent) {
  final fresh = pool.where((l) => !recent.contains(l)).toList();
  final line = (fresh.isEmpty ? pool : fresh)[_rand.nextInt(fresh.isEmpty ? pool.length : fresh.length)];
  recent.add(line);
  if (recent.length > 6) recent.removeAt(0);
  return line;
}

// ─────────────────────────── Mood check-in ───────────────────────────

/// One line for a mood check-in reminder, chosen from the bucket that fits
/// the user's current situation. All lines are ≤ ~58 chars — one line on the
/// lock screen. `{streak}` is filled by the caller.
String moodReminderLine({
  required int streakDays,
  required Mood? lastMood,
  required bool phaseNew,
  required int daysSinceLastEntry,
  required int reminderHour,
}) {
  final List<String> pool;
  if (daysSinceLastEntry >= 3) {
    pool = _moodComeback;
  } else if (phaseNew && streakDays <= 3) {
    pool = _moodFirstWeek;
  } else if (lastMood != null && _negativeMoods.contains(lastMood) && daysSinceLastEntry <= 1) {
    pool = _moodAfterHeavy;
  } else if (lastMood != null && !_negativeMoods.contains(lastMood) && daysSinceLastEntry <= 1) {
    pool = _moodAfterLight;
  } else if (streakDays >= 7) {
    pool = _moodStreakStrong;
  } else if (reminderHour >= 19) {
    pool = _moodEvening;
  } else {
    pool = _moodGeneric;
  }
  return _pick(pool, _recentMood).replaceAll('{streak}', '$streakDays');
}

const _moodComeback = [
  'Mấy hôm nay thế nào? Mây vẫn ở đây, kể Mây nghe nhé.',
  'Lâu rồi bạn chưa ghé. Không sao — hôm nay bạn ổn không?',
  'Mây nhớ bạn. Ghi lại một dòng cảm xúc hôm nay nhé?',
  'Quay lại lúc nào cũng được. Hôm nay bạn thấy sao?',
  'Chỗ của bạn vẫn còn đây. Kể Mây nghe hôm nay đi.',
  'Vài ngày rồi mình chưa nói chuyện. Hôm nay bạn thế nào?',
  'Không cần bắt kịp gì cả. Chỉ cần hôm nay, bạn thấy sao?',
  'Mây để dành một khoảng lặng cho bạn. Ghé chút nhé?',
];

const _moodFirstWeek = [
  'Dành mười giây cho cảm xúc hôm nay nhé?',
  'Hôm nay bạn thế nào? Một dòng thôi cũng đủ.',
  'Mây đang tập làm quen với bạn. Kể hôm nay đi.',
  'Ghi lại hôm nay, để mai nhìn lại bạn hiểu mình hơn.',
  'Một thói quen nhỏ bắt đầu từ hôm nay. Bạn thấy sao?',
  'Chưa cần đều đặn. Chỉ cần hôm nay, bạn ổn không?',
  'Mây hỏi thăm: hôm nay trong lòng bạn thế nào?',
  'Kể Mây nghe một chút về hôm nay của bạn nhé.',
];

const _moodAfterHeavy = [
  'Hôm qua hơi nặng. Hôm nay bạn thấy nhẹ hơn chút nào không?',
  'Mây vẫn nghĩ về bạn. Hôm nay trong lòng thế nào?',
  'Không cần ổn ngay. Chỉ cần kể Mây nghe hôm nay đi.',
  'Hôm nay bạn thấy sao? Mây ở đây, không đi đâu cả.',
  'Một ngày mới rồi. Bạn đang mang cảm xúc gì lúc này?',
  'Mây để ý hôm qua bạn không dễ chịu lắm. Hôm nay đỡ hơn không?',
  'Ghi lại hôm nay nhé, kể cả khi lòng chưa yên.',
  'Bạn không đi qua hôm nay một mình đâu. Kể Mây nghe.',
];

const _moodAfterLight = [
  'Hôm nay có giữ được sự nhẹ nhõm hôm qua không?',
  'Mạch cảm xúc đang đẹp. Hôm nay bạn thấy sao?',
  'Kể tiếp cho Mây nghe — hôm nay trong lòng bạn thế nào?',
  'Hôm qua bạn ổn. Hôm nay thì sao?',
  'Một dòng nữa cho hôm nay nhé? Mây đang nghe.',
  'Ghi lại hôm nay để giữ mạch nha.',
  'Hôm nay bạn thế nào? Mây tò mò lắm.',
  'Dành chút thời gian cho cảm xúc hôm nay nhé.',
];

const _moodStreakStrong = [
  '{streak} ngày rồi. Thêm hôm nay nữa nhé?',
  'Bạn đang giữ nhịp rất tốt. Hôm nay thế nào?',
  'Đừng để hôm nay lỡ nhịp. Kể Mây nghe đi.',
  'Chuỗi ngày của bạn đang đẹp. Hôm nay bạn thấy sao?',
  '{streak} ngày liền bạn kể cho Mây. Hôm nay tiếp nhé.',
  'Mây quen có bạn mỗi ngày rồi. Hôm nay thế nào?',
  'Một dòng cho hôm nay, giữ chuỗi {streak} ngày nhé.',
  'Bạn bền bỉ thật. Hôm nay trong lòng bạn ra sao?',
];

const _moodEvening = [
  'Ăn tối xong rồi. Ngồi lại một chút với Mây nhé?',
  'Cuối ngày rồi. Hôm nay của bạn thế nào?',
  'Trước khi ngày khép lại, kể Mây nghe hôm nay đi.',
  'Một khoảng lặng buổi tối cho cảm xúc hôm nay nhé.',
  'Giờ này thư thả hơn rồi. Bạn thấy trong người sao?',
  'Nhìn lại một ngày: hôm nay bạn ổn không?',
  'Tối rồi. Ghi lại hôm nay trước khi quên nhé.',
  'Mây pha sẵn sự yên tĩnh. Kể hôm nay của bạn đi.',
];

const _moodGeneric = [
  'Hôm nay bạn thế nào? Kể Mây nghe một chút nhé.',
  'Dành mười giây ghi lại cảm xúc hôm nay nhé?',
  'Mây hỏi thăm: trong lòng bạn lúc này thế nào?',
  'Một dòng cho hôm nay thôi, Mây đang đợi.',
  'Bạn đang cảm thấy gì lúc này? Ghi lại nhé.',
  'Hôm nay có gì trong lòng bạn không? Kể Mây nghe.',
  'Ghi lại hôm nay, để hiểu mình hơn mỗi ngày.',
  'Mây để dành cho bạn một khoảng lặng. Ghé nhé.',
];

// ─────────────────────────── Meditation ───────────────────────────

String meditationReminderLine({
  required MedSlot slot,
  required bool everMeditated,
  required bool meditatedYesterday,
  required Mood? recentDominantMood,
  required int medStreakDays,
}) {
  final List<String> pool;
  if (!everMeditated) {
    pool = _medFirstTime;
  } else if (recentDominantMood == Mood.loLang) {
    pool = _medAnxious;
  } else if (recentDominantMood == Mood.cangThang) {
    pool = _medStressed;
  } else if (recentDominantMood == Mood.tucGian) {
    pool = _medAngry;
  } else if (slot == MedSlot.morning) {
    pool = _medMorning;
  } else if (slot == MedSlot.midday) {
    pool = _medMidday;
  } else if (medStreakDays >= 3) {
    pool = _medEveningStreak;
  } else {
    pool = _medEvening;
  }
  return _pick(pool, _recentMed).replaceAll('{streak}', '$medStreakDays');
}

const _medFirstTime = [
  'Thử bài thiền đầu tiên của bạn tối nay nhé?',
  'Mây có một bài ngắn để bắt đầu. Nghe thử không?',
  'Bạn chưa thiền lần nào. Năm phút thôi, thử nhé?',
  'Bài đầu tiên luôn dễ nhất. Mây chờ bạn.',
  'Một bài thiền nhẹ đang đợi. Bắt đầu tối nay nhé?',
  'Chưa cần giỏi. Chỉ cần bấm play và thở cùng Mây.',
  'Thử một bài thở ngắn xem sao. Mây dẫn bạn.',
];

const _medMorning = [
  'Bắt đầu ngày bằng vài phút tĩnh lặng nhé.',
  'Trước khi ngày cuốn đi, thở cùng Mây một chút.',
  'Sáng rồi. Một bài ngắn để tâm trí trong hơn.',
  'Vài hơi thở sâu buổi sáng, cả ngày nhẹ hơn.',
  'Mây pha sẵn buổi sáng yên tĩnh cho bạn.',
  'Mở ngày mới bằng một bài thiền nhẹ nhé?',
  'Trước cà phê, trước tin nhắn — thở đã nhé.',
];

const _medMidday = [
  'Giữa ngày rồi. Dừng lại năm phút với Mây nhé?',
  'Một bài thiền ngắn để reset buổi chiều.',
  'Nghỉ trưa một chút cho tâm trí. Mây dẫn bạn.',
  'Căng rồi hả? Vài phút thở sẽ giúp bạn dịu lại.',
  'Giữa bộn bề, một khoảng lặng nhỏ cũng đủ.',
  'Nạp lại năng lượng bằng một bài thiền ngắn nhé.',
  'Buổi chiều nhẹ hơn nếu bạn dừng lại lúc này.',
];

const _medAnxious = [
  'Mấy hôm bạn hơi lo. Một bài cho sự lo âu nhé?',
  'Mây có một bài giúp đầu bớt ồn. Nghe thử không?',
  'Khi lo lắng dâng lên, vài phút thở sẽ kéo bạn về.',
  'Một bài thiền làm dịu, cho những ngày như dạo này.',
  'Thở chậm lại cùng Mây nhé, lòng sẽ yên hơn.',
  'Vòng suy nghĩ quay hoài? Mây có bài giúp nó chậm lại.',
  'Một bài ngắn cho lo âu. Mây ngồi cùng bạn.',
];

const _medAngry = [
  'Mấy hôm bạn hơi nóng trong người. Một bài giúp hạ nhiệt nhé?',
  'Mây có một bài giúp cơn giận lắng xuống. Thử không?',
  'Khi bực lên, vài phút thở sẽ kéo bạn về lại với mình.',
  'Một bài thiền làm dịu, cho những lúc trong lòng còn nóng.',
  'Thở chậm lại cùng Mây nhé, để cơn giận có chỗ hạ xuống.',
  'Cơn giận cần một chỗ để đi qua. Mây có một bài cho việc đó.',
  'Một bài ngắn để nguôi giận. Mây ngồi cùng bạn.',
];

const _medStressed = [
  'Mấy hôm bạn hơi căng. Một bài thư giãn để buông nhé?',
  'Cơ thể bạn đang gồng. Mây có một bài cho việc đó.',
  'Không cần cố nữa. Vài phút thả lỏng cùng Mây thôi.',
  'Một bài thiền để áp lực trong người được xả ra.',
  'Căng quá thì dừng lại, bật một bài buông nhé.',
  'Mây có một bài nhẹ để bạn hạ nhiệt một chút.',
  'Ngày dồn dập quá. Khép lại bằng một bài thư giãn nhé.',
];

const _medEveningStreak = [
  '{streak} ngày thiền rồi. Tối nay tiếp nhé?',
  'Giữ nhịp nào — một bài ngắn trước khi ngủ.',
  'Mây quen có bạn mỗi tối rồi. Nghe một bài nhé?',
  'Đừng để tối nay lỡ nhịp. Mây đợi bạn.',
  'Chuỗi thiền của bạn đang đẹp. Thêm tối nay nữa.',
  'Vài phút quen thuộc trước khi ngủ nhé?',
  'Bạn bền bỉ thật. Một bài nữa cho tối nay.',
];

const _medEvening = [
  'Tối rồi. Buông ngày dài bằng một bài thiền nhé.',
  'Một bài ngắn trước khi ngủ, để ngủ sâu hơn.',
  'Ngày khép lại nhẹ hơn nếu bạn thở cùng Mây.',
  'Đặt điện thoại xuống sau bài này nhé. Mây dẫn bạn.',
  'Vài phút tĩnh lặng trước giấc ngủ. Bắt đầu nhé?',
  'Mây pha sẵn buổi tối yên tĩnh. Nghe một bài không?',
  'Trước khi ngủ, cho tâm trí một khoảng lặng nhé.',
];
