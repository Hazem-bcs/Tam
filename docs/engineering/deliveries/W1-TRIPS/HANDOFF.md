# W1-TRIPS — تقرير التسليم للمشرف

**المهمة:** W1-TRIPS / الوكيل C / `Tam | تم`
**المرجع:** `tam-w1-baseline-2026-11-07` = `e570439c2593af610ed30b309c15e5cda1027da4` (تحقق محليًا).
**فرع التنفيذ:** `codex/w1-trips`، **worktree:** `/home/hazem/projects/tam-w1-trips`.
**SHA التسليم:** يُسجل بعد إنشاء الكوميت في تقرير المحادثة أو بواسطة `git rev-parse codex/w1-trips`؛ لا يمكن تضمين SHA الكوميت نفسه في محتواه دون تغييره.
**الحالة:** تسليم تطوير للمراجعة المستقلة، وليست موافقة إنتاج.

## الاستلام والمراجع

- قرأت `AGENTS.md`، `docs/engineering/tasks/W1-TRIPS.md`، `agent-onboarding.md`، `agent-task-template.md`، `wave-one-contracts.md`، `mock-api-policy.md`، `api-handoff-template.md`، `parallel-work.md`، `working-agreement.md`، `dart-code-organization.md`، `navigation.md`، `design-system.md`، وADR المعمارية؛ راجعت لوحة المهام.
- شاهدت فعليًا UI-01 (قائمة نشاط العميل) وUI-03 (تفاصيل طلب العميل، صفحتان) من ملفات JPEG داخل `apps/customer/Tam Cusstomer UI/`. لم أستخدم UI-18/19 الخاصة بالسائق.
- Flutter وDart وGit وأدوات قراءة الصور متاحة على حاسوب ASUS ROG. لم أشغّل المحاكي أو Android build أو GitHub Actions.

## النتيجة المرئية والسلوك

- شاشة «طلباتي»: all/active/completed/cancelled، صفحات cursor بحد 20، pull-to-refresh، تحميل المزيد، الفراغ، الفشل، retry؛ دون تكرار سجلات بعد دمج صفحات أو إعادة التحميل.
- شاشة التفاصيل: معرّف رحلة مباشر عبر `tripId`، حالة وموقعا الانطلاق والوصول وأجرة الرحلة وفئتها وتاريخ إنشائها؛ not-found يعرض طريق عودة واضح.
- إلغاء بإقرار صريح للحالات `requested/confirmed` فقط؛ أخطاء الإلغاء domain failures، والإلغاء المتكرر في store idempotent. تعرض القائمة والتفاصيل تحديث المخزن المشترك تلقائيًا.
- «اطلب مجددًا» يمرّر `TripPrefill(pickup,destination)` إلى `CustomerNavigation.openRideRequest`؛ لا ينشئ رحلة ثانية، ولا ينقل السعر القديم أو تأكيدًا.
- `TripsRepository` في domain؛ `MockTripsRepository` إسقاطات وstream changes فوق **نفس** `MockTripStore` المحقون من التطبيق، دون قائمة runtime موازية. وضع API غير الجاهز يستعمل `UnavailableTripsRepository` بخطأ `SERVICE_UNAVAILABLE`، دون mock fallback أو fake Auth.
- `TripWireCodec` لحقول JSON المقترحة مع تحقق للأنواع، الحالة، التاريخ UTC، المال بوحدات صحيحة، والمواقع. محاكاة seed من المشترَك فقط.
- العربية RTL والإنجليزية LTR عبر fragment ARB المملوكين للميزة؛ مكونات `TamCard` و`TamButton` والتصميم المركزي. معظم الملفات الجديدة أقل من 300 سطر.

## الملفات المسلّمة

- `apps/customer/lib/features/trips/**`: domain/data(mock,unavailable API,wire codec)/presentation/entry/l10n.
- `apps/customer/test/features/trips/**`: اختبارات repository، Cubits، Widget.
- `docs/api/trips/README.ar.md` و`trips-v1.md` و`trips-v1.postman_collection.json` (Postman v2.1) و`examples/*.json`: **13 مثال JSON**، **4 requests**، **15 saved responses**.
- `docs/engineering/deliveries/W1-TRIPS/screenshots/trips-list-ar-390.png` و`trip-details-ar-390.png`، وهذا الملف.

## التحقق الذي نُفّذ على جهاز المستخدم

الأوامر من worktree المستقل، بعد `flutter pub get --offline` بنجاح:

| الأمر | النتيجة |
|---|---|
| `python3 scripts/dev/sync_feature_l10n.py` | OK |
| `flutter gen-l10n` من `apps/customer` | OK |
| `dart format --output=none --set-exit-if-changed lib test` | OK، 85 ملفًا دون تغيير |
| `flutter analyze --no-pub` | OK، **No issues found** |
| `flutter test --no-pub` | OK، **162 tests passed** |
| `git diff --check` | OK |
| Python JSON parse + Postman structural check | OK: 13 examples / 4 requests / 15 saved response bodies |
| Flutter domain parsing tests | OK: أمثلة Trip/الأخطاء والصفحات |
| Test widgets | OK: 320×700 Arabic x2، 390×844 Arabic x1، 800×980 English x2، 800×360 English x1؛ القائمة والتفاصيل |

لم أستورد مجموعة Postman فعليًا في تطبيق Postman ولم أرسل HTTP لخادم حي؛ فحصتها كـJSON صالح وبنيتها وأمثلتها. لم أختبر محاكي Android أو جهازًا حقيقيًا، واختبارات العرض ليست قياس أداء إنتاج.

## الأدلة البصرية وحدودها

- `screenshots/trips-list-ar-390.png`: القائمة بالعربية 390×844.
- `screenshots/trip-details-ar-390.png`: التفاصيل بالعربية 390×844.
- الصورتان التُقطتا من واجهات Flutter الحقيقية داخل test renderer، بتحميل خطوط عربية ولاتينية وأيقونات محليًا خصيصًا للمعاينة. **ليستا لقطتين من Android emulator**.
- أداة الالتقاط المؤقتة أنتجت ملفات PNG الصالحة، لكن اختبار الالتقاط الاختياري توقف عند محاولة ضخ/تفريغ إطار آخر (`flutter_tester` timeout)، لذلك استُبعد harness المؤقت من الاختبارات الملتزم بها. صور PNG فُحصت بصريًا؛ لم يُسجّل اختبار الالتقاط بوصفه ناجحًا.

## قيود وطلبات للمشرف

- **لا يوجد backend حي**؛ `docs/api/trips/` عقد **مقترح** للباكند، وليس endpoints منفذة. لا مدفوعات أو خرائط حقيقية أو بيانات سائق أو ETA أو إشعارات مباشرة هنا.
- ملفات `apps/customer/lib/l10n/app_*.arb` و`app_localizations*.dart` تلوثت **محليًا بالتوليد** فقط؛ **غير مضمنة في الكوميت**. على المشرف إعادة تشغيل sync/gen-l10n ضمن فرع التكامل وضم مشتقات الترجمة المشتركة.
- لا تعديل لـAuth أو ride_request أو app/router أو shared أو pubspec أو ملفات المشرف. لا merge إلى main ولا تشغيل Actions.
- عند تنفيذ API الحقيقي: تحقق من Auth/ownership 401/403، سياسة cursor أثناء إدراج رحلات متزامنة، أخطاء الشبكة، session expiry، وتوحيد أكواد B وAuth. أي تعديل للعقد المشترك ينسقه المشرف.
- يحتاج الكود مراجعة مستقلة على SHA النهائي واختبار تكامل بعد دمج ملفات الوكلاء؛ لا يعتمد مالك الميزة عمله بنفسه.

**الحكم:** `READY_FOR_REVIEW` بعد إثبات رفع فرع `codex/w1-trips` فقط وذكر SHA النهائي في رسالة التسليم.
