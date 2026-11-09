import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tam_customer/app/app.dart';
import 'package:tam_customer/app/router/app_routes.dart';
import 'package:tam_customer/core/config/feature_data_mode.dart';
import 'package:tam_customer/features/account_management/presentation/pages/account_management_page.dart';
import 'package:tam_customer/features/auth/data/memory_auth_session_store.dart';
import 'package:tam_customer/features/auth/presentation/bloc/auth_cubit.dart';
import 'package:tam_customer/features/driver_contact/domain/driver_contact_repository.dart';
import 'package:tam_customer/features/driver_contact/presentation/bloc/driver_contact_cubit.dart';
import 'package:tam_customer/features/driver_contact/presentation/pages/driver_contact_page.dart';

import '../support/fake_auth_repository.dart';
import 'support/customer_app_harness.dart';

Future<void> reveal(WidgetTester tester, String key) async {
  final target = find.byKey(Key(key));
  await tester.scrollUntilVisible(
    target,
    160,
    scrollable: find.byType(Scrollable).first,
  );
  await tester.ensureVisible(target);
  await tester.pumpAndSettle();
}

void main() {
  for (final delete in [false, true]) {
    testWidgets(
      'Settings ${delete ? 'deletion' : 'phone change'} completes and ends local session without backend user',
      (tester) async {
        await launchCustomerApp(tester);
        await enterCustomerSession(tester);
        final router = customerRouter(tester), auth = customerAuth(tester);
        router.push(AppRoutes.settings);
        await tester.pumpAndSettle();
        final key = delete
            ? 'settings-delete-account'
            : 'settings-change-phone';
        await reveal(tester, key);
        await tester.tap(find.byKey(Key(key)));
        await tester.pumpAndSettle();
        expect(find.byType(AccountManagementPage), findsOneWidget);
        if (delete) {
          await reveal(tester, 'account-consent');
          await tester.tap(find.byKey(const Key('account-consent')));
          await tester.pumpAndSettle();
        } else {
          await tester.enterText(
            find.byKey(const Key('account-phone')),
            '0951234567',
          );
        }
        await reveal(tester, 'account-start');
        await tester.tap(find.byKey(const Key('account-start')));
        await tester.pumpAndSettle();
        await tester.enterText(find.byKey(const Key('account-code')), '123456');
        await reveal(tester, 'account-confirm');
        await tester.tap(find.byKey(const Key('account-confirm')));
        await tester.pumpAndSettle();
        expect(auth.state.status, AuthStatus.signedOut);
        expect(auth.state.user, isNull);
        expect(find.byKey(const Key('auth-phone')), findsOneWidget);
        await enterCustomerSession(tester, phone: '0951234567');
        expect(auth.state.status, AuthStatus.localAccess);
        expect(auth.state.localPhoneE164, '+963951234567');
        expect(auth.state.user, isNull);
        await tester.pumpWidget(const SizedBox());
      },
    );
  }
  testWidgets('contact from assigned trip simulates without dialing fixture', (
    tester,
  ) async {
    var now = DateTime.now().toUtc();
    await launchCustomerApp(tester, clock: () => now);
    await enterCustomerSession(tester);
    final router = customerRouter(tester);
    router.push(AppRoutes.rideRequest);
    await tester.pumpAndSettle();
    for (final place in [
      ('حدد مكان الانطلاق', 'المزة، شارع الجلاء'),
      ('إلى أين تريد الذهاب؟', 'أبو رمانة، شارع الحمراء'),
    ]) {
      await tester.tap(find.text(place.$1));
      await tester.pumpAndSettle();
      await tester.tap(find.text(place.$2).last);
      await tester.pumpAndSettle();
    }
    await tester.tap(find.text('تأكيد طلب الرحلة'));
    await tester.pumpAndSettle();
    now = now.add(const Duration(seconds: 17));
    await tester.pump(const Duration(seconds: 17));
    await tester.pumpAndSettle();
    await reveal(tester, 'active-call-driver');
    await tester.tap(find.byKey(const Key('active-call-driver')));
    await tester.pumpAndSettle();
    expect(find.byType(DriverContactPage), findsOneWidget);
    await tester.tap(find.byKey(const Key('driver-contact-call')));
    await tester.pumpAndSettle();
    expect(
      tester
          .element(find.byType(DriverContactPage))
          .read<DriverContactCubit>()
          .state
          .result,
      DialerResult.simulated,
    );
    await tester.pumpWidget(const SizedBox());
  });
  testWidgets('API guards reject account and contact for guest/localAccess', (
    tester,
  ) async {
    for (final phone in [null, '0941234567']) {
      await tester.pumpWidget(
        TamApp(
          authRepository: FakeAuthRepository(latency: Duration.zero),
          sessionStore: MemoryAuthSessionStore(),
          temporaryPhoneEntryEnabled: true,
          dataModes: const FeatureDataModes(
            overrides: {
              CustomerFeature.accountManagement: FeatureDataMode.api,
              CustomerFeature.driverContact: FeatureDataMode.api,
            },
          ),
        ),
      );
      await tester.pumpAndSettle();
      await enterCustomerSession(tester, phone: phone);
      final router = customerRouter(tester);
      for (final path in [
        AppRoutes.changePhone,
        AppRoutes.deleteAccount,
        AppRoutes.driverContactLocation('trip', 'driver'),
      ]) {
        router.push(path);
        await tester.pumpAndSettle();
        expect(find.byType(AccountManagementPage), findsNothing);
        expect(find.byType(DriverContactPage), findsNothing);
      }
      await tester.pumpWidget(const SizedBox());
    }
  });
}
