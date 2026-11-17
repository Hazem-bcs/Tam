import 'package:flutter/material.dart';
import 'package:tam_customer/app/theme/app_tokens.dart';
import 'package:tam_customer/features/settings/data/mock/mock_coupon_book.dart';
import 'package:tam_customer/features/settings/presentation/widgets/coupon_entry_sheet.dart';
import 'package:tam_customer/features/settings/presentation/widgets/coupon_ticket.dart';
import 'package:tam_customer/l10n/app_localizations.dart';

/// Coupon previews are strictly local to this session and are not backend offers.
class CouponsPage extends StatelessWidget {
  const CouponsPage({super.key, required this.book});

  final MockCouponBook book;

  Future<void> _openAddSheet(BuildContext context) async {
    final added = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      showDragHandle: true,
      backgroundColor: Theme.of(context).colorScheme.surfaceContainerLowest,
      constraints: const BoxConstraints(maxWidth: 580),
      builder: (context) => CouponEntrySheet(book: book),
    );
    if (added == true && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context).settingsCouponsAdded),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    final colors = Theme.of(context).colorScheme;
    final type = Theme.of(context).textTheme;
    return Scaffold(
      backgroundColor: colors.surface,
      appBar: AppBar(
        title: Text(t.settingsCouponsTitle),
        leading: IconButton(
          key: const Key('coupons-back'),
          tooltip: MaterialLocalizations.of(context).backButtonTooltip,
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 680),
            child: AnimatedBuilder(
              animation: book,
              builder: (context, _) => ListView(
                padding: AppSpacing.pagePadding,
                children: [
                  Wrap(
                    alignment: WrapAlignment.spaceBetween,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    spacing: AppSpacing.md,
                    runSpacing: AppSpacing.md,
                    children: [
                      Text(
                        t.settingsCouponsSubtitle,
                        style: type.bodyMedium?.copyWith(
                          color: colors.onSurfaceVariant,
                        ),
                      ),
                      TextButton.icon(
                        key: const Key('coupons-add'),
                        onPressed: () => _openAddSheet(context),
                        icon: const Icon(Icons.add_rounded),
                        label: Text(t.settingsCouponsAdd),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  DecoratedBox(
                    decoration: BoxDecoration(
                      color: colors.primaryContainer.withValues(alpha: .48),
                      borderRadius: BorderRadius.circular(AppRadii.md),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(AppSpacing.md),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(
                            Icons.info_outline_rounded,
                            size: 19,
                            color: colors.primary,
                          ),
                          const SizedBox(width: AppSpacing.sm),
                          Expanded(
                            child: Text(
                              t.settingsCouponsDemoNotice,
                              style: type.bodySmall?.copyWith(
                                color: colors.onSurface,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  for (final coupon in book.coupons) ...[
                    CouponTicket(
                      key: ValueKey('coupon-${coupon.code}'),
                      offer: coupon,
                    ),
                    const SizedBox(height: AppSpacing.md),
                  ],
                  Text(
                    t.settingsCouponsDemoHelp,
                    textAlign: TextAlign.center,
                    style: type.bodySmall?.copyWith(
                      color: colors.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xxl),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
