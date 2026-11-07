# عقد Settings API — v1 (مقترح، غير منفّذ)

قاعدة `base_url` تتضمن `/api/v1`؛ الاستدعاءات أدناه نسبية إليها. جميعها تتطلب `Authorization: Bearer <access_token>` حقيقيًا (ليس دخول localAccess/guest)، و`Accept: application/json` و`Accept-Language: ar|en`. لطلبات PATCH أرسل `Content-Type: application/json`. التوكن يحصل عليه العميل من Auth الحالي دون تعديل عقد `/auth/me`.

## أشكال النقل

كل نجاح: `HTTP 200 { "data": { ... } }`. كل خطأ: `{ "error": { "code": "FIXED_CODE", "message": {"ar": "...", "en": "..." } } }`؛ لا تُرجع HTTP 200 على الخطأ. الحقول المطلوبة لا تعتمد على defaults صامتة. لا توجد قوائم أو ترتيب أو `limit/cursor` أو pagination بهذه الواجهات المفردة. لا يوجد وقت خادم أو سعر أو معرف مورد مطلوب في هذه النسخة. حقول الهوية `id` و`phoneE164` والتوكن خارج هذا العقد؛ الهاتف من Auth للعرض.

### GET /me/profile
الطلب بلا body. استجابة:
```json
{"data":{"display_name":"مستخدم تم","avatar_url":null}}
```

| الحقل | النوع | مطلوب؟ | nullable؟ | الوصف |
| --- | --- | --- | --- | --- |
| `display_name` | string | نعم | لا | الاسم الظاهر، 2–60 محرف Unicode بعد trim وطيّ المسافات؛ ليس اسم Auth موثقًا |
| `avatar_url` | string URL | نعم | **نعم** | صورة اختيارية للعرض فقط في هذه النسخة؛ لا تُدخل صورة وهمية إن كانت null |

### PATCH /me/profile
الطلب `{"display_name":"اسم جديد"}`؛ الحقل مطلوب، ممنوع null، لا يقبل `phone` أو `avatar_url` كحقل كتابة في v1. يحوّل الخادم مجموعات whitespace إلى مسافة واحدة، ويقص البداية والنهاية، ويرفض بعد التطبيع طولًا خارج `[2,60]` Unicode code points أو رموز التحكم المتبقية. لا يترجم الاسم بين اللغات. يرجع `200` مع الجسم الكامل كـGET (بما فيه `avatar_url`). لا يعدّل AuthUser ولا الهاتف. إعادة PATCH بنفس القيمة تحقق النتيجة نفسها؛ ليس تأكيدًا ماليًا ولا يلزم Idempotency-Key.

### GET /me/preferences
الطلب بلا body. استجابة:
```json
{"data":{"account_notifications_enabled":true}}
```

| الحقل | النوع | مطلوب؟ | nullable؟ | الوصف |
| --- | --- | --- | --- | --- |
| `account_notifications_enabled` | boolean | نعم | لا | رغبة الحساب في إشعارات التطبيق؛ لا يعني Push permission |

### PATCH /me/preferences
الطلب `{"account_notifications_enabled":false}`، الحقل مطلوب boolean لا نص `"false"` ولا null. يرجع `200` مع `data` كاملًا بنفس النوع. لا يُطلب إذن OS، ولا يرسل Push من تطبيق العميل. تعديل preferences لا يلمس display_name، والعكس صحيح.

## الأخطاء والحالات

| الحالة | HTTP | `error.code` | التعامل المطلوب |
| --- | --- | --- | --- |
| جلسة غائبة/منتهية | 401 | `AUTH_REQUIRED` | التدفق الموحد لـAuth، دون mock |
| جلسة لا تملك صلاحية | 403 | `FORBIDDEN` | إظهار منع حقيقي |
| حقل ناقص/نوع خاطئ/اسم قصير أو طويل | 422 | `VALIDATION_ERROR` | الاحتفاظ بالدرفت وإظهار الخطأ |
| خادم غير متاح | 503 | `SERVICE_UNAVAILABLE` | إبقاء البيانات المحفوظة كما هي وإتاحة Retry |
| فشل حفظ غير متوقع | 500 | `INTERNAL_ERROR` | عدم إظهار نجاح وهمي، إمكان retry |

الاستجابة `error.message.ar/en` **مطلوبة للغتين**. لا يغيّر فشل PATCH القيمة المحفوظة، وعلى العميل الاحتفاظ بالدرفت وإظهار Retry. بعد timeout مجهول النتيجة: استعلم GET للتحقق من حالة الحقل؛ يجوز إعادة PATCH المرغوب لأن العملية set-value idempotent. عند تعديلات متزامنة من جهازين: **آخر PATCH ناجح لكل حقل يفوز**؛ لا توجد version/ETag في v1، وهو قرار مفتوح لإصدار تالٍ إن لزم تحكم تنافسي. تعود الاستجابة بقيمة الخادم canonical بعد الحفظ؛ لا تعتمد الواجهة قيمة النص قبل التطبيع.

## بيانات المصادقة والخطوط الحمراء

تُطبّق قيود الوصول على الخادم، ولا يقبل `localAccess` أو `guest` بوصفهما Bearer token. مصدر `phoneE164` هو تدفق Auth الحالي للقراءة فقط. لا يغيّر هذا العقد `/auth/me` ولا يدعم تعديل الهاتف/إعادة OTP أو حذف الحساب أو محفظة أو عناوين أو إعدادًا للغة على الخادم.

## أمثلة وتطابق Mock

`examples/profile-get-success.json`, `examples/preferences-get-success.json`, `examples/profile-patch-request.json`, `examples/preferences-patch-request.json`, `examples/validation-error.json` تماثل أسماء الحقول في `SettingsWireMapper` و`SettingsFixtures`. تُستخدم نفس القواعد للتحقق بالعميل. المستودع الحقيقي لم يُنفّذ بعد؛ عند تنفيذ HTTP، يحوّل طبقة data أخطاء HTTP/DTO إلى `SettingsFailure` domain فقط، ولا يمررها Widgets مباشرة.

## نقاط للموافقة قبل API production

1. مكان خدمة صور الحساب مستقبلًا وحدود URL المسموح؛ حاليًا لا كتابة للصور.
2. هل نحتاج تعارض تعديل من عدة أجهزة (revision/ETag) لاحقًا؟
3. هل تفضيل إشعارات الحساب سيطبّق على الرسائل داخل التطبيق فقط أم لاحقًا Push؟ لا تفعّل Push في هذه الدفعة.
