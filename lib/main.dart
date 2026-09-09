import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:just_audio_background/just_audio_background.dart';
import 'package:provider/provider.dart';

import 'firebase_options.dart';
import 'screens/onboarding/onboarding_screen.dart';
import 'services/auth_service.dart';
import 'state/app_state.dart';
import 'theme/colors.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Firebase backs all three SSO providers. It only initialises once the
  // native config files are in place (GoogleService-Info.plist /
  // google-services.json) — until then the app still runs and the login
  // screen shows a "not configured" message. See AUTH_SETUP.md.
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    AuthService.available = true;
  } catch (e) {
    debugPrint('Firebase not configured yet: $e');
  }

  // Must run before any AudioPlayer is created — wires up lock-screen /
  // notification playback controls for meditation & breathing sessions.
  await JustAudioBackground.init(
    androidNotificationChannelId: 'com.an.an.audio',
    androidNotificationChannelName: 'An — Thiền và thở',
    androidNotificationOngoing: true,
  );

  final appState = AppState();
  await appState.loadSession();

  runApp(AnApp(appState: appState));
}

class AnApp extends StatelessWidget {
  final AppState appState;
  const AnApp({super.key, required this.appState});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: appState,
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
