import 'package:flutter/material.dart';
import 'package:tam_customer/app/theme/app_tokens.dart';
import 'package:tam_customer/features/active_trip/presentation/widgets/active_driver_details_sheet.dart';
import 'package:tam_customer/l10n/app_localizations.dart';
import 'package:tam_customer/shared/domain/trip_live_details.dart';
import 'package:tam_customer/shared/widgets/driver_avatar.dart';

class ActiveDriverCard extends StatelessWidget {
  const ActiveDriverCard({
    super.key,
    required this.driver,
    this.showDemoAvatar = false,
  });

  final TripDriver driver;
  final bool showDemoAvatar;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final colors = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    final english = Localizations.localeOf(context).languageCode == 'en';
    final name = english ? driver.nameEn : driver.name;
    final vehicle = english ? driver.vehicleEn : driver.vehicle;
    return Material(
      color: colors.surfaceContainerLowest,
      borderRadius: BorderRadius.circular(AppRadii.lg),
      clipBehavior: Clip.antiAlias,
      child: Semantics(
        button: true,
        label: l.activeTripDriverDetails,
        child: InkWell(
          key: const Key('active-driver-card'),
          onTap: () => showActiveDriverDetailsSheet(
            context,
            driver: driver,
            showDemoAvatar: showDemoAvatar,
          ),
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Row(
              children: [
                DriverAvatar(showDemoAvatar: showDemoAvatar),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name,
                        style: text.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        vehicle,
                        style: text.bodySmall?.copyWith(
                          color: colors.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      Row(
                        children: [
                          Icon(
                            Icons.star_rounded,
                            color: colors.primary,
                            size: 16,
                          ),
                          const SizedBox(width: AppSpacing.xs),
                          Text(
                            driver.rating.toStringAsFixed(1),
                            style: text.labelMedium,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Icon(
                  Directionality.of(context) == TextDirection.rtl
                      ? Icons.chevron_left_rounded
                      : Icons.chevron_right_rounded,
                  color: colors.onSurfaceVariant,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// The two useful immediate actions stay outside the details sheet.
class ActiveDriverContactBar extends StatelessWidget {
  const ActiveDriverContactBar({super.key, required this.onChat, this.onCall});
  final VoidCallback onChat;
  final VoidCallback? onCall;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return LayoutBuilder(
      builder: (context, constraints) {
        final stacked =
            constraints.maxWidth < 320 ||
            MediaQuery.textScalerOf(context).scale(1) > 1.5;
        final gap = onCall == null ? 0.0 : AppSpacing.sm;
        final width = stacked || onCall == null
            ? constraints.maxWidth
            : (constraints.maxWidth - gap) / 2;
        return Wrap(
          spacing: AppSpacing.sm,
          runSpacing: AppSpacing.sm,
          children: [
            SizedBox(
              width: width,
              child: FilledButton.icon(
                key: const Key('active-chat'),
                onPressed: onChat,
                icon: const Icon(Icons.chat_bubble_outline_rounded),
                label: Text(l.activeTripChat),
              ),
            ),
            if (onCall != null)
              SizedBox(
                width: width,
                child: OutlinedButton.icon(
                  key: const Key('active-call-driver'),
                  onPressed: onCall,
                  icon: const Icon(Icons.phone_outlined),
                  label: Text(l.driverContactTitle),
                ),
              ),
          ],
        );
      },
    );
  }
}
