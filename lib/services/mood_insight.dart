import 'dart:math';

import '../models/journal_entry.dart';
import '../models/mood.dart';

const _positiveMoods = {Mood.vui, Mood.binhThuong};
const _negativeMoods = {Mood.loLang, Mood.buon, Mood.cangThang, Mood.tucGian};

const _weekdaysLower = ['thứ Hai', 'thứ Ba', 'thứ Tư', 'thứ Năm', 'thứ Sáu', 'thứ Bảy', 'Chủ nhật'];
const _weekdaysCap = ['Thứ Hai', 'Thứ Ba', 'Thứ Tư', 'Thứ Năm', 'Thứ Sáu', 'Thứ Bảy', 'Chủ nhật'];

String _timeOfDay(int hour) {
  if (hour < 12) return 'sáng';
  if (hour < 18) return 'chiều';
  return 'tối';
}

class MoodInsight {
  final String label;
  final String text;
  const MoodInsight(this.label, this.text);
}

const _labelNoticed = 'MÂY NHẬN THẤY';
const _labelEncourage = 'MÂY NHẮN NHỦ';

// "Mây nhận thấy" — data-driven only. Every sentence here starts with either
// a fixed word or a capitalized weekday ({pDay}); {nTime}/{nDay} are always
// lowercase so they must never open a sentence (that reads as a typo).
const _bothTemplates = [
  'Bạn thấy dễ chịu nhất vào {pDay}, và hay nặng lòng hơn vào {nTime} {nDay}.',
  '{pDay} thường là ngày nhẹ nhõm nhất của bạn, trong khi {nTime} {nDay} lại hay mang nhiều cảm xúc khó chịu hơn.',
  'Mình để ý {pDay} bạn hay thấy ổn, còn {nTime} {nDay} thì dễ căng thẳng hơn.',
  'Cảm xúc của bạn thường tích cực vào {pDay}, và chùng xuống vào {nTime} {nDay}.',
  'Có vẻ {pDay} là ngày dễ chịu với bạn, còn {nTime} {nDay} thì ngược lại.',
  'Bạn có xu hướng thoải mái hơn vào {pDay}, và hay khó chịu trong lòng vào {nTime} {nDay}.',
  '{pDay} là lúc bạn cảm thấy nhẹ nhàng nhất, {nTime} {nDay} lại là lúc cảm xúc nặng nề ghé thăm nhiều nhất.',
  'Nhìn lại, {pDay} bạn khá thoải mái, nhưng {nTime} {nDay} thường khiến bạn khó chịu hơn.',
];

const _positiveOnlyTemplates = [
  'Bạn thấy dễ chịu nhất vào {pDay}.',
  '{pDay} có vẻ là ngày dễ chịu nhất của bạn gần đây.',
  'Mình thấy {pDay} bạn thường cảm thấy ổn hơn hẳn.',
  'Cảm xúc của bạn nhẹ nhõm nhất vào {pDay}.',
  '{pDay} dường như mang lại cho bạn nhiều niềm vui hơn những ngày khác.',
  'Bạn có xu hướng vui vẻ, thoải mái hơn vào {pDay}.',
  'Nhìn chung {pDay} là ngày tích cực nhất của bạn.',
  'Có vẻ {pDay} luôn là điểm sáng trong khoảng này.',
];

const _negativeOnlyTemplates = [
  'Bạn hay khó chịu trong lòng vào {nTime} {nDay}.',
  'Có vẻ {nTime} {nDay} thường là lúc bạn dễ căng thẳng nhất.',
  'Mình để ý {nTime} {nDay} hay khiến bạn mệt mỏi hơn.',
  'Cảm xúc của bạn hay chùng xuống vào {nTime} {nDay}.',
  'Có vẻ {nTime} {nDay} không phải là khoảng thời gian dễ chịu với bạn.',
  'Dường như {nTime} {nDay} là lúc cảm xúc khó chịu hay ghé thăm bạn nhất.',
  'Bạn thường thấy nặng lòng hơn vào {nTime} {nDay}.',
  'Nhìn lại, {nTime} {nDay} hay là lúc bạn cần được nghỉ ngơi nhất.',
];

// Intensity tail clauses — appended to a "Mây nhận thấy" sentence when the
// average slider value on that side was clearly high or low. Each starts
// with a leading space and ends with its own period.
const _posHighIntensityTail = [
  ' Và những lúc vui đó cũng khá rõ rệt, không chỉ là nhẹ nhàng thoáng qua.',
  ' Niềm vui những hôm đó cũng lên khá cao đấy.',
  ' Mình để ý niềm vui những hôm đó khá đậm.',
];

const _posLowIntensityTail = [
  ' Dù vậy, niềm vui những hôm đó cũng chỉ nhẹ nhàng thôi.',
  ' Những lúc đó cũng không phải vui bùng nổ gì, chỉ là dễ chịu nhẹ.',
];

const _negHighIntensityTail = [
  ' Và cảm xúc những lúc đó khá mạnh, không chỉ là hơi khó chịu.',
  ' Mình để ý mức độ những hôm đó khá cao, không phải chuyện nhỏ.',
  ' Cảm xúc đó cũng không nhẹ đâu, khá rõ rệt.',
];

const _negLowIntensityTail = [
  ' Dù vậy, mức độ những lúc đó cũng khá nhẹ, không nặng lắm.',
  ' Những lúc đó cũng chỉ hơi khó chịu thôi, không quá nặng.',
];

// "Mây nhắn nhủ" — used only when there isn't enough data for a real
// observation. Generic encouragement about meditating, not a claim about
// the user's own data, so no accuracy risk.
const _encourageTemplates = [
  'Mỗi sáng dành ba phút cho hơi thở, cả ngày sẽ nhẹ nhàng hơn rất nhiều.',
  'Một buổi thiền ngắn trước khi ngủ giúp tâm trí bạn thật sự được nghỉ ngơi.',
  'Thử thiền vào buổi sáng xem sao — bắt đầu ngày mới với một tâm trí tĩnh lặng.',
  'Chỉ năm phút mỗi tối cũng đủ để bạn buông bớt những lo âu trong ngày.',
  'Duy trì thói quen thiền đều đặn giúp bạn bình tĩnh hơn trước những điều bất ngờ.',
  'Một hơi thở sâu, một khoảnh khắc chậm lại — đó đã là thiền rồi.',
  'Buổi tối là lúc tuyệt vời để thiền, giúp bạn ngủ ngon và sâu hơn.',
  'Hãy thử dành ra vài phút mỗi sáng để lắng nghe cơ thể mình trước khi bắt đầu ngày mới.',
  'Thiền đều đặn không cần nhiều thời gian, chỉ cần đều đặn.',
  'Một chút tĩnh lặng mỗi ngày giúp bạn hiểu cảm xúc của mình rõ hơn.',
  'Bạn đã thử thiền hôm nay chưa? Chỉ vài phút thôi cũng tạo ra khác biệt.',
  'Buổi sáng sớm, khi tâm trí còn tĩnh, là thời điểm rất tốt để bắt đầu thiền.',
  'Thiền trước khi ngủ giúp những suy nghĩ ngổn ngang trong ngày lắng lại.',
  'Duy trì một nhịp thiền đều đặn — sáng hoặc tối — sẽ giúp bạn cảm thấy vững vàng hơn.',
  'Chăm sóc tâm trí cũng quan trọng như chăm sóc cơ thể — hãy dành thời gian cho nó mỗi ngày.',
  'Một vài hơi thở chậm rãi vào buổi sáng có thể thay đổi cả ngày của bạn.',
  'Thử dành cho mình một khoảng lặng nhỏ mỗi tối, trước khi những suy nghĩ ùa về.',
  'Thiền không cần hoàn hảo, chỉ cần bạn quay lại với nó mỗi ngày.',
  'Một thói quen thiền nhỏ mỗi sáng sẽ giúp bạn phản ứng nhẹ nhàng hơn với căng thẳng.',
  'Buổi tối là lúc lý tưởng để thả lỏng và để cơ thể bạn thật sự nghỉ ngơi.',
  'Bạn không cần nhiều thời gian — chỉ vài phút thiền mỗi ngày cũng đủ tạo thay đổi.',
  'Hãy biến thiền buổi sáng thành một phần nhỏ trong nhịp sống của bạn.',
  'Một buổi thiền ngắn giữa ngày có thể giúp bạn lấy lại sự tập trung.',
  'Đều đặn quan trọng hơn thời lượng — thiền năm phút mỗi ngày tốt hơn năm mươi phút một lần.',
  'Hãy thử kết thúc một ngày dài bằng một bài thiền nhẹ nhàng thay vì lướt điện thoại.',
  'Thiền giúp bạn tạo một khoảng cách nhỏ giữa cảm xúc và phản ứng — rất đáng để luyện tập mỗi ngày.',
  'Mỗi buổi sáng bắt đầu bằng vài phút tĩnh lặng, bạn sẽ thấy mình bình tĩnh hơn cả ngày dài.',
  'Nếu hôm nay chưa thiền, buổi tối vẫn còn kịp — chỉ cần vài phút thôi.',
  'Một tâm trí được nghỉ ngơi mỗi ngày sẽ giúp bạn đón nhận mọi thứ nhẹ nhàng hơn.',
  'Hãy thử biến thiền thành điểm dừng nhỏ giữa những điều bận rộn trong ngày.',
];

/// Picks a (factually accurate) insight from [entriesInRange]. [seed] makes
/// the choice of template stable — pass the same seed (e.g. derived from
/// today's date + which view is active) across rebuilds so the sentence
/// doesn't reshuffle every time the screen happens to redraw, only actually
/// changing once a day. When there's a real pattern in the data, returns a
/// "Mây nhận thấy" observation built only from what's actually there. When
/// there isn't enough data, returns a "Mây nhắn nhủ" encouragement instead —
/// never a vague filler mislabeled as a finding.
MoodInsight generateInsight(List<JournalEntry> entriesInRange, {int seed = 0}) {
  final posCount = <int, int>{};
  final negSlot = <String, int>{};
  var posIntensitySum = 0, posIntensityN = 0;
  var negIntensitySum = 0, negIntensityN = 0;
  for (final e in entriesInRange) {
    if (_positiveMoods.contains(e.mood)) {
      posCount[e.entryDate.weekday] = (posCount[e.entryDate.weekday] ?? 0) + 1;
      posIntensitySum += e.intensity;
      posIntensityN++;
    } else if (_negativeMoods.contains(e.mood)) {
      final key = '${e.entryDate.weekday}|${_timeOfDay(e.entryDate.hour)}';
      negSlot[key] = (negSlot[key] ?? 0) + 1;
      negIntensitySum += e.intensity;
      negIntensityN++;
    }
  }

  String? pDay;
  if (posCount.isNotEmpty) {
    final top = posCount.entries.reduce((a, b) => a.value >= b.value ? a : b);
    pDay = _weekdaysCap[top.key - 1];
  }
  String? nDay;
  String? nTime;
  if (negSlot.isNotEmpty) {
    final top = negSlot.entries.reduce((a, b) => a.value >= b.value ? a : b);
    final parts = top.key.split('|');
    nDay = _weekdaysLower[int.parse(parts[0]) - 1];
    nTime = parts[1];
  }
  final posAvg = posIntensityN > 0 ? posIntensitySum / posIntensityN : null;
  final negAvg = negIntensityN > 0 ? negIntensitySum / negIntensityN : null;

  final rand = Random(seed);
  String pick(List<String> pool) => pool[rand.nextInt(pool.length)];

  // Weaves in one honest clause about how strong the average intensity (the
  // 1–10 slider) was on the relevant side, when it was clearly high (≥7) or
  // clearly low (≤3) — and only about half the time, so it stays a texture
  // rather than a mechanical add-on.
  String withIntensity(String text, {bool pos = false, bool neg = false}) {
    final tails = <String>[];
    if (pos && posAvg != null) {
      tails.addAll(posAvg >= 7 ? _posHighIntensityTail : (posAvg <= 3 ? _posLowIntensityTail : const []));
    }
    if (neg && negAvg != null) {
      tails.addAll(negAvg >= 7 ? _negHighIntensityTail : (negAvg <= 3 ? _negLowIntensityTail : const []));
    }
    if (tails.isEmpty || rand.nextDouble() > 0.5) return text;
    return '$text${tails[rand.nextInt(tails.length)]}';
  }

  if (pDay != null && nDay != null) {
    final text = pick(_bothTemplates).replaceAll('{pDay}', pDay).replaceAll('{nDay}', nDay).replaceAll('{nTime}', nTime!);
    return MoodInsight(_labelNoticed, withIntensity(text, pos: true, neg: true));
  }
  if (pDay != null) {
    final text = pick(_positiveOnlyTemplates).replaceAll('{pDay}', pDay);
    return MoodInsight(_labelNoticed, withIntensity(text, pos: true));
  }
  if (nDay != null) {
    final text = pick(_negativeOnlyTemplates).replaceAll('{nDay}', nDay).replaceAll('{nTime}', nTime!);
    return MoodInsight(_labelNoticed, withIntensity(text, neg: true));
  }
  return MoodInsight(_labelEncourage, pick(_encourageTemplates));
}
