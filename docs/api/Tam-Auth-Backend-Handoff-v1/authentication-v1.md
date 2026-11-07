# TAM | تم
# Authentication API Contract — Version 1.0

## إلى مطور Backend — Laravel

نريد بناء نظام مصادقة موحد لتطبيق **تم | Tam**.

العميل مبني باستخدام Flutter، والخادم باستخدام Laravel.

الهدف من هذه الوثيقة هو الاتفاق مسبقاً على واجهة اتصال ثابتة بين الطرفين، بحيث يستطيع مطور Flutter بناء ميزة المصادقة قبل اكتمال Backend دون الحاجة إلى تعديلات جوهرية عند الربط.

**هذا عقد API مطلوب تنفيذه، وليس وصفاً لواجهات موجودة حالياً.**

يُرجى الالتزام بأسماء المسارات والحقول وأنواع البيانات والاستجابات وأكواد الأخطاء المحددة هنا.

---

## 1. القواعد العامة

### API Base URL

```text
https://api.example.com/api/v1
```

العنوان السابق مثال فقط؛ يُستبدل بعنوان الخادم الفعلي.

تُضاف مسارات المصادقة إلى هذا المسار الأساسي.

مثال:

```text
POST https://api.example.com/api/v1/auth/otp/request
```

### Headers

```http
Accept: application/json
Content-Type: application/json
Accept-Language: ar
```

عند وجود جلسة مصادقة:

```http
Authorization: Bearer <access_token>
```

### Response Format

جميع الاستجابات الناجحة التي تحتوي بيانات تستخدم:

```json
{
  "data": {}
}
```

جميع استجابات الأخطاء تستخدم:

```json
{
  "error": {
    "code": "ERROR_CODE",
    "message": {
      "ar": "رسالة الخطأ بالعربية",
      "en": "Error message in English"
    }
  }
}
```

لا نريد أن يعيد أحد المسارات `message` كنص مباشر، بينما يعيد مسار آخر `message` على شكل كائن.

يجب أن يكون العقد موحداً.

### اللغات

التطبيق يدعم:

- العربية: `ar`
- الإنجليزية: `en`

**نريد أن تتضمن الرسائل النصية القابلة للترجمة اللغتين معاً.**

مثال:

```json
{
  "message": {
    "ar": "رمز التحقق غير صحيح",
    "en": "Invalid verification code"
  }
}
```

تطبيق Flutter يختار الرسالة المناسبة وفق لغة المستخدم.

بالنسبة إلى البيانات النصية متعددة اللغات في واجهات API المستقبلية، مثل أسماء الخدمات والتصنيفات، نعتمد شكلاً ثابتاً:

```json
{
  "name": {
    "ar": "تكسي عادي",
    "en": "Standard Taxi"
  }
}
```

أما البيانات الشخصية، مثل الاسم الذي أدخله المستخدم، فلا يجب ترجمتها اصطناعياً.

يجب أيضاً إرجاع `error.code` ثابت، حتى لا يعتمد منطق Flutter على مقارنة نصوص رسائل الأخطاء.

---

## 2. نموذج رقم الهاتف

يجب أن يعتمد Backend صيغة E.164.

مثال لرقم سوري:

```text
+963912345678
```

يستطيع تطبيق Flutter السماح بإدخال الرقم بالشكل المحلي، مثل:

```text
0912345678
```

ثم تحويله إلى الصيغة الدولية قبل إرسال الطلب.

على Backend التحقق من الرقم أيضاً، وعدم الاعتماد على تحقق Flutter وحده.

الحقل المعتمد دائماً:

```text
phone_e164
```

النوع:

```text
String
```

لا تستخدموا نوعاً رقمياً لتخزين أرقام الهواتف.

---

# 3. Request OTP

## Endpoint

```http
POST /auth/otp/request
```

### Request

```json
{
  "phone_e164": "+963912345678"
}
```

### Success Response — 200 OK

```json
{
  "data": {
    "challenge_id": "ch_8f6c91...",
    "phone_e164": "+963912345678",
    "expires_in_seconds": 120,
    "resend_after_seconds": 60,
    "attempts_remaining": 5
  }
}
```

### شرح الحقول

| Field | Type | Description |
|---|---|---|
| `challenge_id` | String | معرف عشوائي غير قابل للتخمين لعملية التحقق |
| `phone_e164` | String | رقم الهاتف بعد توحيد صيغته |
| `expires_in_seconds` | Integer | المدة المتبقية لصلاحية OTP |
| `resend_after_seconds` | Integer | الوقت اللازم قبل السماح بإعادة الإرسال |
| `attempts_remaining` | Integer | عدد محاولات التحقق المتبقية |

الأرقام الموجودة في المثال توضيحية؛ القيم الفعلية يحددها الخادم.

### شروط مهمة

- توليد OTP من الخادم فقط.
- إرسال الرمز عبر مزود SMS حقيقي.
- عدم إرجاع رمز OTP داخل الاستجابة.
- عدم تخزين OTP كنص صريح في قاعدة البيانات.
- عدم كشف ما إذا كان الرقم يمتلك حساباً مسبقاً.
- تطبيق Rate Limiting على الرقم وعنوان IP وعوامل إساءة الاستخدام المناسبة.
- استخدام Redis أو تخزين آمن مناسب للرموز المؤقتة ومحددات المعدل.

---

# 4. Resend OTP

## Endpoint

```http
POST /auth/otp/resend
```

### Request

```json
{
  "challenge_id": "ch_8f6c91..."
}
```

### Success Response — 200 OK

```json
{
  "data": {
    "challenge_id": "ch_8f6c91...",
    "phone_e164": "+963912345678",
    "expires_in_seconds": 120,
    "resend_after_seconds": 60,
    "attempts_remaining": 4
  }
}
```

### السلوك المطلوب

- يبقى `challenge_id` نفسه أثناء إعادة الإرسال، ما دامت عملية التحقق نفسها ما تزال صالحة.
- إصدار OTP جديد وإبطال الرمز السابق.
- تحديث مدة الصلاحية.
- احترام فترة الانتظار قبل إعادة الإرسال.
- منع المستخدم من تجاوز حدود المحاولات عبر طلب رموز متكررة.
- عدم السماح بإعادة الإرسال دون حدود.

إذا لم تنتهِ فترة الانتظار، يجب أن يعيد الخادم خطأ واضحاً مع مدة الانتظار المتبقية.

---

# 5. Verify OTP

## Endpoint

```http
POST /auth/otp/verify
```

### Request

```json
{
  "challenge_id": "ch_8f6c91...",
  "code": "483921"
}
```

**مهم:** `code` من نوع String حتى لا نفقد الأصفار الموجودة في بداية الرمز.

طول رمز OTP المعتمد في الإصدار الأول: **ست خانات رقمية**.

### Success Response — 200 OK

```json
{
  "data": {
    "user": {
      "id": "b8a9c7d1-2e44-4df3-9012-6f8a2b47e921",
      "phone_e164": "+963912345678",
      "phone_verified": true,
      "display_name": null,
      "created_at": "2026-11-04T12:00:00Z"
    },
    "session": {
      "token_type": "Bearer",
      "access_token": "<access_token>",
      "expires_in_seconds": 900,
      "refresh_token": "<refresh_token>",
      "refresh_expires_in_seconds": 2592000
    },
    "is_new_user": true
  }
}
```

### ملاحظات

`user.id` يجب أن يعامل كـString، حتى لو تغيرت استراتيجية المعرفات مستقبلاً.

`display_name` اختياري ويسمح بالقيمة `null`.

جميع التواريخ بصيغة ISO 8601 وبالتوقيت العالمي UTC.

`is_new_user` يحدد ما إذا أنشأ Backend الحساب أثناء عملية التحقق الحالية.

### إنشاء الحساب

يجب أن يكون تسجيل الدخول والتسجيل في مسار واحد.

السيناريو:

```text
OTP صحيح
    |
    v
هل المستخدم موجود؟
    |
    +-- نعم --> تسجيل الدخول
    |
    +-- لا --> إنشاء حساب جديد
                    |
                    v
               إنشاء جلسة
```

إنشاء المستخدم والجلسة يجب أن يتم بطريقة ذرية وآمنة ضد الطلبات المتزامنة والتكرار.

يُستخدم قيد فريد على رقم الهاتف الموحد لمنع تكرار الحسابات.

بعد نجاح التحقق، يجب إبطال OTP حتى لا يمكن إعادة استخدامه.

---

# 6. Refresh Access Token

## Endpoint

```http
POST /auth/token/refresh
```

### Request

```json
{
  "refresh_token": "<refresh_token>"
}
```

### Success Response — 200 OK

```json
{
  "data": {
    "session": {
      "token_type": "Bearer",
      "access_token": "<new_access_token>",
      "expires_in_seconds": 900,
      "refresh_token": "<new_refresh_token>",
      "refresh_expires_in_seconds": 2592000
    }
  }
}
```

### متطلبات أمنية

- استخدام Refresh Token Rotation.
- إبطال Refresh Token القديم بعد الاستبدال الناجح.
- منع الاستخدام المتكرر للرموز المبطلة.
- دعم إبطال جلسة المستخدم.
- استخدام تخزين آمن للرموز أو بصماتها على الخادم.
- عدم تسجيل الرموز داخل Logs.
- التعامل بصورة صريحة مع الطلبات المتزامنة وتجديد الرمز المكرر.
- ألا يؤدي فشل الاتصال المؤقت إلى اعتبار الجلسة مبطلة.

مدة صلاحية Access Token وRefresh Token تُدار من إعدادات Backend، ولا يضع Flutter افتراضات ثابتة حولها.

يمكن لمطور Laravel اختيار آلية تنفيذ التوكنات المناسبة، بشرط الالتزام بهذا العقد.

**تنبيه:** إذا استُخدم Laravel Sanctum، فإن نظام Refresh Token Rotation الموضح هنا يحتاج إلى تنفيذ إضافي؛ فهو ليس ميزة يوفرها Sanctum تلقائياً.

---

# 7. Get Current User

## Endpoint

```http
GET /auth/me
```

### Headers

```http
Authorization: Bearer <access_token>
```

### Success Response — 200 OK

```json
{
  "data": {
    "user": {
      "id": "b8a9c7d1-2e44-4df3-9012-6f8a2b47e921",
      "phone_e164": "+963912345678",
      "phone_verified": true,
      "display_name": null,
      "created_at": "2026-11-04T12:00:00Z"
    }
  }
}
```

يستخدمه Flutter للتحقق من هوية المستخدم واستعادة بياناته.

يجب أن يعتمد الخادم على الجلسة الفعلية، وليس على `user_id` يرسله العميل.

---

# 8. Logout

## Endpoint

```http
POST /auth/logout
```

### Request

```json
{
  "refresh_token": "<refresh_token>"
}
```

### Success Response

```http
204 No Content
```

لا يوجد جسم JSON في استجابة 204.

### السلوك

- إبطال الجلسة المرتبطة بالـRefresh Token.
- إبطال رموز الجلسة المرتبطة بها أو رفضها بعد تسجيل الخروج.
- إعادة 204 حتى لو كانت الجلسة مبطلة مسبقاً، عند الإمكان.
- على تطبيق Flutter حذف بيانات الجلسة المحلية بأمان.

لا نريد أن يعتمد تسجيل الخروج على وصول المستخدم إلى Access Token ما زال صالحاً؛ قد يرغب في تسجيل الخروج بعد انتهاء صلاحية Access Token.

---

# 9. Guest Mode

المستخدم الضيف لا يحتاج إلى حساب Backend.

**لا نريد Endpoint لتسجيل دخول الضيف في الإصدار الأول.**

حالة الضيف يديرها تطبيق Flutter محلياً.

عندما يدخل المستخدم كضيف:

- لا يُنشأ حساب جديد.
- لا يُنشأ Access Token.
- لا يُنشأ Refresh Token.
- يُسمح له بالوصول إلى الموارد العامة فقط.

كل Endpoint محمي يجب أن يتحقق من وجود جلسة مستخدم حقيقية.

الطلبات التي لا تحتوي مصادقة صالحة يجب أن تعيد `401 Unauthorized`.

المستخدم المصادق عليه الذي لا يملك صلاحية معينة يمكن أن يحصل على `403 Forbidden`.

---

# 10. Unified Error Contract

نريد تنسيقاً ثابتاً للأخطاء.

### مثال: OTP غير صحيح

HTTP:

```http
422 Unprocessable Content
```

Response:

```json
{
  "error": {
    "code": "OTP_INVALID",
    "message": {
      "ar": "رمز التحقق غير صحيح",
      "en": "Invalid verification code"
    },
    "attempts_remaining": 3
  }
}
```

### مثال: تجاوز معدل الطلبات

HTTP:

```http
429 Too Many Requests
Retry-After: 45
```

Response:

```json
{
  "error": {
    "code": "RATE_LIMITED",
    "message": {
      "ar": "طلبات كثيرة، يرجى المحاولة لاحقاً",
      "en": "Too many requests. Please try again later."
    },
    "retry_after_seconds": 45
  }
}
```

### أكواد الأخطاء المطلوبة

| HTTP | Error Code | الحالة |
|---|---|---|
| 422 | `PHONE_INVALID` | رقم الهاتف غير صالح |
| 422 | `OTP_INVALID` | رمز التحقق غير صحيح |
| 422 | `OTP_CHALLENGE_INVALID` | عملية التحقق غير صالحة |
| 410 | `OTP_EXPIRED` | انتهت صلاحية الرمز |
| 429 | `OTP_TOO_MANY_ATTEMPTS` | تجاوز محاولات التحقق |
| 429 | `OTP_RESEND_TOO_EARLY` | إعادة إرسال قبل انتهاء الانتظار |
| 429 | `RATE_LIMITED` | تجاوز معدل الطلبات |
| 503 | `OTP_DELIVERY_UNAVAILABLE` | خدمة إرسال الرسائل غير متاحة |
| 401 | `SESSION_INVALID` | جلسة غير صالحة أو منتهية |
| 401 | `SESSION_REVOKED` | جلسة أُبطلت |
| 403 | `ACCOUNT_DISABLED` | الحساب معطل |
| 403 | `FORBIDDEN` | المستخدم لا يملك الصلاحية |
| 500 | `INTERNAL_ERROR` | خطأ غير متوقع في الخادم |
| 503 | `SERVICE_UNAVAILABLE` | الخدمة غير متاحة مؤقتاً |

يجب أن يكون `error.code` ثابتاً وقابلاً للاعتماد عليه برمجياً.

يمكن إضافة حقول أخرى للأخطاء، بشرط عدم كسر الحقول الأساسية.

أخطاء الشبكة المحلية، مثل عدم وجود اتصال بالإنترنت أو انتهاء مهلة الاتصال، يعالجها Flutter حتى لو لم تصل أي استجابة من Backend.

---

# 11. قواعد الأمان

متطلبات إلزامية:

1. عدم كشف OTP في أي استجابة إنتاجية.
2. عدم تسجيل OTP أو Access Token أو Refresh Token في Logs.
3. تخزين رموز OTP بصورة آمنة مع تاريخ انتهاء.
4. فرض حدود زمنية وعددية على إرسال الرموز والتحقق منها.
5. منع كشف وجود الحسابات عبر اختلاف استجابة طلب OTP.
6. منع إنشاء حسابات متكررة لنفس رقم الهاتف.
7. إبطال OTP مباشرة بعد استخدامه بنجاح.
8. حماية Refresh Tokens وتدويرها.
9. دعم إبطال الجلسات.
10. استخدام HTTPS في الإنتاج.
11. توثيق صلاحية كل Endpoint وتطبيق الصلاحيات على الخادم.
12. عدم الاعتماد على قيود Flutter لحماية بيانات المستخدمين.

يجب التحقق عملياً من قدرة مزود الرسائل على إرسال OTP إلى أرقام سوريا `+963` قبل اعتماد الخدمة للإنتاج.

---

# 12. Versioning and Compatibility

جميع مسارات API الحالية تقع ضمن:

```text
/api/v1
```

بعد الاتفاق على العقد:

- لا نغير أسماء الحقول دون تنسيق.
- لا نغير أنواع الحقول دون إصدار جديد أو اتفاق مسبق.
- لا نغير نوع استجابة `message` بين String وObject.
- لا نغير أسماء أكواد الأخطاء المستخدمة بواسطة Flutter.
- يمكن إضافة حقول اختيارية جديدة دون كسر التوافق.
- يجب إبلاغ مطور Flutter قبل أي تغيير غير متوافق.

يفضل إنشاء توثيق OpenAPI يعكس هذا العقد بدقة.

---

# 13. Integration Deliverables

نحتاج من مطور Backend تسليم:

1. جميع Endpoints الستة.
2. تنفيذ آمن لإرسال والتحقق من OTP.
3. إدارة الجلسات وتجديد الرموز.
4. نماذج الأخطاء الموحدة.
5. دعم العربية والإنجليزية في الرسائل.
6. اختبارات Laravel Feature Tests للحالات الناجحة والفاشلة.
7. ملف OpenAPI يوثق المسارات والحقول والاستجابات.
8. بيئة Staging قابلة للاختبار.
9. طريقة اختبار آمنة في بيئة التطوير دون إرسال SMS حقيقي لكل اختبار.

بيئة التطوير يمكنها استخدام SMS Fake Provider، لكن يجب عزله تماماً عن الإنتاج.

عند الانتهاء، سلّم لمطور Flutter:

```text
API_BASE_URL
OpenAPI Specification
Test Environment Details
Supported Phone Regions
OTP Configuration
Token Expiration Policy
Error Codes
```

لا تُرسل مفاتيح SMS السرية أو مفاتيح توقيع الرموز إلى تطبيق Flutter.

---

# 14. Acceptance Criteria

نعتبر Auth API جاهزاً للربط عندما يتحقق التالي:

- يستطيع رقم جديد التسجيل عبر OTP.
- يستطيع رقم مسجل تسجيل الدخول عبر OTP.
- يحصل التطبيق على User وSession وفق النموذج المتفق عليه.
- يستطيع التطبيق تجديد Access Token دون إعادة تسجيل الدخول.
- يستطيع التطبيق استعادة بيانات المستخدم بعد إعادة فتحه.
- يستطيع المستخدم تسجيل الخروج مع إبطال الجلسة.
- تعمل حالات Invalid OTP وExpired OTP وRate Limiting بصورة صحيحة.
- جميع الأخطاء تستخدم الأكواد والبنية المحددة.
- جميع الرسائل القابلة للترجمة متوفرة بالعربية والإنجليزية.
- تنجح اختبارات الأمان والاختبارات الوظيفية الأساسية.

## Final Requirement

The Flutter team must be able to replace FakeAuthRepository with the real Laravel-backed repository without redesigning the authentication UI, domain entities, BLoC state model, or navigation architecture.

**API contract compatibility is a delivery requirement, not an optional improvement.**