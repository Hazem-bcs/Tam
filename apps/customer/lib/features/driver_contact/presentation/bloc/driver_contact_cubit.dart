import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/driver_contact_repository.dart';

final class DriverContactState {
  const DriverContactState({
    this.busy = false,
    this.ended = false,
    this.result,
    this.failure,
  });
  final bool busy, ended;
  final DialerResult? result;
  final String? failure;
}

final class DriverContactCubit extends Cubit<DriverContactState> {
  DriverContactCubit(
    this.repository,
    this.dialer, {
    required this.tripId,
    required this.driverId,
    DateTime Function()? now,
  }) : now = now ?? DateTime.now,
       super(const DriverContactState()) {
    _changes = repository.changes.listen((change) {
      if (change.sessionReset) {
        _epoch++;
        emit(const DriverContactState(ended: true));
      } else if (change.tripId == tripId && !state.ended) {
        _epoch++;
        emit(const DriverContactState(failure: 'CONTACT_UNAVAILABLE'));
      }
    });
  }
  final DriverContactRepository repository;
  final PhoneDialer dialer;
  final String tripId, driverId;
  final DateTime Function() now;
  late final StreamSubscription<DriverContactChange> _changes;
  int _epoch = 0;
  bool _active = true;
  void setActive(bool active) {
    if (isClosed || state.ended) return;
    _active = active;
    if (!active) {
      _epoch++;
      emit(const DriverContactState());
    }
  }

  Future<void> call({bool Function()? canOpen}) async {
    if (isClosed || state.busy || state.ended || !_active) return;
    final epoch = ++_epoch;
    emit(const DriverContactState(busy: true));
    try {
      final contact = await repository.fetch(
        tripId: tripId,
        driverId: driverId,
      );
      if (!_current(epoch)) return;
      if (contact.tripId != tripId ||
          contact.driverId != driverId ||
          !RegExp(r'^\+[1-9]\d{7,14}$').hasMatch(contact.phoneE164) ||
          !now().toUtc().isBefore(contact.expiresAt)) {
        throw const DriverContactFailure('INVALID_RESPONSE');
      }
      if (canOpen != null && !canOpen()) {
        emit(const DriverContactState());
        return;
      }
      final result = await dialer.open(contact.phoneE164);
      if (_current(epoch)) emit(DriverContactState(result: result));
    } catch (e) {
      if (_current(epoch)) {
        emit(
          DriverContactState(
            failure: e is DriverContactFailure ? e.code : 'SERVICE_UNAVAILABLE',
          ),
        );
      }
    }
  }

  bool _current(int epoch) =>
      !isClosed && !state.ended && _active && epoch == _epoch;
  @override
  Future<void> close() async {
    _epoch++;
    await _changes.cancel();
    return super.close();
  }
}
