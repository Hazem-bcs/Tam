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
    final added = await showCouponEntrySheet(context, book: book);
    if (added && context.mounted) {
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
        toolbarHeight: 70,
        centerTitle: true,
        elevation: 0,
        scrolledUnderElevation: 0,
        backgroundColor: colors.surface,
        title: Text(
          t.settingsCouponsTitle,
          style: type.titleLarge?.copyWith(
            color: colors.onSurface,
            fontWeight: FontWeight.w800,
          ),
        ),
        leadingWidth: 64,
        leading: Padding(
          padding: const EdgeInsetsDirectional.only(start: AppSpacing.md),
          child: Center(
            child: SizedBox(
              width: 44,
              height: 44,
              child: IconButton(
                key: const Key('coupons-back'),
                tooltip: MaterialLocalizations.of(context).backButtonTooltip,
                style: IconButton.styleFrom(
                  backgroundColor: colors.primaryContainer.withValues(
                    alpha: .55,
                  ),
                  foregroundColor: colors.primary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppRadii.md),
                  ),
                ),
                icon: SizedBox(
                  width: 19,
                  height: 24,
                  child: CustomPaint(
                    key: const Key('coupons-ios-chevron'),
                    painter: _IosChevronPainter(
                      color: colors.primary,
                      pointsRight:
                          Directionality.of(context) == TextDirection.rtl,
                    ),
                  ),
                ),
                onPressed: () => Navigator.pop(context),
              ),
            ),
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsetsDirectional.only(end: AppSpacing.lg),
            child: Image.asset(
              'assets/notifications/discount_offer.webp',
              width: 40,
              height: 40,
              fit: BoxFit.contain,
              excludeFromSemantics: true,
            ),
          ),
        ],
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
                        style: TextButton.styleFrom(
                          foregroundColor: colors.primary,
                          backgroundColor: colors.primaryContainer.withValues(
                            alpha: .64,
                          ),
                          padding: const EdgeInsetsDirectional.symmetric(
                            horizontal: AppSpacing.md,
                            vertical: AppSpacing.sm,
                          ),
                          shape: const StadiumBorder(),
                        ),
                        onPressed: () => _openAddSheet(context),
                        icon: const Icon(Icons.add_rounded, size: 20),
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

/// Cupertino-style back stroke without an icon-font dependency.
class _IosChevronPainter extends CustomPainter {
  const _IosChevronPainter({required this.color, required this.pointsRight});

  final Color color;
  final bool pointsRight;

  @override
  void paint(Canvas canvas, Size size) {
    final outerX = pointsRight ? 3.5 : size.width - 3.5;
    final pointX = pointsRight ? size.width - 3.5 : 3.5;
    final path = Path()
      ..moveTo(outerX, 3)
      ..lineTo(pointX, size.height / 2)
      ..lineTo(outerX, size.height - 3);
    canvas.drawPath(
      path,
      Paint()
        ..color = color
        ..strokeWidth = 2.4
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round
        ..style = PaintingStyle.stroke
        ..isAntiAlias = true,
    );
  }

  @override
  bool shouldRepaint(covariant _IosChevronPainter old) =>
      old.color != color || old.pointsRight != pointsRight;
}
