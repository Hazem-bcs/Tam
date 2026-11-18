import 'package:flutter/material.dart';
import 'package:tam_customer/app/theme/app_tokens.dart';
import 'package:tam_customer/features/settings/data/mock/mock_coupon_book.dart';
import 'package:tam_customer/features/settings/presentation/coupon_book_scope.dart';
import 'package:tam_customer/features/settings/presentation/widgets/coupon_entry_sheet.dart';
import 'package:tam_customer/l10n/app_localizations.dart';
import 'package:tam_customer/shared/widgets/tam_snack_bar.dart';

/// Opens the shared demo coupon-entry flow without silently applying a fare discount.
class HomeCouponBanner extends StatelessWidget {
  const HomeCouponBanner({super.key});

  Future<void> _openAddCode(BuildContext context) async {
    final sharedBook = CouponBookScope.maybeOf(context);
    final book = sharedBook ?? MockCouponBook();
    try {
      final added = await showCouponEntrySheet(context, book: book);
      if (added && context.mounted) {
        TamSnackBar.show(
          context,
          message: AppLocalizations.of(context).settingsCouponsAdded,
          tone: TamSnackBarTone.success,
        );
      }
    } finally {
      // Standalone widget tests can render Home without an app scope.
      if (sharedBook == null) book.dispose();
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context), theme = Theme.of(context);
    return Material(
      color: theme.colorScheme.primaryContainer,
      borderRadius: BorderRadius.circular(AppRadii.lg),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        key: const Key('home-coupon-details'),
        onTap: () => _openAddCode(context),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Row(
            children: [
              Image.asset(
                'assets/notifications/discount_offer.webp',
                width: 36,
                height: 36,
                excludeFromSemantics: true,
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                flex: 3,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l.homeCouponTitle,
                      style: theme.textTheme.titleSmall?.copyWith(
                        color: theme.colorScheme.primary,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    Text(
                      l.homeCouponHint,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onPrimaryContainer,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Flexible(
                child: Text(
                  l.homeCouponDetails,
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: theme.colorScheme.primary,
                  ),
                ),
              ),
              Icon(
                Directionality.of(context) == TextDirection.rtl
                    ? Icons.chevron_left
                    : Icons.chevron_right,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
