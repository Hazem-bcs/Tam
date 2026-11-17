import 'package:flutter/material.dart';
import 'package:tam_customer/app/theme/app_tokens.dart';
import 'package:tam_customer/l10n/app_localizations.dart';

import '../../domain/saved_address.dart';
import 'address_visual_icon.dart';

enum _AddressAction { edit, delete }

/// Tapping selects a saved location; only the menu's edit action navigates.
class AddressTile extends StatelessWidget {
  const AddressTile({
    super.key,
    required this.address,
    required this.enabled,
    required this.selected,
    required this.onSelect,
    required this.onEdit,
    required this.onDelete,
  });

  final SavedAddress address;
  final bool enabled;
  final bool selected;
  final VoidCallback onSelect;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Material(
      key: Key('address-item-${address.id}'),
      color: selected ? colors.primaryContainer : colors.surfaceContainerLowest,
      borderRadius: BorderRadius.circular(AppRadii.lg),
      clipBehavior: Clip.antiAlias,
      child: DecoratedBox(
        decoration: BoxDecoration(
          border: Border.all(
            color: selected ? colors.primary : colors.outlineVariant,
            width: selected ? AppDimensions.focusBorderWidth : 1,
          ),
          borderRadius: BorderRadius.circular(AppRadii.lg),
        ),
        child: InkWell(
          key: Key('address-select-${address.id}'),
          onTap: enabled ? onSelect : null,
          child: Padding(
            padding: const EdgeInsetsDirectional.fromSTEB(
              AppSpacing.md,
              AppSpacing.sm,
              AppSpacing.xs,
              AppSpacing.sm,
            ),
            child: Row(
              children: [
                Container(
                  width: 60,
                  height: 60,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: colors.surfaceContainerLowest,
                    borderRadius: BorderRadius.circular(AppRadii.md),
                  ),
                  child: AddressVisualIcon(
                    category: address.input.icon,
                    size: 45,
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              address.input.name,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: theme.textTheme.titleSmall?.copyWith(
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                          if (selected) ...[
                            const SizedBox(width: AppSpacing.xs),
                            Icon(
                              Icons.check_circle_rounded,
                              key: const Key('address-preferred-check'),
                              size: 17,
                              color: colors.primary,
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        address.input.location.label,
                        maxLines: 2,
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
                  position: PopupMenuPosition.under,
                  offset: const Offset(0, 6),
                  constraints: const BoxConstraints(
                    minWidth: 180,
                    maxWidth: 230,
                  ),
                  color: colors.surfaceContainerLowest,
                  elevation: AppElevation.raised,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppRadii.lg),
                    side: BorderSide(color: colors.outlineVariant),
                  ),
                  icon: Icon(
                    Icons.more_horiz_rounded,
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
                      height: 52,
                      child: Row(
                        children: [
                          Icon(
                            Icons.edit_outlined,
                            size: 20,
                            color: colors.primary,
                          ),
                          const SizedBox(width: AppSpacing.md),
                          Expanded(
                            child: Text(
                              t.addressesEdit,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: theme.textTheme.labelLarge?.copyWith(
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const PopupMenuDivider(height: 8),
                    PopupMenuItem(
                      key: Key('address-delete-${address.id}'),
                      value: _AddressAction.delete,
                      height: 52,
                      child: Row(
                        children: [
                          Icon(
                            Icons.delete_outline,
                            color: colors.error,
                            size: 20,
                          ),
                          const SizedBox(width: AppSpacing.md),
                          Expanded(
                            child: Text(
                              t.addressesDelete,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: theme.textTheme.labelLarge?.copyWith(
                                color: colors.error,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
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
