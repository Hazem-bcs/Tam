import 'package:flutter/material.dart';
import 'package:tam_customer/app/theme/app_tokens.dart';
import 'package:tam_customer/l10n/app_localizations.dart';
import '../../domain/saved_address.dart';
import 'address_visual_icon.dart';

enum _AddressAction { edit, delete }

/// A tappable address card with contextual edit/delete actions.
class AddressTile extends StatelessWidget {
  const AddressTile({
    super.key,
    required this.address,
    required this.enabled,
    required this.onEdit,
    required this.onDelete,
  });

  final SavedAddress address;
  final bool enabled;
  final VoidCallback onEdit, onDelete;

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Material(
      key: Key('address-item-${address.id}'),
      color: colors.surfaceContainerLowest,
      borderRadius: BorderRadius.circular(AppRadii.sheet),
      clipBehavior: Clip.antiAlias,
      child: DecoratedBox(
        decoration: BoxDecoration(
          border: Border.all(color: colors.outlineVariant),
          borderRadius: BorderRadius.circular(AppRadii.sheet),
        ),
        child: InkWell(
          onTap: enabled ? onEdit : null,
          child: Padding(
            padding: const EdgeInsetsDirectional.fromSTEB(
              AppSpacing.md,
              AppSpacing.md,
              AppSpacing.sm,
              AppSpacing.md,
            ),
            child: Row(
              children: [
                Container(
                  width: 72,
                  height: 72,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: colors.primaryContainer.withValues(alpha: 0.52),
                    borderRadius: BorderRadius.circular(AppRadii.lg),
                  ),
                  child: AddressVisualIcon(
                    category: address.input.icon,
                    size: 58,
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        address.input.name,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        address.input.location.label,
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: colors.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                PopupMenuButton<_AddressAction>(
                  key: Key('address-menu-${address.id}'),
                  enabled: enabled,
                  tooltip: t.addressesManage,
                  icon: Icon(
                    Icons.more_vert_rounded,
                    color: colors.onSurfaceVariant,
                  ),
                  onSelected: (action) {
                    if (action == _AddressAction.edit) {
                      onEdit();
                    } else {
                      onDelete();
                    }
                  },
                  itemBuilder: (_) => [
                    PopupMenuItem(
                      key: Key('address-edit-${address.id}'),
                      value: _AddressAction.edit,
                      child: Row(
                        children: [
                          const Icon(Icons.edit_outlined),
                          const SizedBox(width: AppSpacing.sm),
                          Text(t.addressesEdit),
                        ],
                      ),
                    ),
                    PopupMenuItem(
                      key: Key('address-delete-${address.id}'),
                      value: _AddressAction.delete,
                      child: Row(
                        children: [
                          Icon(Icons.delete_outline, color: colors.error),
                          const SizedBox(width: AppSpacing.sm),
                          Text(t.addressesDelete),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
