import 'package:equatable/equatable.dart';
import 'package:tam_customer/features/ride_request/domain/ride_models.dart';
import 'package:tam_customer/shared/domain/ride_schedule_policy.dart';
import 'package:tam_customer/shared/domain/trip.dart';

sealed class RideDraftEvent extends Equatable {
  const RideDraftEvent();
  @override
  List<Object?> get props => [];
}

final class PickupSelected extends RideDraftEvent {
  const PickupSelected(this.location);
  final TripLocation location;
  @override
  List<Object?> get props => [location];
}

final class DestinationSelected extends RideDraftEvent {
  const DestinationSelected(this.location);
  final TripLocation location;
  @override
  List<Object?> get props => [location];
}

final class VehicleClassSelected extends RideDraftEvent {
  const VehicleClassSelected(this.vehicleClass);
  final RideVehicleClass vehicleClass;
  @override
  List<Object?> get props => [vehicleClass];
}

final class RidePlaceSearchChanged extends RideDraftEvent {
  const RidePlaceSearchChanged(this.query);
  final String query;
  @override
  List<Object?> get props => [query];
}

final class RideQuoteRequested extends RideDraftEvent {
  const RideQuoteRequested();
}

final class RideScheduleChanged extends RideDraftEvent {
  const RideScheduleChanged(this.scheduledAt);
  final DateTime? scheduledAt;
  @override
  List<Object?> get props => [scheduledAt];
}

final class RideConfirmationRequested extends RideDraftEvent {
  const RideConfirmationRequested();
}

final class RideQuoteExpired extends RideDraftEvent {
  const RideQuoteExpired(this.id);
  final String id;
  @override
  List<Object?> get props => [id];
}

enum RideFlowStatus { editing, quoting, ready, confirming, booked, failed }

enum RideFailureStep { places, quote, confirmation }

final class RideDraftState extends Equatable {
  const RideDraftState({
    this.pickup,
    this.destination,
    this.vehicleClass = RideVehicleClass.standard,
    this.quote,
    this.confirmedTrip,
    this.status = RideFlowStatus.editing,
    this.errorCode,
    this.failureStep,
    this.suggestions = const [],
    this.searching = false,
    this.searchError,
    this.scheduledAt,
  });

  final TripLocation? pickup;
  final TripLocation? destination;
  final RideVehicleClass vehicleClass;
  final RideQuote? quote;
  final Trip? confirmedTrip;
  final RideFlowStatus status;
  final String? errorCode;
  final RideFailureStep? failureStep;
  final List<RidePlace> suggestions;
  final bool searching;
  final String? searchError;
  final DateTime? scheduledAt;

  // An unanswered confirmation must resolve before a new booking intent.
  bool get confirmationPending =>
      status == RideFlowStatus.confirming ||
      status == RideFlowStatus.booked ||
      failureStep == RideFailureStep.confirmation;

  bool get hasRoute =>
      pickup != null &&
      destination != null &&
      pickup!.label.trim().isNotEmpty &&
      destination!.label.trim().isNotEmpty &&
      pickup!.point != destination!.point;

  bool canConfirmAt(
    DateTime now, {
    RideSchedulePolicy policy = const RideSchedulePolicy(),
  }) =>
      hasRoute &&
      quote != null &&
      quote!.pickup == pickup &&
      quote!.destination == destination &&
      quote!.vehicleClass == vehicleClass &&
      quote!.scheduledAt == scheduledAt &&
      policy.allows(scheduledAt, now) &&
      quote!.isValidAt(now) &&
      status != RideFlowStatus.quoting &&
      status != RideFlowStatus.confirming &&
      status != RideFlowStatus.booked;

  RideDraftState copyWith({
    TripLocation? pickup,
    TripLocation? destination,
    RideVehicleClass? vehicleClass,
    RideQuote? quote,
    Trip? confirmedTrip,
    RideFlowStatus? status,
    String? errorCode,
    RideFailureStep? failureStep,
    List<RidePlace>? suggestions,
    bool? searching,
    String? searchError,
    bool clearQuote = false,
    bool clearError = false,
    bool clearSearchError = false,
    DateTime? scheduledAt,
    bool clearSchedule = false,
  }) => RideDraftState(
    pickup: pickup ?? this.pickup,
    destination: destination ?? this.destination,
    vehicleClass: vehicleClass ?? this.vehicleClass,
    quote: clearQuote ? null : quote ?? this.quote,
    confirmedTrip: confirmedTrip ?? this.confirmedTrip,
    status: status ?? this.status,
    errorCode: clearError ? null : errorCode ?? this.errorCode,
    failureStep: clearError ? null : failureStep ?? this.failureStep,
    suggestions: suggestions ?? this.suggestions,
    searching: searching ?? this.searching,
    searchError: clearSearchError ? null : searchError ?? this.searchError,
    scheduledAt: clearSchedule ? null : scheduledAt ?? this.scheduledAt,
  );

  @override
  List<Object?> get props => [
    pickup,
    destination,
    vehicleClass,
    quote,
    confirmedTrip,
    status,
    errorCode,
    failureStep,
    suggestions,
    searching,
    searchError,
    scheduledAt,
  ];
}
