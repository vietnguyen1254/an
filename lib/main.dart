import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:just_audio_background/just_audio_background.dart';
import 'package:provider/provider.dart';

import 'firebase_options.dart';
import 'screens/checkin/mood_checkin_screen.dart';
import 'screens/main_tabs.dart';
import 'screens/onboarding/onboarding_screen.dart';
import 'services/auth_service.dart';
import 'services/notifications/notification_service.dart';
import 'state/app_state.dart';
import 'theme/colors.dart';
import 'widgets/app_lock_gate.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

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

  await NotificationService.instance.init();
  NotificationService.instance.onTap = _handleReminderTap;

  final appState = AppState();
  await appState.loadSession();

  runApp(AnApp(appState: appState));

  // Reconcile with Firebase/the backend in the background — the UI above
  // already rendered from local cache, so a slow or offline connection here
  // never delays the first frame.
  unawaited(appState.syncSessionInBackground());

  // If the app was cold-started from a reminder, act on it once the tree is up.
  final launch = await NotificationService.instance.launchPayload();
  if (launch != null) {
    WidgetsBinding.instance.addPostFrameCallback((_) => _handleReminderTap(launch));
  }
}

void _handleReminderTap(String payload) {
  final nav = navigatorKey.currentState;
  if (nav == null) return;
  final ctx = navigatorKey.currentContext;
  if (payload == 'checkin' && ctx != null) {
    ctx.read<AppState>().beginDraftEntry();
    nav.push(MaterialPageRoute(builder: (_) => const MoodCheckInScreen()));
  } else if (payload == 'meditate') {
    nav.pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const MainTabs(initialIndex: 1)),
      (r) => false,
    );
  }
}

class AnApp extends StatefulWidget {
  final AppState appState;
  const AnApp({super.key, required this.appState});

  @override
  State<AnApp> createState() => _AnAppState();
}

class _AnAppState extends State<AnApp> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // Coming back to the app is the moment to refresh the next week of
    // reminders against the latest history.
    if (state == AppLifecycleState.resumed) widget.appState.rescheduleReminders();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: widget.appState,
      child: MaterialApp(
        navigatorKey: navigatorKey,
        title: 'An — Thiền và chữa lành',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          useMaterial3: true,
          fontFamily: 'BeVietnamPro',
          scaffoldBackgroundColor: AppColors.appBg,
          colorScheme: ColorScheme.fromSeed(seedColor: AppColors.sage),
        ),
        // Biometric lock ("Khoá bằng Face ID") sits above every route.
        builder: (context, child) => AppLockGate(child: child ?? const SizedBox.shrink()),
        // A Consumer (not a plain field read) because the background session
        // sync can now finish after this first build — e.g. it may find the
        // cached login stale and sign the user out — and this needs to react
        // to that instead of being stuck on whatever isLoggedIn was at cold
        // start.
        home: Consumer<AppState>(
          builder: (context, state, _) => state.isLoggedIn ? const MainTabs() : const OnboardingScreen(),
        ),
      ),
    );
  }
}
