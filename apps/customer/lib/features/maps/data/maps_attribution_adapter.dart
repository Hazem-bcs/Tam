import 'package:url_launcher/url_launcher.dart';
import '../domain/maps_repository.dart';

final class MapsAttributionAdapter implements MapAttribution {
  const MapsAttributionAdapter({Future<bool> Function(Uri)? launch})
    : _launch = launch;
  final Future<bool> Function(Uri)? _launch;
  static Future<bool> _external(Uri uri) =>
      launchUrl(uri, mode: LaunchMode.externalApplication);
  @override
  Future<void> open() async {
    try {
      if (await (_launch ?? _external)(
        Uri.https('www.openstreetmap.org', '/copyright'),
      )) {
        return;
      }
    } catch (_) {
      throw const MapsFailure('ATTRIBUTION_UNAVAILABLE');
    }
    throw const MapsFailure('ATTRIBUTION_UNAVAILABLE');
  }
}
