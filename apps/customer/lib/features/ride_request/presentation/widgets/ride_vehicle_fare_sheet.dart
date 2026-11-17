import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tam_customer/app/theme/app_tokens.dart';
import 'package:tam_customer/features/ride_request/presentation/bloc/ride_draft_bloc.dart';
import 'package:tam_customer/l10n/app_localizations.dart';
import 'package:tam_customer/shared/widgets/tam_button.dart';
import 'ride_coupon_field.dart';
import 'ride_journey_sheet.dart';
import 'ride_payment_picker.dart';
import 'ride_quote_review.dart';
import 'ride_schedule_picker.dart';
import 'ride_vehicle_picker.dart';

class RideVehicleFareSheet extends StatelessWidget {
  const RideVehicleFareSheet({
    super.key,
    required this.state,
    this.onContinue,
    this.locationStatus,
  });
  final RideDraftState state;
  final VoidCallback? onContinue;
  final Widget? locationStatus;
  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final bloc = context.read<RideDraftBloc>();
    final enabled = !state.confirmationPending;
    final quoting = state.status == RideFlowStatus.quoting;
    return RideJourneySheet(
      edgeToEdgeContent: true,
      compact: true,
      header: Row(
        children: [
          Expanded(
            child: Text(
              l.rideRequestChooseClass,
              style: Theme.of(context).textTheme.titleSmall,
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Flexible(
            flex: 2,
            child: RideSchedulePicker(
              compact: true,
              scheduledAt: state.scheduledAt,
              enabled: enabled,
              policy: bloc.schedulePolicy,
              now: () => bloc.currentTime,
              onChanged: (time) => bloc.add(RideScheduleChanged(time)),
            ),
          ),
        ],
      ),
      title: l.rideRequestChooseClass,
      subtitle: l.rideRequestLivePriceHint,
      actionLabel: state.failureStep == RideFailureStep.confirmation
          ? l.rideRequestRetry
          : l.rideRequestConfirm,
      loading: state.status == RideFlowStatus.confirming,
      loadingLabel: l.rideRequestConfirming,
      onContinue: onContinue,
      notice: l.rideRequestSimulationNotice,
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (locationStatus != null)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
              child: locationStatus!,
            ),
          RideVehiclePicker(
            selected: state.vehicleClass,
            showHeading: false,
            enabled: enabled,
            quotes: state.vehicleQuotes,
            onSelected: (value) => bloc.add(VehicleClassSelected(value)),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                RideQuoteReview(quote: state.quote, loading: quoting),
                const SizedBox(height: AppSpacing.sm),
                RidePaymentPicker(
                  selected: state.paymentMethod,
                  enabled: enabled,
                  onChanged: (value) => bloc.add(RidePaymentChanged(value)),
                ),
                const SizedBox(height: AppSpacing.sm),
                RideCouponField(
                  code: state.couponCode,
                  quote: state.quote,
                  enabled: enabled,
                  loading: quoting,
                  invalid: state.errorCode == 'COUPON_INVALID',
                  onApply: (code) => bloc.add(RideCouponApplied(code)),
                  onRemove: () => bloc.add(const RideCouponRemoved()),
                ),
                if (state.errorCode != null &&
                    state.errorCode != 'COUPON_INVALID') ...[
                  const SizedBox(height: AppSpacing.sm),
                  Semantics(
                    liveRegion: true,
                    child: Text(
                      _failure(l, state.errorCode!),
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.error,
                      ),
                    ),
                  ),
                ],
                if (state.failureStep == RideFailureStep.quote &&
                    state.errorCode != 'COUPON_INVALID')
                  TamButton.secondary(
                    label: l.rideRequestRefreshQuote,
                    onPressed: enabled
                        ? () => bloc.add(const RideQuoteRequested())
                        : null,
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _failure(AppLocalizations l, String code) => switch (code) {
    'VALIDATION_ERROR' => l.rideRequestErrorValidation,
    'QUOTE_EXPIRED' => l.rideRequestErrorExpired,
    'SERVICE_UNAVAILABLE' => l.rideRequestErrorUnavailable,
    'IDEMPOTENCY_CONFLICT' => l.rideRequestErrorConflict,
    'SCHEDULE_OUT_OF_RANGE' => l.rideRequestScheduleInvalid,
    'SCHEDULE_UNAVAILABLE' => l.rideRequestScheduleUnavailable,
    'PAYMENT_UNAVAILABLE' => l.rideRequestPaymentUnavailable,
    'WALLET_INSUFFICIENT' => l.rideRequestWalletInsufficient,
    _ => l.rideRequestErrorGeneric,
  };
}
