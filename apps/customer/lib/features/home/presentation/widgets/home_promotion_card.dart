import 'package:flutter/material.dart';
import 'package:tam_customer/app/theme/app_tokens.dart';
import 'package:tam_customer/features/home/domain/entities/home_content.dart';
import 'package:tam_customer/l10n/app_localizations.dart';
import 'package:tam_customer/shared/widgets/tam_card.dart';

/// Promotion text and action come entirely from HomeContent.
/// The curved line is abstract brand artwork, never a simulated route/map.
class HomePromotionCard extends StatelessWidget {
  const HomePromotionCard({
    super.key,
    required this.promotion,
    required this.onRideRequest,
  });

  final HomePromotion promotion;
  final VoidCallback onRideRequest;

  @override
  Widget build(BuildContext context) {
    final language = Localizations.localeOf(context).languageCode;
    final action =
        promotion.enabled && promotion.action == HomeAction.rideRequest
        ? onRideRequest
        : null;
    if (promotion.kind == HomePromotionKind.hero) {
      return _HomeJourneyArtwork(
        promotion: promotion,
        onTap: action,
        language: language,
      );
    }
    return _HomeAnnouncement(
      promotion: promotion,
      onTap: action,
      language: language,
    );
  }
}

class _HomeJourneyArtwork extends StatelessWidget {
  const _HomeJourneyArtwork({
    required this.promotion,
    required this.onTap,
    required this.language,
  });

  final HomePromotion promotion;
  final VoidCallback? onTap;
  final String language;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final reduceMotion = MediaQuery.disableAnimationsOf(context);
    return Material(
      color: colors.primary,
      borderRadius: BorderRadius.circular(AppRadii.sheet),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Stack(
          children: [
            Positioned.fill(
              child: TweenAnimationBuilder<double>(
                tween: Tween<double>(begin: 0, end: 1),
                duration: reduceMotion ? Duration.zero : AppMotion.long,
                curve: AppMotion.easeOut,
                builder: (context, progress, child) => CustomPaint(
                  painter: _JourneyLinePainter(
                    line: colors.onPrimary.withValues(alpha: 0.45),
                    glow: colors.onPrimary.withValues(alpha: 0.08),
                    progress: progress,
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsetsDirectional.fromSTEB(
                AppSpacing.xl,
                AppSpacing.xl,
                AppSpacing.xl,
                AppSpacing.lg,
              ),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final largeText =
                      MediaQuery.textScalerOf(context).scale(16) > 24;
                  final artworkHeight = largeText ? 50.0 : 92.0;
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            height: 42,
                            width: 42,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: colors.onPrimary.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(AppRadii.md),
                              border: Border.all(
                                color: colors.onPrimary.withValues(alpha: 0.18),
                              ),
                            ),
                            child: Icon(
                              Icons.route_rounded,
                              color: colors.onPrimary,
                            ),
                          ),
                          const Spacer(),
                          Icon(
                            Icons.north_east_rounded,
                            textDirection: TextDirection.ltr,
                            color: colors.onPrimary,
                          ),
                        ],
                      ),
                      SizedBox(height: artworkHeight),
                      Text(
                        promotion.title.forLanguage(language),
                        style: theme.textTheme.headlineMedium?.copyWith(
                          color: colors.onPrimary,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      Text(
                        promotion.subtitle.forLanguage(language),
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: colors.onPrimary.withValues(alpha: 0.86),
                        ),
                      ),
                      const SizedBox(height: AppSpacing.lg),
                      Container(
                        width: 36,
                        height: 3,
                        decoration: BoxDecoration(
                          color: colors.onPrimary,
                          borderRadius: BorderRadius.circular(AppRadii.sm),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HomeAnnouncement extends StatelessWidget {
  const _HomeAnnouncement({
    required this.promotion,
    required this.onTap,
    required this.language,
  });

  final HomePromotion promotion;
  final VoidCallback? onTap;
  final String language;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    return TamCard(
      onTap: onTap,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: colors.tertiaryContainer,
              borderRadius: BorderRadius.circular(AppRadii.md),
            ),
            child: Icon(Icons.auto_awesome_outlined, color: colors.tertiary),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  promotion.title.forLanguage(language),
                  style: theme.textTheme.titleMedium,
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  promotion.subtitle.forLanguage(language),
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: colors.onSurfaceVariant,
                  ),
                ),
                if (!promotion.enabled) ...[
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    l.homeComingSoon,
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: colors.primary,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _JourneyLinePainter extends CustomPainter {
  const _JourneyLinePainter({
    required this.line,
    required this.glow,
    required this.progress,
  });

  final Color line;
  final Color glow;
  final double progress;

  @override
  void paint(Canvas canvas, Size size) {
    final path = Path()
      ..moveTo(-size.width * 0.1, size.height * 0.54)
      ..cubicTo(
        size.width * 0.15,
        size.height * 0.07,
        size.width * 0.48,
        size.height * 0.80,
        size.width * 0.66,
        size.height * 0.28,
      )
      ..quadraticBezierTo(
        size.width * 0.82,
        size.height * 0.03,
        size.width * 1.06,
        size.height * 0.40,
      );
    final metric = path.computeMetrics().first;
    final painted = metric.extractPath(0, metric.length * progress);
    canvas.drawPath(
      painted,
      Paint()
        ..color = glow
        ..style = PaintingStyle.stroke
        ..strokeWidth = 24
        ..strokeCap = StrokeCap.round,
    );
    canvas.drawPath(
      painted,
      Paint()
        ..color = line
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.5
        ..strokeCap = StrokeCap.round,
    );
    final endpoint = metric.getTangentForOffset(metric.length * progress);
    if (endpoint != null) {
      canvas.drawCircle(endpoint.position, 9, Paint()..color = glow);
      canvas.drawCircle(endpoint.position, 4, Paint()..color = line);
    }
  }

  @override
  bool shouldRepaint(covariant _JourneyLinePainter old) =>
      line != old.line || glow != old.glow || progress != old.progress;
}
