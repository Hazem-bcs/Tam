# حركة التقييم وترتيب الإجراءات

root مشرف ومنفذ، ahmad-ui، قاعدة التكامل الحالية ed908ee، READY_FOR_REVIEW. حُفظت كوميتات الكوبونات المتقدمة من وكلاء آخرين كما هي؛ لا دمج main أو push أو CI.

تظهر النجوم بتدرج خفيف من الأسفل مع تلاشي وتكبير خلال720ms، بفارق زمني بين النجوم. تبدأ الحركة عند وصول القسم إلى مساحة العرض، مرة واحدة، وليس أثناء بناء الصفحة خارج الشاشة. عند تفعيل تقليل الحركة تظهر مباشرة. يُتخلّص من متحكمات الحركة ومستمعي التمرير عند إزالة القسم.

زر الإرسال رئيسي، وبجانبه دعم بإطار وأيقونتنا بنسبة2:1 عند توفر300dp ونص أقل من1.4x؛ يتحولان إلى ترتيب عمودي في العرض الضيق/النص الكبير. يبقى الدعم داخل القسم بعد حفظ التقييم وعند فشل تحميله؛ لا زر دعم ثانٍ أسفل التفاصيل. حالات التعطيل والحفظ وعدم تكرار التقييم باقية.

من الطلب السابق: استُخدمت صورة السائق الاصطناعية الموجودة بدل الأيقونة في رحلة المعاينة فقط. أُخرج DriverAvatar إلى shared لإعادة استخدام نفس السلوك في الرحلة النشطة والتفاصيل. أُلغيت النافذة الجديدة للسائق وقابلية فتحها بناء على تراجع المستخدم؛ نافذة الرحلة النشطة الموجودة أصلًا لم تتغير وظيفيًا. لا صورة مختلقة لمستخدم حقيقي.

## التحقق

- `flutter test --no-pub test/features/completion test/features/trips/trip_inline_rating_test.dart test/features/trips/trip_completion_layout_test.dart`: **66 نجاحًا**، السجل `/tmp/tam-rating-motion-final-tests.log`. يشمل اختبارين للحركة عند التمرير وتقليل الحركة والتخلص من الموارد، إضافة إلى حفظ التقييم وعدم تكراره وحالات الفشل واللغة والنص الكبير والشاشات الصغيرة/الأفقية.
- `flutter analyze --no-pub lib/features/completion/presentation/widgets lib/features/trips lib/shared/widgets/driver_avatar.dart lib/features/active_trip/presentation/widgets/active_driver_card.dart lib/features/active_trip/presentation/widgets/active_driver_details_sheet.dart`: بلا ملاحظات، السجل `/tmp/tam-rating-motion-final-analyze.log`.
- الملفات الملموسة منسقة وgit diff --check ناجح.
- `flutter run --debug --no-pub -d emulator-5554`: debugAPK بُني وثُبّت، ثم Hot Reload للنسخة النهائية؛ `/tmp/tam-rating-motion-run.log`.
- الفحص الشامل للتطبيق لم يُكرر؛ قيوده المعروفة موثقة في التقارير السابقة. لا ادعاء بجاهزية الإصدار.

التغيير UI؛ التقييم يبقى محليًا في وضع التطوير، ولا تغيير في عقد API أو Auth أو الدفع.
