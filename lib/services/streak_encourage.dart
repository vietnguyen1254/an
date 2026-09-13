import 'dart:math';

import '../models/mood.dart';
import 'meditation_recommend.dart' show moodCategory;

/// Builds the encouragement line on the "Cảm ơn bạn đã kể" screen.
///
/// The line is *composed*, not picked from a fixed list: one clause that
/// reflects today's recorded mood (and, when the user tagged one, the topic
/// they picked), joined to one clause about the real streak / Mây being
/// there / a meditation that fits the mood. Every fragment is a complete
/// sentence, so any join is grammatical, and each pool only holds lines that
/// are *true* for that mood — a sad day never gets a "keep shining" line, and
/// the meditation nudge always matches the mood's category.
///
/// ~200 fragments combine into several thousand distinct messages;
/// [_recent] stops the same one showing twice in a row.

enum MoodTrend { none, firstEver, returned, lifted, dipped, steadyLight, steadyHeavy }

const _positiveMoods = {Mood.vui, Mood.binhThuong};
const _negativeMoods = {Mood.loLang, Mood.buon, Mood.cangThang, Mood.tucGian};

/// Works out the arc of today's check-in from the recorded history so the
/// message can reflect it truthfully. [pastMoods] is every earlier entry's
/// mood, most-recent first; [streak] and [totalEntries] come from AppState
/// (called *after* today's entry is saved, so it is counted in both).
MoodTrend computeMoodTrend(
  Mood today,
  List<Mood> pastMoods, {
  required int streak,
  required int totalEntries,
}) {
  if (totalEntries <= 1) return MoodTrend.firstEver;
  if (streak <= 1) return MoodTrend.returned;
  if (pastMoods.isEmpty) return MoodTrend.none;
  final prev = pastMoods.first;
  final todayPos = _positiveMoods.contains(today);
  final prevPos = _positiveMoods.contains(prev);
  final recent = pastMoods.take(3);
  final recentPos = recent.where(_positiveMoods.contains).length;
  final recentNeg = recent.where(_negativeMoods.contains).length;
  if (todayPos && !prevPos) return MoodTrend.lifted;
  if (!todayPos && prevPos) return MoodTrend.dipped;
  if (todayPos && recentPos >= 2) return MoodTrend.steadyLight;
  if (!todayPos && recentNeg >= 2) return MoodTrend.steadyHeavy;
  return MoodTrend.none;
}

final _rand = Random();
final List<String> _recent = [];

String _cap(String s) => s.isEmpty ? s : s[0].toUpperCase() + s.substring(1);

String _pick(List<String> pool) => pool[_rand.nextInt(pool.length)];

String _join(String opener, String? forward) {
  final o = opener.trim();
  if (forward == null || forward.trim().isEmpty) return '$o.';
  return '$o. ${_cap(forward.trim())}.';
}

/// [tagLabel] — the topic picked during check-in ("Công việc" …), or null.
/// [trend] — from [computeMoodTrend]. [intensity] — the 1–10 slider value;
/// only Mood.vui and the negative moods get an intensity-aware tail clause
/// (an 8+ or a 1–2 on those reads as meaningfully strong/mild — a "mạnh"
/// Bình thường doesn't mean anything, so it's left alone).
String generateStreakMessage(
  Mood mood,
  int streak, {
  String? tagLabel,
  MoodTrend trend = MoodTrend.none,
  int intensity = 5,
}) {
  final cat = moodCategory[mood];
  final negative = _negativeMoods.contains(mood);
  final milestone = _milestones[streak];

  String build() {
    // Trend-driven openers take over the whole first clause.
    if (trend == MoodTrend.firstEver) {
      return _join(_pick(_openFirst), null);
    }
    if (trend == MoodTrend.returned) {
      final f = _rand.nextDouble() < 0.35 && cat != null ? _pick(_forwardMeditation[cat]!) : null;
      return _join(_pick(_openReturned), f);
    }
    if (trend == MoodTrend.lifted) {
      final pool = [..._forwardStreak, if (cat != null) ..._forwardMeditation[cat]!];
      final f = _rand.nextDouble() < 0.7 ? _pick(pool) : null;
      return _join(_pick(_openLifted), f);
    }
    if (trend == MoodTrend.dipped) {
      final pool = [..._forwardHere, if (cat != null) ..._forwardMeditation[cat]!];
      final f = _rand.nextDouble() < 0.7 ? _pick(pool) : null;
      return _join(_pick(_openDipped), f);
    }

    // Opener: mood, optionally weaving the tag.
    final opener = (tagLabel != null && _rand.nextDouble() < 0.5)
        ? _pick(_empathyTag[mood]!)
        : _pick(_empathy[mood]!);

    if (milestone != null) return _join(opener, _pick(milestone));
    if (trend == MoodTrend.steadyLight) return _join(opener, _pick(_forwardSteadyLight));
    if (trend == MoodTrend.steadyHeavy) return _join(opener, _pick(_forwardSteadyHeavy));

    // Forward: presence/gentle for a hard day, streak/journey for a light one;
    // a matching meditation nudge is in both pools. Sometimes the opener alone
    // is enough.
    final forwardPool = [
      ...(negative ? _forwardHere : _forwardStreak),
      if (cat != null) ..._forwardMeditation[cat]!,
    ];
    final forward = _rand.nextDouble() < (negative ? 0.85 : 0.8) ? _pick(forwardPool) : null;
    return _join(opener, forward);
  }

  var msg = build();
  for (var i = 0; i < 8 && _recent.contains(msg); i++) {
    msg = build();
  }
  _recent.add(msg);
  if (_recent.length > 16) _recent.removeAt(0);

  msg = msg.replaceAll('{streak}', '$streak');
  if (tagLabel != null) msg = msg.replaceAll('{tag}', tagLabel.toLowerCase());
  msg = _appendIntensityTail(msg, mood, intensity);
  return _cap(msg);
}

/// Weaves in one honest clause about the strength of the feeling, when the
/// slider was clearly high (8–10) or clearly low (1–2) — mid-range (the vast
/// majority of check-ins) gets no extra clause, and only kicks in about half
/// the time even when it applies, so it never feels mechanical.
String _appendIntensityTail(String msg, Mood mood, int intensity) {
  List<String>? pool;
  if (mood == Mood.vui) {
    if (intensity >= 8) pool = _highIntensityPositive;
    if (intensity <= 2) pool = _lowIntensityPositive;
  } else if (_negativeMoods.contains(mood)) {
    if (intensity >= 8) pool = _highIntensityNegative;
    if (intensity <= 2) pool = _lowIntensityNegative;
  }
  if (pool == null || _rand.nextDouble() > 0.5) return msg;
  return '$msg ${_cap(_pick(pool))}.';
}

const _highIntensityPositive = [
  'niềm vui hôm nay khá lớn, cứ tận hưởng nó nhé',
  'mức độ hôm nay cao đấy, một ngày vui rõ rệt',
  'đây không phải kiểu vui nhẹ nhàng thoáng qua, mà là vui thật rõ',
];

const _lowIntensityPositive = [
  'chỉ là một niềm vui nhỏ, nhưng vẫn đáng được ghi lại',
  'nhẹ thôi, nhưng vẫn là vui, và điều đó cũng đủ quý',
  'một chút vui cũng đáng kể, không cần phải lớn mới tính',
];

const _highIntensityNegative = [
  'mức độ hôm nay khá cao, đây không phải chuyện nhỏ đâu',
  'cảm xúc này lên khá mạnh, không chỉ là hơi khó chịu thôi',
  'hôm nay bạn cảm nhận điều này rất rõ, không mơ hồ chút nào',
];

const _lowIntensityNegative = [
  'mức độ hôm nay nhẹ thôi, nhưng vẫn đáng được gọi tên',
  'chỉ là một chút, không nặng lắm, và ghi lại vẫn tốt',
  'cảm giác này khá nhẹ hôm nay, không cần phải to mới đáng kể',
];

// ─────────────────────────────────────────────────────────────────────────
// Opener pools — a complete sentence about how today feels. No trailing dot.
// ─────────────────────────────────────────────────────────────────────────

const _empathy = {
  Mood.tucGian: [
    'hôm nay có điều gì đó khiến bạn tức giận, và bạn đã không nuốt nó vào trong',
    'Mây cảm được sự nóng trong những dòng này của bạn',
    'hôm nay bạn giận, và cảm xúc đó xứng đáng được gọi thẳng tên',
    'có một cơn bực dọc trong bạn hôm nay, Mây nghe thấy rồi',
    'bạn đang tức, và bạn không cần phải xin lỗi vì điều đó',
    'hôm nay có chuyện gì đó chưa được giải quyết, và nó làm bạn nóng lên',
    'sự tức giận hôm nay của bạn là thật, không phải bạn đang quá đáng',
    'bạn vừa để Mây thấy một ngày đầy lửa của mình',
    'lòng bạn hôm nay không êm, có gì đó đang réo lên bên trong',
    'hôm nay bạn khó mà bình tĩnh, và bạn vẫn cố gọi tên cảm xúc đó',
    'cơn giận hôm nay của bạn xứng đáng được lắng nghe, không phải bị dập tắt',
    'bạn đang mang một ngọn lửa trong lòng, và bạn không giấu Mây',
  ],
  Mood.vui: [
    'bạn đang vui, và Mây thấy được điều đó qua từng chữ bạn viết',
    'hôm nay có gì đó khiến bạn nhẹ lòng, và Mây mừng lây',
    'niềm vui của bạn hôm nay làm Mây mỉm cười theo',
    'bạn tỏa nắng một chút hôm nay đấy',
    'một ngày vui, cảm ơn bạn đã mang nó tới kể cho Mây',
    'Mây nghe thấy tiếng cười phía sau những dòng này của bạn',
    'hôm nay bạn thấy phấn chấn, và điều đó thật đáng để ghi lại',
    'bạn đang ở trong một ngày đẹp của mình',
    'có một năng lượng ấm trong những gì bạn vừa kể',
    'niềm vui hôm nay của bạn là có thật, không phải cố để vui',
    'Mây rất vui khi được nghe một ngày như thế này của bạn',
    'bạn vừa chia sẻ một khoảnh khắc sáng trong ngày của mình',
  ],
  Mood.binhThuong: [
    'hôm nay là một ngày bình thường, và bạn vẫn ghé kể cho Mây nghe',
    'không có gì đặc biệt hôm nay, và điều đó hoàn toàn ổn',
    'một ngày đều đều, phần lớn cuộc sống được làm từ những ngày như vậy',
    'bạn không vui hẳn cũng không buồn hẳn, chỉ đang đi qua ngày của mình',
    'hôm nay bạn thấy tạm ổn, và bạn đã thành thật nói ra điều đó',
    'Mây trân trọng cả những ngày không có gì để kể như hôm nay',
    'bình thường cũng là một trạng thái, và nó đáng được ghi nhận',
    'bạn đang ở mức "ổn thôi" hôm nay, Mây nghe rồi',
    'một ngày phẳng lặng, không phải ngày nào cũng cần lên xuống',
    'hôm nay chỉ là hôm nay, và bạn vẫn dành cho mình vài phút này',
    'bạn vừa kể cho Mây nghe một ngày rất đỗi bình thường, và Mây lắng nghe trọn vẹn',
    'không có sóng gió hôm nay, đôi khi đó đã là một tin tốt',
  ],
  Mood.loLang: [
    'hôm nay bạn thấy lo, và bạn vẫn ngồi xuống gọi tên nỗi lo đó',
    'có gì đó đang làm bạn bồn chồn hôm nay',
    'Mây nghe thấy sự căng thẳng trong những dòng này của bạn',
    'lòng bạn hôm nay chưa yên, và điều đó không sao cả',
    'bạn đang mang một nỗi lo, và bạn đã không giấu Mây',
    'hôm nay đầu bạn có nhiều tiếng ồn hơn bình thường',
    'sự lo âu hôm nay là thật, nhưng nó không phải là toàn bộ bạn',
    'bạn thấy chông chênh một chút hôm nay',
    'có một vòng suy nghĩ cứ quay trong bạn hôm nay, Mây hiểu',
    'hôm nay bạn khó ngồi yên với chính mình, và bạn vẫn cố',
    'nỗi lo hôm nay của bạn xứng đáng được lắng nghe, không phải bị gạt đi',
    'bạn vừa kể cho Mây nghe một ngày nhiều lo lắng, và Mây nghe hết rồi',
  ],
  Mood.buon: [
    'hôm nay lòng bạn nặng, và bạn vẫn nói ra được điều đó',
    'có một nỗi buồn trong bạn hôm nay, Mây nghe thấy rồi',
    'hôm nay là một ngày khó với bạn',
    'bạn đang buồn, và bạn không cần phải xin lỗi vì điều đó',
    'Mây cảm được sự chùng xuống trong những dòng này của bạn',
    'hôm nay có gì đó làm bạn hụt hẫng',
    'nỗi buồn hôm nay của bạn là thật, và nó có chỗ ở đây',
    'bạn vừa để Mây nhìn thấy một ngày buồn của mình, cảm ơn bạn vì đã tin',
    'lòng bạn hôm nay không nhẹ, Mây biết',
    'hôm nay bạn thấy trống trải một chút',
    'bạn đang đi qua một quãng không dễ chịu, và bạn vẫn ghi lại',
    'một ngày mà mọi thứ hơi mờ đi, và bạn vẫn gọi tên được nó',
  ],
  Mood.cangThang: [
    'hôm nay bạn thấy căng, và cơ thể bạn đang gồng lên vì điều đó',
    'có quá nhiều thứ dồn lại một lúc, và hôm nay bạn thấy ngộp',
    'Mây cảm được sự căng trong từng chữ bạn viết',
    'hôm nay đầu bạn không lúc nào ngơi, quá nhiều việc cùng lúc',
    'có một áp lực đang đè lên bạn hôm nay, Mây hiểu',
    'bạn đang gồng để xoay hết mọi thứ, không phải vì bạn yếu',
    'hôm nay bạn quá tải, và đó là một tín hiệu, không phải một lỗi',
    'bạn vừa kể cho Mây nghe một ngày dồn ép bạn tới giới hạn',
    'vai và hàm bạn hôm nay chắc đang căng lắm',
    'hôm nay bạn không có chỗ để thở, mọi thứ cứ chồng lên nhau',
    'sự căng thẳng hôm nay của bạn xứng đáng được giảm tải, không phải bị phớt lờ',
    'bạn đã gắng xoay đủ thứ hôm nay, và giờ là lúc chậm lại',
  ],
};

/// Same idea, weaving the topic the user tagged ({tag}, always lowercase and
/// mid-sentence — "chuyện {tag}" reads fine for every tag label).
const _empathyTag = {
  Mood.tucGian: [
    'chuyện {tag} hôm nay làm bạn nóng mặt',
    'Mây thấy {tag} đang khiến bạn khó chịu, thậm chí tức giận',
    'cơn giận hôm nay của bạn phần nhiều là vì {tag}',
    'chuyện {tag} chưa được giải quyết, và nó cứ chọc vào bạn',
    'hôm nay {tag} khiến lòng bạn dậy sóng',
    'bạn đang giận vì {tag}, và điều đó hoàn toàn dễ hiểu',
  ],
  Mood.vui: [
    'chuyện {tag} hôm nay mang lại cho bạn một niềm vui nhỏ',
    'có vẻ {tag} đang suôn sẻ, và bạn thấy phấn chấn hẳn',
    'Mây thấy chuyện {tag} đang làm bạn mỉm cười hôm nay',
    'niềm vui hôm nay của bạn có một phần đến từ {tag}',
    'chuyện {tag} dạo này nhẹ nhõm hơn, và bạn cũng vậy',
    'hôm nay {tag} cho bạn một lý do để vui',
  ],
  Mood.binhThuong: [
    'chuyện {tag} hôm nay không có gì mới, và bạn thấy bình bình',
    'chuyện {tag} vẫn đều đều, giống như cảm xúc hôm nay của bạn',
    'không có gì nổi bật về {tag} hôm nay, và điều đó cũng ổn',
    'chuyện {tag} dạo này tạm ổn, không hơn không kém',
    'hôm nay {tag} chỉ là một phần bình thường trong ngày của bạn',
    'chuyện {tag} không làm bạn xáo trộn gì hôm nay',
  ],
  Mood.loLang: [
    'chuyện {tag} dạo này đang làm bạn lo',
    'Mây thấy {tag} đang chiếm khá nhiều tâm trí bạn hôm nay',
    'nỗi lo hôm nay của bạn phần nhiều là về {tag}',
    'chuyện {tag} chưa ngã ngũ, và bạn thì cứ nghĩ mãi về nó',
    'hôm nay {tag} khiến lòng bạn không yên',
    'bạn đang lo về {tag}, và điều đó hoàn toàn dễ hiểu',
  ],
  Mood.buon: [
    'chuyện {tag} hôm nay làm bạn buồn',
    'Mây thấy {tag} đang khiến lòng bạn nặng xuống',
    'nỗi buồn hôm nay của bạn có liên quan tới {tag}',
    'chuyện {tag} không như bạn mong, và bạn thấy hụt hẫng',
    'hôm nay {tag} chạm vào một chỗ đau trong bạn',
    'bạn đang buồn vì {tag}, và nỗi buồn đó là chính đáng',
  ],
  Mood.cangThang: [
    'chuyện {tag} dạo này đang dồn ép bạn',
    'Mây thấy {tag} đang khiến bạn quá tải',
    'sự căng thẳng hôm nay của bạn phần lớn đến từ {tag}',
    'chuyện {tag} bắt bạn gồng lâu quá rồi',
    'hôm nay {tag} khiến bạn không có chỗ để thở',
    'bạn đang căng vì {tag}, và cơ thể bạn cần được giảm tải',
  ],
};

// ─────────────────────────────────────────────────────────────────────────
// Forward pools — the second clause. No trailing dot. {streak} allowed.
// ─────────────────────────────────────────────────────────────────────────

/// Streak / journey — for a positive or neutral day.
const _forwardStreak = [
  '{streak} ngày liên tục rồi, bạn đang giữ một nhịp rất đẹp cho mình',
  'vậy là {streak} ngày bạn đều đặn ghé qua, điều đó không dễ đâu',
  '{streak} ngày rồi đấy, Mây thích cách bạn kiên trì với chính mình',
  'ngày thứ {streak} của bạn ở An, cảm ơn bạn vì sự bền bỉ này',
  '{streak} ngày ghi lại cảm xúc liên tục, bạn đang hiểu mình hơn từng ngày',
  'bạn đã kể cho Mây nghe {streak} ngày liền, Mây quý điều đó lắm',
  '{streak} ngày rồi, và bạn vẫn ở đây, cứ tiếp tục nhé',
  'con số {streak} ngày là kết quả của rất nhiều lần bạn chọn quay lại',
  '{streak} ngày liên tục, một thói quen tử tế đang lớn lên trong bạn',
  'ngày thứ {streak} rồi, bạn đang làm điều mà phần lớn người ta bỏ dở',
  '{streak} ngày bạn dành vài phút cho mình, nghe thì nhỏ nhưng cộng lại thì không',
  'Mây đã đồng hành cùng bạn {streak} ngày rồi đấy',
  '{streak} ngày rồi, và Mây hiểu bạn rõ hơn nhiều so với ngày đầu',
  'bạn giữ được {streak} ngày, đó là một cách thương mình rất cụ thể',
];

/// Presence / permission — for a hard day.
const _forwardHere = [
  'Mây vẫn ở đây, không đi đâu cả',
  '{streak} ngày rồi, và bạn không phải đi qua ngày hôm nay một mình',
  'bạn không cần ổn ngay bây giờ, Mây ngồi đây với bạn đã',
  'ghi lại cả những ngày như thế này cũng là một dạng dũng cảm, và bạn đã làm {streak} ngày liền',
  'cảm xúc này rồi sẽ dịch chuyển, Mây ở đây cho tới khi nó dịch',
  '{streak} ngày bạn kể thật với Mây, kể cả hôm nay, điều đó đáng quý',
  'hôm nay chỉ cần bạn ghi lại là đủ, không cần làm gì thêm',
  'Mây không có lời khuyên nào lúc này, chỉ có mặt thôi',
  'bạn đã đủ cố gắng cho hôm nay rồi',
  '{streak} ngày rồi, cảm ơn bạn vì đã không giữ mọi thứ một mình',
  'Mây sẽ vẫn ở đây vào ngày mai, dù ngày mai bạn thế nào',
  'được kể ra đã là nhẹ đi một chút, phần còn lại cứ từ từ',
];

/// A meditation nudge that fits the mood's category. Keys must match
/// `moodCategory` in meditation_recommend.dart.
const _forwardMeditation = {
  'tich-cuc': [
    'nếu muốn, một bài thiền ngắn có thể giúp bạn giữ cảm giác này lâu hơn',
    'một bài thiền tích cực đang chờ bạn, để ngày hôm nay tròn hơn một chút',
    'thử vài phút thiền nhẹ xem sao, không phải để đổi gì, chỉ để ở lại với điều dễ chịu này',
    'Mây có một bài thiền hợp với tâm trạng hôm nay của bạn, nếu bạn muốn nghe',
  ],
  'lo-au': [
    'một bài thở ngắn có thể làm chậm lại vòng suy nghĩ đang quay trong bạn',
    'Mây gợi ý một bài thiền làm dịu, vài phút thôi, để cảm xúc đang dồn lên hạ xuống',
    'khi bạn sẵn sàng, một bài thiền làm dịu có thể giúp đầu bạn bớt ồn',
    'thử một bài thở cùng Mây nhé, để cơ thể biết là nó đang an toàn',
  ],
  'chua-lanh': [
    'một bài thiền chữa lành đang ở đó, cho những ngày lòng mình như hôm nay',
    'khi bạn muốn, vài phút thiền dịu dàng có thể xoa bớt chỗ đang đau',
    'Mây có một bài thiền nhẹ cho những ngày buồn, nếu bạn cần một chỗ để tựa vào',
    'không cần ngay bây giờ, nhưng một bài thiền chữa lành sẽ luôn chờ bạn ở đây',
  ],
  'thu-gian': [
    'một bài thư giãn có thể giúp cơ thể bạn bớt gồng lại',
    'khi bạn dừng được, vài phút thiền buông sẽ giúp áp lực nhẹ xuống một chút',
    'Mây gợi ý một bài thiền để thả lỏng, bạn xứng đáng được xả hết căng thẳng này',
    'thử một bài thư giãn trước khi ngủ nhé, để ngày căng này được khép lại nhẹ nhàng',
  ],
};

const _forwardSteadyLight = [
  'mấy hôm nay bạn đều nhẹ nhõm như vậy, {streak} ngày rồi, có vẻ bạn đang ở một quãng đẹp',
  'nhiều ngày liền bạn thấy ổn, Mây mừng khi thấy nhịp này kéo dài',
  'bạn đang có một chuỗi ngày dễ chịu, và {streak} ngày ghi lại giúp bạn nhìn thấy rõ điều đó',
  'không phải ngẫu nhiên mà mấy hôm nay bạn thấy khá hơn, bạn đã chăm sóc mình đều đặn {streak} ngày',
  'một quãng ổn định đang tới với bạn, cứ giữ những gì bạn đang làm nhé',
  'mấy ngày gần đây của bạn khá lành, {streak} ngày rồi, và Mây thấy bạn vững hơn',
  'bạn đang đi qua một giai đoạn êm, ghi lại nó để sau này nhớ rằng mình từng ở đây',
  '{streak} ngày, phần lớn là những ngày nhẹ, bạn đang làm điều gì đó đúng',
];

const _forwardSteadyHeavy = [
  'mấy hôm nay đều nặng nề với bạn, Mây thấy, và Mây không xem nhẹ điều đó',
  'đây là một chuỗi ngày khó, không phải một hôm đơn lẻ, nếu thấy quá sức thì nói với ai đó bạn tin nhé',
  'bạn đã gắng qua nhiều ngày liền rồi, {streak} ngày bạn vẫn ghi lại, đó là bạn đang bám trụ',
  'nhiều ngày khó liên tiếp làm người ta rã rời, bạn không yếu đuối đâu, bạn đang chịu đựng nhiều',
  'Mây ở đây suốt quãng này với bạn, một bài thiền nhẹ có thể là một chỗ nghỉ giữa đường',
  'chuỗi ngày này rồi cũng sẽ đổi, trong lúc chờ, cứ để Mây ngồi cạnh',
  'bạn đã kể thật với Mây nhiều ngày liền, kể cả khi chẳng có gì sáng sủa, điều đó cần sức',
  'nếu mấy hôm nay quá tối, xin bạn đừng đi qua nó một mình, Mây ở đây và những người thương bạn cũng vậy',
];

// ─────────────────────────────────────────────────────────────────────────
// Whole-first-clause openers for the trend cases. No trailing dot.
// ─────────────────────────────────────────────────────────────────────────

const _openFirst = [
  'đây là điều đầu tiên bạn kể cho Mây, cảm ơn bạn đã bắt đầu',
  'lần đầu tiên bạn ghé qua An, Mây chưa biết nhiều về bạn, nhưng Mây rất mừng vì bạn đã tới',
  'ngày đầu tiên của bạn ở đây, một dòng nhỏ thôi, nhưng là một điều tử tế bạn vừa làm cho mình',
  'bạn vừa kể cho Mây nghe điều đầu tiên, không cần vội, từ đây mình đi cùng nhau',
  'khởi đầu nào cũng nhỏ, hôm nay bạn đã ghi lại cảm xúc đầu tiên của mình, và thế là đủ',
  'Mây mới quen bạn hôm nay, nhưng Mây hứa sẽ lắng nghe thật kỹ, mỗi ngày',
  'cảm ơn bạn đã chọn kể, thay vì giữ trong lòng, hôm nay là ngày đầu và Mây ở đây',
  'bạn vừa bước vào An, không có gì phải làm cho đúng, chỉ cần thành thật như bạn vừa làm',
];

const _openReturned = [
  'bạn quay lại rồi, Mây không đếm những ngày vắng, Mây chỉ mừng vì hôm nay bạn ở đây',
  'chào bạn, lâu rồi mới gặp, chỗ này vẫn luôn chờ bạn',
  'bạn đã nghỉ một quãng, và giờ bạn trở lại, đó cũng là chăm sóc bản thân',
  'không cần giải thích vì sao vắng, bạn về là được, và Mây nghe đây',
  'Mây coi hôm nay không phải "bắt đầu lại", mà là "tiếp tục"',
  'rời đi rồi quay về là chuyện rất người, mừng bạn đã về',
  'chuỗi ngày có thể bắt đầu lại, nhưng những gì bạn từng kể thì Mây vẫn giữ',
  'Mây nhớ bạn, hôm nay được nghe lại giọng bạn, vậy là ngày hôm nay đã khác rồi',
];

const _openLifted = [
  'hôm nay bạn nhẹ hơn lần trước rõ rệt, Mây thấy, và Mây mừng cho bạn',
  'so với lần gần nhất bạn kể, hôm nay có gì đó đã dịu xuống',
  'bạn đang khá hơn so với lần ghé Mây gần nhất, điều đó đáng để dừng lại một giây',
  'có một khoảng sáng hôm nay mà lần trước chưa có, cảm ơn bạn đã kể cả hai',
  'từ lần trước tới giờ, bạn đã đi được một quãng về phía nhẹ nhõm',
  'hôm nay bạn lên tinh thần hơn hẳn so với lần gần đây, Mây ghi lại cả hành trình đó',
  'lần trước nặng, hôm nay nhẹ hơn, cảm xúc luôn chuyển động và bạn đang thấy nó chuyển',
];

const _openDipped = [
  'lần trước bạn còn khá ổn, hôm nay thì chùng xuống, không ai đi một đường thẳng cả',
  'hôm nay khó hơn lần bạn kể gần nhất, Mây vẫn ở đây, y như lúc bạn ổn',
  'bạn đang xuống một chút so với lần trước, Mây không hoảng, và bạn cũng đừng nhé',
  'từ lần trước tới giờ, có gì đó đã nặng thêm, cảm ơn bạn vẫn kể ra',
  'hôm nay không sáng bằng lần gần nhất, những ngày như vậy vẫn thuộc về hành trình của bạn',
  'bạn tụt xuống một nhịp so với lần trước, mình cứ đi chậm lại vài hôm cũng được',
  'lần trước nhẹ, hôm nay nặng hơn, Mây ghi lại, không phán xét gì cả',
];

// ─────────────────────────────────────────────────────────────────────────
// Milestone forwards — mood-safe (only about the number + the journey), so
// they sit fine after any empathy opener.
// ─────────────────────────────────────────────────────────────────────────

const _milestones = {
  3: [
    'ba ngày liên tiếp rồi, người ta hay dừng ở ngày thứ ba, bạn thì không',
    'ba ngày, một nhịp nhỏ đang thành hình trong ngày của bạn',
    'ngày thứ ba rồi đấy, cảm ơn bạn đã không để hôm qua là lần cuối',
  ],
  7: [
    'một tuần trọn vẹn, bảy ngày liền bạn kể cho Mây nghe',
    'bảy ngày liên tục rồi, đủ để gọi đây là một thói quen thật sự',
    'hết một tuần, bạn đã cho mình bảy ngày được lắng nghe',
  ],
  14: [
    'hai tuần rồi, sự đều đặn này của bạn không hề nhỏ',
    'mười bốn ngày liên tục, bạn đang thực sự gắn bó với hành trình này',
    'hai tuần bạn ghé qua mỗi ngày, Mây hiểu bạn hơn nhiều so với ngày đầu',
  ],
  21: [
    'hai mươi mốt ngày, người ta nói đây là lúc một thói quen bắt đầu thành tự nhiên',
    'ba tuần liên tục rồi đấy, bạn đang làm rất tốt',
    'hai mươi mốt ngày kể cho Mây nghe, giờ nó gần như là một phần trong ngày của bạn',
  ],
  30: [
    'một tháng trọn vẹn, ba mươi ngày bạn đã ở lại, kể cả những hôm chẳng dễ chút nào',
    'ba mươi ngày liên tục, đây là một cột mốc thật sự đáng dừng lại nhìn',
    'hết một tháng, cảm ơn bạn vì ba mươi ngày tin tưởng kể cho Mây nghe',
  ],
  50: [
    'năm mươi ngày, nửa trăm ngày bạn đã dành cho chính mình',
    'năm mươi ngày liên tục, sự bền bỉ này của bạn đáng ngưỡng mộ',
    'cột mốc năm mươi ngày, Mây đã ở đó cùng bạn từng ngày một',
  ],
  75: [
    'bảy mươi lăm ngày rồi, ba phần tư chặng đường tới trăm ngày',
    'bảy mươi lăm ngày liền, bạn đã biến việc này thành một phần của mình',
    'bảy mươi lăm ngày, Mây không còn phải hỏi bạn có quay lại không nữa',
  ],
  100: [
    'một trăm ngày, một hành trình dài, và Mây đã ở đó suốt cả chặng',
    'cột mốc trăm ngày liên tục, cảm ơn bạn vì đã luôn tin tưởng kể cho Mây nghe',
    'một trăm ngày bạn chọn quay lại với chính mình, con số đó nói rất nhiều',
  ],
  150: [
    'một trăm năm mươi ngày, bạn đã đi xa hơn phần lớn mọi người rất nhiều',
    'một trăm năm mươi ngày liền, đây không còn là thói quen nữa, nó là một phần con người bạn',
    'cột mốc một trăm năm mươi ngày, Mây tự hào về bạn',
  ],
  200: [
    'hai trăm ngày, Mây gần như đoán được bạn cảm thấy gì trước cả khi bạn viết',
    'hai trăm ngày liên tục, một quãng đường mà ngày đầu bạn khó hình dung nổi',
    'hai trăm ngày bạn ở lại với chính mình, thật đáng nể',
  ],
  300: [
    'ba trăm ngày, gần một năm bạn không rời khỏi hành trình này',
    'ba trăm ngày liền, Mây không biết nói gì hơn ngoài: cảm ơn bạn',
    'cột mốc ba trăm ngày, bạn đã cho Mây thấy sự kiên trì trông như thế nào',
  ],
  365: [
    'trọn một năm, ba trăm sáu mươi lăm ngày bạn kể cho Mây nghe, không sót ngày nào',
    'một năm liên tục, Mây đã đi cùng bạn qua đủ bốn mùa cảm xúc',
    'một năm trọn vẹn, nhìn lại đi, bạn của hôm nay và bạn của một năm trước',
  ],
};
