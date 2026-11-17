import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tam_customer/app/router/customer_navigation.dart';
import 'package:tam_customer/app/theme/app_theme.dart';
import 'package:tam_customer/features/notifications/data/mock/mock_notifications_repository.dart';
import 'package:tam_customer/features/notifications/data/unavailable_notifications_repository.dart';
import 'package:tam_customer/features/notifications/domain/notifications_repository.dart';
import 'package:tam_customer/features/notifications/presentation/bloc/notifications_cubit.dart';
import 'package:tam_customer/features/notifications/presentation/pages/notifications_page.dart';
import 'package:tam_customer/l10n/app_localizations.dart';
import 'package:tam_customer/shared/domain/trip.dart';

class _NavigationSpy implements CustomerNavigation {
  var homeCount = 0;
  var tripsCount = 0;
  final openedTrips = <String>[];
  @override
  void openCompletion(String tripId) {}
  @override
  void openSupport({String? tripId}) {}
  @override
  void openTerms() {}
  @override
  void openPrivacy() {}
  @override
  void openChat(String tripId) {}
  @override
  void openActiveTrip({String? id, bool replaceCurrent = false}) {}
  @override
  void openAccountPhone() {}
  @override
  void openAccountDeletion() {}
  @override
  void openDriverContact(String tripId, String driverId) {}
  @override
  void openHome() => homeCount++;
  @override
  void openTrips() => tripsCount++;
  @override
  void openTrip(String id) => openedTrips.add(id);
  @override
  void openNotifications() {}
  @override
  void openAddresses() {}
  @override
  void openSettings() {}
  @override
  void openRideRequest({TripPrefill? prefill}) {}
}

ThemeData _reviewTheme() {
  final base = AppTheme.light;
  return base.copyWith(
    appBarTheme: base.appBarTheme.copyWith(
      titleTextStyle: base.appBarTheme.titleTextStyle?.copyWith(
        fontFamily: 'NotificationsArabic',
        fontFamilyFallback: const ['NotificationsLatin'],
      ),
    ),
    textTheme: base.textTheme.apply(
      fontFamily: 'NotificationsArabic',
      fontFamilyFallback: const ['NotificationsLatin'],
    ),
  );
}

Future<NotificationsCubit> _pumpInbox(
  WidgetTester tester,
  NotificationsRepository repository,
  _NavigationSpy navigation, {
  String locale = 'ar',
  double scale = 1,
}) async {
  final cubit = NotificationsCubit(repository)..load();
  await tester.pumpWidget(
    BlocProvider.value(
      value: cubit,
      child: MaterialApp(
        theme: Platform.environment['TAM_NOTIFICATIONS_GOLDEN'] == '1'
            ? _reviewTheme()
            : AppTheme.light,
        locale: Locale(locale),
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: AppLocalizations.supportedLocales,
        builder: (context, child) {
          final media = MediaQuery.of(context);
          return MediaQuery(
            data: media.copyWith(textScaler: TextScaler.linear(scale)),
            child: child!,
          );
        },
        home: NotificationsPage(
          navigation: navigation,
          clock: () => DateTime(2026, 11, 7, 17),
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
  return cubit;
}

void main() {
  // Opt-in: system-font screenshots are host-specific and shouldn't gate CI.
  final goldenEnabled = Platform.environment['TAM_NOTIFICATIONS_GOLDEN'] == '1';
  // Screenshot rendering only: host Noto font prevents Flutter test's
  // Ahem placeholder squares; no font asset is checked into the repository.
  setUpAll(() async {
    if (!goldenEnabled) return;
    final file = File(
      '/usr/share/fonts/truetype/noto/NotoSansArabic-Regular.ttf',
    );
    if (!file.existsSync()) return;
    final latinFont = File(
      '/usr/share/fonts/truetype/noto/NotoSans-Regular.ttf',
    );
    final loader = FontLoader('NotificationsArabic');
    if (latinFont.existsSync()) {
      await (FontLoader(
        'NotificationsLatin',
      )..addFont(latinFont.readAsBytes().then(ByteData.sublistView))).load();
    }
    loader.addFont(file.readAsBytes().then(ByteData.sublistView));
    await loader.load();
    final icons = File(
      '/home/hazem/development/flutter/bin/cache/artifacts/material_fonts/MaterialIcons-Regular.otf',
    );
    if (icons.existsSync()) {
      final iconLoader = FontLoader('MaterialIcons')
        ..addFont(icons.readAsBytes().then(ByteData.sublistView));
      await iconLoader.load();
    }
  });

  testWidgets('trip target uses shared mock-history-001 and updates unread', (
    tester,
  ) async {
    final repository = MockNotificationsRepository();
    final navigation = _NavigationSpy();
    final cubit = await _pumpInbox(tester, repository, navigation);
    addTearDown(() async {
      await cubit.close();
      await repository.dispose();
    });
    expect(find.text('غير مقروء: 4'), findsOneWidget);
    await tester.tap(
      find.byKey(const Key('notification-notice-trip-complete-001')),
    );
    await tester.pumpAndSettle();
    expect(navigation.openedTrips, ['mock-history-001']);
    expect(await repository.getUnreadCount(), 3);
  });

  testWidgets('unknown and missing-trip targets do not navigate', (
    tester,
  ) async {
    final repository = MockNotificationsRepository();
    final navigation = _NavigationSpy();
    final cubit = await _pumpInbox(tester, repository, navigation);
    addTearDown(() async {
      await cubit.close();
      await repository.dispose();
    });
    for (final id in ['notice-unknown-001', 'notice-missing-trip-001']) {
      final finder = find.byKey(Key('notification-$id'));
      // The horizontal category bar adds a second Scrollable: scroll the feed.
      await tester.scrollUntilVisible(
        finder,
        180,
        scrollable: find.byType(Scrollable).first,
      );
      await Scrollable.ensureVisible(tester.element(finder), alignment: 0.25);
      await tester.pumpAndSettle();
      expect(finder.hitTestable(), findsOneWidget);
      await tester.tap(finder);
      await tester.pumpAndSettle();
      expect(navigation.openedTrips, isEmpty);
      expect(navigation.homeCount, 0);
      expect(navigation.tripsCount, 0);
    }
  });

  testWidgets('read-all updates UI and repeated tap cannot reduce count', (
    tester,
  ) async {
    final repository = MockNotificationsRepository();
    final cubit = await _pumpInbox(tester, repository, _NavigationSpy());
    addTearDown(() async {
      await cubit.close();
      await repository.dispose();
    });
    await tester.tap(find.byKey(const Key('notifications-mark-all')));
    await tester.pumpAndSettle();
    expect(await repository.getUnreadCount(), 0);
    expect(find.text('غير مقروء: 0'), findsOneWidget);
    expect(
      tester
          .widget<IconButton>(find.byKey(const Key('notifications-mark-all')))
          .onPressed,
      isNull,
    );
  });

  testWidgets(
    'unread filter is local, read-all clears it, and all restores the feed',
    (tester) async {
      final repository = MockNotificationsRepository();
      final cubit = await _pumpInbox(tester, repository, _NavigationSpy());
      addTearDown(() async {
        await cubit.close();
        await repository.dispose();
      });
      expect(find.text('غير مقروء: 4'), findsOneWidget);
      await tester.tap(find.byKey(const Key('notifications-filter-unread')));
      await tester.pumpAndSettle();
      expect(
        find.byKey(const Key('notification-notice-trip-complete-001')),
        findsOneWidget,
      );
      expect(
        find.byKey(const Key('notification-notice-account-001')),
        findsNothing,
      );
      await tester.tap(find.byKey(const Key('notifications-mark-all')));
      await tester.pumpAndSettle();
      expect(find.text('غير مقروء: 0'), findsOneWidget);
      expect(find.text('أنت على اطلاع بكل جديد'), findsOneWidget);
      await tester.tap(find.byKey(const Key('notifications-show-all')));
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('notifications-list')), findsOneWidget);
      expect(find.text('أنت على اطلاع بكل جديد'), findsNothing);
      expect(await repository.getUnreadCount(), 0);
    },
  );

  testWidgets('initial error and retry, and empty list are honest UI states', (
    tester,
  ) async {
    final repository = MockNotificationsRepository();
    repository.failOnce(MockNotificationsOperation.page);
    final navigation = _NavigationSpy();
    final cubit = await _pumpInbox(tester, repository, navigation);
    addTearDown(() async {
      await cubit.close();
      await repository.dispose();
    });
    expect(find.text('تعذر تحميل الإشعارات'), findsOneWidget);
    await tester.tap(find.text('إعادة المحاولة'));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('notifications-list')), findsOneWidget);

    final empty = MockNotificationsRepository(seed: []);
    final emptyCubit = await _pumpInbox(tester, empty, navigation);
    addTearDown(() async {
      await emptyCubit.close();
      await empty.dispose();
    });
    expect(find.text('لا توجد إشعارات بعد'), findsOneWidget);
  });

  testWidgets('API mode displays service unavailable, not mock cards', (
    tester,
  ) async {
    const unavailable = UnavailableNotificationsRepository();
    final cubit = await _pumpInbox(tester, unavailable, _NavigationSpy());
    addTearDown(cubit.close);
    expect(
      find.text('خدمة الإشعارات غير متاحة في وضع API حاليًا.'),
      findsOneWidget,
    );
    expect(find.byKey(const Key('notifications-list')), findsNothing);
  });

  testWidgets('failed refresh of an empty inbox is visible and retryable', (
    tester,
  ) async {
    final repository = MockNotificationsRepository(seed: []);
    final cubit = await _pumpInbox(tester, repository, _NavigationSpy());
    addTearDown(() async {
      await cubit.close();
      await repository.dispose();
    });
    repository.failOnce(MockNotificationsOperation.page);
    await tester.tap(find.text('تحديث'));
    await tester.pumpAndSettle();
    expect(find.text('تعذر تحميل الإشعارات'), findsOneWidget);
    await tester.tap(find.text('إعادة المحاولة'));
    await tester.pumpAndSettle();
    expect(find.text('لا توجد إشعارات بعد'), findsOneWidget);
    expect(find.text('تعذر تحميل الإشعارات'), findsNothing);
  });

  testWidgets('notification header and filter strip adapt to RTL', (
    tester,
  ) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(390, 844);
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final repository = MockNotificationsRepository();
    final navigation = _NavigationSpy();
    final cubit = await _pumpInbox(tester, repository, navigation);
    addTearDown(() async {
      await cubit.close();
      await repository.dispose();
    });

    expect(find.byIcon(Icons.arrow_forward_ios_rounded), findsOneWidget);
    final filterStrip = find.byKey(const Key('notifications-filter-list'));
    expect(filterStrip, findsOneWidget);
    final stripRect = tester.getRect(filterStrip);
    expect(stripRect.left, 0);
    expect(stripRect.right, 390);
    final firstFilter = find.byKey(const Key('notifications-filter-all'));
    final initialRight = tester.getRect(firstFilter).right;
    final scrollPosition = tester
        .state<ScrollableState>(
          find
              .descendant(of: filterStrip, matching: find.byType(Scrollable))
              .first,
        )
        .position;
    expect(stripRect.right - initialRight, closeTo(16, 0.1));
    // In RTL the start gutter is part of the scroll contents. Dragging far
    // enough towards later chips advances the scroll position; the first
    // chip may leave the viewport entirely, so don't query its geometry.
    await tester.drag(filterStrip, const Offset(180, 0));
    await tester.pumpAndSettle();
    expect(scrollPosition.pixels, greaterThan(20));

    await tester.tap(find.byKey(const Key('notifications-back')));
    await tester.pumpAndSettle();
    expect(navigation.homeCount, 1);
  });

  testWidgets('back chevron mirrors naturally for English', (tester) async {
    final repository = MockNotificationsRepository();
    final cubit = await _pumpInbox(
      tester,
      repository,
      _NavigationSpy(),
      locale: 'en',
    );
    addTearDown(() async {
      await cubit.close();
      await repository.dispose();
    });
    expect(find.byIcon(Icons.arrow_back_ios_new_rounded), findsOneWidget);
    // The same start-of-list gap follows LTR direction automatically.
    final stripRect = tester.getRect(
      find.byKey(const Key('notifications-filter-list')),
    );
    final firstFilterRect = tester.getRect(
      find.byKey(const Key('notifications-filter-all')),
    );
    expect(firstFilterRect.left - stripRect.left, closeTo(16, 0.1));
  });

  testWidgets('category tabs filter by kind without changing read state', (
    tester,
  ) async {
    final repository = MockNotificationsRepository();
    final cubit = await _pumpInbox(tester, repository, _NavigationSpy());
    addTearDown(() async {
      await cubit.close();
      await repository.dispose();
    });

    await tester.tap(find.byKey(const Key('notifications-filter-trips')));
    await tester.pumpAndSettle();
    expect(
      find.byKey(const Key('notification-notice-trip-complete-001')),
      findsOneWidget,
    );
    expect(
      find.byKey(const Key('notification-notice-offer-001')),
      findsNothing,
    );

    await tester.drag(
      find.byKey(const Key('notifications-filter-list')),
      const Offset(220, 0),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('notifications-filter-offers')));
    await tester.pumpAndSettle();
    expect(
      find.byKey(const Key('notification-notice-trip-complete-001')),
      findsNothing,
    );
    expect(
      find.byKey(const Key('notification-notice-offer-001')),
      findsOneWidget,
    );
    expect(await repository.getUnreadCount(), 4);
  });

  for (final caseItem in [
    ('ar', 390.0, 844.0, 1.0, 'notifications_ar_390.png'),
    ('en', 390.0, 844.0, 1.0, 'notifications_en_390.png'),
    ('ar', 800.0, 1080.0, 1.0, 'notifications_ar_tablet_800.png'),
    ('ar', 320.0, 780.0, 2.0, 'notifications_ar_320_large_text.png'),
  ]) {
    testWidgets('responsive inbox ${caseItem.$5}', (tester) async {
      tester.view.devicePixelRatio = 1.0;
      tester.view.physicalSize = Size(caseItem.$2, caseItem.$3);
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      final repository = MockNotificationsRepository();
      final cubit = await _pumpInbox(
        tester,
        repository,
        _NavigationSpy(),
        locale: caseItem.$1,
        scale: caseItem.$4,
      );
      addTearDown(() async {
        await cubit.close();
        await repository.dispose();
      });
      expect(tester.takeException(), isNull);
      if (goldenEnabled) {
        await expectLater(
          find.byType(Scaffold),
          matchesGoldenFile('goldens/${caseItem.$5}'),
        );
      }
    });
  }
}
