import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'screens/onboarding/onboarding_screen.dart';
import 'state/app_state.dart';
import 'theme/colors.dart';

void main() {
  runApp(const AnApp());
}

class AnApp extends StatelessWidget {
  const AnApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => AppState(),
      child: MaterialApp(
        title: 'An — Thiền và chữa lành',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          useMaterial3: true,
          fontFamily: 'BeVietnamPro',
          scaffoldBackgroundColor: AppColors.appBg,
          colorScheme: ColorScheme.fromSeed(seedColor: AppColors.sage),
        ),
        home: const OnboardingScreen(),
      ),
    );
  }
}
