import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tam_customer/app/theme/app_tokens.dart';
import 'package:tam_customer/features/trips/domain/trips_repository.dart';
import 'package:tam_customer/features/trips/presentation/bloc/trips_list_cubit.dart';
import 'package:tam_customer/l10n/app_localizations.dart';

/// A compact filter action. The choices live in a sheet, not over trip cards.
class TripStatusFilter extends StatelessWidget {
  const TripStatusFilter({super.key});

  Future<void> _showFilters(BuildContext context, TripsFilter selected) async {
    final l = AppLocalizations.of(context);
    final colors = Theme.of(context).colorScheme;
    final type = Theme.of(context).textTheme;
    final choice = await showModalBottomSheet<TripsFilter>(
      context: context,
      useSafeArea: true,
      isScrollControlled: true,
      showDragHandle: true,
      backgroundColor: colors.surface,
      builder: (sheetContext) => SingleChildScrollView(
        child: Center(
          heightFactor: 1,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 520),
            child: Padding(
              padding: const EdgeInsetsDirectional.fromSTEB(
                AppSpacing.lg,
                0,
                AppSpacing.lg,
                AppSpacing.xl,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    l.tripsFilterLabel,
                    style: type.titleLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  for (final (filter, label, icon) in [
                    (TripsFilter.all, l.tripsAll, Icons.grid_view_rounded),
                    (
                      TripsFilter.active,
                      l.tripsActive,
                      Icons.timelapse_rounded,
                    ),
                    (
                      TripsFilter.completed,
                      l.tripsCompletedFilter,
                      Icons.check_circle_outline_rounded,
                    ),
                    (
                      TripsFilter.cancelled,
                      l.tripsCancelledFilter,
                      Icons.cancel_outlined,
                    ),
                  ]) ...[
                    Material(
                      color: selected == filter
                          ? colors.primaryContainer.withValues(alpha: 0.6)
                          : colors.surfaceContainerLowest,
                      borderRadius: BorderRadius.circular(AppRadii.lg),
                      child: InkWell(
                        key: Key('trips-filter-${filter.name}'),
                        onTap: () => Navigator.pop(sheetContext, filter),
                        borderRadius: BorderRadius.circular(AppRadii.lg),
                        child: Padding(
                          padding: const EdgeInsetsDirectional.symmetric(
                            horizontal: AppSpacing.md,
                            vertical: AppSpacing.sm,
                          ),
                          child: Row(
                            children: [
                              Icon(
                                icon,
                                color: selected == filter
                                    ? colors.primary
                                    : colors.onSurfaceVariant,
                                size: 22,
                              ),
                              const SizedBox(width: AppSpacing.md),
                              Expanded(
                                child: Text(
                                  label,
                                  style: type.titleSmall?.copyWith(
                                    color: colors.onSurface,
                                    fontWeight: selected == filter
                                        ? FontWeight.w700
                                        : FontWeight.w500,
                                  ),
                                ),
                              ),
                              if (selected == filter)
                                Icon(
                                  Icons.check_rounded,
                                  color: colors.primary,
                                  size: 22,
                                ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xs),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
    if (context.mounted && choice != null && choice != selected) {
      await context.read<TripsListCubit>().selectFilter(choice);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final colors = Theme.of(context).colorScheme;
    final selected = context.select(
      (TripsListCubit cubit) => cubit.state.filter,
    );
    return Tooltip(
      message: l.tripsFilterLabel,
      child: Material(
        color: colors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(AppRadii.md),
        child: InkWell(
          key: const Key('trips-filter-control'),
          onTap: () => _showFilters(context, selected),
          borderRadius: BorderRadius.circular(AppRadii.md),
          child: SizedBox(
            width: AppDimensions.minTapTarget,
            height: AppDimensions.minTapTarget,
            child: Stack(
              alignment: Alignment.center,
              children: [
                Icon(Icons.tune_rounded, color: colors.primary, size: 22),
                if (selected != TripsFilter.all)
                  PositionedDirectional(
                    top: 8,
                    end: 8,
                    child: CircleAvatar(
                      radius: 3,
                      backgroundColor: colors.primary,
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
