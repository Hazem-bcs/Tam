import 'package:flutter/material.dart';
import 'package:tam_customer/app/theme/app_tokens.dart';
import 'package:tam_customer/l10n/app_localizations.dart';
import 'address_visual_icon.dart';

/// A stylized location affordance, intentionally NOT a live map screenshot.
class AddressLocationSummary extends StatelessWidget {
  const AddressLocationSummary({
    super.key,
    required this.locationLabel,
    required this.onTap,
  });

  final String? locationLabel;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final t = AppLocalizations.of(context);

    return Material(
      key: const Key('address-choose-location'),
      color: colors.surfaceContainerLowest,
      borderRadius: BorderRadius.circular(AppRadii.sheet),
      clipBehavior: Clip.antiAlias,
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppRadii.sheet),
          border: Border.all(color: colors.outlineVariant),
        ),
        child: InkWell(
          onTap: onTap,
          child: Column(
            children: [
              SizedBox(
                height: 128,
                width: double.infinity,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Positioned.fill(
                      child: ExcludeSemantics(
                        child: CustomPaint(
                          painter: _AbstractStreetPainter(
                            ground: colors.primaryContainer.withValues(
                              alpha: 0.52,
                            ),
                            road: colors.surfaceContainerLowest.withValues(
                              alpha: 0.92,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const AddressPinArtwork(size: 80),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsetsDirectional.all(AppSpacing.md),
                child: Row(
                  children: [
                    Icon(Icons.place_outlined, color: colors.primary),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            t.addressesLocation,
                            style: theme.textTheme.labelLarge?.copyWith(
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const SizedBox(height: AppSpacing.xs),
                          Text(
                            locationLabel ?? t.addressesChooseLocation,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: colors.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Icon(
                      Icons.arrow_forward_ios_rounded,
                      size: 18,
                      color: colors.primary,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Purely abstract streets: no GPS/network data, no real cartographic claims.
class _AbstractStreetPainter extends CustomPainter {
  const _AbstractStreetPainter({required this.ground, required this.road});

  final Color ground, road;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRect(Offset.zero & size, Paint()..color = ground);
    final line = Paint()
      ..color = road
      ..style = PaintingStyle.stroke
      ..strokeWidth = 9
      ..strokeCap = StrokeCap.round;
    void street(double x, double y, double ex, double ey) {
      canvas.drawLine(
        Offset(size.width * x, size.height * y),
        Offset(size.width * ex, size.height * ey),
        line,
      );
    }

    street(-.06, .28, 1.05, .76);
    street(.12, -.12, .61, 1.13);
    street(.74, -.08, .33, 1.14);
    street(.02, .89, 1.06, .15);
    street(.31, -.1, .89, 1.13);
  }

  @override
  bool shouldRepaint(covariant _AbstractStreetPainter old) =>
      ground != old.ground || road != old.road;
}
