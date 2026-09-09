import 'dart:math';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/meditation_session.dart';
import '../../models/mood.dart';
import '../../services/meditation_recommend.dart';
import '../../services/sessions_api.dart';
import '../../state/app_state.dart';
import '../../theme/colors.dart';
import '../../utils/vn_date.dart';
import '../../widgets/app_button.dart';
import '../../widgets/basics.dart';
import '../../widgets/may.dart';
import '../checkin/mood_checkin_screen.dart';
import '../meditation/minute_with_justin_screen.dart';
import '../meditation/player_screen.dart';
import '../premium/paywall_screen.dart';

class _Prompt {
  final String question;
  final String description;
  const _Prompt(this.question, this.description);
}

// Kept short on purpose — these sit in a fixed-width card, a long line
// wraps awkwardly or pushes the button off-balance. Goal always stays the
// same regardless of phrasing: get the user to tap through and record.
List<_Prompt> _homePrompts(String greeting) => [
      const _Prompt('Hôm nay bạn thế nào?', 'Mây đang chờ bạn kể. Chỉ mất mười giây thôi.'),
      const _Prompt('Lúc này bạn cảm thấy ra sao?', 'Ghi lại một chút, để Mây hiểu bạn hơn.'),
      const _Prompt('Hôm nay có gì trong lòng bạn?', 'Một vài giây thôi, Mây luôn sẵn sàng lắng nghe.'),
      const _Prompt('Bạn đang cảm thấy thế nào?', 'Ghi lại cảm xúc giúp bạn hiểu chính mình hơn mỗi ngày.'),
      const _Prompt('Hôm nay lòng bạn ra sao?', 'Dù vui hay buồn, Mây cũng muốn biết.'),
      const _Prompt('Cảm xúc hôm nay của bạn là gì?', 'Chỉ một câu thôi, Mây đang chờ đây.'),
      const _Prompt('Bạn đã kể cho Mây nghe chưa?', 'Một phút ghi lại, một ngày nhẹ nhõm hơn.'),
      const _Prompt('Hôm nay bạn ổn không?', 'Kể cho Mây nghe một chút nhé.'),
      const _Prompt('Điều gì đang diễn ra trong bạn?', 'Ghi lại giúp bạn nhìn rõ cảm xúc của mình hơn.'),
      const _Prompt('Bạn thấy trong người thế nào?', 'Một khoảnh khắc dừng lại, cũng là chăm sóc bản thân.'),
      const _Prompt('Sau một ngày, bạn cảm thấy ra sao?', 'Ghi lại trước khi cảm xúc trôi qua nhé.'),
      const _Prompt('Bạn đang mang cảm xúc gì?', 'Mây luôn ở đây, sẵn sàng lắng nghe bạn.'),
      const _Prompt('Hôm nay là một ngày thế nào?', 'Ghi lại một chút — rồi thử một bài thiền nhẹ nhàng nhé.'),
      const _Prompt('Bạn đã dành thời gian cho mình chưa?', 'Bắt đầu bằng việc ghi lại cảm xúc nhé.'),
      _Prompt('$greeting, bạn thế nào rồi?', 'Ghi lại cảm xúc, rồi thử một bài thở ngắn nếu cần.'),
    ];

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  MeditationSession? _recommended;
  late final _Prompt _prompt;

  @override
  void initState() {
    super.initState();
    final prompts = _homePrompts(greetingForHour());
    _prompt = prompts[Random().nextInt(prompts.length)];
    final entries = context.read<AppState>().entries;
    if (entries.isNotEmpty) {
      SessionsApi.instance.fetchAll().then((sessions) {
        if (!mounted) return;
        setState(() => _recommended = pickRecommendation(sessions, entries.first.mood));
      }).catchError((Object e) {
        // No catalog / network hiccup — just don't show the card.
        debugPrint('HomeScreen: failed to load recommendation: $e');
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final isFirstDay = state.entries.isEmpty;
    final isPremium = state.plan != PlanTier.free;

    void openRecommended() {
      final s = _recommended;
      if (s == null) return;
      if (!s.isFree && !isPremium) {
        Navigator.of(context).push(MaterialPageRoute(builder: (_) => const PaywallScreen()));
        return;
      }
      Navigator.of(context).push(MaterialPageRoute(
        builder: (_) => PlayerScreen(
          kind: s.kind == SessionKind.breathing ? PlayerKind.breathing : PlayerKind.guided,
          title: s.title,
          guide: guideName(s.guide),
          minutes: s.minutes,
          audioUrl: SessionsApi.instance.resolve(s.audioUrl),
          imageUrl: s.imageUrl != null ? SessionsApi.instance.resolve(s.imageUrl!) : null,
        ),
      ));
    }

    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [AppColors.skyTop, AppColors.skyMid, AppColors.skyBottom],
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(22, 8, 22, 40),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(
                  isFirstDay ? 'Chào bạn, ${state.userName}' : '${greetingForHour()}, ${state.userName}',
                  style: const TextStyle(fontFamily: 'Lora', fontSize: 25, height: 32 / 25, color: AppColors.ink),
                ),
              ),
              _MayStage(mood: isFirstDay ? Mood.binhThuong : Mood.binhYen),
              Container(
                padding: const EdgeInsets.all(22),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.85),
                  borderRadius: BorderRadius.circular(26),
                  border: Border.all(color: Colors.white.withValues(alpha: 0.9)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isFirstDay ? 'Hôm nay là ngày đầu tiên của bạn ở An.' : _prompt.question,
                      style: const TextStyle(fontFamily: 'Lora', fontSize: 19, height: 27 / 19, color: AppColors.ink),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      isFirstDay ? 'Mây chưa biết gì về bạn cả. Kể cho Mây nghe hôm nay bạn thế nào — mất chừng mười giây.' : _prompt.description,
                      style: TextStyle(fontFamily: 'BeVietnamPro', fontWeight: FontWeight.w300, fontSize: 13.5, height: 21 / 13.5, color: AppColors.ink.withValues(alpha: 0.55)),
                    ),
                    const SizedBox(height: 16),
                    AppButton(
                      label: isFirstDay ? 'Ghi cảm xúc đầu tiên' : 'Ghi lại cảm xúc',
                      variant: AppButtonVariant.sage,
                      height: 50,
                      onPressed: () {
                        context.read<AppState>().beginDraftEntry();
                        Navigator.of(context).push(MaterialPageRoute(builder: (_) => const MoodCheckInScreen()));
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  Expanded(
                    child: _QuickCard(
                      title: 'Bài thở 2 phút',
                      sub: isFirstDay ? 'cùng Mây' : 'Thư giãn nhanh',
                      color: AppColors.sageTint,
                      borderColor: AppColors.sage.withValues(alpha: 0.3),
                      onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const PlayerScreen(kind: PlayerKind.breathing, title: 'Thở cùng Mây', minutes: 2))),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _QuickCard(
                      title: isFirstDay ? 'Góc nhìn' : 'Thiền nhanh 5 phút',
                      sub: isFirstDay ? 'Justin Nguyễn' : 'Yêu đời, bình an',
                      color: AppColors.lavenderTint,
                      borderColor: AppColors.lavender.withValues(alpha: 0.35),
                      onTap: () => isFirstDay
                          ? Navigator.of(context).push(MaterialPageRoute(builder: (_) => const MinuteWithJustinScreen()))
                          : Navigator.of(context).push(MaterialPageRoute(builder: (_) => const PlayerScreen(kind: PlayerKind.breathing, title: 'Thiền nhanh', minutes: 5))),
                    ),
                  ),
                ],
              ),
              if (_recommended != null) ...[
                const SizedBox(height: 14),
                GestureDetector(
                  onTap: openRecommended,
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.85),
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: Colors.white.withValues(alpha: 0.9)),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 56,
                          height: 56,
                          clipBehavior: Clip.hardEdge,
                          decoration: BoxDecoration(color: AppColors.sageTint, borderRadius: BorderRadius.circular(16)),
                          child: _recommended!.imageUrl != null
                              ? Image.network(SessionsApi.instance.resolve(_recommended!.imageUrl!), fit: BoxFit.cover, errorBuilder: (_, _, _) => const SizedBox.shrink())
                              : null,
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(children: [
                                Flexible(
                                  child: Text('MÂY GỢI Ý CHO BẠN', style: TextStyle(fontFamily: 'BeVietnamPro', fontSize: 10.5, letterSpacing: 1, color: AppColors.ink.withValues(alpha: 0.45))),
                                ),
                                const SizedBox(width: 8),
                                Container(
                                  height: 18,
                                  padding: const EdgeInsets.symmetric(horizontal: 7),
                                  alignment: Alignment.center,
                                  decoration: BoxDecoration(color: AppColors.sageTint, borderRadius: BorderRadius.circular(9)),
                                  child: Text(_recommended!.isFree ? 'MIỄN PHÍ' : 'PREMIUM', style: const TextStyle(fontFamily: 'BeVietnamPro', fontWeight: FontWeight.w500, fontSize: 9.5, letterSpacing: 0.5, color: AppColors.sageTintText)),
                                ),
                              ]),
                              const SizedBox(height: 5),
                              Text(_recommended!.title, style: const TextStyle(fontFamily: 'BeVietnamPro', fontWeight: FontWeight.w500, fontSize: 15, color: AppColors.ink)),
                              const SizedBox(height: 3),
                              Text('Thiền dẫn · ${guideName(_recommended!.guide)} · ${_recommended!.minutes} phút', style: TextStyle(fontFamily: 'BeVietnamPro', fontWeight: FontWeight.w300, fontSize: 12.5, color: AppColors.ink.withValues(alpha: 0.5))),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// Mây floating on the sky: a soft radial glow, a few blurred cloud wisps
/// scattered around, and Mây centred. Full-width so Mây sits dead centre.
class _MayStage extends StatelessWidget {
  final Mood mood;
  const _MayStage({required this.mood});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 250,
      child: Stack(
        alignment: Alignment.center,
        clipBehavior: Clip.none,
        children: [
          // radial glow behind Mây
          Container(
            width: 300,
            height: 300,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  Colors.white.withValues(alpha: 0.55),
                  Colors.white.withValues(alpha: 0.0),
                ],
                stops: const [0.0, 0.72],
              ),
            ),
          ),
          // left wisp
          const Positioned(
            left: 26,
            top: 150,
            child: _Wisp(width: 46),
          ),
          // bottom-right wisp
          const Positioned(
            right: 34,
            bottom: 30,
            child: _Wisp(width: 70),
          ),
          // little dot to the right
          Positioned(
            right: 66,
            top: 118,
            child: Container(
              width: 10,
              height: 10,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.65),
              ),
            ),
          ),
          Breathing(child: May(mood: mood, size: 150)),
        ],
      ),
    );
  }
}

/// A soft horizontal cloud wisp — a thin bar bloomed out by a white shadow,
/// so it reads as a blurred puff with no hard edge.
class _Wisp extends StatelessWidget {
  final double width;
  const _Wisp({required this.width});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: 5,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(3),
        color: Colors.white.withValues(alpha: 0.5),
        boxShadow: [
          BoxShadow(
            color: Colors.white.withValues(alpha: 0.5),
            blurRadius: 16,
            spreadRadius: 7,
          ),
        ],
      ),
    );
  }
}

class _QuickCard extends StatelessWidget {
  final String title;
  final String sub;
  final Color color;
  final Color borderColor;
  final VoidCallback onTap;

  const _QuickCard({required this.title, required this.sub, required this.color, required this.borderColor, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.7), borderRadius: BorderRadius.circular(20), border: Border.all(color: AppColors.ink.withValues(alpha: 0.05))),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(width: 28, height: 28, decoration: BoxDecoration(shape: BoxShape.circle, color: color, border: Border.all(color: borderColor))),
            const SizedBox(height: 10),
            Text(title, style: const TextStyle(fontFamily: 'BeVietnamPro', fontWeight: FontWeight.w500, fontSize: 14, color: AppColors.ink)),
            const SizedBox(height: 2),
            Text(sub, style: TextStyle(fontFamily: 'BeVietnamPro', fontWeight: FontWeight.w300, fontSize: 12, color: AppColors.ink.withValues(alpha: 0.5))),
          ],
        ),
      ),
    );
  }
}
