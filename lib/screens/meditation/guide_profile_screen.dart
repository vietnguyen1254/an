import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/meditation_session.dart';
import '../../services/sessions_api.dart';
import '../../state/app_state.dart';
import '../../theme/colors.dart';
import '../premium/paywall_screen.dart';
import 'player_screen.dart';

class _GuideInfo {
  final String name;
  final String bio;
  final String photoAsset;
  final String coDrive;
  final String coDriveLabel;
  const _GuideInfo({required this.name, required this.bio, required this.photoAsset, required this.coDrive, required this.coDriveLabel});
}

const _guides = {
  'justin': _GuideInfo(
    name: 'Justin Nguyễn',
    bio: 'Justin dẫn thiền và nói về chữa lành từ năm 2019. Giọng chậm, ít chỉ dẫn, nhiều khoảng lặng — dành cho người vừa hết một ngày dài.',
    photoAsset: 'assets/guides/justin.jpg',
    coDrive: 'tram',
    coDriveLabel: 'Trâm Nguyễn',
  ),
  'tram': _GuideInfo(
    name: 'Trâm Nguyễn',
    bio: 'Trâm cùng chồng — Justin — dẫn thiền cho An. Giọng nữ nhẹ, ấm, thường dẫn các bài về giấc ngủ và quét cơ thể.',
    photoAsset: 'assets/guides/tram.jpg',
    coDrive: 'justin',
    coDriveLabel: 'Justin Nguyễn',
  ),
};

class GuideProfileScreen extends StatefulWidget {
  final String guide;
  const GuideProfileScreen({super.key, this.guide = 'justin'});

  @override
  State<GuideProfileScreen> createState() => _GuideProfileScreenState();
}

class _GuideProfileScreenState extends State<GuideProfileScreen> {
  late Future<List<MeditationSession>> _future;

  @override
  void initState() {
    super.initState();
    _future = SessionsApi.instance.fetchAll(guide: widget.guide);
  }

  @override
  Widget build(BuildContext context) {
    final g = _guides[widget.guide]!;
    final isPremium = context.watch<AppState>().plan != PlanTier.free;

    void openTrack(MeditationSession s) {
      if (!s.isFree && !isPremium) {
        Navigator.of(context).push(MaterialPageRoute(builder: (_) => const PaywallScreen()));
        return;
      }
      Navigator.of(context).push(MaterialPageRoute(
        builder: (_) => PlayerScreen(
          kind: s.kind == SessionKind.breathing ? PlayerKind.breathing : PlayerKind.guided,
          title: s.title,
          guide: g.name,
          minutes: s.minutes,
          audioUrl: SessionsApi.instance.resolve(s.audioUrl),
          imageUrl: s.imageUrl != null ? SessionsApi.instance.resolve(s.imageUrl!) : null,
          seriesLabel: s.seriesName != null ? 'Chuỗi "${s.seriesName}" · bài ${s.seriesIndex} / ${s.seriesTotal}' : null,
          sessionId: s.id,
        ),
      ));
    }

    return Scaffold(
      backgroundColor: AppColors.appBg,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.only(bottom: 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                height: 300,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    Image.asset(g.photoAsset, fit: BoxFit.cover),
                    Positioned(
                      left: 24,
                      top: 74,
                      child: GestureDetector(
                        onTap: () => Navigator.of(context).pop(),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(color: Colors.black.withValues(alpha: 0.35), borderRadius: BorderRadius.circular(14)),
                          child: const Text('Quay lại', style: TextStyle(fontFamily: 'BeVietnamPro', fontSize: 14, color: Colors.white)),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 22),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 24),
                    Text('NGƯỜI DẪN THIỀN', style: TextStyle(fontFamily: 'BeVietnamPro', fontSize: 10.5, letterSpacing: 1, color: AppColors.ink.withValues(alpha: 0.45))),
                    const SizedBox(height: 8),
                    Text(g.name, style: const TextStyle(fontFamily: 'Lora', fontSize: 29, color: AppColors.ink)),
                    const SizedBox(height: 14),
                    Text(g.bio, style: TextStyle(fontFamily: 'BeVietnamPro', fontWeight: FontWeight.w300, fontSize: 14.5, height: 26 / 14.5, color: AppColors.ink.withValues(alpha: 0.7))),
                    const SizedBox(height: 22),
                    FutureBuilder<List<MeditationSession>>(
                      future: _future,
                      builder: (context, snap) {
                        final sessions = snap.data ?? const [];
                        return Row(children: [
                          Padding(
                            padding: const EdgeInsets.only(right: 24),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('${sessions.length}', style: const TextStyle(fontFamily: 'Lora', fontSize: 22, color: AppColors.ink)),
                                const SizedBox(height: 2),
                                Text('bài thiền', style: TextStyle(fontFamily: 'BeVietnamPro', fontWeight: FontWeight.w300, fontSize: 12, color: AppColors.ink.withValues(alpha: 0.5))),
                              ],
                            ),
                          ),
                        ]);
                      },
                    ),
                    const SizedBox(height: 28),
                    Text('BÀI THIỀN CỦA ${g.name.split(' ').first.toUpperCase()}', style: TextStyle(fontFamily: 'BeVietnamPro', fontSize: 10.5, letterSpacing: 1, color: AppColors.ink.withValues(alpha: 0.45))),
                    const SizedBox(height: 12),
                    FutureBuilder<List<MeditationSession>>(
                      future: _future,
                      builder: (context, snap) {
                        if (snap.connectionState != ConnectionState.done) {
                          return const Padding(
                            padding: EdgeInsets.symmetric(vertical: 20),
                            child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
                          );
                        }
                        if (snap.hasError) {
                          return Text('Không tải được danh sách bài thiền.', style: TextStyle(fontFamily: 'BeVietnamPro', fontSize: 13, color: AppColors.ink.withValues(alpha: 0.5)));
                        }
                        final tracks = snap.data ?? const [];
                        if (tracks.isEmpty) {
                          return Text('Chưa có bài nào.', style: TextStyle(fontFamily: 'BeVietnamPro', fontWeight: FontWeight.w300, fontSize: 13.5, color: AppColors.ink.withValues(alpha: 0.45)));
                        }
                        return Column(
                          children: tracks
                              .map((t) => Padding(
                                    padding: const EdgeInsets.only(bottom: 10),
                                    child: GestureDetector(
                                      onTap: () => openTrack(t),
                                      child: Container(
                                        padding: const EdgeInsets.all(14),
                                        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), border: Border.all(color: AppColors.ink.withValues(alpha: 0.06))),
                                        child: Row(children: [
                                          Container(
                                            width: 52,
                                            height: 52,
                                            clipBehavior: Clip.hardEdge,
                                            decoration: BoxDecoration(color: t.isFree ? AppColors.sageTint : AppColors.lavenderTint, borderRadius: BorderRadius.circular(15)),
                                            child: t.imageUrl != null
                                                ? Image.network(SessionsApi.instance.resolve(t.imageUrl!), fit: BoxFit.cover, errorBuilder: (_, _, _) => const SizedBox.shrink())
                                                : null,
                                          ),
                                          const SizedBox(width: 14),
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Text(t.title, style: const TextStyle(fontFamily: 'BeVietnamPro', fontWeight: FontWeight.w500, fontSize: 15, color: AppColors.ink)),
                                                const SizedBox(height: 3),
                                                Text('${t.minutes} phút', style: TextStyle(fontFamily: 'BeVietnamPro', fontWeight: FontWeight.w300, fontSize: 12.5, color: AppColors.ink.withValues(alpha: 0.5))),
                                              ],
                                            ),
                                          ),
                                          if (t.isFree)
                                            Container(
                                              height: 26,
                                              padding: const EdgeInsets.symmetric(horizontal: 10),
                                              alignment: Alignment.center,
                                              decoration: BoxDecoration(color: AppColors.sageTint, borderRadius: BorderRadius.circular(13)),
                                              child: const Text('Miễn phí', style: TextStyle(fontFamily: 'BeVietnamPro', fontWeight: FontWeight.w500, fontSize: 11, color: AppColors.sageTintText)),
                                            )
                                          else
                                            Container(width: 26, height: 26, decoration: BoxDecoration(color: AppColors.ink.withValues(alpha: 0.06), borderRadius: BorderRadius.circular(13))),
                                        ]),
                                      ),
                                    ),
                                  ))
                              .toList(),
                        );
                      },
                    ),
                    GestureDetector(
                      onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => GuideProfileScreen(guide: g.coDrive))),
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        margin: const EdgeInsets.only(top: 22),
                        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(22), border: Border.all(color: AppColors.ink.withValues(alpha: 0.06))),
                        child: Row(children: [
                          ClipOval(child: Image.asset(_guides[g.coDrive]!.photoAsset, width: 44, height: 44, fit: BoxFit.cover)),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('CÙNG DẪN', style: TextStyle(fontFamily: 'BeVietnamPro', fontSize: 10.5, letterSpacing: 1, color: AppColors.ink.withValues(alpha: 0.45))),
                                const SizedBox(height: 4),
                                Text(g.coDriveLabel, style: const TextStyle(fontFamily: 'BeVietnamPro', fontWeight: FontWeight.w500, fontSize: 15, color: AppColors.ink)),
                              ],
                            ),
                          ),
                        ]),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
