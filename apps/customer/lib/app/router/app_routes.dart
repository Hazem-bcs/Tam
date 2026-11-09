/// Route locations shared by navigation, guards and deep links.
abstract final class AppRoutes {
  static const changePhone = '/account/change-phone';
  static const deleteAccount = '/account/delete';
  static const driverContact = '/trips/:tripId/drivers/:driverId/contact';
  static String driverContactLocation(String tripId, String driverId) => Uri(
    pathSegments: ['', 'trips', tripId, 'drivers', driverId, 'contact'],
  ).toString();
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
  static const completion = '/trips/:tripId/completion';
  static const support = '/support';
  static const supportNew = '/support/new';
  static const supportTicket = '/support/tickets/:ticketId';
  static const terms = '/legal/terms';
  static const privacy = '/legal/privacy';

  static String completionLocation(String id) {
    if (id.trim().isEmpty) throw ArgumentError.value(id, 'id');
    return Uri(pathSegments: ['', 'trips', id, 'completion']).toString();
  }

  static String supportNewLocation({String? tripId}) {
    if (tripId != null && tripId.trim().isEmpty) {
      throw ArgumentError.value(tripId, 'tripId');
    }
    return Uri(
      path: supportNew,
      queryParameters: tripId == null ? null : {'trip_id': tripId},
    ).toString();
  }

  static String supportTicketLocation(String id) {
    if (id.trim().isEmpty) throw ArgumentError.value(id, 'id');
    return Uri(pathSegments: ['', 'support', 'tickets', id]).toString();
  }

  static const chat = '/trips/:tripId/chat';
  static String chatLocation(String id) {
    if (id.trim().isEmpty) throw ArgumentError.value(id, 'id');
    return Uri(pathSegments: ['', 'trips', id, 'chat']).toString();
  }

  static const activeTrip = '/active-trip';
  static const activeTripDetails = '/active-trip/:tripId';
  static String activeTripLocation(String id) {
    if (id.trim().isEmpty) throw ArgumentError.value(id, 'id');
    return Uri(pathSegments: ['', 'active-trip', id]).toString();
  }

  static String addressEditLocation(String id) {
    if (id.trim().isEmpty) throw ArgumentError.value(id, 'id');
    return Uri(pathSegments: ['', 'addresses', id, 'edit']).toString();
  }

  static String tripLocation(String id) {
    if (id.isEmpty) throw ArgumentError.value(id, 'id');
    return Uri(pathSegments: ['', 'trips', id]).toString();
  }
}
