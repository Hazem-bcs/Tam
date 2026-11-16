import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tam_customer/app/theme/app_tokens.dart';
import 'package:tam_customer/features/ride_request/presentation/bloc/ride_draft_bloc.dart';
import 'package:tam_customer/features/ride_request/presentation/widgets/ride_journey_entry.dart';
import 'package:tam_customer/features/ride_request/presentation/widgets/ride_journey_locations.dart';
import 'package:tam_customer/features/ride_request/presentation/widgets/ride_journey_sheet.dart';
import 'package:tam_customer/features/ride_request/presentation/widgets/ride_quote_review.dart';
import 'package:tam_customer/features/ride_request/presentation/widgets/ride_schedule_picker.dart';
import 'package:tam_customer/features/ride_request/presentation/widgets/ride_vehicle_picker.dart';
import 'package:tam_customer/l10n/app_localizations.dart';
import 'package:tam_customer/shared/domain/trip.dart';
import 'package:tam_customer/shared/widgets/tam_button.dart';

import 'ride_journey_place_sheet.dart';

enum RideJourneyStep { entry, places, vehicle, review }

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
    final t = AppLocalizations.of(context);
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
    final title = switch (step) {
      RideJourneyStep.entry => t.rideRequestFlowStartTitle,
      RideJourneyStep.places =>
        pickingPickup
            ? t.rideRequestFlowPickupTitle
            : t.rideRequestFlowDestinationTitle,
      RideJourneyStep.vehicle => t.rideRequestChooseClass,
      RideJourneyStep.review => t.rideRequestFlowReviewTitle,
    };
    return RideJourneySheet(
      title: title,
      subtitle: step == RideJourneyStep.entry
          ? t.rideRequestFlowStartSubtitle
          : step == RideJourneyStep.review
          ? t.rideRequestFlowReviewSubtitle
          : state.hasRoute
          ? '${state.pickup!.label} · ${state.destination!.label}'
          : t.rideRequestFlowChoosePlaces,
      actionLabel: switch (step) {
        RideJourneyStep.entry => t.rideRequestFlowStartAction,
        RideJourneyStep.places =>
          state.hasRoute
              ? t.rideRequestFlowContinue
              : t.rideRequestFlowChoosePlaces,
        RideJourneyStep.vehicle => t.rideRequestFlowContinue,
        RideJourneyStep.review =>
          state.failureStep == RideFailureStep.confirmation
              ? t.rideRequestRetry
              : t.rideRequestConfirm,
      },
      loading: state.status == RideFlowStatus.confirming,
      showAction: step != RideJourneyStep.places || state.hasRoute,
      loadingLabel: t.rideRequestConfirming,
      onContinue: onContinue,
      notice: step == RideJourneyStep.review
          ? t.rideRequestSimulationNotice
          : null,
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (locationStatus != null) ...[
            locationStatus!,
            const SizedBox(height: AppSpacing.md),
          ],
          switch (step) {
            RideJourneyStep.entry => RideJourneyLocations(
              pickup: state.pickup,
              destination: state.destination,
              onPickup: onPickup,
              onDestination: onDestination,
            ),
            RideJourneyStep.places => const SizedBox.shrink(),
            RideJourneyStep.vehicle => Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                RideVehiclePicker(
                  selected: state.vehicleClass,
                  showHeading: false,
                  enabled: !state.confirmationPending,
                  onSelected: (value) => context.read<RideDraftBloc>().add(
                    VehicleClassSelected(value),
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                RideSchedulePicker(
                  scheduledAt: state.scheduledAt,
                  enabled: !state.confirmationPending,
                  policy: context.read<RideDraftBloc>().schedulePolicy,
                  now: () => context.read<RideDraftBloc>().currentTime,
                  onChanged: (time) => context.read<RideDraftBloc>().add(
                    RideScheduleChanged(time),
                  ),
                ),
                if (state.status == RideFlowStatus.quoting) ...[
                  const SizedBox(height: AppSpacing.md),
                  LinearProgressIndicator(
                    semanticsLabel: t.rideRequestQuoteLoading,
                  ),
                ],
              ],
            ),
            RideJourneyStep.review => RideQuoteReview(
              quote: state.quote,
              loading: state.status == RideFlowStatus.quoting,
            ),
          },
          if (state.errorCode != null) ...[
            const SizedBox(height: AppSpacing.md),
            Semantics(
              liveRegion: true,
              child: Text(
                _failureText(t, state.errorCode!),
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.error,
                ),
              ),
            ),
            if (state.failureStep == RideFailureStep.quote)
              TamButton.secondary(
                label: t.rideRequestRefreshQuote,
                onPressed: () => context.read<RideDraftBloc>().add(
                  const RideQuoteRequested(),
                ),
              ),
          ],
        ],
      ),
    );
  }

  String _failureText(AppLocalizations t, String code) => switch (code) {
    'VALIDATION_ERROR' => t.rideRequestErrorValidation,
    'QUOTE_EXPIRED' => t.rideRequestErrorExpired,
    'SERVICE_UNAVAILABLE' => t.rideRequestErrorUnavailable,
    'IDEMPOTENCY_CONFLICT' => t.rideRequestErrorConflict,
    'SCHEDULE_OUT_OF_RANGE' => t.rideRequestScheduleInvalid,
    'SCHEDULE_UNAVAILABLE' => t.rideRequestScheduleUnavailable,
    _ => t.rideRequestErrorGeneric,
  };
}
