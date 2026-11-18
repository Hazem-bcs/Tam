import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tam_customer/app/router/customer_navigation.dart';
import 'package:tam_customer/app/theme/app_tokens.dart';
import 'package:tam_customer/l10n/app_localizations.dart';
import 'package:tam_customer/shared/widgets/tam_button.dart';
import 'package:tam_customer/shared/widgets/tam_loading_indicator.dart';
import 'package:tam_customer/shared/widgets/tam_snack_bar.dart';

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
        automaticallyImplyLeading: false,
        toolbarHeight: 70,
        backgroundColor: colors.surface,
        surfaceTintColor: colors.surface,
        elevation: 0,
        scrolledUnderElevation: 0,
        leadingWidth: 70,
        leading: Padding(
          padding: const EdgeInsetsDirectional.only(start: 16, end: 6),
          child: Center(
            child: SizedBox.square(
              dimension: 48,
              child: IconButton(
                key: const Key('notifications-back'),
                tooltip: MaterialLocalizations.of(context).backButtonTooltip,
                onPressed: () {
                  final navigator = Navigator.of(context);
                  if (navigator.canPop()) {
                    navigator.pop();
                  } else {
                    widget.navigation.openHome();
                  }
                },
                icon: const IconTheme(
                  data: IconThemeData(size: 20),
                  child: BackButtonIcon(),
                ),
                style: IconButton.styleFrom(
                  foregroundColor: colors.onSurface,
                  backgroundColor: colors.surfaceContainerLowest,
                  side: BorderSide(color: colors.outlineVariant),
                  minimumSize: const Size.square(48),
                ),
              ),
            ),
          ),
        ),
        titleSpacing: 2,
        title: Text(
          l10n.navNotifications,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: theme.titleLarge?.copyWith(
            fontWeight: FontWeight.w800,
            color: colors.onSurface,
          ),
        ),
        actions: [
          BlocBuilder<NotificationsCubit, NotificationsState>(
            buildWhen: (a, b) =>
                a.unreadCount != b.unreadCount ||
                a.markingAll != b.markingAll ||
                a.isBusy != b.isBusy,
            builder: (context, state) => Padding(
              padding: const EdgeInsetsDirectional.only(end: 16),
              child: IconButton(
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
                icon: const Icon(Icons.mark_email_read_outlined, size: 22),
                style: IconButton.styleFrom(
                  foregroundColor: colors.primary,
                  backgroundColor: colors.primaryContainer,
                  disabledForegroundColor: colors.onSurfaceVariant,
                  disabledBackgroundColor: colors.surfaceContainerLow,
                  side: BorderSide(color: colors.outlineVariant),
                  minimumSize: const Size.square(48),
                ),
              ),
            ),
          ),
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
          padding: const EdgeInsetsDirectional.fromSTEB(18, 0, 18, 10),
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
        padding: const EdgeInsetsDirectional.only(top: 10, bottom: 32),
        children: [
          Padding(
            padding: const EdgeInsetsDirectional.symmetric(horizontal: 18),
            child: NotificationsOverview(unreadCount: state.unreadCount),
          ),
          const SizedBox(height: 16),
          NotificationsFilterBar(
            selected: _filter,
            onChanged: (selection) => setState(() => _filter = selection),
          ),
          if (state.error != null || state.mutationError != null) ...[
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsetsDirectional.symmetric(horizontal: 18),
              child: NotificationsErrorBanner(
                message: state.mutationError != null
                    ? l10n.notificationsMutationError
                    : _errorMessage(l10n, state.error),
              ),
            ),
          ],
          if (visible.isEmpty) ...[
            const SizedBox(height: 30),
            Padding(
              padding: const EdgeInsetsDirectional.symmetric(horizontal: 18),
              child: Center(
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
            ),
          ],
          ...entries,
          if (state.moreError != null) ...[
            Padding(
              padding: const EdgeInsetsDirectional.symmetric(horizontal: 18),
              child: NotificationsErrorBanner(
                message: l10n.notificationsMoreError,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
          ],
          if (state.hasMore)
            Padding(
              padding: const EdgeInsetsDirectional.symmetric(horizontal: 18),
              child: TamButton.secondary(
                label: l10n.notificationsLoadMore,
                isLoading: state.loadingMore,
                loadingLabel: l10n.notificationsLoadingMore,
                onPressed: state.isBusy
                    ? null
                    : () => unawaited(cubit.loadMore()),
              ),
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
      padding: const EdgeInsetsDirectional.fromSTEB(22, 24, 22, 12),
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
      TamSnackBar.show(
        context,
        message: AppLocalizations.of(context).notificationsUnavailableTarget,
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
