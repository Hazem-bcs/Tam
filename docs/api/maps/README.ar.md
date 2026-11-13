# ربط خرائط تم

العقد [maps-v1.md](maps-v1.md)، الأمثلة فيexamples/، وحزمة Postman مستقلة
ومضمنة أيضًا فيCollection العميل الموحدة.

تحديث 2026-11-13 بتوجيه المستخدم: البلاطات الافتراضية مؤقتًا من
`https://tile.openstreetmap.org/{z}/{x}/{y}.png` حتى تجهز الاستضافة الخاصة.
هذا اختيار صريح للمعاينة، وليس fallback عند فشل السيرفر الخاص.
تبقى خدمات البحث والعكس والمسار غير مهيأة دون `MAP_API_BASE_URL`.
لا يرسل التطبيق عنوان البحث أو توكنات الحساب إلى OSM؛ عارض البلاطات
يطلب الصور اللازمة للعرض فقط بمعرّف `TamCustomer/0.1 (com.tam.tam_customer)`،
وتخزين flutter_map المحلي يحترم HTTP caching headers وETag.
لا تنزيل مناطق أو prefetch. يظهر رابط `© OpenStreetMap contributors`
دائمًا على البلاطات العامة، وفق [سياسة المزوّد](https://operations.osmfoundation.org/policies/tiles/).

لاستبدال البلاطات بالسيرفر الخاص استخدم:

```bash
flutter run --no-pub -d emulator-5554 \
  --dart-define=MAP_TILES_URL_TEMPLATE=https://maps.your-domain/tiles/{z}/{x}/{y}.png \
  --dart-define=MAP_API_BASE_URL=https://api.your-domain/api/v1
```

استبدل النطاقين بعناوين خدماتنا الفعلية. DATA_MODE=mock يظل يحاكي الحجوزات؛
اختيار خدمات الخرائط مستقل وصريح. إعداد العناوين لا يحول mock booking
إلى طلب حقيقي، ولا يرقّي guest/localAccess إلى مصادقة API.

لإيقاف البلاطات صراحة استخدم `--dart-define=MAP_TILES_URL_TEMPLATE=`.
حينها يعمل العارض دون بلاطات، ويظهر عدم التهيئة.
يمكن الاختيار بالإحداثيات من اللوحة وتسميته يدويًا، وطلب GPS من الزر فقط.
هذا ليس خريطة offline أو إثبات طريق حقيقي. يجب توفير الخدمة لتقييم التغطية.

اختبارات Flutter تستعمل HTTP adapter ومزود صور ذاكرة وGPS platform بديلًا؛
لا توكنات أو اتصالات بخدمات عامة في الاختبارات؛ يعطّل harness التكامل البلاطات ويترك حقن مزوّد الاختبار متاحًا. يلزم اختبار HTTPS وCORS للويب وAndroid/iOS
على الخدمات الفعلية عند تسليمها. لم تُنشر بنية خرائط أو بيانات منطقة هنا.

MAP_ALLOW_LOCAL_HTTP يرخّص فقط التحقق من عنوان loopback في إعدادات Dart؛
لا يفتح cleartext في Android ولا يستثني ATS في iOS. لا يوجد استثناء منصة
عام أوخاص في هذا التسليم؛ استخدم HTTPS موثوقًا حتى في اختبار الجهاز.

نسبة OSM تفتح https://www.openstreetmap.org/copyright عند ضغط المستخدم فقط،
عبر محول url_launcher؛ هذه صفحة معلومات ترخيص، وليست خدمة خرائط تشغيلية.
لا تُفتح تلقائيًا ولا يمرر إليها التطبيق إحداثيات أو توكنًا. فشل فتحها ظاهر.
