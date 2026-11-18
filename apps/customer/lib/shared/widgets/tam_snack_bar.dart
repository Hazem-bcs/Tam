import 'dart:async';

import 'package:flutter/material.dart';
import 'package:tam_customer/app/theme/app_colors.dart' show AppStatusColors;
import 'package:tam_customer/app/theme/app_tokens.dart';

import 'snack_bar_countdown.dart';

enum TamSnackBarTone { info, success, error }

/// Shared feedback presented by the native messenger: navigation, swipe,
/// queueing, actions and completion reasons keep their Material behavior.
abstract final class TamSnackBar {
  static ScaffoldFeatureController<SnackBar, SnackBarClosedReason> show(
    BuildContext context, {
    required String message,
    TamSnackBarTone tone = TamSnackBarTone.info,
    Duration duration = AppMotion.snackBar,
    SnackBarAction? action,
  }) {
    assert(duration > Duration.zero);
    final lifetime = SnackBarLifetime(
      duration: duration,
      // Action notices already persist in the installed Material SDK. Give
      // screen-reader users the same unhurried access to all messages.
      persistent: action != null || MediaQuery.accessibleNavigationOf(context),
    );
    final notice = ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        duration: duration,
        persist: lifetime.persistent,
        onVisible: lifetime.start,
        showCloseIcon: false,
        width: MediaQuery.sizeOf(context).width >= 600 ? 560 : null,
        padding: const EdgeInsetsDirectional.fromSTEB(
          AppSpacing.md,
          AppSpacing.xs,
          AppSpacing.md,
          AppSpacing.xs,
        ),
        content: _SnackBarMessage(
          message: message,
          tone: tone,
          lifetime: lifetime,
          action: action,
        ),
      ),
    );
    unawaited(notice.closed.then<void>((_) => lifetime.dispose()));
    return notice;
  }
}

class _SnackBarMessage extends StatelessWidget {
  const _SnackBarMessage({
    required this.message,
    required this.tone,
    required this.lifetime,
    this.action,
  });
  final String message;
  final TamSnackBarTone tone;
  final SnackBarLifetime lifetime;
  final SnackBarAction? action;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final status = theme.extension<AppStatusColors>();
    final accent = switch (tone) {
      TamSnackBarTone.success => status?.success ?? colors.primary,
      TamSnackBarTone.error => colors.error,
      TamSnackBarTone.info => colors.primary,
    };
    final badge = switch (tone) {
      TamSnackBarTone.success =>
        status?.successContainer ?? colors.primaryContainer,
      TamSnackBarTone.error => colors.errorContainer,
      TamSnackBarTone.info => colors.primaryContainer,
    };
    final icon = switch (tone) {
      TamSnackBarTone.success => Icons.check_rounded,
      TamSnackBarTone.error => Icons.priority_high_rounded,
      TamSnackBarTone.info => Icons.info_outline_rounded,
    };
    final symbol = DecoratedBox(
      decoration: BoxDecoration(color: badge, shape: BoxShape.circle),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.sm),
        child: Icon(icon, size: 18, color: accent),
      ),
    );
    final countdown = SnackBarCountdown(lifetime: lifetime, color: accent);
    return LayoutBuilder(
      builder: (context, constraints) {
        final stacked =
            constraints.maxWidth < 360 &&
            MediaQuery.textScalerOf(context).scale(1) > 1.5;
        return Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (stacked) ...[
              Row(children: [symbol, const Spacer(), countdown]),
              const SizedBox(height: AppSpacing.xs),
              Text(message),
            ] else
              Row(
                children: [
                  symbol,
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(child: Text(message)),
                  const SizedBox(width: AppSpacing.xs),
                  countdown,
                ],
              ),
            if (action != null)
              Align(alignment: AlignmentDirectional.centerEnd, child: action),
          ],
        );
      },
    );
  }
}
