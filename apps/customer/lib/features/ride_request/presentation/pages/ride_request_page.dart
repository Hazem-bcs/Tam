import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tam_customer/app/router/customer_navigation.dart';
import 'package:tam_customer/app/theme/app_tokens.dart';
import 'package:tam_customer/features/ride_request/presentation/bloc/ride_draft_bloc.dart';
import 'package:tam_customer/features/ride_request/presentation/widgets/ride_location_fields.dart';
import 'package:tam_customer/features/ride_request/presentation/widgets/ride_place_picker.dart';
import 'package:tam_customer/features/ride_request/presentation/widgets/ride_quote_review.dart';
import 'package:tam_customer/features/ride_request/presentation/widgets/ride_schedule_picker.dart';
import 'package:tam_customer/features/ride_request/presentation/widgets/ride_vehicle_picker.dart';
import 'package:tam_customer/features/ride_request/presentation/widgets/simulated_route_map.dart';
import 'package:tam_customer/l10n/app_localizations.dart';
import 'package:tam_customer/shared/domain/trip.dart';
import 'package:tam_customer/shared/widgets/tam_button.dart';
import 'package:tam_customer/shared/widgets/tam_card.dart';

class RideRequestPage extends StatelessWidget {
  const RideRequestPage({
    super.key,
    required this.navigation,
    this.savedAddressPickerBuilder,
  });

  final CustomerNavigation navigation;
  final Widget Function(ValueChanged<TripLocation>)? savedAddressPickerBuilder;

  Future<void> _pickLocation(
    BuildContext context, {
    required bool pickup,
  }) async {
    final bloc = context.read<RideDraftBloc>();
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (_) => BlocProvider.value(
        value: bloc,
        child: RidePlacePicker(
          pickup: pickup,
          savedAddressPickerBuilder: savedAddressPickerBuilder,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return BlocConsumer<RideDraftBloc, RideDraftState>(
      listenWhen: (previous, current) =>
          previous.confirmedTrip?.id != current.confirmedTrip?.id &&
          current.confirmedTrip != null,
      listener: (context, state) =>
          navigation.openActiveTrip(id: state.confirmedTrip!.id),
      builder: (context, state) {
        final locked = state.confirmationPending;
        final isConfirming = state.status == RideFlowStatus.confirming;
        final canConfirm =
            context.read<RideDraftBloc>().canConfirm ||
            (state.status == RideFlowStatus.failed &&
                state.failureStep == RideFailureStep.confirmation &&
                state.quote != null);
        return Scaffold(
          appBar: AppBar(title: Text(l.rideRequestTitle)),
          body: SafeArea(
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 760),
                child: ListView(
                  padding: AppSpacing.pagePadding,
                  children: [
                    RideLocationFields(
                      pickup: state.pickup,
                      destination: state.destination,
                      enabled: !locked,
                      onPickup: () => _pickLocation(context, pickup: true),
                      onDestination: () =>
                          _pickLocation(context, pickup: false),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    SimulatedRouteMap(hasRoute: state.hasRoute),
                    const SizedBox(height: AppSpacing.lg),
                    RideSchedulePicker(
                      scheduledAt: state.scheduledAt,
                      enabled: !locked,
                      policy: context.read<RideDraftBloc>().schedulePolicy,
                      now: () => context.read<RideDraftBloc>().currentTime,
                      onChanged: (time) => context.read<RideDraftBloc>().add(
                        RideScheduleChanged(time),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xl),
                    RideVehiclePicker(
                      selected: state.vehicleClass,
                      enabled: !locked,
                      onSelected: (vehicle) => context
                          .read<RideDraftBloc>()
                          .add(VehicleClassSelected(vehicle)),
                    ),
                    const SizedBox(height: AppSpacing.xl),
                    RideQuoteReview(
                      quote: state.quote,
                      loading: state.status == RideFlowStatus.quoting,
                    ),
                    if (state.errorCode != null) ...[
                      const SizedBox(height: AppSpacing.md),
                      _ErrorPanel(
                        text: _failureText(l, state.errorCode!),
                        retry: state.failureStep == RideFailureStep.quote
                            ? () => context.read<RideDraftBloc>().add(
                                const RideQuoteRequested(),
                              )
                            : null,
                      ),
                    ],
                    const SizedBox(height: AppSpacing.lg),
                    Text(
                      l.rideRequestSimulationNotice,
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          bottomNavigationBar: SafeArea(
            top: false,
            child: Center(
              heightFactor: 1,
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 760),
                child: Padding(
                  padding: const EdgeInsetsDirectional.fromSTEB(
                    AppSpacing.xl,
                    AppSpacing.sm,
                    AppSpacing.xl,
                    AppSpacing.md,
                  ),
                  child: TamButton.primary(
                    label: state.failureStep == RideFailureStep.confirmation
                        ? l.rideRequestRetry
                        : l.rideRequestConfirm,
                    loadingLabel: l.rideRequestConfirming,
                    isLoading: isConfirming,
                    onPressed: canConfirm
                        ? () => context.read<RideDraftBloc>().add(
                            const RideConfirmationRequested(),
                          )
                        : null,
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  String _failureText(AppLocalizations l, String code) => switch (code) {
    'VALIDATION_ERROR' => l.rideRequestErrorValidation,
    'QUOTE_EXPIRED' => l.rideRequestErrorExpired,
    'SERVICE_UNAVAILABLE' => l.rideRequestErrorUnavailable,
    'IDEMPOTENCY_CONFLICT' => l.rideRequestErrorConflict,
    'SCHEDULE_OUT_OF_RANGE' => l.rideRequestScheduleInvalid,
    'SCHEDULE_UNAVAILABLE' => l.rideRequestScheduleUnavailable,
    _ => l.rideRequestErrorGeneric,
  };
}

class _ErrorPanel extends StatelessWidget {
  const _ErrorPanel({required this.text, required this.retry});

  final String text;
  final VoidCallback? retry;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final l = AppLocalizations.of(context);
    return TamCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Icon(Icons.error_outline, color: colors.error),
              const SizedBox(width: AppSpacing.sm),
              Expanded(child: Text(text)),
            ],
          ),
          if (retry != null) ...[
            const SizedBox(height: AppSpacing.md),
            TamButton.secondary(
              label: l.rideRequestRefreshQuote,
              onPressed: retry,
            ),
          ],
        ],
      ),
    );
  }
}
