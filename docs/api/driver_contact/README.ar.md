# تسليم الاتصال بالسائق — v1

استورد driver_contact-v1.postman_collection.json؛ وصف المجموعة يحتوي
[العقد](driver_contact-v1.md) كاملًا. اضبط base_url وaccess_token وtrip_id
وdriver_id للسائق المعيّن فعلًا. GET يطلب وسيلة اتصال مخولة، ولا يعيّن سائقًا.

Flutter يتحقق من الرحلة والسائق والصلاحية ورقمE164، ثم يفتح تطبيق الهاتف.
لا URL حر أوCALL_PHONE أو ادعاء أن المكالمة تمت. الخادم يختار الرقم المخول
لهذا السياق؛ لا نعد بخدمة إخفاء أرقام لم توفرها البنية. لا رقم في history.

المحاكاة تستخدم المخزن المشترك وMockPhoneDialer، ولا تتصل بأرقام fixtures.
DRIVER_CONTACT_DATA_MODE مستقل؛ السيناريو success/offline/unavailable.
API غير الجاهز يفشل بوضوح. أمثلة JSON مقروءة آليًا ومطابقة للـcodec؛ لم
يُنفذ استيراد Postman فعلي أو اتصال جهاز أو backend حي ضمن الفحوص الحالية.
