import 'dart:async';
import 'package:flutter_test/flutter_test.dart';
import 'package:tam_customer/features/chat/domain/chat_repository.dart';
import 'package:tam_customer/features/chat/presentation/bloc/chat_cubit.dart';
import 'chat_test_support.dart';

void main() {
  late ControlledChatRepository repository;
  late ChatCubit cubit;
  ChatCubit create() => cubit = ChatCubit(
    repository,
    tripId: 'trip-1',
    policy: const ChatPolicy(),
    now: () => chatNow,
  );
  setUp(() => repository = ControlledChatRepository());
  tearDown(() async {
    await cubit.close();
    await repository.events.close();
  });
  test(
    'pagination remains retryable after suspension during older request',
    () async {
      repository.onFetch = (_) => Future.value(
        ChatMessagePage(
          metadata: chatMetadata(),
          messages: [chatMessage(2)],
          nextBeforeSequence: 2,
        ),
      );
      final c = create();
      await chatFlush();
      final older = Completer<ChatMessagePage>();
      repository.onFetch = (before) => before == null
          ? Future.value(
              ChatMessagePage(
                metadata: chatMetadata(),
                messages: [chatMessage(2)],
                nextBeforeSequence: 2,
              ),
            )
          : older.future;
      final loading = c.loadOlder();
      c.setActive(false);
      older.complete(
        ChatMessagePage(metadata: chatMetadata(), messages: [chatMessage(1)]),
      );
      await loading;
      c.setActive(true);
      await chatFlush();
      expect(c.state.loadingOlder, isFalse);
      await c.loadOlder();
      expect(c.state.messages.map((m) => m.sequence), [1, 2]);
    },
  );
  test('older response cannot discard a new latest-page gap cursor', () async {
    repository.onFetch = (_) => Future.value(
      ChatMessagePage(
        metadata: chatMetadata(),
        messages: List.generate(30, (i) => chatMessage(i + 50)),
        nextBeforeSequence: 50,
      ),
    );
    final c = create();
    await chatFlush();
    final older = Completer<ChatMessagePage>();
    repository.onFetch = (before) => before == null
        ? Future.value(
            ChatMessagePage(
              metadata: chatMetadata(revision: 3),
              messages: List.generate(30, (i) => chatMessage(i + 100)),
              nextBeforeSequence: 100,
            ),
          )
        : older.future;
    final loading = c.loadOlder();
    await c.refresh();
    older.complete(
      ChatMessagePage(
        metadata: chatMetadata(revision: 2),
        messages: List.generate(30, (i) => chatMessage(i + 20)),
        nextBeforeSequence: 20,
      ),
    );
    await loading;
    expect(c.state.nextBeforeSequence, 100);
  });
  test(
    'obsolete older failure cannot latch identity after latest success',
    () async {
      repository.onFetch = (_) => Future.value(
        ChatMessagePage(
          metadata: chatMetadata(),
          messages: [chatMessage(2)],
          nextBeforeSequence: 2,
        ),
      );
      final c = create();
      await chatFlush();
      final older = Completer<ChatMessagePage>();
      repository.onFetch = (before) => before == null
          ? Future.value(
              ChatMessagePage(
                metadata: chatMetadata(revision: 4),
                messages: [chatMessage(2)],
                nextBeforeSequence: 2,
              ),
            )
          : older.future;
      final loading = c.loadOlder();
      await c.refresh();
      older.completeError(const ChatFailure('DRIVER_CHANGED'));
      await loading;
      expect(c.state.failure, isNull);
      expect(c.state.canSend, isTrue);
      expect(c.send('still valid'), isTrue);
      await chatFlush();
    },
  );
  test(
    'send acknowledgement ahead of history cannot hide a pagination gap',
    () async {
      repository.onFetch = (_) => Future.value(
        ChatMessagePage(
          metadata: chatMetadata(),
          messages: List.generate(30, (i) => chatMessage(i + 1)),
        ),
      );
      final c = create();
      await chatFlush();
      repository.onSend = (id, body) => Future.value(
        ChatSent(
          chatMetadata(revision: 3),
          ChatMessage(
            id: 'sent',
            sequence: 100,
            author: ChatAuthor.customer,
            body: body,
            sentAt: chatNow,
            clientMessageId: id,
          ),
        ),
      );
      c.send('jump');
      await chatFlush();
      repository.onFetch = (before) => Future.value(
        ChatMessagePage(
          metadata: chatMetadata(revision: 3),
          messages: List.generate(
            30,
            (i) => chatMessage(i + (before == null ? 71 : 41)),
          ),
          nextBeforeSequence: before == null ? 71 : 41,
        ),
      );
      await c.refresh();
      expect(c.state.nextBeforeSequence, 71);
      await c.loadOlder();
      expect(c.state.messages.any((m) => m.sequence == 50), isTrue);
    },
  );
}
