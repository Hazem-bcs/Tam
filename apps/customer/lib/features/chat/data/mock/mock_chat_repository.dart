import 'dart:async';
import 'package:tam_customer/shared/data/mock/mock_trip_store.dart';
import 'package:tam_customer/shared/domain/trip.dart';
import '../../domain/chat_repository.dart';
import 'chat_fixtures.dart';
import 'chat_mock_scenario.dart';

/// Session-owned text store. Trip eligibility is always resolved at operation time.
final class MockChatRepository implements ChatRepository {
  MockChatRepository(
    this._store, {
    DateTime Function()? now,
    this.scenario = ChatMockScenario.success,
    this.policy = const ChatPolicy(),
  }) : _now = now ?? DateTime.now {
    _subscription = _store.changes.listen((_) {
      if (!_disposed) _changes.add(const ChatChange());
    });
  }
  final MockTripStore _store;
  final DateTime Function() _now;
  final ChatMockScenario scenario;
  final ChatPolicy policy;
  final _threads = <String, _Thread>{};
  final _changes = StreamController<ChatChange>.broadcast(sync: true);
  late final StreamSubscription<List<Trip>> _subscription;
  bool _disposed = false;
  bool failNextFetch = false,
      failNextSend = false,
      loseNextSendResponse = false;
  final _scenarioUsed = <String>{};

  _Thread _resolve(String tripId, {bool write = false}) {
    if (_disposed) throw const ChatFailure('SERVICE_UNAVAILABLE');
    final trip = _store.find(tripId);
    if (trip == null) throw const ChatFailure('TRIP_NOT_FOUND');
    final driver = trip.live?.driver;
    if (driver == null ||
        {
          TripStatus.requested,
          TripStatus.scheduled,
          TripStatus.noDriver,
        }.contains(trip.status)) {
      throw const ChatFailure('CHAT_UNAVAILABLE');
    }
    var thread = _threads[tripId];
    if (thread != null && thread.driverId != driver.id) {
      throw const ChatFailure('DRIVER_CHANGED');
    }
    thread ??= _threads[tripId] = _Thread(
      driver.id,
      scenario == ChatMockScenario.empty
          ? []
          : ChatFixtures.messages(tripId, _now().toUtc()),
    );
    final canSend = {
      TripStatus.confirmed,
      TripStatus.driverEnRoute,
      TripStatus.driverArrived,
      TripStatus.inProgress,
    }.contains(trip.status);
    if (write && !canSend) throw const ChatFailure('CHAT_CLOSED');
    final tripRevision = trip.live?.revision ?? 0;
    if (thread.tripRevision != tripRevision) {
      thread.tripRevision = tripRevision;
      thread.revision++;
    }
    thread.metadata = ChatMetadata(
      tripId: tripId,
      driverId: driver.id,
      driverName: driver.name,
      driverNameEn: driver.nameEn,
      revision: thread.revision,
      canSend: canSend,
      deliveredThrough: thread.deliveredThrough,
      readThrough: thread.readThrough,
      customerReadThrough: thread.customerReadThrough,
    );
    return thread;
  }

  @override
  Future<ChatMessagePage> fetch(String tripId, {int? beforeSequence}) async {
    final thread = _resolve(tripId);
    if (failNextFetch || scenario == ChatMockScenario.disconnect) {
      failNextFetch = false;
      throw const ChatFailure('NETWORK_ERROR');
    }
    if (beforeSequence != null && beforeSequence < 1) {
      throw const ChatFailure('VALIDATION_ERROR');
    }
    final eligible = thread.messages
        .where((m) => beforeSequence == null || m.sequence < beforeSequence)
        .toList();
    final page = eligible
        .skip(
          eligible.length > policy.pageSize
              ? eligible.length - policy.pageSize
              : 0,
        )
        .toList();
    return ChatMessagePage(
      metadata: thread.metadata!,
      messages: page,
      nextBeforeSequence: eligible.length > page.length
          ? page.first.sequence
          : null,
    );
  }

  @override
  Future<ChatSent> send(
    String tripId, {
    required String clientMessageId,
    required String body,
  }) async {
    final thread = _resolve(tripId, write: true);
    final value = policy.validate(body);
    if (clientMessageId.trim().isEmpty) {
      throw const ChatFailure('VALIDATION_ERROR');
    }
    final previous = thread.messages
        .where((m) => m.clientMessageId == clientMessageId)
        .firstOrNull;
    if (previous != null) {
      if (previous.body != value) {
        throw const ChatFailure('IDEMPOTENCY_CONFLICT');
      }
      return ChatSent(thread.metadata!, previous);
    }
    if (failNextSend ||
        scenario == ChatMockScenario.disconnect ||
        (scenario == ChatMockScenario.sendFailure &&
            _scenarioUsed.add(tripId))) {
      failNextSend = false;
      throw const ChatFailure('NETWORK_ERROR');
    }
    final sequence = (thread.messages.lastOrNull?.sequence ?? 0) + 1;
    var timestamp = _now().toUtc();
    final last = thread.messages.lastOrNull?.sentAt;
    if (last != null && timestamp.isBefore(last)) timestamp = last;
    final message = ChatMessage(
      id: '$tripId-message-$sequence',
      sequence: sequence,
      clientMessageId: clientMessageId,
      author: ChatAuthor.customer,
      body: value,
      sentAt: timestamp,
    );
    thread.messages.add(message);
    thread.revision++;
    _resolve(tripId);
    if (loseNextSendResponse ||
        (scenario == ChatMockScenario.lostResponse &&
            _scenarioUsed.add(tripId))) {
      loseNextSendResponse = false;
      throw const ChatFailure('NETWORK_ERROR', uncertain: true);
    }
    _changes.add(const ChatChange());
    return ChatSent(thread.metadata!, message);
  }

  @override
  Future<ChatMetadata> markRead(String tripId, int throughSequence) async {
    final thread = _resolve(tripId);
    final last = thread.messages.lastOrNull?.sequence ?? 0;
    if (throughSequence < 0 || throughSequence > last) {
      throw const ChatFailure('VALIDATION_ERROR');
    }
    if (scenario == ChatMockScenario.disconnect) {
      throw const ChatFailure('NETWORK_ERROR');
    }
    if (throughSequence > thread.customerReadThrough) {
      thread.customerReadThrough = throughSequence;
      thread.revision++;
    }
    return _resolve(tripId).metadata!;
  }

  /// Deterministic server receipt event, never inferred by presentation.
  void advanceReceipts(
    String tripId, {
    required int deliveredThrough,
    required int readThrough,
  }) {
    final thread = _resolve(tripId);
    final last = thread.messages.lastOrNull?.sequence ?? 0;
    if (readThrough < thread.readThrough ||
        deliveredThrough < thread.deliveredThrough ||
        readThrough > deliveredThrough ||
        deliveredThrough > last) {
      throw const ChatFailure('VALIDATION_ERROR');
    }
    thread.deliveredThrough = deliveredThrough;
    thread.readThrough = readThrough;
    thread.revision++;
    _changes.add(const ChatChange());
  }

  @override
  Stream<ChatChange> get changes => _changes.stream;
  void resetSession() {
    _threads.clear();
    _scenarioUsed.clear();
    failNextFetch = failNextSend = loseNextSendResponse = false;
    if (!_disposed) _changes.add(const ChatChange(sessionReset: true));
  }

  Future<void> dispose() async {
    _disposed = true;
    await _subscription.cancel();
    await _changes.close();
  }
}

final class _Thread {
  _Thread(this.driverId, this.messages);
  final String driverId;
  final List<ChatMessage> messages;
  int revision = 1, tripRevision = -1;
  int deliveredThrough = 0, readThrough = 0, customerReadThrough = 0;
  ChatMetadata? metadata;
}
