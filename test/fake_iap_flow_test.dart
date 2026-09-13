import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:an/screens/premium/paywall_screen.dart';
import 'package:an/screens/premium/payment_success_screen.dart';
import 'package:an/state/app_state.dart';

/// Exercises the fake-purchase fallback in IapService (see the TODO there):
/// with no real store products configured, buying and restoring must still
/// take the user all the way through the Premium flow with no crash and no
/// real payment attempted.
void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('Nâng cấp Premium completes via the fake-purchase fallback', (tester) async {
    // Default test surface is smaller than a real phone — this screen's
    // fixed-height layout overflows at that size, which can make taps land
    // on the wrong widget. Use a realistic phone-sized surface instead.
    tester.view.physicalSize = const Size(1170, 2532);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final appState = AppState();
    await tester.pumpWidget(
      ChangeNotifierProvider.value(
        value: appState,
        child: const MaterialApp(home: PaywallScreen()),
      ),
    );
    await tester.pumpAndSettle();

    // No real store on the test platform → fake mode, banner shown.
    expect(find.textContaining('CHẾ ĐỘ THỬ NGHIỆM'), findsOneWidget);

    // The plan-card price Text can overflow horizontally in the test
    // environment (no real fonts loaded → different metrics than on
    // device) — harmless here, but it does mean the button can end up
    // below the fold, so scroll it into view before tapping.
    await tester.ensureVisible(find.text('Nâng cấp Premium'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Nâng cấp Premium'));
    await tester.pump(); // start the fake buy (700ms delay)
    await tester.pump(const Duration(milliseconds: 800)); // fake buy resolves, navigates
    await tester.pump(const Duration(milliseconds: 400)); // page transition
    // Not pumpAndSettle from here — PaymentSuccessScreen shows May, whose
    // sway/float/sparkle AnimationControllers use .repeat() and never go
    // idle, so pumpAndSettle would hang forever waiting for them to finish.

    expect(find.byType(PaymentSuccessScreen), findsOneWidget);
    expect(appState.plan, PlanTier.yearly);
    expect(appState.planRenewsAt, isNotNull);
  });
}
