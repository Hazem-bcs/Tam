import 'dart:async';
import 'map_camera_focus.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tam_customer/core/config/map_configuration.dart';
import 'package:tam_customer/l10n/app_localizations.dart';
import 'package:tam_customer/shared/domain/geo_point.dart';

import '../bloc/map_route_cubit.dart';
import '../maps_scope.dart';
import 'map_feedback.dart';
import 'tam_map_canvas.dart';

class RouteMapView extends StatefulWidget {
  const RouteMapView({
    super.key,
    this.origin,
    this.destination,
    this.driver,
    this.height = 260,
    this.bottomInset,
    this.selection,
    this.onSelected,
    this.onLocate,
    this.locating = false,
    this.focus,
    this.markerIconSize = 36,
    this.compactPreview = false,
  });
  final GeoPoint? origin, destination, driver;
  final double height;
  final ValueListenable<double>? bottomInset;
  final GeoPoint? selection;
  final ValueChanged<GeoPoint>? onSelected;
  final VoidCallback? onLocate;
  final bool locating;
  final MapCameraFocus? focus;
  final double markerIconSize;
  final bool compactPreview;
  @override
  State<RouteMapView> createState() => _RouteMapViewState();
}

class _RouteMapViewState extends State<RouteMapView> {
  MapRouteCubit? _routes;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final repository = MapsScope.maybeOf(context)?.repository;
    if (repository != _routes?.repository) {
      if (_routes != null) unawaited(_routes!.close());
      _routes = repository == null ? null : MapRouteCubit(repository);
      _load();
    }
  }

  @override
  void didUpdateWidget(RouteMapView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.origin != widget.origin ||
        oldWidget.destination != widget.destination) {
      _load();
    }
  }

  void _load() {
    if (_routes != null) {
      unawaited(_routes!.load(widget.origin, widget.destination));
    }
  }

  @override
  void dispose() {
    if (_routes != null) unawaited(_routes!.close());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final dependencies = MapsScope.maybeOf(context);
    if (dependencies == null) {
      return SizedBox(
        height: widget.height,
        child: TamMapCanvas(
          configuration: const MapConfiguration(),
          bottomInset: widget.bottomInset,
          selection: widget.selection,
          onSelected: widget.onSelected,
          onLocate: widget.onLocate,
          locating: widget.locating,
          focus: widget.focus,
          markerIconSize: widget.markerIconSize,
          compactPreview: widget.compactPreview,
          origin: widget.origin,
          destination: widget.destination,
          driver: widget.driver,
        ),
      );
    }
    return BlocProvider.value(
      value: _routes!,
      child: BlocBuilder<MapRouteCubit, MapRouteState>(
        builder: (context, state) => SizedBox(
          height: widget.height,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: TamMapCanvas(
                  configuration: dependencies.configuration,
                  bottomInset: widget.bottomInset,
                  selection: widget.selection,
                  onSelected: widget.onSelected,
                  onLocate: widget.onLocate,
                  locating: widget.locating,
                  focus: widget.focus,
                  markerIconSize: widget.markerIconSize,
                  compactPreview: widget.compactPreview,
                  onAttribution: dependencies.attribution.open,
                  tileProviderFactory: dependencies.tileProviderFactory,
                  origin: widget.origin,
                  destination: widget.destination,
                  driver: widget.driver,
                  route: state.route,
                ),
              ),
              if (state.busy) const LinearProgressIndicator(),
              if (state.failure != null &&
                  state.failure != 'MAP_NOT_CONFIGURED')
                MapFeedback(
                  text: AppLocalizations.of(context).mapsRouteFailed,
                  onRetry: () => context.read<MapRouteCubit>().load(
                    widget.origin,
                    widget.destination,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
