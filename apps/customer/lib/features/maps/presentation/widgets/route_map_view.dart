import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tam_customer/core/config/map_configuration.dart';
import 'package:tam_customer/l10n/app_localizations.dart';
import 'package:tam_customer/shared/domain/geo_point.dart';

import '../bloc/map_route_cubit.dart';
import '../maps_scope.dart';
import 'map_feedback.dart';
import 'tam_map_canvas.dart';

class RouteMapView extends StatelessWidget {
  const RouteMapView({
    super.key,
    this.origin,
    this.destination,
    this.driver,
    this.height = 260,
  });
  final GeoPoint? origin, destination, driver;
  final double height;
  @override
  Widget build(BuildContext context) {
    final dependencies = MapsScope.maybeOf(context);
    if (dependencies == null) {
      return SizedBox(
        height: height,
        child: TamMapCanvas(
          configuration: const MapConfiguration(),
          origin: origin,
          destination: destination,
          driver: driver,
        ),
      );
    }
    final repository = dependencies.repository;
    return BlocProvider(
      key: ValueKey((repository, origin, destination)),
      create: (_) => MapRouteCubit(repository)..load(origin, destination),
      child: BlocBuilder<MapRouteCubit, MapRouteState>(
        builder: (context, state) => Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(
              height: height,
              child: TamMapCanvas(
                configuration: dependencies.configuration,
                onAttribution: dependencies.attribution.open,
                tileProviderFactory: dependencies.tileProviderFactory,
                origin: origin,
                destination: destination,
                driver: driver,
                route: state.route,
              ),
            ),
            if (state.busy) const LinearProgressIndicator(),
            if (state.failure != null &&
                (state.failure != 'MAP_NOT_CONFIGURED' ||
                    dependencies.configuration.hasTiles))
              MapFeedback(
                text: AppLocalizations.of(context).mapsRouteFailed,
                onRetry: () =>
                    context.read<MapRouteCubit>().load(origin, destination),
              ),
          ],
        ),
      ),
    );
  }
}
