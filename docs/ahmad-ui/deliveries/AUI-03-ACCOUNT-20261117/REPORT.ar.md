# حسابي — Ahmad UI

أساس التنفيذ: `873853a`؛ الفرع `ahmad-ui`، root مشرف ومنفذ. الحالة READY_FOR_REVIEW، وليست اعتماد إصدار.

أعيد ترتيب الحساب وفق UI-08: بطاقة هوية وردية مع تعديل الاسم، بطاقة المحفظة، العناوين وإرشادات الكوبون وتغيير الهاتف، تفضيلات الإشعارات واللغة، الدعم والوثائق، حذف الحساب وتسجيل الخروج. أعيد استخدام صور account/wallet/address_pin/discount_offer/notification_bell/support/information/security/warning الموجودة. لا توليد صور جديد ولا تغيير Auth أو Domain/Data أو التوجيه أو main.

المحفظة تعرض «الرصيد غير متاح حاليًا»؛ لا يوجد مصدر لرصيد الحساب في العقد الحالي. الكوبون يشرح الإدخال في الحجز ولا يدعي وجود عرض مفعّل. لم نضف مفاتيح شكلية للموقع أو الوضع الداكن؛ ليست وظائف متوفرة حاليًا. وضع Settings الحالي ومحدودية محاكاة الاسم والإشعارات كما قبل التعديل، مع إبقاء إفصاح النسخة.

## التحقق

من apps/customer:
- `flutter test --no-pub test/features/settings/settings_page_test.dart test/features/settings/settings_navigation_test.dart test/features/settings/settings_concurrency_test.dart`: **27 نجاحًا**. يشمل التعديل والحفظ والفشل، الإشعارات، تغيير اللغة، إرشادات الكوبون، الرجوع، 320dp/800dp والنص الكبير ولوحة المفاتيح.
- `flutter analyze --no-pub lib/features/settings/presentation`: بلا ملاحظات.
- `dart format --output=none --set-exit-if-changed lib test`: أبلغ عن 5 ملفات active_trip تحتاج تنسيقًا؛ لم نغيّرها. الملفات الملموسة منسقة.
- `flutter analyze --no-pub`: 45 ملاحظة خارج Settings؛ لا نعتمد الفحص الشامل ناجحًا.
- `flutter test --no-pub`: **819 نجاحًا و46 إخفاقًا**؛ تشمل اختبارات قديمة لتصميم Auth/التميمة وتوقعات عرض الهاتف في Home ومسارات الرحلات. لم نجزم بأنها كلها سابقة دون تشغيل baseline كامل، ولم نوسّع المهمة لإصلاحها. السجل `/tmp/aui-account-full-tests.log`.
- `git diff --check`: ناجح.

Hot Reload على emulator-5554 نجح. فُحص العرض العربي الأصلي أعلى وأسفل الصفحة في `/tmp/aui-account.png` و`/tmp/aui-account-bottom.png`؛ لم تُضف صور تحتوي رقم الجلسة إلى المستودع. فحص الهاتف والتابلت والنص الكبير الإضافي عبر widget tests، وليس جهازًا فعليًا. لا بناء APK جديد؛ التعديل معروض في جلسة Flutter الجارية.

ملف الصفحة أصبح 318 سطرًا بسبب بقاء تأكيدات الخروج/المسودات والتنسيق الحالي؛ الأقسام البصرية منفصلة. لا refactor خارج النطاق لتلبية عدد سطور شكلي.

لا push أو merge إلى main أو تشغيل CI. التقييم المستقل والتثبيت النهائي للتصميم ما زالا للمراجعة.
