import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:tam_customer/app/theme/app_tokens.dart';
import 'package:tam_customer/features/trips/presentation/widgets/trip_journey.dart';
import 'package:tam_customer/l10n/app_localizations.dart';
import 'package:tam_customer/shared/domain/trip.dart';
import 'package:tam_customer/shared/formatters/ride_time_label.dart';
import 'package:tam_customer/shared/presentation/trip_display.dart';

/// A crafted journey ticket: status and route first, price second.
class TripCard extends StatefulWidget {
  const TripCard({super.key, required this.trip, required this.onTap});

  final Trip trip;
  final VoidCallback onTap;

  @override
  State<TripCard> createState() => _TripCardState();
}

class _TripCardState extends State<TripCard> {
  bool _pressed = false;

  String _localizedFare(BuildContext context) {
    final fare = tripMoneyLabel(context, widget.trip.booking.fare);
    if (Localizations.localeOf(context).languageCode == 'ar' &&
        widget.trip.booking.fare.currency == 'SYP') {
      return fare.replaceFirst(
        'SYP',
        AppLocalizations.of(context).tripsCurrencySyp,
      );
    }
    return fare;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final l = AppLocalizations.of(context);
    final locale = Localizations.localeOf(context).languageCode;
    final trip = widget.trip;
    final isCompleted = trip.status == TripStatus.completed;
    final artwork = switch (trip.status) {
      TripStatus.completed => 'assets/notifications/ride_completed.webp',
      TripStatus.cancelled => 'assets/notifications/ride_cancelled.webp',
      TripStatus.noDriver => 'assets/notifications/ride_repeat.webp',
      _ => 'assets/notifications/ride_scheduled.webp',
    };
    final tone = tripStatusColors(context, trip.status);
    final date = DateFormat.MMMd(locale).format(trip.createdAt.toLocal());
    final time = DateFormat.jm(locale).format(trip.createdAt.toLocal());

    return AnimatedScale(
      scale: _pressed ? .986 : 1,
      duration: MediaQuery.disableAnimationsOf(context)
          ? Duration.zero
          : AppMotion.short,
      curve: AppMotion.easeOut,
      child: Material(
        color: colors.surfaceContainerLowest,
        elevation: AppElevation.raised,
        shadowColor: colors.shadow.withValues(alpha: .08),
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(22),
          side: BorderSide(color: colors.outlineVariant.withValues(alpha: .8)),
        ),
        child: InkWell(
          onTap: widget.onTap,
          onHighlightChanged: (pressed) {
            if (mounted) setState(() => _pressed = pressed);
          },
          child: Stack(
            children: [
              PositionedDirectional(
                start: 0,
                top: AppSpacing.lg,
                bottom: AppSpacing.lg,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: tone.foreground.withValues(alpha: .68),
                    borderRadius: const BorderRadiusDirectional.only(
                      topEnd: Radius.circular(3),
                      bottomEnd: Radius.circular(3),
                    ),
                  ),
                  child: const SizedBox(width: 3),
                ),
              ),
              Padding(
                padding: const EdgeInsetsDirectional.fromSTEB(16, 13, 16, 13),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Wrap(
                      alignment: WrapAlignment.spaceBetween,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      spacing: AppSpacing.sm,
                      runSpacing: AppSpacing.sm,
                      children: [
                        TripStatusBadge(status: trip.status),
                        _TripDate(date: date, time: time),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.md),
                    Divider(
                      color: colors.outlineVariant.withValues(alpha: .7),
                      height: 1,
                    ),
                    const SizedBox(height: AppSpacing.md),
                    Row(
                      children: [
                        Expanded(
                          child: TripJourney(
                            pickup: trip.booking.pickup,
                            destination: trip.booking.destination,
                          ),
                        ),
                        const SizedBox(width: AppSpacing.md),
                        DecoratedBox(
                          decoration: BoxDecoration(
                            color: isCompleted
                                ? colors.primaryContainer.withValues(alpha: .65)
                                : colors.errorContainer.withValues(alpha: .65),
                            borderRadius: BorderRadius.circular(15),
                          ),
                          child: SizedBox(
                            width: 48,
                            height: 48,
                            child: ExcludeSemantics(
                              child: Image.asset(
                                artwork,
                                width: 45,
                                height: 45,
                                fit: BoxFit.contain,
                                filterQuality: FilterQuality.medium,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    if (trip.booking.scheduledAt != null) ...[
                      const SizedBox(height: AppSpacing.sm),
                      Text(
                        l.tripsScheduledAt(
                          rideTimeLabel(context, trip.booking.scheduledAt!),
                        ),
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: colors.onSurfaceVariant,
                        ),
                      ),
                    ],
                    const SizedBox(height: AppSpacing.md),
                    Divider(
                      color: colors.outlineVariant.withValues(alpha: .7),
                      height: 1,
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Wrap(
                      alignment: isCompleted
                          ? WrapAlignment.spaceBetween
                          : WrapAlignment.end,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      spacing: AppSpacing.sm,
                      runSpacing: AppSpacing.sm,
                      children: [
                        // A cancelled request has no completed fare to charge.
                        // Keep the amount for completed trips, without a redundant
                        // visible heading. VoiceOver/TalkBack retain the context.
                        if (isCompleted)
                          Semantics(
                            label: '${l.tripsFare}: ${_localizedFare(context)}',
                            child: ExcludeSemantics(
                              child: Text(
                                _localizedFare(context),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: theme.textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w800,
                                  color: colors.primary,
                                ),
                              ),
                            ),
                          ),
                        DecoratedBox(
                          decoration: BoxDecoration(
                            color: colors.primaryContainer.withValues(
                              alpha: .7,
                            ),
                            borderRadius: BorderRadius.circular(40),
                          ),
                          child: Padding(
                            padding: const EdgeInsetsDirectional.symmetric(
                              horizontal: AppSpacing.md,
                              vertical: AppSpacing.sm,
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.arrow_back_rounded,
                                  size: 20,
                                  color: colors.primary,
                                ),
                                const SizedBox(width: AppSpacing.xs),
                                Flexible(
                                  child: Text(
                                    l.tripsDetails,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: theme.textTheme.labelMedium
                                        ?.copyWith(
                                          color: colors.primary,
                                          fontWeight: FontWeight.w700,
                                        ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TripDate extends StatelessWidget {
  const _TripDate({required this.date, required this.time});

  final String date;
  final String time;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    return Wrap(
      spacing: AppSpacing.sm,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        Icon(
          Icons.calendar_today_outlined,
          size: 14,
          color: colors.onSurfaceVariant,
        ),
        Text(
          date,
          style: theme.textTheme.labelSmall?.copyWith(
            color: colors.onSurfaceVariant,
          ),
        ),
        Text(
          time,
          style: theme.textTheme.labelSmall?.copyWith(
            color: colors.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}
