import 'package:flutter/material.dart';
import 'package:tam_customer/app/theme/app_tokens.dart';
import 'package:tam_customer/features/auth/presentation/widgets/auth_artwork.dart';
import 'package:tam_customer/l10n/app_localizations.dart';

/// Existing code-native route/message artwork, with the TAM brand throughout.
class AuthReferenceHeader extends StatelessWidget {
  const AuthReferenceHeader({
    super.key,
    required this.artwork,
    required this.compact,
    this.onBack,
  });
  final AuthArtwork artwork;
  final bool compact;
  final VoidCallback? onBack;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      key: const Key('auth-brand-scene'),
      children: [
        Stack(
          alignment: Alignment.center,
          children: [
            SizedBox(
              width: double.infinity,
              child: Text(
                AppLocalizations.of(context).appName,
                textAlign: TextAlign.center,
                style: theme.textTheme.displayLarge?.copyWith(
                  color: theme.colorScheme.primary,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
            if (onBack != null)
              Align(
                alignment: AlignmentDirectional.centerStart,
                child: IconButton(
                  key: const Key('auth-back'),
                  onPressed: onBack,
                  tooltip: MaterialLocalizations.of(context).backButtonTooltip,
                  icon: const BackButtonIcon(),
                ),
              ),
          ],
        ),
        SizedBox(height: compact ? AppSpacing.sm : AppSpacing.xl),
        CustomPaint(
          painter: _AuthWavePainter(theme.colorScheme.primary),
          child: Padding(
            padding: EdgeInsets.symmetric(
              vertical: compact ? AppSpacing.sm : AppSpacing.lg,
            ),
            child: artwork == AuthArtwork.recovery
                ? AuthHeaderArtwork(artwork: artwork, compact: compact)
                : Image.asset(
                    artwork == AuthArtwork.route
                        ? 'assets/images/ahmad_ui/auth_route.webp'
                        : 'assets/images/ahmad_ui/auth_otp.webp',
                    key: const Key('auth-reference-artwork'),
                    height: compact ? 64 : 112,
                    width: double.infinity,
                    fit: BoxFit.contain,
                    excludeFromSemantics: true,
                  ),
          ),
        ),
      ],
    );
  }
}

class _AuthWavePainter extends CustomPainter {
  const _AuthWavePainter(this.color);
  final Color color;
  @override
  void paint(Canvas canvas, Size size) {
    final path = Path()
      ..moveTo(0, size.height * .45)
      ..cubicTo(
        size.width * .2,
        -size.height * .1,
        size.width * .35,
        size.height * .8,
        size.width * .57,
        size.height * .65,
      )
      ..cubicTo(
        size.width * .8,
        size.height * .5,
        size.width * .8,
        size.height * .05,
        size.width,
        size.height * .35,
      )
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();
    canvas.drawPath(
      path,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [color.withValues(alpha: .05), color.withValues(alpha: 0)],
        ).createShader(Offset.zero & size),
    );
  }

  @override
  bool shouldRepaint(_AuthWavePainter oldDelegate) =>
      color != oldDelegate.color;
}
