import 'package:flutter/material.dart';
import 'package:tam_customer/app/theme/app_tokens.dart';
import 'package:tam_customer/l10n/app_localizations.dart';

class ChatHeader extends StatelessWidget {
  const ChatHeader({
    super.key,
    required this.name,
    required this.onBack,
    required this.onRefresh,
  });
  final String name;
  final VoidCallback onBack, onRefresh;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    return Padding(
      padding: const EdgeInsetsDirectional.fromSTEB(
        AppSpacing.lg,
        AppSpacing.sm,
        AppSpacing.lg,
        AppSpacing.sm,
      ),
      child: Row(
        children: [
          _HeaderAction(
            tooltip: MaterialLocalizations.of(context).backButtonTooltip,
            icon: const BackButtonIcon(),
            onPressed: onBack,
          ),
          const SizedBox(width: AppSpacing.md),
          CircleAvatar(
            backgroundColor: colors.primaryContainer,
            foregroundColor: colors.primary,
            child: const Icon(Icons.person_rounded),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Text(
              name,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          _HeaderAction(
            key: const Key('chat-refresh'),
            tooltip: AppLocalizations.of(context).chatRefresh,
            icon: const Icon(Icons.refresh_rounded),
            onPressed: onRefresh,
          ),
        ],
      ),
    );
  }
}

class _HeaderAction extends StatelessWidget {
  const _HeaderAction({
    super.key,
    required this.tooltip,
    required this.icon,
    required this.onPressed,
  });
  final String tooltip;
  final Widget icon;
  final VoidCallback onPressed;
  @override
  Widget build(BuildContext context) => Material(
    color: Theme.of(context).colorScheme.surfaceContainerLowest,
    shape: const CircleBorder(),
    elevation: AppElevation.raised,
    child: IconButton(
      tooltip: tooltip,
      onPressed: onPressed,
      color: Theme.of(context).colorScheme.primary,
      icon: icon,
    ),
  );
}
