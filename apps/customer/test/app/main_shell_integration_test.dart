import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tam_customer/app/router/app_routes.dart';
import 'package:tam_customer/app/router/customer_navigation.dart';
import 'package:tam_customer/app/shell/main_navigation_bar.dart';
import 'package:tam_customer/app/shell/main_shell.dart';
import 'package:tam_customer/features/home/presentation/pages/home_page.dart';
import 'package:tam_customer/features/settings/presentation/bloc/settings_cubit.dart';
import 'package:tam_customer/features/settings/presentation/pages/settings_page.dart';
import 'package:tam_customer/features/trips/domain/trips_repository.dart';
import 'package:tam_customer/features/trips/presentation/bloc/trips_list_cubit.dart';
import 'package:tam_customer/features/trips/presentation/pages/trip_details_page.dart';
import 'package:tam_customer/features/trips/presentation/pages/trips_list_page.dart';

import 'support/customer_app_harness.dart';

Future<void> selectTab(WidgetTester tester, int index) async {
  await tester.tap(find.byKey(ValueKey('main-tab-$index')));
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('one shell retains tab state without pushing duplicate pages', (
    tester,
  ) async {
    await launchCustomerApp(tester);
    await enterCustomerSession(tester);
    final router = customerRouter(tester);
    final navigation = RouterCustomerNavigation(router);
    final shell = tester.element(find.byType(MainShell));
    final home = tester.element(find.byType(HomePage));
    expect(find.byType(SettingsPage), findsNothing);
    expect(find.byType(TripsListPage), findsNothing);
    final scroll = tester.state<ScrollableState>(
      find
          .descendant(
            of: find.byKey(const PageStorageKey('home-scroll')),
            matching: find.byType(Scrollable),
          )
          .first,
    );
    scroll.position.jumpTo(120);
    await tester.pump();
    final offset = scroll.position.pixels;

    navigation.openTrips();
    await tester.pumpAndSettle();
    final activity = tester.element(find.byType(TripsListPage));
    final cubit = activity.read<TripsListCubit>();
    await cubit.selectFilter(TripsFilter.completed);
    await tester.pumpAndSettle();
    expect(router.canPop(), isFalse);
    await selectTab(tester, 1);
    expect(
      identical(activity, tester.element(find.byType(TripsListPage))),
      isTrue,
    );

    navigation.openSettings();
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('تعديل الاسم'));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.byKey(const Key('settings-name-field')),
      'مسودة محفوظة',
    );
    await tester.pumpAndSettle();
    final account = tester.element(find.byType(SettingsPage));
    final settings = account.read<SettingsCubit>();
    expect(settings.state.hasUnsavedChanges, isTrue);
    await selectTab(tester, 0);
    expect(identical(shell, tester.element(find.byType(MainShell))), isTrue);
    expect(identical(home, tester.element(find.byType(HomePage))), isTrue);
    expect(scroll.position.pixels, offset);
    expect(find.byType(MainNavigationBar), findsOneWidget);
    expect(router.canPop(), isFalse);
    await selectTab(tester, 1);
    expect(
      identical(activity, tester.element(find.byType(TripsListPage))),
      isTrue,
    );
    expect(cubit.state.filter, TripsFilter.completed);
    await selectTab(tester, 2);
    expect(
      identical(account, tester.element(find.byType(SettingsPage))),
      isTrue,
    );
    expect(find.text('مسودة محفوظة'), findsOneWidget);
    expect(find.byType(AlertDialog), findsNothing);
    tester.testTextInput.hide();
    await tester.pumpAndSettle();
    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();
    expect(router.state.uri.path, AppRoutes.home);
    await selectTab(tester, 2);
    expect(settings.state.draftName, 'مسودة محفوظة');
    expect(find.byType(AlertDialog), findsNothing);
    await tester.pumpWidget(const SizedBox.shrink());
    expect(tester.takeException(), isNull);
  });

  testWidgets('details cover the shell and back restores the selected tab', (
    tester,
  ) async {
    await launchCustomerApp(tester);
    await enterCustomerSession(tester);
    final router = customerRouter(tester);
    await selectTab(tester, 1);
    final activity = tester.element(find.byType(TripsListPage));
    RouterCustomerNavigation(router).openTrip('mock-history-001');
    await tester.pumpAndSettle();
    expect(find.byType(TripDetailsPage), findsOneWidget);
    expect(find.byType(MainNavigationBar).hitTestable(), findsNothing);
    router.pop();
    await tester.pumpAndSettle();
    expect(router.state.uri.path, AppRoutes.trips);
    expect(
      identical(activity, tester.element(find.byType(TripsListPage))),
      isTrue,
    );
    expect(find.byType(MainNavigationBar), findsOneWidget);
    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();
    expect(router.state.uri.path, AppRoutes.home);
    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets(
    'ending a session disposes every retained branch and its drafts',
    (tester) async {
      await launchCustomerApp(tester);
      await enterCustomerSession(tester);
      final auth = customerAuth(tester);
      await selectTab(tester, 1);
      final trips = tester
          .element(find.byType(TripsListPage))
          .read<TripsListCubit>();
      await selectTab(tester, 2);
      final settings = tester
          .element(find.byType(SettingsPage))
          .read<SettingsCubit>();
      settings.nameChanged('Private draft');
      await auth.logout();
      await tester.pumpAndSettle();
      expect(find.byType(MainShell, skipOffstage: false), findsNothing);
      await tester.runAsync(() => Future<void>.delayed(Duration.zero));
      expect(settings.isClosed, isTrue);
      expect(trips.isClosed, isTrue);
      await enterCustomerSession(tester, phone: '0951234567');
      await selectTab(tester, 2);
      final next = tester
          .element(find.byType(SettingsPage))
          .read<SettingsCubit>();
      expect(next.state.draftName, isNot('Private draft'));
      expect(next.state.hasUnsavedChanges, isFalse);
      await tester.pumpWidget(const SizedBox.shrink());
      expect(tester.takeException(), isNull);
    },
  );
}
