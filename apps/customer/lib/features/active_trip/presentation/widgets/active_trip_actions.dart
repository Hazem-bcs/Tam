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
  });
  final ActiveTripState state;
  final CustomerNavigation navigation;
  Future<void> _cancel(BuildContext context) async {
    final l = AppLocalizations.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        scrollable: true,
        title: Text(l.activeTripCancelTitle),
        content: Text(l.activeTripCancelPrompt),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(l.activeTripKeep),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (state.actionFailure != null) ...[
          Semantics(
            liveRegion: true,
            child: Text(
              activeTripError(l, state.actionFailure),
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.error,
              ),
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
        ] else if (state.canCancel)
          TamButton.secondary(
            key: const Key('active-cancel'),
            label: l.activeTripCancelTitle,
            onPressed: () => _cancel(context),
          ),
        if (state.cancelling) const LinearProgressIndicator(),
        if (state.canRebook) ...[
          const SizedBox(height: AppSpacing.md),
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
        ],
        const SizedBox(height: AppSpacing.md),
        TamButton.secondary(
          label: l.activeTripDetails,
          onPressed: state.cancelUncertain || state.cancelling
              ? null
              : () => navigation.openTrip(trip.id),
        ),
      ],
    );
  }
}
