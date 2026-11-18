import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tam_customer/app/theme/app_tokens.dart';
import 'package:tam_customer/l10n/app_localizations.dart';
import 'package:tam_customer/shared/widgets/tam_button.dart';
import 'package:tam_customer/shared/widgets/tam_loading_indicator.dart';

import '../bloc/addresses_cubit.dart';
import '../bloc/addresses_state.dart';
import '../bloc/preferred_address_selection.dart';
import '../widgets/address_display.dart';
import '../widgets/address_delete_dialog.dart';
import '../widgets/address_tile.dart';
import '../widgets/addresses_empty_state.dart';

/// Saved, empty and error states use the same identity and bottom action.
class AddressesPage extends StatefulWidget {
  const AddressesPage({
    super.key,
    required this.onAdd,
    required this.onEdit,
    required this.onBack,
  });

  final VoidCallback onAdd, onBack;
  final ValueChanged<String> onEdit;

  @override
  State<AddressesPage> createState() => _AddressesPageState();
}

class _AddressesPageState extends State<AddressesPage> {
  String? _pendingId;

  void _confirmDefault(BuildContext context) {
    final id = _pendingId;
    if (id == null) return;
    context.read<PreferredAddressSelection>().choose(id);
    setState(() => _pendingId = null);
  }

  Future<void> _delete(BuildContext context, String id) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => const AddressDeleteDialog(),
    );
    if (confirmed != true || !mounted || !context.mounted) return;

    final cubit = context.read<AddressesCubit>();
    await cubit.delete(id);
    if (!mounted || !context.mounted) return;
    final ids = cubit.state.items.map((item) => item.id).toSet();
    context.read<PreferredAddressSelection>().clearIfMissing(ids);
    if (_pendingId != null && !ids.contains(_pendingId)) {
      setState(() => _pendingId = null);
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    return Scaffold(
      appBar: AppBar(
        title: Text(
          t.addressesTitle,
          style: theme.textTheme.headlineSmall?.copyWith(
            color: colors.primary,
            fontWeight: FontWeight.w800,
          ),
        ),
        leading: IconButton(
          icon: const BackButtonIcon(),
          tooltip: MaterialLocalizations.of(context).backButtonTooltip,
          onPressed: () => Navigator.of(context).canPop()
              ? Navigator.pop(context)
              : widget.onBack(),
        ),
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 660),
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
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Expanded(
                      child: RefreshIndicator(
                        onRefresh: () => cubit.load(refresh: true),
                        child: ListView(
                          key: const Key('addresses-list'),
                          padding: AppSpacing.pagePadding,
                          physics: const AlwaysScrollableScrollPhysics(),
                          children: [
                            _AddressesHeader(count: state.items.length),
                            const SizedBox(height: AppSpacing.xl),
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
                              const SizedBox(height: AppSpacing.md),
                              TamButton.secondary(
                                label: t.addressesRetry,
                                onPressed: state.busy
                                    ? null
                                    : () => cubit.load(refresh: true),
                              ),
                              const SizedBox(height: AppSpacing.lg),
                            ],
                            if (state.items.isEmpty &&
                                state.status != AddressesStatus.error)
                              const AddressesEmptyState(),
                            BlocBuilder<PreferredAddressSelection, String?>(
                              builder: (context, preferredId) => Column(
                                children: [
                                  for (final item in state.items) ...[
                                    AddressTile(
                                      address: item,
                                      enabled: !state.busy,
                                      selected: (_pendingId ?? preferredId) == item.id,
                                      confirmed: preferredId == item.id,
                                      onSelect: () => setState(() {
                                        _pendingId = item.id == preferredId
                                            ? null
                                            : item.id;
                                      }),
                                      onEdit: () => widget.onEdit(item.id),
                                      onDelete: () => _delete(context, item.id),
                                    ),
                                    const SizedBox(height: AppSpacing.md),
                                  ],
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsetsDirectional.fromSTEB(
                        AppSpacing.xl,
                        AppSpacing.sm,
                        AppSpacing.xl,
                        AppSpacing.lg,
                      ),
                      child: BlocBuilder<PreferredAddressSelection, String?>(
                        builder: (context, preferredId) {
                          final pending = _pendingId != null &&
                              _pendingId != preferredId &&
                              state.items.any((item) => item.id == _pendingId);
                          final canAct =
                              state.status == AddressesStatus.ready && !state.busy;
                          return Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              if (pending) ...[
                                TamButton.primary(
                                  key: const Key('addresses-confirm-default'),
                                  label: t.addressesSetDefault,
                                  icon: Icons.check_rounded,
                                  onPressed: canAct
                                      ? () => _confirmDefault(context)
                                      : null,
                                ),
                                const SizedBox(height: AppSpacing.sm),
                              ],
                              pending
                                  ? TamButton.secondary(
                                      key: const Key('addresses-add-button'),
                                      label: t.addressesAdd,
                                      icon: Icons.add_rounded,
                                      onPressed: canAct ? widget.onAdd : null,
                                    )
                                  : TamButton.primary(
                                      key: const Key('addresses-add-button'),
                                      label: t.addressesAdd,
                                      icon: Icons.add_rounded,
                                      onPressed: canAct ? widget.onAdd : null,
                                    ),
                            ],
                          );
                        },
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}

class _AddressesHeader extends StatelessWidget {
  const _AddressesHeader({required this.count});
  final int count;

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    return Container(
      padding: const EdgeInsetsDirectional.all(AppSpacing.lg),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: AlignmentDirectional.topStart,
          end: AlignmentDirectional.bottomEnd,
          colors: [
            colors.primaryContainer.withValues(alpha: 0.65),
            colors.surface,
          ],
        ),
        borderRadius: BorderRadius.circular(AppRadii.sheet),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            t.addressesDescription,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          DecoratedBox(
            decoration: BoxDecoration(
              color: colors.surfaceContainerLowest,
              borderRadius: BorderRadius.circular(AppRadii.sheet),
            ),
            child: Padding(
              padding: const EdgeInsetsDirectional.symmetric(
                horizontal: AppSpacing.md,
                vertical: AppSpacing.sm,
              ),
              child: Wrap(
                spacing: AppSpacing.sm,
                runSpacing: AppSpacing.xs,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  Icon(
                    Icons.bookmark_outline_rounded,
                    color: colors.primary,
                    size: 20,
                  ),
                  Text(t.addressesSavedTab, style: theme.textTheme.labelMedium),
                  Text(
                    '$count',
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: colors.primary,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
