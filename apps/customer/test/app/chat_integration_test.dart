import '../support/fake_auth_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tam_customer/app/app.dart';
import 'package:tam_customer/app/router/app_routes.dart';
import 'package:tam_customer/core/config/feature_data_mode.dart';
import 'package:tam_customer/features/active_trip/presentation/bloc/active_trip_cubit.dart';
import 'package:tam_customer/features/active_trip/presentation/pages/active_trip_page.dart';
import 'package:tam_customer/features/auth/data/memory_auth_session_store.dart';
import 'package:tam_customer/features/chat/presentation/bloc/chat_cubit.dart';
import 'package:tam_customer/features/chat/presentation/pages/chat_page.dart';

import 'package:tam_customer/features/home/presentation/pages/home_page.dart';
import 'support/customer_app_harness.dart';

void main() {
  testWidgets('driver chat survives navigation and clears on session exit', (
    tester,
  ) async {
    var now = DateTime.now().toUtc();
    await launchCustomerApp(tester, clock: () => now);
    await enterCustomerSession(tester);
    final router = customerRouter(tester);
    router.push(AppRoutes.rideRequest);
    await tester.pumpAndSettle();
    for (final item in [
      ('حدد مكان الانطلاق', 'المزة، شارع الجلاء'),
      ('إلى أين تريد الذهاب؟', 'أبو رمانة، شارع الحمراء'),
    ]) {
      await tester.tap(find.text(item.$1));
      await tester.pumpAndSettle();
      await tester.tap(find.text(item.$2).last);
      await tester.pumpAndSettle();
    }
    await tester.tap(find.text('تأكيد طلب الرحلة'));
    await tester.pumpAndSettle();
    final tracking = tester
        .element(find.byType(ActiveTripPage))
        .read<ActiveTripCubit>();
    final id = tracking.state.trip!.id;
    expect(find.byKey(const Key('active-chat')), findsNothing);
    now = now.add(const Duration(seconds: 18));
    await tester.pump(const Duration(seconds: 18));
    await tester.pumpAndSettle();
    final openChat = find.byKey(const Key('active-chat'));
    await tester.scrollUntilVisible(
      openChat,
      180,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.ensureVisible(openChat);
    await tester.pumpAndSettle();
    await tester.tap(openChat);
    await tester.pumpAndSettle();
    expect(find.byType(ChatPage), findsOneWidget);
    const body = 'أنا عند المدخل الرئيسي الآن';
    await tester.enterText(find.byKey(const Key('chat-input')), body);
    await tester.pump();
    await tester.tap(find.byKey(const Key('chat-send')));
    await tester.pumpAndSettle();
    expect(find.text(body), findsOneWidget);
    await showCustomerHome(tester, router);
    now = now.add(const Duration(seconds: 6));
    await tester.pump(const Duration(seconds: 6));
    router.push(AppRoutes.chatLocation(id));
    await tester.pumpAndSettle();
    expect(find.text(body), findsOneWidget);
    final reopened = tester.element(find.byType(ChatPage)).read<ChatCubit>();
    expect(reopened.state.messages.where((m) => m.body == body), hasLength(1));
    await showCustomerHome(tester, router);
    router.push(AppRoutes.tripLocation(id));
    await tester.pumpAndSettle();
    await tester.tap(find.text('إلغاء الرحلة'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('تأكيد الإلغاء'));
    await tester.pumpAndSettle();
    await showCustomerHome(tester, router);
    router.push(AppRoutes.chatLocation(id));
    await tester.pumpAndSettle();
    final closed = tester.element(find.byType(ChatPage)).read<ChatCubit>();
    expect(closed.state.canSend, isFalse);
    expect(closed.state.messages.where((m) => m.body == body), hasLength(1));
    await showCustomerHome(tester, router);
    await customerAuth(tester).logout();
    await tester.pumpAndSettle();
    await enterCustomerSession(tester, phone: null);
    router.go(AppRoutes.chatLocation(id));
    await tester.pumpAndSettle();
    expect(find.byType(ChatPage), findsOneWidget);
    expect(find.text(body), findsNothing);
    expect(
      tester.element(find.byType(ChatPage)).read<ChatCubit>().state.canSend,
      isFalse,
    );
    await tester.pumpWidget(const SizedBox.shrink());
    expect(tester.takeException(), isNull);
  });
  testWidgets(
    'authenticated API chat exposes unavailable transport without mocks',
    (tester) async {
      final repository = FakeAuthRepository(latency: Duration.zero);
      final challenge = await repository.requestOtp(phoneE164: '+963941234567');
      final verified = await repository.verifyOtp(
        challengeId: challenge.id,
        code: repository.debugOtpCode!,
      );
      final store = MemoryAuthSessionStore();
      await store.write(verified.session);
      await tester.pumpWidget(
        TamApp(
          authRepository: repository,
          sessionStore: store,
          dataModes: const FeatureDataModes(
            overrides: {CustomerFeature.chat: FeatureDataMode.api},
          ),
        ),
      );
      await tester.pumpAndSettle();
      customerRouter(tester).go(AppRoutes.chatLocation('mock-trip-1'));
      await tester.pumpAndSettle();
      final state = tester
          .element(find.byType(ChatPage))
          .read<ChatCubit>()
          .state;
      expect(state.failure, 'SERVICE_UNAVAILABLE');
      expect(state.messages, isEmpty);
      expect(state.canSend, isFalse);
      await tester.pumpWidget(const SizedBox.shrink());
      expect(tester.takeException(), isNull);
    },
  );
  for (final guest in [true, false]) {
    testWidgets('API chat blocks ${guest ? 'guest' : 'localAccess'}', (
      tester,
    ) async {
      await tester.pumpWidget(
        TamApp(
          authRepository: FakeAuthRepository(latency: Duration.zero),
          sessionStore: MemoryAuthSessionStore(),
          temporaryPhoneEntryEnabled: true,
          dataModes: const FeatureDataModes(
            overrides: {CustomerFeature.chat: FeatureDataMode.api},
          ),
        ),
      );
      await tester.pumpAndSettle();
      await enterCustomerSession(tester, phone: guest ? null : '0941234567');
      final router = customerRouter(tester);
      router.go(AppRoutes.chatLocation('mock-trip-1'));
      await tester.pumpAndSettle();
      expect(find.byType(ChatPage), findsNothing);
      expect(find.byType(HomePage), findsOneWidget);
      await tester.pumpWidget(const SizedBox.shrink());
      expect(tester.takeException(), isNull);
    });
  }
}
