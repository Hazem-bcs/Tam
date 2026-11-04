import 'package:flutter_test/flutter_test.dart';
import 'package:tam_customer/app/app.dart';

void main() {
  testWidgets('Arabic app shell launches without backend', (tester) async {
    await tester.pumpWidget(const TamApp());
    await tester.pumpAndSettle();
    expect(find.text('تم'), findsOneWidget);
    expect(find.text('هيكل التطبيق جاهز'), findsOneWidget);
  });
}
