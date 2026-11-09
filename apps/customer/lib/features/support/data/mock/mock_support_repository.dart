import 'dart:async';
import 'dart:convert';
import 'package:tam_customer/shared/data/mock/mock_trip_store.dart';
import '../../domain/support_repository.dart';
import 'support_fixtures.dart';
import 'support_mock_scenario.dart';
export 'support_mock_scenario.dart';

/// App-owned, development-only support records. No backend credentials are made.
final class MockSupportRepository implements SupportRepository {
  MockSupportRepository(
    this._store, {
    DateTime Function()? now,
    this.policy = const SupportPolicy(),
    this.scenario = SupportMockScenario.success,
  }) : _now = now ?? DateTime.now;
  final MockTripStore _store;
  final DateTime Function() _now;
  final SupportPolicy policy;
  final SupportMockScenario scenario;
  final _records = <String, SupportTicket>{};
  final _requests = <String, SupportTicket>{};
  final _changes = StreamController<SupportChange>.broadcast(sync: true);
  var _sequence = 0, _session = 0;
  bool _disposed = false, _lost = false;
  bool failNextRead = false, loseNextCreateResponse = false;

  void _available({bool read = false}) {
    if (_disposed) throw const SupportFailure('SERVICE_UNAVAILABLE');
    if (scenario == SupportMockScenario.offline || (read && failNextRead)) {
      failNextRead = false;
      throw const SupportFailure('NETWORK_ERROR');
    }
  }

  void _trip(String? tripId) {
    if (tripId != null && _store.find(tripId) == null) {
      throw const SupportFailure('TRIP_NOT_FOUND');
    }
  }

  SupportOptions _options(String? tripId) {
    _trip(tripId);
    return SupportOptions(
      tripId: tripId,
      categories: SupportFixtures.categories.where(
        (c) => tripId != null || !c.tripRequired,
      ),
    );
  }

  @override
  Future<SupportOptions> options({String? tripId}) async {
    _available(read: true);
    return _options(tripId);
  }

  @override
  Future<SupportTicketPage> tickets({String? cursor}) async {
    _available(read: true);
    final all = _records.values.toList()
      ..sort((a, b) {
        final byTime = b.createdAt.compareTo(a.createdAt);
        return byTime == 0 ? b.id.compareTo(a.id) : byTime;
      });
    var start = 0;
    if (cursor != null) {
      try {
        final parts = jsonDecode(utf8.decode(base64Url.decode(cursor))) as List;
        if (parts.length != 2 || parts[0] != _session || parts[1] is! String) {
          throw const FormatException();
        }
        start = all.indexWhere((t) => t.id == parts[1]) + 1;
        if (start == 0) throw const FormatException();
      } catch (_) {
        throw const SupportFailure('INVALID_CURSOR');
      }
    }
    final page = all.skip(start).take(policy.pageSize).toList();
    for (final value in page) {
      _trip(value.tripId);
    }
    return SupportTicketPage(
      tickets: page,
      nextCursor: start + page.length < all.length
          ? base64Url.encode(utf8.encode(jsonEncode([_session, page.last.id])))
          : null,
    );
  }

  @override
  Future<SupportTicket> ticket(String id) async {
    _available(read: true);
    final value = _records[id];
    if (value == null) throw const SupportFailure('TICKET_NOT_FOUND');
    _trip(value.tripId);
    return value;
  }

  @override
  Future<SupportTicket> create({
    required String clientRequestId,
    required String categoryId,
    required String body,
    String? tripId,
  }) async {
    _available();
    final value = policy.validateBody(body);
    policy.validateCategory(_options(tripId), categoryId);
    if (!RegExp(r'^[A-Za-z0-9_-]{16,128}$').hasMatch(clientRequestId)) {
      throw const SupportFailure('VALIDATION_ERROR');
    }
    final previous = _requests[clientRequestId];
    if (previous != null) {
      if (previous.body != value ||
          previous.categoryId != categoryId ||
          previous.tripId != tripId) {
        throw const SupportFailure('IDEMPOTENCY_CONFLICT');
      }
      return previous;
    }
    final timestamp = _now().toUtc();
    final created = SupportTicket(
      id: 'mock-support-${++_sequence}',
      clientRequestId: clientRequestId,
      categoryId: categoryId,
      body: value,
      status: SupportTicketStatus.open,
      createdAt: timestamp,
      updatedAt: timestamp,
      revision: 1,
      tripId: tripId,
    );
    _records[created.id] = created;
    _requests[clientRequestId] = created;
    if (loseNextCreateResponse ||
        (scenario == SupportMockScenario.lostResponse && !_lost)) {
      loseNextCreateResponse = false;
      _lost = true;
      throw const SupportFailure('NETWORK_ERROR', uncertain: true);
    }
    _changes.add(const SupportChange());
    return created;
  }

  @override
  Future<LegalDocument?> legal(
    LegalDocumentKind kind, {
    required String languageCode,
  }) async {
    _available(read: true);
    if (!{'ar', 'en'}.contains(languageCode)) {
      throw const SupportFailure('VALIDATION_ERROR');
    }
    return null; // No approved legal copy has been supplied.
  }

  @override
  Stream<SupportChange> get changes => _changes.stream;
  void resetSession() {
    _records.clear();
    _requests.clear();
    _session++;
    _lost = failNextRead = loseNextCreateResponse = false;
    if (!_disposed) _changes.add(const SupportChange(sessionReset: true));
  }

  Future<void> dispose() async {
    _disposed = true;
    await _changes.close();
  }
}
