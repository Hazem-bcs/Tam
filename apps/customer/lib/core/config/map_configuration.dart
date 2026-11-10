import 'package:tam_customer/shared/domain/geo_point.dart';

/// Build-owned endpoints, never inferred from a public map provider.
final class MapConfiguration {
  const MapConfiguration({this.tileUrl = '', this.apiBaseUrl = ''});
  final String tileUrl, apiBaseUrl;
  bool get hasTiles => tileUrl.isNotEmpty;
  bool get hasServices => apiBaseUrl.isNotEmpty;
  GeoPoint get initialCenter => GeoPoint(latitude: 33.5138, longitude: 36.2765);

  factory MapConfiguration.parse({
    required String tileUrl,
    required String apiBaseUrl,
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
        throw ArgumentError('Invalid private map endpoint');
      }
    }

    validate(tileUrl, tile: true);
    validate(apiBaseUrl);
    return MapConfiguration(tileUrl: tileUrl, apiBaseUrl: apiBaseUrl);
  }
}
