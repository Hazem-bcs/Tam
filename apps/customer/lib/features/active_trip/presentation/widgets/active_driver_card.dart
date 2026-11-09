import 'package:flutter/material.dart';
import 'package:tam_customer/app/theme/app_tokens.dart';
import 'package:tam_customer/l10n/app_localizations.dart';
import 'package:tam_customer/shared/domain/trip_live_details.dart';
import 'package:tam_customer/shared/widgets/tam_card.dart';

class ActiveDriverCard extends StatelessWidget {
  const ActiveDriverCard({super.key, required this.driver});
  final TripDriver driver;
  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final english = Localizations.localeOf(context).languageCode == 'en';
    final name = english ? driver.nameEn : driver.name;
    final vehicle = english ? driver.vehicleEn : driver.vehicle;
    return TamCard(
      onTap: () => showDialog<void>(
        context: context,
        builder: (_) => AlertDialog(
          insetPadding: const EdgeInsets.all(AppSpacing.lg),
          scrollable: true,
          title: Text(name),
          content: SizedBox(
            width: double.maxFinite,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Icon(Icons.directions_car_outlined, size: 48),
                const SizedBox(height: AppSpacing.md),
                Text(vehicle),
                const SizedBox(height: AppSpacing.md),
                Text(l.activeTripPlate(driver.plate)),
                const SizedBox(height: AppSpacing.md),
                Text(l.activeTripRating(driver.rating.toStringAsFixed(1))),
                const SizedBox(height: AppSpacing.md),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(l.activeTripClose),
            ),
          ],
        ),
      ),
      child: Row(
        children: [
          const Icon(Icons.account_circle_outlined, size: 48),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: Theme.of(context).textTheme.titleMedium),
                Text(vehicle),
                Text(
                  l.activeTripDriverDetails,
                  style: Theme.of(context).textTheme.labelMedium,
                ),
              ],
            ),
          ),
          const Icon(Icons.info_outline),
        ],
      ),
    );
  }
}
