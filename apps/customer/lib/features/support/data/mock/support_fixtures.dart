import '../../domain/support_repository.dart';

abstract final class SupportFixtures {
  static const categories = [
    SupportCategory(
      id: 'general',
      nameAr: 'استفسار عام',
      nameEn: 'General question',
    ),
    SupportCategory(
      id: 'app_issue',
      nameAr: 'مشكلة في التطبيق',
      nameEn: 'App issue',
    ),
    SupportCategory(
      id: 'trip_issue',
      nameAr: 'بلاغ رحلة',
      nameEn: 'Trip report',
      tripRequired: true,
    ),
  ];
}
