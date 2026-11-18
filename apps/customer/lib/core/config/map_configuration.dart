import 'package:tam_customer/shared/domain/geo_point.dart';

/// Explicitly configured tiles and independent search/routing endpoints.
final class MapConfiguration {
  static const osmCommunityTiles =
      'https://tile.openstreetmap.org/{z}/{x}/{y}.png';
  static const libertyStyleAsset = 'assets/maps/liberty.json';
  const MapConfiguration({
    this.tileUrl = '',
    this.apiBaseUrl = '',
    this.osrmBaseUrl = '',
    this.vectorStyleAsset = '',
  });
  final String vectorStyleAsset;
  bool get hasVectorStyle => vectorStyleAsset.isNotEmpty;
  final String tileUrl, apiBaseUrl, osrmBaseUrl;
  bool get hasOsrm => osrmBaseUrl.isNotEmpty;
  bool get hasTiles => tileUrl.isNotEmpty;
  bool get hasServices => apiBaseUrl.isNotEmpty;
  bool get usesOsmCommunityTiles => tileUrl == osmCommunityTiles;
  GeoPoint get initialCenter => GeoPoint(latitude: 33.5138, longitude: 36.2765);

  factory MapConfiguration.parse({
    required String tileUrl,
    required String apiBaseUrl,
    String vectorStyleAsset = '',
    String osrmBaseUrl = '',
    bool allowLocalHttp = false,
  }) {
    void validate(String value, {bool tile = false}) {
      if (value.isEmpty) return;
      final uri = Uri.tryParse(value);
      final local =
          uri != null &&
          {'localhost', '127.0.0.1', '10.0.2.2', '::1'}.contains(uri.host);
      if (uri == null ||
          !uri.hasAuthority ||
          uri.host.isEmpty ||
          uri.userInfo.isNotEmpty ||
          uri.hasFragment ||
          uri.hasQuery ||
          (uri.scheme != 'https' &&
              !(allowLocalHttp && local && uri.scheme == 'http')) ||
          (tile &&
              (!['{z}', '{x}', '{y}'].every(value.contains) ||
                  RegExp(r'\{[^}]+\}')
                      .allMatches(value)
                      .any(
                        (m) => !{'{z}', '{x}', '{y}'}.contains(m.group(0)),
                      )))) {
        throw ArgumentError('Invalid map endpoint');
      }
    }

    if (vectorStyleAsset.isNotEmpty &&
        (!vectorStyleAsset.startsWith('assets/maps/') ||
            vectorStyleAsset.contains('..') ||
            !vectorStyleAsset.endsWith('.json'))) {
      throw ArgumentError('Invalid bundled map style');
    }
    validate(tileUrl, tile: true);
    validate(apiBaseUrl);
    validate(osrmBaseUrl);
    return MapConfiguration(
      tileUrl: tileUrl,
      apiBaseUrl: apiBaseUrl,
      osrmBaseUrl: osrmBaseUrl,
      vectorStyleAsset: vectorStyleAsset,
    );
  }
}
