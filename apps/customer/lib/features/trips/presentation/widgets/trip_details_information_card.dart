import 'package:flutter/material.dart';
import 'package:tam_customer/app/theme/app_tokens.dart';
import 'package:tam_customer/l10n/app_localizations.dart';
import 'package:tam_customer/shared/domain/trip.dart';
import 'package:tam_customer/shared/presentation/trip_display.dart';
import 'package:tam_customer/shared/widgets/tam_card.dart';

/// Stored fare is a recorded total, never proof that a payment was settled.
class TripDetailsInformationCard extends StatelessWidget {
  const TripDetailsInformationCard({super.key, required this.trip});
  final Trip trip;

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final wallet = trip.booking.paymentMethod == TripPaymentMethod.wallet;
    return TamCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Image.asset(
                'assets/notifications/payment.webp',
                width: 30,
                height: 30,
                excludeFromSemantics: true,
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Text(
                  t.tripsFareSection,
                  style: theme.textTheme.titleMedium,
                ),
              ),
            ],
          ),
          if (trip.booking.couponCode != null) ...[
            const SizedBox(height: AppSpacing.md),
            _ReceiptRow(
              label: t.rideRequestCoupon,
              value: trip.booking.couponCode!,
            ),
            Text(
              t.tripsDiscountUnrecorded,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
          const SizedBox(height: AppSpacing.lg),
          Container(
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: theme.colorScheme.primaryContainer.withValues(alpha: 0.65),
              borderRadius: BorderRadius.circular(AppRadii.md),
            ),
            child: Wrap(
              alignment: WrapAlignment.spaceBetween,
              crossAxisAlignment: WrapCrossAlignment.center,
              spacing: AppSpacing.md,
              runSpacing: AppSpacing.sm,
              children: [
                Text(t.tripsRecordedTotal, style: theme.textTheme.titleSmall),
                Text(
                  tripMoneyLabel(context, trip.booking.fare),
                  style: theme.textTheme.titleLarge?.copyWith(
                    color: theme.colorScheme.primary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Row(
            children: [
              Image.asset(
                'assets/notifications/${wallet ? 'wallet' : 'payment'}.webp',
                width: 28,
                height: 28,
                excludeFromSemantics: true,
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: _ReceiptRow(
                  label: t.rideRequestPayment,
                  value: wallet ? t.rideRequestWallet : t.rideRequestCash,
                ),
              ),
            ],
          ),
          const Divider(height: AppSpacing.xl),
          _ReceiptRow(
            label: t.tripsPaymentStatus,
            value: t.tripsPaymentUnconfirmed,
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            t.tripsFareNote,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

class _ReceiptRow extends StatelessWidget {
  const _ReceiptRow({required this.label, required this.value});
  final String label, value;
  @override
  Widget build(BuildContext context) => Row(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Expanded(
        child: Text(label, style: Theme.of(context).textTheme.bodyMedium),
      ),
      const SizedBox(width: AppSpacing.md),
      Flexible(
        child: Text(
          value,
          textAlign: TextAlign.end,
          style: Theme.of(
            context,
          ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
        ),
      ),
    ],
  );
}
