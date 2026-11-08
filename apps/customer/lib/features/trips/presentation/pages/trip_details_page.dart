import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tam_customer/app/router/customer_navigation.dart';
import 'package:tam_customer/app/theme/app_tokens.dart';
import 'package:tam_customer/features/trips/presentation/bloc/trip_details_cubit.dart';
import 'package:tam_customer/features/trips/presentation/widgets/trip_details_body.dart';
import 'package:tam_customer/features/trips/presentation/widgets/trip_display.dart';
import 'package:tam_customer/l10n/app_localizations.dart';
import 'package:tam_customer/shared/domain/trip.dart';
import 'package:tam_customer/shared/widgets/tam_button.dart';
import 'package:tam_customer/shared/widgets/tam_loading_indicator.dart';

class TripDetailsPage extends StatelessWidget {
  const TripDetailsPage({super.key, required this.navigation});
  final CustomerNavigation navigation;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(l.tripsDetailsTitle),
        leading: IconButton(
          tooltip: MaterialLocalizations.of(context).backButtonTooltip,
          icon: const BackButtonIcon(),
          onPressed: () {
            if (Navigator.of(context).canPop()) {
              Navigator.of(context).pop();
            } else {
              navigation.openTrips();
            }
          },
        ),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 800),
          child: BlocBuilder<TripDetailsCubit, TripDetailsState>(
            builder: (context, state) {
              if (state.isLoading && state.trip == null) {
                return Center(
                  child: TamLoadingIndicator(
                    semanticLabel: l.tripsLoadingDetails,
                  ),
                );
              }
              if (state.errorCode != null && state.trip == null) {
                return _DetailsError(
                  title: l.tripsErrorTitle,
                  message: tripsErrorLabel(l, state.errorCode),
                  onRetry: () => context.read<TripDetailsCubit>().reload(),
                );
              }
              if (state.isNotFound || state.trip == null) {
                return _DetailsError(
                  title: l.tripsNotFoundTitle,
                  message: l.tripsNotFoundDescription,
                  onRetry: navigation.openTrips,
                  buttonLabel: l.tripsBackToList,
                );
              }
              return Column(
                children: [
                  Expanded(child: TripDetailsBody(trip: state.trip!)),
                  _TripActions(
                    trip: state.trip!,
                    state: state,
                    navigation: navigation,
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

class _TripActions extends StatelessWidget {
  const _TripActions({
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

class _DetailsError extends StatelessWidget {
  const _DetailsError({
    required this.title,
    required this.message,
    required this.onRetry,
    this.buttonLabel,
  });

  final String title;
  final String message;
  final String? buttonLabel;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final theme = Theme.of(context);
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.info_outline,
              size: 44,
              color: theme.colorScheme.primary,
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              title,
              style: theme.textTheme.titleLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(message, textAlign: TextAlign.center),
            const SizedBox(height: AppSpacing.lg),
            TamButton.secondary(
              label: buttonLabel ?? l.tripsRetry,
              fullWidth: false,
              onPressed: onRetry,
            ),
          ],
        ),
      ),
    );
  }
}
