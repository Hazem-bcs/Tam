import 'package:flutter/material.dart';
import 'package:tam_customer/app/theme/app_tokens.dart';
import 'package:tam_customer/l10n/app_localizations.dart';
import '../../domain/saved_address.dart';
import 'address_display.dart';
import 'address_visual_icon.dart';

/// Adaptive choice tiles; the preview itself has true alpha transparency.
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
    final typ = Theme.of(context).textTheme;
    final scaling = MediaQuery.textScalerOf(context).scale(14);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          t.addressesChooseIcon,
          style: typ.titleMedium?.copyWith(fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: AppSpacing.md),
        LayoutBuilder(
          builder: (context, dimensions) {
            final columns = dimensions.maxWidth < 360 || scaling > 21 ? 2 : 3;
            final width =
                (dimensions.maxWidth - (columns - 1) * AppSpacing.sm) / columns;
            return Wrap(
              spacing: AppSpacing.sm,
              runSpacing: AppSpacing.sm,
              children: [
                for (final icon in AddressIcon.values)
                  SizedBox(
                    width: width,
                    child: Semantics(
                      selected: selected == icon,
                      button: true,
                      label: addressIconLabel(t, icon),
                      child: Material(
                        color: selected == icon
                            ? colors.primaryContainer
                            : colors.surfaceContainerLowest,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(AppRadii.lg),
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
                          child: Padding(
                            padding: const EdgeInsetsDirectional.symmetric(
                              vertical: AppSpacing.md,
                              horizontal: AppSpacing.xs,
                            ),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                AddressVisualIcon(category: icon, size: 46),
                                const SizedBox(height: AppSpacing.xs),
                                Text(
                                  addressIconLabel(t, icon),
                                  textAlign: TextAlign.center,
                                  style: typ.labelMedium?.copyWith(
                                    fontWeight: selected == icon
                                        ? FontWeight.w800
                                        : FontWeight.w500,
                                  ),
                                ),
                                if (selected == icon)
                                  Icon(
                                    Icons.check_circle_rounded,
                                    size: 17,
                                    color: colors.primary,
                                  ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            );
          },
        ),
      ],
    );
  }
}
