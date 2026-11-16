# TAM-ACTIVITY-FILTER-314F1B3

INTEGRATED؛ root بدور SUPERVISOR/DEVELOPER/QA.
الأساس 4a650909502ee04a9379025372fc530aa1f72e15؛ الفرع codex/activity-filter-314f1b3.
المصدر 314f1b3f524cf50a1c576d8612cc82ed934b381a من clone مستقل /home/hazem/projects/tam-platform.
طلب المستخدم نقل صفحة نشاطي والفلتر فقط دون إرجاع أي صفحات أخرى.

المقارنة: diff الكوميت وحده يغير ملفين، لكنه مبني على تصميم نشاطي أحدث
غائب عن النسخة الحالية. لذلك تُستخرج لقطة ملفات الصفحة السبعة عند314f1b3
دون دمج main الآخر أو نسخ feature كامل. يلزم helper خط AppTheme.activity
المركزي فقط (4 أسطر إضافية)، دون تعديل أي builder أو palette موجود.

الملكية: ملفات trips/presentation السبعة الموضحة في التقرير، واختباراتها
وصورها واختبار لون شريط النظام؛ helper الخط المضاف فقط؛ هذه البطاقة والتقرير
واللوحة. لا تعديل Home/Auth/Settings/Addresses/Notifications/Maps أو assets
أو ARB أو Domain/Data/API. المحاكاة وسياسة الدخول والتنقل ثابتة.

التحقق: مقارنة بقية apps/customer بالأساس حرفيًا؛ إعدادات الثيم القديمة
لا تتغير عند إضافة helper خاص بطلب الصفحة. اختيار فلتر/إغلاق بلا اختيار،
هاتف/تابلت/RTL/LTR/2x؛ صور فعلية؛ format/analyze وtests لميزة Trips مرة
عند التسليم. لا إعادة كامل اختبارات baseline الفاشلة بلا سبب. لا push/Actions.

النتيجة: نقل7 ملفات UI تطابق314، وإضافة helper فقط؛ بقية الصفحات تطابق4a65090.
48 اختبارًا ناجحًا وتحليل نظيف وتنسيق455/0، وتحديث التطبيق القائم.
التقرير في deliveries/TAM-ACTIVITY-FILTER-314F1B3/REPORT.ar.md.
