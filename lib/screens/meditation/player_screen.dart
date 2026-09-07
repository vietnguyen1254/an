import 'dart:async';
import 'package:flutter/material.dart';
import '../../models/mood.dart';
import '../../theme/colors.dart';
import '../../widgets/may.dart';

enum PlayerKind { breathing, guided }

class PlayerScreen extends StatefulWidget {
  final PlayerKind kind;
  final String title;
  final String? guide;
  final int minutes;

  const PlayerScreen({super.key, required this.kind, required this.title, this.guide, this.minutes = 5});

  @override
  State<PlayerScreen> createState() => _PlayerScreenState();
}

const _breaths = ['Hít vào…', 'Giữ…', 'Thở ra…'];

class _PlayerScreenState extends State<PlayerScreen> with SingleTickerProviderStateMixin {
  bool _playing = true;
  int _phase = 0;
  int _elapsed = 0;
  Timer? _phaseTimer;
  Timer? _tickTimer;
  late final AnimationController _breatheCtrl;

  int get _total => widget.minutes * 60;

  @override
  void initState() {
    super.initState();
    _breatheCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 4500))..repeat(reverse: true);
    _phaseTimer = Timer.periodic(const Duration(milliseconds: 4500), (_) {
      if (_playing) setState(() => _phase = (_phase + 1) % 3);
    });
    _tickTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (_playing && _elapsed < _total) setState(() => _elapsed++);
    });
  }

  @override
  void dispose() {
    _phaseTimer?.cancel();
    _tickTimer?.cancel();
    _breatheCtrl.dispose();
    super.dispose();
  }

  String _fmt(int sec) {
    final m = sec ~/ 60;
    final s = sec % 60;
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final pct = (_elapsed / _total).clamp(0.0, 1.0);
    final breathLabel = _playing ? _breaths[_phase] : 'Tạm dừng';

    return Scaffold(
      backgroundColor: AppColors.sessionDarkC,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(26, 8, 26, 40),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  GestureDetector(
                    onTap: () => Navigator.of(context).pop(),
                    child: Text('Xong', style: TextStyle(fontFamily: 'BeVietnamPro', fontSize: 14, color: Colors.white.withValues(alpha: 0.5))),
                  ),
                  Text(
                    widget.kind == PlayerKind.guided ? 'Đang phát' : widget.title,
                    style: TextStyle(fontFamily: 'BeVietnamPro', fontSize: 13, color: Colors.white.withValues(alpha: 0.4)),
                  ),
                  Container(width: 22, height: 22, decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: Colors.white.withValues(alpha: 0.2)))),
                ],
              ),
              if (widget.kind == PlayerKind.breathing) ...[
                SizedBox(
                  height: 320,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      AnimatedBuilder(
                        animation: _breatheCtrl,
                        builder: (context, child) => Transform.scale(scale: 0.86 + 0.2 * _breatheCtrl.value, child: child),
                        child: Container(width: 300, height: 300, decoration: BoxDecoration(shape: BoxShape.circle, color: AppColors.rose.withValues(alpha: 0.16))),
                      ),
                      Container(width: 236, height: 236, decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: Colors.white.withValues(alpha: 0.14)))),
                      Container(width: 170, height: 170, decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: Colors.white.withValues(alpha: 0.08)))),
                      const May(mood: Mood.binhYen, size: 110),
                    ],
                  ),
                ),
                const SizedBox(height: 6),
                Text(breathLabel, style: const TextStyle(fontFamily: 'Lora', fontSize: 30, color: Colors.white)),
                const SizedBox(height: 10),
                Text('Theo nhịp của Mây, không cần gắng', style: TextStyle(fontFamily: 'BeVietnamPro', fontWeight: FontWeight.w300, fontSize: 14, color: Colors.white.withValues(alpha: 0.45))),
              ] else ...[
                Container(margin: const EdgeInsets.only(top: 20), height: 260, decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.06), borderRadius: BorderRadius.circular(28))),
                const SizedBox(height: 24),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(widget.title, style: const TextStyle(fontFamily: 'Lora', fontSize: 27, height: 36 / 27, color: Colors.white)),
                ),
                const SizedBox(height: 16),
                Row(children: [
                  Container(width: 36, height: 36, decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.white.withValues(alpha: 0.14))),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Thiền dẫn · ${widget.guide}', style: const TextStyle(fontFamily: 'BeVietnamPro', fontWeight: FontWeight.w500, fontSize: 14, color: Colors.white)),
                        const SizedBox(height: 2),
                        Text('Chuỗi "Trở về" · bài 3 / 7', style: TextStyle(fontFamily: 'BeVietnamPro', fontWeight: FontWeight.w300, fontSize: 12.5, color: Colors.white.withValues(alpha: 0.45))),
                      ],
                    ),
                  ),
                  Container(
                    height: 32,
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.white.withValues(alpha: 0.22))),
                    child: Text('Theo dõi', style: TextStyle(fontFamily: 'BeVietnamPro', fontSize: 12.5, color: Colors.white.withValues(alpha: 0.75))),
                  ),
                ]),
              ],
              const Spacer(),
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                Text(_fmt(_elapsed), style: TextStyle(fontFamily: 'BeVietnamPro', fontWeight: FontWeight.w300, fontSize: 12, color: Colors.white.withValues(alpha: 0.45))),
                Text('-${_fmt((_total - _elapsed).clamp(0, _total))}', style: TextStyle(fontFamily: 'BeVietnamPro', fontWeight: FontWeight.w300, fontSize: 12, color: Colors.white.withValues(alpha: 0.45))),
              ]),
              const SizedBox(height: 8),
              ClipRRect(
                borderRadius: BorderRadius.circular(2),
                child: Container(
                  height: 3,
                  color: Colors.white.withValues(alpha: 0.14),
                  child: FractionallySizedBox(widthFactor: pct, alignment: Alignment.centerLeft, child: Container(color: Colors.white.withValues(alpha: 0.75))),
                ),
              ),
              const SizedBox(height: 28),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _skipBtn(),
                  const SizedBox(width: 34),
                  GestureDetector(
                    onTap: () => setState(() => _playing = !_playing),
                    child: Container(
                      width: 72,
                      height: 72,
                      alignment: Alignment.center,
                      decoration: const BoxDecoration(shape: BoxShape.circle, color: Colors.white),
                      child: Text(_playing ? 'Dừng' : 'Tiếp', style: const TextStyle(fontFamily: 'BeVietnamPro', fontWeight: FontWeight.w500, fontSize: 13, color: Color(0xFF16201E))),
                    ),
                  ),
                  const SizedBox(width: 34),
                  _skipBtn(),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _skipBtn() {
    return Container(
      width: 44,
      height: 44,
      alignment: Alignment.center,
      decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: Colors.white.withValues(alpha: 0.18))),
      child: Text('15', style: TextStyle(fontFamily: 'BeVietnamPro', fontSize: 12, color: Colors.white.withValues(alpha: 0.6))),
    );
  }
}
