import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tam_customer/features/active_trip/presentation/widgets/active_driver_card.dart';
import 'package:tam_customer/features/chat/domain/chat_repository.dart';
import 'package:tam_customer/features/chat/presentation/bloc/chat_cubit.dart';
import 'package:tam_customer/features/chat/presentation/pages/chat_page.dart';
import 'package:tam_customer/features/completion/domain/completion_repository.dart';
import 'package:tam_customer/features/completion/presentation/bloc/completion_cubit.dart';
import 'package:tam_customer/features/completion/presentation/pages/completion_page.dart';
import 'package:tam_customer/features/completion/presentation/widgets/completion_rating_form.dart';
import 'package:tam_customer/features/support/presentation/widgets/support_editor_sections.dart';
import 'package:tam_customer/l10n/app_localizations.dart';
import '../../support/preview_fonts.dart';
import '../chat/chat_test_support.dart';
import 'completion_test_support.dart';

const _capture = bool.fromEnvironment('CF_TRIPS_UI');

Future<void> _pump(
  WidgetTester tester,
  Widget home, {
  required Size size,
  String locale = 'ar',
  double scale = 1,
}) async {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
  await tester.pumpWidget(
    RepaintBoundary(
      key: const Key('feedback-visual'),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: previewTheme(),
        locale: Locale(locale),
        supportedLocales: AppLocalizations.supportedLocales,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        builder: (context, child) => MediaQuery(
          data: MediaQuery.of(context).copyWith(
            textScaler: TextScaler.linear(scale),
            disableAnimations: true,
          ),
          child: child!,
        ),
        home: home,
      ),
    ),
  );
  await tester.pumpAndSettle();
}

Future<void> _save(WidgetTester tester, String name) async {
  expect(tester.takeException(), isNull);
  if (_capture) {
    await expectLater(
      find.byKey(const Key('feedback-visual')),
      matchesGoldenFile(
        '../../../../../docs/engineering/deliveries/CF-TRIPS/screenshots/$name.png',
      ),
    );
  }
}

void main() {
  setUpAll(() => loadPreviewFonts(enabled: true));
  for (final layout in [
    (
      name: 'completion-ar-390',
      size: const Size(390, 844),
      locale: 'ar',
      scale: 1.0,
    ),
    (
      name: 'completion-ar-320-x2',
      size: const Size(320, 740),
      locale: 'ar',
      scale: 2.0,
    ),
    (
      name: 'completion-en-800',
      size: const Size(800, 1000),
      locale: 'en',
      scale: 1.0,
    ),
  ]) {
    testWidgets(layout.name, (tester) async {
      final repo = ControlledCompletionRepository();
      addTearDown(repo.events.close);
      await _pump(
        tester,
        BlocProvider(
          create: (_) => CompletionCubit(repo, tripId: 'mock-history-001'),
          child: CompletionPage(onBack: () {}, onHome: () {}, onSupport: () {}),
        ),
        size: layout.size,
        locale: layout.locale,
        scale: layout.scale,
      );
      await _save(tester, layout.name);
      if (layout.scale == 1 && layout.locale == 'ar') {
        await tester.ensureVisible(find.byKey(const Key('completion-stars-4')));
        await tester.tap(find.byKey(const Key('completion-stars-4')));
        await tester.pumpAndSettle();
        await tester.ensureVisible(find.byKey(const Key('completion-submit')));
        await tester.pumpAndSettle();
        await _save(tester, 'completion-rating-ar-390');
      }
      await tester.pumpWidget(const SizedBox());
    });
  }
  testWidgets('inline rating support keeps a full-width Arabic label', (
    tester,
  ) async {
    await _pump(
      tester,
      Scaffold(
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: CompletionRatingForm(
              state: CompletionState(completion: completionSnapshot()),
              policy: const CompletionPolicy(),
              onSubmit: (_, _) {},
              onSupport: () {},
            ),
          ),
        ),
      ),
      size: const Size(390, 844),
    );
    await tester.tap(find.byKey(const Key('completion-stars-4')));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.byKey(const Key('trips-support')));
    await tester.pumpAndSettle();
    await _save(tester, 'inline-rating-support-ar-390');
    final submit = tester.getRect(find.byKey(const Key('completion-submit')));
    final support = tester.getRect(find.byKey(const Key('trips-support')));
    expect(support.top, greaterThanOrEqualTo(submit.bottom));
    await tester.pumpWidget(const SizedBox());
  });
  for (final locale in ['ar', 'en']) {
    testWidgets('contact $locale narrow phone', (tester) async {
      await _pump(
        tester,
        Scaffold(
          body: SafeArea(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    const ActiveDriverCard(driver: chatDriver),
                    ActiveDriverContactBar(onChat: () {}, onCall: () {}),
                  ],
                ),
              ),
            ),
          ),
        ),
        size: const Size(390, 600),
        locale: locale,
      );
      await _save(tester, 'contact-$locale-390');
      final chat = tester.getRect(find.byKey(const Key('active-chat')));
      final call = tester.getRect(find.byKey(const Key('active-call-driver')));
      expect(call.top, greaterThanOrEqualTo(chat.bottom));
      await tester.pumpWidget(const SizedBox());
    });
  }
  testWidgets('support counter and hero at 320 x2', (tester) async {
    final controller = TextEditingController(text: 'شرح المشكلة');
    addTearDown(controller.dispose);
    await _pump(
      tester,
      Scaffold(
        body: SafeArea(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  const SupportEditorHero(
                    title: 'كيف يمكننا مساعدتك؟',
                    subtitle: 'اكتب تفاصيل المشكلة',
                  ),
                  SupportEditorDetailsField(
                    controller: controller,
                    hint: 'تفاصيل المشكلة',
                    enabled: true,
                    length: 11,
                    maxLength: 2000,
                    onChanged: (_) {},
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      size: const Size(320, 740),
      scale: 2,
    );
    await tester.ensureVisible(find.text('11 / 2000'));
    await _save(tester, 'support-ar-320-x2');
    await tester.pumpWidget(const SizedBox());
  });
  testWidgets('chat tiny landscape keyboard and large text', (tester) async {
    final repo = ControlledChatRepository();
    addTearDown(repo.events.close);
    addTearDown(tester.view.resetViewInsets);
    await _pump(
      tester,
      BlocProvider(
        create: (_) => ChatCubit(
          repo,
          tripId: 'trip-1',
          policy: const ChatPolicy(),
          now: () => chatNow,
        ),
        child: ChatPage(onBack: () {}),
      ),
      size: const Size(740, 320),
      locale: 'en',
      scale: 2,
    );
    await tester.enterText(
      find.byKey(const Key('chat-input')),
      'Message draft',
    );
    tester.view.viewInsets = const FakeViewPadding(bottom: 200);
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.byKey(const Key('chat-send')));
    await tester.pumpAndSettle();
    await _save(tester, 'chat-en-landscape-keyboard-x2');
    await tester.pumpWidget(const SizedBox());
  });
}
