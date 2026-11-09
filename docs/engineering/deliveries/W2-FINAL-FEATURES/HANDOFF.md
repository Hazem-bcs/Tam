# مرشح التقييم والدعم والتكامل — 2026-11-09

الحالة **REVIEW — تنفيذ وفحص محلي مكتمل، المراجعة المستقلة معلقة**.
مرشح الكود والاختبارات والعقود والصور المجمد:
`7c040f7d9954033530d724237d382780b563bbea`.
الفرع codex/w2-final-features-integration، checkout
/home/hazem/projects/mashwar، الأساس bd24d5993ba8ffe14f2b41d06ba9b3106cf5cdec.

## ما اكتمل

- Completion: ملخص المكتمل، تقييم واحد1..5، تعليق اختياري≤500codepoints،
  حفظ/قراءة/عدم يقين/retry آمن، جلسة معزولة، عقدv1 وPostman.
- Support: طلب عام أو مرتبط برحلة، catalog، قائمة cursor وتفاصيل وإنشاء،
  نص10..2000codepoints، معرف ثابت وimmutable snapshots، عقدv1 وPostman.
- Legal: terms/privacy للقراءة العامة، المحتوى غير منشور؛ لا نص مخترع.
- ربط AppConfig والمستودعات وget_it والتنقل والحراسة والجلسة وARB، ومداخل
  ActiveTrip/Trips/Settings، واختبارات رحلة عابرة للميزات وحراسة API.
- إصلاح قص helper عند تكبير النص فيTamTextField، وجعل حقل المحادثة وعداده
  قابلين للتمرير ضمن المساحة المتاحة فوق الكيبورد؛ منع paint assertion عند
  320dp/2x. فُحصت المحادثة17 اختبارًا ورسومها؛ لا تغييرDomain/Dataللمحادثة.

توقف implement_completion وimplement_support برسالة usage limit من المزوّد.
حفظ المشرف عملهما في ed78e5e وa2b71da وجمعه ثم أكمل النواقص بنفسه.
توليدl10n المؤقت فيworktreesالمطورين محفوظ ولم يُدمج؛ التوليد النهائي موحد.
لا يُحسب فحص المشرف مراجعة مستقلة. لم تُستخدم أداة بديلة أو وكيل بديل
للتجاوز، ولم يُفترض اعتماد لمراجعة لم تحدث.

## التحقق الفعلي

من apps/customer:

```bash
dart format --output=none --set-exit-if-changed lib test
flutter analyze --no-pub
flutter test --no-pub --reporter expanded
```

النتيجة:307 ملفات/0 تغيير، analyze بلا ملاحظات، **569 اختبارًا ناجحًا**.
سجلات الجلسة المحلية /tmp/tam-final-features-analyze.log و
/tmp/tam-final-features-all-tests.log. زيادة101 اختبار على الأساس468؛ ليست
هذه نسبة اكتمال ولا دليل جاهزية إصدار. كود المرشح مطابق للكود المفحوص؛
آخر تغيير بعد كامل الاختبارات كان اختيار مجلد صور test helper فقط، وفُحص
التنسيق والتحليل ومقارنات الصور بعده أيضًا.

المقارنة النهائية **76 اختبار UI ناجحًا دون --update-goldens**:

```bash
flutter test --no-pub \
  --dart-define=CAPTURE_COMPLETION_UI=true \
  --dart-define=CAPTURE_SUPPORT_UI=true \
  --dart-define=CAPTURE_ACTIVE_TRIP_UI=true \
  --dart-define=CAPTURE_SETTINGS_GOLDENS=true \
  --dart-define=CAPTURE_TRIP_COMPLETION_UI=true \
  --dart-define=CAPTURE_CHAT_UI=true \
  --dart-define=CHAT_UI_DELIVERY=W2-FINAL-FEATURES \
  test/features/completion/completion_layout_test.dart \
  test/features/completion/completion_widget_test.dart \
  test/features/support/support_widget_test.dart \
  test/features/active_trip/active_trip_widget_test.dart \
  test/features/settings/settings_page_test.dart \
  test/features/trips/trip_completion_layout_test.dart \
  test/features/chat/chat_widget_test.dart --reporter expanded
```

السجل /tmp/tam-final-features-golden-verify.log. التوليد الأولي استخدم
--update-goldens، ثم فُتحت الصور وراجعها المشرف وأعيدت المقارنة دون تحديث.
31 صورة للتقييم و32 للدعم و23 للمحادثة الحالية في screenshots هنا؛ صور
المحادثة التاريخية في W2-CHAT لم تُعدّل. صور التقييم والدعم في مجلدي
تسليم الميزتين؛ ActiveTrip وSettings goldens الحالية تحت test.
فُتحت الصور عبر view_image، مع contact sheets لكل المجموعات؛ المقاسات
320/390/800 وlandscape، العربية والإنجليزية، خط1x/2x والكيبورد المحاكى.
الرسم من Flutter widget renderer وخطوط Noto/Material المحلية؛ لا Android
أو محاكي ولا قياس لوحة مفاتيح جهاز حقيقية.

من الجذر:

```bash
python3 scripts/dev/sync_feature_l10n.py --check
git diff --check
```

نجحا؛ flutter gen-l10n نُفذ بعد دمج fragments. فُحصت34 JSON في حزمتي API
وبنية Postman2.1، واختبارات العقود تقارن الأمثلة بالمحاكاة والـdecoders
والـsaved responses. لم يُنفذ استيراد فعلي في Postman أو طلب حي. لا ملفات
Dart مكتوبة في Completion/Support فوق300 سطر. لا تغيير في الحزم أو
المنصات أو لوحة الألوان المركزية.

## المراجعة والوجهة والحدود

يلزم مراجع مستقل لهذا SHA وكامل diff من الأساس، يشمل الكود والعقود
وأمثلتها والتكامل المشترك وChatComposer والصور.
[بطاقة المراجعة](../../tasks/W2-FINAL-REVIEW.md).
حالة الميزتين REVIEW دون APPROVED_AT_SHA. ما زال feat/auth-contract عند
bd24d5993ba8ffe14f2b41d06ba9b3106cf5cdec؛ لم يجر الدمج النهائي إليه.
main عند20966b1eaae44623ae58bcefd6836085e308d608، وآخر remote متزامن مسجل
origin/feat/auth-contract عندa5c8dee732811798eda5abdf061a1bda0c728cc3.
لا push/main/Actions أو Android build، ولا backend حي. API غير الجاهز لا
يعود إلى mock.

المراجعة المستقلة ثم إصلاح ملاحظاتها وفحص التكامل هي المتبقية لاعتماد
تدفقات المرحلة الأولى المتفق عليها. التحسين البصري النهائي مرحلة ثانية،
خصوصًا المطابقة مع UI-03/UI-08 والمراجع الأخرى والخطوط والمسافات والأصول.
تفاصيل التقييم وداخل الدعم لا مرجع كامل معتمد لهما؛ لا ندعي المطابقة
النهائية. النص القانوني المعتمد وربط الباكند ينتظران تسليمهما؛ المحفظة
والدفع والكوبونات والخدمات الأخرى ليست ضمن هذا التسليم أو النطاق المتفق عليه.
