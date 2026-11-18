import 'package:flutter/material.dart';
import 'package:tam_customer/app/theme/app_tokens.dart';
import 'package:tam_customer/core/config/map_configuration.dart';
import 'package:tam_customer/features/maps/presentation/maps_scope.dart';
import 'package:tam_customer/features/maps/presentation/widgets/route_map_view.dart';
import 'package:tam_customer/l10n/app_localizations.dart';
import 'package:tam_customer/shared/domain/geo_point.dart';
import 'package:tam_customer/shared/domain/trip.dart';

/// Only actual booking coordinates and a configured map provider authorize a
/// geographic preview. A geocoded label or a decorative route is not enough.
bool canPreviewTripRoute(Trip trip, MapConfiguration? configuration) {
  if (configuration == null ||
      (!configuration.hasTiles && !configuration.hasVectorStyle)) {
    return false;
  }
  final start = trip.booking.pickup.point;
  final end = trip.booking.destination.point;
  return _usableCoordinate(start) && _usableCoordinate(end) && start != end;
}

bool _usableCoordinate(GeoPoint point) =>
    point.latitude.abs() <= 85.0511 &&
    point.longitude.abs() <= 180 &&
    (point.latitude != 0 || point.longitude != 0);

/// A route card that gives the entire width to real trip data. The map is
/// never fabricated: without a provider or genuine coordinates, both
/// addresses use the available width instead of an empty illustration slot.
class TripDetailsRouteCard extends StatelessWidget {
  const TripDetailsRouteCard({
    super.key,
    required this.trip,
    this.onOpenFullMap,
  });

  final Trip trip;
  final VoidCallback? onOpenFullMap;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final type = Theme.of(context).textTheme;
    final l = AppLocalizations.of(context);
    final config = MapsScope.maybeOf(context)?.configuration;
    final showMap = canPreviewTripRoute(trip, config);

    return DecoratedBox(
      decoration: BoxDecoration(
        color: colors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(AppRadii.lg),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    l.tripsRoute,
                    style: type.titleSmall?.copyWith(
                      color: colors.onSurface,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                if (showMap && onOpenFullMap != null)
                  IconButton(
                    key: const Key('trips-open-full-map'),
                    tooltip: l.activeTripFollow,
                    onPressed: onOpenFullMap,
                    visualDensity: VisualDensity.compact,
                    icon: Icon(
                      Icons.open_in_full_rounded,
                      size: 18,
                      color: colors.primary,
                    ),
                  ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            if (showMap) ...[
              SizedBox(height: 190, child: _RealMapPreview(trip: trip)),
              const SizedBox(height: AppSpacing.lg),
            ],
            _StopsTimeline(trip: trip),
          ],
        ),
      ),
    );
  }
}

/// Uses the same configured map engine as the ride-request and active-trip
/// screens. If routing is available, RouteMapView draws its returned geometry;
/// otherwise it displays only real endpoints, not a straight or fake road.
class _RealMapPreview extends StatelessWidget {
  const _RealMapPreview({required this.trip});
  final Trip trip;

  @override
  Widget build(BuildContext context) => RepaintBoundary(
    child: ClipRRect(
      borderRadius: BorderRadius.circular(13),
      child: RouteMapView(
        key: ValueKey((
          trip.id,
          trip.booking.pickup.point,
          trip.booking.destination.point,
        )),
        origin: trip.booking.pickup.point,
        destination: trip.booking.destination.point,
        driver: trip.status.isActive ? trip.live?.position?.point : null,
        height: 190,
        markerIconSize: 20,
        compactPreview: true,
      ),
    ),
  );
}

class _StopsTimeline extends StatelessWidget {
  const _StopsTimeline({required this.trip});
  final Trip trip;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final colors = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _TimelineStop(
          label: l.tripsFrom,
          address: trip.booking.pickup.label,
          destination: false,
        ),
        Padding(
          padding: const EdgeInsetsDirectional.only(start: 7),
          child: Align(
            alignment: AlignmentDirectional.centerStart,
            child: Container(
              width: 1.5,
              height: 24,
              color: colors.outlineVariant,
            ),
          ),
        ),
        _TimelineStop(
          label: l.tripsTo,
          address: trip.booking.destination.label,
          destination: true,
        ),
      ],
    );
  }
}

class _TimelineStop extends StatelessWidget {
  const _TimelineStop({
    required this.label,
    required this.address,
    required this.destination,
  });
  final String label;
  final String address;
  final bool destination;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final type = Theme.of(context).textTheme;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsetsDirectional.only(top: 5),
          child: destination
              ? Image.asset(
                  'assets/images/address_pin.webp',
                  width: 22,
                  height: 22,
                  excludeFromSemantics: true,
                )
              : Icon(Icons.circle_outlined, size: 22, color: colors.primary),
        ),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: type.bodySmall?.copyWith(color: colors.onSurfaceVariant),
              ),
              const SizedBox(height: 3),
              Text(
                address,
                style: type.bodyMedium?.copyWith(
                  color: colors.onSurface,
                  fontWeight: FontWeight.w600,
                  height: 1.35,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
