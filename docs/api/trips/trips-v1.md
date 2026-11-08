# Trip history API — عقد مقترح v1

**Status: PROPOSED / NOT IMPLEMENTED / NOT LIVE VERIFIED.** المالك: W1-TRIPS (C)، تاريخ الإعداد: 2026-11-07. التكامل مع B يعتمد أنواع الرحلة المشتركة في `shared/domain/trip.dart` و`docs/engineering/wave-one-contracts.md`.

## قواعد عامة

- `base_url = https://api.example.invalid/api/v1` قيمة توضيحية فقط، ولا يدخل `/api/v1` ثانية ضمن المسارات.
- جميع العمليات تتطلب `Authorization: Bearer <access_token>` لجلسة `authenticated` حقيقية، و`Accept: application/json`؛ `Content-Type: application/json` لعمليات لها جسم فقط. لا تُقبل حالة `guest/localAccess` كجلسة API.
- نجاح: `{"data":...}`، وترقيم: `{"data":[...],"meta":{"next_cursor":null|string}}`. إخفاق: `{"error":{"code":"CODE","message":{"ar":"...","en":"..."}}}` دون التفاف `data`.
- `id` سلسلة opaque غير فارغة، لا تعتمد على أرقام متسلسلة؛ يُرمّز مكوّن URL وفق URI encoding عند الاستعمال. `created_at` نص ISO-8601 UTC ينتهي `Z` ويُحوّل محليًا للعرض.
- لا يُسمح بإظهار رحلات مستخدم آخر. API يتحقق من الملكية في `GET detail` و`cancel`، ويفلتر القائمة حسب المستخدِم. يمكن إرجاع 404 بدل 403 لتجنب تسريب وجود رحلة؛ يثبت القرار مع الباكند.

## شكل Trip (required، ولا توجد nullable داخله)

| الحقل | النوع والقيود |
|---|---|
| `id` | string غير فارغ opaque |
| `pickup`, `destination` | TripLocation object مطلوب |
| `pickup.label`, `destination.label` | string غير فارغ؛ لا يعني GPS حيًا |
| `pickup.latitude`, `destination.latitude` | number finite بين -90 و90 |
| `pickup.longitude`, `destination.longitude` | number finite بين -180 و180 |
| `vehicle_class_id` | string غير فارغ؛ مثل `standard`؛ يتطابق مع B |
| `fare` | Money object مطلوب، أجرة الرحلة السابقة لا عرض سعر جديد |
| `fare.amount_minor` | integer >= 0؛ لا تستخدم float للأموال |
| `fare.currency` | string ISO 4217 كبير 3 أحرف؛ مثال `SYP` |
| `fare.minor_unit` | integer بين 0 و3؛ في سيناريو SYP = 0 |
| `status` | `requested`, `confirmed`, `in_progress`, `completed`, `cancelled` |
| `created_at` | string ISO-8601 UTC مثل `2026-11-01T12:00:00.000Z` |

كل الحقول المذكورة **required non-null**؛ لا يفترض Flutter قيمة عندما يغيب حقل. لا توجد `driver`، GPS tracking، `payment_method`، `rating`، `discount`، ETA أو route geometry ضمن v1. بيانات التاريخ/العناوين في seed تجريبية.

## GET /trips

Query:
- `filter` اختيارية؛ enum `all|active|completed|cancelled`، الافتراضي `all`. `active` تشمل `requested`, `confirmed`, `in_progress`.
- `limit` اختيارية؛ integer من 1 إلى 50، الافتراضي 20.
- `cursor` اختيارية؛ string opaque غير فارغة تصدر من `meta.next_cursor`. لا ينشئها العميل ولا يفسرها.

`200 OK`: `data: Trip[]` و`meta.next_cursor: string|null` **required nullable**. الترتيب `created_at DESC` ثم `id ASC` لكسر التعادل. عند انتهاء النتائج: `next_cursor=null`. لا عناصر مكررة بين الصفحات لنفس snapshot؛ التغييرات المتزامنة تعالجها سياسة cursor معتم مرتب، مع refresh لإعادة بدء التصفح. الفلاتر الفارغة نجاح 200 و`data=[]`. الأمثلة: `examples/trips-page-1.json`, `examples/trips-empty.json`.

## GET /trips/{id}

`id` إلزامي opaque URL component. `200 OK`: `{"data":Trip}` كما في `examples/trip-details.json`. غير الموجود أو غير المصرّح بوجوده: `404 TRIP_NOT_FOUND`؛ لا `data:null` ناجحة في هذا العقد. في mock، `find` تُعيد null وتُحوّل إلى واجهة not-found لأن الفشل من الخادم غير مفعل.

## POST /trips/{id}/cancel

لا يوجد JSON body. يُنفذ بعد تأكيد واضح في UI، والسيرفر لا يعتمد على زر مخفي كحماية. الحالات:
- `requested` / `confirmed`: تحويل ذري إلى `cancelled`، `200 OK` مع `{"data":Trip}` محدثة.
- `cancelled`: رد **idempotent** `200 OK` بنسخة ملغاة نفسها، دون إنشاء إجراء أو استرداد ثانٍ.
- `in_progress` / `completed`: `409 TRIP_NOT_CANCELLABLE` دون تغيير.
- غير موجودة: `404 TRIP_NOT_FOUND`. شرط ملكية الرحلة ينطبق دائمًا.

العميل يعطّل زر الإلغاء أثناء الإرسال؛ في timeout يمكنه قراءة التفاصيل وإعادة إلغاء الرحلة بأمان لأن العملية idempotent. يعود مصدر الحقيقة إلى رد الخادم عند نجاحه، ولا يختلق إلغاء عند فشل الشبكة.

## أخطاء HTTP المتوقعة

| HTTP | error.code | الدلالة |
|---|---|---|
| 401 | `UNAUTHORIZED` | لا توجد جلسة صالحة؛ يدخل ضمن Auth لا fake token |
| 403 | `FORBIDDEN` | الصلاحية أو ملكية المورد (أو 404 لتجنب تسريب وجوده) |
| 404 | `TRIP_NOT_FOUND` | id غير موجود/غير مرئي للعميل |
| 409 | `TRIP_NOT_CANCELLABLE` | الحالة لا تسمح بالإلغاء |
| 422 | `VALIDATION_ERROR` | قيم filter, limit, cursor أو path غير صالحة |
| 503 | `SERVICE_UNAVAILABLE` | خدمة غير جاهزة/مؤقتًا غير متاحة |

لا تُعيد API وضع mock عند فشل الخادم. نطاقات HTTP مثل `429/500` تتعامل معها طبقة النقل كإخفاق عام مع retry مناسب، وليست نجاحًا صامتًا.

## مصفوفة الواجهة/الاختبارات

| فعل/شاشة | Flutter | API | تحقق |
|---|---|---|---|
| كل/جارية/مكتملة/ملغاة | `TripsListCubit.selectFilter` | `GET /trips?filter=...` | الحالة وتصنيف active |
| سحب تحديث/صفحة تالية | `refresh/loadMore` | `GET /trips?cursor=...` | dedup، انتهاء cursor، فشل/إعادة |
| تفاصيل عبر `tripId` | `TripDetailsCubit.reload` | `GET /trips/{id}` | null/not found، التغيير الحي في mock |
| إلغاء مؤكد | `TripDetailsCubit.cancel` | `POST /trips/{id}/cancel` | الحظر/الإعادة والتحديث |
| «اطلب مجددًا» | `CustomerNavigation.openRideRequest(TripPrefill)` | **يمتلكه B** | لا يحمل السعر/الطلب القديم |

**نقاط مفتوحة للتنسيق:** آلية push/polling وETag للتحديث الحقيقي؛ سياسة cursor عند تغيّر الفلاتر أثناء pagination، وتوحيد أكواد أخطاء النقل مع Auth عند التنفيذ. تغييرات شكل Trip المشتركة تحتاج موافقة المشرف وB.
