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
    final colors = theme.colorScheme;
    return LayoutBuilder(
      builder: (context, bounds) {
        final vertical =
            MediaQuery.textScalerOf(context).scale(14) > 20 ||
            bounds.maxWidth < 280;
        Widget choice(TripPaymentMethod method, String label) {
          final active = selected == method;
          return Semantics(
            selected: active,
            button: true,
            child: Material(
              color: active
                  ? colors.primaryContainer
                  : colors.surfaceContainerLow,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppRadii.lg),
                side: BorderSide(
                  color: active
                      ? colors.primary
                      : colors.outlineVariant.withValues(alpha: .5),
                ),
              ),
              clipBehavior: Clip.antiAlias,
              child: InkWell(
                key: Key('ride-payment-${method.name}'),
                onTap: enabled ? () => onChanged(method) : null,
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.sm),
                  child: Row(
                    children: [
                      if (method == TripPaymentMethod.wallet)
                        Image.asset(
                          'assets/notifications/wallet.webp',
                          width: 32,
                          height: 32,
                          excludeFromSemantics: true,
                        )
                      else
                        SizedBox(
                          width: 32,
                          height: 32,
                          child: Icon(
                            Icons.payments_rounded,
                            size: 26,
                            color: colors.primary,
                          ),
                        ),
                      const SizedBox(width: AppSpacing.sm),
                      Expanded(
                        child: Text(
                          label,
                          style: theme.textTheme.labelLarge?.copyWith(
                            color: active ? colors.primary : colors.onSurface,
                          ),
                        ),
                      ),
                      const SizedBox(width: AppSpacing.xs),
                      Icon(
                        active
                            ? Icons.check_circle_rounded
                            : Icons.radio_button_unchecked_rounded,
                        size: 18,
                        color: active ? colors.primary : colors.outline,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        }

        final wallet = choice(TripPaymentMethod.wallet, l.rideRequestWallet);
        final cash = choice(TripPaymentMethod.cash, l.rideRequestCash);
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
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
