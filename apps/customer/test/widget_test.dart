import 'package:flutter_test/flutter_test.dart';
import 'package:tam_customer/app/app.dart';
import 'package:tam_customer/features/auth/data/memory_auth_session_store.dart';

import 'support/fake_auth_repository.dart';

void main() {
  testWidgets('Arabic app shell launches without backend', (tester) async {
    await tester.pumpWidget(
      TamApp(
        authRepository: FakeAuthRepository(latency: Duration.zero),
        sessionStore: MemoryAuthSessionStore(),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('تم'), findsOneWidget);
    await tester.ensureVisible(find.text('المتابعة كضيف'));
    await tester.tap(find.text('المتابعة كضيف'));
    await tester.pumpAndSettle();
    expect(find.text('رحلتك تبدأ مع تم'), findsOneWidget);
    expect(find.text('خدمة الرحلات غير متاحة حاليًا'), findsOneWidget);
  });
}
