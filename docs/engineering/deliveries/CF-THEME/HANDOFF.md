# CF-THEME — F07 implementation handoff

Task / role: CF-THEME / DEVELOPER. READY_FOR_REVIEW.
Input: `1b8890049177b56b3ce8e2c0254b622defa95bbf`.
Branch: `codex/customer-feedback-theme-20261118`.
Worktree: `/home/hazem/.codex/worktrees/customer-feedback-theme/mashwar`.
Implementation identity: commit containing this handoff (exact SHA sent to supervisor).

## النتيجة المرئية والسلوك

- نظام مركزي أخف للنص، مع عناوين وقراءة أصغر قليلًا، وإبقاء أهداف اللمس كما هي. توحد مداخل account/rideJourney مع السلم المشترك بدل إعادة تثبيت أحجام متفرقة.
- المظهر فاتح أو داكن أو حسب الجهاز (الافتراضي)، مع ألوان foreground/background/status ومناطق الخريطة الداكنة. كل مداخل AppTheme تحترم brightness المحيط؛ الرحلة لا تجبر الفاتح.
- من الإعدادات: حجم النص صغير 0.90، افتراضي 1.00، كبير 1.15، كبير جدًا 1.30. يُطبّق العامل بعد TextScaler الخاص بالجهاز دون استبدال منطقه غير الخطي أو فرض سقف للتكبير.
- اللغة الافتراضية العربية حتى على جهاز إنجليزي؛ حفظ اختيار العربية/الإنجليزية والمظهر وحجم النص بين مرات التشغيل. تبقى هذه تفضيلات محلية مستقلة عن الحساب والخروج، ولا تمنح جلسة أو صلاحية.
- تحميل وكتابة متسلسلان لحماية التغييرات السريعة؛ فشل الحفظ يعيد الاختيار السابق ويظهر الخطأ، وفشل الاستعادة يعرض إعادة المحاولة. القيم التالفة تعود للقيمة الافتراضية لكل حقل دون إتلاف الحقول السليمة.

## التخزين والترحيل

يستخدم CachedAppPreferencesRepository عقد LocalCacheStore الحالي/SQLite، بمفتاح `app.preferences` وإصدار payload 2. الإصدارات السابقة في baseline كانت تحفظ اللغة ضمن الذاكرة فقط؛ ليس هناك تفضيل لغة دائم معروف يُمحى أو يستبدل. يدعم القارئ أيضًا شكل v1 المحتمل (`locale`, `themeMode`, `textScale`) ويحفظ الاختيارات الصحيحة وحقول metadata غير المعروفة عند الكتابة. لا يحذف المفتاح القديم ولا يمس إشعارات الحساب أو صورته أو مفاتيح الرحلات. لا endpoints جديدة ولا حزمة إضافية.

## الملفات والتكامل المطلوب

الملكية المعدلة: app.dart، app/locale، app/theme، app/preferences الجديدة، settings_preferences_section/settings_language_sheet/settings_page، settings_appearance_preferences الجديدة، شظايا ARB للإعدادات والاختبارات المطابقة. لا تعديل ملفات coupon أو settings_profile_section أو Auth أو router.

على المشرف تسجيل `AppPreferencesRepository` في app/di/service_locator.dart:

```dart
import 'package:tam_customer/app/preferences/app_preferences.dart';
import 'package:tam_customer/app/preferences/cached_app_preferences_repository.dart';

locator.registerLazySingleton<AppPreferencesRepository>(
  () => CachedAppPreferencesRepository(locator<LocalCacheStore>()),
);
```

TamApp يقبل preferencesRepository لاختبارات التكامل. دون التسجيل/الحقن يستخدم تفضيلات الذاكرة فقط، لذا تسجيل DI شرط التكامل. طلب التغيير أُرسل للمشرف ووافق عليه. الترجمة المولدة متاحة محليًا للفحص ولم تُضم إلى الكوميت؛ المشرف ينفذ sync_feature_l10n.py ثم flutter gen-l10n عند التجميع.

app.dart وsettings_page.dart كانا فوق الإرشاد 300 سطر أصلًا؛ أبقيت دورة حياة التطبيق/الصفحة في موضعها وأضفت فقط الربط الضروري بدل إعادة هيكلة خارج الطلب. المنطق والتخزين والخيارات الجديدة في ملفات مستقلة صغيرة.

## التحقق الفعلي

من apps/customer، Flutter/Dart المثبتان محليًا، مع إعادة استخدام .dart_tool من نسخة ahmad-ui (ملفات مهملة، غير مضمنة):

- `flutter gen-l10n`: نجح من apps/customer. محاولات سابقة من جذر المستودع رُفضت بسبب عدم وجود pubspec Flutter في ذلك الموضع.
- `dart format` للملفات الملموسة: نجح.
- `flutter test --no-pub --dart-define=CAPTURE_PREFERENCES=true test/app/preferences --timeout 30s`: **11 اختبارًا ناجحًا**، تشمل الاستعادة/الترحيل/البيانات التالفة/فشل القراءة والكتابة/الاختيارات المتتابعة، non-linear scaler، تباين الألوان الداكنة ومداخل الثيم ومناطق الخريطة، وتغير ثيم الجهاز وتجاوب الخيارات والصفائح.
- أُصلح خطأ generic inference ظهر في أول تجميع. عُلّق fixture التقاط الصورة أولًا ثم أُصلح بوضع عمليات الرسم في tester.runAsync؛ نجحت دفعة 11 اختبارًا بعدها. أُعيد اختبار الحالتين المرئيتين فقط بعد تحميل خط MaterialIcons لتحسين دليل الصور: **2 ناجحان**.
- فحص `dart analyze` المركّز النهائي لكل الملفات المعدلة في المنتج واختبارات التفضيلات: **No issues found!**. أُصلحت info سابقة (getter deprecated وترتيب imports وأقواس if). فحص التنسيق النهائي: 18 ملفًا دون تغيير.
- فحص `test/app/feature_foundation_test.dart`: **5 من 6 ناجحة**؛ اختبار تبديل اللغة ينجح في بقاء route وAuthCubit phone واللغة، ثم يفشل بتوقع نص رقم الهاتف في Home. المشرف أكد أن غياب رقم الهاتف قائم في Home؛ لم أغير الاختبار/الميزة خارج الملكية.
- `git diff --check`: نجح.
- لم أُشغّل full suite أو build أو محاكي؛ فحوص milestone الشاملة وAndroid/QA بعد الدمج من مسؤولية المشرف.

## الدليل المرئي والحدود

فُحصت الصورتان فعليًا باستخدام view_image:

- `evidence/preferences-ar.png`: renderer اختبارات Flutter، عربية RTL، 320×700، داكن، تكبير جهاز 2×. النصان والاختياران والأيقونات ظاهرة دون قص.
- `evidence/preferences-en.png`: renderer اختبارات Flutter، إنجليزية LTR، 800×900، فاتح، تكبير 1×، عرض المحتوى محدود 560dp.

حُمّلت خطوط TamSansArabic/TamSansLatin المرفقة وMaterialIcons. هذا دليل لعنصري التفضيلات وليس شهادة device أو مراجعة كل الصفحات. باقي الصفحات وثيماتها والكيبورد/التكبير الشديد والاتجاه الأفقي وتباين الأصول المصورة تحتاج QA التكامل. المشرف يتولى شريط النظام في Auth/Home ومراجعة توافق بقية الميزات مع الداكن. لا يدعي هذا التسليم اكتمال الاعتماد البصري النهائي أو جاهزية إصدار إنتاجي.

البيانات الحالية mock كالسابق، دون تغيير Auth/guest/localAccess/TEMPORARY_PHONE_ENTRY. لا push ولا دمج main ولا Actions.
