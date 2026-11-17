import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:tam_customer/app/theme/app_tokens.dart';
import 'package:tam_customer/l10n/app_localizations.dart';
import 'package:tam_customer/shared/domain/trip.dart';
import 'package:tam_customer/shared/widgets/driver_avatar.dart';
import 'package:tam_customer/shared/widgets/tam_card.dart';

class TripDetailsDriverCard extends StatelessWidget {
  const TripDetailsDriverCard({super.key, required this.trip});
  final Trip trip;

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final driver = trip.live?.driver;
    final ar = Localizations.localeOf(context).languageCode == 'ar';
    return TamCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Image.asset(
                'assets/notifications/account.webp',
                width: 30,
                height: 30,
                excludeFromSemantics: true,
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Text(
                  t.tripsDriverSection,
                  style: theme.textTheme.titleMedium,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          if (driver == null)
            Text(
              t.tripsDriverUnavailable,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            )
          else
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                DriverAvatar(
                  size: 52,
                  showDemoAvatar: trip.receipt?.isSimulated == true,
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        ar ? driver.name : driver.nameEn,
                        style: theme.textTheme.titleSmall,
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        '${ar ? driver.vehicle : driver.vehicleEn} · ${driver.plate}',
                        style: theme.textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Image.asset(
                  'assets/notifications/rating.webp',
                  width: 24,
                  height: 24,
                  excludeFromSemantics: true,
                ),
                Text(
                  NumberFormat(
                    '0.0',
                    Localizations.localeOf(context).toLanguageTag(),
                  ).format(driver.rating),
                  style: theme.textTheme.labelLarge,
                ),
              ],
            ),
        ],
      ),
    );
  }
}
