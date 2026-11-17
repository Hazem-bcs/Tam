# التقييم المدمج وبيانات المعاينة

Task AUI-06-INLINE-RATING-20261117، root مشرف ومنفذ، أساس53ee590، فرع ahmad-ui، READY_FOR_REVIEW.

## النتيجة

التقييم ضمن تفاصيل الطلب المكتمل، باستخدام CompletionCubit/CompletionRatingForm وعقد CompletionRepository نفسيهما، دون ملخص ثانٍ أو صفحة إضافية. مسار completion القديم يعيد التوجيه إلى تفاصيل الرحلة، بما يشمل الوصول من الرحلة النشطة والروابط القديمة. حُذف زر «اطلب مجددًا» ورابط صفحة التقييم، وبقي الدعم والإلغاء/المتابعة للحالات المناسبة.

استجابة لتعليق المستخدم التالي: صار رسم النجم28dp بدل43dp تقريبًا، بينما مساحة كل فعل48dp. خيارات الانطباعات أصبحت FilterChip مستديرة تتسع للنص وتلتف، بأيقونات account/ride_completed/rating أو ride_scheduled/warning/support الموجودة. الاختيار يظهر بعلامة صح والثيم، مع دعم لوحة المفاتيح والدلالات وتعطيل الإرسال. صُغرت العناوين والمسافات وحقل التعليق إلى سطرين، مع قابلية التمرير والنص الكبير دون قص.

## البيانات التجريبية والعزل

أضيف TripReceipt اختياري إلى نموذج الرحلة ويحافظ عليه withStatus/withLive، لعرض حقائق المسافة والمدة والأجرة قبل الخصم والخصم والتسديد. لا يستنتج أي منها من حالة الرحلة. يختار app composition فقط سيناريو seedMockTrips(includeReceiptPreview:true)، ويظل seedMockTrips() الافتراضي مطابقًا لأمثلة عقود API الحالية واختباراتها.

المعاينة mock-history-001: محمد أحمد، كيا سيراتو بيضاء، لوحة12345، تقييم4.9، مسافة7.8كم و18دقيقة، أصل الأجرة30000ل.س وخصم5000، إجمالي25000 نقدًا ومدفوع في **المحاكاة فقط**. توضيح المحاكاة ظاهر. لا تغيير لعقود HTTP أو تنفيذ دفع حقيقي؛ receipt غير موصول بcodec الشبكة الحالي. استكمال إيصال backend يحتاج توسعة عقد ونقل مستقلة. وضع API لا يتحول إلى Mock.

التقييم يبقى محليًا في مستودع الجلسة بنفس قواعد عدم التكرار/idempotency والفشل وإعادة المحاولة وإنهاء الجلسة. لم يُغيّر Auth أو منح صلاحيات لضيف. Hot Restart لتحميل السيناريو أعاد ضبط الجلسة المحلية، وأُبلغ المستخدم بذلك قبل التشغيل.

## التحقق

من apps/customer:
- `flutter test --no-pub test/features/trips/trip_details_receipt_test.dart test/features/trips/trip_details_premium_preview_test.dart test/features/trips/trips_cubit_test.dart test/features/trips/trips_repository_test.dart test/features/completion test/features/trips/trip_inline_rating_test.dart test/features/trips/trip_completion_layout_test.dart`: **81 نجاحًا** على التغيير النهائي. يشمل التقييم المدمج دون ملخص/إعادة طلب، حفظ نفس tripId ومنع التكرار، عقود fixtures الأصلية، أخطاء التقييم/انقطاعه/session reset، RTL/LTR والنص2x والهاتف والتابلت والأفقي والكيبورد، وشرائح الانطباعات بدون overflow مع لمس48dp.
- `flutter analyze --no-pub lib/features/completion/presentation/widgets lib/features/trips lib/shared/domain/trip.dart lib/shared/data/mock/seed_trips.dart lib/app/app.dart lib/app/router/app_router.dart`: بلا ملاحظات.
- تنسيق الملفات الملموسة وgit diff --check ناجحان.
- Hot Restart وHot Reload على emulator-5554 نجحا. مراجعة native لبيانات الإيصال `/tmp/aui-inline-details.png`، والتقييم المدمج قبل التصغير `/tmp/aui-inline-rating-final.png`، وبعده `/tmp/aui-compact-rating-final.png` و`/tmp/aui-compact-tags.png`. اختبار تفاعلي native لاختيار النجوم فقط دون إرسال تقييم. اختبارات الحفظ كانت في test mocks المعزولة.

لا بناءAPK جديد في هذه الدفعة، ولا إعادة للفحص الشامل للتطبيق؛ نتائج AUI-03 الشاملة وإخفاقات goldens نشاطي غير الملموسة ما تزال حدودًا موثقة، وليست نجاح إصدار. لا push/merge إلىmain/CI. كود صفحة Completion القديمة باقٍ للاختبارات والتوافق الداخلي، لكنه لم يعد واجهة يفتحها الراوتر.
