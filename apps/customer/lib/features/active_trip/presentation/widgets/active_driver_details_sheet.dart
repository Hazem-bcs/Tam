import 'package:flutter/material.dart';
import 'package:tam_customer/app/theme/app_tokens.dart';
import 'package:tam_customer/features/active_trip/presentation/widgets/active_driver_avatar.dart';
import 'package:tam_customer/l10n/app_localizations.dart';
import 'package:tam_customer/shared/domain/trip_live_details.dart';
import 'package:tam_customer/shared/widgets/tam_vehicle_icon.dart';

/// Replaces the old AlertDialog with a readable, scrollable details sheet.
Future<void> showActiveDriverDetailsSheet(
  BuildContext context, {
  required TripDriver driver,
  required VoidCallback onChat,
  VoidCallback? onCall,
  bool showDemoAvatar = false,
}) {
  final colors = Theme.of(context).colorScheme;
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    showDragHandle: true,
    backgroundColor: colors.surfaceContainerLowest,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(
        top: Radius.circular(AppRadii.sheet),
      ),
    ),
    builder: (sheetContext) => ConstrainedBox(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.sizeOf(sheetContext).height * 0.86,
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsetsDirectional.fromSTEB(
          AppSpacing.xl,
          AppSpacing.xs,
          AppSpacing.xl,
          AppSpacing.xl,
        ),
        child: _DriverDetails(
          driver: driver,
          showDemoAvatar: showDemoAvatar,
          onChat: () {
            Navigator.of(sheetContext).pop();
            onChat();
          },
          onCall: onCall == null
              ? null
              : () {
                  Navigator.of(sheetContext).pop();
                  onCall();
                },
        ),
      ),
    ),
  );
}

class _DriverDetails extends StatelessWidget {
  const _DriverDetails({
    required this.driver,
    required this.showDemoAvatar,
    required this.onChat,
    this.onCall,
  });

  final TripDriver driver;
  final bool showDemoAvatar;
  final VoidCallback onChat;
  final VoidCallback? onCall;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final colors = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    final english = Localizations.localeOf(context).languageCode == 'en';
    final name = english ? driver.nameEn : driver.name;
    final vehicle = english ? driver.vehicleEn : driver.vehicle;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          l.activeTripDriverDetails,
          textAlign: TextAlign.center,
          style: text.titleLarge?.copyWith(fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: AppSpacing.lg),
        Align(
          child: ActiveDriverAvatar(
            size: 86,
            showDemoAvatar: showDemoAvatar,
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        Text(
          name,
          textAlign: TextAlign.center,
          style: text.titleLarge?.copyWith(fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: AppSpacing.xs),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.star_rounded, color: colors.primary, size: 19),
            const SizedBox(width: AppSpacing.xs),
            Flexible(
              child: Text(
                l.activeTripRating(driver.rating.toStringAsFixed(1)),
                style: text.bodyMedium?.copyWith(color: colors.onSurfaceVariant),
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.xl),
        DecoratedBox(
          decoration: BoxDecoration(
            color: colors.surfaceContainerLow,
            borderRadius: BorderRadius.circular(AppRadii.lg),
          ),
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Row(
              children: [
                const TamVehicleIcon(size: 56),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(vehicle, style: text.titleMedium),
                      const SizedBox(height: AppSpacing.xs),
                      SelectableText(
                        l.activeTripPlate(driver.plate),
                        style: text.bodyMedium?.copyWith(
                          color: colors.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.lg),
        FilledButton.icon(
          key: const Key('active-sheet-chat'),
          onPressed: onChat,
          icon: const Icon(Icons.chat_bubble_outline_rounded),
          label: Text(l.activeTripChat),
        ),
        if (onCall != null) ...[
          const SizedBox(height: AppSpacing.sm),
          OutlinedButton.icon(
            key: const Key('active-sheet-call'),
            onPressed: onCall,
            icon: const Icon(Icons.phone_outlined),
            label: Text(l.driverContactTitle),
          ),
        ],
        const SizedBox(height: AppSpacing.sm),
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(l.activeTripClose),
        ),
      ],
    );
  }
}
