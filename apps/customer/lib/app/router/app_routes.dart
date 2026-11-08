/// Route locations shared by navigation, guards and deep links.
abstract final class AppRoutes {
  static const home = '/';
  static const auth = '/auth';
  static const otp = '/auth/otp';
  static const authStatus = '/auth/status';
  static const rideRequest = '/ride-request';
  static const trips = '/trips';
  static const tripDetails = '/trips/:tripId';
  static const notifications = '/notifications';
  static const settings = '/settings';
  static const addresses = '/addresses';
  static const addAddress = '/addresses/new';
  static const editAddress = '/addresses/:addressId/edit';

  static String addressEditLocation(String id) {
    if (id.trim().isEmpty) throw ArgumentError.value(id, 'id');
    return Uri(pathSegments: ['', 'addresses', id, 'edit']).toString();
  }

  static String tripLocation(String id) {
    if (id.isEmpty) throw ArgumentError.value(id, 'id');
    return Uri(pathSegments: ['', 'trips', id]).toString();
  }
}
