import '../../domain/customer_notification.dart';
import '../notifications_codec.dart';

/// Fixed, non-personal sample content. No device notifications or server calls.
const mockNotificationsFixture = <Map<String, dynamic>>[
  {
    'id': 'notice-trip-complete-001',
    'type': 'ride.completed',
    'kind': 'trip',
    'title': {'ar': 'اكتملت رحلتك', 'en': 'Your trip is complete'},
    'body': {
      'ar': 'شكرًا لاختيارك تم. يمكنك مراجعة تفاصيل رحلتك.',
      'en': 'Thanks for choosing Tam. Review your trip details.',
    },
    'created_at': '2026-11-07T12:20:00Z',
    'read_at': null,
    'target': {'type': 'trip', 'trip_id': 'mock-history-001'},
  },
  {
    'id': 'notice-offer-001',
    'type': 'offer.available',
    'kind': 'offer',
    'title': {'ar': 'عرض جديد على رحلاتك', 'en': 'A new ride offer'},
    'body': {
      'ar': 'تعرّف على عروض الرحلات المتاحة داخل التطبيق.',
      'en': 'Explore available ride offers in the app.',
    },
    'created_at': '2026-11-07T11:40:00Z',
    'read_at': null,
    'target': {'type': 'home'},
  },
  {
    'id': 'notice-trips-001',
    'type': 'ride.history',
    'kind': 'trip',
    'title': {'ar': 'راجع رحلاتك السابقة', 'en': 'Review your past trips'},
    'body': {
      'ar': 'تجد سجل رحلاتك السابقة في قسم طلباتي.',
      'en': 'Your ride history is available under My trips.',
    },
    'created_at': '2026-11-07T10:10:00Z',
    'read_at': null,
    'target': {'type': 'trips'},
  },
  {
    'id': 'notice-account-001',
    'type': 'account.welcome',
    'kind': 'account',
    'title': {'ar': 'مرحبًا بك في تم', 'en': 'Welcome to Tam'},
    'body': {
      'ar': 'استكشف الخدمات من الصفحة الرئيسية.',
      'en': 'Discover our services on the home screen.',
    },
    'created_at': '2026-11-06T18:00:00Z',
    'read_at': '2026-11-06T18:10:00Z',
    'target': {'type': 'home'},
  },
  {
    'id': 'notice-unknown-001',
    'type': 'system.announcement',
    'kind': 'system',
    'title': {'ar': 'تحديث عن خدماتنا', 'en': 'Service update'},
    'body': {
      'ar': 'هذه الرسالة للعرض فقط، دون فتح روابط خارجية.',
      'en': 'This message is for reading only. No external links open.',
    },
    'created_at': '2026-11-06T11:10:00Z',
    'read_at': '2026-11-06T12:00:00Z',
    'target': {'type': 'external', 'url': 'https://example.invalid/unsafe'},
  },
  {
    'id': 'notice-missing-trip-001',
    'type': 'ride.details',
    'kind': 'trip',
    'title': {'ar': 'تفاصيل رحلة غير متاحة', 'en': 'Trip details unavailable'},
    'body': {
      'ar': 'يمكنك قراءة الرسالة دون فتح رحلة غير محددة.',
      'en': 'You can read this message without opening a missing trip.',
    },
    'created_at': '2026-11-05T09:00:00Z',
    'read_at': null,
    'target': {'type': 'trip', 'trip_id': null},
  },
  {
    'id': 'notice-system-001',
    'type': 'system.announcement',
    'kind': 'system',
    'title': {'ar': 'شكرًا لتجربة تم', 'en': 'Thanks for trying Tam'},
    'body': {
      'ar': 'نستمع دائمًا إلى ملاحظاتك.',
      'en': 'We always appreciate your feedback.',
    },
    'created_at': '2026-11-04T08:00:00Z',
    'read_at': '2026-11-04T09:00:00Z',
    'target': {'type': 'home'},
  },
];

List<CustomerNotification> seededNotifications() =>
    List.unmodifiable(mockNotificationsFixture.map(NotificationsCodec.item));
