import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:tam_customer/app/theme/app_tokens.dart';
import 'package:tam_customer/features/ride_request/domain/ride_models.dart';
import 'package:tam_customer/l10n/app_localizations.dart';
import 'package:tam_customer/shared/widgets/tam_text_field.dart';
import 'ride_fare_format.dart';

class RideCouponField extends StatefulWidget {
  const RideCouponField({
    super.key,
    required this.code,
    required this.quote,
    required this.enabled,
    required this.loading,
    required this.invalid,
    required this.onApply,
    required this.onRemove,
  });
  final String? code;
  final RideQuote? quote;
  final bool enabled, loading, invalid;
  final ValueChanged<String> onApply;
  final VoidCallback onRemove;
  @override
  State<RideCouponField> createState() => _RideCouponFieldState();
}

class _RideCouponFieldState extends State<RideCouponField> {
  late final _text = TextEditingController(text: widget.code ?? '');
  @override
  void didUpdateWidget(RideCouponField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.code != widget.code) _text.text = widget.code ?? '';
  }

  @override
  void dispose() {
    _text.dispose();
    super.dispose();
  }

  void _apply() {
    if (!widget.enabled || widget.loading || _text.text.trim().isEmpty) return;
    FocusScope.of(context).unfocus();
    widget.onApply(_text.text);
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context), theme = Theme.of(context);
    final quote = widget.quote;
    final applied =
        widget.code != null &&
        quote?.couponCode == widget.code &&
        quote?.discount != null &&
        !widget.invalid;
    if (applied) {
      return Container(
        key: const Key('ride-coupon-applied'),
        decoration: BoxDecoration(
          color: theme.colorScheme.primaryContainer,
          borderRadius: BorderRadius.circular(AppRadii.lg),
          border: Border.all(
            color: theme.colorScheme.primary.withValues(alpha: .2),
          ),
        ),
        padding: const EdgeInsetsDirectional.all(AppSpacing.md),
        child: Row(
          children: [
            Image.asset(
              'assets/notifications/discount_offer.webp',
              width: 44,
              height: 44,
              excludeFromSemantics: true,
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(widget.code!, style: theme.textTheme.titleSmall),
                  Text(
                    l.rideRequestCouponSaving(
                      rideFareFormat(
                        quote!.discount!,
                        Localizations.localeOf(context).languageCode,
                      ),
                    ),
                    style: theme.textTheme.bodySmall,
                  ),
                ],
              ),
            ),
            IconButton(
              key: const Key('ride-coupon-remove'),
              tooltip: l.rideRequestRemoveCoupon,
              onPressed: widget.enabled ? widget.onRemove : null,
              icon: const Icon(Icons.close),
            ),
          ],
        ),
      );
    }
    final apply = TextButton(
      key: const Key('ride-coupon-apply'),
      onPressed:
          widget.enabled && !widget.loading && _text.text.trim().isNotEmpty
          ? _apply
          : null,
      child: Text(l.rideRequestApplyCoupon),
    );
    return LayoutBuilder(
      builder: (context, bounds) {
        final vertical =
            bounds.maxWidth < 400 &&
            MediaQuery.textScalerOf(context).scale(14) > 20;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TamTextField(
              key: const Key('ride-coupon-input'),
              controller: _text,
              labelText: l.rideRequestCoupon,
              hintText: l.rideRequestCouponHint,
              enabled: widget.enabled,
              textDirection: TextDirection.ltr,
              textInputAction: TextInputAction.done,
              prefixIcon: Padding(
                padding: const EdgeInsets.all(AppSpacing.sm),
                child: Image.asset(
                  'assets/notifications/discount_offer.webp',
                  width: 32,
                  height: 32,
                  excludeFromSemantics: true,
                ),
              ),
              suffixIcon: vertical
                  ? null
                  : Padding(
                      padding: const EdgeInsetsDirectional.only(
                        end: AppSpacing.xs,
                      ),
                      child: apply,
                    ),
              inputFormatters: [
                LengthLimitingTextInputFormatter(32),
                FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z0-9_-]')),
              ],
              onFieldSubmitted: (_) => _apply(),
              onChanged: (_) => setState(() {}),
              errorText: widget.invalid ? l.rideRequestCouponInvalid : null,
            ),
            if (vertical)
              Align(alignment: AlignmentDirectional.centerEnd, child: apply),
            if (widget.code != null)
              Align(
                alignment: AlignmentDirectional.centerStart,
                child: TextButton(
                  onPressed: widget.enabled ? widget.onRemove : null,
                  child: Text(l.rideRequestRemoveCoupon),
                ),
              ),
          ],
        );
      },
    );
  }
}
