import 'package:url_launcher/url_launcher.dart';
import '../domain/driver_contact_repository.dart';

/// Opens the system dialer; it does not claim a connected or answered call.
final class DriverPhoneDialer implements PhoneDialer {
  const DriverPhoneDialer({Future<bool> Function(Uri)? launch})
    : _launch = launch;
  final Future<bool> Function(Uri)? _launch;
  static Future<bool> _external(Uri uri) =>
      launchUrl(uri, mode: LaunchMode.externalApplication);
  @override
  Future<DialerResult> open(String phoneE164) async {
    if (!RegExp(r'^\+[1-9]\d{7,14}$').hasMatch(phoneE164)) {
      throw const DriverContactFailure('INVALID_RESPONSE');
    }
    try {
      if (await (_launch ?? _external)(Uri(scheme: 'tel', path: phoneE164))) {
        return DialerResult.opened;
      }
    } catch (_) {
      throw const DriverContactFailure('DIALER_UNAVAILABLE');
    }
    throw const DriverContactFailure('DIALER_UNAVAILABLE');
  }
}

final class UnavailableDriverContactRepository
    implements DriverContactRepository {
  const UnavailableDriverContactRepository();
  @override
  Future<DriverContact> fetch({
    required String tripId,
    required String driverId,
  }) async => throw const DriverContactFailure('SERVICE_UNAVAILABLE');
  @override
  Stream<DriverContactChange> get changes => const Stream.empty();
}
