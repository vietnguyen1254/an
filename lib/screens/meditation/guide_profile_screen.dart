import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../state/app_state.dart';
import '../../theme/colors.dart';
import '../premium/paywall_screen.dart';
import 'player_screen.dart';

class _Track {
  final String title;
  final String meta;
  final bool free;
  const _Track(this.title, this.meta, this.free);
}

class _Guide {
  final String name;
  final String bio;
  final List<(String, String)> stats;
  final List<_Track> tracks;
  final String coDrive;
  final String coDriveLabel;
  const _Guide({required this.name, required this.bio, required this.stats, required this.tracks, required this.coDrive, required this.coDriveLabel});
}

const _guides = {
  'justin': _Guide(
    name: 'Justin Nguyễn',
    bio: 'Justin dẫn thiền và nói về chữa lành từ năm 2019. Giọng chậm, ít chỉ dẫn, nhiều khoảng lặng — dành cho người vừa hết một ngày dài.',
    stats: [('42', 'bài thiền'), ('6', 'chuỗi bài'), ('18', 'góc nhìn')],
    tracks: [_Track('Buông một ngày dài', '12 phút', true), _Track('Trở về hơi thở', '12 phút · chuỗi "Trở về"', false)],
    coDrive: 'tram',
    coDriveLabel: 'Trâm Nguyễn',
  ),
  'tram': _Guide(
    name: 'Trâm Nguyễn',
    bio: 'Trâm cùng chồng — Justin — dẫn thiền cho An. Giọng nữ nhẹ, ấm, thường dẫn các bài về giấc ngủ và quét cơ thể.',
    stats: [('15', 'bài thiền'), ('2', 'chuỗi bài'), ('4', 'góc nhìn')],
    tracks: [_Track('Quét cơ thể', '15 phút', false)],
    coDrive: 'justin',
    coDriveLabel: 'Justin Nguyễn',
  ),
};

class GuideProfileScreen extends StatelessWidget {
  final String guide;
  const GuideProfileScreen({super.key, this.guide = 'justin'});

  @override
  Widget build(BuildContext context) {
    final g = _guides[guide]!;
    final isPremium = context.watch<AppState>().plan != PlanTier.free;

    void openTrack(_Track t) {
      if (!t.free && !isPremium) {
        Navigator.of(context).push(MaterialPageRoute(builder: (_) => const PaywallScreen()));
      } else {
        Navigator.of(context).push(MaterialPageRoute(builder: (_) => PlayerScreen(kind: PlayerKind.guided, title: t.title, guide: g.name, minutes: 12)));
      }
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
                  children: [
                    Container(color: const Color(0xFFDCE6EC)),
                    Positioned(
                      left: 24,
                      top: 74,
                      child: GestureDetector(
                        onTap: () => Navigator.of(context).pop(),
                        child: Text('Quay lại', style: TextStyle(fontFamily: 'BeVietnamPro', fontSize: 14, color: AppColors.ink.withValues(alpha: 0.5))),
                      ),
                    ),
                    Positioned(
                      left: 24,
                      bottom: 24,
                      child: Text('ảnh chân dung người dẫn', style: TextStyle(fontFamily: 'BeVietnamPro', fontWeight: FontWeight.w300, fontSize: 10.5, color: AppColors.ink.withValues(alpha: 0.4))),
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
                    Row(
                      children: g.stats
                          .map((s) => Padding(
                                padding: const EdgeInsets.only(right: 24),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(s.$1, style: const TextStyle(fontFamily: 'Lora', fontSize: 22, color: AppColors.ink)),
                                    const SizedBox(height: 2),
                                    Text(s.$2, style: TextStyle(fontFamily: 'BeVietnamPro', fontWeight: FontWeight.w300, fontSize: 12, color: AppColors.ink.withValues(alpha: 0.5))),
                                  ],
                                ),
                              ))
                          .toList(),
                    ),
                    const SizedBox(height: 28),
                    Text('BÀI THIỀN CỦA ${g.name.split(' ').first.toUpperCase()}', style: TextStyle(fontFamily: 'BeVietnamPro', fontSize: 10.5, letterSpacing: 1, color: AppColors.ink.withValues(alpha: 0.45))),
                    const SizedBox(height: 12),
                    ...g.tracks.map((t) => Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: GestureDetector(
                            onTap: () => openTrack(t),
                            child: Container(
                              padding: const EdgeInsets.all(14),
                              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), border: Border.all(color: AppColors.ink.withValues(alpha: 0.06))),
                              child: Row(children: [
                                Container(width: 52, height: 52, decoration: BoxDecoration(color: t.free ? AppColors.sageTint : AppColors.lavenderTint, borderRadius: BorderRadius.circular(15))),
                                const SizedBox(width: 14),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(t.title, style: const TextStyle(fontFamily: 'BeVietnamPro', fontWeight: FontWeight.w500, fontSize: 15, color: AppColors.ink)),
                                      const SizedBox(height: 3),
                                      Text(t.meta, style: TextStyle(fontFamily: 'BeVietnamPro', fontWeight: FontWeight.w300, fontSize: 12.5, color: AppColors.ink.withValues(alpha: 0.5))),
                                    ],
                                  ),
                                ),
                                if (t.free)
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
                        )),
                    GestureDetector(
                      onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => GuideProfileScreen(guide: g.coDrive))),
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        margin: const EdgeInsets.only(top: 22),
                        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(22), border: Border.all(color: AppColors.ink.withValues(alpha: 0.06))),
                        child: Row(children: [
                          Container(width: 44, height: 44, decoration: BoxDecoration(shape: BoxShape.circle, color: const Color(0xFFDFE7EC))),
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
