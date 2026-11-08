import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tam_customer/app/theme/app_tokens.dart';
import 'package:tam_customer/l10n/app_localizations.dart';
import 'package:tam_customer/shared/widgets/tam_button.dart';
import 'package:tam_customer/shared/widgets/tam_loading_indicator.dart';

import '../bloc/addresses_cubit.dart';
import '../bloc/addresses_state.dart';
import '../widgets/address_display.dart';
import '../widgets/address_tile.dart';

class AddressesPage extends StatelessWidget {
  const AddressesPage({
    super.key,
    required this.onAdd,
    required this.onEdit,
    required this.onBack,
  });
  final VoidCallback onAdd, onBack;
  final ValueChanged<String> onEdit;

  Future<void> _delete(BuildContext context, String id) async {
    final t = AppLocalizations.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(t.addressesDeleteTitle),
        content: Text(t.addressesDeleteBody),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: Text(t.addressesCancel),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: Text(t.addressesConfirmDelete),
          ),
        ],
      ),
    );
    if (confirmed == true && context.mounted) {
      await context.read<AddressesCubit>().delete(id);
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(t.addressesTitle),
        leading: IconButton(
          icon: const BackButtonIcon(),
          tooltip: MaterialLocalizations.of(context).backButtonTooltip,
          onPressed: () => Navigator.of(context).canPop()
              ? Navigator.pop(context)
              : onBack(),
        ),
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 740),
            child: BlocBuilder<AddressesCubit, AddressesState>(
              builder: (context, state) {
                final cubit = context.read<AddressesCubit>();
                if (state.status == AddressesStatus.loading) {
                  return Center(
                    child: TamLoadingIndicator(
                      semanticLabel: t.addressesLoading,
                    ),
                  );
                }
                return RefreshIndicator(
                  onRefresh: () => cubit.load(refresh: true),
                  child: ListView(
                    key: const Key('addresses-list'),
                    padding: AppSpacing.pagePadding,
                    physics: const AlwaysScrollableScrollPhysics(),
                    children: [
                      Text(
                        t.addressesDescription,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      const SizedBox(height: AppSpacing.lg),
                      if (state.failure != null) ...[
                        Semantics(
                          liveRegion: true,
                          child: Text(
                            addressFailureMessage(t, state.failure),
                            style: Theme.of(context).textTheme.bodyMedium
                                ?.copyWith(
                                  color: Theme.of(context).colorScheme.error,
                                ),
                          ),
                        ),
                        TamButton.secondary(
                          label: t.addressesRetry,
                          onPressed: state.busy
                              ? null
                              : () => cubit.load(refresh: true),
                        ),
                        const SizedBox(height: AppSpacing.lg),
                      ],
                      if (state.items.isEmpty &&
                          state.status != AddressesStatus.error) ...[
                        Icon(
                          Icons.bookmark_border,
                          size: 48,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                        const SizedBox(height: AppSpacing.md),
                        Text(
                          t.addressesEmpty,
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        Text(t.addressesEmptyBody),
                      ],
                      for (final item in state.items) ...[
                        AddressTile(
                          address: item,
                          enabled: !state.busy,
                          onEdit: () => onEdit(item.id),
                          onDelete: () => _delete(context, item.id),
                        ),
                        const SizedBox(height: AppSpacing.md),
                      ],
                      const SizedBox(height: AppSpacing.lg),
                      TamButton.primary(
                        label: t.addressesAdd,
                        icon: Icons.add,
                        onPressed:
                            state.status == AddressesStatus.ready && !state.busy
                            ? onAdd
                            : null,
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
