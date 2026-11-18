import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tam_customer/app/router/customer_navigation.dart';
import 'package:tam_customer/app/theme/app_tokens.dart';
import 'package:tam_customer/features/active_trip/presentation/bloc/active_trip_cubit.dart';
import 'package:tam_customer/features/active_trip/presentation/widgets/active_driver_card.dart';
import 'package:tam_customer/features/active_trip/presentation/widgets/active_route_map.dart';
import 'package:tam_customer/features/active_trip/presentation/widgets/active_trip_actions.dart';
import 'package:tam_customer/features/active_trip/presentation/widgets/active_trip_display.dart';
import 'package:tam_customer/features/driver_contact/domain/driver_contact_repository.dart';
import 'package:tam_customer/l10n/app_localizations.dart';
import 'package:tam_customer/shared/formatters/ride_time_label.dart';
import 'package:tam_customer/shared/presentation/trip_display.dart';
import 'package:tam_customer/shared/widgets/tam_card.dart';
import 'package:tam_customer/shared/widgets/trip_route.dart';

/// Tracking is a journey, not a list of equally prominent action cards.
class ActiveTripOverview extends StatelessWidget {
  const ActiveTripOverview({
    super.key,
    required this.state,
    required this.navigation,
    this.showDemoAvatar = false,
  });

  final ActiveTripState state;
  final CustomerNavigation navigation;
  final bool showDemoAvatar;

  @override
  Widget build(BuildContext context) {
    final trip = state.trip!;
    final colors = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    final l = AppLocalizations.of(context);
    final driver = trip.live?.driver;
    final canCall =
        canContactDriver(trip) && !state.cancelUncertain && !state.cancelling;
    final eta = !state.offline && !state.positionStale
        ? trip.live?.etaSeconds
        : null;
    final onChat = driver == null ? null : () => navigation.openChat(trip.id);
    final onCall = driver == null || !canCall
        ? null
        : () => navigation.openDriverContact(trip.id, driver.id);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Semantics(
          liveRegion: true,
          child: Text(
            tripStatusLabel(l, trip.status),
            style: text.headlineSmall?.copyWith(fontWeight: FontWeight.w700),
          ),
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(
          activeTripDescription(l, trip.status),
          style: text.bodyMedium?.copyWith(color: colors.onSurfaceVariant),
        ),
        if (trip.booking.scheduledAt != null) ...[
          const SizedBox(height: AppSpacing.sm),
          Text(rideTimeLabel(context, trip.booking.scheduledAt!)),
        ],
        const SizedBox(height: AppSpacing.lg),
        if (state.offline) ...[
          TamCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    const Icon(Icons.cloud_off_outlined),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(child: Text(activeTripError(l, state.failure))),
                  ],
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(l.activeTripCached, style: text.bodySmall),
                TextButton.icon(
                  onPressed: state.refreshing ? null : () => _refresh(context),
                  icon: const Icon(Icons.refresh_rounded),
                  label: Text(l.activeTripRefresh),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.md),
        ],
        if (state.refreshing) const LinearProgressIndicator(),
        ClipRRect(
          borderRadius: BorderRadius.circular(AppRadii.sheet),
          child: ActiveRouteMap(
            trip: trip,
            stale: state.offline || state.positionStale,
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        DecoratedBox(
          decoration: BoxDecoration(
            color: colors.surfaceContainerLowest,
            borderRadius: BorderRadius.circular(AppRadii.lg),
          ),
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TripRoute(
                  pickup: trip.booking.pickup,
                  destination: trip.booking.destination,
                ),
                if (eta != null && eta > 0) ...[
                  const SizedBox(height: AppSpacing.md),
                  DecoratedBox(
                    decoration: BoxDecoration(
                      color: colors.primaryContainer,
                      borderRadius: BorderRadius.circular(AppRadii.md),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.md,
                        vertical: AppSpacing.sm,
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.schedule_rounded,
                            color: colors.onPrimaryContainer,
                          ),
                          const SizedBox(width: AppSpacing.sm),
                          Expanded(
                            child: Text(
                              l.activeTripEta((eta / 60).ceil()),
                              style: text.titleSmall?.copyWith(
                                color: colors.onPrimaryContainer,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
        if (driver != null) ...[
          const SizedBox(height: AppSpacing.md),
          ActiveDriverCard(driver: driver, showDemoAvatar: showDemoAvatar),
          const SizedBox(height: AppSpacing.sm),
          ActiveDriverContactBar(onChat: onChat!, onCall: onCall),
        ],
        const SizedBox(height: AppSpacing.lg),
        ActiveTripActions(state: state, navigation: navigation),
        const SizedBox(height: AppSpacing.lg),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              Icons.info_outline_rounded,
              size: 18,
              color: colors.onSurfaceVariant,
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Text(
                l.activeTripSimulationNotice,
                style: text.bodySmall?.copyWith(color: colors.onSurfaceVariant),
              ),
            ),
          ],
        ),
      ],
    );
  }

  void _refresh(BuildContext context) {
    context.read<ActiveTripCubit>().refresh();
  }
}
