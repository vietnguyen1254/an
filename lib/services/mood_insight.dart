import 'dart:math';

import '../models/journal_entry.dart';
import '../models/mood.dart';

const _positiveMoods = {Mood.binhYen, Mood.vui, Mood.binhThuong};
const _negativeMoods = {Mood.loLang, Mood.buon, Mood.kietSuc};

const _weekdaysLower = ['thứ Hai', 'thứ Ba', 'thứ Tư', 'thứ Năm', 'thứ Sáu', 'thứ Bảy', 'Chủ nhật'];
const _weekdaysCap = ['Thứ Hai', 'Thứ Ba', 'Thứ Tư', 'Thứ Năm', 'Thứ Sáu', 'Thứ Bảy', 'Chủ nhật'];

String _timeOfDay(int hour) {
  if (hour < 12) return 'sáng';
  if (hour < 18) return 'chiều';
  return 'tối';
}

// Sentence banks, grouped by what the underlying data actually supports —
// never fill a placeholder with a guess, only pick from the bucket that
// matches what was really found in entriesInRange.
const _bothTemplates = [
  'Bạn bình yên nhất vào {pDay}, và hay lo lắng vào {nTime} {nDay}.',
  '{pDay} thường là ngày nhẹ nhõm nhất của bạn, trong khi {nTime} {nDay} lại hay mang nhiều lo âu hơn.',
  'Mình để ý {pDay} bạn hay thấy ổn, còn {nTime} {nDay} thì dễ căng thẳng hơn.',
  'Cảm xúc của bạn thường tích cực vào {pDay}, và chùng xuống vào {nTime} {nDay}.',
  'Có vẻ {pDay} là ngày dễ chịu với bạn, còn {nTime} {nDay} thì ngược lại.',
  'Bạn có xu hướng bình yên hơn vào {pDay}, và hay bồn chồn vào {nTime} {nDay}.',
  '{pDay} là lúc bạn cảm thấy nhẹ nhàng nhất, {nTime} {nDay} lại là lúc lo âu ghé thăm nhiều nhất.',
  'Nhìn lại, {pDay} bạn khá thoải mái, nhưng {nTime} {nDay} thường khiến bạn lo lắng hơn.',
];

const _positiveOnlyTemplates = [
  'Bạn bình yên nhất vào {pDay}.',
  '{pDay} có vẻ là ngày dễ chịu nhất của bạn gần đây.',
  'Mình thấy {pDay} bạn thường cảm thấy ổn hơn hẳn.',
  'Cảm xúc của bạn nhẹ nhõm nhất vào {pDay}.',
  '{pDay} dường như mang lại cho bạn nhiều bình yên hơn những ngày khác.',
  'Bạn có xu hướng vui vẻ, thoải mái hơn vào {pDay}.',
  'Nhìn chung {pDay} là ngày tích cực nhất của bạn.',
  'Có vẻ {pDay} luôn là điểm sáng trong khoảng này.',
];

const _negativeOnlyTemplates = [
  'Bạn hay lo lắng vào {nTime} {nDay}.',
  '{nTime} {nDay} thường là lúc bạn dễ căng thẳng nhất.',
  'Mình để ý {nTime} {nDay} hay khiến bạn mệt mỏi hơn.',
  'Cảm xúc của bạn hay chùng xuống vào {nTime} {nDay}.',
  'Có vẻ {nTime} {nDay} không phải là khoảng thời gian dễ chịu với bạn.',
  '{nTime} {nDay} dường như là lúc lo âu hay ghé thăm bạn nhất.',
  'Bạn thường thấy nặng lòng hơn vào {nTime} {nDay}.',
  'Nhìn lại, {nTime} {nDay} hay là lúc bạn cần được nghỉ ngơi nhất.',
];

const _noPatternTemplates = [
  'Mây cần thêm vài ngày ghi nhận nữa để hiểu bạn rõ hơn.',
  'Ghi lại đều đặn hơn một chút, Mây sẽ nhận ra được nhịp cảm xúc của bạn.',
  'Chưa đủ dữ liệu để Mây nhận ra quy luật rõ ràng — cứ tiếp tục ghi nhé.',
  'Mây đang lắng nghe, nhưng cần thêm thời gian để hiểu bạn hơn.',
  'Cảm xúc của bạn khá đa dạng trong khoảng này, chưa thấy ngày nào nổi bật hẳn.',
  'Mây chưa thấy quy luật rõ ràng — mỗi ngày của bạn đều khác nhau.',
];

/// Picks a random (but factually accurate) insight sentence from
/// [entriesInRange]. Never fabricates a day/time that isn't backed by the
/// actual data — falls back to an honest "not enough data" line instead.
String generateInsight(List<JournalEntry> entriesInRange) {
  final posCount = <int, int>{};
  final negSlot = <String, int>{};
  for (final e in entriesInRange) {
    if (_positiveMoods.contains(e.mood)) {
      posCount[e.entryDate.weekday] = (posCount[e.entryDate.weekday] ?? 0) + 1;
    } else if (_negativeMoods.contains(e.mood)) {
      final key = '${e.entryDate.weekday}|${_timeOfDay(e.entryDate.hour)}';
      negSlot[key] = (negSlot[key] ?? 0) + 1;
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

  final rand = Random();
  String pick(List<String> pool) => pool[rand.nextInt(pool.length)];

  if (pDay != null && nDay != null) {
    return pick(_bothTemplates).replaceAll('{pDay}', pDay).replaceAll('{nDay}', nDay).replaceAll('{nTime}', nTime!);
  }
  if (pDay != null) {
    return pick(_positiveOnlyTemplates).replaceAll('{pDay}', pDay);
  }
  if (nDay != null) {
    return pick(_negativeOnlyTemplates).replaceAll('{nDay}', nDay).replaceAll('{nTime}', nTime!);
  }
  return pick(_noPatternTemplates);
}
