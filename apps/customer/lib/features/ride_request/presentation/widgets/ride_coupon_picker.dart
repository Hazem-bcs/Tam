import 'package:flutter/material.dart';
import 'package:tam_customer/app/theme/app_tokens.dart';
import 'package:tam_customer/features/ride_request/domain/ride_coupon_offer.dart';
import 'package:tam_customer/features/ride_request/domain/ride_models.dart';
import 'package:tam_customer/l10n/app_localizations.dart';

import 'ride_coupon_field.dart';

/// Offers appear here automatically; adding a code stays a focused dialog.
class RideCouponPicker extends StatelessWidget {
  const RideCouponPicker({
    super.key,
    required this.offers,
    required this.code,
    required this.quote,
    required this.enabled,
    required this.loading,
    required this.invalid,
    required this.onApply,
    required this.onRemove,
  });
  final List<RideCouponOffer> offers;
  final String? code;
  final RideQuote? quote;
  final bool enabled, loading, invalid;
  final ValueChanged<String> onApply;
  final VoidCallback onRemove;

  Future<void> _add(BuildContext context) async {
    final l = AppLocalizations.of(context);
    final value = await showDialog<String>(
      context: context,
      builder: (dialogContext) => Dialog(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 440),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppSpacing.xl),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    Image.asset(
                      'assets/notifications/discount_offer.webp',
                      width: 40,
                      height: 40,
                      excludeFromSemantics: true,
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: Text(
                        l.rideRequestAddCoupon,
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                    ),
                    IconButton(
                      tooltip: l.rideRequestScheduleCancel,
                      onPressed: () => Navigator.of(dialogContext).pop(),
                      icon: const Icon(Icons.close_rounded),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.lg),
                RideCouponField(
                  code: null,
                  quote: null,
                  enabled: true,
                  loading: false,
                  invalid: false,
                  onApply: (value) => Navigator.of(dialogContext).pop(value),
                  onRemove: () {},
                ),
              ],
            ),
          ),
        ),
      ),
    );
    if (context.mounted && value != null) onApply(value);
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context), theme = Theme.of(context);
    final applied = code != null && quote?.couponCode == code && !invalid;
    if (applied) {
      return RideCouponField(
        code: code,
        quote: quote,
        enabled: enabled,
        loading: loading,
        invalid: false,
        onApply: onApply,
        onRemove: onRemove,
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Image.asset(
              'assets/notifications/discount_offer.webp',
              width: 30,
              height: 30,
              excludeFromSemantics: true,
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Text(
                l.rideRequestCoupon,
                style: theme.textTheme.titleSmall,
              ),
            ),
            TextButton.icon(
              key: const Key('ride-coupon-add'),
              onPressed: enabled && !loading ? () => _add(context) : null,
              icon: const Icon(Icons.add_rounded, size: 18),
              label: Text(l.rideRequestAddCouponShort),
            ),
          ],
        ),
        if (offers.isNotEmpty)
          Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.xs,
            children: [
              for (final offer in offers)
                ActionChip(
                  key: ValueKey('ride-offer-${offer.code}'),
                  avatar: Icon(
                    Icons.local_offer_outlined,
                    size: 18,
                    color: theme.colorScheme.primary,
                  ),
                  label: Text(
                    l.rideRequestOfferLabel(offer.code, offer.percent),
                  ),
                  onPressed: enabled && !loading
                      ? () => onApply(offer.code)
                      : null,
                ),
            ],
          )
        else
          Text(
            l.rideRequestNoActiveCoupons,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        if (invalid) ...[
          Text(
            l.rideRequestCouponInvalid,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.error,
            ),
          ),
          TextButton(
            onPressed: enabled ? onRemove : null,
            child: Text(l.rideRequestRemoveCoupon),
          ),
        ],
      ],
    );
  }
}
