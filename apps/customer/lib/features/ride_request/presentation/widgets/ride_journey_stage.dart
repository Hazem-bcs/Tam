import 'package:flutter/material.dart';
import 'package:tam_customer/features/ride_request/presentation/bloc/ride_draft_bloc.dart';
import 'package:tam_customer/features/ride_request/presentation/widgets/ride_journey_entry.dart';
import 'package:tam_customer/shared/domain/trip.dart';

import 'ride_journey_place_sheet.dart';
import 'ride_vehicle_fare_sheet.dart';

enum RideJourneyStep { entry, places, vehicle }

class RideJourneyStage extends StatelessWidget {
  const RideJourneyStage({
    super.key,
    required this.step,
    required this.state,
    required this.pickingPickup,
    required this.onPickup,
    required this.onDestination,
    required this.onSelected,
    required this.onContinue,
    this.savedAddressPickerBuilder,
    this.locationStatus,
    this.onPickOnMap,
  });
  final Widget? locationStatus;
  final VoidCallback? onPickOnMap;
  final RideJourneyStep step;
  final RideDraftState state;
  final bool pickingPickup;
  final VoidCallback onPickup, onDestination;
  final ValueChanged<TripLocation> onSelected;
  final VoidCallback? onContinue;
  final Widget Function(ValueChanged<TripLocation>)? savedAddressPickerBuilder;

  @override
  Widget build(BuildContext context) {
    if (step == RideJourneyStep.entry) {
      return SingleChildScrollView(
        child: RideJourneyEntry(
          pickup: state.pickup,
          destination: state.destination,
          onPickup: onPickup,
          onDestination: onDestination,
          onContinue: onContinue,
          status: locationStatus,
        ),
      );
    }
    if (step == RideJourneyStep.places) {
      return RideJourneyPlaceSheet(
        pickingPickup: pickingPickup,
        pickup: state.pickup,
        destination: state.destination,
        onOtherEndpoint: pickingPickup ? onDestination : onPickup,
        onSelected: onSelected,
        onPickOnMap: onPickOnMap,
        status: locationStatus,
        savedAddressPickerBuilder: savedAddressPickerBuilder,
      );
    }
    return RideVehicleFareSheet(
      state: state,
      onContinue: onContinue,
      locationStatus: locationStatus,
    );
  }
}
