# تم — الخرائط المستضافة على خوادمنا v1

مقترح تنفيذ2026-11-10؛ الخدمات لم تجهز بعد. لا يعتمد العميل على خوادم
OpenStreetMap العامة أو Google مباشرة. تغطي هذه الحزمة واجهات عرض الخريطة
واختيار المكان والمسار؛ لا تنشئ حجزًا أو سعرًا أو جلسة Auth.

## الاستضافة والتهيئة

- طبقة العرض raster XYZ: PNG بحجم256×256، zoom3..19 وWeb Mercator.
  `MAP_TILES_URL_TEMPLATE=https://maps.your-domain/tiles/{z}/{x}/{y}.png`.
  تخدمها بنيتنا من بيانات OSM المرخصة؛ هذه قيمة توضيحية وليست خدمة متاحة.
  لا مفاتيح إدارية أو روابط سرية في Flutter، ولا redirects إلى خدمات عامة.
- `MAP_API_BASE_URL=https://api.your-domain/api/v1` للبحث والعكس والمسار.
  قد يكون نفس base_url لبقية التطبيق؛ لا يرسل العميل Bearer أوcookies
  إلى هذه الخدمات العامة من خوادمنا. يطبق الخادم rate limiting وحدود المنطقة.
- الإعدادان فارغان افتراضيًا؛ غيابهما يعرض عدم التهيئة ولا يفعل fallback.
  HTTPS لازم. الاختبارات المحلية فقط يمكنها تفعيل MAP_ALLOW_LOCAL_HTTP
  لعناوين localhost/127.0.0.1/10.0.2.2/::1؛ لا HTTP عام أو تساهل TLS.
- © OpenStreetMap contributors ظاهر في العارض. يلزم الخادم بيانات مصدر
  وتحديثات وترخيص صحيحة. لا تنزيل مسبق أو cache قرص دائم في هذا الإصدار؛
  HTTP tiles بلا اعتمادات التطبيق، والمزود لا يتبع redirect.

## GET /places — المورد المشترك

نفس عقد ride_request-v1؛ لا مزود بحث ثانٍ لكل شاشة. q بطول0..100codepoints،
limit=20 في منتقي الخريطة، وAccept-Language:ar|en. يعيد data:[Place]
وmeta.next_cursor؛ Place={id,label,label_en,latitude,longitude}.
يعرض المنتقي أول20 نتيجة؛ لا طلب تلقائي عند فتح الصفحة، ويجمع الكتابة
بمهلة300ms. البحث والعكس ينفذهما Laravel عبر خدمة الأسماء التي تستضيفها
بنيتنا. لا اتصال Nominatim عام أو SDK geocoding من الهاتف.

## GET /map/reverse

Query latitude وlongitude رقمان ضمن[-90,90] و[-180,180]؛ القيم غير المنتهية
مرفوضة. Accept-Language:ar|en.200:

```json
{"data":{"label":"المزة، شارع الجلاء","label_en":"Mezzeh, Al Jalaa Street","latitude":33.5,"longitude":36.25}}
```

label وlabel_en نصان غير فارغين بحد200codepoints. نقطة النتيجة تبعد200م
كحد أقصى عن الطلب؛ يحتفظ Flutter بنقطة الدبوس الأصلية ويستعمل النص فقط.
404 LOCATION_NOT_FOUND يسمح بإدخال وصف يدوي لنفس النقطة، دون الادعاء
بنجاح العكس. هذا الخيار متاح أيضًا عند تعطل الخدمة أو عدم تهيئتها.
422 VALIDATION_ERROR و429 RATE_LIMITED و503 SERVICE_UNAVAILABLE.

## POST /map/routes — معاينة جغرافية فقط

Content-Type:application/json، مورد عام محدود المعدل من خادمنا، بلا Bearer.
الطلب لا ينشئ رحلة ولا يستقبل سعرًا ولا يستخدم Idempotency-Key:

```json
{"origin":{"latitude":33.5,"longitude":36.25},"destination":{"latitude":33.519,"longitude":36.283}}
```

النقطتان مختلفتان وصالحتان.200:

```json
{"data":{"origin":{"latitude":33.5,"longitude":36.25},"destination":{"latitude":33.519,"longitude":36.283},"geometry":{"type":"LineString","coordinates":[[36.25,33.5],[36.27,33.51],[36.283,33.519]]},"distance_meters":5019,"duration_seconds":1080,"provider":"osrm"}}
```

origin/destination صدى النقطتين المطلوبتين بالأرقام نفسها؛ لا تبديل lat/lng.
geometry من الخادم فقط، GeoJSON LineString من2 إلى10000 نقطة؛ كل إحداثية
بالترتيب **longitude,latitude**. أول/آخر نقطة لا تبعد عن الانطلاق/الوجهة أكثر
من200م بسبب snapping للطريق. distance_meters وduration_seconds عددان صحيحان
موجبان؛ provider=osrm|google. لا تحويل لوحدات عائم أو encoded polyline غير معلن.

Laravel يستعمل RoutingService المتفق عليه: OSRM المستضاف أو Google Routes
من جهة الخادم. وحدة backend/laravel الحالية تعيد encodedPolyline؛ يلزم عند
دمج هذا endpoint تحويله بدقةpolyline5 إلى LineString أو طلبGeoJSON من OSRM
في adapter متوافق. Google وOSRM يرجعان نفس Schema أعلاه، بلا تغيير Flutter.

المسار هنا للعرض ولا يثبت السعر أو يحل محل quote. POST /ride-quotes وPOST
/trips يظلان صاحبي السعر والتوفر والتحقق والحجز. للمجدولة يحسب الخادم السعر
وفق موعدها؛ لا يعتمد سعرًا من الهاتف أو من مسار معاينة قديم.

تعرض خريطة الرحلة الطريق بين الانطلاق والوجهة وعلامة السائق منlive؛ لا
ملاحة دورًا بدور أو تحديث ETA من جهاز العميل. عند وصول موقع سائق قديم/فشل
المتابعة تُخفى العلامة القديمة. الحركة وحدها لا تعيد طلب المسار أو تحرك
الكاميرا قسرًا؛ تغير الطرفين أو retry يطلب معاينة جديدة. لا رسم خط مستقيم
بديل عند الفشل، ولا تخزين دائم للمسار أو ادعاء معرفته offline.

404 ROUTE_NOT_FOUND أو422 VALIDATION_ERROR أو429 RATE_LIMITED أو503
SERVICE_UNAVAILABLE؛ لا تحويل الفشل إلى مسار افتراضي.

## GET tiles/{z}/{x}/{y}.png — مضيف البلاطات

هذا عنوان استضافة صور، مستقل عن JSON base_url.200 Content-Type:image/png
وجسم PNG256×256؛ لا غلافdata. الصور الثنائية لا تدرج كـJSON في saved response؛
طلب Postman يوضح headers والمقاسات، ويقرأ الصورة الحقيقية عند تشغيل الخادم.
404 بلاطة غير موجودة،429 أو503. لا redirects، أوفاتورة دفع، أوعنوانGPS فيlogs.
حدود الاستضافة والتحديث واختبارات التغطية السورية مسؤولية الباكند/البنية.

## الأخطاء والموقع

أخطاء JSON بغلاف {error:{code,message:{ar,en}}}؛ لا نص خادم يعرض دون ترجمة.
GPS قراءة foreground واحدة عند ضغط المستخدم فقط، بمهلة15ثانية. رفض الإذن
أو إغلاق خدمة الموقع لا يمنع الاختيار اليدوي. لا صلاحية خلفية أو endpoint
لرفع موقع الراكب تلقائيًا أو GPS وهمي. label اليدوي200codepoints كحد أقصى.
يحمي العميل الاختيار الجديد من رد عكس/GPS قديم، ويمهل البحث ويهمل ردوده
بعد المغادرة؛ لا تظهر إحداثيات قديمة في جلسة أخرى.

## فحوص مطور الباكند قبل الربط

زودنا بعنوانَي HTTPS، وتأكد من التغطية والمقاس والمحاور وحقوق OSM، ونجاح
قواعد العكس وGeoJSON وحدود المنطقة والطريق غير الموجود، وعدم redirect
إلى مزود عام. اختبر rate limits وtimeouts، ولا تسجل النصوص/الإحداثيات
الشخصية في logs. تظل تجربة15/15 يوم السابقة معطلة حتى جاهزية المزودين
وتأكيد تفعيلها؛ العميل لا يختار routing provider بنفسه.
