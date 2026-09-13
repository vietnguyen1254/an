import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/meditation_session.dart';
import '../../services/meditation_recommend.dart';
import '../../services/sessions_api.dart';
import '../../state/app_state.dart';
import '../../theme/colors.dart';
import '../../utils/vn_date.dart';
import '../../widgets/may.dart';
import '../../widgets/session_thumb.dart';
import '../checkin/mood_checkin_screen.dart';
import '../meditation/player_screen.dart';
import '../premium/paywall_screen.dart';

class DayDetailScreen extends StatefulWidget {
  final String entryId;
  const DayDetailScreen({super.key, required this.entryId});

  @override
  State<DayDetailScreen> createState() => _DayDetailScreenState();
}

class _DayDetailScreenState extends State<DayDetailScreen> {
  late final Future<List<MeditationSession>> _sessionsFuture;

  @override
  void initState() {
    super.initState();
    _sessionsFuture = SessionsApi.instance.fetchAll();
  }

  Future<void> _confirmDelete(BuildContext context, String id) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: const Text('Xoá cảm xúc này?', style: TextStyle(fontFamily: 'Lora', fontSize: 20, color: AppColors.ink)),
        content: Text(
          'Ghi chú và toàn bộ chi tiết ngày này sẽ bị xoá vĩnh viễn.',
          style: TextStyle(fontFamily: 'BeVietnamPro', fontWeight: FontWeight.w300, fontSize: 13.5, height: 22 / 13.5, color: AppColors.ink.withValues(alpha: 0.7)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text('Huỷ', style: TextStyle(fontFamily: 'BeVietnamPro', fontSize: 14, color: AppColors.ink.withValues(alpha: 0.5))),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Xoá', style: TextStyle(fontFamily: 'BeVietnamPro', fontWeight: FontWeight.w500, fontSize: 14, color: AppColors.danger)),
          ),
        ],
      ),
    );
    if (!(confirmed ?? false)) return;
    if (!context.mounted) return;
    await context.read<AppState>().deleteEntry(id);
    if (context.mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final matches = state.entries.where((e) => e.id == widget.entryId);
    if (matches.isEmpty) return const SizedBox.shrink();
    final entry = matches.first;

    final tagLabels = entry.tags
        .map(
          (k) => kTags
              .firstWhere((t) => t.key == k, orElse: () => TagDef(k, k))
              .label,
        )
        .toList();

    // Sessions actually listened to on this calendar day — one card per
    // distinct session, no listened-duration detail (not tracked per-session).
    final listenedSessionIds = state.meditationLog
        .where((m) => m.date.year == entry.entryDate.year && m.date.month == entry.entryDate.month && m.date.day == entry.entryDate.day)
        .map((m) => m.sessionId)
        .whereType<String>()
        .toSet();

    void openSession(MeditationSession s) {
      final isPremium = state.plan != PlanTier.free;
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
      backgroundColor: moodWash(entry.mood),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(22, 14, 22, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  GestureDetector(
                    onTap: () => Navigator.of(context).pop(),
                    child: Text(
                      'Đóng',
                      style: TextStyle(
                        fontFamily: 'BeVietnamPro',
                        fontSize: 14,
                        color: AppColors.ink.withValues(alpha: 0.5),
                      ),
                    ),
                  ),
                  Row(
                    children: [
                      GestureDetector(
                        onTap: () {
                          context.read<AppState>().beginEditEntry(entry);
                          Navigator.of(context).push(
                            MaterialPageRoute(builder: (_) => MoodCheckInScreen(skipSavedScreen: true, forDate: entry.entryDate)),
                          );
                        },
                        child: Text(
                          'Sửa',
                          style: TextStyle(
                            fontFamily: 'BeVietnamPro',
                            fontSize: 14,
                            color: AppColors.ink.withValues(alpha: 0.5),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      GestureDetector(
                        onTap: () => _confirmDelete(context, entry.id),
                        child: Text(
                          'Xoá',
                          style: TextStyle(
                            fontFamily: 'BeVietnamPro',
                            fontSize: 14,
                            color: AppColors.ink.withValues(alpha: 0.5),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 22),
              Text(
                formatVietnameseDate(entry.entryDate),
                style: TextStyle(
                  fontFamily: 'BeVietnamPro',
                  fontWeight: FontWeight.w300,
                  fontSize: 13,
                  color: AppColors.ink.withValues(alpha: 0.5),
                ),
              ),
              const SizedBox(height: 6),
              Text(
                moodLabels[entry.mood]!,
                style: const TextStyle(
                  fontFamily: 'Lora',
                  fontSize: 27,
                  color: AppColors.ink,
                ),
              ),
              SizedBox(
                height: 138,
                child: Center(
                  child: Transform.translate(
                    offset: const Offset(-18, -14),
                    child: May(mood: entry.mood, size: 150),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: AppColors.ink.withValues(alpha: 0.06),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'MỨC ĐỘ',
                          style: TextStyle(
                            fontFamily: 'BeVietnamPro',
                            fontSize: 10.5,
                            letterSpacing: 1,
                            color: AppColors.ink.withValues(alpha: 0.45),
                          ),
                        ),
                        Text(
                          intensityLabel(entry.intensity),
                          style: TextStyle(
                            fontFamily: 'BeVietnamPro',
                            fontWeight: FontWeight.w300,
                            fontSize: 13,
                            color: AppColors.ink.withValues(alpha: 0.55),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(3),
                      child: LayoutBuilder(
                        builder: (context, c) {
                          return Container(
                            height: 6,
                            color: AppColors.ink.withValues(alpha: 0.09),
                            child: Align(
                              alignment: Alignment.centerLeft,
                              child: Container(
                                width:
                                    c.maxWidth *
                                    entry.intensity /
                                    kIntensityMax,
                                color: moodSolid(entry.mood),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      'ĐIỀU ẢNH HƯỞNG',
                      style: TextStyle(
                        fontFamily: 'BeVietnamPro',
                        fontSize: 10.5,
                        letterSpacing: 1,
                        color: AppColors.ink.withValues(alpha: 0.45),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: tagLabels
                          .map(
                            (label) => Container(
                              height: 32,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 14,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.sageTint,
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Center(
                                widthFactor: 1,
                                child: Text(
                                  label,
                                  style: const TextStyle(
                                    fontFamily: 'BeVietnamPro',
                                    fontWeight: FontWeight.w500,
                                    fontSize: 13,
                                    color: AppColors.sageTintText,
                                  ),
                                ),
                              ),
                            ),
                          )
                          .toList(),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      'BẠN VIẾT',
                      style: TextStyle(
                        fontFamily: 'BeVietnamPro',
                        fontSize: 10.5,
                        letterSpacing: 1,
                        color: AppColors.ink.withValues(alpha: 0.45),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      entry.note.isEmpty ? '—' : entry.note,
                      style: TextStyle(
                        fontFamily: 'BeVietnamPro',
                        fontWeight: FontWeight.w300,
                        fontSize: 14.5,
                        height: 26 / 14.5,
                        color: AppColors.ink.withValues(alpha: 0.72),
                      ),
                    ),
                  ],
                ),
              ),
              if (listenedSessionIds.isNotEmpty)
                FutureBuilder<List<MeditationSession>>(
                  future: _sessionsFuture,
                  builder: (context, snap) {
                    final sessions = (snap.data ?? []).where((s) => listenedSessionIds.contains(s.id)).toList();
                    if (sessions.isEmpty) return const SizedBox.shrink();
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 20),
                        Text(
                          'BẠN ĐÃ NGHE',
                          style: TextStyle(
                            fontFamily: 'BeVietnamPro',
                            fontSize: 10.5,
                            letterSpacing: 1,
                            color: AppColors.ink.withValues(alpha: 0.45),
                          ),
                        ),
                        const SizedBox(height: 10),
                        for (final s in sessions) ...[
                          _SessionCard(session: s, onTap: () => openSession(s)),
                          const SizedBox(height: 10),
                        ],
                      ],
                    );
                  },
                ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Same visual style as the session list cards in LibraryScreen — kept as
/// its own private widget here since that one isn't importable (private to
/// its file).
class _SessionCard extends StatelessWidget {
  final MeditationSession session;
  final VoidCallback onTap;
  const _SessionCard({required this.session, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final imageUrl = session.imageUrl != null ? SessionsApi.instance.resolve(session.imageUrl!) : null;
    final color = session.guide == 'justin' ? AppColors.sageTint : AppColors.lavenderTint;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), border: Border.all(color: AppColors.ink.withValues(alpha: 0.06))),
        child: Row(
          children: [
            SessionThumbnail(color: color, imageUrl: imageUrl),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(session.title, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontFamily: 'BeVietnamPro', fontWeight: FontWeight.w500, fontSize: 15, color: AppColors.ink)),
                  const SizedBox(height: 3),
                  Text(
                    '${session.kind == SessionKind.breathing ? "Bài thở" : "Bài thiền"} · ${session.minutes} phút',
                    style: TextStyle(fontFamily: 'BeVietnamPro', fontWeight: FontWeight.w300, fontSize: 12.5, color: AppColors.ink.withValues(alpha: 0.5)),
                  ),
                  const SizedBox(height: 2),
                  Text('Hướng dẫn bởi ${guideName(session.guide)}', style: TextStyle(fontFamily: 'BeVietnamPro', fontWeight: FontWeight.w300, fontSize: 12.5, color: AppColors.ink.withValues(alpha: 0.5))),
                ],
              ),
            ),
            if (session.isFree)
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
          ],
        ),
      ),
    );
  }
}
