import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:tam_customer/app/theme/app_tokens.dart';
import 'package:tam_customer/features/ride_request/domain/ride_models.dart';
import 'package:tam_customer/l10n/app_localizations.dart';
import 'ride_animated_fare.dart';
import 'ride_fare_format.dart';

/// The useful quote summary stays alongside the vehicle and payment choices.
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
    final l = AppLocalizations.of(context), theme = Theme.of(context);
    final locale = Localizations.localeOf(context).languageCode;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Divider(height: AppSpacing.xl),
        Text(
          quote?.discount == null
              ? l.rideRequestEstimatedFare
              : l.rideRequestDiscountedFare,
          textAlign: TextAlign.center,
          style: theme.textTheme.bodySmall,
        ),
        const SizedBox(height: AppSpacing.sm),
        RideAnimatedFare(value: quote?.fare, loading: loading),
        if (loading) ...[
          const SizedBox(height: AppSpacing.sm),
          LinearProgressIndicator(semanticsLabel: l.rideRequestQuoteLoading),
        ],
        const SizedBox(height: AppSpacing.sm),
        Text(
          loading
              ? l.rideRequestQuoteLoading
              : quote == null
              ? l.rideRequestFareUnavailable
              : l.rideRequestFareDisclaimer,
          textAlign: TextAlign.center,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        Container(
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            color: theme.colorScheme.surfaceContainerLow,
            borderRadius: BorderRadius.circular(AppRadii.md),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: _Stat(
                  icon: Icons.route_outlined,
                  label: l.rideRequestDistance,
                  value: quote == null
                      ? '—'
                      : '${NumberFormat.decimalPatternDigits(locale: locale, decimalDigits: 1).format(quote!.distanceMeters / 1000)} ${l.rideRequestKm}',
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: _Stat(
                  icon: Icons.schedule_outlined,
                  label: l.rideRequestDuration,
                  value: quote == null
                      ? '—'
                      : '${NumberFormat.decimalPattern(locale).format(quote!.durationMinutes)} ${l.rideRequestMinute}',
                ),
              ),
            ],
          ),
        ),
        if (quote?.discount != null)
          Padding(
            padding: const EdgeInsetsDirectional.only(top: AppSpacing.sm),
            child: Text(
              l.rideRequestCouponSaving(
                rideFareFormat(quote!.discount!, locale),
              ),
              textAlign: TextAlign.center,
              style: theme.textTheme.labelMedium?.copyWith(
                color: theme.colorScheme.primary,
              ),
            ),
          ),
      ],
    );
  }
}

class _Stat extends StatelessWidget {
  const _Stat({required this.icon, required this.label, required this.value});
  final IconData icon;
  final String label, value;
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 16, color: theme.colorScheme.onSurfaceVariant),
            const SizedBox(width: AppSpacing.xs),
            Flexible(child: Text(label, style: theme.textTheme.labelSmall)),
          ],
        ),
        Text(
          value,
          textAlign: TextAlign.center,
          style: theme.textTheme.titleSmall,
        ),
      ],
    );
  }
}
