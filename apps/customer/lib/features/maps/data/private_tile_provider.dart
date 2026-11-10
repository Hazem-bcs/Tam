import 'package:flutter_map/flutter_map.dart';
import 'package:http/http.dart' as http;

/// Tiles never receive application credentials or follow cross-host redirects.
final class PrivateTileClient extends http.BaseClient {
  PrivateTileClient(this.origin, {http.Client? client})
    : _client = client ?? http.Client();
  final Uri origin;
  final http.Client _client;
  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) async {
    if (request.url.origin != origin.origin) {
      throw http.ClientException('Map origin mismatch');
    }
    request.followRedirects = false;
    request.headers.removeWhere(
      (key, _) => {
        'authorization',
        'cookie',
        'proxy-authorization',
      }.contains(key.toLowerCase()),
    );
    final response = await _client
        .send(request)
        .timeout(const Duration(seconds: 12));
    return http.StreamedResponse(
      response.stream.timeout(const Duration(seconds: 12)),
      response.statusCode,
      headers: response.headers,
      request: request,
    );
  }

  @override
  void close() => _client.close();
}

final class PrivateTileProvider extends NetworkTileProvider {
  PrivateTileProvider._(this.client)
    : super(
        httpClient: client,
        cachingProvider: const DisabledMapCachingProvider(),
        attemptDecodeOfHttpErrorResponses: false,
      );
  factory PrivateTileProvider(String url) =>
      PrivateTileProvider._(PrivateTileClient(Uri.parse(url)));
  final PrivateTileClient client;
  @override
  Future<void> dispose() async {
    client.close();
    await super.dispose();
  }
}
