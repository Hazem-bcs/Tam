import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:tam_customer/app/theme/app_tokens.dart';
import 'package:tam_customer/features/trips/presentation/widgets/trip_journey.dart';
import 'package:tam_customer/l10n/app_localizations.dart';
import 'package:tam_customer/shared/domain/trip.dart';
import 'package:tam_customer/shared/formatters/ride_time_label.dart';
import 'package:tam_customer/shared/presentation/trip_display.dart';

/// Tam's compact journey ticket: status, route and fare in one visual scan.
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
    final date = DateFormat.MMMd(
      Localizations.localeOf(context).languageCode,
    ).format(widget.trip.createdAt.toLocal());

    return AnimatedScale(
      duration: MediaQuery.disableAnimationsOf(context)
          ? Duration.zero
          : const Duration(milliseconds: 130),
      curve: Curves.easeOutCubic,
      scale: _pressed ? .986 : 1,
      child: Material(
        color: colors.surfaceContainerLowest,
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(22),
          side: BorderSide(color: colors.outlineVariant.withValues(alpha: .9)),
        ),
        child: InkWell(
          onTap: widget.onTap,
          onHighlightChanged: (value) {
            if (mounted) setState(() => _pressed = value);
          },
          child: Stack(
            children: [
              PositionedDirectional(
                top: 62,
                start: 0,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: colors.primary.withValues(alpha: .65),
                    borderRadius: const BorderRadiusDirectional.only(
                      topEnd: Radius.circular(3),
                      bottomEnd: Radius.circular(3),
                    ),
                  ),
                  child: const SizedBox(width: 3, height: 37),
                ),
              ),
              Padding(
                padding: const EdgeInsetsDirectional.fromSTEB(16, 11, 16, 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      children: [
                        TripStatusBadge(status: widget.trip.status),
                        const Spacer(),
                        Text(
                          date,
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: colors.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    TripJourney(
                      pickup: widget.trip.booking.pickup,
                      destination: widget.trip.booking.destination,
                    ),
                    if (widget.trip.booking.scheduledAt != null) ...[
                      const SizedBox(height: AppSpacing.sm),
                      Text(
                        l.tripsScheduledAt(
                          rideTimeLabel(
                            context,
                            widget.trip.booking.scheduledAt!,
                          ),
                        ),
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: colors.onSurfaceVariant,
                        ),
                      ),
                    ],
                    const SizedBox(height: AppSpacing.sm),
                    Container(
                      height: 1,
                      color: colors.outlineVariant.withValues(alpha: .75),
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Wrap(
                      alignment: WrapAlignment.spaceBetween,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      spacing: AppSpacing.md,
                      runSpacing: AppSpacing.xs,
                      children: [
                        Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              l.tripsFare,
                              style: theme.textTheme.labelSmall?.copyWith(
                                color: colors.onSurfaceVariant,
                              ),
                            ),
                            Text(
                              _localizedFare(context),
                              style: theme.textTheme.titleMedium?.copyWith(
                                color: colors.primary,
                                fontWeight: FontWeight.w800,
                                letterSpacing: -.35,
                              ),
                            ),
                          ],
                        ),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              l.tripsDetails,
                              style: theme.textTheme.labelMedium?.copyWith(
                                color: colors.onSurface,
                              ),
                            ),
                            const SizedBox(width: AppSpacing.sm),
                            DecoratedBox(
                              decoration: BoxDecoration(
                                color: colors.primaryContainer,
                                shape: BoxShape.circle,
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(7),
                                child: Icon(
                                  Icons.arrow_back_rounded,
                                  size: 18,
                                  color: colors.primary,
                                ),
                              ),
                            ),
                          ],
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
