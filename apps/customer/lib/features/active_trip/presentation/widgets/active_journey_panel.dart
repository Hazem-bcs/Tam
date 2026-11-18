import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tam_customer/app/router/customer_navigation.dart';
import 'package:tam_customer/app/theme/app_tokens.dart';
import 'package:tam_customer/features/active_trip/presentation/bloc/active_trip_cubit.dart';
import 'package:tam_customer/features/driver_contact/domain/driver_contact_repository.dart';
import 'package:tam_customer/features/ride_request/presentation/widgets/ride_fare_format.dart';
import 'package:tam_customer/l10n/app_localizations.dart';
import 'package:tam_customer/shared/domain/trip.dart';
import 'package:tam_customer/shared/formatters/ride_time_label.dart';
import 'package:tam_customer/shared/presentation/trip_display.dart';
import 'package:tam_customer/shared/presentation/vehicle_marker_kind.dart';
import 'package:tam_customer/shared/widgets/tam_button.dart';
import 'package:tam_customer/shared/widgets/tam_loading_indicator.dart';

import 'active_driver_card.dart';
import 'active_matching_pulse.dart';
import 'active_trip_actions.dart';
import 'active_trip_display.dart';
import 'active_vehicle_badge.dart';

/// All live phases share this sheet and the already-mounted map behind it.
class ActiveJourneyPanel extends StatelessWidget {
  const ActiveJourneyPanel({
    super.key,
    required this.state,
    required this.navigation,
    this.showDemoAvatar = false,
    this.simulated = false,
  });
  final ActiveTripState state;
  final CustomerNavigation navigation;
  final bool showDemoAvatar, simulated;
  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context), theme = Theme.of(context);
    final trip = state.trip;
    if (trip == null) {
      return SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (state.phase == ActiveTripPhase.loading)
              TamLoadingIndicator(semanticLabel: l.activeTripLoading)
            else ...[
              Text(
                state.phase == ActiveTripPhase.failed
                    ? activeTripError(l, state.failure)
                    : l.activeTripEmpty,
                style: theme.textTheme.titleMedium,
              ),
              const SizedBox(height: AppSpacing.md),
              TamButton.secondary(
                label: l.activeTripRefresh,
                onPressed: () => context.read<ActiveTripCubit>().refresh(),
              ),
              if (state.phase == ActiveTripPhase.empty)
                TamButton.primary(
                  label: l.activeTripNewBooking,
                  onPressed: navigation.openRideRequest,
                ),
            ],
          ],
        ),
      );
    }
    final searching = trip.status == TripStatus.requested;
    final driver = trip.live?.driver;
    final canContact =
        canContactDriver(trip) &&
        !state.offline &&
        !state.cancelUncertain &&
        !state.cancelling;
    final eta = state.offline || state.positionStale
        ? null
        : trip.live?.etaSeconds;
    return SingleChildScrollView(
      key: const Key('active-trip-scroll'),
      padding: const EdgeInsetsDirectional.fromSTEB(
        AppSpacing.lg,
        0,
        AppSpacing.lg,
        AppSpacing.md,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (searching) const ActiveMatchingPulse(),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Semantics(
                  liveRegion: true,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        searching
                            ? l.rideRequestProgressMatching
                            : tripStatusLabel(l, trip.status),
                        style: theme.textTheme.titleLarge,
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        activeTripDescription(l, trip.status),
                        style: theme.textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
              ),
              if (!searching)
                Padding(
                  padding: const EdgeInsetsDirectional.only(
                    start: AppSpacing.sm,
                  ),
                  child: ActiveVehicleBadge(
                    status: trip.status,
                    kind: VehicleMarkerKind.fromClassId(
                      trip.booking.vehicleClassId,
                    ),
                  ),
                ),
            ],
          ),
          if (eta != null && eta > 0) ...[
            const SizedBox(height: AppSpacing.sm),
            Row(
              children: [
                Icon(
                  Icons.schedule_rounded,
                  size: 18,
                  color: theme.colorScheme.primary,
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Text(
                    l.activeTripEta((eta / 60).ceil()),
                    style: theme.textTheme.labelLarge,
                  ),
                ),
              ],
            ),
          ],
          if (trip.booking.scheduledAt != null) ...[
            const SizedBox(height: AppSpacing.sm),
            Text(
              rideTimeLabel(context, trip.booking.scheduledAt!),
              style: theme.textTheme.bodySmall,
            ),
          ],
          const SizedBox(height: AppSpacing.md),
          if (state.failure != null ||
              state.offline ||
              state.positionStale) ...[
            Row(
              children: [
                Icon(
                  Icons.cloud_off_outlined,
                  color: theme.colorScheme.error,
                  size: 20,
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Text(
                    state.failure == 'ROUTING_UNAVAILABLE'
                        ? l.mapsRouteFailed
                        : state.offline
                        ? l.activeTripCached
                        : l.activeTripPositionStale,
                    style: theme.textTheme.bodySmall,
                  ),
                ),
                TextButton(
                  onPressed: state.refreshing
                      ? null
                      : () => context.read<ActiveTripCubit>().refresh(),
                  child: Text(l.activeTripRefresh),
                ),
              ],
            ),
          ],
          if (driver != null) ...[
            ActiveDriverCard(
              driver: driver,
              showDemoAvatar: showDemoAvatar,
              vehicleKind: VehicleMarkerKind.fromClassId(
                trip.booking.vehicleClassId,
              ),
            ),
            ActiveDriverContactBar(
              onChat: () => navigation.openChat(trip.id),
              onCall: canContact
                  ? () => navigation.openDriverContact(trip.id, driver.id)
                  : null,
            ),
            const SizedBox(height: AppSpacing.sm),
          ],
          DecoratedBox(
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainerLow,
              borderRadius: BorderRadius.circular(AppRadii.md),
            ),
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.sm),
              child: Row(
                children: [
                  Image.asset(
                    'assets/notifications/${trip.booking.paymentMethod == TripPaymentMethod.wallet ? 'wallet' : 'payment'}.webp',
                    width: 28,
                    height: 28,
                    excludeFromSemantics: true,
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Text(
                      trip.booking.paymentMethod == TripPaymentMethod.wallet
                          ? l.rideRequestWallet
                          : l.rideRequestCash,
                      style: theme.textTheme.bodySmall,
                    ),
                  ),
                  Flexible(
                    child: Text(
                      '${rideFareFormat(trip.booking.fare, Localizations.localeOf(context).languageCode)} ${l.rideRequestCurrencySyp}',
                      style: theme.textTheme.titleSmall,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          ActiveTripActions(
            state: state,
            navigation: navigation,
            compact: true,
          ),
          if (simulated) ...[
            const SizedBox(height: AppSpacing.sm),
            Text(
              l.activeTripSimulationNotice,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
