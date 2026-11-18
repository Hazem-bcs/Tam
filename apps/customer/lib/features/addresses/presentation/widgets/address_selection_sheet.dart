import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tam_customer/app/theme/app_tokens.dart';
import 'package:tam_customer/l10n/app_localizations.dart';
import 'package:tam_customer/shared/widgets/tam_loading_indicator.dart';

import '../bloc/addresses_cubit.dart';
import '../bloc/addresses_state.dart';
import '../bloc/preferred_address_selection.dart';
import 'address_display.dart';
import 'address_visual_icon.dart';

Future<void> showAddressSelectionSheet(
  BuildContext context, {
  required VoidCallback onManage,
}) {
  final addresses = context.read<AddressesCubit>();
  final selection = context.read<PreferredAddressSelection>();
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    builder: (sheetContext) => MultiBlocProvider(
      providers: [
        BlocProvider.value(value: addresses),
        BlocProvider.value(value: selection),
      ],
      child: _AddressSelectionSheet(onManage: onManage),
    ),
  );
}

class _AddressSelectionSheet extends StatelessWidget {
  const _AddressSelectionSheet({required this.onManage});
  final VoidCallback onManage;

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final selected = context.watch<PreferredAddressSelection>().state;
    return Center(
      heightFactor: 1,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: 640,
          maxHeight: MediaQuery.sizeOf(context).height * .8,
        ),
        child: SingleChildScrollView(
          key: const Key('home-address-sheet'),
          padding: const EdgeInsetsDirectional.fromSTEB(
            AppSpacing.xl,
            0,
            AppSpacing.xl,
            AppSpacing.lg,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                t.homeSelectDefaultAddress,
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              BlocBuilder<AddressesCubit, AddressesState>(
                builder: (context, state) => Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (state.status == AddressesStatus.loading)
                      Center(
                        child: TamLoadingIndicator(
                          semanticLabel: t.addressesLoading,
                        ),
                      ),
                    if (state.failure != null) ...[
                      Semantics(
                        liveRegion: true,
                        child: Text(
                          addressFailureMessage(t, state.failure),
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: colors.error,
                          ),
                        ),
                      ),
                      Align(
                        alignment: AlignmentDirectional.centerStart,
                        child: TextButton(
                          onPressed: state.busy
                              ? null
                              : () => context.read<AddressesCubit>().load(
                                  refresh: true,
                                ),
                          child: Text(t.addressesRetry),
                        ),
                      ),
                    ],
                    if (state.status == AddressesStatus.ready &&
                        state.items.isEmpty &&
                        state.failure == null)
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          vertical: AppSpacing.md,
                        ),
                        child: Text(t.addressesEmptyBody),
                      ),
                    for (final item in state.items) ...[
                      Semantics(
                        selected: selected == item.id,
                        child: Material(
                          color: selected == item.id
                              ? colors.primaryContainer
                              : colors.surfaceContainerLow,
                          borderRadius: BorderRadius.circular(AppRadii.md),
                          clipBehavior: Clip.antiAlias,
                          child: InkWell(
                            key: Key('home-address-option-${item.id}'),
                            onTap: state.busy
                                ? null
                                : () {
                                    context
                                        .read<PreferredAddressSelection>()
                                        .choose(item.id);
                                    Navigator.of(context).pop();
                                  },
                            child: Padding(
                              padding: const EdgeInsets.all(AppSpacing.md),
                              child: Row(
                                children: [
                                  AddressVisualIcon(
                                    category: item.input.icon,
                                    size: 40,
                                  ),
                                  const SizedBox(width: AppSpacing.md),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text(
                                          item.input.name,
                                          style: theme.textTheme.titleSmall
                                              ?.copyWith(
                                                fontWeight: FontWeight.w700,
                                              ),
                                        ),
                                        const SizedBox(height: AppSpacing.xs),
                                        Text(
                                          item.input.location.label,
                                          style: theme.textTheme.bodySmall
                                              ?.copyWith(
                                                color: colors.onSurfaceVariant,
                                              ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  if (selected == item.id) ...[
                                    const SizedBox(width: AppSpacing.sm),
                                    Icon(
                                      Icons.check_circle_rounded,
                                      color: colors.primary,
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: AppSpacing.sm),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              TextButton.icon(
                key: const Key('home-manage-addresses'),
                onPressed: () {
                  Navigator.of(context).pop();
                  onManage();
                },
                icon: const Icon(Icons.edit_location_alt_outlined),
                label: Text(t.addressesManage),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
