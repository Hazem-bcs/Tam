import 'package:flutter/material.dart';
import 'package:tam_customer/app/theme/app_tokens.dart';
import 'package:tam_customer/l10n/app_localizations.dart';
import 'package:tam_customer/shared/domain/trip_live_details.dart';
import 'package:tam_customer/shared/presentation/vehicle_marker_kind.dart';
import 'package:tam_customer/shared/widgets/driver_avatar.dart';
import 'package:tam_customer/shared/widgets/tam_vehicle_icon.dart';

/// Replaces the old AlertDialog with a readable, scrollable details sheet.
Future<void> showActiveDriverDetailsSheet(
  BuildContext context, {
  required TripDriver driver,
  bool showDemoAvatar = false,
  VehicleMarkerKind vehicleKind = VehicleMarkerKind.car,
}) {
  final colors = Theme.of(context).colorScheme;
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    showDragHandle: true,
    backgroundColor: colors.surfaceContainerLowest,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadii.sheet)),
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
          vehicleKind: vehicleKind,
        ),
      ),
    ),
  );
}

class _DriverDetails extends StatelessWidget {
  const _DriverDetails({
    required this.driver,
    required this.showDemoAvatar,
    required this.vehicleKind,
  });

  final TripDriver driver;
  final VehicleMarkerKind vehicleKind;
  final bool showDemoAvatar;

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
        const SizedBox(height: AppSpacing.md),
        Align(child: DriverAvatar(size: 72, showDemoAvatar: showDemoAvatar)),
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
                style: text.bodyMedium?.copyWith(
                  color: colors.onSurfaceVariant,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.lg),
        DecoratedBox(
          decoration: BoxDecoration(
            color: colors.surfaceContainerLow,
            borderRadius: BorderRadius.circular(AppRadii.lg),
          ),
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Row(
              children: [
                _VehiclePhoto(
                  imageUrl: driver.vehicleImageUrl,
                  showDemo: showDemoAvatar,
                  kind: vehicleKind,
                ),
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
        const SizedBox(height: AppSpacing.sm),
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(l.activeTripClose),
        ),
      ],
    );
  }
}

/// A driver-provided photo takes precedence; demo artwork is mock-only.
class _VehiclePhoto extends StatelessWidget {
  const _VehiclePhoto({
    this.imageUrl,
    required this.showDemo,
    required this.kind,
  });
  final String? imageUrl;
  final bool showDemo;
  final VehicleMarkerKind kind;

  @override
  Widget build(BuildContext context) {
    final fallback = TamVehicleIcon(size: 56, kind: kind);
    final url = imageUrl?.trim();
    return SizedBox(
      width: 84,
      height: 64,
      child: url != null && url.isNotEmpty
          ? Image.network(
              url,
              fit: BoxFit.contain,
              errorBuilder: (_, _, _) => fallback,
            )
          : showDemo
          ? Image.asset(
              switch (kind) {
                VehicleMarkerKind.motorbike =>
                  'assets/maps/vehicle-motorbike-user.webp',
                VehicleMarkerKind.van => 'assets/maps/vehicle-van-user.webp',
                VehicleMarkerKind.car =>
                  'assets/images/ahmad_ui/driver_car_demo.webp',
              },
              fit: BoxFit.contain,
              errorBuilder: (_, _, _) => fallback,
            )
          : fallback,
    );
  }
}
