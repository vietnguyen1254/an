import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/meditation_session.dart';
import '../../models/mood.dart';
import '../../services/meditation_recommend.dart';
import '../../services/notifications/notification_service.dart';
import '../../services/sessions_api.dart';
import '../../services/streak_encourage.dart';
import '../../state/app_state.dart';
import '../../theme/colors.dart';
import '../../widgets/app_button.dart';
import '../../widgets/may.dart';
import '../../widgets/session_thumb.dart';
import '../main_tabs.dart';
import '../meditation/player_screen.dart';
import '../premium/paywall_screen.dart';

class SavedScreen extends StatefulWidget {
  const SavedScreen({super.key});

  @override
  State<SavedScreen> createState() => _SavedScreenState();
}

class _SavedScreenState extends State<SavedScreen> {
  MeditationSession? _recommended;
  late final String _message;

  @override
  void initState() {
    super.initState();
    final state = context.read<AppState>();
    final tagLabel = state.draftTags.isNotEmpty
        ? kTags.firstWhere((t) => t.key == state.draftTags.first, orElse: () => TagDef(state.draftTags.first, state.draftTags.first)).label
        : null;
    // Today's entry is already saved and counted; the arc comes from every
    // earlier entry's mood, most-recent first.
    final now = DateTime.now();
    bool isToday(DateTime d) => d.year == now.year && d.month == now.month && d.day == now.day;
    final pastMoods = state.entries.where((e) => !isToday(e.entryDate)).map((e) => e.mood).toList();
    final trend = computeMoodTrend(
      state.draftMood,
      pastMoods,
      streak: state.streakDays,
      totalEntries: state.entries.length,
    );
    _message = generateStreakMessage(
      state.draftMood,
      state.streakDays,
      tagLabel: tagLabel,
      trend: trend,
      intensity: state.draftIntensity,
    );
    SessionsApi.instance.fetchAll().then((sessions) {
      if (!mounted) return;
      setState(() => _recommended = pickRecommendation(sessions, state.draftMood));
    }).catchError((Object e) {
      debugPrint('SavedScreen: failed to load recommendation: $e');
    });

    // First check-in ever → this is the moment to offer daily reminders.
    if (!state.notifPrimed) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _offerReminders());
    }
  }

  Future<void> _offerReminders() async {
    if (!mounted) return;
    final wants = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: const Text('Để Mây nhắc bạn nhé?', style: TextStyle(fontFamily: 'Lora', fontSize: 20, color: AppColors.ink)),
        content: Text(
          'Mỗi ngày Mây gửi hai lời nhắc nhẹ: một để ghi cảm xúc, một để thiền. '
          'Giờ giấc Mây tự điều chỉnh theo bạn. Tắt bất cứ lúc nào trong phần Cài đặt.',
          style: TextStyle(fontFamily: 'BeVietnamPro', fontWeight: FontWeight.w300, fontSize: 13.5, height: 22 / 13.5, color: AppColors.ink.withValues(alpha: 0.7)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text('Để sau', style: TextStyle(fontFamily: 'BeVietnamPro', fontSize: 14, color: AppColors.ink.withValues(alpha: 0.5))),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Có, nhắc mình', style: TextStyle(fontFamily: 'BeVietnamPro', fontWeight: FontWeight.w500, fontSize: 14, color: AppColors.sage)),
          ),
        ],
      ),
    );
    if (!mounted) return;
    await context.read<AppState>().markNotifPrimed();
    if (wants ?? false) {
      await NotificationService.instance.requestPermission();
      if (mounted) context.read<AppState>().rescheduleReminders();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isPremium = context.watch<AppState>().plan != PlanTier.free;

    void goPractice() {
      Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (_) => const MainTabs(initialIndex: 1)), (route) => false);
    }

    void openFollowUp() {
      final s = _recommended;
      if (s == null) {
        goPractice();
        return;
      }
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
          sessionId: s.id,
        ),
      ));
    }

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [AppColors.loginTop, AppColors.loginMid, AppColors.loginBottom]),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(30, 60, 30, 16),
            child: Column(
              children: [
                Transform.translate(offset: const Offset(-15, 0), child: const May(mood: Mood.vui, size: 156)),
                const SizedBox(height: 24),
                const Text('Cảm ơn bạn đã kể.', style: TextStyle(fontFamily: 'Lora', fontSize: 27, height: 37 / 27, color: AppColors.ink), textAlign: TextAlign.center),
                const SizedBox(height: 12),
                Text(
                  _message,
                  textAlign: TextAlign.center,
                  style: TextStyle(fontFamily: 'BeVietnamPro', fontWeight: FontWeight.w300, fontSize: 15, height: 26 / 15, color: AppColors.ink.withValues(alpha: 0.6)),
                ),
                const SizedBox(height: 26),
                if (_recommended != null)
                  GestureDetector(
                    onTap: openFollowUp,
                    child: Container(
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.8), borderRadius: BorderRadius.circular(22), border: Border.all(color: Colors.white.withValues(alpha: 0.9))),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('GỢI Ý CHO BẠN', style: TextStyle(fontFamily: 'BeVietnamPro', fontSize: 11, letterSpacing: 1, color: AppColors.ink.withValues(alpha: 0.45))),
                          const SizedBox(height: 12),
                          Row(children: [
                            SessionThumbnail(
                              size: 54,
                              color: AppColors.sageTint,
                              imageUrl: _recommended!.imageUrl != null ? SessionsApi.instance.resolve(_recommended!.imageUrl!) : null,
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                                Text(_recommended!.title, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontFamily: 'BeVietnamPro', fontWeight: FontWeight.w500, fontSize: 15, color: AppColors.ink)),
                                const SizedBox(height: 3),
                                Text('Thiền dẫn · ${guideName(_recommended!.guide)} · ${_recommended!.minutes} phút', maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontFamily: 'BeVietnamPro', fontWeight: FontWeight.w300, fontSize: 12.5, color: Color(0x8C1B2420))),
                              ]),
                            ),
                          ]),
                        ],
                      ),
                    ),
                  ),
                const Spacer(),
                AppButton(label: 'Nghe ngay', onPressed: openFollowUp),
                const SizedBox(height: 16),
                GestureDetector(
                  onTap: goPractice,
                  child: Text('Thực hành thiền/thở', style: TextStyle(fontFamily: 'BeVietnamPro', fontSize: 14, color: AppColors.ink.withValues(alpha: 0.5))),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
