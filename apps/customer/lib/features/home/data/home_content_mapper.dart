import 'package:tam_customer/features/home/domain/entities/home_content.dart';

abstract final class HomeContentMapper {
  static HomeContent fromEnvelope(Map<String, dynamic> envelope) {
    final data = _object(envelope['data']);
    final promos = _array(data['promotions']).map((item) {
      final v = _object(item);
      return HomePromotion(
        id: _string(v['id']),
        kind: switch (_string(v['kind'])) {
          'hero' => HomePromotionKind.hero,
          'announcement' => HomePromotionKind.announcement,
          _ => throw const FormatException('Invalid promotion kind'),
        },
        title: _text(v['title']),
        subtitle: _text(v['subtitle']),
        enabled: _bool(v['enabled']),
        action: _requiredAction(v),
        imageUrl: _imageUrl(v['image_url']),
      );
    }).toList();
    final services = _array(data['services']).map((item) {
      final v = _object(item);
      return HomeService(
        id: switch (_string(v['id'])) {
          'ride' => HomeServiceId.ride,
          'food' => HomeServiceId.food,
          'shopping' => HomeServiceId.shopping,
          _ => throw const FormatException('Unknown service'),
        },
        available: _bool(v['available']),
        action: _requiredAction(v),
      );
    }).toList();
    if (promos.length > 5 ||
        promos.map((e) => e.id).toSet().length != promos.length ||
        services.map((e) => e.id).toSet().length != services.length ||
        services.any((e) => e.available != (e.action != null)) ||
        services.any((e) => e.available && e.id != HomeServiceId.ride)) {
      throw const FormatException('Invalid Home availability/IDs');
    }
    return HomeContent(
      revision: _string(data['revision']),
      promotions: promos,
      services: services,
    );
  }

  static Map<String, dynamic> _object(Object? value) {
    if (value is Map<String, dynamic>) return value;
    throw const FormatException('Expected object');
  }

  static List<dynamic> _array(Object? value) {
    if (value is List<dynamic>) return value;
    throw const FormatException('Expected array');
  }

  static String _string(Object? value) {
    if (value is String && value.trim().isNotEmpty) return value;
    throw const FormatException('Expected non-empty string');
  }

  static String? _imageUrl(Object? value) {
    if (value == null) return null;
    if (value is! String) {
      throw const FormatException('Invalid campaign image URL');
    }
    final url = Uri.tryParse(value);
    if (url == null ||
        url.scheme != 'https' ||
        url.host.isEmpty ||
        url.userInfo.isNotEmpty ||
        url.hasFragment) {
      throw const FormatException('Invalid campaign image URL');
    }
    return value;
  }

  static bool _bool(Object? value) {
    if (value is bool) return value;
    throw const FormatException('Expected boolean');
  }

  static HomeLocalizedText _text(Object? value) {
    final v = _object(value);
    return HomeLocalizedText(ar: _string(v['ar']), en: _string(v['en']));
  }

  static HomeAction? _action(Object? v) => switch (v) {
    null => null,
    'ride_request' => HomeAction.rideRequest,
    _ => throw const FormatException('Invalid action'),
  };

  static HomeAction? _requiredAction(Map<String, dynamic> value) {
    if (!value.containsKey('action')) {
      throw const FormatException('Missing required action');
    }
    return _action(value['action']);
  }
}
