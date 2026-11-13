import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:tam_customer/app/theme/app_tokens.dart';
import 'package:tam_customer/features/auth/presentation/widgets/auth_artwork.dart';
import 'package:tam_customer/features/auth/presentation/widgets/auth_brand_hero.dart';

/// A single art-directed shell for phone entry, verification, and recovery.
///
/// Navigation and authentication status remain owned by AuthCubit/GoRouter.
/// The entire layout scrolls in response to keyboard and large text.
class AuthScaffold extends StatelessWidget {
  const AuthScaffold({
    super.key,
    required this.title,
    required this.description,
    required this.child,
    this.onBack,
    this.busy = false,
    this.artwork = AuthArtwork.route,
  });

  final String title;
  final String description;
  final Widget child;
  final VoidCallback? onBack;
  final bool busy;
  final AuthArtwork artwork;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final reduceMotion = MediaQuery.disableAnimationsOf(context);

    return PopScope(
      canPop: onBack == null,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop && !busy) onBack?.call();
      },
      child: AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle(
          statusBarColor: colors.primary,
          statusBarIconBrightness: Brightness.light,
          statusBarBrightness: Brightness.dark,
          systemNavigationBarColor: colors.surface,
          systemNavigationBarIconBrightness: Brightness.dark,
        ),
        child: Scaffold(
          backgroundColor: colors.surface,
          body: Stack(
            children: [
              PositionedDirectional(
                top: 0,
                start: 0,
                end: 0,
                height: 280,
                child: ColoredBox(color: colors.primary),
              ),
              SafeArea(
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final compact =
                        constraints.maxHeight < 610 ||
                        MediaQuery.textScalerOf(context).scale(16) > 23;

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
                                onBack: onBack,
                              ),
                              Transform.translate(
                                offset: const Offset(0, -AppSpacing.xl),
                                child: Padding(
                                  padding:
                                      const EdgeInsetsDirectional.symmetric(
                                        horizontal: AppSpacing.lg,
                                      ),
                                  child: TweenAnimationBuilder<double>(
                                    duration: reduceMotion
                                        ? Duration.zero
                                        : const Duration(milliseconds: 340),
                                    tween: Tween(begin: 0, end: 1),
                                    curve: Curves.easeOutCubic,
                                    builder: (context, progress, child) =>
                                        Opacity(
                                          opacity: progress,
                                          child: Transform.translate(
                                            offset: Offset(
                                              0,
                                              (1 - progress) * AppSpacing.lg,
                                            ),
                                            child: child,
                                          ),
                                        ),
                                    child: Material(
                                      key: const Key('auth-form-surface'),
                                      color: colors.surfaceContainerLowest,
                                      elevation: AppElevation.raised,
                                      shape: RoundedRectangleBorder(
                                        side: BorderSide(
                                          color: colors.outlineVariant,
                                        ),
                                        borderRadius: BorderRadius.circular(
                                          AppRadii.sheet,
                                        ),
                                      ),
                                      clipBehavior: Clip.antiAlias,
                                      child: Padding(
                                        padding:
                                            const EdgeInsetsDirectional.all(
                                              AppSpacing.xl,
                                            ),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.stretch,
                                          children: [
                                            Align(
                                              alignment: AlignmentDirectional
                                                  .centerStart,
                                              child: Container(
                                                height: AppSpacing.xs,
                                                width: AppSpacing.xxl,
                                                decoration: BoxDecoration(
                                                  color: colors.primary,
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                        AppRadii.sm,
                                                      ),
                                                ),
                                              ),
                                            ),
                                            const SizedBox(
                                              height: AppSpacing.lg,
                                            ),
                                            Text(
                                              title,
                                              textAlign: TextAlign.start,
                                              style: theme
                                                  .textTheme
                                                  .headlineMedium
                                                  ?.copyWith(
                                                    fontWeight: FontWeight.w800,
                                                  ),
                                            ),
                                            const SizedBox(
                                              height: AppSpacing.sm,
                                            ),
                                            Text(
                                              description,
                                              textAlign: TextAlign.start,
                                              style: theme.textTheme.bodyMedium
                                                  ?.copyWith(
                                                    color:
                                                        colors.onSurfaceVariant,
                                                  ),
                                            ),
                                            SizedBox(
                                              height: compact
                                                  ? AppSpacing.lg
                                                  : AppSpacing.xxl,
                                            ),
                                            child,
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
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
