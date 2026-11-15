import 'package:flutter/material.dart';
import 'package:tam_customer/app/theme/app_tokens.dart';
import 'package:tam_customer/features/auth/presentation/widgets/auth_artwork.dart';
import 'package:tam_customer/l10n/app_localizations.dart';

/// Consistent brand scene for phone entry, OTP and session recovery.
///
/// The map-inspired curves are abstract artwork, not real geographic routes.
/// No perpetual animation is used on the authentication surface.
class AuthBrandHero extends StatelessWidget {
  const AuthBrandHero({
    super.key,
    required this.artwork,
    required this.compact,
    this.onBack,
    this.busy = false,
  });

  final AuthArtwork artwork;
  final bool compact;
  final VoidCallback? onBack;
  final bool busy;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final t = AppLocalizations.of(context);
    final reduceMotion = MediaQuery.disableAnimationsOf(context);

    return Container(
      key: const Key('auth-brand-scene'),
      height: compact ? 143 : 246,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: AlignmentDirectional.topStart,
          end: AlignmentDirectional.bottomEnd,
          colors: [
            colors.primary,
            Color.alphaBlend(
              colors.onPrimary.withValues(alpha: 0.06),
              colors.primary,
            ),
          ],
        ),
        borderRadius: const BorderRadiusDirectional.only(
          bottomStart: Radius.circular(AppRadii.sheet),
          bottomEnd: Radius.circular(AppRadii.sheet),
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          PositionedDirectional(
            end: -82,
            bottom: -124,
            child: Container(
              height: 230,
              width: 230,
              decoration: BoxDecoration(
                color: colors.onPrimary.withValues(alpha: 0.07),
                shape: BoxShape.circle,
              ),
            ),
          ),
          PositionedDirectional(
            start: -58,
            top: -88,
            child: Container(
              height: 180,
              width: 180,
              decoration: BoxDecoration(
                color: colors.onPrimary.withValues(alpha: 0.035),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsetsDirectional.fromSTEB(
              AppSpacing.xl,
              AppSpacing.lg,
              AppSpacing.xl,
              AppSpacing.xl,
            ),
            child: Column(
              children: [
                SizedBox(
                  height: compact ? AppDimensions.minTapTarget : 57,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Center(
                        child: Text(
                          t.appName,
                          textAlign: TextAlign.center,
                          style:
                              (compact
                                      ? theme.textTheme.headlineMedium
                                      : theme.textTheme.displaySmall)
                                  ?.copyWith(
                                    color: colors.onPrimary,
                                    fontWeight: FontWeight.w800,
                                  ),
                        ),
                      ),
                      if (onBack != null)
                        PositionedDirectional(
                          start: 0,
                          child: IconButton(
                            tooltip: MaterialLocalizations.of(
                              context,
                            ).backButtonTooltip,
                            onPressed: busy ? null : onBack,
                            style: IconButton.styleFrom(
                              minimumSize: const Size.square(
                                AppDimensions.minTapTarget,
                              ),
                              foregroundColor: colors.onPrimary,
                              backgroundColor: colors.onPrimary.withValues(
                                alpha: 0.13,
                              ),
                            ),
                            icon: const BackButtonIcon(),
                          ),
                        ),
                    ],
                  ),
                ),
                SizedBox(height: compact ? AppSpacing.xs : AppSpacing.md),
                Flexible(
                  child: TweenAnimationBuilder<double>(
                    tween: Tween(begin: 0, end: 1),
                    duration: reduceMotion
                        ? Duration.zero
                        : const Duration(milliseconds: 520),
                    curve: Curves.easeOutCubic,
                    builder: (context, value, child) => Opacity(
                      opacity: value,
                      child: Transform.translate(
                        offset: Offset(0, (1 - value) * AppSpacing.md),
                        child: child,
                      ),
                    ),
                    child: AuthHeaderArtwork(
                      artwork: artwork,
                      compact: compact,
                      onDark: true,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
