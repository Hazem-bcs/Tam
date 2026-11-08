import 'package:flutter/material.dart';
import 'package:tam_customer/app/theme/app_tokens.dart';
import 'package:tam_customer/l10n/app_localizations.dart';
import '../../domain/saved_address.dart';
import 'address_display.dart';

class AddressIconPicker extends StatelessWidget {
  const AddressIconPicker({
    super.key,
    required this.selected,
    required this.enabled,
    required this.onSelected,
  });
  final AddressIcon selected;
  final bool enabled;
  final ValueChanged<AddressIcon> onSelected;

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          t.addressesChooseIcon,
          style: Theme.of(context).textTheme.titleSmall,
        ),
        const SizedBox(height: AppSpacing.sm),
        Wrap(
          spacing: AppSpacing.sm,
          runSpacing: AppSpacing.sm,
          children: [
            for (final icon in AddressIcon.values)
              ChoiceChip(
                key: Key('address-icon-${icon.name}'),
                avatar: Icon(addressIcon(icon)),
                label: Text(addressIconLabel(t, icon)),
                selected: selected == icon,
                onSelected: enabled ? (_) => onSelected(icon) : null,
              ),
          ],
        ),
      ],
    );
  }
}
