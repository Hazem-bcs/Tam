import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:tam_customer/app/theme/app_theme.dart';
import 'package:tam_customer/app/theme/app_tokens.dart';
import 'package:tam_customer/features/settings/data/mock/mock_coupon_book.dart';
import 'package:tam_customer/l10n/app_localizations.dart';
import 'package:tam_customer/shared/widgets/tam_button.dart';

/// The same sheet is used from Home and from the coupon collection in Account.
Future<bool> showCouponEntrySheet(
  BuildContext context, {
  required MockCouponBook book,
}) async {
  final sheetTheme = AppTheme.account(Theme.of(context));
  final result = await showModalBottomSheet<bool>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    showDragHandle: true,
    backgroundColor: sheetTheme.colorScheme.surfaceContainerLowest,
    constraints: const BoxConstraints(maxWidth: 580),
    builder: (_) => Theme(
      data: sheetTheme,
      child: CouponEntrySheet(book: book),
    ),
  );
  return result ?? false;
}

class CouponEntrySheet extends StatefulWidget {
  const CouponEntrySheet({super.key, required this.book});

  final MockCouponBook book;

  @override
  State<CouponEntrySheet> createState() => _CouponEntrySheetState();
}

class _CouponEntrySheetState extends State<CouponEntrySheet> {
  final _controller = TextEditingController();
  String? _error;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _addCoupon() {
    final t = AppLocalizations.of(context);
    final result = widget.book.add(_controller.text);
    switch (result) {
      case AddDemoCouponResult.added:
        Navigator.pop(context, true);
      case AddDemoCouponResult.duplicate:
        setState(() => _error = t.settingsCouponsDuplicate);
      case AddDemoCouponResult.invalid:
        setState(() => _error = t.settingsCouponsInvalid);
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    final colors = Theme.of(context).colorScheme;
    final theme = Theme.of(context);
    return Padding(
      padding: EdgeInsetsDirectional.only(
        start: AppSpacing.xl,
        end: AppSpacing.xl,
        bottom: MediaQuery.viewInsetsOf(context).bottom + AppSpacing.xl,
      ),
      child: SafeArea(
        top: false,
        child: SingleChildScrollView(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 490),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Align(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: colors.primaryContainer,
                      borderRadius: BorderRadius.circular(AppRadii.lg),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(AppSpacing.lg),
                      child: Image.asset(
                        'assets/notifications/discount_offer.webp',
                        width: 55,
                        height: 55,
                        fit: BoxFit.contain,
                        excludeFromSemantics: true,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),
                Text(
                  t.settingsCouponsSheetTitle,
                  textAlign: TextAlign.center,
                  style: theme.textTheme.titleLarge,
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  t.settingsCouponsSheetDescription,
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: colors.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: AppSpacing.xl),
                TextField(
                  key: const Key('coupon-code-input'),
                  controller: _controller,
                  textDirection: TextDirection.ltr,
                  textCapitalization: TextCapitalization.characters,
                  autocorrect: false,
                  maxLength: 32,
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z0-9_-]')),
                  ],
                  decoration: InputDecoration(
                    labelText: t.settingsCouponsCode,
                    hintText: t.settingsCouponsHint,
                    errorText: _error,
                    prefixIcon: Padding(
                      padding: const EdgeInsets.all(AppSpacing.sm),
                      child: Image.asset(
                        'assets/notifications/discount_offer.webp',
                        width: 28,
                        height: 28,
                        fit: BoxFit.contain,
                        excludeFromSemantics: true,
                      ),
                    ),
                  ),
                  onChanged: (_) {
                    if (_error != null) setState(() => _error = null);
                  },
                  onSubmitted: (_) => _addCoupon(),
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  t.settingsCouponsDemoHelp,
                  textAlign: TextAlign.start,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colors.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),
                Row(
                  children: [
                    Expanded(
                      child: TamButton.primary(
                        label: t.settingsCouponsConfirm,
                        onPressed: _addCoupon,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: TamButton.secondary(
                        label: t.settingsCancel,
                        onPressed: () => Navigator.pop(context, false),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
