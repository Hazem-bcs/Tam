# تسليم W1-SETTINGS — الوكيل E

**الحالة:** READY_FOR_REVIEW — تنفيذ ميزة معتمدة على Mock، تحتاج مراجعة مستقلة ودمجًا من المشرف فقط.

## المرجع والمساحة

- Task: `W1-SETTINGS`; role: feature developer E.
- Baseline tag: `tam-w1-baseline-2026-11-07`.
- Baseline SHA: `e570439c2593af610ed30b309c15e5cda1027da4` (تم فحص التطابق محليًا).
- Branch: `codex/w1-settings`.
- Worktree: `/home/hazem/projects/tam-w1-settings` (مستقل عن المشرف).
- Implementation/final SHA: يُؤخذ من `git rev-parse HEAD` بعد كوميت التسليم ويُرسل للمشرف مع التقرير؛ لا يُضمّن SHA ذاتي داخل الكوميت.
- GitHub target: `Hazem-bcs/Tam`؛ **تنبيه:** `origin` الموروث من مجلد `mashwar` يشير إلى `Hazem-bcs/mashwar`، لذلك أُرسل هذا الفرع حصريًا إلى URL `git@github.com:Hazem-bcs/Tam.git` دون تغيير `origin` المشترك.

## المراجع المقروءة

`AGENTS.md`، `docs/engineering/tasks/W1-SETTINGS.md`، `agent-onboarding.md`، `agent-task-template.md`، `wave-one-contracts.md`، `mock-api-policy.md`، `api-handoff-template.md`، `design-reference-index.md`، `design-system.md`، ملفات AppLocaleController / CustomerNavigation / AppTheme / AppTokens / Shared widgets / router وAuth contract. فُتحت صورة **UI-08** الأصلية بصريًا داخل worktree وتم تمييز الأجزاء خارج النطاق.

## الوظائف المملوكة المنفّذة

- `features/settings/domain/`: `SettingsProfile`، `SettingsPreferences`، تحقق الاسم (2–60 محرفًا بعد التطبيع)، فشل المجال و`SettingsRepository`، دون AuthUser.
- `data/mock/`: بيانات مستقرة ومخزن ذاكرة لنجاح/فشل القراءة وحفظ الاسم والتفضيلات؛ لا طلبات حقيقية ولا هوية موازية. `data/settings_wire_mapper.dart` لقراءة أمثلة عقد API.
- `data/api/`: `UnavailableSettingsRepository` يفشل بوضوح `SERVICE_UNAVAILABLE`؛ لا HTTP حي ولا fallback للمحاكاة.
- `settings_entry.dart`: يحتفظ بتوقيع نقطة الدخول ويحدد مصدر البيانات من `FeatureDataMode` في composition فقط. مستودع Mock يعاد استخدامه أثناء عملية التطبيق الواحدة عبر controller المحقون، لا يُخزّن في Auth.
- `presentation/`: صفحة متجاوبة مع بطاقة حساب، اسم قابل للتعديل، هاتف محقون LTR للقراءة، إشعارات الحساب المحاكية مع زر حفظ حقيقي ورفض/إعادة محاولة، اختيار لغة ar/en عبر `AppLocaleController.setLocale`، تأكيد خروج عبر callback المحقون، تحذير unsaved changes عند الرجوع/تغيير التبويب/الانتقال؛ loading/error/retry/success.
- ترجمة عربية/إنجليزية بقطع ARB المملوكة. جميع الألوان/المكونات من الثيم المركزي دون تغيير مشترك.

## الحدود المتعمدة

- **اللغة محلية وفورية فقط أثناء تشغيل التطبيق الحالي، دون استمرار بعد restart** (حسب البطاقة). لا endpoint لغة.
- الاسم والتفضيلات في Mock ذاكرة محلية تجريبية وليسا تغييرات محفوظة على خادم. عرض الهاتف من Auth فقط؛ لا تعديل هوية أو رقم أو إعادة تحقق.
- المحفظة والعناوين (UI-02) والوضع الداكن والبصمة وتغيير الرقم وحذف الحساب خارج النطاق؛ لا مفاتيح تجريبية فعالة بلا سلوك. لا Push permission أو FCM.
- `avatar_url` حقل قراءة اختياري في العقد وfixture null؛ لا واجهة اختيار/رفع صورة ولا SDK جديد. سياسة/شروط/دعم لم تُقدَّم كمحتوى قانوني مُعتمد أو كرابط فعال؛ يظهر إشعار واضح بأن البيانات تجريبية. يمكن للمشرف تكليف المحتوى القانوني والرفع لاحقًا.
- لا Android build/محاكي فعلي: لا يتم تشغيل المحاكي أثناء عمل الوكلاء بالتوازي. الصور أدناه **Flutter widget-test goldens** فعلية، وليست لقطات من جهاز Android.

## حزمة Backend

- `docs/api/settings/README.ar.md`
- `docs/api/settings/settings-v1.md` — اقتراح GET/PATCH `/me/profile` و GET/PATCH `/me/preferences`، بيانات/nullable/validation/headers/auth/errors.
- `docs/api/settings/settings-v1.postman_collection.json` — Collection v2.1 تحتوي طلبات saved responses (200/401/422/503).
- `docs/api/settings/examples/*.json` — أمثلة طلب/نجاح/أخطاء تماثل Mock وMapper.
- **ليست endpoints قائمة أو منفذة على الخادم**. ملفات JSON فُحصت parsing وبنية وأمثلة؛ **لم يُتحقق من الاستيراد في واجهة Postman ولم تُنفّذ اتصالات HTTP**.

## فحوص منفذة (من worktree، 2026-11-07)

| الأمر | النتيجة |
|---|---|
| `python3 scripts/dev/sync_feature_l10n.py` | PASS — Localization inputs are synchronized |
| `flutter gen-l10n` من `apps/customer` | PASS؛ نواتج مشتركة محليًا فقط |
| `dart format --output=none --set-exit-if-changed lib test` | PASS — 85 files, 0 changed |
| `flutter analyze --no-pub` | PASS — No issues found |
| `flutter test --no-pub` | PASS — **159 tests**, All tests passed |
| `flutter test --no-pub test/features/settings` | PASS — **23 tests** |
| `flutter test --no-pub test/features/settings/settings_page_test.dart --dart-define=CAPTURE_SETTINGS_GOLDENS=true --update-goldens` | PASS — **9 tests** (صور UI حقيقية من widget renderer) |
| Python `json.loads` على أمثلة وPostman، فحص v2.1 والـendpoints والأجسام وأخطاء ar/en | PASS |
| `git diff --check` | PASS |

صور الواجهة المنسوخة إلى:
- `screenshots/settings_ar_390.png`
- `screenshots/settings_ar_320_large.png` (خط 2x)
- `screenshots/settings_en_800.png`

الصور المقابلة المستخدمة في الاختبارات: `apps/customer/test/features/settings/goldens/`. تم فحصها بصريًا؛ حسنت بطاقة الاسم لشاشات الهاتف الصغير والخط الكبير. اختبار لقطات goldens الاختياري يستخدم خطوطًا محلية على جهاز المطوّر؛ التشغيل الافتراضي للاختبارات لا يحتاج هذه الخطوط. توثيق ربط الباكند والحفظ الدائم لاحقًا مطلوب قبل الإطلاق الفعلي.

## الملفات المشتركة والمشرف

لا تغييرات مرفوعة خارج `apps/customer/lib/features/settings/**` و`apps/customer/test/features/settings/**` و`docs/api/settings/**` و`docs/engineering/deliveries/W1-SETTINGS/**`.

قام `sync_feature_l10n.py` و`flutter gen-l10n` بتعديل `apps/customer/lib/l10n/app_*.arb` و`app_localizations*.dart` محليًا لأغراض الفحص **ولم تدخل ملفات الناتج المشترك في كوميت الوكيل**. يجب على المشرف جمع الـARB وتوليد النواتج في تكامل الفرع، ثم إعادة فحص التطبيق. لا تغييرات في Auth أو الثيم أو main أو app/router أو المجلدات الخاصة بالوكلاء الآخرين.

**المطلوب من المشرف:** مراجعة مستقلة لـSHA المرسل، ثم دمج الفرع فقط بعد قبول العقد والفحوص/الصور؛ وحسم رابط السياسة/الشروط وصورة الحساب عبر تكليف منفصل إن لزم. لا CI أو Actions أو force push ضمن تسليم هذا الوكيل.
