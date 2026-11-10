# ADR0004 — عارض خرائط العميل

قرار التنفيذ2026-11-10 بعد اعتماد المستخدم تجهيز جهة Flutter فقط دون
خدمات عامة؛ الخدمات الخاصة غير جاهزة. يتمم ADR0003 ولا يغير مسؤولية السعر.

flutter_map يعرض raster XYZ256 من عنواننا الصريح؛ البيانات والستايل من
بنيتنا مع نسبة OSM. لا Google Maps SDK أو public tile endpoint أو fallback.
تصل خدمات البحث والعكس ومعاينة الطريق عبر Laravel بصيغة موحدة. يظل
اختيارOSRM/Google واستضافة البحث والبلاطات على الخادم، لا فيUI/Bloc.

Repository/codec/HTTP وGPS فيmaps/data؛ Domain بلا SDK. MapScope يحقن
اعتماديات التطبيق المنشأة فيget_it؛ widgets لا تصل للـlocator. الموقع
foreground وبطلب صريح. AppConfig يملك العناوين والتحقق منHTTPS.
المسار المعروض GeoJSON موثوق بصحة حقوله وحدود حجمه وسياقه، وليس سعرًا.
لا رسم توضيحي بديل أو أثر booking حقيقي بالمحاكاة.

اختيار raster حد حالي معلن؛ استضافة vector tiles تتطلب عارضًا وعقد styles
مختلفين ولا تُفعّل بعنوانMVT في إعدادPNG. إعداداتنا فارغة حتى يوفرها الخادم.

المراجع الأولية: https://docs.fleaflet.dev/layers/raster-tile-layer.md
وhttps://pub.dev/documentation/geolocator/latest/ .
