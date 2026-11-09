import 'dart:async';
import 'package:tam_customer/shared/data/mock/mock_trip_store.dart';
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
  }
  final MockTripStore trips;
  final DateTime Function() now;
  final String scenario;
  final _resets = StreamController<bool>.broadcast(sync: true);
  @override
  Future<DriverContact> fetch({
    required String tripId,
    required String driverId,
  }) async {
    if (scenario == 'offline') {
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
    return DriverContact(
      tripId: tripId,
      driverId: driverId,
      phoneE164: '+963900000000',
      expiresAt: now().toUtc().add(const Duration(minutes: 2)),
    );
  }

  @override
  Stream<bool> get sessionResets => _resets.stream;
  void resetSession() => _resets.add(true);
  Future<void> dispose() => _resets.close();
}

final class MockPhoneDialer implements PhoneDialer {
  const MockPhoneDialer();
  @override
  Future<DialerResult> open(String phoneE164) async => DialerResult.simulated;
}
