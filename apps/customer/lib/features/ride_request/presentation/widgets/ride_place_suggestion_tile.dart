import 'package:flutter/material.dart';
import 'package:tam_customer/app/theme/app_tokens.dart';
import 'ride_artwork.dart';

class RidePlaceSuggestionTile extends StatelessWidget {
  const RidePlaceSuggestionTile({
    super.key,
    required this.label,
    required this.onTap,
  });
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final parts = label.split(RegExp('[،,]')).map((s) => s.trim()).toList();
    final title = parts.length == 2 ? parts.last : label;
    return Semantics(
      label: label,
      button: true,
      onTap: onTap,
      excludeSemantics: true,
      child: ListTile(
        onTap: onTap,
        minTileHeight: 60,
        contentPadding: const EdgeInsetsDirectional.symmetric(
          horizontal: AppSpacing.sm,
          vertical: AppSpacing.xs,
        ),
        leading: Container(
          width: 40,
          height: 40,
          padding: const EdgeInsets.all(AppSpacing.sm),
          decoration: BoxDecoration(
            color: theme.colorScheme.surfaceContainerLow,
            borderRadius: BorderRadius.circular(AppRadii.md),
          ),
          child: const RideArtwork(type: RideArtworkType.place),
        ),
        title: Text(title, style: theme.textTheme.titleSmall),
        subtitle: parts.length == 2
            ? Text(
                parts.first,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              )
            : null,
        trailing: Icon(
          Icons.chevron_right_rounded,
          size: 18,
          color: theme.colorScheme.outline,
        ),
      ),
    );
  }
}
