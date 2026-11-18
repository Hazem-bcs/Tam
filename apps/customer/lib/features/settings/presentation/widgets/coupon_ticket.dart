import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart' show DateFormat;
import 'package:tam_customer/app/theme/app_tokens.dart';
import 'package:tam_customer/features/settings/data/mock/mock_coupon_book.dart';
import 'package:tam_customer/l10n/app_localizations.dart';
import 'package:tam_customer/shared/domain/coupon_code.dart';
import 'package:tam_customer/shared/widgets/tam_snack_bar.dart';

import 'coupon_ticket_shape.dart';

/// Restrained ticket artwork, using TAM's semantic colors instead of a new palette.
class CouponTicket extends StatelessWidget {
  const CouponTicket({super.key, required this.offer});

  final DemoCoupon offer;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final scale = MediaQuery.textScalerOf(context).scale(1);
    return LayoutBuilder(
      builder: (context, constraints) {
        final stacked = constraints.maxWidth < 315 || scale > 1.55;
        final clipper = CouponTicketClipper(
          isRtl: Directionality.of(context) == TextDirection.rtl,
          horizontalSplit: !stacked,
        );
        return CustomPaint(
          foregroundPainter: CouponTicketOutlinePainter(
            color: colors.outlineVariant,
            clipper: clipper,
          ),
          child: ClipPath(
            key: const Key('coupon-ticket-cutout'),
            clipper: clipper,
            child: Material(
              color: colors.surfaceContainerLowest,
              child: stacked
                  ? Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _DiscountPanel(offer: offer, horizontal: true),
                        const _TicketDivider(horizontal: true),
                        _CouponInformation(offer: offer),
                      ],
                    )
                  : IntrinsicHeight(
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          SizedBox(
                            width: 112,
                            child: _DiscountPanel(offer: offer),
                          ),
                          const _TicketDivider(horizontal: false),
                          Expanded(child: _CouponInformation(offer: offer)),
                        ],
                      ),
                    ),
            ),
          ),
        );
      },
    );
  }
}

class _DiscountPanel extends StatelessWidget {
  const _DiscountPanel({required this.offer, this.horizontal = false});
  final DemoCoupon offer;
  final bool horizontal;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final t = AppLocalizations.of(context);
    final label = offer.isAvailable
        ? t.settingsCouponsAvailable
        : t.settingsCouponsExpired;
    final status = Text(
      label,
      textAlign: TextAlign.center,
      style: theme.textTheme.labelSmall?.copyWith(
        color: offer.isAvailable ? colors.primary : colors.onSurfaceVariant,
        fontWeight: FontWeight.w700,
      ),
    );
    return ColoredBox(
      color: offer.isAvailable
          ? colors.primaryContainer
          : colors.surfaceContainerLow,
      child: Padding(
        padding: const EdgeInsetsDirectional.symmetric(
          horizontal: AppSpacing.sm,
          vertical: AppSpacing.lg,
        ),
        child: horizontal
            ? Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _Percent(offer: offer),
                  Flexible(child: status),
                ],
              )
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _Percent(offer: offer),
                  const SizedBox(height: AppSpacing.sm),
                  status,
                ],
              ),
      ),
    );
  }
}

class _Percent extends StatelessWidget {
  const _Percent({required this.offer});
  final DemoCoupon offer;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    return Text(
      '${offer.percent}%',
      textDirection: TextDirection.ltr,
      style: theme.textTheme.headlineLarge?.copyWith(
        fontWeight: FontWeight.w800,
        color: offer.isAvailable ? colors.primary : colors.onSurfaceVariant,
      ),
    );
  }
}

class _TicketDivider extends StatelessWidget {
  const _TicketDivider({required this.horizontal});
  final bool horizontal;

  @override
  Widget build(BuildContext context) => CustomPaint(
    painter: _DashedDivider(
      Theme.of(context).colorScheme.outlineVariant,
      horizontal,
    ),
    child: SizedBox(
      width: horizontal ? null : 1,
      height: horizontal ? 1 : null,
    ),
  );
}

class _DashedDivider extends CustomPainter {
  const _DashedDivider(this.color, this.horizontal);
  final Color color;
  final bool horizontal;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1.5;
    final extent = horizontal ? size.width : size.height;
    for (var offset = 0.0; offset < extent; offset += 11) {
      final end = (offset + 5).clamp(0.0, extent);
      if (horizontal) {
        canvas.drawLine(Offset(offset, 0), Offset(end, 0), paint);
      } else {
        canvas.drawLine(Offset(0, offset), Offset(0, end), paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant _DashedDivider old) =>
      old.color != color || old.horizontal != horizontal;
}

class _CouponInformation extends StatelessWidget {
  const _CouponInformation({required this.offer});
  final DemoCoupon offer;

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final expiry = offer.expiresAt;
    final date = expiry == null
        ? null
        : DateFormat.yMd(
            Localizations.localeOf(context).languageCode,
          ).format(expiry);
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Image.asset(
                'assets/notifications/discount_offer.webp',
                width: 27,
                height: 27,
                fit: BoxFit.contain,
                excludeFromSemantics: true,
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Text(
                  offer.code,
                  textDirection: couponCodeIsRtl(offer.code)
                      ? TextDirection.rtl
                      : TextDirection.ltr,
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: colors.onSurface,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
          if (offer.remainingTrips != null) ...[
            const SizedBox(height: AppSpacing.sm),
            _MetaLine(
              icon: Icons.directions_car_outlined,
              asset: 'assets/images/ride_car.webp',
              label: t.settingsCouponsTrips(
                '${offer.remainingTrips}/${offer.totalTrips}',
              ),
            ),
          ],
          if (date != null) ...[
            const SizedBox(height: AppSpacing.sm),
            _MetaLine(
              icon: Icons.event_outlined,
              label: t.settingsCouponsExpiry(date),
            ),
          ],
          if (offer.isAvailable) ...[
            const SizedBox(height: AppSpacing.sm),
            Align(
              alignment: AlignmentDirectional.centerStart,
              child: TextButton.icon(
                key: const Key('coupon-copy'),
                onPressed: () async {
                  await Clipboard.setData(ClipboardData(text: offer.code));
                  if (context.mounted) {
                    TamSnackBar.show(
                      context,
                      message: t.settingsCouponsCopied,
                      tone: TamSnackBarTone.success,
                    );
                  }
                },
                icon: const Icon(Icons.copy_rounded, size: 17),
                label: Text(t.settingsCouponsCopy),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _MetaLine extends StatelessWidget {
  const _MetaLine({required this.icon, required this.label, this.asset});
  final IconData icon;
  final String label;
  final String? asset;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (asset == null)
          Icon(icon, size: 17, color: theme.colorScheme.onSurfaceVariant)
        else
          Image.asset(
            asset!,
            width: 24,
            height: 19,
            fit: BoxFit.contain,
            excludeFromSemantics: true,
          ),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: Text(
            label,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ),
      ],
    );
  }
}
