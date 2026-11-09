import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tam_customer/app/router/customer_navigation.dart';
import 'package:tam_customer/app/theme/app_tokens.dart';
import 'package:tam_customer/features/trips/domain/trips_repository.dart';
import 'package:tam_customer/features/trips/presentation/bloc/trips_list_cubit.dart';
import 'package:tam_customer/features/trips/presentation/widgets/trip_card.dart';
import 'package:tam_customer/features/trips/presentation/widgets/trips_failure_banner.dart';
import 'package:tam_customer/l10n/app_localizations.dart';
import 'package:tam_customer/shared/presentation/trip_display.dart';
import 'package:tam_customer/shared/widgets/tam_button.dart';
import 'package:tam_customer/shared/widgets/tam_loading_indicator.dart';

class TripsListPage extends StatelessWidget {
  const TripsListPage({super.key, required this.navigation});
  final CustomerNavigation navigation;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(l.navTrips)),
      bottomNavigationBar: NavigationBar(
        selectedIndex: 1,
        onDestinationSelected: (index) {
          if (index == 0) navigation.openHome();
          if (index == 2) navigation.openSettings();
        },
        destinations: [
          NavigationDestination(
            icon: const Icon(Icons.home_outlined),
            label: l.navHome,
          ),
          NavigationDestination(
            icon: const Icon(Icons.history),
            label: l.navTrips,
          ),
          NavigationDestination(
            icon: const Icon(Icons.person_outline),
            label: l.navSettings,
          ),
        ],
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 800),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const _FilterBar(),
              Expanded(
                child: BlocBuilder<TripsListCubit, TripsListState>(
                  builder: (context, state) =>
                      _TripResults(state: state, navigation: navigation),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FilterBar extends StatelessWidget {
  const _FilterBar();

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final labels = {
      TripsFilter.all: l.tripsAll,
      TripsFilter.active: l.tripsActive,
      TripsFilter.completed: l.tripsCompletedFilter,
      TripsFilter.cancelled: l.tripsCancelledFilter,
    };
    final current = context.select(
      (TripsListCubit cubit) => cubit.state.filter,
    );
    return Semantics(
      label: l.tripsTripList,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsetsDirectional.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.sm,
        ),
        child: Row(
          children: [
            for (final filter in TripsFilter.values) ...[
              ChoiceChip(
                key: Key('trips-filter-${filter.name}'),
                label: Text(labels[filter]!),
                selected: current == filter,
                onSelected: (_) =>
                    context.read<TripsListCubit>().selectFilter(filter),
              ),
              const SizedBox(width: AppSpacing.sm),
            ],
          ],
        ),
      ),
    );
  }
}

class _TripResults extends StatelessWidget {
  const _TripResults({required this.state, required this.navigation});

  final TripsListState state;
  final CustomerNavigation navigation;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final cubit = context.read<TripsListCubit>();
    if (state.isLoading && state.items.isEmpty) {
      return Center(child: TamLoadingIndicator(semanticLabel: l.tripsLoading));
    }
    final results = RefreshIndicator(
      onRefresh: () => cubit.refresh(),
      child: NotificationListener<ScrollNotification>(
        onNotification: (notification) {
          if (notification.metrics.extentAfter < 240 &&
              notification is ScrollUpdateNotification) {
            cubit.loadMore();
          }
          return false;
        },
        child: state.items.isEmpty
            ? ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(AppSpacing.xl),
                children: [_EmptyOrError(state: state)],
              )
            : ListView.separated(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsetsDirectional.fromSTEB(
                  AppSpacing.lg,
                  AppSpacing.md,
                  AppSpacing.lg,
                  AppSpacing.xxl,
                ),
                itemCount:
                    state.items.length +
                    (state.nextCursor != null || state.moreErrorCode != null
                        ? 1
                        : 0),
                separatorBuilder: (_, _) =>
                    const SizedBox(height: AppSpacing.md),
                itemBuilder: (context, index) {
                  if (index == state.items.length) {
                    return Column(
                      children: [
                        if (state.moreErrorCode != null)
                          Text(tripsErrorLabel(l, state.moreErrorCode)),
                        TamButton.secondary(
                          label: state.moreErrorCode == null
                              ? l.tripsLoadMore
                              : l.tripsRetry,
                          isLoading: state.isLoadingMore,
                          onPressed: state.isLoadingMore
                              ? null
                              : cubit.loadMore,
                        ),
                      ],
                    );
                  }
                  final trip = state.items[index];
                  return TripCard(
                    key: ValueKey(trip.id),
                    trip: trip,
                    onTap: () => navigation.openTrip(trip.id),
                  );
                },
              ),
      ),
    );
    if (state.errorCode == null || state.items.isEmpty) return results;
    return Column(
      children: [
        TripsFailureBanner(
          errorCode: state.errorCode!,
          onRetry: () => cubit.refresh(),
        ),
        Expanded(child: results),
      ],
    );
  }
}

class _EmptyOrError extends StatelessWidget {
  const _EmptyOrError({required this.state});
  final TripsListState state;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final hasError = state.errorCode != null;
    final theme = Theme.of(context);
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            hasError ? Icons.wifi_off_outlined : Icons.receipt_long_outlined,
            size: 44,
            color: theme.colorScheme.primary,
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            hasError ? l.tripsErrorTitle : l.tripsEmptyTitle,
            style: theme.textTheme.titleMedium,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            hasError
                ? tripsErrorLabel(l, state.errorCode)
                : l.tripsEmptyDescription,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
          if (hasError) ...[
            const SizedBox(height: AppSpacing.lg),
            TamButton.secondary(
              label: l.tripsRetry,
              fullWidth: false,
              onPressed: () => context.read<TripsListCubit>().refresh(),
            ),
          ],
        ],
      ),
    );
  }
}
