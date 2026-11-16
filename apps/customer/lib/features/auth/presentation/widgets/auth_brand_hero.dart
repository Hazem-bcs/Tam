import 'package:flutter/material.dart';
import 'package:tam_customer/app/theme/app_tokens.dart';
import 'package:tam_customer/features/auth/presentation/widgets/auth_artwork.dart';
import 'package:tam_customer/features/auth/presentation/widgets/auth_rive_mascot.dart';
import 'package:tam_customer/l10n/app_localizations.dart';

/// Auth header inspired by the approved two-screen visual reference.
///
/// Uses the actual TAM Rive mascot asset. The Rive state machine plays a
/// welcome wave before settling into Idle; Flutter does not duplicate it.
class AuthBrandHero extends StatelessWidget {
  const AuthBrandHero({
    super.key,
    required this.artwork,
    required this.compact,
    this.onBack,
    this.busy = false,
    this.inputFocused = false,
    this.gazeProgress = 0,
    this.otpStage = false,
    this.hasError = false,
    this.success = false,
  });

  final AuthArtwork artwork;
  final bool compact;
  final VoidCallback? onBack;
  final bool busy;
  final bool inputFocused;
  final double gazeProgress;
  final bool otpStage;
  final bool hasError;
  final bool success;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final l = AppLocalizations.of(context);
    final reduced = MediaQuery.disableAnimationsOf(context);
    final height = compact ? 188.0 : 292.0;

    return SizedBox(
      key: const Key('auth-brand-scene'),
      height: height,
      width: double.infinity,
      child: Stack(
        clipBehavior: Clip.hardEdge,
        children: [
          Positioned.fill(
            child: CustomPaint(
              painter: _PastelWavesPainter(
                top: colors.surface,
                back: colors.primaryContainer,
                front: colors.primaryFixedDim.withValues(alpha: 0.65),
                bottom: colors.surfaceContainerLow,
              ),
            ),
          ),
          Positioned(
            top: compact ? 0 : 10,
            left: AppSpacing.lg,
            right: AppSpacing.lg,
            child: Text(
              l.appName,
              textAlign: TextAlign.center,
              style:
                  (compact
                          ? theme.textTheme.headlineLarge
                          : theme.textTheme.displayMedium)
                      ?.copyWith(
                        fontWeight: FontWeight.w900,
                        color: colors.primary,
                        letterSpacing: -0.8,
                      ),
            ),
          ),
          Positioned(
            top: compact ? 52 : 80,
            left: compact ? AppSpacing.lg : AppSpacing.xl,
            right: compact ? AppSpacing.lg : AppSpacing.xl,
            height: compact ? 52 : 72,
            child: AuthHeaderArtwork(artwork: artwork, compact: compact),
          ),
          Positioned(
            top: compact ? 78 : 123,
            left: 0,
            right: 0,
            child: Center(
              child: _MascotIntroMotion(
                compact: compact,
                busy: busy,
                inputFocused: inputFocused,
                gazeProgress: gazeProgress,
                otpStage: otpStage,
                hasError: hasError,
                success: success,
                reducedMotion: reduced,
              ),
            ),
          ),
          if (onBack != null)
            PositionedDirectional(
              top: AppSpacing.sm,
              start: AppSpacing.md,
              child: IconButton(
                tooltip: MaterialLocalizations.of(context).backButtonTooltip,
                onPressed: busy ? null : onBack,
                icon: const BackButtonIcon(),
                style: IconButton.styleFrom(
                  backgroundColor: colors.surfaceContainerLowest.withValues(
                    alpha: 0.82,
                  ),
                  foregroundColor: colors.primary,
                  minimumSize: const Size.square(AppDimensions.minTapTarget),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// Rive owns the entrance, breathing, wave and reaction timelines.
///
/// Do not add a second Flutter entrance controller here: it overlaps the
/// Rive welcome wave, repaints needlessly, and makes motion feel mechanical.
class _MascotIntroMotion extends StatelessWidget {
  const _MascotIntroMotion({
    required this.compact,
    required this.busy,
    required this.inputFocused,
    required this.gazeProgress,
    required this.otpStage,
    required this.hasError,
    required this.success,
    required this.reducedMotion,
  });

  final bool compact;
  final bool busy;
  final bool inputFocused;
  final double gazeProgress;
  final bool otpStage;
  final bool hasError;
  final bool success;
  final bool reducedMotion;

  @override
  Widget build(BuildContext context) => ExcludeSemantics(
    child: RepaintBoundary(
      child: AuthRiveMascot(
        size: compact ? 136 : 222,
        reduceMotion: reducedMotion,
        inputFocused: inputFocused,
        gazeProgress: gazeProgress,
        busy: busy,
        otpStage: otpStage,
        hasError: hasError,
        success: success,
      ),
    ),
  );
}

class _PastelWavesPainter extends CustomPainter {
  const _PastelWavesPainter({
    required this.top,
    required this.back,
    required this.front,
    required this.bottom,
  });

  final Color top;
  final Color back;
  final Color front;
  final Color bottom;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRect(
      Offset.zero & size,
      Paint()
        ..shader = LinearGradient(
          colors: [top, bottom],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ).createShader(Offset.zero & size),
    );

    final rear = Path()
      ..moveTo(0, size.height * 0.78)
      ..cubicTo(
        size.width * .18,
        size.height * .62,
        size.width * .29,
        size.height * .85,
        size.width * .48,
        size.height * .70,
      )
      ..cubicTo(
        size.width * .67,
        size.height * .54,
        size.width * .81,
        size.height * .64,
        size.width,
        size.height * .68,
      )
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();
    canvas.drawPath(rear, Paint()..color = back);

    final near = Path()
      ..moveTo(0, size.height * .91)
      ..cubicTo(
        size.width * .15,
        size.height * .80,
        size.width * .34,
        size.height * .89,
        size.width * .52,
        size.height * .90,
      )
      ..cubicTo(
        size.width * .69,
        size.height * .97,
        size.width * .88,
        size.height * .82,
        size.width,
        size.height * .88,
      )
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();
    canvas.drawPath(near, Paint()..color = front);
  }

  @override
  bool shouldRepaint(covariant _PastelWavesPainter old) =>
      top != old.top ||
      back != old.back ||
      front != old.front ||
      bottom != old.bottom;
}
