import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:tam_customer/app/theme/app_tokens.dart';
import 'package:tam_customer/features/ride_request/domain/ride_models.dart';
import 'package:tam_customer/l10n/app_localizations.dart';
import 'ride_animated_fare.dart';

/// One compact row keeps the fare, distance and duration visible together.
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
    return Padding(
      padding: const EdgeInsets.only(top: AppSpacing.sm),
      child: Container(
        padding: const EdgeInsets.symmetric(
          vertical: AppSpacing.sm,
          horizontal: AppSpacing.sm,
        ),
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceContainerLow,
          borderRadius: BorderRadius.circular(AppRadii.md),
        ),
        child: Column(
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  flex: 2,
                  child: Tooltip(
                    message: quote == null
                        ? l.rideRequestFareUnavailable
                        : l.rideRequestFareDisclaimer,
                    child: Column(
                      children: [
                        Text(
                          quote?.discount == null
                              ? l.rideRequestEstimatedFare
                              : l.rideRequestDiscountedFare,
                          style: theme.textTheme.labelSmall,
                          textAlign: TextAlign.center,
                        ),
                        RideAnimatedFare(value: quote?.fare, loading: loading),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
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
            if (loading)
              LinearProgressIndicator(
                semanticsLabel: l.rideRequestQuoteLoading,
              ),
          ],
        ),
      ),
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
            Icon(icon, size: 14, color: theme.colorScheme.onSurfaceVariant),
            const SizedBox(width: AppSpacing.xs),
            Flexible(child: Text(label, style: theme.textTheme.labelSmall)),
          ],
        ),
        Text(
          value,
          textAlign: TextAlign.center,
          style: theme.textTheme.labelLarge,
        ),
      ],
    );
  }
}
