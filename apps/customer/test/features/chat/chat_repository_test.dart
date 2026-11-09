import 'package:flutter_test/flutter_test.dart';
import 'package:tam_customer/features/chat/data/mock/chat_mock_scenario.dart';
import 'package:tam_customer/features/chat/data/mock/mock_chat_repository.dart';
import 'package:tam_customer/features/chat/data/unavailable_chat_repository.dart';
import 'package:tam_customer/features/chat/domain/chat_repository.dart';
import 'package:tam_customer/shared/data/mock/mock_trip_store.dart';
import 'package:tam_customer/shared/domain/trip.dart';
import 'package:tam_customer/shared/domain/trip_live_details.dart';
import 'chat_test_support.dart';

void main() {
  late MockTripStore store;
  late MockChatRepository repository;
  setUp(() {
    store = chatStore();
    repository = MockChatRepository(store, now: () => chatNow);
  });
  tearDown(() async {
    await repository.dispose();
    await store.dispose();
  });
  final failure = isA<ChatFailure>();
  test('trim and Unicode scalar length including emoji', () async {
    final result = await repository.send(
      'trip-1',
      clientMessageId: 'emoji',
      body: '  😀  ',
    );
    expect(result.message.body, '😀');
    await repository.send(
      'trip-1',
      clientMessageId: 'limit',
      body: List.filled(1000, '😀').join(),
    );
    await expectLater(
      repository.send(
        'trip-1',
        clientMessageId: 'too-long',
        body: List.filled(1001, '😀').join(),
      ),
      throwsA(failure),
    );
    await expectLater(
      repository.send('trip-1', clientMessageId: 'blank', body: ' \n '),
      throwsA(failure),
    );
  });
  test(
    'lost response retry uses same message and detects conflicting body',
    () async {
      repository.loseNextSendResponse = true;
      await expectLater(
        repository.send('trip-1', clientMessageId: 'stable', body: 'hello'),
        throwsA(
          isA<ChatFailure>().having((f) => f.uncertain, 'uncertain', true),
        ),
      );
      final result = await repository.send(
        'trip-1',
        clientMessageId: 'stable',
        body: 'hello',
      );
      expect(result.message.sequence, 4);
      expect(
        (await repository.fetch(
          'trip-1',
        )).messages.where((m) => m.clientMessageId == 'stable'),
        hasLength(1),
      );
      await expectLater(
        repository.send('trip-1', clientMessageId: 'stable', body: 'changed'),
        throwsA(failure),
      );
    },
  );
  test('latest 30 and older exclusive cursor have no overlap', () async {
    for (var i = 0; i < 65; i++) {
      await repository.send(
        'trip-1',
        clientMessageId: 'id-$i',
        body: 'body $i',
      );
    }
    final latest = await repository.fetch('trip-1');
    final older = await repository.fetch(
      'trip-1',
      beforeSequence: latest.nextBeforeSequence,
    );
    final oldest = await repository.fetch(
      'trip-1',
      beforeSequence: older.nextBeforeSequence,
    );
    expect(
      latest.messages.map((m) => m.sequence),
      orderedEquals(List.generate(30, (i) => i + 39)),
    );
    expect(
      older.messages.map((m) => m.sequence),
      orderedEquals(List.generate(30, (i) => i + 9)),
    );
    expect(
      oldest.messages.map((m) => m.sequence),
      orderedEquals(List.generate(8, (i) => i + 1)),
    );
    expect(oldest.nextBeforeSequence, isNull);
  });
  test(
    'eligibility is resolved for each send and terminal is readable',
    () async {
      await repository.fetch('trip-1');
      store.cancel('trip-1');
      expect((await repository.fetch('trip-1')).metadata.canSend, isFalse);
      await expectLater(
        repository.send('trip-1', clientMessageId: 'closed', body: 'hi'),
        throwsA(failure),
      );
    },
  );
  for (final status in [
    TripStatus.scheduled,
    TripStatus.requested,
    TripStatus.noDriver,
  ]) {
    test('no conversation for $status without assigned driver', () async {
      final other = MockTripStore(
        seed: [chatTrip(id: 'other', status: status, driver: null)],
      );
      final repo = MockChatRepository(other);
      await expectLater(repo.fetch('other'), throwsA(failure));
      await expectLater(
        repo.send('other', clientMessageId: 'x', body: 'hi'),
        throwsA(failure),
      );
      await repo.dispose();
      await other.dispose();
    });
  }
  test('driver changes cannot deliver to the previous identity', () async {
    await repository.fetch('trip-1');
    const replacement = TripDriver(
      id: 'driver-2',
      name: 'ب',
      nameEn: 'B',
      vehicle: 'س',
      vehicleEn: 'C',
      plate: '456',
      rating: 4,
    );
    store.updateLive(
      chatTrip(driver: replacement, revision: 2),
      expectedRevision: 1,
    );
    await expectLater(repository.fetch('trip-1'), throwsA(failure));
    await expectLater(
      repository.send('trip-1', clientMessageId: 'x', body: 'hi'),
      throwsA(failure),
    );
  });
  test(
    'receipts are explicit, monotonic, bounded and independent of customer read',
    () async {
      expect((await repository.fetch('trip-1')).metadata.readThrough, 0);
      await repository.markRead('trip-1', 3);
      expect((await repository.fetch('trip-1')).metadata.readThrough, 0);
      repository.advanceReceipts('trip-1', deliveredThrough: 3, readThrough: 2);
      expect((await repository.fetch('trip-1')).metadata.readThrough, 2);
      expect(
        () => repository.advanceReceipts(
          'trip-1',
          deliveredThrough: 1,
          readThrough: 1,
        ),
        throwsA(failure),
      );
      await expectLater(repository.markRead('trip-1', 4), throwsA(failure));
      expect((await repository.markRead('trip-1', 1)).customerReadThrough, 3);
    },
  );
  test(
    'reset clears sent text and keys, isolates trips and notifies immediately',
    () async {
      await repository.send('trip-1', clientMessageId: 'x', body: 'private');
      final events = <ChatChange>[];
      final subscription = repository.changes.listen(events.add);
      repository.resetSession();
      expect(events.single.sessionReset, isTrue);
      expect(
        (await repository.fetch(
          'trip-1',
        )).messages.any((m) => m.body == 'private'),
        isFalse,
      );
      expect(
        (await repository.send(
          'trip-1',
          clientMessageId: 'x',
          body: 'new session',
        )).message.body,
        'new session',
      );
      await expectLater(repository.fetch('different'), throwsA(failure));
      await subscription.cancel();
    },
  );
  test('clock regression cannot reorder server timestamps', () async {
    await repository.send('trip-1', clientMessageId: 'a', body: 'a');
    final page = await repository.fetch('trip-1');
    expect(page.messages.last.sentAt, chatNow);
  });
  test(
    'scenarios are deterministic and API never falls back to mock',
    () async {
      expect(
        ChatMockScenario.parse('send_failure'),
        ChatMockScenario.sendFailure,
      );
      final repo = MockChatRepository(store, scenario: ChatMockScenario.empty);
      expect((await repo.fetch('trip-1')).messages, isEmpty);
      await repo.dispose();
      const unavailable = UnavailableChatRepository();
      await expectLater(unavailable.fetch('trip-1'), throwsA(failure));
      await expectLater(
        unavailable.send('trip-1', clientMessageId: 'x', body: 'x'),
        throwsA(failure),
      );
      await expectLater(unavailable.markRead('trip-1', 1), throwsA(failure));
    },
  );
  test(
    'simulation catches up delivery/read/reply and stops replies on closed trip',
    () async {
      var clock = chatNow;
      final repo = MockChatRepository(store, now: () => clock);
      await repo.send('trip-1', clientMessageId: 'simulation', body: 'hello');
      clock = clock.add(const Duration(seconds: 2));
      expect((await repo.fetch('trip-1')).metadata.deliveredThrough, 4);
      expect((await repo.fetch('trip-1')).metadata.readThrough, 0);
      clock = clock.add(const Duration(seconds: 2));
      expect((await repo.fetch('trip-1')).metadata.readThrough, 4);
      clock = clock.add(const Duration(seconds: 2));
      final page = await repo.fetch('trip-1');
      expect(page.messages.last.author, ChatAuthor.driver);
      expect(page.messages.last.sequence, 5);
      expect((await repo.fetch('trip-1')).messages, hasLength(5));
      await repo.send('trip-1', clientMessageId: 'closed-reply', body: 'bye');
      store.cancel('trip-1');
      clock = clock.add(const Duration(seconds: 10));
      expect(
        (await repo.fetch('trip-1')).messages.last.author,
        ChatAuthor.customer,
      );
      expect(
        page.messages.every(
          (m) => !m.sentAt.isBefore(store.find('trip-1')!.createdAt),
        ),
        isTrue,
      );
      await repo.dispose();
    },
  );
  test('backward clock is clamped to last accepted timestamp', () async {
    var clock = chatNow;
    final repo = MockChatRepository(store, now: () => clock);
    await repo.send('trip-1', clientMessageId: 'before', body: 'before');
    clock = clock.subtract(const Duration(days: 1));
    final sent = await repo.send(
      'trip-1',
      clientMessageId: 'after',
      body: 'after',
    );
    expect(sent.message.sentAt, chatNow);
    await repo.dispose();
  });
  test(
    'accepted lost response is resolved idempotently after closure without new write',
    () async {
      repository.loseNextSendResponse = true;
      await expectLater(
        repository.send('trip-1', clientMessageId: 'accepted', body: 'hello'),
        throwsA(isA<ChatFailure>()),
      );
      store.cancel('trip-1');
      final resolved = await repository.send(
        'trip-1',
        clientMessageId: 'accepted',
        body: 'hello',
      );
      expect(resolved.metadata.canSend, isFalse);
      expect(resolved.message.sequence, 4);
      expect((await repository.fetch('trip-1')).messages, hasLength(4));
      await expectLater(
        repository.send('trip-1', clientMessageId: 'new', body: 'hello'),
        throwsA(isA<ChatFailure>()),
      );
    },
  );
}
