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
        borderRadius: BorderRadius.circular(20),
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
                      fontSize: 15,
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
            LayoutBuilder(
              builder: (context, constraints) {
                final compact =
                    constraints.maxWidth < 300 ||
                    MediaQuery.textScalerOf(context).scale(1) >= 1.35;
                if (!showMap) {
                  return compact
                      ? _StopsTimeline(trip: trip)
                      : _StopsAcrossWidth(trip: trip);
                }
                final preview = _RealMapPreview(trip: trip);
                if (compact) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _StopsTimeline(trip: trip),
                      const SizedBox(height: AppSpacing.md),
                      SizedBox(height: 150, child: preview),
                    ],
                  );
                }
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(child: _StopsTimeline(trip: trip)),
                    const SizedBox(width: AppSpacing.md),
                    SizedBox(
                      width: constraints.maxWidth * .41,
                      height: 156,
                      child: preview,
                    ),
                  ],
                );
              },
            ),
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
        height: 156,
        markerIconSize: 20,
        compactPreview: true,
      ),
    ),
  );
}

/// The full-width fallback intentionally distributes stops across the card.
class _StopsAcrossWidth extends StatelessWidget {
  const _StopsAcrossWidth({required this.trip});
  final Trip trip;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final colors = Theme.of(context).colorScheme;
    final rtl = Directionality.of(context) == TextDirection.rtl;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: _InlineStop(
            caption: l.tripsFrom,
            address: trip.booking.pickup.label,
            destination: false,
          ),
        ),
        Padding(
          padding: const EdgeInsetsDirectional.fromSTEB(6, 28, 6, 0),
          child: Icon(
            rtl ? Icons.arrow_back_rounded : Icons.arrow_forward_rounded,
            size: 18,
            color: colors.outline,
          ),
        ),
        Expanded(
          child: _InlineStop(
            caption: l.tripsTo,
            address: trip.booking.destination.label,
            destination: true,
          ),
        ),
      ],
    );
  }
}

class _InlineStop extends StatelessWidget {
  const _InlineStop({
    required this.caption,
    required this.address,
    required this.destination,
  });
  final String caption;
  final String address;
  final bool destination;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final type = Theme.of(context).textTheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          destination ? Icons.location_on_rounded : Icons.circle_outlined,
          size: 16,
          color: colors.primary,
        ),
        const SizedBox(height: 7),
        Text(
          caption,
          style: type.bodySmall?.copyWith(
            color: colors.onSurfaceVariant,
            fontSize: 12,
          ),
        ),
        const SizedBox(height: 3),
        Text(
          address,
          softWrap: true,
          style: type.bodyMedium?.copyWith(
            color: colors.onSurface,
            fontSize: 14,
            fontWeight: FontWeight.w600,
            height: 1.35,
          ),
        ),
      ],
    );
  }
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
          child: Icon(
            destination ? Icons.location_on_rounded : Icons.circle_outlined,
            size: 16,
            color: colors.primary,
          ),
        ),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: type.bodySmall?.copyWith(
                  color: colors.onSurfaceVariant,
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                address,
                style: type.bodyMedium?.copyWith(
                  color: colors.onSurface,
                  fontSize: 14,
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
