import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:tam_customer/app/theme/app_tokens.dart';
import 'package:tam_customer/features/ride_request/domain/ride_models.dart';
import 'package:tam_customer/features/ride_request/presentation/widgets/ride_vehicle_picker.dart';
import 'package:tam_customer/l10n/app_localizations.dart';
import 'package:tam_customer/shared/formatters/ride_time_label.dart';
import 'package:tam_customer/shared/widgets/tam_card.dart';

class RideQuoteReview extends StatelessWidget {
  const RideQuoteReview({
    super.key,
    required this.quote,
    required this.loading,
  });

  final RideQuote? quote;
  final bool loading;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final locale = Localizations.localeOf(context).languageCode;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(l.rideRequestQuoteTitle, style: theme.textTheme.titleMedium),
        const SizedBox(height: AppSpacing.md),
        TamCard(
          child: loading
              ? Row(
                  children: [
                    const CircularProgressIndicator(),
                    const SizedBox(width: AppSpacing.md),
                    Flexible(child: Text(l.rideRequestQuoteLoading)),
                  ],
                )
              : quote == null
              ? Text(l.rideRequestRouteHint)
              : Wrap(
                  alignment: WrapAlignment.spaceBetween,
                  spacing: AppSpacing.lg,
                  runSpacing: AppSpacing.lg,
                  children: [
                    _Stat(
                      title: l.rideRequestDistance,
                      value:
                          '${(quote!.distanceMeters / 1000).toStringAsFixed(1)} ${l.rideRequestKm}',
                    ),
                    _Stat(
                      title: l.rideRequestDuration,
                      value: '${quote!.durationMinutes} ${l.rideRequestMinute}',
                    ),
                    _Stat(
                      title: l.rideRequestFare,
                      value:
                          '${_formatMoney(quote!.fare.amountMinor, quote!.fare.minorUnit, locale)} ${l.rideRequestCurrencySyp}',
                      highlighted: true,
                    ),
                  ],
                ),
        ),
        const SizedBox(height: AppSpacing.xl),
        Text(l.rideRequestReview, style: theme.textTheme.titleMedium),
        const SizedBox(height: AppSpacing.md),
        TamCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _ReviewLine(
                label: l.rideRequestPickup,
                value: quote?.pickup.label ?? '—',
              ),
              const SizedBox(height: AppSpacing.md),
              _ReviewLine(
                label: l.rideRequestDestination,
                value: quote?.destination.label ?? '—',
              ),
              const Divider(),
              if (quote != null) ...[
                _ReviewLine(
                  label: l.tripsVehicleClass,
                  value: RideVehiclePicker.labelFor(l, quote!.vehicleClass),
                ),
                const SizedBox(height: AppSpacing.md),
              ],
              _ReviewLine(
                label: l.rideRequestScheduleTime,
                value: quote?.scheduledAt == null
                    ? l.rideRequestImmediate
                    : rideTimeLabel(context, quote!.scheduledAt!),
              ),
              const SizedBox(height: AppSpacing.md),
              _ReviewLine(
                label: l.rideRequestPayment,
                value: l.rideRequestCash,
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                l.rideRequestCashOnly,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  static String _formatMoney(int minor, int minorUnit, String locale) {
    final scale = List.filled(minorUnit, 10).fold<int>(1, (a, b) => a * b);
    final integerPart = NumberFormat.decimalPattern(
      locale,
    ).format(minor ~/ scale);
    if (minorUnit == 0) return integerPart;
    final fractional = (minor % scale).toString().padLeft(minorUnit, '0');
    return '$integerPart.$fractional';
  }
}

class _Stat extends StatelessWidget {
  const _Stat({
    required this.title,
    required this.value,
    this.highlighted = false,
  });
  final String title;
  final String value;
  final bool highlighted;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ConstrainedBox(
      constraints: const BoxConstraints(minWidth: 88),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: theme.textTheme.labelSmall),
          const SizedBox(height: AppSpacing.xs),
          Text(
            value,
            style: theme.textTheme.titleSmall?.copyWith(
              color: highlighted ? theme.colorScheme.primary : null,
            ),
          ),
        ],
      ),
    );
  }
}

class _ReviewLine extends StatelessWidget {
  const _ReviewLine({required this.label, required this.value});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(flex: 2, child: Text(label, style: theme.textTheme.bodySmall)),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          flex: 3,
          child: Text(value, style: theme.textTheme.bodyMedium),
        ),
      ],
    );
  }
}
