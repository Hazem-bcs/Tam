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
import '../widgets/notifications_overview.dart';

class NotificationsPage extends StatefulWidget {
  const NotificationsPage({super.key, required this.navigation, this.clock});
  final CustomerNavigation navigation;
  final DateTime Function()? clock;

  @override
  State<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  bool _unreadOnly = false;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      backgroundColor: const Color(0xFFFCF9F8),
      appBar: AppBar(
        toolbarHeight: 60,
        backgroundColor: const Color(0xFFFCF9F8),
        title: Text(
          l10n.navNotifications,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontSize: 19,
            fontWeight: FontWeight.w800,
            color: const Color(0xFF291C21),
          ),
        ),
        actions: [
          BlocBuilder<NotificationsCubit, NotificationsState>(
            buildWhen: (before, after) =>
                before.unreadCount != after.unreadCount ||
                before.markingAll != after.markingAll ||
                before.isBusy != after.isBusy,
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
              icon: const Icon(Icons.done_all_outlined),
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
      return _MessageState(
        icon: Icons.wifi_off_outlined,
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
              child: _MessageState(
                icon: Icons.notifications_none,
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
    final visible = _unreadOnly
        ? state.items.where((item) => item.isUnread).toList(growable: false)
        : state.items;
    final entries = <Widget>[];
    String? previousGroup;
    for (final notification in visible) {
      final group = _group(notification.createdAt.toLocal(), now);
      if (group != previousGroup) {
        previousGroup = group;
        entries.add(
          Padding(
            padding: const EdgeInsetsDirectional.fromSTEB(5, 14, 5, 8),
            child: Row(
              children: [
                Container(
                  height: 6,
                  width: 6,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Color(0xFF8D153A),
                  ),
                ),
                const SizedBox(width: 9),
                Text(
                  switch (group) {
                    'today' => l10n.notificationsToday,
                    'yesterday' => l10n.notificationsYesterday,
                    _ => l10n.notificationsEarlier,
                  },
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFF5E4C53),
                  ),
                ),
                const SizedBox(width: 11),
                const Expanded(
                  child: Divider(color: Color(0xFFEADFE2), thickness: 1),
                ),
              ],
            ),
          ),
        );
      }
      entries.add(
        Padding(
          padding: const EdgeInsetsDirectional.only(bottom: 5),
          child: NotificationTile(
            notification: notification,
            isPending:
                state.pendingReadIds.contains(notification.id) ||
                state.markingAll,
            onTap: () => unawaited(_open(context, notification)),
          ),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () => cubit.load(refresh: true),
      child: ListView(
        key: const Key('notifications-list'),
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsetsDirectional.fromSTEB(18, 8, 18, 28),
        children: [
          NotificationsOverview(unreadCount: state.unreadCount),
          const SizedBox(height: 15),
          Row(
            children: [
              Expanded(
                child: _filterTab(
                  key: const Key('notifications-filter-all'),
                  label: l10n.notificationsAllFilter,
                  selected: !_unreadOnly,
                  onTap: () => setState(() => _unreadOnly = false),
                ),
              ),
              const SizedBox(width: 9),
              Expanded(
                child: _filterTab(
                  key: const Key('notifications-filter-unread'),
                  label: l10n.notificationsUnreadFilter,
                  selected: _unreadOnly,
                  onTap: () => setState(() => _unreadOnly = true),
                ),
              ),
              const SizedBox(width: 5),
              IconButton(
                key: const Key('notifications-refresh'),
                tooltip: l10n.notificationsRefresh,
                onPressed: state.isBusy
                    ? null
                    : () => unawaited(cubit.load(refresh: true)),
                icon: state.refreshing
                    ? const TamLoadingIndicator(size: AppDimensions.iconSize)
                    : const Icon(Icons.refresh_rounded, size: 21),
                color: const Color(0xFF8D153A),
              ),
            ],
          ),
          if (state.error != null || state.mutationError != null) ...[
            const SizedBox(height: 9),
            _MessageBanner(
              message: state.mutationError != null
                  ? l10n.notificationsMutationError
                  : _errorMessage(l10n, state.error),
            ),
          ],
          if (_unreadOnly && visible.isEmpty) ...[
            const SizedBox(height: 26),
            Center(
              child: Column(
                children: [
                  const Icon(
                    Icons.check_circle_outline_rounded,
                    size: 35,
                    color: Color(0xFF8D153A),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    l10n.notificationsNoUnread,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontSize: 14,
                      color: const Color(0xFF5E4C53),
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextButton(
                    key: const Key('notifications-show-all'),
                    onPressed: () => setState(() => _unreadOnly = false),
                    child: Text(l10n.notificationsShowAll),
                  ),
                ],
              ),
            ),
          ],
          ...entries,
          if (state.moreError != null) ...[
            _MessageBanner(message: l10n.notificationsMoreError),
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

  Widget _filterTab({
    required Key key,
    required String label,
    required bool selected,
    required VoidCallback onTap,
  }) {
    final reduceMotion = MediaQuery.disableAnimationsOf(context);
    return Material(
      color: Colors.transparent,
      child: InkWell(
        key: key,
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: AnimatedContainer(
          duration: reduceMotion
              ? Duration.zero
              : const Duration(milliseconds: 170),
          curve: Curves.easeInOut,
          decoration: BoxDecoration(
            color: selected ? const Color(0xFF8D153A) : const Color(0xFFF3ECEE),
            borderRadius: BorderRadius.circular(14),
          ),
          constraints: const BoxConstraints(minHeight: 43),
          alignment: Alignment.center,
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 9),
          child: Text(
            label,
            maxLines: 2,
            textAlign: TextAlign.center,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
              fontSize: 12,
              fontWeight: selected ? FontWeight.w800 : FontWeight.w600,
              color: selected ? Colors.white : const Color(0xFF685760),
            ),
          ),
        ),
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

class _MessageBanner extends StatelessWidget {
  const _MessageBanner({required this.message});
  final String message;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsetsDirectional.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: colors.errorContainer,
        borderRadius: BorderRadius.circular(AppRadii.md),
      ),
      child: Text(message, style: TextStyle(color: colors.onErrorContainer)),
    );
  }
}

class _MessageState extends StatelessWidget {
  const _MessageState({
    required this.icon,
    required this.title,
    required this.message,
    required this.action,
    required this.onAction,
  });
  final IconData icon;
  final String title;
  final String message;
  final String action;
  final VoidCallback onAction;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsetsDirectional.all(AppSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 48, color: theme.colorScheme.primary),
            const SizedBox(height: AppSpacing.lg),
            Text(
              title,
              textAlign: TextAlign.center,
              style: theme.textTheme.titleLarge,
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              message,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium,
            ),
            const SizedBox(height: AppSpacing.xl),
            TamButton.secondary(
              label: action,
              onPressed: onAction,
              fullWidth: false,
            ),
          ],
        ),
      ),
    );
  }
}
