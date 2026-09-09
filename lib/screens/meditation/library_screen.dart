import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/meditation_session.dart';
import '../../models/mood.dart';
import '../../services/sessions_api.dart';
import '../../state/app_state.dart';
import '../../theme/colors.dart';
import '../../widgets/may.dart';
import '../premium/paywall_screen.dart';
import 'minute_with_justin_screen.dart';
import 'player_screen.dart';

const _categories = ['Tất cả', 'Lo lắng', 'Ngủ', 'Tập trung'];
const _categoryKeys = [null, 'lo-lang', 'ngu', 'tap-trung'];

const _guideNames = {'justin': 'Justin Nguyễn', 'tram': 'Trâm Nguyễn'};

String _guideName(String key) => _guideNames[key] ?? key;

class LibraryScreen extends StatefulWidget {
  const LibraryScreen({super.key});

  @override
  State<LibraryScreen> createState() => _LibraryScreenState();
}

class _LibraryScreenState extends State<LibraryScreen> {
  int _categoryIndex = 0;
  late Future<List<MeditationSession>> _future;

  @override
  void initState() {
    super.initState();
    _future = SessionsApi.instance.fetchAll();
  }

  @override
  Widget build(BuildContext context) {
    final isPremium = context.watch<AppState>().plan != PlanTier.free;

    void openSession(MeditationSession s) {
      if (!s.isFree && !isPremium) {
        Navigator.of(context).push(MaterialPageRoute(builder: (_) => const PaywallScreen()));
        return;
      }
      Navigator.of(context).push(MaterialPageRoute(
        builder: (_) => PlayerScreen(
          kind: s.kind == SessionKind.breathing ? PlayerKind.breathing : PlayerKind.guided,
          title: s.title,
          guide: _guideName(s.guide),
          minutes: s.minutes,
          audioUrl: SessionsApi.instance.resolve(s.audioUrl),
          imageUrl: s.imageUrl != null ? SessionsApi.instance.resolve(s.imageUrl!) : null,
          seriesLabel: s.seriesName != null ? 'Chuỗi "${s.seriesName}" · bài ${s.seriesIndex} / ${s.seriesTotal}' : null,
        ),
      ));
    }

    return Container(
      color: AppColors.appBg,
      child: SafeArea(
        bottom: false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.only(bottom: 40),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(22, 14, 22, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Thiền', style: TextStyle(fontFamily: 'Lora', fontSize: 27, color: AppColors.ink)),
                    const SizedBox(height: 16),
                    Container(
                      height: 44,
                      padding: const EdgeInsets.symmetric(horizontal: 18),
                      alignment: Alignment.centerLeft,
                      decoration: BoxDecoration(color: AppColors.ink.withValues(alpha: 0.05), borderRadius: BorderRadius.circular(22)),
                      child: Text('Tìm bài thiền, chủ đề…', style: TextStyle(fontFamily: 'BeVietnamPro', fontWeight: FontWeight.w300, fontSize: 14, color: AppColors.ink.withValues(alpha: 0.4))),
                    ),
                  ],
                ),
              ),
              SizedBox(
                height: 50,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 8),
                  children: List.generate(_categories.length, (i) {
                    final active = i == _categoryIndex;
                    return GestureDetector(
                      onTap: () => setState(() => _categoryIndex = i),
                      child: Container(
                        margin: const EdgeInsets.only(right: 8),
                        height: 34,
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: active ? AppColors.ink : Colors.white,
                          borderRadius: BorderRadius.circular(17),
                          border: Border.all(color: active ? AppColors.ink : AppColors.ink.withValues(alpha: 0.08)),
                        ),
                        child: Text(_categories[i], style: TextStyle(fontFamily: 'BeVietnamPro', fontWeight: active ? FontWeight.w500 : FontWeight.w400, fontSize: 13, color: active ? Colors.white : AppColors.ink.withValues(alpha: 0.6))),
                      ),
                    );
                  }),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 22),
                child: GestureDetector(
                  onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const PlayerScreen(kind: PlayerKind.breathing, title: 'Thở cùng Mây', minutes: 5))),
                  child: Container(
                    height: 158,
                    padding: const EdgeInsets.all(20),
                    clipBehavior: Clip.hardEdge,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(26),
                      gradient: const LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [Color(0xFF2E4A42), Color(0xFF16201E)]),
                    ),
                    child: Stack(children: [
                      const Positioned(right: -20, top: -10, child: May(mood: Mood.binhYen, size: 110)),
                      Align(
                        alignment: Alignment.bottomLeft,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            SizedBox(width: 200, child: Text('MIỄN PHÍ · BÀI TẬP THỞ', style: TextStyle(fontFamily: 'BeVietnamPro', fontSize: 11, letterSpacing: 1, color: Colors.white.withValues(alpha: 0.55)))),
                            const SizedBox(height: 8),
                            const SizedBox(width: 210, child: Text('Thở cùng Mây', style: TextStyle(fontFamily: 'Lora', fontSize: 24, color: Colors.white))),
                            const SizedBox(height: 6),
                            Text('5 phút · hít 4, giữ 4, thở 6', style: TextStyle(fontFamily: 'BeVietnamPro', fontWeight: FontWeight.w300, fontSize: 13, color: Colors.white.withValues(alpha: 0.6))),
                          ],
                        ),
                      ),
                    ]),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(22, 20, 22, 0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text('MỘT PHÚT CÙNG JUSTIN NGUYỄN', style: TextStyle(fontFamily: 'BeVietnamPro', fontSize: 11, letterSpacing: 1, color: AppColors.ink.withValues(alpha: 0.45))),
                    ),
                    const SizedBox(width: 8),
                    Text('Xem tất cả', style: TextStyle(fontFamily: 'BeVietnamPro', fontWeight: FontWeight.w300, fontSize: 12.5, color: AppColors.ink.withValues(alpha: 0.45))),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(22, 12, 22, 0),
                child: Row(children: [
                  Expanded(child: _MinuteCard(title: 'Khi lòng mình ồn ào', meta: 'Video · 90 giây', color: const Color(0xFFE4EDF3))),
                  const SizedBox(width: 12),
                  Expanded(child: _MinuteCard(title: 'Một điều để nhớ', meta: 'Đọc · 1 phút', color: AppColors.lavenderTint)),
                ]),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(22, 20, 22, 0),
                child: Text('BÀI THIỀN', style: TextStyle(fontFamily: 'BeVietnamPro', fontSize: 11, letterSpacing: 1, color: AppColors.ink.withValues(alpha: 0.45))),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(22, 12, 22, 0),
                child: FutureBuilder<List<MeditationSession>>(
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
                    final key = _categoryKeys[_categoryIndex];
                    final sessions = (snap.data ?? []).where((s) => key == null || s.category == key).toList();
                    if (sessions.isEmpty) {
                      return Text('Chưa có bài nào ở mục này.', style: TextStyle(fontFamily: 'BeVietnamPro', fontWeight: FontWeight.w300, fontSize: 13.5, color: AppColors.ink.withValues(alpha: 0.45)));
                    }
                    return Column(
                      children: [
                        for (final s in sessions) ...[
                          _ListMeditationCard(
                            title: s.title,
                            meta: 'Thiền dẫn · ${_guideName(s.guide)} · ${s.minutes} phút',
                            color: s.guide == 'justin' ? AppColors.sageTint : AppColors.lavenderTint,
                            free: s.isFree,
                            onTap: () => openSession(s),
                          ),
                          const SizedBox(height: 10),
                        ],
                      ],
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MinuteCard extends StatelessWidget {
  final String title;
  final String meta;
  final Color color;
  const _MinuteCard({required this.title, required this.meta, required this.color});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const MinuteWithJustinScreen())),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), border: Border.all(color: AppColors.ink.withValues(alpha: 0.06))),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(height: 70, decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(14))),
            const SizedBox(height: 12),
            Text(title, style: const TextStyle(fontFamily: 'BeVietnamPro', fontWeight: FontWeight.w500, fontSize: 14, color: AppColors.ink)),
            const SizedBox(height: 3),
            Text(meta, style: TextStyle(fontFamily: 'BeVietnamPro', fontWeight: FontWeight.w300, fontSize: 12, color: AppColors.ink.withValues(alpha: 0.5))),
          ],
        ),
      ),
    );
  }
}

class _ListMeditationCard extends StatelessWidget {
  final String title;
  final String meta;
  final Color color;
  final bool free;
  final VoidCallback onTap;
  const _ListMeditationCard({required this.title, required this.meta, required this.color, required this.free, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), border: Border.all(color: AppColors.ink.withValues(alpha: 0.06))),
        child: Row(children: [
          Container(width: 56, height: 56, decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(16))),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontFamily: 'BeVietnamPro', fontWeight: FontWeight.w500, fontSize: 15, color: AppColors.ink)),
                const SizedBox(height: 3),
                Text(meta, style: TextStyle(fontFamily: 'BeVietnamPro', fontWeight: FontWeight.w300, fontSize: 12.5, color: AppColors.ink.withValues(alpha: 0.5))),
              ],
            ),
          ),
          if (free)
            Container(
              height: 26,
              padding: const EdgeInsets.symmetric(horizontal: 10),
              alignment: Alignment.center,
              decoration: BoxDecoration(color: AppColors.sageTint, borderRadius: BorderRadius.circular(13)),
              child: const Text('Miễn phí', style: TextStyle(fontFamily: 'BeVietnamPro', fontWeight: FontWeight.w500, fontSize: 11, color: AppColors.sageTintText)),
            )
          else
            Container(
              width: 26,
              height: 26,
              decoration: BoxDecoration(color: AppColors.ink.withValues(alpha: 0.06), borderRadius: BorderRadius.circular(13)),
            ),
        ]),
      ),
    );
  }
}
