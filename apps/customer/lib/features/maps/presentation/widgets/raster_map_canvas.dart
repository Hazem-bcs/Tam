import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:tam_customer/app/theme/app_tokens.dart';
import 'package:tam_customer/core/config/map_configuration.dart';
import 'package:tam_customer/l10n/app_localizations.dart';
import 'package:tam_customer/shared/domain/geo_point.dart';
import 'package:tam_customer/shared/widgets/tam_vehicle_icon.dart';
import '../../domain/maps_repository.dart';
import 'map_attribution_link.dart';
import 'map_feedback.dart';
import 'private_tile_layer.dart';
import 'vector/vector_map_controls.dart';

class RasterMapCanvas extends StatefulWidget {
  const RasterMapCanvas({
    super.key,
    required this.configuration,
    this.origin,
    this.destination,
    this.driver,
    this.route,
    this.onSelected,
    this.tileProviderFactory,
    this.onAttribution,
    this.bottomInset,
    this.selection,
    this.onLocate,
    this.locating = false,
    this.markerIconSize = 36,
  });
  final ValueListenable<double>? bottomInset;
  final GeoPoint? selection;
  final VoidCallback? onLocate;
  final bool locating;
  final double markerIconSize;
  final MapConfiguration configuration;
  final GeoPoint? origin, destination, driver;
  final MapRoute? route;
  final ValueChanged<GeoPoint>? onSelected;
  final TileProvider Function(String)? tileProviderFactory;
  final Future<void> Function()? onAttribution;
  @override
  State<RasterMapCanvas> createState() => _RasterMapCanvasState();
}

class _RasterMapCanvasState extends State<RasterMapCanvas> {
  final _controller = MapController();
  bool _ready = false, _failed = false, _loaded = false;
  int _generation = 0;
  LatLng _latLng(GeoPoint p) =>
      LatLng(p.latitude.clamp(-85.0511, 85.0511), p.longitude);
  List<LatLng> get _points => [
    if (widget.origin != null) _latLng(widget.origin!),
    if (widget.destination != null) _latLng(widget.destination!),
    ...?widget.route?.points.map(_latLng),
  ];
  double get _inset => widget.bottomInset?.value ?? 0;
  void _fit() {
    if (!mounted || !_ready) return;
    final points = _points.toSet().toList();
    if (points.length > 1) {
      _controller.fitCamera(
        CameraFit.coordinates(
          coordinates: points,
          padding: EdgeInsets.fromLTRB(
            48,
            80,
            48,
            (_inset + 48).clamp(
              48,
              (_controller.camera.nonRotatedSize.height - 120).clamp(
                48,
                double.infinity,
              ),
            ),
          ),
          maxZoom: 16,
        ),
      );
    } else if (points.isNotEmpty) {
      _controller.move(points.first, 15, offset: Offset(0, -_inset / 2));
    }
  }

  @override
  void didUpdateWidget(RasterMapCanvas oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.configuration.tileUrl != widget.configuration.tileUrl) {
      _generation++;
      _failed = _loaded = false;
    }
    if (oldWidget.origin != widget.origin ||
        oldWidget.destination != widget.destination ||
        oldWidget.route != widget.route) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _fit());
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    assert(
      !widget.configuration.hasTiles || widget.tileProviderFactory != null,
    );
    final l = AppLocalizations.of(context),
        colors = Theme.of(context).colorScheme;
    final center =
        widget.origin ??
        widget.destination ??
        widget.configuration.initialCenter;
    Marker marker(GeoPoint point, IconData icon, String label) => Marker(
      point: _latLng(point),
      width: 48,
      height: 48,
      child: Tooltip(
        message: label,
        child: Semantics(
          label: label,
          child: icon == Icons.local_taxi
              ? TamVehicleIcon(size: widget.markerIconSize)
              : Icon(icon, size: widget.markerIconSize, color: colors.primary),
        ),
      ),
    );
    return ClipRRect(
      borderRadius: BorderRadius.circular(AppRadii.lg),
      child: AnimatedBuilder(
        animation:
            widget.bottomInset ?? const AlwaysStoppedAnimation<double>(0),
        child: Positioned.fill(
          child: FlutterMap(
            mapController: _controller,
            options: MapOptions(
              initialCenter: _latLng(center),
              initialZoom: 13,
              minZoom: 3,
              maxZoom: 19,
              backgroundColor: colors.surfaceContainer,
              onMapReady: () {
                _ready = true;
                WidgetsBinding.instance.addPostFrameCallback((_) => _fit());
              },
              onTap: widget.onSelected == null
                  ? null
                  : (_, p) => widget.onSelected!(
                      GeoPoint(latitude: p.latitude, longitude: p.longitude),
                    ),
            ),
            children: [
              if (widget.configuration.hasTiles)
                PrivateTileLayer(
                  key: ValueKey((widget.configuration.tileUrl, _generation)),
                  url: widget.configuration.tileUrl,
                  providerFactory: widget.tileProviderFactory!,
                  onLoaded: () {
                    if (!_loaded) setState(() => _loaded = true);
                  },
                  onFailure: () {
                    if (!_failed) setState(() => _failed = true);
                  },
                ),
              if (widget.route != null)
                PolylineLayer(
                  polylines: [
                    Polyline(
                      points: widget.route!.points.map(_latLng).toList(),
                      strokeWidth: 5,
                      color: colors.primary,
                    ),
                  ],
                ),
              MarkerLayer(
                markers: [
                  if (widget.origin != null)
                    marker(widget.origin!, Icons.trip_origin, l.mapsOrigin),
                  if (widget.destination != null)
                    marker(
                      widget.destination!,
                      Icons.location_on,
                      l.mapsDestination,
                    ),
                  if (widget.selection != null)
                    marker(
                      widget.selection!,
                      Icons.add_location_alt_rounded,
                      l.mapsSelectedPoint,
                    ),
                  if (widget.driver != null)
                    marker(widget.driver!, Icons.local_taxi, l.mapsDriver),
                ],
              ),
            ],
          ),
        ),
        builder: (context, map) => LayoutBuilder(
          builder: (context, bounds) {
            final zoomControls =
                widget.bottomInset == null || bounds.maxHeight - _inset >= 240;
            return Stack(
              children: [
                map!,
                if (!widget.configuration.hasTiles || _failed)
                  Positioned(
                    top: 8,
                    left: 8,
                    right: 8,
                    child: IgnorePointer(
                      ignoring: !widget.configuration.hasTiles,
                      child: MapFeedback(
                        text: widget.configuration.hasTiles
                            ? l.mapsTilesFailed
                            : l.mapsNotConfigured,
                        onRetry: !widget.configuration.hasTiles
                            ? null
                            : () => setState(() {
                                _generation++;
                                _failed = _loaded = false;
                              }),
                      ),
                    ),
                  ),
                if (widget.configuration.hasTiles && !_failed && !_loaded)
                  const Positioned(
                    top: 0,
                    left: 0,
                    right: 0,
                    child: LinearProgressIndicator(),
                  ),
                if (zoomControls && widget.onLocate != null)
                  VectorMapControls(
                    bottomInset: _inset,
                    onLocate: widget.onLocate,
                    locating: widget.locating,
                  ),
                PositionedDirectional(
                  bottom: _inset + AppSpacing.xs,
                  start: AppSpacing.xs,
                  end: AppDimensions.minTapTarget + AppSpacing.sm,
                  child: MapAttributionLink(
                    onOpen: widget.onAttribution,
                    permanent: widget.configuration.usesOsmCommunityTiles,
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
