import 'package:flutter/material.dart';
import 'package:tam_customer/app/theme/app_tokens.dart';
import 'package:tam_customer/l10n/app_localizations.dart';

import '../../domain/saved_address.dart';
import 'address_display.dart';
import 'address_visual_icon.dart';

/// One compact horizontal strip, using the existing transparent TAM artwork.
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
    final colors = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          t.addressesChooseIcon,
          style: text.titleSmall?.copyWith(fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: AppSpacing.sm),
        LayoutBuilder(
          builder: (context, bounds) {
            const gap = AppSpacing.sm;
            final available = (bounds.maxWidth - gap * 4) / 5;
            final itemWidth = available.clamp(64.0, 84.0);
            return SingleChildScrollView(
              key: const Key('address-icons-scroll'),
              scrollDirection: Axis.horizontal,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  for (final (index, icon) in AddressIcon.values.indexed) ...[
                    if (index > 0) const SizedBox(width: gap),
                    SizedBox(
                      width: itemWidth,
                      child: Semantics(
                        selected: selected == icon,
                        button: true,
                        enabled: enabled,
                        label: addressIconLabel(t, icon),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Material(
                              color: selected == icon
                                  ? colors.primaryContainer
                                  : colors.surfaceContainerLowest,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(
                                  AppRadii.md,
                                ),
                                side: BorderSide(
                                  color: selected == icon
                                      ? colors.primary
                                      : colors.outlineVariant,
                                  width: selected == icon
                                      ? AppDimensions.focusBorderWidth
                                      : AppDimensions.borderWidth,
                                ),
                              ),
                              clipBehavior: Clip.antiAlias,
                              child: InkWell(
                                key: Key('address-icon-${icon.name}'),
                                onTap: enabled ? () => onSelected(icon) : null,
                                child: SizedBox(
                                  width: itemWidth,
                                  height: 62,
                                  child: Center(
                                    child: AddressVisualIcon(
                                      category: icon,
                                      size: 37,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: AppSpacing.xs),
                            Text(
                              addressIconLabel(t, icon),
                              maxLines: 2,
                              textAlign: TextAlign.center,
                              overflow: TextOverflow.ellipsis,
                              style: text.labelSmall?.copyWith(
                                color: selected == icon
                                    ? colors.primary
                                    : colors.onSurfaceVariant,
                                fontWeight: selected == icon
                                    ? FontWeight.w700
                                    : FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            );
          },
        ),
      ],
    );
  }
}
