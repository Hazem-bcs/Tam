import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tam_customer/app/app.dart';
import 'package:tam_customer/features/auth/data/memory_auth_session_store.dart';
import 'package:tam_customer/features/auth/presentation/bloc/auth_cubit.dart';
import 'package:tam_customer/features/home/presentation/pages/home_page.dart';

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
    final auth = tester.element(find.byType(HomePage)).read<AuthCubit>();
    expect(auth.state.status, AuthStatus.guest);
    expect(auth.state.user, isNull);
  });
}
