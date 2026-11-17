import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:tam_customer/app/theme/app_colors.dart';
import 'package:tam_customer/app/theme/app_tokens.dart';
import 'package:tam_customer/l10n/app_localizations.dart';
import 'package:tam_customer/shared/presentation/trip_display.dart';
import 'package:tam_customer/shared/widgets/trip_route.dart';
import '../../domain/completion_repository.dart';
import 'completion_surface.dart';

/// A readable completion receipt, not a payment confirmation.
class CompletionSummary extends StatelessWidget {
  const CompletionSummary({super.key, required this.completion});

  final TripCompletion completion;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final trip = completion.trip;
    final colors = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    final status = Theme.of(context).extension<AppStatusColors>()!;
    final driver = trip.live?.driver;

    return CompletionSurface(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(l.completionThankYou, style: text.titleLarge),
                    const SizedBox(height: AppSpacing.sm),
                    DecoratedBox(
                      decoration: BoxDecoration(
                        color: status.successContainer,
                        borderRadius: BorderRadius.circular(AppRadii.sheet),
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
                              Icons.check_circle_rounded,
                              color: status.onSuccessContainer,
                              size: 18,
                            ),
                            const SizedBox(width: AppSpacing.xs),
                            Flexible(
                              child: Text(
                                l.tripsStatusCompleted,
                                style: text.labelMedium?.copyWith(
                                  color: status.onSuccessContainer,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              ExcludeSemantics(
                child: SvgPicture.asset(
                  'assets/images/completion_clipboard.svg',
                  width: 72,
                  height: 72,
                ),
              ),
            ],
          ),
          const Divider(height: AppSpacing.xl),
          Row(
            children: [
              Icon(
                Icons.receipt_long_outlined,
                size: 18,
                color: colors.primary,
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Text(
                  l.completionTripId(trip.id),
                  style: text.bodySmall?.copyWith(
                    color: colors.onSurfaceVariant,
                  ),
                  softWrap: true,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Row(
            children: [
              Icon(
                Icons.calendar_today_outlined,
                size: 18,
                color: colors.onSurfaceVariant,
              ),
              const SizedBox(width: AppSpacing.sm),
              Flexible(
                child: Text(
                  tripDateLabel(context, trip.createdAt),
                  style: text.bodySmall?.copyWith(
                    color: colors.onSurfaceVariant,
                  ),
                ),
              ),
            ],
          ),
          const Divider(height: AppSpacing.xl),
          TripRoute(
            pickup: trip.booking.pickup,
            destination: trip.booking.destination,
          ),
          const SizedBox(height: AppSpacing.lg),
          DecoratedBox(
            decoration: BoxDecoration(
              color: colors.primaryContainer.withValues(alpha: 0.45),
              borderRadius: BorderRadius.circular(AppRadii.lg),
            ),
            child: Padding(
              padding: const EdgeInsetsDirectional.all(AppSpacing.md),
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
                              l.completionRecordedFare,
                              style: text.labelMedium?.copyWith(
                                color: colors.onSurface,
                              ),
                            ),
                            const SizedBox(height: AppSpacing.xs),
                            Text(
                              tripMoneyLabel(context, trip.booking.fare),
                              style: text.headlineSmall?.copyWith(
                                color: colors.primary,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      ExcludeSemantics(
                        child: SvgPicture.asset(
                          'assets/images/completion_wallet.svg',
                          width: 72,
                          height: 72,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    l.completionFareNote,
                    style: text.bodySmall?.copyWith(
                      color: colors.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (driver != null) ...[
            const SizedBox(height: AppSpacing.md),
            Text(
              l.completionDriver(
                Localizations.localeOf(context).languageCode == 'ar'
                    ? driver.name
                    : driver.nameEn,
              ),
              style: text.bodyMedium,
            ),
          ],
        ],
      ),
    );
  }
}
