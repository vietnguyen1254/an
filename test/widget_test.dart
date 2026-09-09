import 'package:flutter_test/flutter_test.dart';

import 'package:an/main.dart';
import 'package:an/state/app_state.dart';

void main() {
  testWidgets('App boots to onboarding welcome screen', (WidgetTester tester) async {
    await tester.pumpWidget(AnApp(appState: AppState()));
    await tester.pump();

    expect(find.text('AN · THIỀN VÀ CHỮA LÀNH'), findsOneWidget);
  });
}
