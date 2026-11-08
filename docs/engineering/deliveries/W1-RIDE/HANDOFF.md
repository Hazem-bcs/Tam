# W1-RIDE — تقرير تسليم الوكيل B

**الحالة:** READY_FOR_REVIEW — التنفيذ المحلي جاهز للمراجعة المستقلة، وليس اعتمادًا إنتاجيًا.
**التاريخ:** 2026-11-08.
**المستودع المقصود:** `Hazem-bcs/Tam`.
**مرجع الأساس:** `tam-w1-baseline-2026-11-07` = `e570439c2593af610ed30b309c15e5cda1027da4`.
**الفرع:** `codex/w1-ride-request`.
**checkout المستقل:** `/home/hazem/projects/tam-w1-ride-request`.
**كوميت التنفيذ:** `9d6013e3f07fc37260d40326e0757d358eee55c9`.
**كوميت التسليم النهائي:** الكوميت الذي يحتوي هذا التقرير، ويُذكر SHA الكامل في رسالة التسليم؛ للتحقق بعد الاستنساخ: `git rev-parse codex/w1-ride-request`. لا يمكن تضمين SHA الكوميت الحامل لهذا التقرير داخل محتواه دون تغيير الـSHA نفسه.

## القراءة والمراجع

- قُرئت تعليمات `AGENTS.md`، بطاقة `docs/engineering/tasks/W1-RIDE.md`، `agent-onboarding.md`، `agent-task-template.md`، `task-board.md`، `parallel-work.md`، `wave-one-contracts.md`، `mock-api-policy.md`، `api-handoff-template.md`، `design-reference-index.md`، وإرشادات التصميم/المعمارية والتنقل وتنظيم Dart.
- فُتحت فعليًا صورتا التصميم الأصليتان:
  - UI-10: `apps/customer/Tam Cusstomer UI/WhatsApp Image 2026-11-04 at 3.03.01 PM (2).jpeg`.
  - UI-11: `apps/customer/Tam Cusstomer UI/WhatsApp Image 2026-11-04 at 3.03.01 PM.jpeg`.
- بيئة التحقق: Flutter/Dart على جهاز المستخدم Ubuntu ROG عبر Desktop Commander. لم أستخدم جهازًا آخر للكتابة، ولم أشغّل محاكي Android لأن استخدامه منسّق مع بقية الوكلاء.

## التنفيذ والحدود

1. شاشة طلب الرحلة بالعربية والإنجليزية مع اختيار موقع الانطلاق والوجهة والبحث ضمن أماكن اصطناعية معروفة؛ رسم خريطة **توضيحية فقط** بلا GPS ولا طلب صلاحيات ولا SDK خرائط.
2. اختيار `standard` و`comfort` و`van` و`motorbike`، وتسعير محدد في الـmock مع وحدة `SYP/minorUnit=0`، والمراجعة وطريقة الدفع النقدي فقط.
3. استخدام `TripLocation / GeoPoint / Money / TripBookingInput / TripPrefill` المشتركة؛ توسعة `RideDraftBloc` الموجود لا إنشاء Draft آخر. إعادة الطلب تملأ الموقعين فقط ويُعاد التسعير.
4. `RideRequestRepository` في domain، `MockRideRequestRepository` في data/mock، وstub لوضع `api` يعيد `SERVICE_UNAVAILABLE` صراحة؛ مصدر الاختيار في entry/composition وليس في الواجهة.
5. تأكيد الرحلة يُنشئ `Trip` بواسطة **نفس** `MockTripStore` المحقون من `TamApp`، ويستدعي `navigation.openTrip(trip.id)` عند النجاح. لا يوجد مخزن ثانٍ أو شاشة تفاصيل بديلة.
6. حماية تأكيدين متزامنين، صلاحية quote محددة بـ90 ثانية في fixture، إعادة التسعير عند تغيير المواقع/الفئة، وفشل واضح وإعادة محاولة بنفس `Idempotency-Key` عند نتيجة تأكيد غير محسومة. اختبار مستقل يعالج retry حتى بعد انتهاء quote عندما سُجل الحجز أصلًا.
7. لا تغيير لـAuth أو routing أو الثيم المشترك أو خصائص الدفع الحقيقي أو التتبع والمطابقة والدردشة والجدولة.

الملفات المضافة/المعدلة محصورة في:
- `apps/customer/lib/features/ride_request/**` بما في ذلك جزآ الترجمة `l10n/app_ar.arb` و`app_en.arb`.
- `apps/customer/test/features/ride_request/**`.
- `docs/api/ride_request/**`.
- `docs/engineering/deliveries/W1-RIDE/**`.

الملفات `apps/customer/lib/l10n/app_*.arb` و`app_localizations*.dart` **مُعاد توليدها محليًا للفحص فقط**، ولم تُضم إلى كوميتات B. يجب أن يعيد المشرف توليدها ضمن دمج الدفعة؛ لا تستنسخ هذا التغيير يدويًا.

## التحقق المُنجز

من جذر المشروع:
- `python3 scripts/dev/sync_feature_l10n.py` → **PASS**: `Localization inputs are synchronized.`

من `apps/customer`:
- `flutter gen-l10n` → **PASS**.
- `dart format --output=none --set-exit-if-changed lib test` → **PASS**: `Formatted 86 files (0 changed)`.
- `flutter analyze --no-pub` → **PASS**: `No issues found!`.
- `flutter test --no-pub` → **PASS**: **155 اختبارات ناجحة**، تتضمن **20 اختبارًا لميزة ride_request** (المستودع، parsing، BLoC، widget).
- `git diff --cached --check` → **PASS** قبل كوميت التنفيذ؛ أُصلح فراغ Markdown في README أثناء التحقق.
- JSON في `docs/api/ride_request`: **13 ملف JSON صالحًا** بينها Postman v2.1؛ فُحصت بنية Collection وعدد ثلاث عمليات و15 saved response.
- استُخدمت fixtures parsing في اختبارات Dart لضمان عدم الاكتفاء بفحص JSON.
- ملفات Dart المكتوبة يدويًا ضمن هذه الميزة ≤300 سطر بعد فصل `ride_draft_state.dart` عن `ride_draft_bloc.dart`.

### صور اختبار Flutter الفعلية

- `ride-ar-390.png` — هاتف 390dp بالعربية، اختيار مكانين مع مسار توضيحي وفئات.
- `ride-ar-390-details.png` — هاتف 390dp بالعربية، تفاصيل السعر ومراجعة الدفع والتأكيد.
- `ride-en-390.png` — هاتف 390dp بالإنجليزية وprefill.
- `ride-ar-800.png` — تابلت 800dp بالعربية.
- `ride-en-320-scale2.png` — هاتف 320dp بالإنجليزية مع تكبير الخط 2x.

تمت مشاهدة صور العرض الناتجة من اختبار Flutter فعلًا، وتصحيح مشكلة الخط العربي المربع بواسطة خط نظام تجريبي **داخل اختبار Widget فقط**، دون إضافة خط إلى التطبيق أو المستودع. تم تعطيل شارة DEBUG من لقطات الاختبار. اختُبر فتح لوحة المفاتيح عبر Widget Test. **لم تُنفذ معاينة على محاكي Android أو جهاز فعلي**، لذلك تبقى معاينة الجهاز جزءًا من QA بعد التكامل.

## حزمة الباكند المقترحة

- `docs/api/ride_request/README.ar.md`: طريقة التنفيذ والاستيراد والمتطلبات.
- `docs/api/ride_request/ride_request-v1.md`: عقد مقترح **ليس API قائمًا**.
- `docs/api/ride_request/ride_request-v1.postman_collection.json`: Postman v2.1، أمثلة استجابات وأخطاء، متغير `quote_id` و`Idempotency-Key`.
- `docs/api/ride_request/examples/*.json`: أمثلة متوافقة مع Parser واختباراته.

المسارات المقترحة: `GET /places`، `POST /ride-quotes`، `POST /trips` فقط. الكائنات المشتركة `Trip` والمال والوقت وحالات الفشل موثّقة. **لم يتم استيراد المجموعة في واجهة Postman فعلية ولا إجراء اتصال HTTP حي**؛ JSON وبنيته والأمثلة هي ما جرى فحصه. `api` غير منفذ عمدًا.

## طلبات التكامل والقيود المتبقية

- مسؤول C يكمّل `GET /trips` وتفاصيل الرحلة في فرعه؛ في baseline يستطيع B الانتقال إلى المسار المشترك لكنه لا يصنع شاشة تفاصيل بديلة. تظهر الرحلة في `MockTripStore` فورًا ويقرأها C من المخزن نفسه عند التكامل.
- المشرف يدمج أجزاء ترجمة الميزات المتعددة ويشغل sync/gen-l10n ويُضم النواتج المشتركة بكوميت التكامل.
- تأكيد API الحقيقي يتطلب جلسة `authenticated` وباكند وصلاحيات فعلية؛ `guest/localAccess` لا يتحولان إلى Auth حقيقي. بيانات المحاكاة مؤقتة وليست حجزًا/سعرًا إنتاجيًا.
- ثبّت مع الباكند TTL لمفاتيح idempotency والعملة وسياسة الفئات والتغطية والأسعار وحالة الاستجابة المفقودة. مواصفات v1 مقترحة لا معتمدة.
- مراجعة مستقلة وQA لدمج الفرع مع C، والانسياب البصري على محاكي/جهاز حقيقي، قبل الجاهزية للإصدار.
- Git `origin` المحلي في `/home/hazem/projects/mashwar` ما يزال يشير إلى `Hazem-bcs/mashwar`، بينما رسالة التكليف تحدد `Hazem-bcs/Tam`. لتجنب تغيير remote مشترك بين worktrees، يتم رفع الفرع صراحة إلى مستودع `Hazem-bcs/Tam` فقط، دون مس `main` أو بدء Actions.

**التوصية:** READY_FOR_REVIEW عند إثبات رفع الفرع وSHA النهائي؛ لا يُعتمد الكود بالمراجعة الذاتية، ولا يُعد جاهزًا للإنتاج.
