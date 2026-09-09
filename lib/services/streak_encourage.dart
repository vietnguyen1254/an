import 'dart:math';

import '../models/mood.dart';

/// Warm, varied encouragement for the "saved" screen — combines today's
/// just-recorded mood with the real streak count (past data), never a made
/// up claim. Milestone counts (1, 3, 7, 14, 21, 30, 50, 100) get their own
/// pool since those are genuinely worth calling out; everything else picks
/// from a mood-specific pool with {streak} filled in.
const _byMood = {
  Mood.binhYen: [
    'Bình yên là một món quà — cảm ơn bạn đã kể cho Mây nghe, ngày thứ {streak} rồi đấy.',
    'Bạn đang bình yên, Mây mừng lắm. {streak} ngày ghi lại rồi, cứ tiếp tục nhé.',
    'Một ngày bình yên nữa được ghi lại — {streak} ngày rồi, bạn đang làm rất tốt.',
    'Cảm ơn bạn đã kể Mây nghe. Bình yên hôm nay, và {streak} ngày bền bỉ ghé thăm Mây.',
    'Giữ được sự bình yên này không dễ đâu. {streak} ngày rồi, bạn đang chăm sóc mình rất tốt.',
    'Mây thấy bạn bình yên hôm nay. {streak} ngày liên tục ghi lại cảm xúc — thật đáng quý.',
    'Một ngày nhẹ nhàng. Cảm ơn bạn vì {streak} ngày đã tin tưởng kể cho Mây nghe.',
    'Bình yên hôm nay là kết quả của những ngày bạn kiên trì. {streak} ngày rồi đấy.',
    'Mây thích những ngày như hôm nay của bạn. {streak} ngày ghi lại rồi, tiếp tục nhé.',
    'Bình yên là điều Mây luôn mong bạn có, và {streak} ngày qua bạn đang tìm thấy nó.',
    '{streak} ngày rồi, và hôm nay bạn thấy bình yên — một sự kết hợp rất đẹp.',
    'Mỗi ngày ghi lại là một bước gần hơn với chính mình. Hôm nay bình yên, ngày thứ {streak}.',
    'Bạn đang ở một nơi rất tốt lúc này. {streak} ngày rồi, Mây tự hào về bạn.',
    'Bình yên như hôm nay xứng đáng được ghi nhớ. Cảm ơn bạn vì {streak} ngày đồng hành cùng Mây.',
  ],
  Mood.vui: [
    'Bạn đang vui, Mây cũng vui lây! {streak} ngày ghi lại rồi, cứ giữ nhịp này nhé.',
    'Một ngày vui vẻ nữa! Cảm ơn bạn đã kể cho Mây nghe, ngày thứ {streak} rồi đấy.',
    'Niềm vui hôm nay của bạn làm Mây mỉm cười theo. {streak} ngày liên tục rồi!',
    '{streak} ngày rồi, và hôm nay bạn vui — Mây thích những ngày như thế này.',
    'Vui vẻ là năng lượng tốt, mong bạn giữ mãi. Cảm ơn vì {streak} ngày đã ghé Mây.',
    'Bạn đang tỏa nắng hôm nay đấy! {streak} ngày ghi lại cảm xúc, thật tuyệt.',
    'Mây ghi lại nụ cười của bạn hôm nay. {streak} ngày rồi, cứ tiếp tục nhé.',
    'Một ngày vui trọn vẹn. Cảm ơn bạn vì {streak} ngày đã kể cho Mây nghe.',
    'Niềm vui hôm nay xứng đáng được lưu lại. {streak} ngày liên tục rồi đấy.',
    'Bạn vui, Mây cũng thấy nhẹ lòng. {streak} ngày ghi lại rồi, giữ vững nhé.',
    'Hôm nay là một ngày đẹp với bạn. {streak} ngày rồi, Mây rất vui vì điều đó.',
    'Cảm ơn bạn đã chia sẻ niềm vui này. {streak} ngày bền bỉ, thật đáng khen.',
    'Vui vẻ như hôm nay là điều Mây luôn mong cho bạn. {streak} ngày rồi đấy.',
    'Ngày thứ {streak} của bạn tràn đầy niềm vui — Mây ghi lại và mừng cùng bạn.',
  ],
  Mood.binhThuong: [
    'Một ngày bình thường cũng đáng được ghi lại. {streak} ngày rồi, cảm ơn bạn.',
    'Không phải ngày nào cũng đặc biệt, và điều đó cũng ổn. {streak} ngày ghi lại rồi.',
    'Hôm nay bình thường thôi, nhưng bạn vẫn ghé kể cho Mây — {streak} ngày rồi đấy.',
    'Những ngày bình thường mới là phần lớn cuộc sống. Cảm ơn vì {streak} ngày bền bỉ.',
    'Mây trân trọng cả những ngày bình thường như hôm nay. {streak} ngày liên tục rồi.',
    'Không cần phải vui hay buồn, chỉ cần thật với cảm xúc của mình. {streak} ngày rồi.',
    'Một ngày bình thường, một bước nhỏ đều đặn. {streak} ngày ghi lại, thật đáng quý.',
    'Cảm ơn bạn đã kể Mây nghe, dù hôm nay không có gì đặc biệt. {streak} ngày rồi.',
    'Bình thường cũng là một trạng thái đáng ghi nhận. {streak} ngày liên tục, tốt lắm.',
    'Những ngày như hôm nay giúp Mây hiểu bạn rõ hơn. {streak} ngày rồi đấy.',
    'Ổn định cũng là một điều tốt. {streak} ngày ghi lại rồi, cứ tiếp tục nhé.',
    'Hôm nay bình thường, và điều đó không sao cả. Cảm ơn vì {streak} ngày đồng hành.',
    'Mây thích sự đều đặn của bạn. {streak} ngày ghi lại rồi, kể cả những ngày bình thường.',
    'Ngày thứ {streak}, một ngày bình thường — nhưng sự kiên trì của bạn thì không bình thường chút nào.',
  ],
  Mood.loLang: [
    'Lo âu hôm nay không sao cả — Mây ở đây lắng nghe. {streak} ngày rồi, bạn không đơn độc.',
    'Cảm ơn bạn đã kể Mây nghe, kể cả khi lòng đang lo lắng. {streak} ngày liên tục rồi.',
    'Bạn đang lo lắng, và điều đó hoàn toàn bình thường. {streak} ngày bền bỉ ghi lại rồi.',
    'Mây nhận thấy hôm nay bạn hơi lo. {streak} ngày rồi, cứ hít thở chậm lại một chút nhé.',
    'Lo âu rồi cũng sẽ qua. Cảm ơn bạn vì {streak} ngày đã tin tưởng kể cho Mây nghe.',
    'Ghi lại cả những ngày lo lắng cũng là một dạng dũng cảm. {streak} ngày rồi đấy.',
    'Mây ở đây, dù hôm nay lòng bạn không yên. {streak} ngày liên tục ghi lại, thật đáng quý.',
    'Lo lắng hôm nay không định nghĩa con người bạn. {streak} ngày rồi, cứ từ từ thôi.',
    'Cảm ơn bạn đã không giấu Mây điều gì, kể cả sự lo âu. {streak} ngày bền bỉ rồi.',
    'Một ngày lo lắng cũng xứng đáng được ghi lại. {streak} ngày rồi, Mây luôn ở đây.',
    'Thử một bài thở ngắn có thể giúp bạn nhẹ lòng hơn. {streak} ngày ghi lại rồi đấy.',
    'Mây thấy bạn đang cố gắng, dù hôm nay không dễ dàng. {streak} ngày liên tục rồi.',
    'Lo âu là một phần của hành trình, không phải điểm dừng. {streak} ngày rồi, cứ tiếp tục kể cho Mây nghe.',
    'Cảm ơn bạn đã kể thật với Mây hôm nay. {streak} ngày rồi, bạn đang làm rất tốt.',
  ],
  Mood.buon: [
    'Hôm nay có vẻ nặng lòng. Mây ở đây, {streak} ngày rồi bạn vẫn kể cho Mây nghe.',
    'Buồn cũng cần được lắng nghe. Cảm ơn bạn vì {streak} ngày đã tin tưởng Mây.',
    'Mây nhận thấy hôm nay bạn buồn. {streak} ngày liên tục rồi, cứ để cảm xúc được ghi lại.',
    'Không sao nếu hôm nay không ổn. {streak} ngày rồi, Mây vẫn ở đây cùng bạn.',
    'Nỗi buồn hôm nay cũng đáng được ghi nhận. {streak} ngày bền bỉ, thật đáng quý.',
    'Cảm ơn bạn đã kể Mây nghe, dù lòng đang buồn. {streak} ngày rồi đấy.',
    'Buồn rồi cũng sẽ dịu lại. {streak} ngày ghi lại rồi, bạn không phải một mình.',
    'Mây ở đây, dù hôm nay không phải một ngày dễ dàng. {streak} ngày liên tục rồi.',
    'Ghi lại cả những ngày buồn cũng là một cách chăm sóc bản thân. {streak} ngày rồi.',
    'Một chút thời gian cho chính mình có thể giúp ích lúc này. {streak} ngày ghi lại rồi.',
    'Cảm ơn bạn đã không giữ nỗi buồn một mình. {streak} ngày liên tục, Mây luôn lắng nghe.',
    'Hôm nay buồn, và điều đó không sao cả. {streak} ngày rồi, cứ từ từ nhé.',
    'Mây thấy bạn đang cố gắng vượt qua. {streak} ngày bền bỉ, thật đáng trân trọng.',
    'Nỗi buồn hôm nay rồi sẽ qua đi. {streak} ngày rồi, cảm ơn bạn đã kể cho Mây nghe.',
  ],
  Mood.kietSuc: [
    'Hôm nay có vẻ mệt mỏi lắm. {streak} ngày rồi, cảm ơn bạn đã ghé kể cho Mây nghe.',
    'Kiệt sức là dấu hiệu bạn cần nghỉ ngơi. {streak} ngày liên tục ghi lại rồi đấy.',
    'Mây nhận thấy hôm nay bạn khá căng thẳng. {streak} ngày rồi, hãy cho mình một chút nghỉ ngơi nhé.',
    'Cảm ơn bạn đã kể Mây nghe, dù cơ thể đang mệt nhoài. {streak} ngày bền bỉ rồi.',
    'Một chút thời gian tĩnh lặng có thể giúp bạn hồi phục. {streak} ngày ghi lại rồi.',
    'Kiệt sức hôm nay không sao cả — nghỉ ngơi cũng là một phần hành trình. {streak} ngày rồi.',
    'Mây ở đây, dù hôm nay bạn không còn nhiều năng lượng. {streak} ngày liên tục rồi.',
    'Cơ thể đang nhắc bạn chậm lại. {streak} ngày rồi, cảm ơn bạn đã lắng nghe nó.',
    'Thử một bài thở ngắn có thể giúp bạn lấy lại sức. {streak} ngày ghi lại rồi đấy.',
    'Mệt mỏi hôm nay cũng xứng đáng được ghi nhận. {streak} ngày bền bỉ, thật đáng quý.',
    'Cảm ơn bạn đã không phớt lờ sự mệt mỏi của mình. {streak} ngày liên tục rồi.',
    'Nghỉ ngơi không phải là yếu đuối. {streak} ngày rồi, cứ cho mình thời gian nhé.',
    'Mây thấy bạn đã cố gắng rất nhiều rồi. {streak} ngày bền bỉ, giờ là lúc chậm lại.',
    'Một ngày mệt mỏi cũng là một ngày bạn đã cố gắng. {streak} ngày rồi, cảm ơn bạn đã kể cho Mây nghe.',
  ],
};

const _milestones = {
  1: [
    'Ngày đầu tiên của bạn ở đây. Cảm ơn vì đã bắt đầu — Mây rất vui được đồng hành cùng bạn.',
    'Đây là lần đầu bạn kể cho Mây nghe. Một khởi đầu nhỏ, nhưng rất đáng quý.',
  ],
  3: [
    'Ba ngày rồi đấy. Một thói quen nhỏ đang dần hình thành.',
    '3 ngày liên tục — bạn đang xây một nhịp điệu tốt cho mình.',
  ],
  7: [
    'Một tuần trọn vẹn rồi! Bạn đã kiên trì kể cho Mây nghe suốt 7 ngày.',
    '7 ngày liên tục — một tuần đầy đủ cảm xúc được ghi lại. Cảm ơn bạn.',
  ],
  14: [
    'Hai tuần rồi đấy! Mây rất trân trọng sự kiên trì này của bạn.',
    '14 ngày liên tục — bạn đang thực sự gắn bó với hành trình này.',
  ],
  21: [
    '21 ngày rồi — người ta nói đây là lúc một thói quen bắt đầu trở nên tự nhiên.',
    'Ba tuần liên tục! Bạn đang làm rất tốt.',
  ],
  30: [
    'Một tháng trọn vẹn! 30 ngày bạn đã kiên trì kể cho Mây nghe.',
    '30 ngày liên tục — đây là một cột mốc thật sự đáng tự hào.',
  ],
  50: [
    '50 ngày rồi! Nửa trăm ngày bạn đã dành cho chính mình.',
    '50 ngày liên tục — sự bền bỉ của bạn thật đáng ngưỡng mộ.',
  ],
  100: [
    '100 ngày! Một hành trình dài và Mây đã ở đó cùng bạn suốt chặng đường.',
    'Cột mốc 100 ngày liên tục — cảm ơn bạn vì đã luôn tin tưởng kể cho Mây nghe.',
  ],
};

String generateStreakMessage(Mood mood, int streak) {
  final rand = Random();
  final milestonePool = _milestones[streak];
  if (milestonePool != null) {
    return milestonePool[rand.nextInt(milestonePool.length)];
  }
  final pool = _byMood[mood]!;
  return pool[rand.nextInt(pool.length)].replaceAll('{streak}', '$streak');
}
