import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tam_customer/app/router/customer_navigation.dart';
import 'package:tam_customer/app/theme/app_tokens.dart';
import 'package:tam_customer/features/trips/presentation/bloc/trip_details_cubit.dart';
import 'package:tam_customer/l10n/app_localizations.dart';
import 'package:tam_customer/shared/domain/trip.dart';
import 'package:tam_customer/shared/presentation/trip_display.dart';
import 'package:tam_customer/shared/widgets/tam_button.dart';
import 'package:tam_customer/shared/widgets/tam_snack_bar.dart';

/// One strong action. Rating and help stay easy to reach but visually quiet.
class TripDetailsActions extends StatelessWidget {
  const TripDetailsActions({
    super.key,
    required this.trip,
    required this.state,
    required this.navigation,
    this.showSupport = true,
  });

  final bool showSupport;
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
      TamSnackBar.show(
        context,
        message: l.tripsCancelledSuccess,
        tone: TamSnackBarTone.success,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final colors = Theme.of(context).colorScheme;
    final enabled = !state.isCancelling;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (state.actionErrorCode != null) ...[
          Text(
            tripsErrorLabel(l, state.actionErrorCode),
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: colors.error),
          ),
          const SizedBox(height: AppSpacing.sm),
        ],
        if (trip.status.isActive) ...[
          TamButton.primary(
            icon: Icons.route_outlined,
            label: l.activeTripFollow,
            onPressed: enabled
                ? () => navigation.openActiveTrip(id: trip.id)
                : null,
          ),
          const SizedBox(height: AppSpacing.sm),
        ],
        if (showSupport)
          TamButton.secondary(
            key: const Key('trips-support'),
            icon: Icons.headset_mic_outlined,
            label: l.tripsSupportAction,
            onPressed: enabled
                ? () => navigation.openSupport(tripId: trip.id)
                : null,
          ),
        if (trip.canCancel) ...[
          const SizedBox(height: AppSpacing.sm),
          TamButton.secondary(
            label: l.tripsCancel,
            isLoading: state.isCancelling,
            loadingLabel: l.tripsCancelling,
            onPressed: enabled ? () => _confirmCancel(context) : null,
          ),
        ],
      ],
    );
  }
}
