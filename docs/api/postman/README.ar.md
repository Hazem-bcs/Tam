# تسليم عقد المصادقة — تم | Tam

إلى مطور Backend / Laravel:

هذا عقد مطلوب تنفيذه، وليس API يعمل حاليًا. ملف Postman يحتوي العقد العربي كاملًا في وصف المجموعة، وشرح كل مسار وأمثلة نجاح وفشل محفوظة تحته.

## الملفات

- `Tam-Authentication-v1.postman_collection.json`: استورده في Postman وافتح وصف المجموعة أولًا. هذا الملف وحده يكفي لقراءة كامل المتطلبات.
- `authentication-v1.md`: العقد الأصلي كاملًا دون تعديل.
- `authentication-v1.openapi.json`: مواصفة OpenAPI قابلة للاستيراد أو التحقق آليًا.

في المستودع: ملفا العقد وOpenAPI في `docs/api/`، وملف Postman وهذا الدليل في `docs/api/postman/`. الحزمة ZIP تجمع النسخ الأربع في مجلد واحد لتسهيل إرسالها.

## القراءة في Postman

1. افتح Postman واختر Import، ثم اختر ملف `.postman_collection.json`.
2. افتح المجموعة `Tam | تم — Authentication API Contract v1.0` واقرأ وصفها؛ العقد كامل موجود فيه.
3. افتح كل طلب لقراءة وصفه وBody وHeaders وAuthorization.
4. افتح Examples المحفوظة تحت الطلب لرؤية JSON المتوقع وأكواد HTTP والأخطاء.

## عند توفر الخادم

اضبط متغيرات المجموعة `base_url` و`language` و`phone_e164`. انسخ `challenge_id` من الرد، وأدخل `otp_code` الحالي. بعد Verify أو Refresh استخدم التوكنين المعادين في `access_token` و`refresh_token`. لا توجد سكربتات لحفظ الرموز تلقائيًا.

العنوان `https://api.example.com/api/v1` مثال فقط. الهاتف والرموز الفعلية فارغة في المتغيرات؛ أمثلة الاستجابات توضيحية. لا تشارك نسخة تحتوي بيانات اعتماد حقيقية.

مسار النجاح: Request OTP → Verify OTP → Get Current User → Refresh → Get Current User → Logout. عملية Resend اختيارية وتُجرّب بعد الانتظار، مع اختبار إبطال الرمز السابق وبقاء challenge_id.

## نقاط التسليم الأساسية

- ستة مسارات، دون Endpoint للضيف.
- تسجيل الدخول والتسجيل في عملية OTP واحدة.
- phone_e164 وcode وuser.id كنصوص؛ الرمز ست خانات.
- رسائل عربية وإنجليزية معًا داخل message، وأكواد أخطاء ثابتة.
- إدارة آمنة للرموز وحدود المحاولات وإعادة الإرسال وتدوير التوكنات وإبطال الجلسة.
- GET /auth/me فقط ضمن هذه المجموعة يستخدم Bearer access token؛ Refresh وLogout يستخدمان refresh_token في JSON ولا يتطلبان Access Token صالحًا.
- Logout يعيد 204 بجسم فارغ.
- تسليم Laravel Feature Tests وStaging ومزود اختبار SMS معزول عن الإنتاج، والتحقق من دعم أرقام +963.

العقد داخل المجموعة هو المرجع للمتطلبات التفصيلية. أمثلة الأخطاء الإضافية توضح البنية المطلوبة؛ نصوص الرسائل قابلة للتحسين بشرط الحفاظ على اللغتين والأكواد والأنواع.

مرجع استيراد الملفات الرسمي: https://learning.postman.com/docs/getting-started/importing-and-exporting/importing-data/
