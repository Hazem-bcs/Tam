import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tam_customer/app/router/customer_navigation.dart';
import 'package:tam_customer/app/theme/app_tokens.dart';
import 'package:tam_customer/l10n/app_localizations.dart';
import 'package:tam_customer/shared/widgets/tam_button.dart';
import 'package:tam_customer/shared/widgets/tam_loading_indicator.dart';

import '../../domain/customer_notification.dart';
import '../../domain/notifications_repository.dart';
import '../bloc/notifications_cubit.dart';
import '../bloc/notifications_state.dart';
import '../widgets/notification_tile.dart';
import '../widgets/notifications_feedback.dart';
import '../widgets/notifications_filter_bar.dart';
import '../widgets/notifications_overview.dart';

class NotificationsPage extends StatefulWidget {
  const NotificationsPage({super.key, required this.navigation, this.clock});
  final CustomerNavigation navigation;
  final DateTime Function()? clock;

  @override
  State<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  NotificationsFeedFilter _filter = NotificationsFeedFilter.all;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colors = Theme.of(context).colorScheme;
    final theme = Theme.of(context).textTheme;
    return Scaffold(
      backgroundColor: colors.surface,
      appBar: AppBar(
        toolbarHeight: 64,
        backgroundColor: colors.surface,
        titleSpacing: 0,
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.notifications_none_rounded,
              color: colors.primary,
              size: 24,
            ),
            const SizedBox(width: 8),
            Flexible(
              child: Text(
                l10n.navNotifications,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: theme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: colors.onSurface,
                ),
              ),
            ),
          ],
        ),
        actions: [
          BlocBuilder<NotificationsCubit, NotificationsState>(
            buildWhen: (a, b) =>
                a.unreadCount != b.unreadCount ||
                a.markingAll != b.markingAll ||
                a.isBusy != b.isBusy,
            builder: (context, state) => IconButton(
              key: const Key('notifications-mark-all'),
              tooltip: l10n.notificationsMarkAll,
              onPressed:
                  state.unreadCount != null &&
                      state.unreadCount! > 0 &&
                      !state.isBusy
                  ? () => unawaited(
                      context.read<NotificationsCubit>().markAllAsRead(),
                    )
                  : null,
              icon: const Icon(Icons.done_all_rounded),
            ),
          ),
          BlocBuilder<NotificationsCubit, NotificationsState>(
            buildWhen: (a, b) =>
                a.isBusy != b.isBusy || a.refreshing != b.refreshing,
            builder: (context, state) => IconButton(
              key: const Key('notifications-refresh'),
              tooltip: l10n.notificationsRefresh,
              onPressed: state.isBusy
                  ? null
                  : () => unawaited(
                      context.read<NotificationsCubit>().load(refresh: true),
                    ),
              icon: const Icon(Icons.refresh_rounded),
            ),
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 740),
            child: BlocBuilder<NotificationsCubit, NotificationsState>(
              builder: (context, state) => _body(context, state),
            ),
          ),
        ),
      ),
    );
  }

  Widget _body(BuildContext context, NotificationsState state) {
    final l10n = AppLocalizations.of(context);
    final cubit = context.read<NotificationsCubit>();
    if (state.status == NotificationsLoadStatus.initial ||
        state.status == NotificationsLoadStatus.loading) {
      return Center(
        child: TamLoadingIndicator(semanticLabel: l10n.notificationsLoading),
      );
    }
    if (state.status == NotificationsLoadStatus.error ||
        (state.items.isEmpty && state.error != null)) {
      return NotificationsFeedbackState(
        icon: Icons.wifi_off_rounded,
        title: l10n.notificationsErrorTitle,
        message: _errorMessage(l10n, state.error),
        action: l10n.notificationsRetry,
        onAction: cubit.load,
      );
    }
    if (state.items.isEmpty) {
      return RefreshIndicator(
        onRefresh: () => cubit.load(refresh: true),
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          children: [
            SizedBox(
              height: 420,
              child: NotificationsFeedbackState(
                icon: Icons.notifications_none_rounded,
                title: l10n.notificationsEmptyTitle,
                message: l10n.notificationsEmptyBody,
                action: l10n.notificationsRefresh,
                onAction: () => cubit.load(refresh: true),
              ),
            ),
          ],
        ),
      );
    }

    final now = (widget.clock?.call() ?? DateTime.now()).toLocal();
    final visible = state.items.where(_filter.accepts).toList(growable: false);
    final entries = <Widget>[];
    String? previousGroup;
    for (final notification in visible) {
      final group = _group(notification.createdAt.toLocal(), now);
      if (group != previousGroup) {
        previousGroup = group;
        entries.add(_groupHeader(context, group));
      }
      entries.add(
        Padding(
          padding: const EdgeInsetsDirectional.only(bottom: 10),
          child: NotificationTile(
            notification: notification,
            isPending:
                state.pendingReadIds.contains(notification.id) ||
                state.markingAll,
            onTap: () => unawaited(_open(context, notification)),
            onMarkRead: notification.isUnread
                ? () => unawaited(cubit.markAsRead(notification.id))
                : null,
          ),
        ),
      );
    }
    return RefreshIndicator(
      onRefresh: () => cubit.load(refresh: true),
      child: ListView(
        key: const Key('notifications-list'),
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsetsDirectional.fromSTEB(18, 10, 18, 32),
        children: [
          NotificationsOverview(unreadCount: state.unreadCount),
          const SizedBox(height: 16),
          NotificationsFilterBar(
            selected: _filter,
            onChanged: (selection) => setState(() => _filter = selection),
          ),
          if (state.error != null || state.mutationError != null) ...[
            const SizedBox(height: 12),
            NotificationsErrorBanner(
              message: state.mutationError != null
                  ? l10n.notificationsMutationError
                  : _errorMessage(l10n, state.error),
            ),
          ],
          if (visible.isEmpty) ...[
            const SizedBox(height: 30),
            Center(
              child: Column(
                children: [
                  Icon(
                    Icons.inbox_outlined,
                    size: 42,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    _filter == NotificationsFeedFilter.unread
                        ? l10n.notificationsNoUnread
                        : l10n.notificationsNoMatches,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                  const SizedBox(height: 8),
                  TextButton(
                    key: const Key('notifications-show-all'),
                    onPressed: () => setState(() {
                      _filter = NotificationsFeedFilter.all;
                    }),
                    child: Text(l10n.notificationsShowAll),
                  ),
                ],
              ),
            ),
          ],
          ...entries,
          if (state.moreError != null) ...[
            NotificationsErrorBanner(message: l10n.notificationsMoreError),
            const SizedBox(height: AppSpacing.sm),
          ],
          if (state.hasMore)
            TamButton.secondary(
              label: l10n.notificationsLoadMore,
              isLoading: state.loadingMore,
              loadingLabel: l10n.notificationsLoadingMore,
              onPressed: state.isBusy
                  ? null
                  : () => unawaited(cubit.loadMore()),
            ),
        ],
      ),
    );
  }

  Widget _groupHeader(BuildContext context, String group) {
    final l10n = AppLocalizations.of(context);
    final colors = Theme.of(context).colorScheme;
    final label = switch (group) {
      'today' => l10n.notificationsToday,
      'yesterday' => l10n.notificationsYesterday,
      _ => l10n.notificationsEarlier,
    };
    return Padding(
      padding: const EdgeInsetsDirectional.fromSTEB(4, 24, 4, 12),
      child: Row(
        children: [
          Icon(Icons.calendar_today_outlined, size: 17, color: colors.primary),
          const SizedBox(width: 8),
          Text(
            label,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
              color: colors.onSurface,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(child: Divider(color: colors.outlineVariant, thickness: 1)),
        ],
      ),
    );
  }

  String _group(DateTime date, DateTime now) {
    final today = DateUtils.dateOnly(now);
    final day = DateUtils.dateOnly(date);
    if (day == today) return 'today';
    if (day == today.subtract(const Duration(days: 1))) return 'yesterday';
    return 'earlier';
  }

  Future<void> _open(
    BuildContext context,
    CustomerNotification notification,
  ) async {
    await context.read<NotificationsCubit>().markAsRead(notification.id);
    if (!context.mounted) return;
    final target = notification.target;
    if (!target.canOpen) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            AppLocalizations.of(context).notificationsUnavailableTarget,
          ),
        ),
      );
      return;
    }
    switch (target.destination) {
      case NotificationDestination.home:
        widget.navigation.openHome();
      case NotificationDestination.trips:
        widget.navigation.openTrips();
      case NotificationDestination.trip:
        widget.navigation.openTrip(target.tripId!);
      case NotificationDestination.unknown:
        break;
    }
  }

  String _errorMessage(
    AppLocalizations l10n,
    NotificationsFailureCode? error,
  ) => error == NotificationsFailureCode.serviceUnavailable
      ? l10n.notificationsOfflineBody
      : l10n.notificationsErrorBody;
}
