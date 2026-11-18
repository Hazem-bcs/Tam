import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tam_customer/app/router/customer_navigation.dart';
import 'package:tam_customer/app/theme/app_tokens.dart';
import 'package:tam_customer/features/active_trip/presentation/bloc/active_trip_cubit.dart';
import 'package:tam_customer/features/active_trip/presentation/widgets/active_trip_display.dart';
import 'package:tam_customer/l10n/app_localizations.dart';
import 'package:tam_customer/shared/domain/trip.dart';
import 'package:tam_customer/shared/widgets/tam_button.dart';

class ActiveTripActions extends StatelessWidget {
  const ActiveTripActions({
    super.key,
    required this.state,
    required this.navigation,
    this.compact = false,
  });

  final ActiveTripState state;
  final CustomerNavigation navigation;
  final bool compact;

  Future<void> _cancel(BuildContext context) async {
    final l = AppLocalizations.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        scrollable: true,
        title: Text(l.activeTripCancelTitle),
        content: Text(l.activeTripCancelPrompt),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: Text(l.activeTripKeep),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: Text(l.activeTripConfirmCancel),
          ),
        ],
      ),
    );
    if (confirmed == true && context.mounted) {
      await context.read<ActiveTripCubit>().cancel();
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final trip = state.trip!;
    final busy = state.cancelUncertain || state.cancelling;
    final colors = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (state.actionFailure != null) ...[
          Semantics(
            liveRegion: true,
            child: Text(
              activeTripError(l, state.actionFailure),
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: colors.error),
            ),
          ),
          const SizedBox(height: AppSpacing.md),
        ],
        if (state.cancelUncertain) ...[
          Text(l.activeTripCancelUncertain),
          const SizedBox(height: AppSpacing.sm),
          TamButton.primary(
            label: l.activeTripRetryCancel,
            isLoading: state.cancelling,
            loadingLabel: l.activeTripCancelling,
            onPressed: state.cancelling
                ? null
                : () => context.read<ActiveTripCubit>().cancel(),
          ),
        ],
        if (state.cancelling) const LinearProgressIndicator(),
        if (trip.status == TripStatus.completed) ...[
          TamButton.primary(
            key: const Key('active-completion'),
            label: l.activeTripCompletion,
            onPressed: () => navigation.openCompletion(trip.id),
          ),
          const SizedBox(height: AppSpacing.sm),
        ],
        if (state.canRebook &&
            (!compact || trip.status != TripStatus.completed)) ...[
          TamButton.primary(
            key: const Key('active-rebook'),
            label: l.activeTripRebook,
            onPressed: () => navigation.openRideRequest(
              prefill: TripPrefill(
                pickup: trip.booking.pickup,
                destination: trip.booking.destination,
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
        ],
        if (compact)
          OutlinedButton.icon(
            key: const Key('active-support'),
            onPressed: busy
                ? null
                : () => navigation.openSupport(tripId: trip.id),
            icon: Image.asset(
              'assets/notifications/support.webp',
              width: 24,
              height: 24,
              excludeFromSemantics: true,
            ),
            label: Text(
              l.activeTripSupport,
              style: Theme.of(context).textTheme.labelMedium,
            ),
          )
        else
          DecoratedBox(
            decoration: BoxDecoration(
              color: colors.surfaceContainerLowest,
              borderRadius: BorderRadius.circular(AppRadii.lg),
            ),
            child: ListTile(
              key: const Key('active-support'),
              contentPadding: const EdgeInsetsDirectional.symmetric(
                horizontal: AppSpacing.lg,
              ),
              leading: const Icon(Icons.support_agent_outlined),
              title: Text(l.activeTripSupport),
              trailing: const Icon(Icons.chevron_right_rounded),
              onTap: busy
                  ? null
                  : () => navigation.openSupport(tripId: trip.id),
            ),
          ),
        if (state.canCancel && !state.cancelUncertain) ...[
          const SizedBox(height: AppSpacing.md),
          OutlinedButton.icon(
            key: const Key('active-cancel'),
            onPressed: state.cancelling ? null : () => _cancel(context),
            icon: const Icon(Icons.close_rounded),
            label: Text(l.activeTripCancelTitle),
            style: OutlinedButton.styleFrom(foregroundColor: colors.error),
          ),
        ],
      ],
    );
  }
}
