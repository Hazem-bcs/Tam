# تم — لوحة المهام المشتركة

آخر تحديث: 2026-11-10. يدير المشرف وحده التكليفات وتحديث هذه اللوحة،
وفق تقارير الوكلاء؛ لا تكتشف اللوحة نشاط محادثات Claude/Gemini وغيرها تلقائيًا.
تأكد وصول تسليمات الملاك الخمسة على origin، وانتهت المراجعات المستقلة
الأولى للأربعة المتبقية، ثم جُمعت الميزات الخمس في feat/auth-contract
وحُلت عيوب التكامل واجتازت مراجعة مستقلة للنسخة المجمعة. قبول الدفعة
للمرحلة الأولى وفق قرار المستخدم؛ التصميم النهائي مرحلة ثانية. [سجل المراجعات](wave-one-review-status.md)
يحتوي SHAs والعيوب والطلبات المشتركة. [خطة الدفعة](wave-one-plan.md) مرجع النطاق.

## الحالات والحجز

اكتمل التكليف W4-MAPS: INTEGRATED، المشرف root، فرع codex/customer-maps
منb599713؛ [البطاقة](tasks/W4-MAPS.md). تأكيد المستخدم: خدماتنا غير جاهزة،
تجهيز العميل والعقود دون استخدام خدمات خرائط عامة. لا كاتب متزامن في ملكيتها.

- `PLANNED`: مقترحة وتحتاج تفاصيل/مدخلات قبل الإرسال.
- `BLOCKED`: المانع مذكور؛ عدم وجود مالك لا يجعلها متاحة.
- `READY`: بطاقة مكتملة وbaseline متاح، ولا يوجد تعارض ملكية؛ متاحة للتكليف.
- `IMPLEMENTING`: حجزها المشرف لوكيل بفرع وcheckout محددين قبل الكتابة.
- `REVIEW`: تسليم على SHA محدد، متاح لمراجع مستقل يكلفه المشرف.
- `CHANGES_REQUIRED`: المراجعة منتهية وفيها إصلاحات/طلبات تمنع الاعتماد النهائي.
- `APPROVED_AT_SHA`: اعتماد النسخة النهائية المحددة بعد الإصلاحات ضمن النطاق الموثق؛ يذكر الاعتماد البصري منفصلًا.
- `INTEGRATED`: دمج وفحص في فرع التكامل الموثق، وليس بالضرورة main.

عند تعثر مهمة جارية يسجل المشرف الحالة السابقة وسبب التوقف والملفات
التي تبقى محجوزة؛ لا يفسر BLOCKED كإخلاء للملكية أو إذن لوكيل ثان بالكتابة.
لا يختار الوكيل مهمة من نسخة قديمة ولا يحجزها تلقائيًا؛ يطلبها من المشرف.

## الأساس المشترك

أساس التنفيذ هو الكوميت الذي يشير إليه Git tag الثابت
`tam-w1-baseline-2026-11-07`؛ يرسل المشرف SHA الكامل معه في الرسائل الخمس.
يتضمن اختيار mock/API، مخزن الرحلات المشترك، نقاط الدخول والمسارات، الترجمة
المقسمة وبطاقات التنفيذ. لا يبدأ أحد من main القديم أو من اسم فرع متحرك.

W1-BASE جاهز من ناحية التجهيز والتحقق المحلي؛ لا تُسجل اختبارات الأساس
كمراجعة مستقلة للميزات التي لم تُنفذ بعد. يذكر تقرير الأساس أدلة التحقق.

## الدفعة الحالية — تكليفات جاهزة ومحجوزة

| المهمة | الحالة | المالك / المراجع | البطاقة |
|---|---|---|---|
| W1-HOME | INTEGRATED — المرحلة الأولى؛ التحسين البصري للمرحلة الثانية | A / المشرف | [الرئيسية](tasks/W1-HOME.md) |
| W1-RIDE | INTEGRATED — المرحلة الأولى؛ التحسين البصري للمرحلة الثانية | B / review_ride | [طلب الرحلة](tasks/W1-RIDE.md) |
| W1-TRIPS | INTEGRATED — المرحلة الأولى؛ التحسين البصري للمرحلة الثانية | C / review_trips | [طلباتي](tasks/W1-TRIPS.md) |
| W1-NOTIFICATIONS | INTEGRATED — عزل الجلسة والشارة محلولان؛ التحسين البصري للمرحلة الثانية | D / المشرف | [الإشعارات](tasks/W1-NOTIFICATIONS.md) |
| W1-SETTINGS | INTEGRATED — reset الجلسة مربوط؛ التحسين البصري للمرحلة الثانية | E / review_settings | [الإعدادات](tasks/W1-SETTINGS.md) |
| AUTH-API | BLOCKED | غير مسند / غير مسند | ينتظر الباكند وتفويض الربط |

اعتماد Home عند `ede036c5fbd4e833c62327414ef9d3eaec0ddeb4`؛ الكود
المجمع بترجماته محفوظ عند `48b1649a05f639d5fe4fff874e7a29f9bb0f1592`.
[تقرير المراجعة](deliveries/W1-HOME/REVIEW.md) و[جرد واجهات العميل](customer-ui-progress.md).
معيار العمل الحالي في [خطة المرحلتين](development-phases.md): نكمل البنية
والسلوك وDomain/Data والعقود بواجهة مبدئية الآن، ثم التحسين البصري الشامل
بعد اكتمال التدفقات المتفق عليها. الفروق البصرية المعروفة لا تمنع وحدها
دمج المرحلة الأولى، ولا نحذفها من قائمة المتابعة.

اعتماد التكامل المستقل عند `57e966ca2382b1e344a649bbb088ad8884cadc30`؛
**296 اختبارًا ناجحًا**، format/analyze وl10n --check ناجحة. راجع
[تسليم التكامل](deliveries/W1-INTEGRATION/HANDOFF.md) و[مراجعته](deliveries/W1-INTEGRATION/REVIEW.md).
شُغّلت النسخة المجمعة على المحاكي وشملت الخمس، مع [صور Android فعلية](deliveries/W1-INTEGRATION/screenshots/).
زُومن فرع feat/auth-contract إلى GitHub عند `a5c8dee732811798eda5abdf061a1bda0c728cc3`
قبل بدء العناوين؛ لم يُدمج main أو تُشغل Actions. المراجع البصرية تظل مرجع المرحلة الثانية.

## الدفعة التالية — الحالة الفعلية

| المهمة | الحالة | الاعتماد / المراجع |
|---|---|---|
| W2-ADDRESSES | INTEGRATED — المرحلة الأولى؛ 333 اختبارًا ناجحًا بعد الدمج المحلي | المشرف / review_addresses؛ [البطاقة](tasks/W2-ADDRESSES.md) و[المراجعة](deliveries/W2-ADDRESSES/REVIEW.md) |
| W2-SCHEDULE | INTEGRATED — المرحلة الأولى؛ 363 اختبارًا ناجحًا بعد الدمج المحلي | المشرف / review_schedule؛ [البطاقة](tasks/W2-SCHEDULE.md) و[المراجعة](deliveries/W2-SCHEDULE/REVIEW.md) |
| W2-ACTIVE-TRIP | INTEGRATED — المرحلة الأولى؛409 اختبارات ناجحة بعد الدمج المحلي | المشرف / review_active_trip؛ [البطاقة](tasks/W2-ACTIVE-TRIP.md) و[المراجعة](deliveries/W2-ACTIVE-TRIP/REVIEW.md) |
| W2-CHAT | INTEGRATED — المرحلة الأولى؛468 اختبارًا ناجحًا بعد الدمج المحلي | المشرف / review_chat؛ [البطاقة](tasks/W2-CHAT.md) و[المراجعة](deliveries/W2-CHAT/REVIEW.md) |
| W2-COMPLETION | INTEGRATED — اعتماد الإغلاق المجمع511ca9c؛625 اختبارًا بعد الدمج | [البطاقة](tasks/W2-COMPLETION.md)؛ [المراجعة المستقلة](deliveries/W3-ACCOUNT-CONTACT/REVIEW.md) |
| W2-SUPPORT | INTEGRATED — اعتماد الإغلاق المجمع511ca9c؛625 اختبارًا بعد الدمج | [البطاقة](tasks/W2-SUPPORT.md)؛ القانوني غير منشور حتى اعتماد نصه |

العناوين والجدولة والرحلة الجارية والمحادثة معتمدة ومدمجة للمرحلة الأولى.
السجل التالي يصف مرشح W2 قبل مراجعة الإغلاق؛ حُل تعليق اعتماده لاحقًا
بمراجعة W3 الشاملة منbd24d59 إلى511ca9c كما في سجل الإغلاق أدناه.
التقييم والدعم منفذان ومفحوصان على `7c040f7d9954033530d724237d382780b563bbea`
في codex/w2-final-features-integration؛569 اختبارًا و76 اختبار مقارنة UI
ناجحة، وformat/analyze/l10n/JSON34/diff سليمة. توقف المنفذان عند حد
الاستخدام؛ حفظ المشرف عملهما وأكمل النواقص. لم تُنفذ مراجعة مستقلة لهذا
المرشح، لذلك لم يُجمع إلى feat/auth-contract ولم يُسجل INTEGRATED أوAPPROVED.
[تسليم المرشح](deliveries/W2-FINAL-FEATURES/HANDOFF.md) و[بطاقة المراجعة الجاهزة](tasks/W2-FINAL-REVIEW.md).
لم تكن المراجعة مسندة آنذاك؛ استوعبتها بطاقة W3-CUSTOMER-REVIEW لاحقًا.
لا حجز جديد لكتابة الميزتين، ولا push/main/Actions. المحفظة/الكوبونات والخدمات الأخرى تحتاج قرار منتج وتصميم عميل،
ولا يُستخدم تصميم محفظة السائق بديلًا عنها.

اكتملت المراجعة المستقلة للعناوين في 2026-11-09 على
`codex/review-w2-addresses`، باعتماد `8c351a43d3c4c1d21f258754ef0fa89e0870a2f3`.
رأس المراجعة `1f0fe085719a6460b846ffb5d77cd9f48bad7ea7` يضيف تقريرًا فقط.
دُمج محليًا دون تعارض في `codex/w2-integration` عند
`5fc71deef9202b79439ede0d073d9802ab6a32f6`، ثم جُمّع إلى feat/auth-contract.
كود المرشح واختباراته وحزمة API مطابقة للرأس المعتمد؛ أعاد المشرف
format (192 ملفًا دون تغيير)، analyze، الاختبارات الكاملة (333 ناجحة)،
وفحص l10n وdiff. لا رفع جديد أو main أو Actions. المحاولة السابقة للمراجعة
توقفت عند حد الاستخدام ولم تُحتسب اعتمادًا.

الجدولة معتمدة مستقلاً عند `d5e55034fc1b29f2fe02fd5bad71ac5afe781a6a`؛
رأس المراجعة `d5bf236ed2ca2d551c145fe3d3a40c687fc8b1d5` يضيف تقريرًا فقط.
دُمج دون تعارض في codex/w2-schedule-integration عند
`10e00a57527387e88b3cd94dcc963e9fe946e70c`، ثم جُمع إلى feat/auth-contract.
كود المرشح واختباراته وحزمة API مطابقة للرأس المعتمد؛ أعاد المشرف format
(208 ملفات دون تغيير)، analyze، كامل الاختبارات (363 ناجحة)، وl10n وdiff.
لا رفع جديد أو main أو Actions. انتهت المراجعة بعد استئناف انقطاع اتصال
مزود الخدمة، ولم يُحتسب أي اعتماد قبل اكتمال تقريرها.

الرحلة الجارية معتمدة مستقلاً عند `cb60f95e1697732d2e9125870440c6290eb1b4da`؛
رأس المراجعة `d952046b557a5e73158095d9784ac87bda941f33` يضيف تقريرًا فقط.
أصلح المراجع تراجع ساعة الجهاز قبل أول live snapshot وأضاف اختبار ارتداد.
دُمج دون تعارض في codex/w2-active-trip-integration عند
`961f1e62bfc54044077f3287aae98d13cfd37366`، ثم جُمع إلى feat/auth-contract المحلي.
كود المرشح واختباراته وحزمة API مطابقة للرأس المعتمد؛ أعاد المشرف format
(232 ملفًا دون تغيير)، analyze، كامل الاختبارات (409 ناجحة)، وl10n وJSON20 وdiff.
راجع المراجع UI-12/UI-15 وصور التسليم19، ونجحت مقارنة golden15 دون تحديث.
لا رفع جديد أو main أو Actions أو محاكي أو Android build ضمن هذه المهمة.

المحادثة معتمدة مستقلاً عند `5eb9d0eb2800d9152b508857469e9365b8ae8c8a`؛
رأس المراجعة `2539f9b8e1fe46e0a01c279dce914e3fe1b71562` يضيف تقريرًا فقط.
أصلح المراجع خمسة عيوب في pagination/late replies/visibility، واتساق هيدر
السائق في Postman، وأضاف ستة اختبارات سلوكية. دُمج الكود دون تعارض في
codex/w2-chat-integration عند `57fa0b4b1a03563462d3895cd3fbc3ba1df47778`،
وأضيف التقرير عند `83d46a8f8478cb7a02866f6fc954c2006a03162a`، ثم جُمع محليًا إلى feat/auth-contract.
كود المرشح واختباراته وAPI مطابق للرأس المعتمد. أعاد المشرف format257/0
وanalyze وكامل الاختبارات468 وl10n/JSON21/diff. أعاد المراجع مقارنةgolden17
للمحادثة و15للمتابعة دون تحديث، وفحصUI-13 وصور المحادثة23 والمتابعة19.
لا رفع أو main أو Actions أو محاكي أو Android build؛ الباكند غير مربوط.

## حفظ معرفات التخطيط السابق

المهام القديمة غير المسندة لم تبدأ ولم تُحذف نتائج منفذة:
TAM-001 (مواصفات Home) يُستوعب في تحضير W1-HOME، وTAM-002 (تدقيق Dart)
مؤجلة كتدقيق اختياري. TAM-003/004/006 تتوزع بين W1-HOME/W1-RIDE،
وTAM-005 يصبح AUTH-API، وTAM-007 ضمن W1-SETTINGS بنطاقه المحدد والعناوين
للاحق، وTAM-008 يصبح W1-TRIPS. لا نعيد استعمال الأرقام لمعان مختلفة.

## سجل كل تكليف يملؤه المشرف عند الإرسال

```text
Task / feature owner / independent reviewer:
Status / last update / blocker and retained ownership:
Baseline SHA / dependency SHAs:
Implementation branch / isolated checkout:
Owned and excluded paths / design references:
Acceptance criteria / shared interfaces / data mode:
API handoff path / actual verification capabilities:
Delivered SHA / review branch / approved final SHA:
Integration SHA and branch / unresolved limitations:
```

يستخدم المشرف [قالب التكليف والتسليم](agent-task-template.md). عند نهاية
العمل يرسل الوكيل SHA واختباراته وعقد API وPostman وأدلته للمشرف عبر
المستخدم أو قناة مأذون بها؛ لا يعدل نسخًا متنافسة من اللوحة داخل فرعه.
المشرف يطلب المراجعة ويجمع المعتمد تدريجيًا. لا تبدأ مهمة جديدة بعد التسليم
إلا بتكليف آخر، ولا يُستنتج إذن main/Actions من اعتماد كود الميزة.

## إغلاق نطاق تسليم الباكند — قرار المستخدم 2026-11-09

| المهمة | الحالة | المالك | البطاقة |
|---|---|---|---|
| W3-ACCOUNT-CONTACT | INTEGRATED — اعتماد511ca9c؛625 اختبارًا بعد الدمج | المشرف root / review_chat | [التكليف](tasks/W3-ACCOUNT-CONTACT.md) |
| W3-CUSTOMER-REVIEW | APPROVED_AT_SHA511ca9c — شمل W2 وW3 كاملين | review_chat، فرع codex/review-customer-api | [التقرير](deliveries/W3-ACCOUNT-CONTACT/REVIEW.md) |

يشمل حذف الحساب وتغيير الرقم والاتصال بالسائق، ثم تجميع ومراجعة Postman
موحد. المحفظة والدفع الإلكتروني والكوبونات مؤجلة. لا يتطلب العمل باكندًا
حيًا؛ لا يبدأ الصقل البصري حتى تسليم العقد المتفق عليه.

مرشح إغلاق منطق العميل الأصلي `882c9e55ca17bc651f238d0b98abbabe14d877fb`
يتضمن تغييرات الرقم والحذف والاتصال وPostman موحدًا بـ14 مجلدًا و58 مثال
طلب. format334/0 وanalyze و618 اختبارًا و92 مقارنة UI وستة اختبارات
Python وJSON218 وl10n/Postman --check/diff ناجحة. المراجعة المستقلة تشمل
W2 السابق غير المعتمد وW3 معًا؛ [بطاقة المراجعة](tasks/W3-CUSTOMER-REVIEW.md)
و[التسليم](deliveries/W3-ACCOUNT-CONTACT/HANDOFF.md). هذه نتائج المرشح قبل إصلاحات المراجعة.

تعيين المراجعة: review_chat على codex/review-customer-api داخل worktree
/home/hazem/.codex/worktrees/review-customer-api/mashwar من882c9e5؛
المجلدات القديمة محفوظة بتوليداتها غير الملتزم بها ولا تُستخدم للكتابة.
اكتملت المراجعة الشاملة عند511ca9ce2ed24484602c78db283d5ef1fc66eb25؛
الرأس93c663effa3fec72061d762f370decb6751b7cba يضيف التقرير فقط.
أصلح المراجع إبطال OTP وسباق أهلية/هوية الاتصال وظهور الصفحة، وأضاف7
اختبارات.625 اختبارًا و92 مقارنة UI وPython6 وJSON218 وschema والتوليد سليمة.
دُمج المعتمد دون تعارض محليًا عند0409a37، والتقرير عندb775ccc، في
codex/customer-backend-handoff. تحقق المشرف من تطابق الكود/API/scripts
مع511ca9c وأعاد التنسيق336/0 والتحليل وكامل625 اختبارًا وPython6 وJSON218
وl10n/Postman/schema/diff؛ جميعها سليمة. الملف BACKEND_HANDOFF_PROPOSAL
صالح لتسليم طلب التنفيذ، وليس API حيًا. لا push/main/Actions أو Android build.

مرشح W4-MAPS عند `217b8da4fab5bbf1b5e000a7fd27fb375528e9a3`؛
المراجعة المستقلة مسندة إلى review_chat في codex/review-customer-maps داخل
/home/hazem/.codex/worktrees/review-customer-maps/mashwar. فحص المشرف:
format360/0 وanalyze وكامل667 اختبارًا وPython7 و227JSON وschema/l10n ناجحة.
نجح اختيار نقطة فعلية في Android وإعادتها إلى الحجز بوصف يدوي؛ خدمات
الخريطة غير مهيأة ولا شوارع حية بعد. لا push/main/Actions.

أغلق W4-MAPS: اعتماد مستقل `8c7087253e07c4a94eb1c0abb52a6ed36a6c49df`، تقرير de67a8b، دمج `06a914c68bf2a59d0ecd8c0586664d7e5416859f`.
الكود وAPI/scripts مطابقان للاعتماد.676 اختبارًا و38 UI وPython7 سليمة؛
Postman BACKEND_HANDOFF_PROPOSAL بـ15/62، نُسخ إلى سطح المكتب.
لا خدمات حية بعد؛ لا push/main/Actions.

W4-MAPS-ATTRIBUTION: INTEGRATED، root، أساس3dcd151؛
طلب المستخدم تصغير الإسناد وطيه مع بقاء الحقوق متاحة.
[البطاقة](tasks/W4-MAPS-ATTRIBUTION.md). لا تغييرات API أو استضافة.

تحقق تعديل الإسناد: 679 اختبارًا و38 مقارنة UI والتنسيق والتحليل سليمة.

## TAM-MAIN-SHELL-01 — تكليف المستخدم 2026-11-16

IMPLEMENTED بواسطة root على أساس `d35efab` في
`codex/unified-main-shell-20261116`؛ [بطاقة المهمة](tasks/TAM-MAIN-SHELL-01.md).
توحيد شريط التنقّل تحت MainShell، دون تغيير البيانات أو المصادقة.

تحقق MainShell:81 اختبارًا محددًا ناجحًا، وformat/analyze/l10n سليمة، ومراجعة Android للصفحات الثلاث.
المجموعة الكاملة غير ناجحة؛ [التفاصيل والحدود](deliveries/TAM-MAIN-SHELL-01/HANDOFF.md).

TAM-VECTOR-MAPS-01: IMPLEMENTED بواسطة root على36413be، [البطاقة](tasks/TAM-VECTOR-MAPS-01.md).
خرائط MapLibre/OpenFreeMap وثيم مركزي ورموز متجهة، دون تغيير Auth أو الحجز.
105 اختبارات محددة والتحليل والتنسيق سليمة؛ عُرضت نسخة Android المجمعة مع main
على المحاكي. [التسليم وحدود خدمة المسارات والمجموعة الكاملة](deliveries/TAM-VECTOR-MAPS-01/HANDOFF.md).

TAM-FLOATING-LOCATION-01: IMPLEMENTED بواسطة root على242cff7، بطاقات عائمة
بحجم المحتوى وقائمة أماكن ورموز SVG أصلية. [البطاقة](tasks/TAM-FLOATING-LOCATION-01.md)،
[التسليم والفحوص المؤجلة](deliveries/TAM-FLOATING-LOCATION-01/HANDOFF.md).
