import 'package:dio/dio.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:tam_customer/core/config/app_config.dart';
import 'package:tam_customer/core/config/map_configuration.dart';

import 'data/api_maps_repository.dart';
import 'data/device_location_adapter.dart';
import 'data/device_location_settings_adapter.dart';
import 'data/maps_attribution_adapter.dart';
import 'data/osm_tile_provider.dart';
import 'data/osrm_maps_repository.dart';
import 'data/private_tile_provider.dart';
import 'domain/foreground_location.dart';
import 'domain/maps_repository.dart';

final class MapsDependencies {
  const MapsDependencies({
    required this.configuration,
    required this.repository,
    required this.deviceLocation,
    this.locationSettings = const DeviceLocationSettingsAdapter(),
    this.attribution = const MapsAttributionAdapter(),
    this.client,
    this.osrm,
    this.currentLocation,
    this.tileProviderFactory,
  });
  final MapConfiguration configuration;
  final MapsRepository repository;
  final DeviceLocation deviceLocation;
  final ForegroundLocation? currentLocation;
  final DeviceLocationSettings locationSettings;
  final MapAttribution attribution;
  final Dio? client;
  final OsrmMapsRepository? osrm;
  final TileProvider Function(String)? tileProviderFactory;
  factory MapsDependencies.configured(MapConfiguration configuration) {
    final dio = configuration.hasServices
        ? Dio(
            BaseOptions(
              baseUrl:
                  '${configuration.apiBaseUrl.replaceFirst(RegExp(r'/+$'), '')}/',
              connectTimeout: const Duration(seconds: 8),
              receiveTimeout: const Duration(seconds: 12),
              sendTimeout: const Duration(seconds: 12),
              followRedirects: false,
              headers: {'Accept': 'application/json'},
            ),
          )
        : null;
    final places = dio == null
        ? const UnconfiguredMapsRepository()
        : ApiMapsRepository(dio);
    final osrm = configuration.hasOsrm
        ? OsrmMapsRepository(
            Dio(
              BaseOptions(
                baseUrl:
                    '${configuration.osrmBaseUrl.replaceFirst(RegExp(r'/+$'), '')}/',
                connectTimeout: const Duration(seconds: 8),
                receiveTimeout: const Duration(seconds: 12),
                sendTimeout: const Duration(seconds: 12),
                followRedirects: false,
                headers: {
                  'Accept': 'application/json',
                  'User-Agent': 'Tam-Development/1.0',
                },
              ),
            ),
            places: places,
          )
        : null;
    final location = ForegroundLocation(
      sensor: DeviceLocationAdapter(policy: AppConfig.locationPolicy),
      policy: AppConfig.locationPolicy,
    );
    return MapsDependencies(
      configuration: configuration,
      repository: osrm ?? places,
      osrm: osrm,
      deviceLocation: location,
      currentLocation: location,
      client: dio,
      tileProviderFactory: configuration.usesOsmCommunityTiles
          ? OsmTileProvider.new
          : PrivateTileProvider.new,
    );
  }
  void clearRoutingSession() => osrm?.clearSession();

  void dispose() {
    osrm?.dispose();
    currentLocation?.dispose();
    client?.close(force: true);
  }
}
