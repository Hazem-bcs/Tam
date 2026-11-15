import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tam_customer/app/router/customer_navigation.dart';
import 'package:tam_customer/app/theme/app_tokens.dart';
import 'package:tam_customer/features/trips/domain/trips_repository.dart';
import 'package:tam_customer/features/trips/presentation/bloc/trips_list_cubit.dart';
import 'package:tam_customer/l10n/app_localizations.dart';

/// The burgundy journey motif is Tam's signature, not an unrelated decoration.
class ActivityMasthead extends StatelessWidget {
  const ActivityMasthead({super.key, required this.navigation});
  final CustomerNavigation navigation;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final l = AppLocalizations.of(context);
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: AlignmentDirectional.topStart,
          end: AlignmentDirectional.bottomEnd,
          colors: [colors.primary, colors.onPrimaryContainer],
        ),
        borderRadius: const BorderRadiusDirectional.only(
          bottomStart: Radius.circular(28),
          bottomEnd: Radius.circular(28),
        ),
      ),
      child: Stack(
        clipBehavior: Clip.hardEdge,
        children: [
          PositionedDirectional(
            start: -40,
            top: -25,
            child: IgnorePointer(
              child: SizedBox(
                width: 226,
                height: 164,
                child: CustomPaint(
                  painter: _JourneyMarkPainter(
                    colors.onPrimary.withValues(alpha: 0.16),
                  ),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsetsDirectional.fromSTEB(
              AppSpacing.lg,
              AppSpacing.md,
              AppSpacing.lg,
              AppSpacing.lg,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            l.tripsActivityTitle,
                            style: theme.textTheme.headlineMedium?.copyWith(
                              color: colors.onPrimary,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            l.tripsActivitySubtitle,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: colors.onPrimary.withValues(alpha: 0.76),
                            ),
                          ),
                        ],
                      ),
                    ),
                    _HeaderAction(
                      key: const Key('trips-notifications'),
                      tooltip: l.navNotifications,
                      onTap: navigation.openNotifications,
                      icon: Icons.notifications_none_rounded,
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    const _ActivityFilter(),
                  ],
                ),
                const SizedBox(height: AppSpacing.lg),
                const _ActivityServices(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _HeaderAction extends StatelessWidget {
  const _HeaderAction({
    super.key,
    required this.icon,
    required this.tooltip,
    required this.onTap,
  });
  final IconData icon;
  final String tooltip;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Tooltip(
      message: tooltip,
      child: Material(
        color: colors.onPrimary.withValues(alpha: 0.13),
        borderRadius: BorderRadius.circular(15),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(15),
          child: SizedBox(
            width: 44,
            height: 44,
            child: Icon(icon, color: colors.onPrimary, size: 23),
          ),
        ),
      ),
    );
  }
}

class _ActivityFilter extends StatelessWidget {
  const _ActivityFilter();

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final colors = Theme.of(context).colorScheme;
    final current = context.select(
      (TripsListCubit cubit) => cubit.state.filter,
    );
    return Material(
      color: colors.onPrimary.withValues(alpha: 0.13),
      borderRadius: BorderRadius.circular(15),
      child: PopupMenuButton<TripsFilter>(
        key: const Key('trips-filter-control'),
        tooltip: l.tripsFilterLabel,
        initialValue: current,
        icon: Icon(Icons.tune_rounded, color: colors.onPrimary, size: 22),
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
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (current == filter) ...[
                    Icon(Icons.check_rounded, color: colors.primary, size: 18),
                    const SizedBox(width: AppSpacing.sm),
                  ],
                  Text(label),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class _ActivityServices extends StatelessWidget {
  const _ActivityServices();

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final colors = Theme.of(context).colorScheme;
    return Material(
      color: colors.surfaceContainerLowest,
      elevation: AppElevation.raised,
      borderRadius: BorderRadius.circular(19),
      child: Padding(
        padding: const EdgeInsets.all(4),
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: _Service(label: l.tripsServiceRides, selected: true),
              ),
              Expanded(
                child: _Service(
                  label: l.tripsServiceShopping,
                  subtitle: l.tripsSoon,
                ),
              ),
              Expanded(
                child: _Service(
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

class _Service extends StatelessWidget {
  const _Service({required this.label, this.subtitle, this.selected = false});
  final String label;
  final String? subtitle;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return Semantics(
      selected: selected,
      enabled: selected,
      button: true,
      child: AnimatedContainer(
        duration: MediaQuery.disableAnimationsOf(context)
            ? Duration.zero
            : const Duration(milliseconds: 220),
        curve: Curves.easeOutCubic,
        constraints: const BoxConstraints(minHeight: 51),
        padding: const EdgeInsetsDirectional.symmetric(
          vertical: AppSpacing.xs,
          horizontal: AppSpacing.xs,
        ),
        decoration: BoxDecoration(
          color: selected ? scheme.primary : scheme.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(15),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              textAlign: TextAlign.center,
              style: theme.textTheme.labelMedium?.copyWith(
                fontWeight: selected ? FontWeight.w800 : FontWeight.w600,
                color: selected ? scheme.onPrimary : scheme.onSurface,
              ),
            ),
            if (subtitle != null)
              Text(
                subtitle!,
                textAlign: TextAlign.center,
                style: theme.textTheme.labelSmall?.copyWith(
                  color: scheme.onSurfaceVariant,
                  fontSize: 10,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _JourneyMarkPainter extends CustomPainter {
  const _JourneyMarkPainter(this.color);
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round;
    final path = Path()
      ..moveTo(0, size.height * .19)
      ..cubicTo(
        size.width * .25,
        size.height * .96,
        size.width * .62,
        -.12 * size.height,
        size.width,
        size.height * .7,
      );
    for (final metric in path.computeMetrics()) {
      for (var distance = 0.0; distance < metric.length; distance += 14) {
        canvas.drawPath(
          metric.extractPath(distance, (distance + 7).clamp(0, metric.length)),
          paint,
        );
      }
    }
    final dot = Paint()..color = color;
    canvas.drawCircle(Offset(size.width * .18, size.height * .52), 9, dot);
    canvas.drawCircle(Offset(size.width * .85, size.height * .42), 6, dot);
  }

  @override
  bool shouldRepaint(covariant _JourneyMarkPainter oldDelegate) =>
      oldDelegate.color != color;
}
