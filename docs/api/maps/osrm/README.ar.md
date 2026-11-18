# تم — تكامل OSRM Route v1، 2026-11-18

اختار المستخدم OSRM لتجربة المسارات على الطرق. هذا تعديل صريح للتفضيل السابق بعدم استعمال خدمة توجيه عامة. حجز الرحلة والكابتن والدفع ما زالت محاكاة محلية؛ هندسة الطريق فقط تأتي من خدمة فعلية.

## التهيئة

- `MAP_OSRM_BASE_URL` يحدد host مستقلًا لخدمة OSRM. في debug، عندما لا يحدد `MAP_API_BASE_URL`، الافتراضي التجريبي `https://router.project-osrm.org`.
- في release/profile لا يختار التطبيق الخادم العام تلقائيًا. مرر host مملوكًا/مناسبًا للاستخدام الفعلي. `--dart-define=MAP_OSRM_BASE_URL=` يعطل هذا المزود صراحة، وتبقى routes من API المهيأ أو عدم التهيئة.
- إذا ضُبط backend للخرائط لا يستبدله التطبيق تلقائيًا بـOSRM. ضبط OSRM صراحة يختار المسارات فقط؛ search/reverse يبقيان من المصدر السابق. لا اتصال Nominatim عام أو fallback إلى mock عند فشل API.
- Dio مستقل بلا Bearer أو cookies؛ HTTPS، بلا redirects، مهل اتصال8ث/قراءة12ث. ضبط local HTTP يخضع للتحقق المركزي الموجود.

## الطلب والرد

`GET {osrm_base_url}/route/v1/driving/{origin_lng},{origin_lat};{destination_lng},{destination_lat}`

`overview=full&geometries=geojson&steps=false&alternatives=false&generate_hints=false&radiuses=100;100`

لا body أو credentials. ترسل الإحداثيات اللازمة للتوجيه فقط. GeoJSON بترتيب longitude ثم latitude؛ `code=Ok`، أول route له `geometry.type=LineString` و2..10000 نقطة، وdistance بالمتر وduration بالثانية. تعاد هندسة الطرق كما هي دون وصلات مستقيمة إلى دبوس خارج الطريق؛ snap حتى100م لكل طرف. لا يجعل ذلك المسافة/المدة تصريحًا بالسعر.

`NoRoute`/`NoSegment` → `ROUTE_NOT_FOUND`، HTTP429 → `RATE_LIMITED`، انقطاع/مهلة → `SERVICE_UNAVAILABLE`، رد/هندسة/قياسات غير صحيحة → `INVALID_RESPONSE`. لا نجاح وهمي أو fallback عند الخطأ. أمثلة الردود قابلة للاستيراد في مجموعة Postman المرفقة. `examples/route-damascus.json` رد حي محفوظ لإثبات التجربة؛ ليس fixture يحقن في UI.

## الحمل والخصوصية

صف واحد للتطبيق يترك1100ms على الأقل بين بدء طلبين. دمج الطلبات المتطابقة الجارية، cache ذاكرة حتى32 مسارًا ولمدة5دقائق. لا طلب لكل إطار سيارة. تصفر الذاكرة وتلغى الطلبات عند انتهاء الجلسة؛ الرد المتأخر لا يعيد بياناتها. انتهاء التطبيق يزيل cache الذاكرة؛ snapshots الرحلات التجريبية تحفظ المسار الحالي ضمن آلية الجلسة الموجودة.

الخادم التجريبي يسمح باستخدام معقول غير تجاري، بحد أقصى طلب واحد بالثانية، ولا يضمن التوافر أو حداثة البيانات. قبل الإنتاج يلزم استضافة OSRM أو اتفاق مزود مناسب. إسناد © OpenStreetMap contributors الموجود على الخريطة يبقى ظاهرًا.

## محاكاة السائق والتسليم للباكند

`MockRoadRoutes` يحضر مسارين للطلب: بذرة كابتن محلية بين نقطتي الطلب → الانطلاق، والانطلاق → الوجهة. `ActiveTripSimulation` يرسل fix كل ثانية، بالمسافة القوسية على polyline واتجاه المقطع. الزمن مضغوط للعرض لكن سرعة المحاكاة محدودة بنحو18م/ث حتى لا تقفز السيارة على الطرق الطويلة. الطريق نفسه يحترم اتجاهات خدمة driving؛ لا نستنتج طريقًا من خط يصل النقطتين.

إذا تأخر التحضير ينتظر الانطلاق دون قفزة زمنية. فشل التوجيه يبقي حالة الانتظار مع تنبيه وإعادة محاولة آلية كل10ث، وإمكانية الإلغاء؛ لا تتحرك السيارة على مسار اصطناعي. في اختبارات بلا مزود تبقى fixtures القديمة الحتمية داخل data/mock، موسومة road_aligned=false ومخفية من الرسم.

للإنتاج: GPS الكابتن الحقيقي وحالات الرحلة من الخادم، مع route لكل مرحلة وbearing وrecorded_at وrevision حسب `docs/api/active_trip/tracking-v1.1.ar.md`. لا توليد GPS محلي في API mode. هذا التسليم لا يضيف endpoint حجز أو يفعّل backend غير موجود.

المراجع: [Route API](https://project-osrm.org/docs/v5.24.0/api/#route-service)، [سياسة Demo الرسمية](https://github.com/Project-OSRM/osrm-backend/wiki/Demo-server).
