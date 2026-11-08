import 'package:flutter/material.dart';
import 'package:tam_customer/app/theme/app_tokens.dart';
import 'package:tam_customer/l10n/app_localizations.dart';
import 'package:tam_customer/shared/widgets/tam_card.dart';
import '../../domain/saved_address.dart';
import 'address_display.dart';

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
    return TamCard(
      key: Key('address-item-${address.id}'),
      child: Row(
        children: [
          Icon(
            addressIcon(address.input.icon),
            color: theme.colorScheme.primary,
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(address.input.name, style: theme.textTheme.titleMedium),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  address.input.location.label,
                  style: theme.textTheme.bodyMedium,
                ),
              ],
            ),
          ),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                key: Key('address-edit-${address.id}'),
                tooltip: t.addressesEdit,
                onPressed: enabled ? onEdit : null,
                icon: const Icon(Icons.edit_outlined),
              ),
              IconButton(
                key: Key('address-delete-${address.id}'),
                tooltip: t.addressesDelete,
                onPressed: enabled ? onDelete : null,
                icon: const Icon(Icons.delete_outline),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
