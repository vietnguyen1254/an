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

  void _goLogin() {
    Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => const LoginScreen()));
  }

  void _next() {
    if (_page == 0) {
      _controller.animateToPage(1, duration: const Duration(milliseconds: 350), curve: Curves.easeOut);
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
                  onPageChanged: (i) => setState(() => _page = i),
                  children: [
                    GestureDetector(behavior: HitTestBehavior.translucent, onTap: _next, child: const _WelcomePage()),
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
        color: active ? AppColors.ink.withValues(alpha: 0.6) : AppColors.ink.withValues(alpha: 0.2),
      ),
    );
  }
}

class _WelcomePage extends StatelessWidget {
  const _WelcomePage();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(30, 40, 30, 40),
      child: Column(
        children: [
          SizedBox(
            height: 190,
            child: Center(
              child: Container(
                width: 150,
                height: 150,
                alignment: Alignment.center,
                decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.white.withValues(alpha: 0.35)),
                child: Stack(alignment: Alignment.center, children: [
                  Container(
                    width: 96,
                    height: 96,
                    decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: const Color(0x472F5B72))),
                  ),
                  Container(width: 52, height: 52, decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.white.withValues(alpha: 0.92))),
                ]),
              ),
            ),
          ),
          const Text(
            'AN · THIỀN VÀ CHỮA LÀNH',
            style: TextStyle(fontFamily: 'BeVietnamPro', fontSize: 14, color: Color(0xFF2F5B72), letterSpacing: 2),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 18),
          const Text(
            'Chào mừng bạn\nđến với An',
            style: TextStyle(fontFamily: 'Lora', fontSize: 30, height: 40 / 30, color: AppColors.ink),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Text(
            'Một khoảng nhỏ để bạn chậm lại, lắng nghe mình và tìm về sự bình an.',
            style: TextStyle(fontFamily: 'BeVietnamPro', fontWeight: FontWeight.w300, fontSize: 15, height: 26 / 15, color: AppColors.ink.withValues(alpha: 0.62)),
            textAlign: TextAlign.center,
          ),
          const Spacer(),
          Text(
            'Lướt sang để tiếp tục',
            style: TextStyle(fontFamily: 'BeVietnamPro', fontWeight: FontWeight.w300, fontSize: 13.5, color: AppColors.ink.withValues(alpha: 0.5)),
          ),
        ],
      ),
    );
  }
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
          const May(mood: Mood.binhYen, size: 150),
          const SizedBox(height: 18),
          const Text('Mình là Mây.', style: TextStyle(fontFamily: 'Lora', fontSize: 30, height: 40 / 30, color: AppColors.ink), textAlign: TextAlign.center),
          const SizedBox(height: 16),
          Text(
            'Mây sẽ đồng hành cùng bạn, lắng nghe cảm xúc và giúp bạn tìm điều mình cần trong từng ngày.',
            style: TextStyle(fontFamily: 'BeVietnamPro', fontWeight: FontWeight.w300, fontSize: 15, height: 26 / 15, color: AppColors.ink.withValues(alpha: 0.62)),
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
            child: Row(children: [
              Container(width: 44, height: 44, decoration: BoxDecoration(shape: BoxShape.circle, color: const Color(0xFFE4EDF3))),
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  'Các bài thiền trong An do người thật dẫn. Mây ở bên bạn phần cảm xúc.',
                  style: TextStyle(fontFamily: 'BeVietnamPro', fontWeight: FontWeight.w300, fontSize: 13, height: 21 / 13, color: AppColors.ink.withValues(alpha: 0.7)),
                ),
              ),
            ]),
          ),
          const Spacer(),
          AppButton(label: 'Bắt đầu cùng mình nhé!', onPressed: onStart),
        ],
      ),
    );
  }
}
