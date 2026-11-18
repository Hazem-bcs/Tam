import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tam_customer/features/chat/data/mock/chat_mock_scenario.dart';
import 'package:tam_customer/features/chat/data/mock/mock_chat_repository.dart';
import 'package:tam_customer/features/chat/domain/chat_repository.dart';
import 'chat_test_support.dart';
import 'chat_widget_support.dart';

void main() {
  setUpAll(loadChatFonts);
  testWidgets('groups current messages under the local day', (tester) async {
    final repo = ControlledChatRepository();
    addTearDown(repo.events.close);
    await pumpChat(tester, repository: repo);
    expect(find.text('محادثة اليوم'), findsOneWidget);
  });
  testWidgets(
    'late send does not erase newer draft, and original text remains',
    (tester) async {
      final repo = ControlledChatRepository();
      addTearDown(repo.events.close);
      final result = Completer<ChatSent>();
      repo.onSend = (_, _) => result.future;
      final c = await pumpChat(tester, repository: repo, locale: 'en');
      await tester.enterText(
        find.byKey(const Key('chat-input')),
        'first draft',
      );
      await tester.pump();
      await tester.tap(find.byKey(const Key('chat-send')));
      await tester.pump();
      await tester.enterText(
        find.byKey(const Key('chat-input')),
        'newer draft',
      );
      result.complete(
        ChatSent(
          chatMetadata(revision: 3),
          ChatMessage(
            id: 'sent',
            sequence: 2,
            author: ChatAuthor.customer,
            body: 'first draft',
            sentAt: chatNow,
            clientMessageId: repo.sends.single,
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('newer draft'), findsOneWidget);
      expect(find.text('first draft'), findsOneWidget);
      expect(c.state.pending, isEmpty);
      await tester.pumpWidget(const SizedBox());
    },
  );
  testWidgets(
    'hidden route and background never acknowledge unseen latest messages',
    (tester) async {
      final repo = ControlledChatRepository();
      addTearDown(repo.events.close);
      final nav = GlobalKey<NavigatorState>();
      final c = await pumpChat(tester, repository: repo, navigator: nav);
      expect(repo.reads, [1]);
      nav.currentState!.push(
        MaterialPageRoute<void>(
          builder: (_) => const Scaffold(body: Text('other page')),
        ),
      );
      await tester.pumpAndSettle();
      repo.onFetch = (_) => Future.value(
        ChatMessagePage(
          metadata: chatMetadata(revision: 3, customerRead: 1),
          messages: [chatMessage(2)],
        ),
      );
      await c.refresh();
      await tester.pumpAndSettle();
      expect(repo.reads, [1]);
      nav.currentState!.pop();
      await tester.pumpAndSettle();
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.inactive);
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.hidden);
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.paused);
      repo.onFetch = (_) => Future.value(
        ChatMessagePage(
          metadata: chatMetadata(revision: 4, customerRead: 1),
          messages: [chatMessage(3)],
        ),
      );
      await c.refresh();
      expect(repo.reads, [1]);
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.hidden);
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.inactive);
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
      await tester.pumpAndSettle();
      expect(repo.reads.last, 3);
      await tester.pumpWidget(const SizedBox());
    },
  );
  testWidgets(
    'reading history keeps position and does not mark new messages until newest',
    (tester) async {
      final repo = ControlledChatRepository();
      addTearDown(repo.events.close);
      repo.onFetch = (_) => Future.value(
        ChatMessagePage(
          metadata: chatMetadata(),
          messages: List.generate(30, (i) => chatMessage(i + 1)),
          nextBeforeSequence: 1,
        ),
      );
      final c = await pumpChat(tester, repository: repo, locale: 'en');
      expect(repo.reads.last, 30);
      await tester.drag(find.byType(ListView), const Offset(0, 600));
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('chat-newest')), findsOneWidget);
      final scroll = tester
          .state<ScrollableState>(
            find
                .descendant(
                  of: find.byType(ListView),
                  matching: find.byType(Scrollable),
                )
                .first,
          )
          .position;
      final before = scroll.pixels;
      final reads = repo.reads.length;
      repo.onFetch = (_) => Future.value(
        ChatMessagePage(
          metadata: chatMetadata(revision: 3, customerRead: 30),
          messages: List.generate(30, (i) => chatMessage(i + 2)),
          nextBeforeSequence: 2,
        ),
      );
      await c.refresh();
      await tester.pumpAndSettle();
      expect(scroll.pixels, greaterThan(before));
      expect(repo.reads, hasLength(reads));
      await tester.tap(find.byKey(const Key('chat-newest')));
      await tester.pumpAndSettle();
      expect(repo.reads.last, 31);
      await tester.pumpWidget(const SizedBox());
    },
  );
  for (final locale in ['ar', 'en']) {
    for (final target in [
      (320.0, 640.0, 2.0),
      (390.0, 844.0, 1.0),
      (800.0, 1000.0, 2.0),
      (800.0, 390.0, 1.0),
    ]) {
      testWidgets('$locale layout ${target.$1} x${target.$3}', (tester) async {
        tester.view.physicalSize = Size(target.$1, target.$2);
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);
        final store = chatStore();
        final repo = MockChatRepository(store, now: () => chatNow);
        addTearDown(repo.dispose);
        addTearDown(store.dispose);
        await pumpChat(
          tester,
          repository: repo,
          locale: locale,
          scale: target.$3,
        );
        expect(tester.takeException(), isNull);
        await captureChat(
          tester,
          'conversation-$locale-${target.$1.toInt()}x${target.$2.toInt()}-x${target.$3.toInt()}',
        );
        await tester.enterText(
          find.byKey(const Key('chat-input')),
          'رسالة / message',
        );
        tester.view.viewInsets = FakeViewPadding(
          bottom: target.$2 < 500 ? 120 : 260,
        );
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
        expect(
          tester.getRect(find.byKey(const Key('chat-send'))).bottom,
          lessThanOrEqualTo(target.$2 - tester.view.viewInsets.bottom),
        );
        await captureChat(
          tester,
          'keyboard-$locale-${target.$1.toInt()}x${target.$2.toInt()}-x${target.$3.toInt()}',
        );
        tester.view.resetViewInsets();
        await tester.pumpWidget(const SizedBox());
      });
    }
  }
  for (final scenario in [
    ChatMockScenario.empty,
    ChatMockScenario.disconnect,
    ChatMockScenario.sendFailure,
    ChatMockScenario.lostResponse,
  ]) {
    testWidgets('state $scenario renders accessibly', (tester) async {
      final store = chatStore();
      final repo = MockChatRepository(
        store,
        now: () => chatNow,
        scenario: scenario,
      );
      addTearDown(repo.dispose);
      addTearDown(store.dispose);
      await pumpChat(tester, repository: repo);
      if (scenario == ChatMockScenario.sendFailure ||
          scenario == ChatMockScenario.lostResponse) {
        await tester.enterText(
          find.byKey(const Key('chat-input')),
          'رسالة تجريبية',
        );
        await tester.pump();
        await tester.tap(find.byKey(const Key('chat-send')));
        await tester.pumpAndSettle();
        expect(find.text('إعادة المحاولة'), findsOneWidget);
      }
      expect(tester.takeException(), isNull);
      await captureChat(tester, 'state-${scenario.name}');
      await tester.pumpWidget(const SizedBox());
    });
  }
  testWidgets('loading and read only states remain explicit', (tester) async {
    final delayed = ControlledChatRepository();
    addTearDown(delayed.events.close);
    final response = Completer<ChatMessagePage>();
    delayed.onFetch = (_) => response.future;
    await pumpChat(tester, repository: delayed, settle: false);
    await captureChat(tester, 'state-loading');
    response.complete(
      ChatMessagePage(metadata: chatMetadata(), messages: [chatMessage(1)]),
    );
    await tester.pumpAndSettle();
    await tester.pumpWidget(const SizedBox());
    final store = chatStore();
    store.cancel('trip-1');
    final repo = MockChatRepository(store, now: () => chatNow);
    addTearDown(repo.dispose);
    addTearDown(store.dispose);
    await pumpChat(tester, repository: repo);
    expect(
      tester.widget<IconButton>(find.byKey(const Key('chat-send'))).onPressed,
      isNull,
    );
    await captureChat(tester, 'state-read-only');
    await tester.pumpWidget(const SizedBox());
  });
  testWidgets('server read receipt is shown only from metadata', (
    tester,
  ) async {
    final repo = ControlledChatRepository();
    addTearDown(repo.events.close);
    repo.onFetch = (_) => Future.value(
      ChatMessagePage(
        metadata: chatMetadata(
          revision: 6,
          delivered: 2,
          read: 2,
          customerRead: 2,
        ),
        messages: [
          chatMessage(1),
          chatMessage(2, clientId: 'receipt'),
        ],
      ),
    );
    await pumpChat(tester, repository: repo);
    expect(find.text('مقروءة'), findsOneWidget);
    await captureChat(tester, 'state-read-receipt');
    await tester.pumpWidget(const SizedBox());
  });
}
