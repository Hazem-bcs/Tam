/// Non-personal, deterministic GET /home v1 response. Matches API examples.
const homeSuccessFixture = <String, dynamic>{
  'data': {
    'revision': 'home-demo-1',
    'promotions': [
      {
        'id': 'promo-ride',
        'kind': 'hero',
        'title': {
          'ar': 'مشوارك أسهل مع تم',
          'en': 'Getting there is easier with Tam',
        },
        'subtitle': {
          'ar': 'من أول خطوة حتى وجهتك، اطلب رحلتك ببساطة.',
          'en': 'From pickup to destination, request a ride with ease.',
        },
        'enabled': true,
        'action': 'ride_request',
      },
      {
        'id': 'promo-future',
        'kind': 'announcement',
        'title': {'ar': 'مزايا جديدة في الطريق', 'en': 'More is on the way'},
        'subtitle': {
          'ar': 'تابعنا لمعرفة الخدمات الجديدة عند إطلاقها.',
          'en': 'Look out for new services as they launch.',
        },
        'enabled': false,
        'action': null,
      },
    ],
    'services': [
      {'id': 'ride', 'available': true, 'action': 'ride_request'},
      {'id': 'food', 'available': false, 'action': null},
      {'id': 'shopping', 'available': false, 'action': null},
    ],
  },
};

const homeEmptyFixture = <String, dynamic>{
  'data': {
    'revision': 'home-demo-empty-1',
    'promotions': <Object>[],
    'services': <Object>[],
  },
};
