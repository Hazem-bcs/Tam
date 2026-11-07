# تم — تقرير إعادة تصميم واجهات المصادقة

تاريخ المراجعة: 2026-11-04. الفرع: `feat/auth-contract`.

أُعيد تصميم شاشة الهاتف والتحقق بالرمز وفق الصور المرجعية، مع الحفاظ على العمل غير الملتزم الموجود مسبقًا. بقيت التغييرات محلية، دون commit أو push أو دمج أو تشغيل GitHub Actions، ودون بناء Android جديد. استُخدم المحاكي الجاري مع Hot Reload.

## التغييرات البصرية والمقارنة مع المراجع

راجعت الصور المرجعية أولًا، ثم لقطات Flutter المرسومة فعليًا ولقطات Android بعد التعديل. المقارنة أدناه تعتمد على هذه اللقطات.

المرجعان:

- [شاشة الهاتف A](</home/hazem/projects/mashwar/apps/customer/Tam Cusstomer UI/WhatsApp Image 2026-11-04 at 3.03.00 PM (1).jpeg>)
- [شاشة التحقق B](</home/hazem/projects/mashwar/apps/customer/Tam Cusstomer UI/WhatsApp Image 2026-11-04 at 3.03.00 PM (2).jpeg>)

| العنصر | شاشة الهاتف — المرجع A والنتيجة | شاشة التحقق — المرجع B والنتيجة |
|---|---|---|
| الهوية | اسم تم/Tam أعلى المحتوى بدل الاسم القديم؛ لا توجد أصول شعار رسمية مناسبة، لذلك استُخدم اسم مكتوب مؤقت | الاسم نفسه مع زر رجوع اتجاهي، دون شعار سائق أو هوية إضافية |
| الخلفية والرسم | موجات وردية خفيفة أعلى السطح، ومسار متقطع بين علامتي موقع صغيرتين | الموجات نفسها مع رسم رسالة وعلامة تحقق بخطوط وردية رفيعة |
| التسلسل الطباعي | الهوية، عنوان ترحيب، وصف قصير، تسمية خارجية للحقل، ثم الإجراء الرئيسي | عنوان التأكيد، وصف، رقم LTR واضح، تعديل الرقم، الخانات، التأكيد، ثم إعادة الإرسال |
| الحقول | مقدمة ثابتة +963، فاصل رفيع، إدخال LTR داخل إطار مستدير؛ تسميات RTL/LTR حسب اللغة | ست خانات مستديرة ومتساوية؛ إطار أوضح للخانة النشطة وتعبئة خفيفة للخانات المكتملة |
| الأزرار | TamButton باللون العنابي من الثيم، مع رابط دخول الضيف تحته | TamButton بنفس الارتفاع والزوايا؛ إعادة الإرسال نص ثانوي مع عدّاد mm:ss |
| المسافات والمحاذاة | نموذج واضح دون بطاقة ثقيلة، بعرض مريح ومتمركز على التابلت | ست خانات في صف عند الأحجام المعتادة، مع مسافات كافية قبل التأكيد والعدّاد |
| التوازن الرأسي | الرسم صغير ليبقى الهاتف والإجراء ظاهرين في الهاتف المعتاد؛ يمكن التمرير على العرض القصير | الرسم يصغر مع المساحة الرأسية المحدودة؛ يمكن التمرير لإظهار التأكيد فوق لوحة المفاتيح |

الاختلافات المقصودة عن الصور: بقي تسجيل الدخول وإنشاء الحساب مسارًا واحدًا بلا اسم إلزامي، وبقي دخول الضيف. أُضيف تعديل الرقم وتنبيه وضع التطوير وحالات الصلاحية والمحاولات الموجودة أصلًا. العَدّاد يستخدم الموعد الوارد في التحدي، وليس قيمة الصورة 00:45. عند تكبير الخط إلى 250% على عرض 320dp تلتف الخانات الست إلى صفين من ثلاث خانات، مع ترتيب LTR وحقل منطقي واحد؛ لا يُصغّر خط النظام لفرض صف واحد.

جميع الألوان من `ColorScheme` والخطوط من `TextTheme` والمسافات من رموز التصميم الحالية. الرسوم Canvas داخل الميزة، دون صور أو حزم أو خطوط جديدة. بقيت أزرار Tam وحالات التحميل والتعطيل الأصلية، وأُضيف انتقال خفيف لتركيز الخانات يحترم تعطيل الحركة.

## الملفات التي أُنشئت أو عُدّلت في هذه المهمة

هذه القائمة تخص إعادة التصميم فقط؛ ملفات المصادقة الأخرى الموجودة مسبقًا لم تُنشأ ضمن هذه المهمة.

| الحالة | الملف | الغرض |
|---|---|---|
| جديد | [auth_artwork.dart](/home/hazem/projects/mashwar/apps/customer/lib/features/auth/presentation/widgets/auth_artwork.dart) | خلفية الموجات ورسوم المسار والرسالة |
| جديد | [auth_phone_field.dart](/home/hazem/projects/mashwar/apps/customer/lib/features/auth/presentation/widgets/auth_phone_field.dart) | مقدمة البلد الثابتة، العرض المحلي، دلالات الوصول، والحفاظ على صيغ الإدخال السابقة |
| جديد | [auth_otp_input.dart](/home/hazem/projects/mashwar/apps/customer/lib/features/auth/presentation/widgets/auth_otp_input.dart) | ست خانات مرئية وحقل إدخال أصلي واحد |
| معدّل | [auth_widgets.dart](/home/hazem/projects/mashwar/apps/customer/lib/features/auth/presentation/widgets/auth_widgets.dart) | التكوين المتجاوب والهوية والتنبيه التجريبي الهادئ |
| معدّل | [phone_auth_page.dart](/home/hazem/projects/mashwar/apps/customer/lib/features/auth/presentation/pages/phone_auth_page.dart) | حقل الهاتف الجديد وترتيب الإجراء ودخول الضيف |
| معدّل | [otp_auth_page.dart](/home/hazem/projects/mashwar/apps/customer/lib/features/auth/presentation/pages/otp_auth_page.dart) | الخانات والعدّاد وترتيب حالات الرمز |
| معدّل | [auth_status_page.dart](/home/hazem/projects/mashwar/apps/customer/lib/features/auth/presentation/pages/auth_status_page.dart) | تطبيق رسم الترويسة المتناسق على استعادة الجلسة |
| معدّل | [app_ar.arb](/home/hazem/projects/mashwar/apps/customer/lib/l10n/app_ar.arb) | وصف حقل الهاتف وإعادة الإرسال بالعربية |
| معدّل | [app_en.arb](/home/hazem/projects/mashwar/apps/customer/lib/l10n/app_en.arb) | المقابل الإنجليزي |
| مولّد مجددًا | [app_localizations.dart](/home/hazem/projects/mashwar/apps/customer/lib/l10n/app_localizations.dart) | واجهة الترجمة المولدة |
| مولّد مجددًا | [app_localizations_ar.dart](/home/hazem/projects/mashwar/apps/customer/lib/l10n/app_localizations_ar.dart) | الترجمة العربية المولدة |
| مولّد مجددًا | [app_localizations_en.dart](/home/hazem/projects/mashwar/apps/customer/lib/l10n/app_localizations_en.dart) | الترجمة الإنجليزية المولدة |
| جديد | [auth_inputs_test.dart](/home/hazem/projects/mashwar/apps/customer/test/features/auth/auth_inputs_test.dart) | 29 اختبارًا للسلوك والتجاوب والوصول وحالات الرمز |
| معدّل | [auth_flow_test.dart](/home/hazem/projects/mashwar/apps/customer/test/features/auth/auth_flow_test.dart) | تحديث تأكيد عرض الرقم عند تعديله ليتوافق مع فصل +963، مع إبقاء سيناريوهات المصادقة |
| جديد | [authentication-ui-redesign.md](/home/hazem/projects/mashwar/docs/engineering/authentication-ui-redesign.md) | هذا التقرير وقائمة الأدلة |

## الحفاظ على الوظائف

لم تتغير طبقات data أو domain أو AuthCubit أو تركيب الاعتماديات أو التوجيه أو API/Postman أو Laravel أو الاعتماديات. قورنت بصمات SHA-256 لعدد 36 ملفًا محفوظًا قبل البدء، وكانت مطابقة بعد الإنجاز. سجل المقارنة المحلي: [preserved-files.json](/home/hazem/.codex/visualizations/2026/11/04/01a1a664-bf1c-7392-8258-f7fdc11e0e8a/tam-auth-redesign/preserved-files.json).

استمرت اختبارات الدخول بالعربية والإنجليزية، الرمز الخطأ ثم تصحيحه، الخروج، استعادة الجلسة، فشل الشبكة والجلسة المنتهية، الضيف دون مستخدم أو رمز جلسة، صلاحية التحدي، منع تجاوز المحاولات، وإعادة الإرسال. تغطي اختبارات الواجهة الإضافية:

- صيغ الهاتف المحلية والدولية والأرقام العربية والفارسية؛ يبقى التطبيع الأصلي في domain كما هو، ويضيف العرض فقط +963 إلى الجزء الوطني.
- ست خانات وحقل EditableText واحد مع التركيز التلقائي ودلالات وصول قابلة للقراءة في الاتجاهين.
- اللصق عبر مسار الحافظة الأصلي في EditableText، حذف Backspace من لوحة مفاتيح خارجية، الحد الأقصى ست خانات، وبقاء الصفر الأول.
- تهيئة oneTimeCode وتحديث النص عبر قناة الإدخال لمحاكاة الملء التلقائي.
- حالات الخطأ، الانتهاء، استنفاد المحاولات، والانتظار مع منع التأكيد المكرر، ثم الانتقال إلى الدخول الناجح.
- عدّاد مدته 7 ثوانٍ مُعاد من المستودع في الاختبار لإثبات عدم تثبيت 60 ثانية في الواجهة.
- عروض 320 و360 و390 و430 و600 و840 و1024dp، والوضع الأفقي 844×390، بالعربية والإنجليزية.
- عرض 320dp وخط 250% ولوحة مفاتيح محاكاة بارتفاع 240dp، مع إمكانية إظهار زر التأكيد كاملًا دون overflow.

## الأدلة البصرية

الملفات خارج شجرة المصدر المتتبعة. لقطات Android مأخوذة من المحاكي الجاري بعد Hot Reload بخطوط النظام ولوحة مفاتيحه الفعلية. بقية اللقطات ناتجة عن رسم Widgets التطبيق نفسه في Flutter، وليست صورًا مصممة يدويًا. استُخدم خط DejaVuSans في مولّد المراجعة المؤقت خارج المشروع ليظهر النص في الاختبارات؛ لم يُضف إلى التطبيق، ولذلك تختلف أشكال الحروف عن Android.

| الحالة | المسار الكامل |
|---|---|
| هاتف عربي — Android | [android-ar-phone.png](/home/hazem/.codex/visualizations/2026/11/04/01a1a664-bf1c-7392-8258-f7fdc11e0e8a/tam-auth-redesign/android-ar-phone.png) |
| تحقق عربي — Android، إدخال جزئي يبدأ بصفر | [android-ar-otp.png](/home/hazem/.codex/visualizations/2026/11/04/01a1a664-bf1c-7392-8258-f7fdc11e0e8a/tam-auth-redesign/android-ar-otp.png) |
| تحقق مع لوحة أرقام Android مفتوحة | [android-ar-otp-keyboard.png](/home/hazem/.codex/visualizations/2026/11/04/01a1a664-bf1c-7392-8258-f7fdc11e0e8a/tam-auth-redesign/android-ar-otp-keyboard.png) |
| إدخال جزئي مع لوحة Android مفتوحة | [android-ar-otp-partial-keyboard.png](/home/hazem/.codex/visualizations/2026/11/04/01a1a664-bf1c-7392-8258-f7fdc11e0e8a/tam-auth-redesign/android-ar-otp-partial-keyboard.png) |
| هاتف عربي 390×844 | [ar-phone.png](/home/hazem/.codex/visualizations/2026/11/04/01a1a664-bf1c-7392-8258-f7fdc11e0e8a/tam-auth-redesign/ar-phone.png) |
| تحقق عربي 390×844 | [ar-otp.png](/home/hazem/.codex/visualizations/2026/11/04/01a1a664-bf1c-7392-8258-f7fdc11e0e8a/tam-auth-redesign/ar-otp.png) |
| هاتف إنجليزي 390×844 | [en-phone.png](/home/hazem/.codex/visualizations/2026/11/04/01a1a664-bf1c-7392-8258-f7fdc11e0e8a/tam-auth-redesign/en-phone.png) |
| تحقق إنجليزي 390×844 | [en-otp.png](/home/hazem/.codex/visualizations/2026/11/04/01a1a664-bf1c-7392-8258-f7fdc11e0e8a/tam-auth-redesign/en-otp.png) |
| هاتف صغير 320×700 | [small-phone.png](/home/hazem/.codex/visualizations/2026/11/04/01a1a664-bf1c-7392-8258-f7fdc11e0e8a/tam-auth-redesign/small-phone.png) |
| تحقق صغير 320×700، موضع التمرير بعد التركيز | [small-otp.png](/home/hazem/.codex/visualizations/2026/11/04/01a1a664-bf1c-7392-8258-f7fdc11e0e8a/tam-auth-redesign/small-otp.png) |
| هاتف تابلت 840×1100 | [tablet-phone.png](/home/hazem/.codex/visualizations/2026/11/04/01a1a664-bf1c-7392-8258-f7fdc11e0e8a/tam-auth-redesign/tablet-phone.png) |
| تحقق تابلت 840×1100 | [tablet-otp.png](/home/hazem/.codex/visualizations/2026/11/04/01a1a664-bf1c-7392-8258-f7fdc11e0e8a/tam-auth-redesign/tablet-otp.png) |
| تحقق مع حجز مساحة لوحة مفاتيح 300dp — محاكاة | [keyboard-otp.png](/home/hazem/.codex/visualizations/2026/11/04/01a1a664-bf1c-7392-8258-f7fdc11e0e8a/tam-auth-redesign/keyboard-otp.png) |
| أفقي — أعلى شاشة التحقق | [landscape-otp-top.png](/home/hazem/.codex/visualizations/2026/11/04/01a1a664-bf1c-7392-8258-f7fdc11e0e8a/tam-auth-redesign/landscape-otp-top.png) |
| أفقي — بعد التمرير إلى التأكيد | [landscape-otp.png](/home/hazem/.codex/visualizations/2026/11/04/01a1a664-bf1c-7392-8258-f7fdc11e0e8a/tam-auth-redesign/landscape-otp.png) |
| خط 250% — الخانات الست ملتفة | [large-text-otp-input.png](/home/hazem/.codex/visualizations/2026/11/04/01a1a664-bf1c-7392-8258-f7fdc11e0e8a/tam-auth-redesign/large-text-otp-input.png) |
| خط 250% — بعد التمرير إلى التأكيد | [large-text-otp.png](/home/hazem/.codex/visualizations/2026/11/04/01a1a664-bf1c-7392-8258-f7fdc11e0e8a/tam-auth-redesign/large-text-otp.png) |
| رمز جزئي وتركيز | [state-partial.png](/home/hazem/.codex/visualizations/2026/11/04/01a1a664-bf1c-7392-8258-f7fdc11e0e8a/tam-auth-redesign/state-partial.png) |
| رمز مكتمل | [state-complete.png](/home/hazem/.codex/visualizations/2026/11/04/01a1a664-bf1c-7392-8258-f7fdc11e0e8a/tam-auth-redesign/state-complete.png) |
| رمز غير صحيح | [state-invalid.png](/home/hazem/.codex/visualizations/2026/11/04/01a1a664-bf1c-7392-8258-f7fdc11e0e8a/tam-auth-redesign/state-invalid.png) |
| انتظار التحقق | [state-loading.png](/home/hazem/.codex/visualizations/2026/11/04/01a1a664-bf1c-7392-8258-f7fdc11e0e8a/tam-auth-redesign/state-loading.png) |
| استنفاد المحاولات | [state-blocked.png](/home/hazem/.codex/visualizations/2026/11/04/01a1a664-bf1c-7392-8258-f7fdc11e0e8a/tam-auth-redesign/state-blocked.png) |
| انتهاء الصلاحية | [state-expired.png](/home/hazem/.codex/visualizations/2026/11/04/01a1a664-bf1c-7392-8258-f7fdc11e0e8a/tam-auth-redesign/state-expired.png) |

راجعت اللقطات الواردة أعلاه بصريًا. في الأفقي والخط الكبير لا تظهر كل الشاشة دفعة واحدة؛ التمرير مقصود ويحافظ على حجم الخط وإمكانية الوصول إلى الإجراءات. على التابلت يبلغ حد الحاوية 480dp، وعرض الحقول الأقصى 432dp بعد الهوامش.

## أوامر التحقق والنتائج

من `/home/hazem/projects/mashwar/apps/customer`:

```bash
flutter gen-l10n
dart format lib/features/auth/presentation test/features/auth
flutter test --no-pub test/features/auth/auth_inputs_test.dart -r expanded
dart format --output=none --set-exit-if-changed lib test
flutter analyze --no-pub
flutter test --no-pub
```

- توليد الترجمات والتنسيق: نجحا؛ الفحص النهائي نسّق 50 ملفًا دون تغييرات.
- اختبارات الإدخال الإضافية: 29 اختبارًا ناجحًا.
- التحليل: `No issues found!`.
- مجموعة اختبارات التطبيق الكاملة: **80 اختبارًا ناجحًا**، بما فيها الاختبارات الموجودة سابقًا.
- `git diff --check` من جذر المستودع: نجح.
- فحص بصمات الملفات المحمية: 36 ملفًا مطابقًا، صفر تغييرات.

مولّدات اللقطات المؤقتة شُغّلت بعد ذلك خارج شجرة المصدر:

```bash
flutter test --no-pub /tmp/tam_auth_redesign_preview_test.dart /tmp/tam_auth_redesign_responsive_preview_test.dart -r expanded
flutter test --no-pub /tmp/tam_auth_redesign_states_preview_test.dart -r expanded
```

النتيجة النهائية: نجح اختبارا اللقطات العامة والمتجاوبة، ونجح اختبار لقطات الحالات. هذه المولّدات للمراجعة المحلية، وليست اختبارات golden مثبتة في المستودع.

## القيود المتبقية

- اسم تم/Tam المكتوب معالجة هوية مؤقتة إلى أن يتوفر أصل الشعار الرسمي.
- المصادقة ما زالت FakeAuthRepository وفق العمل السابق؛ لا توجد رسائل SMS حقيقية أو خدمة Backend موصولة ضمن هذه المهمة.
- اختُبر عقد الإدخال الخاص بالملء التلقائي في Widget tests، ولم تُجرَّب رسالة SMS حقيقية. دلالات الوصول مُتحقق منها بالاختبارات؛ لم تُنفّذ جلسة TalkBack صوتية أو اختبار iOS على جهاز فعلي.
- لقطات الاختبارات تستخدم خط مراجعة مؤقتًا؛ لقطات Android توضح شكل الخط الفعلي على المحاكي. لا تحتوي اللقطات العامة على بيانات دخول حقيقية.
- صور المراجعة خارج المستودع ومحلية لهذه الآلة؛ لن تنتقل تلقائيًا عبر Git.
