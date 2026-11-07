# W1-NOTIFICATIONS — الإشعارات

التكليف: منفذ الميزة D، مسند وجاهز للتنفيذ عند وصول هذه البطاقة.
المراجع المستقل يعيّنه المشرف عند التسليم؛ لا تعتمد عملك بنفسك.
مرجع الأساس الثابت: Git tag `tam-w1-baseline-2026-11-07`؛ يجب أن يساوي
SHA الكامل الذي أرسله المستخدم في رسالة التكليف. لا تبدأ من main.
فرعك: `codex/w1-notifications`. اسم مجلد عمل محلي مقترح:
`/home/hazem/projects/tam-w1-notifications`، مستقل عن checkout المشرف والبقية.

## إنشاء مساحة العمل

على جهاز المستخدم، نفذ من أي مجلد دون تغيير فرع checkout المشرف:

```bash
git -C /home/hazem/projects/mashwar fetch origin tag tam-w1-baseline-2026-11-07
git -C /home/hazem/projects/mashwar worktree add -b codex/w1-notifications /home/hazem/projects/tam-w1-notifications tam-w1-baseline-2026-11-07
```

بعدها نفّذ **كل** قراءة وتعديل وأمر داخل `/home/hazem/projects/tam-w1-notifications`
باستخدام workdir الأداة، وتحقق من HEAD مقابل SHA رسالة التكليف قبل الكتابة.
إذا كانت المساحة/الفرع موجودين، لا تحذفهما أو reset لهما؛ تحقق من أنهما
تكليفك الصحيح ولا تكتب في مساحة وكيل آخر. عند lock مؤقت من تجهيز وكيل
آخر، أعد المحاولة بعد انتهائه دون حذف lock نشط.

على جهاز آخر، استخدم clone مستقلًا من `git@github.com:Hazem-bcs/Tam.git`،
اجلب tag نفسه وأنشئ فرعك المحدد منه؛ لا يشترط وجود مسار جهاز المستخدم.
إن لم تتوفر أدوات Git/Flutter/الصور، أعلن ذلك وقدّم الأجزاء الممكنة وpatch
مرتبطًا بالأساس وفق القالب بدل الادعاء أنك نفذت الأوامر.

## الاستلام والبداية

اقرأ AGENTS.md ثم agent-onboarding.md والقواعد المرتبطة، وهذه البطاقة،
و[العقود المشتركة](../wave-one-contracts.md) و[سياسة Mock/API](../mock-api-policy.md)
و[متطلبات الباكند](../api-handoff-template.md). افتح الصور بصريًا من
[الفهرس](../design-reference-index.md): **UI-05**.
سجّل ما قرأته وSHA/الفرع/المجلد وصورك وأدواتك في تقرير المهمة، ثم ابدأ
التنفيذ دون انتظار موافقة أخرى عندما تتطابق مدخلات التكليف. إن كانت صورة
أو أداة غير متاحة، تقدم في الأجزاء المستقلة واذكر ما يمنع الجزء المعتمد عليها.

## الملكية

- `apps/customer/lib/features/notifications/**` بما فيه entry وl10n الخاصان بك.
- `apps/customer/test/features/notifications/**`.
- `docs/api/notifications/**` و`docs/engineering/deliveries/W1-NOTIFICATIONS/**` فقط.
- الكود المشترك والميزات الأخرى وroot tests وscripts وpubspec وملفات
  المنصات وapp/core وshared وAGENTS ولوحة المهام للقراءة فقط. أي حاجة لتغييرها
  تسجلها كطلب واضح للمشرف في تقريرك؛ لا تكررها داخل ميزتك.
- استثناء مشتقات الترجمة: شغّل أداة الجمع وFlutter gen-l10n محليًا للفحص؛
  لا تعدل النواتج يدويًا ولا تضمها لكوميتك. ارفع ARB fragment المملوك فقط.

## التنفيذ المطلوب

- نفذ صندوق إشعارات العميل مع الحالة المقروءة/غير المقروءة، قائمة وترقيم وتحديث وmark-as-read وmark-all-read، وتفاصيل محتوى بسيطة عند الحاجة.
- ضع بيانات اصطناعية محددة في data/mock فقط. الإشعار المرتبط برحلة يستخدم mock-history-001 الموجودة في seed المشتركة، لا معرفًا يولده الوكيل عشوائيًا.
- واجهة domain repository هي مصدر unread count. اجعل الحالة والمستودع يظلان متسقين بعد القراءة/refresh/failure، وسلّم واجهة عداد موثقة للمشرف لتوصيل شارة Home لاحقًا؛ لا تعدّل Home.
- وجهات allowlist فقط home/trips/trip. افتح الرحلة عبر CustomerNavigation؛ unknown target لا يفتح URL أو route من JSON.
- استبدل notifications_entry مع الحفاظ على التوقيع. المحاكاة ليست إشعارات نظام؛ Push/FCM وتسجيل الجهاز والأذونات والعمل بالخلفية خارج النطاق.
- يحدد العقد created_at/read_at وأنواع الإشعارات ومحتواها، ولا يربط منطق التطبيق بمقارنة نص الرسالة.

## معايير القبول

- العدد لا يصبح سالبًا ولا يُنقص مرتين عند إعادة التعليم كمقروء؛ بعد الخطأ لا تعرض حالة نجاح غير مؤكدة.
- فتح وجهة صحيحة واختبار unknown target، وempty/error/retry/pagination ومعرّف رحلة مفقود دون crash.
- اختبارات repository/cubit/widgets والمقروء وإلغاء الاشتراكات، وصور اللغتين والهاتف والتابلت والخط الكبير.
- Clean Architecture/SOLID/DRY بصورة عملية، الثيم والمكونات المركزية،
  ملفات مكتوبة يدويًا يفضل ألا تتجاوز 300 سطر مع تفسير أي استثناء.
- مصدر البيانات يختار في entry/composition فقط. لا fixtures أو if(mock)
  داخل Page/Cubit؛ في api غير الجاهز استخدم repository يفشل بوضوح
  SERVICE_UNAVAILABLE ولا fallback إلى Mock. لا تنفيذ HTTP حي أو fake Auth.
- تصميم هاتف 320/390 وتابلت 800dp، RTL/LTR، خط 2x، safe areas والكيبورد
  والنص الطويل والرجوع؛ لا تحتاج Android build لكل تعديل صغير.

## تسليم الباكند إلزامي

GET /notifications، GET /notifications/unread-count، POST /notifications/{id}/read، POST /notifications/read-all؛ أمثلة للوجهات المعروفة وغير المعروفة والترقيم وأخطاء القراءة.

سلّم داخل docs/api/notifications/: README.ar.md، notifications-v1.md،
notifications-v1.postman_collection.json (v2.1) وأمثلة تطابق fixtures/parsing.
وثق headers/auth والحقول والأنواع/nullable والقيود والنجاح والأخطاء والترقيم
وحالات التعديل، بعقد مقترح للباكند لا ادعاء endpoint قائم. لا أسرار أو
تعديل للعقد الأصلي لـAuth. افحص JSON والعقد والأمثلة وأبلغ بحدود التحقق.

## التحقق والتسليم للمشرف

من جذر المستودع: `python3 scripts/dev/sync_feature_l10n.py`.
من apps/customer: `flutter gen-l10n` ثم
`dart format --output=none --set-exit-if-changed lib test`،
`flutter analyze --no-pub`، `flutter test --no-pub`.
أصلح عيوب نطاقك؛ اذكر فشلًا ناتجًا عن عقد/اختبار مشترك مع خطواته وطلب تغييره
دون حذفه لإظهار نتيجة خضراء. افحص UI فعلية واحفظ الصور ضمن deliveries/W1-NOTIFICATIONS.
نسق أي استخدام للمحاكي عبر المستخدم؛ لا تشغله إذا كان وكيل آخر يستخدمه.

احفظ تقرير HANDOFF.md ضمن deliveries/W1-NOTIFICATIONS: baseline/فرع/SHA، الملفات،
ما اكتمل، أوامر ونتائج فعلية، الصور والبيئة، حزمة API، القيود وطلبات المشترك.
اعمل كوميت بملفاتك المملوكة فقط ورسالة تنتهي [skip ci]، وارفع **فرعك فقط**
إلى origin إن توفرت الصلاحية. هذا التكليف يفوض ذلك؛ لا main ولا merge
ولا Actions ولا force-push. إن تعذر push احتفظ بالكوميت واذكر العائق.
أعد للمستخدم تقريرًا لينقله للمشرف مع SHA النهائي، ثم جمّد نسخة التسليم
للمراجعة. لا تراسل وكلاء أو أطرافًا أخرى دون تفويض، ولا تبدأ مهمة أخرى تلقائيًا.
