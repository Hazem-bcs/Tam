/// Localized Home content from the backend contract.
final class HomeLocalizedText {
  const HomeLocalizedText({required this.ar, required this.en});
  final String ar;
  final String en;
  String forLanguage(String code) => code == 'en' ? en : ar;
}

enum HomeServiceId { ride, food, shopping }

enum HomePromotionKind { hero, announcement }

enum HomeAction { rideRequest }

final class HomeService {
  const HomeService({
    required this.id,
    required this.available,
    required this.action,
  });
  final HomeServiceId id;
  final bool available;
  final HomeAction? action;
}

final class HomePromotion {
  const HomePromotion({
    required this.id,
    required this.kind,
    required this.title,
    required this.subtitle,
    required this.enabled,
    required this.action,
  });
  final String id;
  final HomePromotionKind kind;
  final HomeLocalizedText title;
  final HomeLocalizedText subtitle;
  final bool enabled;
  final HomeAction? action;
}

final class HomeContent {
  HomeContent({
    required this.revision,
    required List<HomePromotion> promotions,
    required List<HomeService> services,
  }) : promotions = List.unmodifiable(promotions),
       services = List.unmodifiable(services);

  final String revision;
  final List<HomePromotion> promotions;
  final List<HomeService> services;
  bool get isEmpty => promotions.isEmpty && services.isEmpty;
}
