# W2-FINAL-REVIEW — مراجعة مستقلة لمرشح التقييم والدعم

استوعبت هذه البطاقة مراجعة W3-CUSTOMER-REVIEW الشاملة، وانتهت باعتماد
511ca9ce2ed24484602c78db283d5ef1fc66eb25 على كامل التغيير منbd24d59.
[التقرير](../deliveries/W3-ACCOUNT-CONTACT/REVIEW.md). لا توجد مراجعة أخرى
READY لهذه النسخة؛ التعليمات التالية تحفظ نطاق التكليف الأصلي.
هذه البطاقة محايدة للمزوّد؛ لا تفترض الاطلاع على تاريخ المحادثة.

## البروتوكول والنسخة

اقرأ AGENTS.md وagent-task-template.md وparallel-work.md وdevelopment-phases.md
وworking-agreement.md وADR0001 وdesign-system.md وnavigation.md وسياسة
mock-api-policy.md وapi-handoff-template.md من docs/engineering أوdocs/architecture.
اقرأ بطاقتي W2-COMPLETION/W2-SUPPORT وتسليماتهما وتسليم W2-FINAL-FEATURES.
أكد دور REVIEWER، النسخة الفعلية، الملفات والصور المتاحة وأدوات التحقق.

الأساس `bd24d5993ba8ffe14f2b41d06ba9b3106cf5cdec`؛ مرشح الكود المجمد
`7c040f7d9954033530d724237d382780b563bbea` في المستودع
/home/hazem/projects/mashwar على codex/w2-final-features-integration.
أنشئ فرع مراجعة معزولًا من المرشح بعد تكليف المشرف، ولا تغير checkout
المشرف أوworktrees المطورين؛ فيها مخرجات توليد مؤقتة محفوظة غير ملتزم بها.
تقرير المشرف اللاحق يغيّر الوثائق فقط؛ اعتمادك يجب أن يذكر SHA الكود الفعلي.

## النطاق والملكية

المراجعة تشمل diff كاملًا من الأساس: Completion وSupport وعقودهما وأمثلة
Postman، AppConfig/DI/router والحراسة والجلسة وARB، مداخل ActiveTrip/Trips/
Settings، TamTextField وChatComposer وأدلة الاختبارات والصور.
يجوز إصلاح عيب مثبت داخل هذا النطاق في فرع المراجعة مع اختبار ارتداد،
وتنسيق تعديل العقد مع أمثلته. لا إعادة تصميم شاملة أو تغيير Auth أو خصائص
غير متفق عليها. المراجع لا يحرر لوحة المهام؛ يسلّم SHA وتقريرًا للمشرف.

اختبر الملكية والهوية وimmutable revisions والقراءات المتأخرة والخروج
والإغلاق ومنع تكرار الإرسال وفقد الرد والتصفح واللغات والـkeyboard/2x.
تحقق أنAPI لا يعود إلىmock، وأنguest/localAccess لا يمنحانAPI، وأنlegal
عام وغير منشور افتراضيًا، ولا نصوص قانونية أو دفعات أو جهات اتصال مختلقة.
قارن الأمثلة بالـmappers والمحاكاة والـsaved responses والهيدرات والتفويض.

## المراجع والفحوص

UI-03: apps/customer/Tam Cusstomer UI/WhatsApp Image 2026-11-04 at 3.02.59 PM (1).jpeg
UI-08: apps/customer/Tam Cusstomer UI/WhatsApp Image 2026-11-04 at 3.03.00 PM.jpeg
افتحهما فعليًا؛ لا مرجع كامل لنموذج التقييم أو داخل الدعم. القبول مرحلة
أولى بواجهة مبدئية سليمة؛ الصقل البصري النهائي مؤجل صراحة.

شغّل format/analyze/full tests من apps/customer، وl10n --check وdiff/JSON
من الجذر. أوامر مقارنة الصور كاملة في تسليم W2-FINAL-FEATURES؛ قارن دون
تحديث أولًا. راجع الصور الفعلية، وصرّح بأداة الرسم؛ لا عرض محاكي أوbackend
حي ضمن الأدلة الحالية. لا push/main/Actions/Android build. إذا احتجت
المحاكي بتكليف منفصل، اتبع run-emu.

## التسليم

اكتب docs/engineering/deliveries/W2-FINAL-FEATURES/REVIEW.md في فرع المراجعة:
الـSHA المفحوص، العيوب وإصلاحاتها، الفحوص والنتائج الفعلية، الصور المفتوحة،
القيود، والقرار APPROVED_AT_SHA أوCHANGES_REQUIRED. اعتماد مشروط أو غير مكتمل
لا يسجل APPROVED. إذا عدلت الكود أعد الفحوص وحدد SHA الاعتماد الجديد، وأرسل
رأس الفرع للمشرف لدمجه وفحص التكامل. لا تعتبر تقرير المشرف مراجعة مستقلة.
