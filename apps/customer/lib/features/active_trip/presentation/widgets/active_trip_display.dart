import 'package:tam_customer/l10n/app_localizations.dart';
import 'package:tam_customer/shared/domain/trip.dart';

String activeTripDescription(AppLocalizations l, TripStatus status) =>
    switch (status) {
      TripStatus.scheduled => l.activeTripScheduledHint,
      TripStatus.requested => l.activeTripSearchingHint,
      TripStatus.confirmed => l.activeTripAssignedHint,
      TripStatus.driverEnRoute => l.activeTripEnRouteHint,
      TripStatus.driverArrived => l.activeTripArrivedHint,
      TripStatus.inProgress => l.activeTripJourneyHint,
      TripStatus.completed => l.activeTripCompletedHint,
      TripStatus.cancelled => l.activeTripCancelledHint,
      TripStatus.noDriver => l.activeTripNoDriverHint,
    };

String activeTripError(AppLocalizations l, String? code) => switch (code) {
  'ROUTING_UNAVAILABLE' => l.mapsRouteFailed,
  'TRIP_NOT_CANCELLABLE' => l.activeTripCannotCancel,
  'TRIP_NOT_FOUND' => l.activeTripNotFound,
  'INVALID_RESPONSE' => l.activeTripInvalidResponse,
  'UNAUTHENTICATED' || 'FORBIDDEN' => l.activeTripAccessDenied,
  'SERVICE_UNAVAILABLE' => l.activeTripUnavailable,
  _ => l.activeTripConnectionLost,
};
