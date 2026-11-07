import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:tam_customer/app/theme/app_tokens.dart';
import 'package:tam_customer/features/auth/domain/auth_models.dart';
import 'package:tam_customer/features/auth/presentation/widgets/auth_artwork.dart';
import 'package:tam_customer/l10n/app_localizations.dart';

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
    final t = AppLocalizations.of(context);
    final overlay = theme.brightness == Brightness.light
        ? SystemUiOverlayStyle.dark
        : SystemUiOverlayStyle.light;
    return PopScope(
      canPop: onBack == null,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop && !busy) onBack?.call();
      },
      child: AnnotatedRegion<SystemUiOverlayStyle>(
        value: overlay.copyWith(systemNavigationBarColor: colors.surface),
        child: Scaffold(
          body: Stack(
            children: [
              const Positioned.fill(child: AuthBackground()),
              SafeArea(
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final compact = constraints.maxHeight < 560;
                    return Align(
                      alignment: Alignment.topCenter,
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 480),
                        child: SingleChildScrollView(
                          padding: AppSpacing.pagePadding,
                          keyboardDismissBehavior:
                              ScrollViewKeyboardDismissBehavior.onDrag,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              ConstrainedBox(
                                constraints: const BoxConstraints(
                                  minHeight: AppDimensions.minTapTarget,
                                ),
                                child: Stack(
                                  alignment: Alignment.center,
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: AppDimensions.minTapTarget,
                                      ),
                                      child: Text(
                                        t.appName,
                                        textAlign: TextAlign.center,
                                        style:
                                            (compact
                                                    ? theme
                                                          .textTheme
                                                          .headlineMedium
                                                    : theme
                                                          .textTheme
                                                          .displaySmall)
                                                ?.copyWith(
                                                  color: colors.primary,
                                                  fontWeight: FontWeight.w700,
                                                ),
                                      ),
                                    ),
                                    if (onBack != null)
                                      PositionedDirectional(
                                        start: 0,
                                        top: 0,
                                        bottom: 0,
                                        child: Center(
                                          child: IconButton(
                                            tooltip: MaterialLocalizations.of(
                                              context,
                                            ).backButtonTooltip,
                                            onPressed: busy ? null : onBack,
                                            icon: const BackButtonIcon(),
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                              SizedBox(
                                height: compact ? AppSpacing.xs : AppSpacing.md,
                              ),
                              AuthHeaderArtwork(
                                artwork: artwork,
                                compact: compact,
                              ),
                              SizedBox(
                                height: compact ? AppSpacing.md : AppSpacing.xl,
                              ),
                              Text(
                                title,
                                textAlign: TextAlign.center,
                                style: theme.textTheme.headlineSmall,
                              ),
                              const SizedBox(height: AppSpacing.sm),
                              Text(
                                description,
                                textAlign: TextAlign.center,
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: colors.onSurfaceVariant,
                                ),
                              ),
                              SizedBox(
                                height: compact
                                    ? AppSpacing.xl
                                    : AppSpacing.xxl,
                              ),
                              child,
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

class AuthErrorNotice extends StatelessWidget {
  const AuthErrorNotice({super.key, required this.failure});
  final AuthFailure failure;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Semantics(
      liveRegion: true,
      child: Container(
        padding: const EdgeInsetsDirectional.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: theme.colorScheme.errorContainer,
          borderRadius: BorderRadius.circular(AppRadii.md),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              Icons.error_outline,
              color: theme.colorScheme.onErrorContainer,
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Text(
                failure.message.forLanguage(
                  Localizations.localeOf(context).languageCode,
                ),
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onErrorContainer,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Countdown is local widget state; it never ticks the global auth BLoC.
class AuthCountdown extends StatefulWidget {
  const AuthCountdown({
    super.key,
    required this.deadline,
    required this.builder,
  });
  final DateTime? deadline;
  final Widget Function(BuildContext context, int seconds) builder;

  @override
  State<AuthCountdown> createState() => _AuthCountdownState();
}

class _AuthCountdownState extends State<AuthCountdown> {
  Timer? _timer;

  int get _remaining => widget.deadline == null
      ? 0
      : max(
          0,
          (widget.deadline!.difference(DateTime.now().toUtc()).inMilliseconds /
                  1000)
              .ceil(),
        );

  @override
  void initState() {
    super.initState();
    _start();
  }

  @override
  void didUpdateWidget(AuthCountdown oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.deadline != widget.deadline) _start();
  }

  void _start() {
    _timer?.cancel();
    if (_remaining <= 0) return;
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remaining == 0) timer.cancel();
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.builder(context, _remaining);
}
