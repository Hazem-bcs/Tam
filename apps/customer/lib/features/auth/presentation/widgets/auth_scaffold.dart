import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:tam_customer/app/theme/app_theme.dart';
import 'package:tam_customer/app/theme/app_tokens.dart';
import 'package:tam_customer/features/auth/presentation/widgets/auth_artwork.dart';
import 'package:tam_customer/features/auth/presentation/widgets/auth_reference_header.dart';

/// Ahmad UI presentation. Session, OTP security and temporary entry stay owned
/// by AuthCubit and the existing route policy.
class AuthScaffold extends StatelessWidget {
  const AuthScaffold({
    super.key,
    required this.title,
    required this.description,
    required this.child,
    this.onBack,
    this.footer,
    this.busy = false,
    this.inputFocused = false,
    this.gazeProgress = 0,
    this.otpStage = false,
    this.hasError = false,
    this.success = false,
    this.artwork = AuthArtwork.route,
  });
  final String title, description;
  final Widget child;
  final Widget? footer;
  final VoidCallback? onBack;
  final bool busy, inputFocused, otpStage, hasError, success;
  final double gazeProgress;
  final AuthArtwork artwork;

  @override
  Widget build(BuildContext context) {
    final theme = AppTheme.auth(Theme.of(context));
    final colors = theme.colorScheme;
    final top = Color.alphaBlend(
      colors.primaryContainer.withValues(alpha: .85),
      colors.surface,
    );
    final keyboardInset = MediaQuery.viewInsetsOf(context).bottom;
    return Theme(
      data: theme,
      child: PopScope(
        canPop: onBack == null,
        onPopInvokedWithResult: (didPop, _) {
          if (!didPop && !busy) onBack?.call();
        },
        child: AnnotatedRegion<SystemUiOverlayStyle>(
          value: SystemUiOverlayStyle(
            statusBarColor: top,
            statusBarIconBrightness: Brightness.dark,
            statusBarBrightness: Brightness.light,
            systemStatusBarContrastEnforced: false,
            systemNavigationBarColor: colors.surface,
            systemNavigationBarIconBrightness: Brightness.dark,
          ),
          child: Scaffold(
            backgroundColor: colors.surface,
            body: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [top, colors.surface, colors.surface],
                  stops: const [0, .55, 1],
                ),
              ),
              child: SafeArea(
                child: LayoutBuilder(
                  builder: (context, viewport) {
                    final fullHeight = viewport.maxHeight + keyboardInset;
                    final compact =
                        fullHeight < 700 ||
                        MediaQuery.textScalerOf(context).scale(16) > 23;
                    return Align(
                      alignment: Alignment.topCenter,
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 480),
                        child: SingleChildScrollView(
                          key: const Key('auth-form-scroll'),
                          keyboardDismissBehavior:
                              ScrollViewKeyboardDismissBehavior.onDrag,
                          child: ConstrainedBox(
                            constraints: BoxConstraints(
                              minHeight: viewport.maxHeight,
                            ),
                            child: Padding(
                              padding: const EdgeInsetsDirectional.fromSTEB(
                                AppSpacing.xl,
                                AppSpacing.lg,
                                AppSpacing.xl,
                                AppSpacing.xl,
                              ),
                              child: Column(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.stretch,
                                    children: [
                                      AuthReferenceHeader(
                                        artwork: artwork,
                                        compact: compact,
                                        onBack: busy ? null : onBack,
                                      ),
                                      SizedBox(
                                        height: compact
                                            ? AppSpacing.lg
                                            : AppSpacing.xl,
                                      ),
                                      Text(
                                        title,
                                        textAlign: TextAlign.center,
                                        style: theme.textTheme.headlineSmall
                                            ?.copyWith(
                                              color: colors.onSurface,
                                              fontWeight: FontWeight.w800,
                                            ),
                                      ),
                                      const SizedBox(height: AppSpacing.sm),
                                      Text(
                                        description,
                                        textAlign: TextAlign.center,
                                        style: theme.textTheme.bodyMedium
                                            ?.copyWith(
                                              color: colors.onSurfaceVariant,
                                            ),
                                      ),
                                      SizedBox(
                                        height: compact
                                            ? AppSpacing.xl
                                            : AppSpacing.xxl,
                                      ),
                                      Container(
                                        key: const Key('auth-form-surface'),
                                        child: child,
                                      ),
                                    ],
                                  ),
                                  if (footer != null)
                                    Padding(
                                      padding: const EdgeInsets.only(
                                        top: AppSpacing.xxl,
                                      ),
                                      child: footer!,
                                    ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
