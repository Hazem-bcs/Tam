import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tam_customer/app/router/app_routes.dart';
import 'package:tam_customer/features/auth/presentation/bloc/auth_cubit.dart';
import 'package:tam_customer/features/notifications/presentation/pages/notifications_page.dart';
import 'package:tam_customer/features/settings/presentation/bloc/settings_cubit.dart';
import 'package:tam_customer/features/settings/presentation/pages/settings_page.dart';
import 'package:tam_customer/features/trips/presentation/bloc/trip_details_cubit.dart';
import 'package:tam_customer/features/trips/presentation/pages/trip_details_page.dart';

import 'support/customer_app_harness.dart';

void main() {
  for (final nextPhone in ['0941234567', '0951234567', null]) {
    testWidgets('Home logout resets account data before entry $nextPhone', (
      tester,
    ) async {
      await launchCustomerApp(tester);
      await enterCustomerSession(tester);
      final router = customerRouter(tester);
      final auth = customerAuth(tester);
      expect(find.byTooltip('الإشعارات، غير المقروء: 4'), findsOneWidget);

      router.push(AppRoutes.settings);
      await tester.pumpAndSettle();
      final settings = tester
          .element(find.byType(SettingsPage))
          .read<SettingsCubit>();
      settings.nameChanged('First Account');
      await settings.saveName();
      settings.notificationsChanged(false);
      await settings.savePreferences();
      await showCustomerHome(tester, router);

      await tester.tap(find.byKey(const Key('home-notifications')));
      await tester.pumpAndSettle();
      expect(find.byType(NotificationsPage), findsOneWidget);
      await tester.tap(find.byKey(const Key('notifications-mark-all')));
      await tester.pumpAndSettle();
      router.pop();
      await tester.pumpAndSettle();
      expect(find.byTooltip('الإشعارات، غير المقروء: 0'), findsOneWidget);

      await dismissCustomerMessages(tester);
      await tester.ensureVisible(find.text('تسجيل الخروج'));
      await tester.tap(find.text('تسجيل الخروج'));
      await tester.pumpAndSettle();
      expect(auth.state.status, AuthStatus.signedOut);
      await enterCustomerSession(tester, phone: nextPhone);
      expect(
        auth.state.status,
        nextPhone == null ? AuthStatus.guest : AuthStatus.localAccess,
      );
      expect(auth.state.user, isNull);
      expect(find.byTooltip('الإشعارات، غير المقروء: 4'), findsOneWidget);
      router.push(AppRoutes.settings);
      await tester.pumpAndSettle();
      final nextSettings = tester
          .element(find.byType(SettingsPage))
          .read<SettingsCubit>();
      expect(nextSettings.state.profile!.displayName, 'مستخدم تم');
      expect(nextSettings.state.preferences!.accountNotificationsEnabled, true);
      await tester.pumpWidget(const SizedBox.shrink());
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets('notification opens shared trip and updates Home badge', (
    tester,
  ) async {
    await launchCustomerApp(tester);
    await enterCustomerSession(tester);
    final router = customerRouter(tester);
    final auth = customerAuth(tester);
    await tester.tap(find.byKey(const Key('home-notifications')));
    await tester.pumpAndSettle();
    await tester.tap(
      find.byKey(const Key('notification-notice-trip-complete-001')),
    );
    await tester.pumpAndSettle();
    final trip = tester
        .element(find.byType(TripDetailsPage))
        .read<TripDetailsCubit>()
        .state
        .trip;
    expect(trip!.id, 'mock-history-001');
    expect(auth.state.status, AuthStatus.localAccess);
    await showCustomerHome(tester, router);
    expect(find.byTooltip('الإشعارات، غير المقروء: 3'), findsOneWidget);
    await tester.pumpWidget(const SizedBox.shrink());
    expect(tester.takeException(), isNull);
  });
}
