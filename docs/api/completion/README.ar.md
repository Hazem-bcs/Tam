# ملخص الرحلة والتقييم — حزمة الباكند v1

**الحالة: عقد مقترح لتنفيذ الباكند، غير متحقق مع خادم حي.** التطبيق الحالي
يستخدم محاكاة جلسة محلية، ولا ينشئ تقييمًا على خادم أو عملية دفع أو إيصالًا.
API mode يعرض SERVICE_UNAVAILABLE صراحة دون نجاح وهمي أو fallback.

- العقد الكامل: [completion-v1.md](completion-v1.md).
- استورد `completion-v1.postman_collection.json` كـCollection v2.1؛ اضبط
  `base_url` و`access_token` و`trip_id`، وللتقييم `idempotency_key` جديدًا آمنًا.
  لا تحتوي الحزمة أسرارًا. النطاق example.invalid توضيحي غير قابل للتشغيل.
- نفّذ GET للرحلة المكتملة، ثم POST بتقييم1..5 وتعليق اختياري. بعد قبول
  التقييم يظهر للقراءة فقط. عند فقد الرد استخدم GET أو نفس POST بنفس المفتاح
  والحمولة؛ لا تُنشئ مفتاحًا جديدًا لتجاوز عدم اليقين.
- `examples/unrated.json` يطابق `seedMockTrips().first`، و`rated.json` يطابق
  MockCompletionRepository عند2026-11-09T12:00:00Z والحمولة المحفوظة في
  `submit-request.json`. باقي الأمثلة أخطاء موثقة في العقد وPostman.

اختيار المصدر والسيناريو مركزيان فيAppConfig بتنسيق المشرف:
`COMPLETION_DATA_MODE` يرث `DATA_MODE`، والسيناريو
`COMPLETION_MOCK_SCENARIO=success|offline|lost_response`.
المحاكاة تستخدمMockTripStore نفسه ولا تغير دورة الرحلة. التقييمات المقبولة
تستعاد طوال جلسة المستودع وتُمسح عندresetSession؛ المسودة والمفتاح غير المقبول
ليساoutbox دائمًا ويزولان بإغلاق الصفحة. في الخدمة الحقيقية تبقى التقييمات
المقبولة مرتبطة بالحساب عبر الخادم؛ إعادة فتح التطبيق تحسمها GET.

الفحص الآلي يغطي JSON وقراءةالأمثلة وroundtrip ومطابقة المحاكاة وsaved responses.
لم يُنفذ استيراد فعلي بتطبيقPostman، ولم تُرسل طلبات حية. توثيق المصادقة
لا يغيّر Auth أوguest/localAccess؛ يجب على الباكند تفويض كل عملية فعليًا.
