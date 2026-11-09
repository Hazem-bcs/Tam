import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tam_customer/app/router/customer_navigation.dart';
import 'package:tam_customer/app/theme/app_tokens.dart';
import 'package:tam_customer/features/trips/presentation/bloc/trip_details_cubit.dart';
import 'package:tam_customer/l10n/app_localizations.dart';
import 'package:tam_customer/shared/domain/trip.dart';
import 'package:tam_customer/shared/presentation/trip_display.dart';
import 'package:tam_customer/shared/widgets/tam_button.dart';

class TripDetailsActions extends StatelessWidget {
  const TripDetailsActions({
    super.key,
    required this.trip,
    required this.state,
    required this.navigation,
  });

  final Trip trip;
  final TripDetailsState state;
  final CustomerNavigation navigation;

  Future<void> _confirmCancel(BuildContext context) async {
    if (!trip.canCancel || state.isCancelling) return;
    final l = AppLocalizations.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(l.tripsCancelTitle),
        content: Text(l.tripsCancelPrompt),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: Text(l.tripsKeepTrip),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: Text(l.tripsConfirmCancel),
          ),
        ],
      ),
    );
    if (confirmed != true || !context.mounted) return;
    final success = await context.read<TripDetailsCubit>().cancel();
    if (success && context.mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l.tripsCancelledSuccess)));
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsetsDirectional.fromSTEB(
          AppSpacing.lg,
          AppSpacing.sm,
          AppSpacing.lg,
          AppSpacing.lg,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (state.actionErrorCode != null) ...[
              Text(
                tripsErrorLabel(l, state.actionErrorCode),
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.error,
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
            ],
            if (trip.status.isActive) ...[
              TamButton.primary(
                label: l.activeTripFollow,
                onPressed: state.isCancelling
                    ? null
                    : () => navigation.openActiveTrip(id: trip.id),
              ),
              const SizedBox(height: AppSpacing.sm),
            ],
            if (trip.status == TripStatus.completed) ...[
              TamButton.primary(
                key: const Key('trips-completion'),
                label: l.tripsCompletion,
                onPressed: () => navigation.openCompletion(trip.id),
              ),
              const SizedBox(height: AppSpacing.sm),
            ],
            TamButton.primary(
              label: l.tripsRebook,
              icon: Icons.replay,
              onPressed: state.isCancelling
                  ? null
                  : () {
                      navigation.openRideRequest(
                        prefill: TripPrefill(
                          pickup: trip.booking.pickup,
                          destination: trip.booking.destination,
                        ),
                      );
                    },
            ),
            const SizedBox(height: AppSpacing.sm),
            TamButton.secondary(
              key: const Key('trips-support'),
              label: l.tripsSupport,
              onPressed: state.isCancelling
                  ? null
                  : () => navigation.openSupport(tripId: trip.id),
            ),
            if (trip.canCancel) ...[
              const SizedBox(height: AppSpacing.sm),
              TamButton.secondary(
                label: l.tripsCancel,
                isLoading: state.isCancelling,
                loadingLabel: l.tripsCancelling,
                onPressed: state.isCancelling
                    ? null
                    : () => _confirmCancel(context),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
