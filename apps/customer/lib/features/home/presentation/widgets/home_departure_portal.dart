import 'package:flutter/material.dart';
import 'package:tam_customer/app/theme/app_tokens.dart';
import 'package:tam_customer/l10n/app_localizations.dart';

/// One departure surface, with a non-geographic direction sculpture.
/// Entrance animation runs once; press/focus uses native Material feedback.
class HomeDeparturePortal extends StatefulWidget {
  const HomeDeparturePortal({
    super.key,
    required this.onRideRequest,
    this.child,
  });

  final VoidCallback onRideRequest;
  final Widget? child;

  @override
  State<HomeDeparturePortal> createState() => _HomeDeparturePortalState();
}

class _HomeDeparturePortalState extends State<HomeDeparturePortal> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    if (widget.child != null) return widget.child!;
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final t = AppLocalizations.of(context);
    final reducedMotion = MediaQuery.disableAnimationsOf(context);
    return Material(
      color: colors.primary,
      borderRadius: const BorderRadius.all(Radius.circular(AppRadii.sheet)),
      clipBehavior: Clip.antiAlias,
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: TweenAnimationBuilder<double>(
          key: const Key('home-departure-reveal'),
          tween: Tween(begin: reducedMotion ? 1 : 0, end: 1),
          duration: reducedMotion ? Duration.zero : AppMotion.long,
          curve: AppMotion.easeOut,
          builder: (context, value, child) => Transform.translate(
            offset: Offset(0, (1 - value) * AppSpacing.md),
            child: Opacity(opacity: value, child: child),
          ),
          child: LayoutBuilder(
            builder: (context, bounds) {
              final heading = LayoutBuilder(
                builder: (context, bounds) {
                  final compact =
                      bounds.maxWidth < 290 ||
                      MediaQuery.textScalerOf(context).scale(16) > 24 ||
                      MediaQuery.sizeOf(context).height < 500;
                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Semantics(
                          header: true,
                          child: Text(
                            t.homeRideEntryTitle,
                            style: theme.textTheme.displayLarge?.copyWith(
                              color: colors.onPrimary,
                            ),
                          ),
                        ),
                      ),
                      if (!compact) ...[
                        const SizedBox(width: AppSpacing.md),
                        ExcludeSemantics(
                          child: RepaintBoundary(
                            child: CustomPaint(
                              size: const Size(92, 130),
                              painter: _DepartureSculpture(
                                face: colors.secondaryContainer,
                                edge: colors.onPrimary.withValues(alpha: 0.22),
                                rtl:
                                    Directionality.of(context) ==
                                    TextDirection.rtl,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ],
                  );
                },
              );
              final action = Align(
                alignment: AlignmentDirectional.centerStart,
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 480),
                  child: AnimatedScale(
                    scale: _pressed ? 0.98 : 1,
                    duration: reducedMotion ? Duration.zero : AppMotion.short,
                    curve: AppMotion.easeOut,
                    child: Material(
                      color: colors.surfaceContainerLowest,
                      borderRadius: BorderRadius.circular(AppRadii.lg),
                      clipBehavior: Clip.antiAlias,
                      child: InkWell(
                        key: const Key('home-ride-entry'),
                        onTap: widget.onRideRequest,
                        onHighlightChanged: (pressed) {
                          if (_pressed != pressed) {
                            setState(() => _pressed = pressed);
                          }
                        },
                        child: Padding(
                          padding: const EdgeInsets.all(AppSpacing.lg),
                          child: Row(
                            children: [
                              Expanded(
                                child: Text(
                                  t.homeRideEntryHint,
                                  style: theme.textTheme.labelLarge?.copyWith(
                                    color: colors.onSurface,
                                  ),
                                ),
                              ),
                              const SizedBox(width: AppSpacing.md),
                              DecoratedBox(
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: colors.secondaryContainer,
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(AppSpacing.md),
                                  child: Icon(
                                    Icons.arrow_forward_rounded,
                                    color: colors.onSecondaryContainer,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              );
              final wideLandscape =
                  bounds.maxWidth >= 500 &&
                  MediaQuery.sizeOf(context).height < 500;
              return wideLandscape
                  ? Row(
                      children: [
                        Expanded(child: heading),
                        const SizedBox(width: AppSpacing.xl),
                        Expanded(child: action),
                      ],
                    )
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        heading,
                        const SizedBox(height: AppSpacing.xl),
                        action,
                      ],
                    );
            },
          ),
        ),
      ),
    );
  }
}

class _DepartureSculpture extends CustomPainter {
  const _DepartureSculpture({
    required this.face,
    required this.edge,
    required this.rtl,
  });
  final Color face;
  final Color edge;
  final bool rtl;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.save();
    if (rtl) {
      canvas.translate(size.width, 0);
      canvas.scale(-1, 1);
    }
    canvas.scale(size.width / 92, size.height / 130);
    final stem = Path()
      ..moveTo(10, 117)
      ..lineTo(64, 49)
      ..lineTo(77, 61)
      ..lineTo(27, 129)
      ..close();
    canvas.drawPath(stem, Paint()..color = edge);
    final arrow = Path()
      ..moveTo(4, 98)
      ..lineTo(51, 39)
      ..lineTo(20, 42)
      ..lineTo(24, 20)
      ..lineTo(84, 14)
      ..lineTo(88, 75)
      ..lineTo(66, 81)
      ..lineTo(65, 53)
      ..lineTo(22, 111)
      ..close();
    canvas.drawPath(arrow, Paint()..color = face);
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _DepartureSculpture oldDelegate) =>
      face != oldDelegate.face ||
      edge != oldDelegate.edge ||
      rtl != oldDelegate.rtl;
}
