# ربط خرائط تم

العقد [maps-v1.md](maps-v1.md)، الأمثلة فيexamples/، وحزمة Postman مستقلة
ومضمنة أيضًا فيCollection العميل الموحدة. لا خدمات عامة افتراضية.

```bash
flutter run --no-pub -d emulator-5554 \
  --dart-define=MAP_TILES_URL_TEMPLATE=https://maps.your-domain/tiles/{z}/{x}/{y}.png \
  --dart-define=MAP_API_BASE_URL=https://api.your-domain/api/v1
```

استبدل النطاقين بعناوين خدماتنا الفعلية. DATA_MODE=mock يظل يحاكي الحجوزات؛
اختيار خدمات الخرائط مستقل وصريح. إعداد العناوين لا يحول mock booking
إلى طلب حقيقي، ولا يرقّي guest/localAccess إلى مصادقة API.

بلا عناوين، يعمل عارض الخريطة دون تحميل بلاطات أو مسار ويظهر عدم التهيئة.
يمكن الاختيار بالإحداثيات من اللوحة وتسميته يدويًا، وطلب GPS من الزر فقط.
هذا ليس خريطة offline أو إثبات طريق حقيقي. يجب توفير الخدمة لتقييم التغطية.

اختبارات Flutter تستعمل HTTP adapter ومزود صور ذاكرة وGPS platform بديلًا؛
لا توكنات أو اتصالات بخدمات عامة. يلزم اختبار HTTPS وCORS للويب وAndroid/iOS
على الخدمات الفعلية عند تسليمها. لم تُنشر بنية خرائط أو بيانات منطقة هنا.
