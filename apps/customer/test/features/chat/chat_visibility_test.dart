import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tam_customer/features/chat/domain/chat_repository.dart';
import 'package:tam_customer/features/chat/presentation/widgets/chat_message_bubble.dart';
import 'chat_test_support.dart';
import 'chat_widget_support.dart';

void main() {
  testWidgets('variable-height arrivals preserve the visible history message', (
    tester,
  ) async {
    final repo = ControlledChatRepository();
    addTearDown(repo.events.close);
    repo.onFetch = (_) => Future.value(
      ChatMessagePage(
        metadata: chatMetadata(),
        messages: List.generate(30, (i) => chatMessage(i + 1)),
      ),
    );
    final cubit = await pumpChat(tester, repository: repo, locale: 'en');
    await tester.drag(find.byType(ListView), const Offset(0, 600));
    await tester.pumpAndSettle();
    final viewport = tester.getRect(find.byType(ListView));
    final anchor = find.byType(ChatMessageBubble).evaluate().firstWhere((e) {
      final rect = tester.getRect(find.byWidget(e.widget));
      return rect.top > viewport.top && rect.bottom < viewport.bottom;
    }).widget;
    final key = anchor.key!;
    final before = tester.getTopLeft(find.byKey(key));
    repo.onFetch = (_) => Future.value(
      ChatMessagePage(
        metadata: chatMetadata(revision: 3, customerRead: 30),
        messages: [
          ChatMessage(
            id: 'tall',
            sequence: 31,
            author: ChatAuthor.driver,
            body: List.filled(70, 'longtext').join(' '),
            sentAt: chatNow,
          ),
        ],
      ),
    );
    await cubit.refresh();
    await tester.pumpAndSettle();
    expect(find.byKey(key), findsOneWidget);
    expect(tester.getTopLeft(find.byKey(key)).dy, closeTo(before.dy, 1));
    await tester.pumpWidget(const SizedBox());
  });
  testWidgets(
    'pending text cannot acknowledge an accepted message outside the viewport',
    (tester) async {
      final repo = ControlledChatRepository();
      addTearDown(repo.events.close);
      final sent = Completer<ChatSent>();
      repo.onSend = (_, _) => sent.future;
      final cubit = await pumpChat(tester, repository: repo, locale: 'en');
      expect(repo.reads, [1]);
      cubit.send(List.filled(70, 'longtext').join(' '));
      await tester.pumpAndSettle();
      repo.onFetch = (_) => Future.value(
        ChatMessagePage(
          metadata: chatMetadata(revision: 3, customerRead: 1),
          messages: [chatMessage(1), chatMessage(2)],
        ),
      );
      await cubit.refresh();
      await tester.pumpAndSettle();
      final accepted = find.text('message 2');
      final viewport = tester.getRect(find.byType(ListView));
      expect(
        accepted.evaluate().isEmpty ||
            !tester.getRect(accepted).overlaps(viewport),
        isTrue,
      );
      expect(repo.reads, [1]);
      sent.complete(
        ChatSent(
          chatMetadata(revision: 4, customerRead: 1),
          ChatMessage(
            id: 'accepted-send',
            sequence: 3,
            author: ChatAuthor.customer,
            body: List.filled(70, 'longtext').join(' '),
            sentAt: chatNow,
            clientMessageId: repo.sends.single,
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(repo.reads.last, 3);
      await tester.pumpWidget(const SizedBox());
    },
  );
}
