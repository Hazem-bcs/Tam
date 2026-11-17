import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tam_customer/app/router/customer_navigation.dart';
import 'package:tam_customer/app/theme/app_tokens.dart';
import 'package:tam_customer/app/theme/app_typography.dart';
import 'package:tam_customer/features/trips/presentation/bloc/trip_details_cubit.dart';
import 'package:tam_customer/features/trips/presentation/widgets/trip_details_actions.dart';
import 'package:tam_customer/features/trips/presentation/widgets/trip_details_body.dart';
import 'package:tam_customer/features/trips/presentation/widgets/trips_failure_banner.dart';
import 'package:tam_customer/l10n/app_localizations.dart';
import 'package:tam_customer/shared/presentation/trip_display.dart';
import 'package:tam_customer/shared/widgets/tam_button.dart';
import 'package:tam_customer/shared/widgets/tam_loading_indicator.dart';

class TripDetailsPage extends StatelessWidget {
  const TripDetailsPage({super.key, required this.navigation});
  final CustomerNavigation navigation;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final colors = Theme.of(context).colorScheme;
    final theme = Theme.of(context);
    return Theme(
      data: theme.copyWith(textTheme: AppTypography.home(theme.textTheme)),
      child: Scaffold(
        backgroundColor: colors.surface,
        appBar: AppBar(
          centerTitle: true,
          backgroundColor: colors.surface,
          foregroundColor: colors.onSurface,
          surfaceTintColor: colors.surface,
          title: Text(
            l.tripsDetailsTitle,
            style: AppTypography.home(
              theme.textTheme,
            ).titleLarge?.copyWith(fontSize: 17, fontWeight: FontWeight.w600),
          ),
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
        body: SafeArea(
          top: false,
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
              return Align(
                alignment: AlignmentDirectional.topCenter,
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 640),
                  child: SingleChildScrollView(
                    key: const Key('trips-details-scroll'),
                    padding: const EdgeInsetsDirectional.fromSTEB(
                      AppSpacing.lg,
                      AppSpacing.sm,
                      AppSpacing.lg,
                      AppSpacing.xxl,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        if (state.errorCode != null) ...[
                          TripsFailureBanner(
                            errorCode: state.errorCode!,
                            onRetry: () =>
                                context.read<TripDetailsCubit>().reload(),
                          ),
                          const SizedBox(height: AppSpacing.md),
                        ],
                        TripDetailsBody(trip: state.trip!),
                        const SizedBox(height: AppSpacing.lg),
                        TripDetailsActions(
                          trip: state.trip!,
                          state: state,
                          navigation: navigation,
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
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
