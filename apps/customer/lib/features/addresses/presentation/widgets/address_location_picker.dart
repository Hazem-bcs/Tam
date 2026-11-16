import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tam_customer/app/theme/app_tokens.dart';
import 'package:tam_customer/features/maps/maps_entry.dart';
import 'package:tam_customer/features/maps/presentation/maps_scope.dart';
import 'package:tam_customer/l10n/app_localizations.dart';
import 'package:tam_customer/shared/widgets/tam_button.dart';
import 'package:tam_customer/shared/widgets/tam_loading_indicator.dart';
import 'package:tam_customer/shared/widgets/tam_text_field.dart';

import '../bloc/address_editor_cubit.dart';
import '../bloc/address_editor_state.dart';
import 'address_display.dart';

/// A real search/selection sheet. Map selection is delegated to MapsScope.
class AddressLocationPicker extends StatefulWidget {
  const AddressLocationPicker({super.key});

  @override
  State<AddressLocationPicker> createState() => _AddressLocationPickerState();
}

class _AddressLocationPickerState extends State<AddressLocationPicker> {
  final _query = TextEditingController();

  @override
  void dispose() {
    _query.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    final colors = Theme.of(context).colorScheme;
    final theme = Theme.of(context);
    final cubit = context.read<AddressEditorCubit>();

    return BlocBuilder<AddressEditorCubit, AddressEditorState>(
      builder: (context, state) => Column(
        children: [
          Expanded(
            child: ListView(
              key: const Key('address-location-options'),
              padding: AppSpacing.pagePadding,
              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
              children: [
                Text(
                  t.addressesChooseLocation,
                  style: theme.textTheme.headlineSmall?.copyWith(
                    color: colors.primary,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  t.addressesSearch,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: colors.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),
                TamTextField(
                  key: const Key('address-location-search'),
                  labelText: t.addressesSearch,
                  controller: _query,
                  prefixIcon: const Icon(Icons.search_rounded),
                  onChanged: cubit.search,
                ),
                const SizedBox(height: AppSpacing.lg),
                if (MapsScope.maybeOf(context) != null) ...[
                  Material(
                    borderRadius: BorderRadius.circular(AppRadii.lg),
                    color: colors.primaryContainer,
                    child: InkWell(
                      key: const Key('address-pick-on-map'),
                      borderRadius: BorderRadius.circular(AppRadii.lg),
                      onTap: () async {
                        final selected = await showMapLocationPicker(
                          context,
                          initial: state.location,
                        );
                        if (!context.mounted || selected == null) return;
                        cubit.locationSelected(selected);
                        Navigator.pop(context);
                      },
                      child: Padding(
                        padding: const EdgeInsetsDirectional.all(AppSpacing.md),
                        child: Row(
                          children: [
                            Icon(Icons.map_outlined, color: colors.primary),
                            const SizedBox(width: AppSpacing.md),
                            Expanded(
                              child: Text(
                                t.mapsPickLocation,
                                style: theme.textTheme.titleSmall?.copyWith(
                                  color: colors.onPrimaryContainer,
                                ),
                              ),
                            ),
                            Icon(
                              Icons.arrow_forward_ios_rounded,
                              color: colors.primary,
                              size: 18,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                ],
                if (state.searching)
                  Center(
                    child: TamLoadingIndicator(
                      semanticLabel: t.addressesLoading,
                    ),
                  )
                else if (state.searchFailure != null) ...[
                  Text(
                    addressFailureMessage(t, state.searchFailure),
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: colors.error,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  TamButton.secondary(
                    label: t.addressesRetry,
                    onPressed: () => cubit.search(_query.text),
                  ),
                ] else if (state.suggestions.isEmpty)
                  Padding(
                    padding: const EdgeInsetsDirectional.symmetric(
                      vertical: AppSpacing.xl,
                    ),
                    child: Text(
                      t.addressesNoPlaces,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: colors.onSurfaceVariant,
                      ),
                    ),
                  )
                else
                  for (final location in state.suggestions) ...[
                    Material(
                      color: colors.surfaceContainerLowest,
                      borderRadius: BorderRadius.circular(AppRadii.lg),
                      child: ListTile(
                        contentPadding: const EdgeInsetsDirectional.symmetric(
                          horizontal: AppSpacing.md,
                          vertical: AppSpacing.sm,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(AppRadii.lg),
                          side: BorderSide(color: colors.outlineVariant),
                        ),
                        leading: Icon(
                          Icons.place_outlined,
                          color: colors.primary,
                        ),
                        title: Text(location.label),
                        trailing: Icon(
                          Icons.arrow_forward_ios_rounded,
                          color: colors.onSurfaceVariant,
                          size: 18,
                        ),
                        onTap: () {
                          cubit.locationSelected(location);
                          Navigator.pop(context);
                        },
                      ),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                  ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
