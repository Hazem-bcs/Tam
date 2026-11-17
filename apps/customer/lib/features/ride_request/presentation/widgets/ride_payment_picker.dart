import 'package:flutter/material.dart';
import 'package:tam_customer/app/theme/app_tokens.dart';
import 'package:tam_customer/l10n/app_localizations.dart';
import 'package:tam_customer/shared/domain/trip.dart';

class RidePaymentPicker extends StatelessWidget {
  const RidePaymentPicker({
    super.key,
    required this.selected,
    required this.enabled,
    required this.onChanged,
  });
  final TripPaymentMethod selected;
  final bool enabled;
  final ValueChanged<TripPaymentMethod> onChanged;
  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context), theme = Theme.of(context);
    return LayoutBuilder(
      builder: (context, bounds) {
        final vertical =
            MediaQuery.textScalerOf(context).scale(14) > 20 ||
            bounds.maxWidth < 280;
        Widget choice(TripPaymentMethod method, String label, IconData icon) {
          final active = selected == method;
          return Semantics(
            selected: active,
            button: true,
            child: OutlinedButton(
              key: Key('ride-payment-${method.name}'),
              style: OutlinedButton.styleFrom(
                backgroundColor: active
                    ? theme.colorScheme.primaryContainer
                    : theme.colorScheme.surfaceContainerLowest,
                foregroundColor: active
                    ? theme.colorScheme.primary
                    : theme.colorScheme.onSurface,
                side: BorderSide(
                  color: active
                      ? theme.colorScheme.primary
                      : theme.colorScheme.outlineVariant,
                ),
              ),
              onPressed: enabled ? () => onChanged(method) : null,
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(icon, size: 20),
                    const SizedBox(width: AppSpacing.sm),
                    Flexible(child: Text(label, textAlign: TextAlign.center)),
                    if (active) ...[
                      const SizedBox(width: AppSpacing.xs),
                      const Icon(Icons.check, size: 16),
                    ],
                  ],
                ),
              ),
            ),
          );
        }

        final wallet = choice(
          TripPaymentMethod.wallet,
          l.rideRequestWallet,
          Icons.account_balance_wallet_outlined,
        );
        final cash = choice(
          TripPaymentMethod.cash,
          l.rideRequestCash,
          Icons.payments_outlined,
        );
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(l.rideRequestPayment, style: theme.textTheme.labelMedium),
            const SizedBox(height: AppSpacing.sm),
            if (vertical) ...[
              wallet,
              const SizedBox(height: AppSpacing.sm),
              cash,
            ] else
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(child: wallet),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(child: cash),
                ],
              ),
          ],
        );
      },
    );
  }
}
