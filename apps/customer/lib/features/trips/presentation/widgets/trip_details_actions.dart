import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tam_customer/app/router/customer_navigation.dart';
import 'package:tam_customer/app/theme/app_tokens.dart';
import 'package:tam_customer/features/trips/presentation/bloc/trip_details_cubit.dart';
import 'package:tam_customer/l10n/app_localizations.dart';
import 'package:tam_customer/shared/domain/trip.dart';
import 'package:tam_customer/shared/presentation/trip_display.dart';
import 'package:tam_customer/shared/widgets/tam_button.dart';

/// One strong action. Rating and help stay easy to reach but visually quiet.
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
          _PrimaryTripAction(
            icon: Icons.route_outlined,
            label: l.activeTripFollow,
            onPressed: enabled
                ? () => navigation.openActiveTrip(id: trip.id)
                : null,
          ),
          const SizedBox(height: AppSpacing.sm),
        ],
        _PrimaryTripAction(
          icon: Icons.replay_rounded,
          label: l.tripsRebook,
          onPressed: enabled
              ? () => navigation.openRideRequest(
                  prefill: TripPrefill(
                    pickup: trip.booking.pickup,
                    destination: trip.booking.destination,
                  ),
                )
              : null,
          quiet: true,
        ),
        const SizedBox(height: AppSpacing.sm),
        if (trip.status == TripStatus.completed) ...[
          _ActionLink(
            key: const Key('trips-completion'),
            icon: Icons.star_outline_rounded,
            label: l.tripsRateAction,
            onTap: () => navigation.openCompletion(trip.id),
          ),
        ],
        TamButton.primary(
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

class _PrimaryTripAction extends StatelessWidget {
  const _PrimaryTripAction({
    required this.icon,
    required this.label,
    required this.onPressed,
    this.quiet = false,
  });
  final IconData icon;
  final String label;
  final VoidCallback? onPressed;
  final bool quiet;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final type = Theme.of(context).textTheme;
    return SizedBox(
      width: double.infinity,
      child: FilledButton(
        onPressed: onPressed,
        style: FilledButton.styleFrom(
          minimumSize: const Size(0, 52),
          backgroundColor: quiet ? colors.primaryContainer : colors.primary,
          foregroundColor: quiet ? colors.primary : colors.onPrimary,
          elevation: 0,
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: AppSpacing.md,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 19),
            const SizedBox(width: AppSpacing.sm),
            Flexible(
              child: Text(
                label,
                textAlign: TextAlign.center,
                style: type.labelLarge?.copyWith(
                  color: quiet ? colors.primary : colors.onPrimary,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ActionLink extends StatelessWidget {
  const _ActionLink({
    super.key,
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Material(
      type: MaterialType.transparency,
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: 48),
          child: Padding(
            padding: const EdgeInsetsDirectional.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.sm,
            ),
            child: Row(
              children: [
                Image.asset(
                  icon == Icons.headset_mic_outlined
                      ? 'assets/notifications/support.webp'
                      : 'assets/notifications/rating.webp',
                  width: 30,
                  height: 30,
                  excludeFromSemantics: true,
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Text(
                    label,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: colors.onSurface,
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                Icon(
                  Directionality.of(context) == TextDirection.rtl
                      ? Icons.chevron_left_rounded
                      : Icons.chevron_right_rounded,
                  color: colors.onSurfaceVariant,
                  size: 20,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
