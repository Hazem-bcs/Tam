# W2-CHAT — تسليم المنفذ

التاريخ: 2026-11-09. الدور: DEVELOPER. الفرع: `codex/w2-chat`.
مكان العمل: `/home/hazem/.codex/worktrees/review-w2-addresses/mashwar`.

- الأساس الوظيفي: `a1199ef952f2f0f94c6088ff32d0609e0ec2b555`.
- مدخل البطاقة النظيف: `4dde1e485fccdadc2c51c83e016fe3ff37797270`.
- كود التسليم واختباراته وعقده وصوره: `8bf7964ef13e653399ada51c9e81f310aa090c88`.
- الكوميت اللاحق الذي يحمل هذا التقرير توثيق فقط. checkpoint الأول `53111e72eccdbeb12ee5efbfa5131a55b08d0d4e` ليس اعتمادًا.
- المراجعة المستقلة لم تبدأ عند التسليم؛ يطلبها المشرف على SHA المجموع مع ربطه.

## السياق والملكية

قرأ المنفذ AGENTS والبروتوكول وخطة التوازي والبطاقة ومراجع الاتفاق والمعمارية والثيم والتنقل وسياسة Mock/API وخطة المرحلتين وتسليم الباكند. فُتح UI-13 الأصلي فعليًا: `apps/customer/Tam Cusstomer UI/WhatsApp Image 2026-11-04 at 3.03.02 PM.jpeg`.

التغيير محفوظ فقط داخل `apps/customer/lib/features/chat/**` و`apps/customer/test/features/chat/**` و`docs/api/chat/**` وهذا التسليم وصوره. لا تعديل محفوظ في Auth أو router/config/DI/theme/shared/ActiveTrip أو اللوحة. Git وFlutter/Dart وعرض الصور متاحة؛ لا backend أو اتصال سائق فعلي.

## النتيجة والسلوك

- Domain خالص، ونماذج immutable وChatRepository وChatPolicy. لا use cases تمريرية.
- MockChatRepository يقرأ حالة الرحلة من MockTripStore في كل عملية، ويربط هوية السائق الأولى داخل جلسة المستودع. تغيير السائق يحجب السياق القديم والإرسال.
- النص trim ثم 1..1000 Unicode code points؛ أحدث 30 رسالة، cursor exclusive، والترتيب sequence.
- مفتاح عشوائي 24 bytes مستقل عن الساعة وعمر الصفحة. retry يحتفظ بالمفتاح والنص. فقد الرد يحفظ uncertain، ثم يصالح GET أو retry دون تكرار.
- بعد إغلاق الرحلة يعيد المفتاح المقبول سابقًا الرسالة الأصلية بعد فحص الهوية، دون كتابة جديدة. المفتاح الجديد مرفوض.
- Cubit يحرس الجلسة والإغلاق والطلبات القديمة وrevision وreceipts. ويتحقق أن send acknowledgement يطابق clientMessageId/body/author؛ الرد المخالف يصبح INVALID_RESPONSE/uncertain مع بقاء النص والمعرف الأصليين.
- polling كل 5 ثوانٍ والاستئناف وinvalidations تدمج الأحدث دون محو التاريخ. يملأ cursor فجوة الرسائل إذا فات أكثر من 30 رسالة بين تحديثين، وتُزال التكرارات بالمصالحة.
- markRead لا يصدر من poll أو fetch نفسه؛ الصفحة تؤكده بعد الرسم عند الأحدث فقط، وهي current والتطبيق resumed. خطأ التحميل يوقفه، واستجابة قراءة قديمة لا تعكس metadata أحدث.
- نجاح الإرسال لا يدعي تسليمًا أو قراءة. أحداث mock حتمية: delivered بعد ثانيتين، read بعد 4 ثوانٍ، ورد سائق بعد 6 ثوانٍ؛ fetch يستدرك الوقت، ولا رد سائق جديد بعد الإغلاق. fixtures لا تسبق إنشاء الرحلة أو حالتها الحالية، وتراجع الساعة لا يعكس توقيت آخر رسالة مقبولة.
- resetSession يحذف النصوص ومفاتيح العمليات ويخلي الصفحة فورًا؛ dispose يغلق الموارد. API mode يفشل SERVICE_UNAVAILABLE دون fallback أو credentials أو جلسة Auth جديدة.

الواجهة مبدئية وتستهلك الثيم والتوكنات والمكونات المركزية. تدعم العربية RTL والإنجليزية LTR. جهة العميل يمين والسائق يسار كما UI-13؛ محاذاة المؤلف ثابتة ومقصودة حتى في RTL. تعرض الأوقات والحالات بالنص وأيقونات Material الحقيقية، مع حقل متعدد الأسطر وعداد وحدود وإرسال قابل للوصول. التمرير معكوس لإبقاء الأحدث قرب الحقل، وإضافة رسائل عند قراءة التاريخ تحفظ الموضع. توجد إجراءات تحميل الأقدم والتحديث والعودة للأحدث عند الحاجة.

ChatCubit يبلغ **336 سطرًا**؛ تجاوز محدود ومقصود لإبقاء دورة async متماسكة قابلة للقراءة. حراس epoch والطلبات والهوية والمصالحة والإرسال والقراءة تتشارك حالة واحدة. لم يُضغط التنسيق ولم تُنشأ part أو طبقات تمريرية لتخفيض العدد. الصفحة مركبة من ChatTimeline وChatStatusBanner وChatComposer وChatMessageBubble بمسؤوليات واضحة.

## الربط وحزمة الباكند

- `chat_entry.dart`: `registerChatDependencies(GetIt)` يسجل factoryParam، ويستخدمه `buildChatFeature(repository:, tripId:, policy:, now:, onBack:)` مع fallback للاختبار المعزول. لا locator داخل widgets.
- `domain/chat_repository.dart`: ChatPolicy وChatRepository وتصدير chat_models.
- `data/mock/mock_chat_repository.dart`: `MockChatRepository(MockTripStore, {now, scenario, policy})`، وresetSession/dispose.
- `data/mock/chat_mock_scenario.dart`: success/empty/disconnect/sendFailure/lostResponse؛ parse يقبل success/empty/disconnect/send_failure/lost_response.
- `data/unavailable_chat_repository.dart`: فشل صريح دون fallback.
- UI keys: chat-input، chat-send، chat-refresh، chat-load-older، chat-newest.

المشرف يملك route وAppConfig وDI وreset/navigation ومدخل ActiveTrip واختبارات الربط والترجمات المولدة. نُسقت الواجهات وChatPolicy وX-Chat-Driver-Id معه. بعد أول GET يحتفظ adapter المقترح بربط هوية المحادثة داخل الجلسة، ويرسل الهيدر في الكتابة وread والقراءات التالية، ويرفض الخادم DRIVER_CHANGED بدل التوجيه الصامت لسائق آخر.

الحزمة: [العقد العربي v1](../../../api/chat/chat-v1.md)، [README.ar.md](../../../api/chat/README.ar.md)، [Collection v2.1](../../../api/chat/chat-v1.postman_collection.json)، و20 مثال JSON تحت examples. idempotency الدائم والتفويض والهوية مسؤولية الخادم الحقيقي. لم يجر HTTP حي أو استيراد فعلي في Postman أو رفع الحزمة إلى حساب خارجي.

## التحقق الفعلي

شُغلت الأوامر التالية من `apps/customer`:

```bash
dart format --output=none --set-exit-if-changed lib test
flutter analyze --no-pub
flutter test --no-pub
flutter test --no-pub test/features/chat
flutter test --no-pub --dart-define=CAPTURE_CHAT_UI=true --update-goldens test/features/chat/chat_widget_test.dart
flutter test --no-pub --dart-define=CAPTURE_CHAT_UI=true test/features/chat/chat_widget_test.dart
```

النتائج النهائية: format على 254 ملفًا دون تغيير، analyze بلا مشكلات، **458 اختبارًا كاملًا ناجحًا** على فرع الميزة، منها **49 اختبارًا جديدًا**. ونجحت 17 حالة widget/golden عند الالتقاط، ثم 17 عند المقارنة دون تحديث.

شمل التحقق حدود runes والترقيم والتسلسل وreceipts وidempotency وفقد الرد والإغلاق وتغيير السائق وعزل الجلسة والقراءة المتأخرة مقابل الإرسال وإغلاق الصفحة والـack المخالف والصفحة المخفية والخلفية والمسودة الأحدث وحفظ موضع التاريخ وملء فجوة polling. اختبارات العقد تفك كل مثال، وتقارن mock fetch/send/read، وتطابق saved responses، وترفض UTC/version/cursor/identity والترتيب غير الصالح.

نجح أيضًا `python3 scripts/dev/sync_feature_l10n.py --check` و`git diff --check`، وفُك 21 ملف JSON (20 مثالًا وCollection) باستخدام json.loads.

لأن sync script والملفات المولدة ملك المشرف، أضيف دعم chat مؤقتًا محليًا لتوليد الترجمة والتحقق. لم تُلتزم هذه التغييرات، وأعيدت الملفات إلى الأساس قبل التسليم. لإعادة اختبار SHA الميزة منفردًا يلزم تمكين fragment chat في sync script ثم sync/gen-l10n؛ المشرف يملك ذلك في فرع التكامل. النتائج أعلاه تشمل الترجمات المولدة المطابقة لـARB النهائية. لم يختبر المنفذ root integration داخل worktree الميزة؛ المشرف يفحص SHA المجموع.

## الصور والمقارنة

23 صورة تحت [screenshots/](screenshots/) من Flutter widget-test renderer. استُخدمت خطوط النظام Noto Arabic/Noto Latin محليًا للاختبار وMaterialIcons؛ لا خط جديد أو dependency جديدة في التطبيق. فُحصت الصور فعليًا، أفرادًا وcontact sheet: اللغتان، 320×640 بخط 2x، و390×844 بخط 1x، و800×1000 بخط 2x، و800×390 بخط 1x، مع وبدون keyboard insets مقدارها 260dp (120dp في الاتجاه الأفقي). وتشمل empty/loading/offline/failed/uncertain/read-only/read receipt.

عند 320/2x مع الكيبورد يبقى الحقل والإرسال ضمن المساحة. الرسائل الطويلة والقديمة تُراجع بالتمرير، والحقل قابل للتمرير داخليًا عند الضيق. مؤشر المحاكاة مختصر إلى Simulation/محاكاة تطوير ليبقى مقروءًا. لا cap لتحجيم النص. هذه أدلة renderer وليست Android أو IME حقيقيًا أو تحققًا على جهاز فعلي.

واجهة المرحلة الأولى قابلة للاستخدام وقريبة من لغة UI-13، وليست بصريًا نهائية أو release-ready. يؤجل للمرحلة الثانية الصقل الدقيق لذيول الفقاعات والخطوط والمسافات وتجميع التواريخ وتوزيع الرسائل في الصفحة القصيرة مقارنة بالمرجع. إطار الهاتف وصور الموكأب ليست من المنتج.

## الحدود والتسليم

المسودة وpending غير المقبول لا يُحفظان بعد مغادرة الصفحة، باتفاق المشرف. لا outbox دائم أو حفظ على القرص. المقبول يستعاد من repository عند إعادة الفتح؛ retry داخل الصفحة يحفظ المعرف الأصلي. المحاكاة لا تنشئ توكنات أو حجوزات أو دفعًا أو رسائل حقيقية. مؤشر المحاكاة ثابت لهذه المرحلة، ويُستبدل ضمن تكليف live integration لاحقًا مع بيانات receipts وشبكة حقيقيتين.

لا push أو main أو Actions أو Android build أو تشغيل محاكي. لا طلبات مشتركة معلقة؛ الربط وفحص التكامل والترجمة المولدة والمراجعة المستقلة تحت ملكية المشرف. يجمّد المنفذ كود التسليم حتى طلب إصلاح محدد.

## تجميع المشرف قبل المراجعة المستقلة

جمع المشرف تنفيذ8bf7964 وتسليم30b2866 مع الربط في codex/w2-chat-integration.
الكود المشترك والترجمات واختبارات التطبيق محفوظة عند70f147a؛ مرشح التجميع
بعد تقرير المنفذ7bc9c37a0abbabd5bfde30c13c2953e1a45bd9bb. هذا جاهز للمراجعة
وليس اعتمادًا ذاتيًا أو دمجًا نهائيًا إلى فرع العمل.

الربط: CHAT_DATA_MODE وCHAT_MOCK_SCENARIO وChatPolicy فيAppConfig، مصدر
MockChatRepository واحد بعمرTamApp مع reset/dispose، وget_it factoryParam.
مسار /trips/:tripId/chat وحراسته مستقلان عنTrips/ActiveTrip. openChat يفتح
المعرف فقط؛ مدخل من المتابعة عند وجود سائق، وعودة pop مع بديل متابعة الرابط
المباشر. لم يتغيرAuth/OTP أوTemporary Phone Entry.

أعاد المشرف format255/0 وanalyze بلا ملاحظات، وflutter test --no-pub
--reporter expanded: **462 PASS** (458 مع الميزة و4 لاختباراتApp الجديدة)،
والسجل المؤقت /tmp/tam-chat-combined-tests.log. l10n --check وJSON21 وdiff سليمة.
اختباراتApp الأربعة تثبت الحجز والتعيين ثم إرسال مؤكد واستعادة الرسالة مرة
واحدة بعدHome، وإلغاء الرحلة منطلباتي ثم القراءة فقط، والخروج/جلسة جديدة
دون رسائل السابقة. وتثبت منعguest/localAccess فيAPI، وعدمmock fallback للمستخدم
الموثق عند عدم توفر النقل. أصلحت ملاحظات ترتيبimports ضمن الفحص النهائي.

حُدثت صورgolden الخاصة بمتابعة الرحلة لتعرض مدخل المحادثة، ونص بطاقة السائق
أصبح يصف المكالمات وحدها. نُسقت مساحة الحوار على320/2x باستخدام inset16dp
منAppSpacing وضبط عرض المحتوى؛ يظل النص والحوار قابلين للتمرير. نجحت15حالة
التقاط ثم15مقارنة دون تحديث. الأدلة الحالية في
apps/customer/test/features/active_trip/goldens/؛ صور تسليمActiveTrip القديمة
توثّق النسخة السابقة وتبقى محفوظة. فُتحت confirmed390 وdriver320/2x
وdriverEN-landscape وresponsiveAR800 فعليًا، وصور المحادثة/الكيبورد/الفشل في
تسليمها. المراجع يفحص SHA المجموع والمراجع الأصلية والأدلة النهائية.
