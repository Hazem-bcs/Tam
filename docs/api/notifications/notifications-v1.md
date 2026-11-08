# عقد إشعارات العميل v1.0 — مقترح للباكند

**الحالة:** مقترح، غير مطبق على الخادم، غير متحقق حيًا. **Owner:** W1-NOTIFICATIONS (D).
**Base URL:** `https://api.example.com/api/v1` مثال غير حي. المسارات أدناه نسبية إلى `/api/v1`.

## 1. الترويسات والمصادقة والشكل العام

- `Accept: application/json`، و`Accept-Language: ar|en`.
- `Authorization: Bearer <access_token>` **إلزامي** في API لجميع العمليات؛ ينطبق Auth القائم دون تعديل. استجابة 401 عند الغياب/انتهاء الجلسة، 403 للمنع. لا تستخدِم localAccess أو guest كجلسة API حقيقية.
- `Content-Type: application/json` لعمليات POST مع الجسم `{}` (لا حقول إضافية).
- نجاح القراءة: `{ "data": ..., "meta": { "next_cursor": string|null } }` للقائمة، و`{ "data": ... }` للبقية.
- الخطأ: `{ "error": { "code": "STABLE_CODE", "message": { "ar": "...", "en": "..." } } }`؛ قرارات التطبيق بالأكواد لا بنص الرسالة.
- الأوقات ISO-8601 UTC وتنتهي حرفيًا `Z`، ويحوّل Flutter التاريخ إلى التوقيت المحلي للعرض. النصوص المترجمة كائنان `{ ar: string, en: string }` غير فارغين.

## 2. نموذج الإشعار

| الحقل | النوع | السماح بـ null؟ | الدلالة |
|---|---|---|---|
| `id` | string، opaque، غير فارغ | لا | معرف فريد ثابت، لا تفترض صيغة رقمية. |
| `kind` | string | لا | `trip`, `offer`, `account`, `system`؛ أي قيمة مستقبلية تُعرض بأيقونة عامة. |
| `title` | object `{ar,en}` | لا | نص قصير بلغتين. |
| `body` | object `{ar,en}` | لا | وصف بلغتين؛ لا HTML تنفيذي. |
| `created_at` | UTC ISO-8601 `Z` | لا | تاريخ الإنشاء والترتيب. |
| `read_at` | UTC ISO-8601 `Z` | نعم | `null` تعني غير مقروء. التعليم لا يغيّر القيمة إن كانت موجودة. |
| `target` | object | لا | `type: home|trips|trip` أو قيمة جديدة غير معروفة. |
| `target.trip_id` | string opaque | نعم / غائب | مطلوب وغير فارغ فقط حين `type=trip` لتنقل صالح. |

**أمان التنقل:** allowlist ثابتة `home / trips / trip`. ينقل Flutter إلى التفاصيل بواسطة `CustomerNavigation.openTrip(trip_id)` فقط، لا بفتح URL أو route من JSON. `target.type` غير معروف أو `trip_id` فارغ: يُعرض نص الإشعار، **ولا تنقل**. يمكن أن يحتوي JSON إضافات مجهولة؛ يجب تجاهلها وعدم تنفيذها. مثال `notice-unknown-001` يعرض `target.type=external` و`url` لأغراض اختبار الرفض فقط؛ لا ينبغي أن يطلبه الباكند للإنتاج. إشعار الرحلة الأساسي يستخدم `mock-history-001`، نفس seed للرحلات في Flutter.

## 3. GET /notifications

**Query:** `limit` اختياري، عدد صحيح افتراضي 20 في المجال 1..50؛ `cursor` اختياري opaque string (لا تفسره الواجهة). لا يوجد filter إلزامي في v1. استجابة HTTP 200:

```json
{
  "data": [
    {
      "id": "notice-trip-complete-001",
      "kind": "trip",
      "title": {"ar": "اكتملت رحلتك", "en": "Your trip is complete"},
      "body": {"ar": "شكرًا لاختيارك تم. يمكنك مراجعة تفاصيل رحلتك.", "en": "Thanks for choosing Tam. Review your trip details."},
      "created_at": "2026-11-07T12:20:00Z",
      "read_at": null,
      "target": {"type": "trip", "trip_id": "mock-history-001"}
    }
  ],
  "meta": {"next_cursor": "bjE6Mg"}
}
```

المثال أعلاه مختصر توضيحي؛ `examples/notifications-page-1.json` يتضمن العنصرين المتطابقين مع طلب `limit=2`. الترتيب **`created_at DESC, id ASC`**، مع عدم تكرار `id` بين الصفحات. `next_cursor=null` يعني النهاية. القائمة الفارغة نجاح `200` و`data=[]`. ينسق الباكند cursor ثابتًا عبر الصفحات في وجود إشعارات جديدة (نقترح cursor مقيّدًا بلقطة القائمة)؛ عند انتهاء/فساد cursor يُعيد `INVALID_CURSOR` حتى يبدأ العميل من الصفحة الأولى. تغير `read_at` لا يعيد ترتيب القائمة.

## 4. GET /notifications/unread-count

استجابة HTTP 200: `{"data":{"unread_count":4}}`. عدد صحيح غير سالب؛ يُحسب لكل حساب المستخدم، بما فيها العناصر غير المحمّلة في القائمة. يعد هذا endpoint مصدر الحقيقة للعداد. يُطلب عند فتح الصندوق وعند إعادة المزامنة؛ في المستقبل يحق لخادم الحدث دفع تحديثات موثوقة إلى المستودع نفسه، دون إنشاء عداد ثانٍ داخل Home.

## 5. POST /notifications/{id}/read

`id` مُعرّف opaque يُرمّز عند تكوين URI؛ الجسم `{}`. استجابة HTTP 200 تعيد `{"data": <Notification>}` مع `read_at` غير null. العملية **idempotent**: إذا كان مقروءًا سابقًا، يُعيد `read_at` الأصلية، ولا يُنقص العدد مجددًا. تعيين عنصر لا يخص الحساب يعامل كـ404 دون كشف وجوده. لا تفترض الواجهة نجاح القراءة قبل استجابة ناجحة؛ بعد timeout يمكن تكرار الطلب بأمان. مثال `examples/mark-read.json`.

## 6. POST /notifications/read-all

الجسم `{}`، استجابة HTTP 200 `{"data":{"read_at":"2026-11-07T15:00:00Z","unread_count":0}}`. يطبَّق على كل إشعارات الحساب غير المقروءة **بعملية ذرّية**، حتى غير المحمّلة. يُرجع `read_at` وقت العملية الذي يُستخدم فقط لتحديث العناصر التي كانت غير مقروءة؛ تُحفَظ أوقات قراءة العناصر القديمة. تكرار العملية آمن: يبقى العدد 0، ولا تُسجَّل إنقاصات إضافية. عند timeout يعيد العميل العملية ثم يراجع unread-count. مثال `examples/mark-all-read.json`.

## 7. أخطاء موحّدة وإعادة المحاولة

| HTTP | `error.code` | الحالات |
|---|---|---|
| 400 | `INVALID_CURSOR` | cursor فاسد/منتهي أو `limit` خارج 1..50. |
| 401 | `UNAUTHENTICATED` | جلسة مفقودة/منتهية؛ لا تستخدم Auth محاكى كبديل. |
| 403 | `FORBIDDEN` | حق وصول مرفوض. |
| 404 | `NOTIFICATION_NOT_FOUND` | معرف غير موجود أو غير مملوك. |
| 422 | `VALIDATION_ERROR` | جسم POST أو query غير صالح، مع رسائل باللغتين. |
| 429 | `RATE_LIMITED` | استخدام مفرط، احترم `Retry-After` إن وجد. |
| 503 | `SERVICE_UNAVAILABLE` | خدمة غير متاحة؛ لم يكتمل التعديل. |
| 500 | `INTERNAL_ERROR` | عطل عام لا يُعرض نصه الخام للمستخدم. |

في أخطاء HTTP أو الاتصال، لا تعدّل حالة القراءة محليًا بصورة مؤكدة؛ احتفظ بحالة آخر نجاح واعرض خطأ وإعادة محاولة. قد يكون timeout حصل بعد تطبيق التعديل فعليًا؛ idempotency والتحديث من المستودع يضمنان التقارب. يعرض العميل بيانات الصفحة السابقة بعد فشل تحديثها مع رسالة واضحة، ولا يُبنى عدد جديد من العناصر المحمّلة.

## 8. مصفوفة الربط والمسؤوليات

| التدفق | Domain repository | API |
|---|---|---|
| فتح الصندوق/السحب للتحديث | `getPage(limit,cursor)` | GET /notifications |
| الترقيم | `getPage(cursor)` | GET /notifications |
| الشارة وعدد غير المقروء | `getUnreadCount()` و`unreadChanges` | GET /notifications/unread-count |
| نقر إشعار جديد | `markAsRead(id)` | POST /notifications/{id}/read |
| تعيين الكل | `markAllAsRead()` | POST /notifications/read-all |
| فتح وجهة مصرح بها | `NotificationTarget` + `CustomerNavigation` | لا API إضافي؛ رحلة قائمة في GET /trips/{id} عند الربط |

المحاكاة حالياً ثابتة seed وبداخل الذاكرة؛ لا Push أو SDK للنظام. **على الباكند** تطبيق auth والملكية والترتيب والعداد الذري وidempotency والأخطاء؛ **على Flutter مستقبلًا** تنفيذ HTTP adapter مع اختبار body/error parsing والتحقق من الجلسات وretry. **نقطة تنسيق:** تثبيت عمر cursor وسياسة اتساق الصفحات تحت التغييرات المتزامنة قبل الاعتماد النهائي.
