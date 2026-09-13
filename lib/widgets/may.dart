import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../models/mood.dart';

/// Mây — the cloud companion. Ported 1:1 from the CSS construction in
/// `May copy.dc.html`: a cloud silhouette built from three overlapping
/// circular "lobes" plus a rounded base, plain shapes/gradients only (no
/// illustration asset exists yet — see the design chat transcript).

class _MoodSpec {
  final Color fill;
  final Color shade;
  final Color glow;
  final Color ink;
  final String eyes; // arc | dot | sad | heavy | glare
  final String mouth; // grin | smile | line | o | frown | flat | wavy | grit
  final bool cheeks;
  final String? browStyle; // worried | furrowed | null
  final bool sparkly;
  final bool sway;
  final int drops;

  const _MoodSpec({
    required this.fill,
    required this.shade,
    required this.glow,
    required this.ink,
    required this.eyes,
    required this.mouth,
    this.cheeks = false,
    this.browStyle,
    this.sparkly = false,
    this.sway = false,
    this.drops = 0,
  });
}

final Map<Mood, _MoodSpec> _moods = {
  Mood.tucGian: const _MoodSpec(
    fill: Color(0xFFFDF1EE),
    shade: Color(0x5CDB8A72),
    glow: Color(0x80F2A98C),
    ink: Color(0xFF8C3D2C),
    eyes: 'glare',
    mouth: 'grit',
    browStyle: 'furrowed',
    sway: true,
  ),
  Mood.vui: const _MoodSpec(
    fill: Color(0xFFFFFDF6),
    shade: Color(0x4DEECB96),
    glow: Color(0x99FAE2B4),
    ink: Color(0xFF6B5B3E),
    eyes: 'arc',
    mouth: 'grin',
    cheeks: true,
    sparkly: true,
    sway: true,
  ),
  Mood.binhThuong: const _MoodSpec(
    fill: Color(0xFFFBFCFD),
    shade: Color(0x42B0C4D6),
    glow: Color(0x99FFFFFF),
    ink: Color(0xFF6A7885),
    eyes: 'dot',
    mouth: 'line',
  ),
  Mood.loLang: const _MoodSpec(
    fill: Color(0xFFF4F2F9),
    shade: Color(0x579284B4),
    glow: Color(0x70AAA0C4),
    ink: Color(0xFF5D5375),
    eyes: 'dot',
    mouth: 'wavy',
    browStyle: 'worried',
    sway: true,
  ),
  Mood.buon: const _MoodSpec(
    fill: Color(0xFFE9EFF5),
    shade: Color(0x6B748EAE),
    glow: Color(0x66889BBA),
    ink: Color(0xFF4E617A),
    eyes: 'sad',
    mouth: 'frown',
    drops: 4,
  ),
  Mood.cangThang: const _MoodSpec(
    fill: Color(0xFFF0EFEB),
    shade: Color(0x5CA09888),
    glow: Color(0x52C0A894),
    ink: Color(0xFF6E6656),
    eyes: 'heavy',
    mouth: 'grit',
    browStyle: 'furrowed',
    drops: 2,
  ),
};

const double _box = 200;
const double _bwX = (_box - 178) / 2; // 11
const double _bwY = (_box - 120) / 2; // 40

class May extends StatefulWidget {
  final Mood mood;
  final double size;

  const May({super.key, this.mood = Mood.binhThuong, this.size = 96});

  @override
  State<May> createState() => _MayState();
}

class _MayState extends State<May> with TickerProviderStateMixin {
  late final AnimationController _swayCtrl;
  late final AnimationController _floatCtrl;
  late final AnimationController _sparkCtrl;

  @override
  void initState() {
    super.initState();
    _swayCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 4500),
    )..repeat();
    _floatCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 7000),
    )..repeat(reverse: true);
    _sparkCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3400),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _swayCtrl.dispose();
    _floatCtrl.dispose();
    _sparkCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final m = _moods[widget.mood] ?? _moods[Mood.binhThuong]!;
    final scale = widget.size / _box;
    final droop = m.eyes == 'heavy' ? 6.0 : 0.0;

    return SizedBox(
      width: widget.size,
      height: widget.size,
      child: Center(
        child: AnimatedBuilder(
          animation: _floatCtrl,
          builder: (context, child) {
            final ty = -6.0 * _floatCtrl.value;
            return Transform.translate(offset: Offset(0, ty), child: child);
          },
          child: Transform.scale(
            scale: scale,
            child: SizedBox(
              width: _box,
              height: _box,
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  _glow(344, 300, m.glow, 0.46),
                  _glow(232, 206, m.glow, 0.7),
                  if (m.sparkly) ..._sparkles(),
                  AnimatedBuilder(
                    animation: _swayCtrl,
                    builder: (context, child) {
                      final tx = m.sway
                          ? 3.0 * math.sin(_swayCtrl.value * 2 * math.pi)
                          : 0.0;
                      return Transform.translate(
                        offset: Offset(tx, 0),
                        child: child,
                      );
                    },
                    child: _cloudBody(m, droop),
                  ),
                  if (m.drops > 0) _rain(m.drops),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// A halo layer: a radial wash that fades to fully transparent at the rim,
  /// so it blends into whatever is behind Mây with no visible edge.
  Widget _glow(double w, double h, Color color, double opacity) {
    return Positioned(
      left: (_box - w) / 2,
      top: (_box - h) / 2,
      child: IgnorePointer(
        child: Container(
          width: w,
          height: h,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(999),
            gradient: RadialGradient(
              colors: [
                color.withValues(alpha: opacity),
                color.withValues(alpha: opacity * 0.55),
                color.withValues(alpha: 0),
              ],
              stops: const [0.0, 0.55, 1.0],
            ),
          ),
        ),
      ),
    );
  }

  /// Two twinkles anchored right against the cloud's own rim (not floating
  /// in the empty space above it) — at small render sizes (e.g. the library
  /// screen's recommendation card) a sparkle positioned in that empty space
  /// reads as a stray disconnected dot rather than a twinkle on the cloud.
  List<Widget> _sparkles() {
    return [
      AnimatedBuilder(
        animation: _sparkCtrl,
        builder: (context, _) => Positioned(
          left: _bwX + 22,
          top: _bwY + 28,
          child: Transform.rotate(
            angle: math.pi / 4,
            child: Opacity(
              opacity: 0.15 + 0.55 * _sparkCtrl.value,
              child: Container(
                width: 6,
                height: 6,
                color: const Color(0xB2F6D8A6),
              ),
            ),
          ),
        ),
      ),
      AnimatedBuilder(
        animation: _sparkCtrl,
        builder: (context, _) => Positioned(
          left: _bwX + 152,
          top: _bwY + 32,
          child: Transform.rotate(
            angle: math.pi / 4,
            child: Opacity(
              opacity: 0.15 + 0.55 * (1 - _sparkCtrl.value),
              child: Container(
                width: 5,
                height: 5,
                color: const Color(0x99F6D8A6),
              ),
            ),
          ),
        ),
      ),
    ];
  }

  Widget _cloudBody(_MoodSpec m, double droop) {
    return SizedBox(
      width: _box,
      height: _box,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // cloud lobes
          _circle(_bwX + 14, _bwY + 34, 66, m.fill),
          _circle(_bwX + 52, _bwY + 8, 88, m.fill),
          _circle(_bwX + 108, _bwY + 38, 62, m.fill),
          _roundedRect(_bwX + 2, _bwY + 56, 174, 60, 30, m.fill),
          // underside shade
          Positioned(
            left: _bwX + 2,
            top: _bwY + 82,
            child: Container(
              width: 174,
              height: 34,
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(30),
                  bottomRight: Radius.circular(30),
                ),
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [m.shade.withValues(alpha: 0), m.shade],
                ),
              ),
            ),
          ),
          // top shine
          Positioned(
            left: _bwX + 64,
            top: _bwY + 22,
            child: Opacity(
              opacity: 0.85,
              child: Container(
                width: 52,
                height: 22,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(26),
                  gradient: const LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Color(0xF2FFFFFF), Color(0x00FFFFFF)],
                  ),
                ),
              ),
            ),
          ),
          if (m.browStyle == 'worried') ..._worriedBrows(),
          if (m.browStyle == 'furrowed') ..._furrowedBrows(m.ink),
          _eye(m.eyes, 60, droop, m.ink),
          _eye(m.eyes, 104, droop, m.ink),
          if (m.cheeks) ..._cheeks(),
          _mouth(m.mouth, m.ink),
        ],
      ),
    );
  }

  /// Inner corners raised, outer corners low — reads as apprehensive/uneasy.
  List<Widget> _worriedBrows() {
    return [
      Positioned(
        left: _bwX + 58,
        top: _bwY + 50,
        child: Transform.rotate(
          angle: -12 * math.pi / 180,
          child: Container(
            width: 16,
            height: 7,
            decoration: BoxDecoration(
              border: Border(
                top: BorderSide(color: const Color(0x99556E7A), width: 2),
              ),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(8),
                topRight: Radius.circular(8),
              ),
            ),
          ),
        ),
      ),
      Positioned(
        left: _bwX + 104,
        top: _bwY + 50,
        child: Transform.rotate(
          angle: 12 * math.pi / 180,
          child: Container(
            width: 16,
            height: 7,
            decoration: BoxDecoration(
              border: Border(
                top: BorderSide(color: const Color(0x99556E7A), width: 2),
              ),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(8),
                topRight: Radius.circular(8),
              ),
            ),
          ),
        ),
      ),
    ];
  }

  /// Inner corners pulled down and together, lower and steeper than
  /// [_worriedBrows] — a furrowed scowl for Mood.tucGian.
  List<Widget> _furrowedBrows(Color ink) {
    final color = ink.withValues(alpha: 0.75);
    return [
      Positioned(
        left: _bwX + 55,
        top: _bwY + 54,
        child: Transform.rotate(
          angle: 22 * math.pi / 180,
          child: Container(
            width: 18,
            height: 3,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        ),
      ),
      Positioned(
        left: _bwX + 105,
        top: _bwY + 54,
        child: Transform.rotate(
          angle: -22 * math.pi / 180,
          child: Container(
            width: 18,
            height: 3,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        ),
      ),
    ];
  }

  List<Widget> _cheeks() {
    Widget cheek(double left) => Positioned(
      left: left,
      top: _bwY + 76,
      child: Container(
        width: 15,
        height: 9,
        decoration: BoxDecoration(
          color: const Color(0x4DE8B0BE),
          borderRadius: BorderRadius.circular(6),
        ),
      ),
    );
    return [cheek(_bwX + 46), cheek(_bwX + 118)];
  }

  Widget _eye(String type, double x, double droop, Color ink) {
    if (type == 'arc') {
      return Positioned(
        left: _bwX + x,
        top: _bwY + 62 + droop,
        child: Opacity(
          opacity: 0.8,
          child: Container(
            width: 15,
            height: 8,
            decoration: BoxDecoration(
              border: Border(top: BorderSide(color: ink, width: 2)),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(15),
                topRight: Radius.circular(15),
              ),
            ),
          ),
        ),
      );
    }
    if (type == 'sad') {
      return Positioned(
        left: _bwX + x + 3,
        top: _bwY + 64,
        child: Opacity(
          opacity: 0.75,
          child: Container(
            width: 9,
            height: 9,
            decoration: BoxDecoration(color: ink, shape: BoxShape.circle),
          ),
        ),
      );
    }
    if (type == 'glare') {
      final side = x < 89 ? 1.0 : -1.0;
      return Positioned(
        left: _bwX + x - 1,
        top: _bwY + 63 + droop,
        child: Opacity(
          opacity: 0.82,
          child: Transform.rotate(
            angle: side * 18 * math.pi / 180,
            child: Container(
              width: 15,
              height: 3,
              decoration: BoxDecoration(
                color: ink,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
        ),
      );
    }
    if (type == 'heavy') {
      return Positioned(
        left: _bwX + x,
        top: _bwY + 68,
        child: Opacity(
          opacity: 0.7,
          child: Container(
            width: 15,
            height: 3,
            decoration: BoxDecoration(
              color: ink,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        ),
      );
    }
    return Positioned(
      left: _bwX + x + 4,
      top: _bwY + 63,
      child: Opacity(
        opacity: 0.72,
        child: Container(
          width: 7,
          height: 7,
          decoration: BoxDecoration(color: ink, shape: BoxShape.circle),
        ),
      ),
    );
  }

  Widget _mouth(String type, Color ink) {
    const cx = _bwX + 89; // 50% of the 178-wide bodyWrap
    if (type == 'grin') {
      return Positioned(
        left: cx - 9.5,
        top: _bwY + 78,
        child: Opacity(
          opacity: 0.75,
          child: Container(
            width: 19,
            height: 10,
            decoration: BoxDecoration(
              border: Border(bottom: BorderSide(color: ink, width: 2)),
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(14),
                bottomRight: Radius.circular(14),
              ),
            ),
          ),
        ),
      );
    }
    if (type == 'smile') {
      return Positioned(
        left: cx - 6.5,
        top: _bwY + 79,
        child: Opacity(
          opacity: 0.62,
          child: Container(
            width: 13,
            height: 7,
            decoration: BoxDecoration(
              border: Border(bottom: BorderSide(color: ink, width: 2)),
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(10),
                bottomRight: Radius.circular(10),
              ),
            ),
          ),
        ),
      );
    }
    if (type == 'line') {
      return Positioned(
        left: cx - 6.5,
        top: _bwY + 82,
        child: Opacity(
          opacity: 0.6,
          child: Container(
            width: 13,
            height: 2,
            decoration: BoxDecoration(
              color: ink,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        ),
      );
    }
    if (type == 'o') {
      return Positioned(
        left: cx - 4,
        top: _bwY + 78,
        child: Opacity(
          opacity: 0.7,
          child: Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: ink, width: 2),
            ),
          ),
        ),
      );
    }
    if (type == 'wavy') {
      return Positioned(
        left: cx - 9,
        top: _bwY + 80,
        child: Opacity(
          opacity: 0.7,
          child: SizedBox(
            width: 18,
            height: 9,
            child: CustomPaint(painter: _WavyMouthPainter(ink)),
          ),
        ),
      );
    }
    if (type == 'grit') {
      return Positioned(
        left: cx - 8,
        top: _bwY + 80,
        child: Opacity(
          opacity: 0.75,
          child: Container(
            width: 16,
            height: 6,
            decoration: BoxDecoration(
              border: Border.all(color: ink, width: 2),
              borderRadius: BorderRadius.circular(2),
            ),
            child: Center(child: Container(width: 1.5, height: 6, color: ink)),
          ),
        ),
      );
    }
    if (type == 'frown') {
      return Positioned(
        left: cx - 6.5,
        top: _bwY + 84,
        child: Opacity(
          opacity: 0.6,
          child: Container(
            width: 13,
            height: 7,
            decoration: BoxDecoration(
              border: Border(top: BorderSide(color: ink, width: 2)),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(10),
                topRight: Radius.circular(10),
              ),
            ),
          ),
        ),
      );
    }
    return Positioned(
      left: cx - 5,
      top: _bwY + 84,
      child: Opacity(
        opacity: 0.5,
        child: Container(
          width: 10,
          height: 2,
          decoration: BoxDecoration(
            color: ink,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
      ),
    );
  }

  Widget _circle(double left, double top, double diameter, Color color) {
    return Positioned(
      left: left,
      top: top,
      child: Container(
        width: diameter,
        height: diameter,
        decoration: BoxDecoration(color: color, shape: BoxShape.circle),
      ),
    );
  }

  Widget _roundedRect(
    double left,
    double top,
    double w,
    double h,
    double r,
    Color color,
  ) {
    return Positioned(
      left: left,
      top: top,
      child: Container(
        width: w,
        height: h,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(r),
        ),
      ),
    );
  }

  Widget _rain(int count) {
    return Positioned(
      left: 0,
      right: 0,
      top: 132,
      height: 60,
      child: Stack(
        clipBehavior: Clip.none,
        children: List.generate(count, (i) => _RainDrop(index: i)),
      ),
    );
  }
}

class _RainDrop extends StatefulWidget {
  final int index;
  const _RainDrop({required this.index});

  @override
  State<_RainDrop> createState() => _RainDropState();
}

class _RainDropState extends State<_RainDrop>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1900),
    );
    Future.delayed(Duration(milliseconds: widget.index * 420), () {
      if (mounted) _ctrl.repeat();
    });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final w = widget.index.isOdd ? 5.0 : 6.0;
    final h = widget.index.isOdd ? 11.0 : 13.0;
    return AnimatedBuilder(
      animation: _ctrl,
      builder: (context, _) {
        final t = _ctrl.value;
        final ty = 46.0 * t;
        double opacity;
        if (t < 0.18) {
          opacity = t / 0.18 * 0.85;
        } else {
          opacity = 0.85 * (1 - (t - 0.18) / 0.82);
        }
        return Positioned(
          left: 34.0 + widget.index * 34,
          top: ty,
          child: Opacity(
            opacity: opacity.clamp(0.0, 1.0),
            child: Container(
              width: w,
              height: h,
              decoration: BoxDecoration(
                color: const Color(0x9E7E98B8),
                borderRadius: BorderRadius.circular(w / 2),
              ),
            ),
          ),
        );
      },
    );
  }
}

/// A small nervous "~" mouth — reads as uneasy rather than the open "o"
/// (which read as surprise) for Mood.loLang.
class _WavyMouthPainter extends CustomPainter {
  final Color color;
  const _WavyMouthPainter(this.color);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    final path = Path()
      ..moveTo(0, size.height * 0.5)
      ..quadraticBezierTo(size.width * 0.25, 0, size.width * 0.5, size.height * 0.5)
      ..quadraticBezierTo(size.width * 0.75, size.height, size.width, size.height * 0.5);
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _WavyMouthPainter oldDelegate) => oldDelegate.color != color;
}
