import 'dart:async';
import 'dart:math';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/chat_repository.dart';
import 'chat_state.dart';
export 'chat_state.dart';

final class ChatCubit extends Cubit<ChatState> {
  ChatCubit(
    this.repository, {
    required this.tripId,
    required this.policy,
    required this.now,
    String Function()? createClientMessageId,
  }) : _createId = createClientMessageId ?? _randomId,
       super(ChatState(loading: true)) {
    _subscription = repository.changes.listen((change) {
      if (change.sessionReset) {
        _epoch++;
        _timer?.cancel();
        emit(ChatState(sessionEnded: true, failure: 'SESSION_ENDED'));
      } else if (_active) {
        refresh();
      }
    });
    _timer = Timer.periodic(policy.pollInterval, (_) {
      if (_active) refresh();
    });
    refresh();
  }
  final ChatRepository repository;
  final String tripId;
  final ChatPolicy policy;
  final DateTime Function() now;
  late final StreamSubscription<ChatChange> _subscription;
  Timer? _timer;
  final String Function() _createId;
  static String _randomId() {
    final random = Random.secure();
    return List.generate(
      24,
      (_) => random.nextInt(256).toRadixString(16).padLeft(2, '0'),
    ).join();
  }

  int _epoch = 0, _request = 0, _olderRequest = 0, _acknowledgedThrough = 0;
  bool _active = true,
      _reading = false,
      _identityLost = false,
      _latestAvailable = false;
  bool _valid(int epoch) => !isClosed && epoch == _epoch && !state.sessionEnded;

  void _update({
    ChatMetadata? metadata,
    List<ChatMessage>? messages,
    List<ChatPending>? pending,
    bool? loading,
    bool? loadingOlder,
    String? failure,
    int? nextBeforeSequence,
    bool replaceCursor = false,
    bool? loaded,
  }) => emit(
    ChatState(
      metadata: metadata ?? state.metadata,
      messages: messages ?? state.messages,
      pending: pending ?? state.pending,
      loading: loading ?? state.loading,
      loadingOlder: loadingOlder ?? state.loadingOlder,
      failure: _identityLost ? 'CHAT_UNAVAILABLE' : failure,
      loaded: loaded ?? state.loaded,
      nextBeforeSequence: replaceCursor
          ? nextBeforeSequence
          : state.nextBeforeSequence,
    ),
  );

  ChatMetadata _metadata(ChatMetadata incoming) {
    if (_identityLost) throw const ChatFailure('CHAT_UNAVAILABLE');
    final old = state.metadata;
    if (incoming.tripId != tripId ||
        (old != null && old.driverId != incoming.driverId)) {
      throw const ChatFailure('DRIVER_CHANGED');
    }
    if (old == null) return incoming;
    if (incoming.revision < old.revision) return old;
    if (incoming.deliveredThrough < old.deliveredThrough ||
        incoming.readThrough < old.readThrough ||
        incoming.customerReadThrough < old.customerReadThrough) {
      return old;
    }
    return incoming;
  }

  List<ChatMessage> _merge(Iterable<ChatMessage> incoming) {
    final bySequence = {for (final m in state.messages) m.sequence: m};
    for (final m in incoming) {
      bySequence[m.sequence] = m;
    }
    final result = bySequence.values.toList()
      ..sort((a, b) => a.sequence.compareTo(b.sequence));
    return result;
  }

  List<ChatPending> _reconcile(List<ChatMessage> messages) {
    final ids = messages.map((m) => m.clientMessageId).toSet();
    return state.pending
        .where((p) => !ids.contains(p.clientMessageId))
        .toList();
  }

  bool _hasNewGap(ChatMessagePage page) {
    if (page.messages.isEmpty) return false;
    final first = page.messages.first.sequence;
    // A send acknowledgement may already be ahead of the fetched page.
    final preceding = state.messages
        .where((m) => m.sequence < first)
        .lastOrNull;
    return first > (preceding?.sequence ?? 0) + 1;
  }

  Future<void> refresh() async {
    if (isClosed || state.sessionEnded || !_active) return;
    final epoch = _epoch, request = ++_request;
    _latestAvailable = false;
    _update(loading: !state.loaded);
    try {
      final page = await repository.fetch(tripId);
      if (!_valid(epoch) || request != _request || !_active) return;
      final metadata = _metadata(page.metadata);
      final messages = _merge(page.messages);
      _latestAvailable = true;
      _update(
        metadata: metadata,
        messages: messages,
        pending: _reconcile(messages),
        loading: false,
        loaded: true,
        replaceCursor: !state.loaded || _hasNewGap(page),
        nextBeforeSequence: page.nextBeforeSequence,
      );
    } on ChatFailure catch (failure) {
      if (!_valid(epoch) || request != _request) return;
      if ({
        'DRIVER_CHANGED',
        'CHAT_UNAVAILABLE',
        'TRIP_NOT_FOUND',
      }.contains(failure.code)) {
        _identityLost = true;
      }
      if (_valid(epoch) && request == _request) {
        _update(loading: false, failure: failure.code);
      }
    } catch (_) {
      if (_valid(epoch) && request == _request) {
        _update(loading: false, failure: 'INVALID_RESPONSE');
      }
    }
  }

  Future<void> loadOlder() async {
    final before = state.nextBeforeSequence;
    if (before == null ||
        state.loadingOlder ||
        state.sessionEnded ||
        !_active) {
      return;
    }
    final epoch = _epoch, request = ++_olderRequest, latestRequest = _request;
    _update(loadingOlder: true, failure: state.failure);
    try {
      final page = await repository.fetch(tripId, beforeSequence: before);
      if (!_valid(epoch) || request != _olderRequest || !_active) return;
      final metadata = _metadata(page.metadata);
      final messages = _merge(page.messages);
      _update(
        metadata: metadata,
        messages: messages,
        pending: _reconcile(messages),
        loadingOlder: false,
        replaceCursor: state.nextBeforeSequence == before,
        nextBeforeSequence: page.nextBeforeSequence,
      );
    } on ChatFailure catch (failure) {
      if (!_valid(epoch) || request != _olderRequest) return;
      if (latestRequest != _request) {
        _update(loadingOlder: false, failure: state.failure);
        return;
      }
      if ({
        'DRIVER_CHANGED',
        'CHAT_UNAVAILABLE',
        'TRIP_NOT_FOUND',
      }.contains(failure.code)) {
        _identityLost = true;
      }
      if (_valid(epoch)) _update(loadingOlder: false, failure: failure.code);
    } catch (_) {
      if (_valid(epoch) && request == _olderRequest) {
        _update(
          loadingOlder: false,
          failure: latestRequest == _request
              ? 'INVALID_RESPONSE'
              : state.failure,
        );
      }
    }
  }

  /// Accept the draft synchronously; later responses cannot clear a newer draft.
  bool send(String body) {
    if (!state.canSend || !_active || _identityLost) return false;
    String value;
    try {
      value = policy.validate(body);
    } on ChatFailure catch (failure) {
      _update(failure: failure.code);
      return false;
    }
    final pending = ChatPending(
      clientMessageId: _createId(),
      body: value,
      createdAt: now().toUtc(),
      status: ChatSendStatus.sending,
    );
    _update(pending: [...state.pending, pending]);
    _send(pending);
    return true;
  }

  Future<void> retry(String clientMessageId) async {
    if (!state.canSend || !_active || _identityLost) return;
    final pending = state.pending
        .where((p) => p.clientMessageId == clientMessageId)
        .firstOrNull;
    if (pending == null || pending.status == ChatSendStatus.sending) return;
    await _send(pending);
  }

  Future<void> _send(ChatPending pending) async {
    final epoch = _epoch;
    _pendingStatus(pending.clientMessageId, ChatSendStatus.sending);
    try {
      final sent = await repository.send(
        tripId,
        clientMessageId: pending.clientMessageId,
        body: pending.body,
      );
      if (!_valid(epoch)) return;
      if (sent.message.clientMessageId != pending.clientMessageId ||
          sent.message.body != pending.body ||
          sent.message.author != ChatAuthor.customer) {
        throw const ChatFailure('INVALID_RESPONSE', uncertain: true);
      }
      final metadata = _metadata(sent.metadata);
      final messages = _merge([sent.message]);
      _update(
        metadata: metadata,
        messages: messages,
        pending: _reconcile(messages),
      );
    } on ChatFailure catch (failure) {
      if (!_valid(epoch)) return;
      // A concurrent fetch may already have reconciled a lost response.
      _pendingStatus(
        pending.clientMessageId,
        failure.uncertain ? ChatSendStatus.uncertain : ChatSendStatus.failed,
        failure: failure.code,
      );
      if ({
        'CHAT_CLOSED',
        'DRIVER_CHANGED',
        'CHAT_UNAVAILABLE',
      }.contains(failure.code)) {
        refresh();
      }
    } catch (_) {
      if (_valid(epoch)) {
        _pendingStatus(
          pending.clientMessageId,
          ChatSendStatus.uncertain,
          failure: 'NETWORK_ERROR',
        );
      }
    }
  }

  void _pendingStatus(String id, ChatSendStatus status, {String? failure}) {
    _update(
      pending: state.pending
          .map((p) => p.clientMessageId == id ? p.withStatus(status) : p)
          .toList(),
      failure: failure,
    );
  }

  Future<void> displayedThrough(int sequence) async {
    if (!_active ||
        !_latestAvailable ||
        _reading ||
        !state.loaded ||
        state.failure != null ||
        state.sessionEnded ||
        sequence <=
            max(
              _acknowledgedThrough,
              state.metadata?.customerReadThrough ?? 0,
            ) ||
        sequence > (state.messages.lastOrNull?.sequence ?? 0)) {
      return;
    }
    final epoch = _epoch;
    _reading = true;
    try {
      final metadata = await repository.markRead(tripId, sequence);
      if (_valid(epoch) && _active) {
        _acknowledgedThrough = max(_acknowledgedThrough, sequence);
        _update(metadata: _metadata(metadata), failure: state.failure);
      }
    } on ChatFailure catch (failure) {
      if (!_valid(epoch)) return;
      if ({
        'DRIVER_CHANGED',
        'CHAT_UNAVAILABLE',
        'TRIP_NOT_FOUND',
      }.contains(failure.code)) {
        _identityLost = true;
      }
      if (_valid(epoch)) _update(failure: failure.code);
    } catch (_) {
      if (_valid(epoch)) _update(failure: 'INVALID_RESPONSE');
    } finally {
      _reading = false;
    }
  }

  void setActive(bool value) {
    _active = value;
    _request++;
    _olderRequest++;
    if (state.loadingOlder) {
      _update(loadingOlder: false, failure: state.failure);
    }
    if (value) refresh();
  }

  @override
  Future<void> close() async {
    _epoch++;
    _active = false;
    _timer?.cancel();
    await _subscription.cancel();
    return super.close();
  }
}
