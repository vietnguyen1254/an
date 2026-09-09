import 'dart:async';

import 'package:flutter/material.dart';

import '../../theme/colors.dart';
import '../../widgets/app_button.dart';
import '../../widgets/may.dart';
import '../../models/mood.dart';
import 'login_screen.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _controller = PageController();
  int _page = 0;
  Timer? _autoAdvance;

  @override
  void initState() {
    super.initState();
    // Welcome page moves on by itself after a short beat; a swipe still works.
    _autoAdvance = Timer(const Duration(seconds: 3), () {
      if (!mounted || _page != 0) return;
      _controller.animateToPage(
        1,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
    });
  }

  @override
  void dispose() {
    _autoAdvance?.cancel();
    _controller.dispose();
    super.dispose();
  }

  void _goLogin() {
    _autoAdvance?.cancel();
    Navigator.of(
      context,
    ).pushReplacement(MaterialPageRoute(builder: (_) => const LoginScreen()));
  }

  void _next() {
    _autoAdvance?.cancel();
    if (_page == 0) {
      _controller.animateToPage(
        1,
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeOut,
      );
    } else {
      _goLogin();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [AppColors.skyTop, AppColors.skyMid, AppColors.skyBottom],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: PageView(
                  controller: _controller,
                  onPageChanged: (i) {
                    _autoAdvance?.cancel();
                    setState(() => _page = i);
                  },
                  children: [
                    GestureDetector(
                      behavior: HitTestBehavior.translucent,
                      onTap: _next,
                      child: const _WelcomePage(),
                    ),
                    _MeetMayPage(onStart: _goLogin),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _Dot(active: _page == 0),
                    const SizedBox(width: 8),
                    _Dot(active: _page == 1),
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

class _Dot extends StatelessWidget {
  final bool active;
  const _Dot({required this.active});

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      width: active ? 28 : 4,
      height: 4,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(2),
        color: active
            ? AppColors.ink.withValues(alpha: 0.6)
            : AppColors.ink.withValues(alpha: 0.2),
      ),
    );
  }
}

class _WelcomePage extends StatefulWidget {
  const _WelcomePage();

  @override
  State<_WelcomePage> createState() => _WelcomePageState();
}

class _WelcomePageState extends State<_WelcomePage>
    with SingleTickerProviderStateMixin {
  late final AnimationController _breath = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 4000),
  )..repeat(reverse: true);

  late final Animation<double> _scale = Tween<double>(
    begin: 0.82,
    end: 1.08,
  ).animate(CurvedAnimation(parent: _breath, curve: Curves.easeInOut));

  @override
  void dispose() {
    _breath.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(30, 40, 30, 40),
      child: Column(
        children: [
          SizedBox(
            height: 240,
            child: Center(
              child: ScaleTransition(
                scale: _scale,
                child: const _BreathCircle(size: 190),
              ),
            ),
          ),
          const SizedBox(height: 40),
          const Text(
            'AN · THIỀN VÀ CHỮA LÀNH',
            style: TextStyle(
              fontFamily: 'BeVietnamPro',
              fontSize: 17,
              color: Color(0xFF2F5B72),
              letterSpacing: 2.4,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 28),
          Text(
            'Một khoảng nhỏ để bạn chậm lại, lắng nghe mình và tìm về sự bình an.',
            style: TextStyle(
              fontFamily: 'BeVietnamPro',
              fontWeight: FontWeight.w300,
              fontSize: 15,
              height: 26 / 15,
              color: AppColors.ink.withValues(alpha: 0.62),
            ),
            textAlign: TextAlign.center,
          ),
          const Spacer(),
          Text(
            'Tự động chuyển sau 3 giây · hoặc lướt sang',
            style: TextStyle(
              fontFamily: 'BeVietnamPro',
              fontWeight: FontWeight.w300,
              fontSize: 13.5,
              color: AppColors.ink.withValues(alpha: 0.5),
            ),
          ),
        ],
      ),
    );
  }
}

/// Soft, translucent "breathing" orb — no hard edges: a white radial glow that
/// fades to nothing, an outer bloom, and a bright diffuse core.
class _BreathCircle extends StatelessWidget {
  final double size;
  const _BreathCircle({required this.size});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: [
            Colors.white.withValues(alpha: 0.9),
            Colors.white.withValues(alpha: 0.45),
            Colors.white.withValues(alpha: 0.0),
          ],
          stops: const [0.0, 0.6, 1.0],
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.white.withValues(alpha: 0.55),
            blurRadius: 28,
            spreadRadius: 2,
          ),
          BoxShadow(
            color: const Color(0xFF2F5B72).withValues(alpha: 0.08),
            blurRadius: 40,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // outer ring
          Container(
            width: size * 0.82,
            height: size * 0.82,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.3),
                width: 1.5,
              ),
            ),
          ),
          // inner ring
          Container(
            width: size * 0.5,
            height: size * 0.5,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.5),
                width: 1.5,
              ),
            ),
          ),
          // bright diffuse core
          Container(
            width: size * 0.34,
            height: size * 0.34,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  Colors.white,
                  Colors.white.withValues(alpha: 0.0),
                ],
                stops: const [0.45, 1.0],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Slow ease-in-out "breathing" pulse — scales its child up ~20% and back,
/// forever.
class _Breathing extends StatefulWidget {
  final Widget child;
  const _Breathing({required this.child});

  @override
  State<_Breathing> createState() => _BreathingState();
}

class _BreathingState extends State<_Breathing>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 4200),
  )..repeat(reverse: true);

  late final Animation<double> _scale = Tween<double>(
    begin: 1.0,
    end: 1.2,
  ).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut));

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) =>
      ScaleTransition(scale: _scale, child: widget.child);
}

class _MeetMayPage extends StatelessWidget {
  final VoidCallback onStart;
  const _MeetMayPage({required this.onStart});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(30, 40, 30, 40),
      child: Column(
        children: [
          const SizedBox(height: 20),
          Transform.translate(
            offset: const Offset(-25, 0),
            child: const _Breathing(
              child: May(mood: Mood.binhYen, size: 150),
            ),
          ),
          const SizedBox(height: 44),
          const Text(
            'Mình là Mây.',
            style: TextStyle(
              fontFamily: 'Lora',
              fontSize: 30,
              height: 40 / 30,
              color: AppColors.ink,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Text(
            'Mây sẽ đồng hành cùng bạn, lắng nghe cảm xúc và giúp bạn tìm điều mình cần trong từng ngày.',
            style: TextStyle(
              fontFamily: 'BeVietnamPro',
              fontWeight: FontWeight.w300,
              fontSize: 15,
              height: 26 / 15,
              color: AppColors.ink.withValues(alpha: 0.62),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 26),
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.72),
              borderRadius: BorderRadius.circular(22),
              border: Border.all(color: Colors.white.withValues(alpha: 0.9)),
            ),
            child: Row(
              children: [
                SizedBox(
                  width: 44 + 30,
                  height: 44,
                  child: Stack(
                    children: const [
                      Positioned(left: 0, child: _GuideAvatar('assets/guides/tram.jpg')),
                      Positioned(left: 30, child: _GuideAvatar('assets/guides/justin.jpg')),
                    ],
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Text(
                    'Các bài thiền được hướng dẫn bởi người thật. Mây ở bên bạn phần cảm xúc.',
                    style: TextStyle(
                      fontFamily: 'BeVietnamPro',
                      fontWeight: FontWeight.w300,
                      fontSize: 13,
                      height: 21 / 13,
                      color: AppColors.ink.withValues(alpha: 0.7),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const Spacer(),
          AppButton(label: 'Bắt đầu cùng mình nhé!', onPressed: onStart),
        ],
      ),
    );
  }
}

/// A real guide's photo, cropped into a circle with a soft white rim.
class _GuideAvatar extends StatelessWidget {
  final String asset;
  const _GuideAvatar(this.asset);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: const Color(0xFFE4EDF3),
        border: Border.all(color: Colors.white, width: 2),
        boxShadow: [
          BoxShadow(
            color: AppColors.ink.withValues(alpha: 0.12),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ClipOval(
        child: Image.asset(asset, fit: BoxFit.cover),
      ),
    );
  }
}
