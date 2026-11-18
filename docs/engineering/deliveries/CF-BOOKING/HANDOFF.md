# CF-BOOKING — تسليم تنفيذ للمراجعة

الدور: DEVELOPER. الأساس: `1b8890049177b56b3ce8e2c0254b622defa95bbf`.
الفرع: `codex/customer-feedback-booking-20261118`.
النسخة التنفيذية: الكوميت الذي يحتوي هذا التسليم؛ يرسل SHA الكامل للمشرف
بعد commit، وتُجمّد النسخة للمراجعة المستقلة. الحكم: READY_FOR_REVIEW،
وليس اعتمادًا ذاتيًا أو جاهزية إصدار للعميل.

## السلوك والملكية

- F05: `ActiveTripRepository.current()` يختار الرحلة الفورية/الموزعة فقط.
  وجود حجز الغد لا يستولي على مسار إنشاء طلب جديد. يبقى `fetch(id)` قادرًا
  على متابعة أي حجز بعينه. لا تغيير في حدود مهلة الجدولة: 30 دقيقة إلى7 أيام.
- عقد Domain صغير مستقل `UpcomingTripsRepository` يعرض المجدولة فقط،
  بالموعد ثم المعرف، من مصدر الرحلات نفسه؛ لا نسخة بيانات مستقلة في الواجهة.
  تطبيق API غير المنفذ يفشل صراحة. المحاكاة لا تطبق سياسة تصادم خادم مخترعة.
- حقل اختياري جديد `upcomingTrips` في `buildHomeFeature` يركب Cubit وبطاقات
  الرئيسية. لكل حجز مساره ومعرفه؛ الإلغاء يحذف ذلك المعرف فقط من القائمة.
  إعادة التشغيل تستعيد الحجوزات مع الرحلة الفورية من snapshot الموجود،
  والخروج وتبديل المالك يعزلان البيانات. حُفظت هذه الآلية ولم تُنشأ طبقة حفظ ثانية.
- Cubit القادمة يستمع للتحديثات، يمنع نتيجة async القديمة من استبدال الأحدث،
  يغلق الاشتراك، ويعرض فشل التحديث مع البيانات القديمة موضحة وإجراء إعادة محاولة.
  مفاتيح تركيب provider تشمل المستودع وحالة Auth والرقم لعزل هوية العرض.
- F04: مسافة ابتدائية ونهائية اتجاهية لقائمة المركبات، مع تلميح وأسهم وصول
  ظاهرة أيضًا في النسخة المضغوطة. يمكن الوصول لكل الفئات دون السحب فقط.
  انتقال الصفحة أصبح تلاشيًا خفيفًا؛ اللوحات تملك حركتها، والخريطة لا تتحرك
  مكانيًا مع حركة دخول الصفحة. تقليل الحركة ما زال يلغي الانتقال.
- F02 الخاص بالحجز: فتح لوحة المفاتيح يكشف محتوى اللوحة المطوية ويستخدم
  ارتفاعًا ملائمًا ضمن المساحة المتاحة؛ لا يغيّر حجم الخريطة أو inset الكاميرا
  المجمد أثناء الكيبورد. إجراء التأكيد يمرر مع المحتوى في الشاشة القصيرة أو
  الكيبورد أو الخط الكبير. اختبار منفصل يثبت وصول الحقل والإجراء في هذه الحالات.
- F08 الخاص بالبحث: مكبرة ودوائر هادئة بثيم التطبيق، بدورة واحدة محدودة
  داخل RepaintBoundary، وتتوقف عند تقليل الحركة. عنصر الرسم لا يكرر semantics
  نص البحث الموجود ولا يتدخل في الإلغاء أو الفشل أو تدفق الحالات.
- أشرطة الحالة في Home وصفحة الحجز تتبع سطوع الثيم/لون الخلفية تمهيدًا
  للثيم الداكن الذي ينفذه المشرف. لا قيم palette داخل الميزة.

الملفات الجديدة للواجهة/الحالة أقل من300 سطر. صفحة الحجز القديمة (425 سطرًا)
تغيرت فقط في شريط الحالة، وshell بقي303 سطور لأن دورة الارتفاع/الكيبورد/
السحب مترابطة؛ لم تُنشأ تجزئة شكلية أو إعادة هيكلة خارج المهمة.

## العقد والمحاكاة

وضع البيانات الافتراضي ما زال mock؛ لا HTTP أو اعتماد backend أو حجز/دفع
حقيقي. Auth والضيف وlocalAccess وTEMPORARY_PHONE_ENTRY محفوظة.
حدّثت حزمة `docs/api/scheduling/` v1 بإضافة موثقة بتاريخ2026-11-18:
`GET /trips?filter=scheduled&sort=scheduled_at_asc&limit=20` مع cursor،
وترتيب الموعد ثم id، ونتيجة الفراغ، والإلغاء المحدد، وعزل الحساب.
يجب على تطبيق Data API المستقبلي تجميع الصفحات. تحديث الحالية يستثني scheduled؛
سياسة التوفر والتعارض الإنتاجية يحددها الخادم قبل الربط.

أضيف `examples/trips-upcoming.json` و`trips-upcoming-after-cancel.json`،
وطلب06 وSaved responses في Postman v2.1، واختبار تطابق فعلي مع المحاكاة
بما فيه live metadata. حدّثت قسم current فقط في عقد active_trip بإذن المشرف.
لم أستورد واجهة Postman أو أستدع خادمًا؛ تحقق JSON واختبارات العقد محليان.

## التحقق المنفذ

البيئة: Linux، Flutter/Dart المحليان في `/home/hazem/development/flutter`.
`flutter pub get --offline` جهز worktree دون تغيير lock أو إضافة dependency.
`sync_feature_l10n.py` ثم `flutter gen-l10n` من apps/customer نجحا للتجربة؛
تُستبعد الترجمة المشتركة المولدة من الكوميت، ويولدها المشرف عند الدمج.

من `apps/customer` شغلت دفعات مركزة، وكل آخر نتيجة للمسارات التالية ناجحة:

```bash
flutter test --no-pub test/features/home/home_upcoming_trips_cubit_test.dart test/features/active_trip/active_trip_repository_test.dart test/shared/mock_trip_snapshot_test.dart test/features/ride_request/scheduling/scheduling_contract_test.dart
flutter test --no-pub --dart-define=CAPTURE_BOOKING_FEEDBACK=true test/features/home/booking_feedback_layout_test.dart test/features/ride_request/presentation/widgets/ride_keyboard_panel_test.dart test/features/ride_request/scheduling/scheduling_contract_test.dart
flutter test --no-pub test/features/ride_request/presentation/widgets/ride_live_continuity_test.dart test/features/ride_request/presentation/widgets/ride_vehicle_fare_test.dart
flutter test --no-pub --dart-define=CAPTURE_BOOKING_FEEDBACK=true test/features/home/booking_feedback_layout_test.dart test/features/active_trip/active_trip_repository_test.dart
```

الدفعة الأخيرة:19 اختبارًا، والسابقة الخاصة بالاستمرارية/التسعير:12،
ودفعة الكيبورد/المخطط/العقد:11. تشمل الاختبارات: استعادة حجزين وفوري ثم إلغاء
واحد وإعادة التشغيل وتبديل المستخدم؛ فشل القراءة والكتابة؛ ترتيب القادمة؛
إخفاق الشبكة وإعادة المحاولة؛ النتائج المتأخرة؛ API الصريح؛ المطابقة مع JSON؛
وهوية Map State عبر جميع مراحل الرحلة، ومركبات RTL/LTR والخط الكبير.
الدفعات متداخلة؛ هذه أعداد دفعات وليست ادعاء فحص كامل للمستودع.

فحص format على21 ملف Dart مملوكًا:0 تغييرات. `git diff --check` وقراءة كل
JSON تحت scheduling ناجحان. أُجري تحليل مركز على كل المسارات المتغيرة؛
تعالجت ملاحظات ترتيب imports والأقواس قبل التسليم. التحليل النهائي لـ15 مسارًا انتهى: No issues found (5.3s)،
ويُكرر SHA والنتيجة في رسالة المشرف.

أثناء إعداد اختبار preview احتاج تنظيف stream إلى `tester.runAsync`؛ أُوقفت
دفعة معلقة ثم صُحح التنظيف ونجحت إعادة التشغيل. هذا عيب harness مصحح،
ولا يُعد تشغيل الدفعة المقطوعة نجاحًا. أصلحت أيضًا تطابق live metadata في
fixtures قبل نجاح اختبار العقد؛ لم أحذف أي اختبار لتجاوز إخفاق.

## المراجعة البصرية وحدودها

قُرئت المراجع الثلاثة الأصلية. فُحصت PNGs فعلية من Flutter widget renderer
في هذا المجلد، بحالة تقليل الحركة: ar320×740 بخط2x، en390×844 بخط1x،
ar800×1000 بخط1x، en844×390 بخط2x. ملفات `upcoming-*` تعرض بداية القائمة،
و`feedback-*` تعرض المركبات/مكبرة البحث بعد التمرير. استخدم harness نفس خطوط
Noto المحلية بصيغة preview؛ هي معاينة مكونات وليست صورة صفحة Home المتكاملة.
العربية الكبيرة تلتف وتمتد البطاقات وتمريرها؛ لا قص أو overflow في الاختبارات.
اتجاه عناوين المواقع معزول Unicode داخل النص المترجم لحماية المزج العربي/الإنجليزي.

اختبار الكيبورد يستخدم insets محاكاة220dp في320×740 و844×390 و800×1000
وخط2x. ليس كيبورد Android مرسومًا. لا تشغيل محاكي أو APK أو قياس profile أو
اعتماد 60fps أو مراجعة حركة بشرية فعلية أو ثيم داكن متكامل في هذا worktree.
هذه تحتاج milestone التكامل الذي يديره المشرف. لم يُشغل full suite أو build.

## تغييرات التكامل المطلوبة من المشرف

1. تمرير `upcomingTrips` إلى buildHomeFeature في app_router عبر
   `activeTrips is UpcomingTripsRepository ? activeTrips as UpcomingTripsRepository : null`
   واستيراد domain interface الجديد. Home لا يحل الخدمات من locator.
2. توليد الترجمات المشتركة من fragments Home فقط عند جمع الفروع.
3. تعديل تطبيع/قبول الكوبون العربي داخل RideDraftBloc وMockRideRequestRepository
   مع helper المشرف؛ لم ألمسهما أو ملف pricing أو حقلي coupon المملوكين له.
4. راجع Saved responses الخاصة بـcurrent في حزمة active_trip، واحذف مثال
   scheduled إن كان مسجلاً تحت current أو انقله للتفاصيل. القسم النصي معدّل.
5. حافظ على نوع subtree الخريطة في الحجز قبل/بعد التأكيد؛ لا تستبدل
   RideJourneyBackdrop بشرط يبني ActiveJourneyMap فقط عند active!=null،
   لأن ذلك يفقد FlutterMap State. cache geometry يمكن تمريره دون تغيير النوع.
6. مراجعة مستقلة على SHA النهائي ثم الفحوص الشاملة والمراجعة الفعلية للأجهزة،
   واللغة والخط والكيبورد والثيم الداكن وأداء وحجم APK في فرع التكامل.

لا push أو main أو Actions أو تشغيل Emulator في هذا التسليم.
