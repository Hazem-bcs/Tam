import 'dart:async';
import 'package:tam_customer/shared/data/mock/mock_trip_store.dart';
import 'package:tam_customer/shared/domain/trip.dart';
import '../../domain/driver_contact_repository.dart';

final class MockDriverContactRepository implements DriverContactRepository {
  MockDriverContactRepository(
    this.trips, {
    DateTime Function()? now,
    this.scenario = 'success',
  }) : now = now ?? DateTime.now {
    if (!{'success', 'offline', 'unavailable'}.contains(scenario)) {
      throw ArgumentError.value(scenario);
    }
    _subscription = trips.changes.listen((_) {
      for (final entry in _bindings.entries.toList()) {
        final current = _binding(trips.find(entry.key));
        if (entry.value != current) {
          _bindings[entry.key] = current;
          _changes.add(DriverContactChange(tripId: entry.key));
        }
      }
    });
  }
  final MockTripStore trips;
  final DateTime Function() now;
  final String scenario;
  final _changes = StreamController<DriverContactChange>.broadcast(sync: true);
  final _bindings = <String, (String?, bool)>{};
  late final StreamSubscription<List<Trip>> _subscription;
  bool _disposed = false;
  (String?, bool) _binding(Trip? trip) =>
      (trip?.live?.driver?.id, trip != null && canContactDriver(trip));
  @override
  Future<DriverContact> fetch({
    required String tripId,
    required String driverId,
  }) async {
    if (_disposed || scenario == 'offline') {
      throw const DriverContactFailure('SERVICE_UNAVAILABLE');
    }
    final trip = trips.find(tripId);
    if (trip == null) throw const DriverContactFailure('TRIP_NOT_FOUND');
    if (trip.live?.driver?.id != driverId) {
      throw const DriverContactFailure('DRIVER_CHANGED');
    }
    if (!canContactDriver(trip) || scenario == 'unavailable') {
      throw const DriverContactFailure('CONTACT_UNAVAILABLE');
    }
    _bindings[tripId] = _binding(trip);
    return DriverContact(
      tripId: tripId,
      driverId: driverId,
      phoneE164: '+963900000000',
      expiresAt: now().toUtc().add(const Duration(minutes: 2)),
    );
  }

  @override
  Stream<DriverContactChange> get changes => _changes.stream;
  void resetSession() {
    _bindings.clear();
    if (!_disposed) _changes.add(const DriverContactChange(sessionReset: true));
  }

  Future<void> dispose() async {
    _disposed = true;
    await _subscription.cancel();
    await _changes.close();
  }
}

final class MockPhoneDialer implements PhoneDialer {
  const MockPhoneDialer();
  @override
  Future<DialerResult> open(String phoneE164) async => DialerResult.simulated;
}
