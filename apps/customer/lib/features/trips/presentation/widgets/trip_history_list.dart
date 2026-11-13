import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:tam_customer/app/router/customer_navigation.dart';
import 'package:tam_customer/app/theme/app_tokens.dart';
import 'package:tam_customer/features/trips/presentation/bloc/trips_list_cubit.dart';
import 'package:tam_customer/features/trips/presentation/widgets/active_trip_card.dart';
import 'package:tam_customer/features/trips/presentation/widgets/trip_card.dart';
import 'package:tam_customer/features/trips/presentation/widgets/trips_failure_banner.dart';
import 'package:tam_customer/l10n/app_localizations.dart';
import 'package:tam_customer/shared/domain/trip.dart';
import 'package:tam_customer/shared/presentation/trip_display.dart';
import 'package:tam_customer/shared/widgets/tam_button.dart';
import 'package:tam_customer/shared/widgets/tam_loading_indicator.dart';

/// One scrollable feed: active journeys first, then history grouped by date.
class TripHistoryList extends StatelessWidget {
  const TripHistoryList({
    super.key,
    required this.state,
    required this.navigation,
  });
  final TripsListState state;
  final CustomerNavigation navigation;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final cubit = context.read<TripsListCubit>();
    if (state.isLoading && state.items.isEmpty) {
      return Center(child: TamLoadingIndicator(semanticLabel: l.tripsLoading));
    }

    final content = RefreshIndicator(
      onRefresh: cubit.refresh,
      child: NotificationListener<ScrollNotification>(
        onNotification: (notification) {
          if (notification is ScrollUpdateNotification &&
              notification.metrics.extentAfter < 240) {
            cubit.loadMore();
          }
          return false;
        },
        child: ListView(
          key: const Key('trips-activity-feed'),
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsetsDirectional.fromSTEB(
            AppSpacing.lg,
            AppSpacing.sm,
            AppSpacing.lg,
            AppSpacing.xxl,
          ),
          children: state.items.isEmpty
              ? [_EmptyResult(state: state)]
              : _tripSections(context, cubit),
        ),
      ),
    );
    if (state.errorCode == null || state.items.isEmpty) return content;
    return Column(
      children: [
        TripsFailureBanner(errorCode: state.errorCode!, onRetry: cubit.refresh),
        Expanded(child: content),
      ],
    );
  }

  List<Widget> _tripSections(BuildContext context, TripsListCubit cubit) {
    final l = AppLocalizations.of(context);
    final active = state.items.where((trip) => trip.status.isActive).toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    final history = state.items.where((trip) => !trip.status.isActive).toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    final children = <Widget>[];

    for (final trip in active) {
      children.add(
        ActiveTripCard(
          key: ValueKey('active-${trip.id}'),
          trip: trip,
          onFollow: () => navigation.openActiveTrip(id: trip.id),
        ),
      );
      children.add(const SizedBox(height: AppSpacing.md));
    }

    DateTime? previousDay;
    for (final trip in history) {
      final day = trip.createdAt.toLocal();
      if (previousDay == null || !DateUtils.isSameDay(previousDay, day)) {
        children.add(
          Padding(
            padding: const EdgeInsetsDirectional.only(
              top: AppSpacing.sm,
              bottom: AppSpacing.sm,
            ),
            child: Text(
              _dateHeader(context, day),
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ),
        );
        previousDay = day;
      }
      children.add(
        TripCard(
          key: ValueKey(trip.id),
          trip: trip,
          onTap: () => navigation.openTrip(trip.id),
        ),
      );
      children.add(const SizedBox(height: AppSpacing.md));
    }

    if (state.nextCursor != null || state.moreErrorCode != null) {
      children.add(
        Column(
          children: [
            if (state.moreErrorCode != null)
              Text(tripsErrorLabel(l, state.moreErrorCode)),
            TamButton.secondary(
              label: state.moreErrorCode == null
                  ? l.tripsLoadMore
                  : l.tripsRetry,
              isLoading: state.isLoadingMore,
              onPressed: state.isLoadingMore ? null : cubit.loadMore,
            ),
          ],
        ),
      );
    }
    return children;
  }

  String _dateHeader(BuildContext context, DateTime date) {
    final l = AppLocalizations.of(context);
    final now = DateTime.now();
    if (DateUtils.isSameDay(date, now)) return l.tripsToday;
    final yesterday = DateTime(now.year, now.month, now.day - 1);
    if (DateUtils.isSameDay(date, yesterday)) return l.tripsYesterday;
    return DateFormat.yMMMd(
      Localizations.localeOf(context).languageCode,
    ).format(date);
  }
}

class _EmptyResult extends StatelessWidget {
  const _EmptyResult({required this.state});
  final TripsListState state;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final hasError = state.errorCode != null;
    return Padding(
      padding: const EdgeInsetsDirectional.symmetric(vertical: AppSpacing.xxl),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            hasError ? Icons.wifi_off_outlined : Icons.route_outlined,
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
              onPressed: context.read<TripsListCubit>().refresh,
            ),
          ],
        ],
      ),
    );
  }
}
