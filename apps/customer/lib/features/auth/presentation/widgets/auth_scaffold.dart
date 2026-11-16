import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:tam_customer/app/theme/app_tokens.dart';
import 'package:tam_customer/features/auth/presentation/widgets/auth_artwork.dart';
import 'package:tam_customer/features/auth/presentation/widgets/auth_brand_hero.dart';

/// Responsive, RTL-aware auth screen. This is presentation-only: all OTP
/// submission, recovery, and routing remain in AuthCubit / GoRouter.
///
/// Design reference: soft pink layered waves, centered brand and mascot,
/// a rounded white form card and restrained crimson typography.
class AuthScaffold extends StatelessWidget {
  const AuthScaffold({
    super.key,
    required this.title,
    required this.description,
    required this.child,
    this.onBack,
    this.busy = false,
    this.inputFocused = false,
    this.gazeProgress = 0,
    this.otpStage = false,
    this.hasError = false,
    this.success = false,
    this.artwork = AuthArtwork.route,
  });

  final String title;
  final String description;
  final Widget child;
  final VoidCallback? onBack;
  final bool busy;
  final bool inputFocused;
  final double gazeProgress;
  final bool otpStage;
  final bool hasError;
  final bool success;
  final AuthArtwork artwork;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final reduceMotion = MediaQuery.disableAnimationsOf(context);
    // Read from the outer MediaQuery: Scaffold clears viewInsets for its body.
    final keyboardInset = MediaQuery.viewInsetsOf(context).bottom;

    return PopScope(
      canPop: onBack == null,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop && !busy) onBack?.call();
      },
      child: AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle(
          statusBarColor: colors.surface,
          statusBarIconBrightness: Brightness.dark,
          statusBarBrightness: Brightness.light,
          systemNavigationBarColor: colors.surfaceContainerLowest,
          systemNavigationBarIconBrightness: Brightness.dark,
        ),
        child: Scaffold(
          backgroundColor: colors.surfaceContainerLowest,
          body: Stack(
            children: [
              Positioned.fill(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        colors.surface,
                        colors.surfaceContainerLow,
                        colors.surfaceContainerLowest,
                      ],
                      stops: const [0, .48, 1],
                    ),
                  ),
                ),
              ),
              SafeArea(
                child: LayoutBuilder(
                  builder: (context, viewport) {
                    // Keyboard obscures the viewport but must NOT change
                    // the hero or card design scale while the user types.
                    // We retain scrolling so focused fields remain accessible.
                    final fullHeight = viewport.maxHeight + keyboardInset;
                    final compact =
                        fullHeight < 650 ||
                        MediaQuery.textScalerOf(context).scale(16) > 23;
                    final heroHeight = compact ? 188.0 : 292.0;

                    return Align(
                      alignment: Alignment.topCenter,
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 512),
                        child: SingleChildScrollView(
                          key: const Key('auth-form-scroll'),
                          keyboardDismissBehavior:
                              ScrollViewKeyboardDismissBehavior.onDrag,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              AuthBrandHero(
                                artwork: artwork,
                                compact: compact,
                                busy: busy,
                                inputFocused: inputFocused,
                                gazeProgress: gazeProgress,
                                otpStage: otpStage,
                                hasError: hasError,
                                success: success,
                                onBack: onBack,
                              ),
                              Transform.translate(
                                offset: const Offset(0, -17),
                                child: Padding(
                                  padding:
                                      const EdgeInsetsDirectional.symmetric(
                                        horizontal: AppSpacing.lg,
                                      ),
                                  child: TweenAnimationBuilder<double>(
                                    duration: reduceMotion
                                        ? Duration.zero
                                        : const Duration(milliseconds: 350),
                                    curve: Curves.easeOutCubic,
                                    tween: Tween(begin: 0, end: 1),
                                    builder: (context, t, child) => Opacity(
                                      opacity: t,
                                      child: Transform.translate(
                                        offset: Offset(0, (1 - t) * 12),
                                        child: child,
                                      ),
                                    ),
                                    child: Container(
                                      key: const Key('auth-form-surface'),
                                      constraints: BoxConstraints(
                                        minHeight: compact
                                            ? 0
                                            : (fullHeight - heroHeight + 10)
                                                  .clamp(0.0, double.infinity),
                                      ),
                                      decoration: BoxDecoration(
                                        color: colors.surfaceContainerLowest,
                                        borderRadius: BorderRadius.circular(34),
                                        border: Border.all(
                                          color: colors.outlineVariant,
                                          width: 1,
                                        ),
                                        boxShadow: [
                                          BoxShadow(
                                            color: colors.shadow.withValues(
                                              alpha: .075,
                                            ),
                                            blurRadius: 24,
                                            offset: const Offset(0, 12),
                                          ),
                                        ],
                                      ),
                                      padding:
                                          const EdgeInsetsDirectional.fromSTEB(
                                            AppSpacing.xl,
                                            AppSpacing.xxl,
                                            AppSpacing.xl,
                                            AppSpacing.xxl,
                                          ),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.stretch,
                                        children: [
                                          Text(
                                            title,
                                            textAlign: TextAlign.center,
                                            style: theme
                                                .textTheme
                                                .headlineMedium
                                                ?.copyWith(
                                                  color: colors.primary,
                                                  height: 1.25,
                                                  fontWeight: FontWeight.w900,
                                                ),
                                          ),
                                          const SizedBox(height: AppSpacing.sm),
                                          Text(
                                            description,
                                            textAlign: TextAlign.center,
                                            style: theme.textTheme.bodyMedium
                                                ?.copyWith(
                                                  color:
                                                      colors.onSurfaceVariant,
                                                  height: 1.45,
                                                ),
                                          ),
                                          const SizedBox(
                                            height: AppSpacing.xxl,
                                          ),
                                          child,
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: AppSpacing.sm),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
