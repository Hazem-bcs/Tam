# W3-CUSTOMER-REVIEW — مراجعة منطق العميل وحزمة الباكند

التاريخ: 2026-11-09. الدور: REVIEWER مستقل؛ لم أنفذ تغييرات W2 Completion/Support
أو W3 الحساب/الاتصال والتجميع. الحكم النهائي: **APPROVED_AT_SHA
`511ca9ce2ed24484602c78db283d5ef1fc66eb25`** للمرحلة الأولى ولمقترح تسليم الباكند.
لا توجد ملاحظة مانعة متبقية ضمن النطاق. كوميت هذا التقرير لاحق وتوثيقي فقط.

## النسخة والملكية والمدخلات

- الأساس: `bd24d5993ba8ffe14f2b41d06ba9b3106cf5cdec`.
- مدخل المراجعة النظيف: `882c9e55ca17bc651f238d0b98abbabe14d877fb`.
- الفرع: `codex/review-customer-api`.
- مكان العمل الوحيد: `/home/hazem/.codex/worktrees/review-customer-api/mashwar`.
- إصلاحات المراجعة: `c55edfc56439b3d8e00f2124bb3b7563b804f291`.
- وصف مقترح التسليم وتوليده: `511ca9ce2ed24484602c78db283d5ef1fc66eb25`.

راجعت كامل نطاق التغيير من الأساس، وليس W3 وحدها أو ملخص المشرف. شمل ذلك
Completion/Support/Legal، الحساب والاتصال، Domain/Data/Mock/mappers/Cubits/UI،
التوجيه وDI والإعدادات والجلسة ومداخل Settings/ActiveTrip/Trips، وتعديل
TamTextField/ChatComposer، والعقود والأمثلة ومصادر Postman والمجمع واختباراته.
قرأت AGENTS والبروتوكول وخطة التوازي والمرحلتين والاتفاق وADR والثيم والتنقل
وسياسة المحاكاة ومتطلبات API، وبطاقات وتسليمات W2/W3 ذات الصلة.

بطاقة W3-CUSTOMER-REVIEW وتسليم W3 المتأخران توثيقيًا قُرئا فقط من المسارين
المحددين تحت `/home/hazem/projects/mashwar/docs/engineering/`؛ لم أعدلهما.
لم أستخدم worktree القديمة أو أكتب في checkout المشرف أو اللوحة أو التقدم.
الأدوات الفعلية: Git وFlutter/Dart وPython وjsonschema وعرض الصور. لا خادم
حي أو SMS أو اختبار جهاز. لم أستخدم محاكيًا أو Android build أو Actions أو push/main.

## العيوب المثبتة والمصححة

**P2 — رمز OTP سابق يعود صالحًا بعد resend.** كان
`account_management/data/mock/mock_account_management_repository.dart` يختار
الرمز بحسب parity للـrevision، بينما تزيد المحاولات الخاطئة revision أيضًا.
بعد1 أو3 أخطاء كان resend يعيد123456 ويمكنه تأكيد الحذف. أُثبت ذلك باختبارين
فاشلين على المدخل الأصلي. صار تسلسل الرمز مستقلًا لكل challenge:123456 أولًا،
ثم654321 و654322 وما بعدها، دون إعادة رمز سابق؛ تُرفض نهاية فضاء fixture بدل
الالتفاف. أضيف اختبار ثالث لثلاث resends يرفض كل الرموز السابقة ويقبل أحدثها.
بقي request_id ثابتًا في retry ولا يرسل التكرار رمزًا جديدًا. حُدث وصف المحاكاة
في عقد الحساب وأعيد توليد الحزمة؛ لا تغيير لرمز OTP الدخول أو Auth API.

**P2 — نتيجة اتصال قديمة تُفتح بعد فقد أهلية الرحلة أو تغير السائق.** مع
MockTripStore الحقيقي، يبدأ call ثم تُلغى الرحلة قبل continuation، ومع ذلك
كان dialer يُفتح. أُثبت الفشل قبل الإصلاح. صار DriverContactRepository يصدر
DriverContactChange لإبطال هوية/أهلية رحلة مرصودة من المصدر المشترك؛ يرفع Cubit
epoch ويهمل الرد القديم. تغطي الاختبارات الإلغاء وتبديل السائق، وتثبت أن تقدم
الرحلة مع السائق نفسه وتحديثاته العادية لا يبطلان اتصالًا صالحًا. تُحرر subscription
عند dispose؛ لا مصدر رحلات موازٍ أو رقم إضافي في history.

**P2 — فتح متأخر من صفحة اتصال غطاها مسار آخر.** حراسة lifecycle وحدها لا
تلتقط تغطية الصفحة داخل التطبيق. أثبت اختبار widget أن الرد المتأخر كان يفتح
dialer بينما الصفحة ليست current. صار الاستدعاء يفحص ظهور الصفحة قبيل تسليم
URI؛ يلغي النتيجة ويحرر busy عند تغطيتها. يثبت الاختبار أيضًا أن العودة وضغطًا
جديدًا يسمحان بطلب جديد. حُدث عقد الاتصال وحدود المعرفة في العميل: التغيير
المعروف يبطل الطلب، ولا ندعي معرفة بتغيير خادمي لم يصل أو إلغاء URI سُلّم للنظام.

اختبارات الارتداد الجديدة سبعة في:
`test/features/account_management/account_resend_regression_test.dart` و
`test/features/driver_contact/driver_contact_race_test.dart`. نتائج ما قبل الإصلاح
محفوظة مؤقتًا في `/tmp/w3-review-otp-before.log` و`/tmp/w3-review-contact-before.log`؛
نتيجة الحالات السبع بعد الإصلاح في `/tmp/w3-review-final-regressions.log`.

## نتيجة مراجعة الميزات والتكامل

- Completion يشترط completed ويقرأ Trip المشترك بما فيه التاريخ القديم بلا
  سائق. مبلغ الطلب ليس إيصال دفع. تقييم واحد immutable بحد1..5 وتعليق500
  codepoints، ومفتاح ثابت عند عدم اليقين؛ تحقق الإقرار والهوية والنسخ يمنع
  رجوع قراءة متأخرة عن تقييم مقبول. لا تحويل لحالة الرحلة من الراكب.
- Support يتحقق من سياق الرحلة وcatalog، وحد10..2000codepoints، والهوية الثابتة
  للطلب وإعادة المحاولة. snapshots تبقي حقول الإنشاء ثابتة وتقبل تحديث الحالة
  بإصدار أحدث؛ cursor مربوط بالجلسة والترتيب. المحتوى القانوني الافتراضي null
  وغير منشور، بلا نص قانوني أو SLA أو وسيلة اتصال مختلقة.
- الحساب يثبت الغرض والهدف والعملية، ويفرض cooldown/expiry والمحاولات والقفل
  عبر challenges الجديدة، ويعيد فحص الرحلات عند التأكيد. unknown result يقفل
  النية والرمز حتى receipt أو retry نفسه. القبول ينهي الجلسة؛ لا AuthUser/token
  مختلق ولا ترقية guest/localAccess. عمليات إعادة الجلسة والردود المتأخرة محروسة.
- عقد recovery grant واضح: أول أثر يتطلب Bearer وOTP صالحين، وX-Operation-Token
  لا يبدأ تعديلًا. بعد إبطال الجلسة يتيح نتيجة العملية نفسها فقط، لا ملف الحساب
  أو رقم الهاتف أو موردًا آخر؛ يخزنه adapter المستقبلي خصوصيًا في data. هذه
  قواعد مقترحة للخادم، وليست ادعاء تنفيذ أو اختبار تحقق خادمي حي في mock.
- الاتصال لا يقبل إلا E164 ويبني tel محليًا دون URL حر أو CALL_PHONE. adapter
  المنصة مختبر عبر launch seam؛ المحاكاة تستخدم MockPhoneDialer ولا تمرر fixture
  للنظام. تغيّر الجلسة والخلفية والإغلاق والظهور وهوية الرحلة محروس قبل الفتح.
- Domain خالٍ من SDK/Flutter/transport؛ platform SDK في data، والاختيار في
  AppConfig/composition وget_it. API غير المجهز يفشل دون fallback. المستودعات
  مملوكة للتطبيق وتصفّر البيانات عند الخروج. لم تتغير ملفات Auth وعقده عن الأساس.

اختبارات التطبيق تعبر من Settings إلى الحساب والإنهاء وإعادة الدخول المحلي،
ومن الحجز والتعيين إلى اتصال محاكى، ومن اكتمال الرحلة إلى التقييم والدعم،
وتراجع legal العامة وحراسة API للضيف وlocalAccess. لا اعتماد ذاتي للمشرف؛
أعدت الفحوص بنفسي داخل فرع المراجعة بعد قراءة التنفيذ والعقود.

## حزمة الباكند والـschema

المجمع حتمي من14 مصدرًا إلى14 مجلدًا و58 مثال طلب، لا58 endpoint مستقلًا.
فُحصت scopes للمتغيرات والتفويض وsaved requests/responses وعدم تكرار Auth.
Trip/Hold/الحجز والجدولة والإلغاء مصدر واحد؛ توضيحات الامتدادات الحالية تحدث
قيود W1 القديمة. 401 للميزات موحد UNAUTHENTICATED مع إبقاء أكواد Auth الأصلية.
المحفظة والدفع الإلكتروني والكوبونات خارج النطاق صراحة.

بعد اجتياز المراجعة والفحوص، تحولت الحزمة من REVIEW_REQUIRED إلى
**BACKEND_HANDOFF_PROPOSAL** في builder وmanifest وREADME والعقد الموحد، ثم
أعيد توليد Collection وفحصها. يعني ذلك مقترح تنفيذ صالح لتسليم مطور الباكند
ومراجعته؛ لا قبولًا من الباكند أو خادمًا منفذًا أو جاهزية نشر.

أعدت محليًا `Draft4Validator.check_schema` و`iter_errors` على الحزمة النهائية:
**0 أخطاء**. الـschema التي وفرها المشرف مجمعة من24 ملفًا رسميًا في
[postmanlabs/schemas عند c5fa20c6210207d09b06a23d700f9228c31ad703](https://github.com/postmanlabs/schemas/tree/c5fa20c6210207d09b06a23d700f9228c31ad703/schemas/draft-04/v2.1.0)،
مع id الرسمي لكل definition وإزالة JSON comments فقط، في
`/tmp/tam-postman-v2.1.0-schema.json`. المضيفان الرسميان للـschema أعادا403
للمشرف؛ استُخدم مصدر GitHub الرسمي. لم أجر استيراد Postman UI أو رفعًا لحساب
أو طلب HTTP حي. صحة schema وتطابق fixtures لا تثبت تنفيذ خادم Laravel.

## التحقق الفعلي

البيئة Linux محلية، Flutter3.41.4/Dart3.11.1. أوامر Flutter من `apps/customer`؛
أوامر Python وGit من الجذر. نجح `flutter pub get` في worktree الجديدة دون تغيير lock.

| الفحص | النتيجة |
| --- | --- |
| `dart format --output=none --set-exit-if-changed lib test` |336 ملفًا،0 تغيير |
| `flutter analyze --no-pub` |بلا ملاحظات |
| `flutter test --no-pub --reporter expanded` |625 PASS بعد الإصلاح؛618 PASS على input |
| حالات الارتداد المحددة |7 PASS |
| المقارنة النهائية UI بالأعلام والملفات أدناه |92 PASS دون update-goldens |
| `python3 scripts/api/build_customer_postman.py --check` |متزامن،14 مجلدًا/58 مثالًا |
| `python3 -m unittest discover -s scripts/api/tests -v` |6 PASS بعد التوليد النهائي |
| `python3 scripts/dev/sync_feature_l10n.py --check` و`flutter gen-l10n` |نجاح، المولدات بلا تغيير |
| JSON لكل `docs/api/**/*.json` |218 ملفًا صالحًا |
| Postman v2.1.0 الرسمي محليًا |0 أخطاء |
| `git diff --check` |سليم |
| مقارنة الصور وl10n وpubspec.lock بـinput |لم تتغير |

أمر المقارنة النهائي الفعلي:

```bash
flutter test --no-pub \
  --dart-define=CAPTURE_ACCOUNT_CONTACT_UI=true \
  --dart-define=CAPTURE_COMPLETION_UI=true \
  --dart-define=CAPTURE_SUPPORT_UI=true \
  --dart-define=CAPTURE_ACTIVE_TRIP_UI=true \
  --dart-define=CAPTURE_SETTINGS_GOLDENS=true \
  --dart-define=CAPTURE_TRIP_COMPLETION_UI=true \
  --dart-define=CAPTURE_CHAT_UI=true \
  --dart-define=CHAT_UI_DELIVERY=W2-FINAL-FEATURES \
  test/features/account_management/account_layout_test.dart \
  test/features/completion/completion_layout_test.dart \
  test/features/completion/completion_widget_test.dart \
  test/features/support/support_widget_test.dart \
  test/features/active_trip/active_trip_widget_test.dart \
  test/features/settings/settings_page_test.dart \
  test/features/trips/trip_completion_layout_test.dart \
  test/features/chat/chat_widget_test.dart --reporter expanded
```

السجلات: `/tmp/w3-review-input-tests.log`، `/tmp/w3-review-fixed-full-tests.log`،
`/tmp/w3-review-ui-comparison.log` و`/tmp/w3-review-final-ui-comparison.log`.
بعد فحص Flutter الكامل لم يتغير Dart؛ آخر تغيير وصف حالة الحزمة وbuilder،
وأعيدت فحوص Python/schema/JSON والتوليد عليه قبل تثبيت SHA الاعتماد.

## الفحص البصري والقيود

فتحت UI-03 وUI-08 الأصليين فعليًا من `apps/customer/Tam Cusstomer UI/`:
`WhatsApp Image 2026-11-04 at 3.02.59 PM (1).jpeg` و
`WhatsApp Image 2026-11-04 at 3.03.00 PM.jpeg`. لا مرجع تفصيلي أصلي للحساب
أو الاتصال أو نموذج التقييم أو داخل الدعم؛ لا ادعاء مطابقة مرجع غير موجود.

فتحت148 صورة حالية فعليًا ضمن28 contact sheet، وليست صورًا تاريخية بديلة:

| المسار | الصور |
| --- | --- |
| `docs/engineering/deliveries/W3-ACCOUNT-CONTACT/screenshots/` |40 |
| `docs/engineering/deliveries/W2-COMPLETION/screenshots/` |31، تشمل Trips |
| `docs/engineering/deliveries/W2-SUPPORT/screenshots/` |32 |
| `docs/engineering/deliveries/W2-FINAL-FEATURES/screenshots/` |23 للمحادثة الحالية |
| `apps/customer/test/features/active_trip/goldens/` |19 |
| `apps/customer/test/features/settings/goldens/` |3 |

شملت العربية RTL والإنجليزية LTR والهاتف320/390 والتابلت800 وlandscape،
وخط1x/2x وkeyboard insets وحالات التحميل والفراغ والفشل وعدم اليقين والنجاح
والجلسة والقراءة فقط. فُحصت قابلية الوصول للأفعال بالتمرير عند الضيق، ونمو
النصوص والحقول، وثيم التطبيق ومؤشرات الحالات النصية. لا overflow منسوب
للتغيير باقٍ في الفحوص، ولا عائق مرحلة أولى ظاهر في الرسوم المراجعة.

الدليل Flutter widget renderer بخطوط preview/Noto المحلية وMaterialIcons؛
لا Android/iOS أو IME أو screen reader على جهاز. الصقل الدقيق للأصول والخطوط
والمسافات والأنميشن والتوزيع البصري مرحلة ثانية، وليس اعتمادًا بصريًا نهائيًا.
API/SMS/الخدمات والخرائط وPush والاتصال الحقيقي تحتاج مرحلة الربط واختبارها.
المسودات والعمليات غير المحسومة لعمر الصفحة، دون outbox دائم؛ النص القانوني
المعتمد لم يُنشر، ولا سياسة احتفاظ قانونية مخترعة. لا تعني نتيجة المحاكاة
حذف حساب أو تغيير رقم أو دفعًا أو مكالمة فعلية.
