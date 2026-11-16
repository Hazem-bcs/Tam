import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tam_customer/app/router/customer_navigation.dart';
import 'package:tam_customer/app/theme/app_tokens.dart';
import 'package:tam_customer/features/trips/domain/trips_repository.dart';
import 'package:tam_customer/features/trips/presentation/bloc/trips_list_cubit.dart';
import 'package:tam_customer/features/trips/presentation/widgets/active_trip_card.dart';
import 'package:tam_customer/features/trips/presentation/widgets/next_trip_prompt.dart';
import 'package:tam_customer/features/trips/presentation/widgets/trip_card.dart';
import 'package:tam_customer/features/trips/presentation/widgets/trips_failure_banner.dart';
import 'package:tam_customer/l10n/app_localizations.dart';
import 'package:tam_customer/shared/domain/trip.dart';
import 'package:tam_customer/shared/presentation/trip_display.dart';
import 'package:tam_customer/shared/widgets/tam_button.dart';
import 'package:tam_customer/shared/widgets/tam_loading_indicator.dart';

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
    final duration = MediaQuery.disableAnimationsOf(context)
        ? Duration.zero
        : const Duration(milliseconds: 240);

    final content = RefreshIndicator(
      onRefresh: cubit.refresh,
      child: NotificationListener<ScrollNotification>(
        onNotification: (notice) {
          if (notice is ScrollUpdateNotification &&
              notice.metrics.extentAfter < 240) {
            cubit.loadMore();
          }
          return false;
        },
        child: AnimatedSwitcher(
          duration: duration,
          switchInCurve: Curves.easeOutCubic,
          switchOutCurve: Curves.easeInCubic,
          transitionBuilder: (child, animation) => FadeTransition(
            opacity: animation,
            child: SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0, .025),
                end: Offset.zero,
              ).animate(animation),
              child: child,
            ),
          ),
          child: ListView(
            key: ValueKey(
              'trips-activity-${state.filter.name}-${state.items.isEmpty}',
            ),
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsetsDirectional.fromSTEB(
              AppSpacing.lg,
              AppSpacing.lg,
              AppSpacing.lg,
              AppSpacing.xxl,
            ),
            children: state.items.isEmpty
                ? [_EmptyResult(state: state)]
                : _sections(context, cubit),
          ),
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

  List<Widget> _sections(BuildContext context, TripsListCubit cubit) {
    final l = AppLocalizations.of(context);
    final live = state.items.where((trip) => trip.status.isActive).toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    final history = state.items.where((trip) => !trip.status.isActive).toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));

    final children = <Widget>[];
    var position = 0;
    if (live.isNotEmpty) {
      children.add(
        _SectionHeading(
          label: l.tripsLiveHeading,
          icon: Icons.radio_button_checked_rounded,
        ),
      );
      children.add(const SizedBox(height: AppSpacing.md));
      for (final trip in live) {
        children.add(
          _Reveal(
            order: position++,
            child: ActiveTripCard(
              key: ValueKey('active-${trip.id}'),
              trip: trip,
              onFollow: () => navigation.openActiveTrip(id: trip.id),
            ),
          ),
        );
        children.add(const SizedBox(height: AppSpacing.md));
      }
    }
    if (history.isNotEmpty) {
      children.add(
        _SectionHeading(
          label: l.tripsHistoryHeading,
          count: l.tripsVisibleCount(history.length),
          icon: Icons.route_rounded,
        ),
      );
      children.add(const SizedBox(height: AppSpacing.md));
      for (final trip in history) {
        children.add(
          _Reveal(
            order: position++,
            child: TripCard(
              key: ValueKey(trip.id),
              trip: trip,
              onTap: () => navigation.openTrip(trip.id),
            ),
          ),
        );
        children.add(const SizedBox(height: AppSpacing.md));
      }
    }
    if (state.filter == TripsFilter.all &&
        live.isEmpty &&
        history.isNotEmpty &&
        state.nextCursor == null) {
      children.add(
        _Reveal(
          order: position++,
          child: NextTripPrompt(onRequestRide: navigation.openRideRequest),
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
}

class _SectionHeading extends StatelessWidget {
  const _SectionHeading({required this.label, required this.icon, this.count});
  final String label;
  final IconData icon;
  final String? count;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    return Wrap(
      alignment: WrapAlignment.spaceBetween,
      crossAxisAlignment: WrapCrossAlignment.center,
      spacing: AppSpacing.sm,
      runSpacing: AppSpacing.xs,
      children: [
        Wrap(
          crossAxisAlignment: WrapCrossAlignment.center,
          spacing: AppSpacing.sm,
          runSpacing: AppSpacing.xs,
          children: [
            DecoratedBox(
              decoration: BoxDecoration(
                color: colors.primaryContainer,
                borderRadius: BorderRadius.circular(11),
              ),
              child: Padding(
                padding: const EdgeInsets.all(8),
                child: Icon(icon, color: colors.primary, size: 18),
              ),
            ),
            Text(
              label,
              style: text.titleMedium?.copyWith(
                fontWeight: FontWeight.w800,
                color: colors.onSurface,
              ),
            ),
          ],
        ),
        if (count != null)
          Text(
            count!,
            style: text.labelSmall?.copyWith(color: colors.onSurfaceVariant),
          ),
      ],
    );
  }
}

class _Reveal extends StatelessWidget {
  const _Reveal({required this.order, required this.child});
  final int order;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    if (MediaQuery.disableAnimationsOf(context)) return child;
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: Duration(milliseconds: 240 + (order * 55).clamp(0, 275)),
      curve: Curves.easeOutCubic,
      builder: (context, progress, child) => Opacity(
        opacity: progress,
        child: Transform.translate(
          offset: Offset(0, 14 * (1 - progress)),
          child: child,
        ),
      ),
      child: child,
    );
  }
}

class _EmptyResult extends StatelessWidget {
  const _EmptyResult({required this.state});
  final TripsListState state;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final hasError = state.errorCode != null;
    return Padding(
      padding: const EdgeInsetsDirectional.symmetric(vertical: AppSpacing.xxl),
      child: Column(
        children: [
          Container(
            width: 82,
            height: 82,
            decoration: BoxDecoration(
              color: colors.primaryContainer,
              borderRadius: BorderRadius.circular(27),
            ),
            child: Icon(
              hasError ? Icons.wifi_off_rounded : Icons.route_rounded,
              color: colors.primary,
              size: 36,
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          Text(
            hasError ? l.tripsErrorTitle : l.tripsEmptyTitle,
            style: theme.textTheme.titleLarge,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            hasError
                ? tripsErrorLabel(l, state.errorCode)
                : l.tripsEmptyDescription,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: colors.onSurfaceVariant,
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
