import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tam_customer/app/router/customer_navigation.dart';
import 'package:tam_customer/app/theme/app_tokens.dart';
import 'package:tam_customer/features/trips/presentation/bloc/trip_details_cubit.dart';
import 'package:tam_customer/l10n/app_localizations.dart';
import 'package:tam_customer/shared/domain/trip.dart';
import 'package:tam_customer/shared/presentation/trip_display.dart';
import 'package:tam_customer/shared/widgets/tam_button.dart';

/// Contextual actions are part of the page scroll, never three competing
/// sticky CTAs that hide the route and recorded fare.
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
    final colors = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    final available = !state.isCancelling;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (state.actionErrorCode != null) ...[
          Padding(
            padding: const EdgeInsetsDirectional.only(bottom: AppSpacing.sm),
            child: Text(
              tripsErrorLabel(l, state.actionErrorCode),
              style: text.bodyMedium?.copyWith(color: colors.error),
            ),
          ),
        ],
        if (trip.status.isActive) ...[
          _LargeAction(
            label: l.activeTripFollow,
            icon: Icons.route_outlined,
            onPressed: available
                ? () => navigation.openActiveTrip(id: trip.id)
                : null,
          ),
          const SizedBox(height: AppSpacing.sm),
        ],
        if (trip.status == TripStatus.completed) ...[
          _LargeAction(
            key: const Key('trips-completion'),
            label: l.tripsCompletion,
            icon: Icons.star_border_rounded,
            onPressed: () => navigation.openCompletion(trip.id),
          ),
          const SizedBox(height: AppSpacing.md),
        ],
        ConstrainedBox(
          constraints: const BoxConstraints(minHeight: 58),
          child: OutlinedButton(
            onPressed: available
                ? () => navigation.openRideRequest(
                    prefill: TripPrefill(
                      pickup: trip.booking.pickup,
                      destination: trip.booking.destination,
                    ),
                  )
                : null,
            style: OutlinedButton.styleFrom(
              foregroundColor: colors.primary,
              side: BorderSide(color: colors.primary, width: 1.3),
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.lg,
                vertical: AppSpacing.md,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(19),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.replay_rounded, size: 23),
                const SizedBox(width: AppSpacing.sm),
                Flexible(
                  child: Text(
                    l.tripsRebook,
                    textAlign: TextAlign.center,
                    style: text.titleSmall?.copyWith(
                      color: colors.primary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        Material(
          color: colors.surfaceContainerLowest,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(19),
            side: BorderSide(color: colors.outlineVariant),
          ),
          child: InkWell(
            key: const Key('trips-support'),
            borderRadius: BorderRadius.circular(19),
            onTap: available
                ? () => navigation.openSupport(tripId: trip.id)
                : null,
            child: Padding(
              padding: const EdgeInsetsDirectional.symmetric(
                horizontal: AppSpacing.lg,
                vertical: AppSpacing.md,
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.headset_mic_outlined,
                    size: 22,
                    color: colors.primary,
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Text(
                      l.tripsSupport,
                      style: text.titleSmall?.copyWith(
                        color: colors.onSurface,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  Icon(
                    Icons.arrow_forward_ios_rounded,
                    size: 16,
                    color: colors.onSurfaceVariant,
                  ),
                ],
              ),
            ),
          ),
        ),
        if (trip.canCancel) ...[
          const SizedBox(height: AppSpacing.md),
          TamButton.secondary(
            label: l.tripsCancel,
            isLoading: state.isCancelling,
            loadingLabel: l.tripsCancelling,
            onPressed: available ? () => _confirmCancel(context) : null,
          ),
        ],
      ],
    );
  }
}

class _LargeAction extends StatelessWidget {
  const _LargeAction({
    super.key,
    required this.label,
    required this.icon,
    required this.onPressed,
  });

  final String label;
  final IconData icon;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return ConstrainedBox(
      constraints: const BoxConstraints(minHeight: 60),
      child: FilledButton(
        onPressed: onPressed,
        style: FilledButton.styleFrom(
          backgroundColor: colors.primary,
          foregroundColor: colors.onPrimary,
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: AppSpacing.lg,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(19),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 23),
            const SizedBox(width: AppSpacing.sm),
            Flexible(
              child: Text(
                label,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  color: colors.onPrimary,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
