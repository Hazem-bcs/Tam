import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tam_customer/app/router/customer_navigation.dart';
import 'package:tam_customer/app/theme/app_tokens.dart';
import 'package:tam_customer/features/trips/domain/trips_repository.dart';
import 'package:tam_customer/features/trips/presentation/bloc/trips_list_cubit.dart';
import 'package:tam_customer/features/trips/presentation/widgets/trip_history_list.dart';
import 'package:tam_customer/features/trips/presentation/widgets/trips_activity_navigation.dart';
import 'package:tam_customer/l10n/app_localizations.dart';

/// Activity screen, reference: customer "نشاطي" trips history.
class TripsListPage extends StatelessWidget {
  const TripsListPage({super.key, required this.navigation});
  final CustomerNavigation navigation;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l = AppLocalizations.of(context);
    return Scaffold(
      backgroundColor: theme.colorScheme.surfaceContainerLowest,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: theme.colorScheme.surfaceContainerLowest,
        toolbarHeight: 72,
        title: Text(
          l.tripsActivityTitle,
          style: theme.textTheme.headlineMedium,
        ),
        actions: [
          PopupMenuButton<TripsFilter>(
            key: const Key('trips-filter-control'),
            tooltip: l.tripsFilterLabel,
            icon: const Icon(Icons.tune_rounded),
            initialValue: context.select(
              (TripsListCubit bloc) => bloc.state.filter,
            ),
            onSelected: context.read<TripsListCubit>().selectFilter,
            itemBuilder: (context) => [
              for (final (filter, label) in [
                (TripsFilter.all, l.tripsAll),
                (TripsFilter.active, l.tripsActive),
                (TripsFilter.completed, l.tripsCompletedFilter),
                (TripsFilter.cancelled, l.tripsCancelledFilter),
              ])
                PopupMenuItem(
                  key: Key('trips-filter-${filter.name}'),
                  value: filter,
                  child: Text(label),
                ),
            ],
          ),
          IconButton(
            key: const Key('trips-notifications'),
            onPressed: navigation.openNotifications,
            tooltip: l.navNotifications,
            icon: const Icon(Icons.notifications_none_outlined),
          ),
          const SizedBox(width: AppSpacing.sm),
        ],
      ),
      bottomNavigationBar: TripsActivityNavigation(navigation: navigation),
      body: SafeArea(
        top: false,
        child: Align(
          alignment: Alignment.topCenter,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 660),
            child: Column(
              children: [
                const Padding(
                  padding: EdgeInsetsDirectional.fromSTEB(
                    AppSpacing.lg,
                    AppSpacing.sm,
                    AppSpacing.lg,
                    AppSpacing.md,
                  ),
                  child: _ActivityServices(),
                ),
                Expanded(
                  child: BlocBuilder<TripsListCubit, TripsListState>(
                    builder: (context, state) =>
                        TripHistoryList(state: state, navigation: navigation),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Disabled service tabs are clearly marked as upcoming, never fake navigation.
class _ActivityServices extends StatelessWidget {
  const _ActivityServices();

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;
    return DecoratedBox(
      decoration: BoxDecoration(
        border: Border.all(color: scheme.outlineVariant),
        borderRadius: BorderRadius.circular(AppRadii.md),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppRadii.md),
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: _ServiceTab(label: l.tripsServiceRides, selected: true),
              ),
              Expanded(
                child: _ServiceTab(
                  label: l.tripsServiceShopping,
                  subtitle: l.tripsSoon,
                ),
              ),
              Expanded(
                child: _ServiceTab(
                  label: l.tripsServiceFood,
                  subtitle: l.tripsSoon,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ServiceTab extends StatelessWidget {
  const _ServiceTab({
    required this.label,
    this.subtitle,
    this.selected = false,
  });
  final String label;
  final String? subtitle;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final fg = selected ? colors.onPrimary : colors.onSurface;
    return Semantics(
      selected: selected,
      enabled: selected,
      button: true,
      child: Container(
        constraints: const BoxConstraints(minHeight: 58),
        padding: const EdgeInsetsDirectional.symmetric(
          horizontal: AppSpacing.xs,
          vertical: AppSpacing.sm,
        ),
        color: selected ? colors.primary : colors.surfaceContainerLowest,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              textAlign: TextAlign.center,
              style: theme.textTheme.labelMedium?.copyWith(color: fg),
            ),
            if (subtitle != null)
              Text(
                subtitle!,
                textAlign: TextAlign.center,
                style: theme.textTheme.labelSmall?.copyWith(
                  color: colors.onSurfaceVariant,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
