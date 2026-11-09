# Ride request HTTP contract v1 — مقترح

> نطاق W1 التاريخي؛ التنفيذ الحالي يضيف [امتداد الجدولة v1](../scheduling/scheduling-v1.md)
> للموعد والسعر والتأكيد. اقرأ الحزمتين قبل تنفيذ الباكند.

الحالة: **Proposed / mock-first**، 2026-11-07؛ ليس إعلانًا عن وجود خادم. Base URL متغير `{{base_url}}` يشمل `/api/v1`، مثل `https://api.example.invalid/api/v1`.

## القواعد العامة

- `Accept: application/json`، `Accept-Language: ar|en` اختياري (افتراضي ar)، `Content-Type: application/json` لكل POST.
- `Authorization: Bearer <access_token>` مطلوب لـ `POST /ride-quotes` و`POST /trips` في API الحقيقي؛ `GET /places` عام مقترحًا. لا تستخدم الجلسات المحلية/الضيف كرموز موثقة. 401 `UNAUTHENTICATED`، 403 `FORBIDDEN`.
- JSON UTF-8؛ النجاح `{"data":...}`، وفشل الطلب `{"error":{"code":"...","message":{"ar":"...","en":"..."}}}`. يمكن إضافة `error.details` ككائن اختياري غير حساس؛ لا تعتمد الواجهة على نص رسالة خادم مباشرة.
- كل المعرفات `string` opaque وغير فارغة. القيم المالية `Money={amount_minor:int>=0,currency:string ISO 4217,minor_unit:int 0..3}`؛ مثال سوري `SYP / minor_unit=0`. لا تستخدم float للمال.
- `Location={label:string غير فارغ <=200 حرف,latitude:number [-90,90],longitude:number [-180,180]}`؛ الموقعان يجب أن يختلفا في الإحداثيات. إحداثيات الأمثلة اصطناعية للتطوير وليست موقع الجهاز.
- أوقات الخادم `ISO-8601 UTC` مع `Z` (مثل `2026-11-07T12:01:30Z`). لا ترسل زمن الجهاز كسعر نهائي. `duration_minutes:int>0` و`distance_meters:int>0` قيم تقديرية.
- الفئات المعروفة حاليًا `standard, comfort, van, motorbike`؛ تغيير القائمة ينسق مع Flutter. الحجز فوري فقط و`payment_method=cash`، بلا حقول wallet/coupon/schedule.
- أي اختيار مكان/فئة مختلف يبطل الـquote في العميل؛ الخادم يربط quote بمدخلاته ويتحقق منها مجددًا. كل فشل API يظل فشلًا ولا ينقلب إلى mock.

## GET /places

بحث الأماكن؛ طلب عام مقترح. Query params:

| الاسم | النوع | الإلزام | القيود |
| --- | --- | --- | --- |
| `q` | string | اختياري | بحث عربي/إنجليزي، trim؛ طول 0..100؛ الفارغ يعيد اقتراحات |
| `limit` | int | اختياري | 1..50، الافتراضي 20 |
| `cursor` | string | اختياري | opaque، غير فارغ إذا قدم |

الاستجابة `200`: `data:[Place]` و`meta:{next_cursor:string|null}`. كل Place يحتوي `id:string` و`label:string` و`label_en:string` و`latitude:number` و`longitude:number` وجميعها إلزامية/غير nullable؛ `label` عربي canonical في الأمثلة، و`label_en` بديل إنجليزي. النتائج الفارغة `data:[]` نجاح. ترتيب النتائج ثابت من المزود، وcursor لا يعيد السجل نفسه عند التصفح. Mock يعيد حتى خمسة أماكن ثابتة ولا يحتاج ترقيمًا فعليًا. مثال: `examples/places_success.json`، والفراغ `places_empty.json`.

الأخطاء: 422 `VALIDATION_ERROR` لمعاملات غير صالحة؛ 429 `RATE_LIMITED`؛ 503 `SERVICE_UNAVAILABLE`. لا تعاد بيانات مكان جهاز حقيقية ضمن المحاكاة.

## POST /ride-quotes

يُستخدم بعد اختيار مكانين وفئة، ويعاد كلما تغيّر الاختيار. **Authorization required**.

Request JSON، كل الحقول إلزامية وغير nullable:

```json
{
  "pickup": {"label":"المزة، شارع الجلاء","latitude":33.5,"longitude":36.25},
  "destination": {"label":"أبو رمانة، شارع الحمراء","latitude":33.519,"longitude":36.283},
  "vehicle_class_id": "standard"
}
```

`201 Created` (أو `200 OK` عند استخدام endpoint pure-quote إذا ثبت لاحقًا)؛ نوصي `201` لإنشاء مورد عرض سعر محدود العمر. `data` يحوي:
- `quote_id:string` معرف غير فارغ وopaque.
- `pickup:Location` و`destination:Location` موقعان معتمدان، غير nullable.
- `vehicle_class_id:string` من الفئات المذكورة، غير nullable.
- `fare:Money` السعر المحدد للعملة والوحدة، غير nullable.
- `distance_meters:int>0`، `duration_minutes:int>0`.
- `expires_at:UTC ISO-8601 Z` وقت نهاية الصلاحية **حصريًا**، غير nullable؛ `now >= expires_at` يُعد منتهيًا.

أمثلة: `quote_request.json` و`quote_success.json` (حزمة محاكاة ثابتة: 5019م، 18 دقيقة، 27000 ل.س؛ انتهاء بعد 90 ثانية من ساعة fixture). التسعير النهائي قرار الباكند، ولا يقبل `fare` يرسله العميل كمدخل.

الأخطاء: 400 JSON معطوب؛ 401/403؛ 422 `VALIDATION_ERROR` (موقعان متماثلان/فئة مجهولة/قيود المنطقة)؛ 429؛ 503. عند timeout يمكن إعادة طلب عرض سعر جديد ولا يُستخدم العرض القديم تلقائيًا.

## POST /trips

**Authorization required**، و`Idempotency-Key: UUID v4` **مطلوب**، فريد لكل نية حجز جديدة، محفوظ لإعادة المحاولة لنفس الطلب ونفس quote. الطلب كله إلزامي وغير nullable:

```json
{
  "quote_id": "mock-quote-1",
  "pickup": {"label":"المزة، شارع الجلاء","latitude":33.5,"longitude":36.25},
  "destination": {"label":"أبو رمانة، شارع الحمراء","latitude":33.519,"longitude":36.283},
  "vehicle_class_id": "standard",
  "payment_method": "cash"
}
```

لا يرسل العميل `fare`؛ يعيد الخادم التحقق من `quote_id` وربط pickup/destination/class بالمحتوى الذي سُعّر، وصلاحيته وسعره وتوفر فئة الخدمة والهوية والصلاحيات. لا يتم خصم أموال في هذه الموجة.

`201 Created`:
```json
{
  "data": {
    "id":"mock-trip-1",
    "pickup":{"label":"المزة، شارع الجلاء","latitude":33.5,"longitude":36.25},
    "destination":{"label":"أبو رمانة، شارع الحمراء","latitude":33.519,"longitude":36.283},
    "vehicle_class_id":"standard",
    "fare":{"amount_minor":27000,"currency":"SYP","minor_unit":0},
    "status":"requested",
    "created_at":"2026-11-07T12:00:30Z"
  }
}
```

`status`: `requested | confirmed | in_progress | completed | cancelled`؛ الحجز الجديد يبدأ `requested`. المستفيد C يقرأ نفس `Trip` عبر عمليات GET المملوكة له؛ لا يضاف endpoint قراءة هنا.

### منع التكرار والتعارض

- يخزن الباكند على نحو ذري أثر `(authenticated_user_id, Idempotency-Key, normalized_request_hash)` ونتيجة الطلب؛ إن أعيد نفس الطلب والمفتاح يرجع **نفس id والجسم/الحالة** دون رحلة إضافية، حتى لو انتهى quote بعد نجاح الحجز الأول. لا يكرر حالة إنشاء الرحلة.
- إعادة استخدام المفتاح مع جسم مختلف تُرجع `409 IDEMPOTENCY_CONFLICT` دون إنشاء رحلة. عند انتهاء quote قبل **أول** إنشاء تُرجع `410 QUOTE_EXPIRED` دون رحلة؛ العميل يعيد طلب quote ويولد مفتاحًا جديدًا.
- حفظ المفاتيح لمدة **24 ساعة على الأقل مقترح**، ويثبت الباكند مدة الحفظ، وحدود التزامن وسياسة التخزين قبل الإنتاج. الطلبان المتزامنان بالمفتاح نفسه يجب ألا يسببا رحلتين.
- عند timeout أو 503 غير حاسم **لا تولّد مفتاحًا جديدًا**؛ حاول بذات المفتاح والطلب حتى تعرف النتيجة. إذا تأكد فشل سابق قبل أي إنشاء وانتهى السعر، أعِد التسعير؛ لا تدّعِ نجاحًا.
- خلال النتيجة غير المحسومة، يقفل العميل تعديل المواقع والفئة وإعادة التسعير إلى أن تعيد المحاولة بالمفتاح الأصلي وتُحسم العملية؛ لا يمسح نية حجز قد تكون نُفذت بالفعل.
- في المحاكاة، `MockTripStore.create` يحقق التكرار وتعارض مدخلات الحجز، وRepository يربط المفتاح أيضًا بـquote_id حتى يُرفض تغيير العرض مع المفتاح نفسه ولو تساوى الموقعان والفئة والسعر. يستعمل instance محقونًا واحدًا فقط.

الأخطاء المتوقعة: 400 JSON معطوب؛ 401 `UNAUTHENTICATED`؛ 403 `FORBIDDEN`؛ 409 `IDEMPOTENCY_CONFLICT`؛ 410 `QUOTE_EXPIRED`؛ 422 `VALIDATION_ERROR` (quote مجهول/موقع/فئة/طريقة الدفع/مفتاح مفقود أو غير صالح)؛ 429 `RATE_LIMITED`؛ 503 `SERVICE_UNAVAILABLE`. يجب تضمين `error.code` الثابت و`error.message.ar/en`، مع `error.details` الاختياري للحقول غير الصالحة. لا تغير أكواد Auth الأصلية.

## التغييرات والتكرار والحدود

- إلغاء رحلة/تفاصيل/قائمة/ترقيم GET /trips ضمن ملكية C؛ لا تنشئ نسخة قراءة داخل B.
- في وضع mock `TripStatus.requested` فعليًا داخل store، لا يوجد سائق أو ضمان توفر حقيقي.
- بعد اعتماد العقد: إضافة transport API حقيقي باختبارات parsing وHTTP adapter، ولا يجوز API-mode fallback إلى mock.
- تثبيت حدود TTL، search ordering، policy العملات والوسيلة الفعلية، نتيجة إعادة محاولة POST وHTTP status 201 مع الباكند قبل التنفيذ الإنتاجي.
