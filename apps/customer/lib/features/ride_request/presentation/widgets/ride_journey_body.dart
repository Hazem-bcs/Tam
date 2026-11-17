import 'package:flutter/material.dart';
import 'package:tam_customer/features/maps/presentation/widgets/map_camera_focus.dart';
import 'package:tam_customer/features/ride_request/presentation/bloc/ride_draft_bloc.dart';
import 'package:tam_customer/features/ride_request/presentation/bloc/ride_location_cubit.dart';
import 'package:tam_customer/l10n/app_localizations.dart';
import 'package:tam_customer/shared/domain/geo_point.dart';
import 'package:tam_customer/shared/domain/trip.dart';
import 'ride_journey_backdrop.dart';
import 'ride_journey_header.dart';
import 'ride_journey_shell.dart';
import 'ride_journey_stage.dart';
import 'ride_location_access_prompt.dart';
import 'ride_map_point_panel.dart';

class RideJourneyBody extends StatelessWidget {
  const RideJourneyBody({
    super.key,
    required this.step,
    required this.draft,
    required this.location,
    required this.pickingPickup,
    required this.onBack,
    required this.onPickup,
    required this.onDestination,
    required this.onSelected,
    required this.onContinue,
    required this.onMapPoint,
    required this.onMapPickup,
    required this.onMapDestination,
    required this.onClearPoint,
    this.onLocate,
    this.onSettings,
    this.savedAddressPickerBuilder,
  });
  final RideJourneyStep step;
  final RideDraftState draft;
  final RideLocationState location;
  final bool pickingPickup;
  final VoidCallback onBack, onPickup, onDestination, onClearPoint;
  final VoidCallback? onContinue, onLocate, onSettings;
  final ValueChanged<TripLocation> onSelected, onMapPickup, onMapDestination;
  final ValueChanged<GeoPoint> onMapPoint;
  final Widget Function(ValueChanged<TripLocation>)? savedAddressPickerBuilder;

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    final selecting = location.point != null;
    final title = switch (step) {
      RideJourneyStep.entry => t.rideRequestProgressPlan,
      RideJourneyStep.places =>
        pickingPickup ? t.rideRequestPickup : t.rideRequestDestination,
      RideJourneyStep.vehicle => t.rideRequestProgressVehicle,
    };
    return LayoutBuilder(
      builder: (context, bounds) {
        final scale = MediaQuery.textScalerOf(context).scale(14) / 14;
        final entryHeight =
            350 +
            (scale - 1) * 180 +
            (location.locating
                ? 32
                : location.failure != null
                ? 68
                : 0);
        final extent = selecting
            ? .64
            : switch (step) {
                RideJourneyStep.entry => (entryHeight / bounds.maxHeight).clamp(
                  .30,
                  .85,
                ),
                RideJourneyStep.places => .70,
                RideJourneyStep.vehicle => .67,
              };
        return RideJourneyShell(
          stageKey: selecting ? 'map-selection' : (step, pickingPickup),
          preferredExtent: extent,
          maximumExtent: !selecting && step == RideJourneyStep.vehicle
              ? .67
              : null,
          expandOnChange: location.point,
          collapsedLabel: selecting
              ? t.rideRequestMapPointTitle
              : draft.destination?.label ?? t.rideRequestFlowStartTitle,
          header: RideJourneyHeader(
            step: step.index + 1,
            label: title,
            onBack: onBack,
          ),
          mapBuilder: (inset) => RideJourneyBackdrop(
            pickup: draft.pickup,
            destination: draft.destination,
            selection: location.point,
            bottomInset: inset,
            onSelected: draft.confirmationPending ? null : onMapPoint,
            onLocate: draft.confirmationPending ? null : onLocate,
            locating: location.locating,
            focus: location.focusPoint != null && location.focusRevision > 0
                ? MapCameraFocus(location.focusPoint!, location.focusRevision)
                : null,
          ),
          panelBuilder: (collapse) => selecting
              ? RideMapPointPanel(
                  point: location.point!,
                  initialPickup:
                      step == RideJourneyStep.places && pickingPickup,
                  address: location.address,
                  resolving: location.resolving,
                  onPickup: onMapPickup,
                  onDestination: onMapDestination,
                  onClose: onClearPoint,
                )
              : RideJourneyStage(
                  step: step,
                  state: draft,
                  pickingPickup: pickingPickup,
                  onPickup: onPickup,
                  onDestination: onDestination,
                  onSelected: onSelected,
                  onPickOnMap: collapse,
                  onContinue: onContinue,
                  locationStatus: location.locating || location.failure != null
                      ? RideLocationStatus(
                          locating: location.locating,
                          failure: location.failure,
                          onRetry: onLocate,
                          onSettings: onSettings,
                        )
                      : null,
                  savedAddressPickerBuilder: savedAddressPickerBuilder,
                ),
        );
      },
    );
  }
}
