import 'dart:async';
import 'package:tam_customer/features/driver_contact/domain/driver_contact_repository.dart';

final contactNow = DateTime.utc(2026, 11, 9, 12);

final class ContactProbe implements DriverContactRepository {
  final events = StreamController<bool>.broadcast(sync: true);
  Future<DriverContact> Function()? onFetch;
  @override
  Future<DriverContact> fetch({
    required String tripId,
    required String driverId,
  }) =>
      onFetch?.call() ??
      Future.value(
        DriverContact(
          tripId: tripId,
          driverId: driverId,
          phoneE164: '+963900000000',
          expiresAt: contactNow.add(const Duration(minutes: 2)),
        ),
      );
  @override
  Stream<bool> get sessionResets => events.stream;
}

final class DialerProbe implements PhoneDialer {
  int calls = 0;
  @override
  Future<DialerResult> open(String phoneE164) async {
    calls++;
    return DialerResult.simulated;
  }
}
