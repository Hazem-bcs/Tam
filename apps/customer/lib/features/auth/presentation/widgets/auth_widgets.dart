import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:tam_customer/app/theme/app_tokens.dart';
import 'package:tam_customer/features/auth/domain/auth_models.dart';

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
