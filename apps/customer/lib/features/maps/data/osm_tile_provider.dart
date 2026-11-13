import 'package:flutter_map/flutter_map.dart';

import 'private_tile_provider.dart';

/// Community tiles use persistent HTTP-aware caching and an app identifier.
/// No prefetch, offline download or application credentials are involved.
final class OsmTileProvider extends NetworkTileProvider {
  OsmTileProvider._(this.client)
    : super(
        httpClient: client,
        headers: {'User-Agent': 'TamCustomer/0.1 (com.tam.tam_customer)'},
        cachingProvider: BuiltInMapCachingProvider.getOrCreateInstance(
          maxCacheSize: 100 * 1024 * 1024,
        ),
        attemptDecodeOfHttpErrorResponses: false,
      );

  factory OsmTileProvider(String url) =>
      OsmTileProvider._(PrivateTileClient(Uri.parse(url)));

  final PrivateTileClient client;

  @override
  Future<void> dispose() async {
    client.close();
    await super.dispose();
  }
}
