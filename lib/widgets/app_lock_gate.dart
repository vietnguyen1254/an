import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/mood.dart';
import '../services/app_lock.dart';
import '../state/app_state.dart';
import '../theme/colors.dart';
import 'app_button.dart';
import 'may.dart';

/// Wraps the signed-in app. When "Khoá bằng Face ID" is on, an opaque cover
/// sits over [child] until the user passes a biometric / passcode check —
/// on cold start and every time the app comes back from the background.
class AppLockGate extends StatefulWidget {
  final Widget child;
  const AppLockGate({super.key, required this.child});

  @override
  State<AppLockGate> createState() => _AppLockGateState();
}

class _AppLockGateState extends State<AppLockGate> with WidgetsBindingObserver {
  bool _locked = false;
  bool _authenticating = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    if (context.read<AppState>().appLockEnabled) {
      _locked = true;
      WidgetsBinding.instance.addPostFrameCallback((_) => _tryUnlock());
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (!mounted) return;
    // Only a real trip to the background re-locks — `inactive` alone fires
    // for the Face ID sheet itself and for Control Center, which shouldn't
    // count.
    if (state == AppLifecycleState.paused && !_authenticating) {
      if (context.read<AppState>().appLockEnabled) setState(() => _locked = true);
    } else if (state == AppLifecycleState.resumed && _locked) {
      _tryUnlock();
    }
  }

  Future<void> _tryUnlock() async {
    if (_authenticating) return;
    if (!context.read<AppState>().appLockEnabled) {
      setState(() => _locked = false);
      return;
    }
    _authenticating = true;
    final ok = await AppLock.instance.authenticate('Mở khoá An');
    _authenticating = false;
    if (!mounted) return;
    if (ok) setState(() => _locked = false);
  }

  @override
  Widget build(BuildContext context) {
    final enabled = context.watch<AppState>().appLockEnabled;
    final show = enabled && _locked;
    return Stack(
      children: [
        widget.child,
        if (show)
          Positioned.fill(
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [AppColors.loginTop, AppColors.loginMid, AppColors.loginBottom],
                ),
              ),
              child: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(30, 40, 30, 28),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const May(mood: Mood.binhThuong, size: 120),
                      const SizedBox(height: 28),
                      const Text(
                        'An đang khoá',
                        style: TextStyle(fontFamily: 'Lora', fontSize: 24, color: AppColors.ink),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        'Nhật ký cảm xúc của bạn chỉ mở được bằng Face ID hoặc mật mã máy.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontFamily: 'BeVietnamPro',
                          fontWeight: FontWeight.w300,
                          fontSize: 14,
                          height: 22 / 14,
                          color: AppColors.ink.withValues(alpha: 0.6),
                        ),
                      ),
                      const SizedBox(height: 28),
                      AppButton(label: 'Mở khoá', onPressed: _tryUnlock),
                    ],
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}
