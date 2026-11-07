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

class NotificationsPage extends StatelessWidget {
  const NotificationsPage({super.key, required this.navigation, this.clock});
  final CustomerNavigation navigation;
  final DateTime Function()? clock;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(
          l10n.navNotifications,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
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
    if (state.status == NotificationsLoadStatus.error) {
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

    final now = (clock?.call() ?? DateTime.now()).toLocal();
    final entries = <Widget>[];
    String? previousGroup;
    for (final notification in state.items) {
      final group = _group(notification.createdAt.toLocal(), now);
      if (group != previousGroup) {
        previousGroup = group;
        entries.add(
          Padding(
            padding: const EdgeInsetsDirectional.only(
              top: AppSpacing.lg,
              bottom: AppSpacing.sm,
            ),
            child: Text(switch (group) {
              'today' => l10n.notificationsToday,
              'yesterday' => l10n.notificationsYesterday,
              _ => l10n.notificationsEarlier,
            }, style: Theme.of(context).textTheme.titleSmall),
          ),
        );
      }
      entries.add(
        Padding(
          padding: const EdgeInsetsDirectional.only(bottom: AppSpacing.md),
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
        padding: const EdgeInsetsDirectional.fromSTEB(
          AppSpacing.lg,
          AppSpacing.sm,
          AppSpacing.lg,
          AppSpacing.xl,
        ),
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  state.unreadCount == null
                      ? l10n.notificationsUnknownCount
                      : l10n.notificationsUnreadCount(state.unreadCount!),
                  style: Theme.of(context).textTheme.labelLarge,
                ),
              ),
              IconButton(
                tooltip: l10n.notificationsRefresh,
                onPressed: state.isBusy
                    ? null
                    : () => unawaited(cubit.load(refresh: true)),
                icon: state.refreshing
                    ? const TamLoadingIndicator(size: AppDimensions.iconSize)
                    : const Icon(Icons.refresh_outlined),
              ),
            ],
          ),
          if (state.error != null || state.mutationError != null) ...[
            _MessageBanner(
              message: state.mutationError != null
                  ? l10n.notificationsMutationError
                  : _errorMessage(l10n, state.error),
            ),
            const SizedBox(height: AppSpacing.sm),
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
        navigation.openHome();
      case NotificationDestination.trips:
        navigation.openTrips();
      case NotificationDestination.trip:
        navigation.openTrip(target.tripId!);
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
