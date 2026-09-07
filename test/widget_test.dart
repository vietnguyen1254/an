import 'package:flutter_test/flutter_test.dart';

import 'package:an/main.dart';

void main() {
  testWidgets('App boots to onboarding welcome screen', (WidgetTester tester) async {
    await tester.pumpWidget(const AnApp());
    await tester.pump();

    expect(find.text('Chào mừng bạn\nđến với An'), findsOneWidget);
  });
}
