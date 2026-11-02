import 'package:flutter_test/flutter_test.dart';
import 'package:mashwar_customer/app/app.dart';

void main() {
  testWidgets('Arabic app shell launches without backend', (tester) async {
    await tester.pumpWidget(const MashwarApp());
    await tester.pumpAndSettle();
    expect(find.text('مشوار'), findsOneWidget);
    expect(find.text('هيكل التطبيق جاهز'), findsOneWidget);
  });
}
