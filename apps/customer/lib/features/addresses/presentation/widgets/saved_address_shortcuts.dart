import 'package:flutter/material.dart';
import 'package:tam_customer/app/theme/app_tokens.dart';
import 'package:tam_customer/shared/domain/trip.dart';
import '../../domain/saved_address.dart';
import 'address_display.dart';

/// Repository-backed shortcuts for choosing a ride endpoint, without management.
class SavedAddressShortcuts extends StatelessWidget {
  const SavedAddressShortcuts({
    super.key,
    required this.items,
    required this.onSelected,
  });
  final List<SavedAddress> items;
  final ValueChanged<TripLocation> onSelected;

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, bounds) {
      final stacked =
          bounds.maxWidth < 280 ||
          MediaQuery.textScalerOf(context).scale(14) > 22;
      final width = stacked
          ? bounds.maxWidth
          : (bounds.maxWidth - AppSpacing.sm) / 2;
      return Wrap(
        spacing: AppSpacing.sm,
        runSpacing: AppSpacing.sm,
        children: [
          for (final item in items)
            SizedBox(
              width: width,
              child: _AddressShortcut(
                item: item,
                onTap: () => onSelected(item.input.location),
              ),
            ),
        ],
      );
    },
  );
}

class _AddressShortcut extends StatelessWidget {
  const _AddressShortcut({required this.item, required this.onTap});
  final SavedAddress item;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    return Material(
      color: colors.surfaceContainerLow,
      borderRadius: BorderRadius.circular(AppRadii.lg),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        key: Key('saved-address-${item.id}'),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  ExcludeSemantics(
                    child: Icon(
                      addressIcon(item.input.icon),
                      color: colors.primary,
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Text(
                      item.input.name,
                      style: theme.textTheme.titleSmall,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                item.input.location.label,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: colors.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
