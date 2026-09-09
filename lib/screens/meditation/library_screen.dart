import 'dart:math';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/meditation_session.dart';
import '../../models/mood.dart';
import '../../services/meditation_recommend.dart';
import '../../services/sessions_api.dart';
import '../../state/app_state.dart';
import '../../theme/colors.dart';
import '../../widgets/may.dart';
import '../premium/paywall_screen.dart';
import 'player_screen.dart';

const _categories = ['Chữa lành', 'Lo âu', 'Thư giãn', 'Tích cực'];
const _categoryKeys = ['chua-lanh', 'lo-au', 'thu-gian', 'tich-cuc'];

class LibraryScreen extends StatefulWidget {
  const LibraryScreen({super.key});

  @override
  State<LibraryScreen> createState() => _LibraryScreenState();
}

class _LibraryScreenState extends State<LibraryScreen> {
  final Set<int> _selectedCategories = {};
  late Future<List<MeditationSession>> _future;
  final _searchCtrl = TextEditingController();
  String _query = '';
  MeditationSession? _recommended;

  /// Always a positive expression on the recommendation card — not tied to
  /// the recorded mood that produced the recommendation.
  final Mood _cardMood = Random().nextBool() ? Mood.vui : Mood.binhYen;

  @override
  void initState() {
    super.initState();
    _future = SessionsApi.instance.fetchAll();
    _searchCtrl.addListener(() => setState(() => _query = _searchCtrl.text.trim().toLowerCase()));
    _future.then((sessions) {
      if (!mounted) return;
      final mood = context.read<AppState>().draftMood;
      setState(() => _recommended = pickRecommendation(sessions, mood));
    }).catchError((Object e) {
      debugPrint('LibraryScreen: failed to load recommendation: $e');
    });
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
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
          guide: guideName(s.guide),
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
                    const Text('Thiền và Thở', style: TextStyle(fontFamily: 'Lora', fontSize: 27, color: AppColors.ink)),
                    const SizedBox(height: 16),
                    Container(
                      height: 44,
                      padding: const EdgeInsets.symmetric(horizontal: 18),
                      decoration: BoxDecoration(color: AppColors.ink.withValues(alpha: 0.05), borderRadius: BorderRadius.circular(22)),
                      child: Row(children: [
                        Icon(Icons.search_rounded, size: 19, color: AppColors.ink.withValues(alpha: 0.35)),
                        const SizedBox(width: 8),
                        Expanded(
                          child: TextField(
                            controller: _searchCtrl,
                            style: const TextStyle(fontFamily: 'BeVietnamPro', fontWeight: FontWeight.w400, fontSize: 14, color: AppColors.ink),
                            decoration: InputDecoration(
                              isDense: true,
                              border: InputBorder.none,
                              hintText: 'Tìm bài thiền, chủ đề…',
                              hintStyle: TextStyle(fontFamily: 'BeVietnamPro', fontWeight: FontWeight.w300, fontSize: 14, color: AppColors.ink.withValues(alpha: 0.4)),
                            ),
                          ),
                        ),
                        if (_query.isNotEmpty)
                          GestureDetector(
                            onTap: () => _searchCtrl.clear(),
                            child: Icon(Icons.close_rounded, size: 18, color: AppColors.ink.withValues(alpha: 0.35)),
                          ),
                      ]),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(22, 10, 22, 4),
                child: Row(
                  children: List.generate(_categories.length, (i) {
                    final active = _selectedCategories.contains(i);
                    return Expanded(
                      child: Padding(
                        padding: EdgeInsets.only(right: i == _categories.length - 1 ? 0 : 8),
                        child: GestureDetector(
                          onTap: () => setState(() {
                            if (!_selectedCategories.add(i)) _selectedCategories.remove(i);
                          }),
                          child: Container(
                            height: 34,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: active ? AppColors.ink : Colors.white,
                              borderRadius: BorderRadius.circular(17),
                              border: Border.all(color: active ? AppColors.ink : AppColors.ink.withValues(alpha: 0.08)),
                            ),
                            child: Text(
                              _categories[i],
                              textAlign: TextAlign.center,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(fontFamily: 'BeVietnamPro', fontWeight: active ? FontWeight.w500 : FontWeight.w400, fontSize: 12.5, color: active ? Colors.white : AppColors.ink.withValues(alpha: 0.6)),
                            ),
                          ),
                        ),
                      ),
                    );
                  }),
                ),
              ),
              if (_recommended != null)
                Padding(
                  padding: const EdgeInsets.fromLTRB(22, 18, 22, 0),
                  child: _RecommendedCard(session: _recommended!, mood: _cardMood, onTap: () => openSession(_recommended!)),
                ),
              Padding(
                padding: const EdgeInsets.fromLTRB(22, 20, 22, 0),
                child: Text('BÀI HƯỚNG DẪN', style: TextStyle(fontFamily: 'BeVietnamPro', fontSize: 11, letterSpacing: 1, color: AppColors.ink.withValues(alpha: 0.45))),
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
                    final selectedKeys = _selectedCategories.map((i) => _categoryKeys[i]).toSet();
                    final sessions = (snap.data ?? [])
                        .where((s) => selectedKeys.isEmpty || s.categories.any(selectedKeys.contains))
                        .where((s) => _query.isEmpty || s.title.toLowerCase().contains(_query) || guideName(s.guide).toLowerCase().contains(_query))
                        .toList();
                    if (sessions.isEmpty) {
                      final msg = _query.isNotEmpty ? 'Không tìm thấy bài nào cho "$_query".' : 'Chưa có bài nào ở mục này.';
                      return Text(msg, style: TextStyle(fontFamily: 'BeVietnamPro', fontWeight: FontWeight.w300, fontSize: 13.5, color: AppColors.ink.withValues(alpha: 0.45)));
                    }
                    return Column(
                      children: [
                        for (final s in sessions) ...[
                          _ListMeditationCard(
                            title: s.title,
                            typeDuration: '${s.kind == SessionKind.breathing ? "Bài thở" : "Bài thiền"} · ${s.minutes} phút',
                            guideLine: 'Hướng dẫn bởi ${guideName(s.guide)}',
                            color: s.guide == 'justin' ? AppColors.sageTint : AppColors.lavenderTint,
                            imageUrl: s.imageUrl != null ? SessionsApi.instance.resolve(s.imageUrl!) : null,
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

class _RecommendedCard extends StatelessWidget {
  final MeditationSession session;
  final Mood mood;
  final VoidCallback onTap;
  const _RecommendedCard({required this.session, required this.mood, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final typeLabel = session.kind == SessionKind.breathing ? 'BÀI TẬP THỞ' : 'BÀI THIỀN DẪN';
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 158,
        padding: const EdgeInsets.all(20),
        clipBehavior: Clip.hardEdge,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(26),
          gradient: const LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [Color(0xFF2E4A42), Color(0xFF16201E)]),
        ),
        child: Stack(children: [
          Positioned(right: 10, top: 16, child: _RecommendedMay(mood: mood)),
          Align(
            alignment: Alignment.bottomLeft,
            child: Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(width: 210, child: Text('ĐỀ XUẤT CHO BẠN · $typeLabel', style: TextStyle(fontFamily: 'BeVietnamPro', fontSize: 11, letterSpacing: 1, color: Colors.white.withValues(alpha: 0.55)))),
                  const SizedBox(height: 8),
                  SizedBox(width: 210, child: Text(session.title, style: const TextStyle(fontFamily: 'Lora', fontSize: 24, color: Colors.white))),
                  const SizedBox(height: 6),
                  Text('${guideName(session.guide)} · ${session.minutes} phút', style: TextStyle(fontFamily: 'BeVietnamPro', fontWeight: FontWeight.w300, fontSize: 13, color: Colors.white.withValues(alpha: 0.6))),
                ],
              ),
            ),
          ),
        ]),
      ),
    );
  }
}

/// Mây with a slow "breathing" pulse on top of her own idle animation — sized
/// and positioned to stay clear of the card's clipped edge so the halo never
/// gets cut off mid-glow.
class _RecommendedMay extends StatefulWidget {
  final Mood mood;
  const _RecommendedMay({required this.mood});

  @override
  State<_RecommendedMay> createState() => _RecommendedMayState();
}

class _RecommendedMayState extends State<_RecommendedMay> with SingleTickerProviderStateMixin {
  late final AnimationController _pulse;

  @override
  void initState() {
    super.initState();
    _pulse = AnimationController(vsync: this, duration: const Duration(milliseconds: 4200))..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulse.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _pulse,
      builder: (context, child) => Transform.scale(scale: 0.94 + 0.12 * _pulse.value, child: child),
      child: May(mood: widget.mood, size: 96),
    );
  }
}

class _ListMeditationCard extends StatelessWidget {
  final String title;
  final String typeDuration;
  final String guideLine;
  final Color color;
  final String? imageUrl;
  final bool free;
  final VoidCallback onTap;
  const _ListMeditationCard({required this.title, required this.typeDuration, required this.guideLine, required this.color, this.imageUrl, required this.free, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), border: Border.all(color: AppColors.ink.withValues(alpha: 0.06))),
        child: Row(children: [
          Container(
            width: 56,
            height: 56,
            clipBehavior: Clip.hardEdge,
            decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(16)),
            child: imageUrl != null ? Image.network(imageUrl!, fit: BoxFit.cover, errorBuilder: (_, _, _) => const SizedBox.shrink()) : null,
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontFamily: 'BeVietnamPro', fontWeight: FontWeight.w500, fontSize: 15, color: AppColors.ink)),
                const SizedBox(height: 3),
                Text(typeDuration, style: TextStyle(fontFamily: 'BeVietnamPro', fontWeight: FontWeight.w300, fontSize: 12.5, color: AppColors.ink.withValues(alpha: 0.5))),
                const SizedBox(height: 2),
                Text(guideLine, style: TextStyle(fontFamily: 'BeVietnamPro', fontWeight: FontWeight.w300, fontSize: 12.5, color: AppColors.ink.withValues(alpha: 0.5))),
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
