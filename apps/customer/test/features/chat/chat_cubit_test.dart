import 'dart:async';
import 'package:flutter_test/flutter_test.dart';
import 'package:tam_customer/features/chat/domain/chat_repository.dart';
import 'package:tam_customer/features/chat/presentation/bloc/chat_cubit.dart';
import 'chat_test_support.dart';

void main() {
  late ControlledChatRepository repository;
  final cubits = <ChatCubit>[];
  ChatCubit create({String Function()? id}) {
    final cubit = ChatCubit(
      repository,
      tripId: 'trip-1',
      policy: const ChatPolicy(),
      now: () => chatNow,
      createClientMessageId: id,
    );
    cubits.add(cubit);
    return cubit;
  }

  setUp(() => repository = ControlledChatRepository());
  tearDown(() async {
    for (final c in cubits) {
      if (!c.isClosed) await c.close();
    }
    cubits.clear();
    await repository.events.close();
  });
  test(
    'poll never marks read; only bounded explicitly displayed sequence does',
    () async {
      final c = create();
      await chatFlush();
      expect(repository.reads, isEmpty);
      await c.displayedThrough(2);
      expect(repository.reads, isEmpty);
      await c.displayedThrough(1);
      expect(repository.reads, [1]);
      c.setActive(false);
      await c.displayedThrough(1);
      expect(repository.reads, [1]);
    },
  );
  test(
    'failed load retains last messages and prevents read acknowledgement',
    () async {
      final c = create();
      await chatFlush();
      repository.onFetch = (_) =>
          Future.error(const ChatFailure('NETWORK_ERROR'));
      await c.refresh();
      expect(c.state.messages.single.sequence, 1);
      await c.displayedThrough(1);
      expect(repository.reads, isEmpty);
    },
  );
  test(
    'late older read receipt cannot roll back send metadata or receipts',
    () async {
      final c = create(id: () => 'stable');
      await chatFlush();
      final read = Completer<ChatMetadata>();
      repository.onRead = (_) => read.future;
      final acknowledgement = c.displayedThrough(1);
      repository.onSend = (id, body) => Future.value(
        ChatSent(
          chatMetadata(revision: 5, delivered: 2, read: 2, customerRead: 1),
          ChatMessage(
            id: 'sent',
            sequence: 2,
            author: ChatAuthor.customer,
            body: body,
            sentAt: chatNow,
            clientMessageId: id,
          ),
        ),
      );
      expect(c.send('hello'), isTrue);
      await chatFlush();
      read.complete(chatMetadata(revision: 2, customerRead: 1));
      await acknowledgement;
      expect(c.state.metadata!.revision, 5);
      expect(c.state.metadata!.readThrough, 2);
    },
  );
  test('out of order fetch responses never replace newer revision', () async {
    final c = create();
    await chatFlush();
    final old = Completer<ChatMessagePage>();
    repository.onFetch = (_) => old.future;
    final request = c.refresh();
    repository.onFetch = (_) => Future.value(
      ChatMessagePage(
        metadata: chatMetadata(revision: 8),
        messages: [chatMessage(2)],
      ),
    );
    await c.refresh();
    old.complete(
      ChatMessagePage(
        metadata: chatMetadata(revision: 2),
        messages: [chatMessage(1)],
      ),
    );
    await request;
    expect(c.state.metadata!.revision, 8);
    expect(c.state.messages.map((m) => m.sequence), [1, 2]);
  });
  test('uncertain retry retains client id and reconciles once', () async {
    final c = create(id: () => 'stable');
    await chatFlush();
    repository.onSend = (_, _) =>
        Future.error(const ChatFailure('NETWORK_ERROR', uncertain: true));
    c.send('retained');
    await chatFlush();
    expect(c.state.pending.single.status, ChatSendStatus.uncertain);
    expect(c.state.pending.single.body, 'retained');
    repository.onSend = (id, body) => Future.value(
      ChatSent(
        chatMetadata(revision: 3),
        ChatMessage(
          id: 'sent',
          sequence: 2,
          author: ChatAuthor.customer,
          body: body,
          sentAt: chatNow,
          clientMessageId: id,
        ),
      ),
    );
    await c.retry('stable');
    expect(repository.sends, ['stable', 'stable']);
    expect(c.state.pending, isEmpty);
    expect(
      c.state.messages.where((m) => m.clientMessageId == 'stable'),
      hasLength(1),
    );
  });
  test('refresh reconciles accepted lost response without resending', () async {
    final c = create(id: () => 'stable');
    await chatFlush();
    repository.onSend = (_, _) =>
        Future.error(const ChatFailure('NETWORK_ERROR', uncertain: true));
    c.send('retained');
    await chatFlush();
    repository.onFetch = (_) => Future.value(
      ChatMessagePage(
        metadata: chatMetadata(revision: 3),
        messages: [
          chatMessage(1),
          chatMessage(2, clientId: 'stable'),
        ],
      ),
    );
    await c.refresh();
    expect(c.state.pending, isEmpty);
    expect(repository.sends, ['stable']);
  });
  test('new Cubit with same frozen clock generates distinct ids', () async {
    final first = create();
    await chatFlush();
    first.send('one');
    await chatFlush();
    await first.close();
    final second = create();
    await chatFlush();
    second.send('two');
    await chatFlush();
    expect(repository.sends.toSet(), hasLength(2));
  });
  test(
    'session reset clears all text and ignores in-flight fetch/send/read',
    () async {
      final c = create(id: () => 'secret');
      await chatFlush();
      final send = Completer<ChatSent>();
      repository.onSend = (_, _) => send.future;
      c.send('private');
      final fetch = Completer<ChatMessagePage>();
      repository.onFetch = (_) => fetch.future;
      final refresh = c.refresh();
      repository.events.add(const ChatChange(sessionReset: true));
      expect(c.state.messages, isEmpty);
      expect(c.state.pending, isEmpty);
      expect(c.state.canSend, isFalse);
      send.complete(
        ChatSent(
          chatMetadata(revision: 10),
          chatMessage(2, clientId: 'secret'),
        ),
      );
      fetch.complete(
        ChatMessagePage(
          metadata: chatMetadata(revision: 9),
          messages: [chatMessage(1)],
        ),
      );
      await refresh;
      await chatFlush();
      expect(c.state.messages, isEmpty);
      expect(c.state.sessionEnded, isTrue);
    },
  );
  test('close ignores a late send and fetch', () async {
    final c = create();
    await chatFlush();
    final result = Completer<ChatSent>();
    repository.onSend = (_, _) => result.future;
    c.send('private');
    await c.close();
    result.complete(
      ChatSent(chatMetadata(revision: 2), chatMessage(2, clientId: 'id')),
    );
    await chatFlush();
    expect(c.isClosed, isTrue);
  });
  test(
    'older pagination preserves history through latest polling and fills missed interval',
    () async {
      repository.onFetch = (_) => Future.value(
        ChatMessagePage(
          metadata: chatMetadata(),
          messages: List.generate(30, (i) => chatMessage(i + 1)),
        ),
      );
      final c = create();
      await chatFlush();
      repository.onFetch = (before) => Future.value(
        ChatMessagePage(
          metadata: chatMetadata(revision: 2),
          messages: before == 50
              ? List.generate(30, (i) => chatMessage(i + 20))
              : List.generate(30, (i) => chatMessage(i + 50)),
          nextBeforeSequence: before == 50 ? 20 : 50,
        ),
      );
      await c.refresh();
      expect(c.state.nextBeforeSequence, 50);
      await c.loadOlder();
      expect(
        c.state.messages.map((m) => m.sequence),
        List.generate(79, (i) => i + 1),
      );
    },
  );
  test(
    'driver change blocks sending even if an old send response arrives later',
    () async {
      final c = create();
      await chatFlush();
      final result = Completer<ChatSent>();
      repository.onSend = (_, _) => result.future;
      c.send('old');
      repository.onFetch = (_) =>
          Future.error(const ChatFailure('DRIVER_CHANGED'));
      await c.refresh();
      expect(c.send('new'), isFalse);
      result.complete(
        ChatSent(
          chatMetadata(revision: 5),
          chatMessage(2, clientId: repository.sends.single),
        ),
      );
      await chatFlush();
      expect(c.state.canSend, isFalse);
      expect(c.send('new'), isFalse);
    },
  );
  test(
    'mismatched send acknowledgement is uncertain and keeps original retry identity/body',
    () async {
      final c = create(id: () => 'stable');
      await chatFlush();
      repository.onSend = (_, _) => Future.value(
        ChatSent(
          chatMetadata(revision: 4),
          chatMessage(2, clientId: 'another-id'),
        ),
      );
      c.send('original');
      await chatFlush();
      expect(c.state.failure, 'INVALID_RESPONSE');
      expect(c.state.pending.single.status, ChatSendStatus.uncertain);
      expect(c.state.pending.single.body, 'original');
      expect(c.state.messages, hasLength(1));
      repository.onSend = (id, body) => Future.value(
        ChatSent(
          chatMetadata(revision: 5),
          ChatMessage(
            id: 'accepted',
            sequence: 2,
            author: ChatAuthor.customer,
            body: body,
            sentAt: chatNow,
            clientMessageId: id,
          ),
        ),
      );
      await c.retry('stable');
      expect(repository.sends, ['stable', 'stable']);
      expect(c.state.pending, isEmpty);
    },
  );
  test(
    'obsolete fetch failure cannot latch identity after newer success',
    () async {
      final c = create();
      await chatFlush();
      final old = Completer<ChatMessagePage>();
      repository.onFetch = (_) => old.future;
      final request = c.refresh();
      repository.onFetch = (_) => Future.value(
        ChatMessagePage(
          metadata: chatMetadata(revision: 4),
          messages: [chatMessage(1)],
        ),
      );
      await c.refresh();
      old.completeError(const ChatFailure('DRIVER_CHANGED'));
      await request;
      expect(c.state.canSend, isTrue);
      expect(c.send('valid'), isTrue);
      await chatFlush();
    },
  );
}
