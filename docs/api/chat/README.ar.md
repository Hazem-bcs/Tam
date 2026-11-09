# محادثة تم — تسليم الباكند v1

حزمة مرحلة أولى لعقد مقترح، بتاريخ 2026-11-09. لا backend حي ولا إرسال لسائق فعلي.
تنفيذ Flutter الحالي mock معزول، وAPI mode يعيد SERVICE_UNAVAILABLE دون fallback.
لا تغير المصادقة أو temporary localAccess؛ تلك الجلسات ليست Bearer credentials.

- العقد العربي: [chat-v1.md](chat-v1.md).
- الاستيراد: استورد `chat-v1.postman_collection.json` كـCollection v2.1 في Postman.
- `base_url` مثال غير قابل للاستخدام؛ استبدله بعنوان خادم الاختبار المصرح به.
- ضع token اختبار مملوكًا للعميل في `access_token`، و`trip_id` لرحلته.
- ابدأ GET بلا X-Chat-Driver-Id؛ احفظ `metadata.driver.id` في `driver_id`.
- بعد أول استجابة، يضيف adapter الهيدر إلى read/send وGET اللاحق لحراسة هوية المحادثة.
- GET الأحدث بحد30؛ ثم before_sequence من next_before_sequence، والتوقف عند null.
- POST بنص جديد ومعرف جديد عشوائي. عند فقد الرد أعد POST بالمعرف والنص نفسيهما،
  أو GET للمصالحة؛ لا تولد معرفًا جديدًا للرسالة نفسها.
- PUT read فقط إلى آخر sequence عُرض للعميل والصفحة أمامه والتطبيق resumed.
- أمثلة `examples/` اصطناعية ومتوافقة مع ChatCodec واختبارات mock.
- أمثلة الفراغ/الإغلاق/الصفحات صور مستقلة لنفس المورد، وليست سجل أحداث واحدًا.

المحاكاة: success / empty / disconnect / send_failure / lost_response.
في success تظهر delivered بعد2ث وread بعد4ث ورد سائق بعد6ث من قبول الرسالة،
ويستدرك fetch مرور الوقت. لا رد سائق جديد بعد إغلاق الرحلة، ولا أحداث حية/Push/WebSocket.
resetSession يحذف الرسائل ومفاتيح الإرسال ويخلي الصفحة فورًا. لا تخزين على القرص.
مؤشر المحاكاة في UI ثابت لهذه المرحلة، ويُستبدل ضمن تكليف live integration مستقبلًا.

تحقق التسليم: JSON وCollection structure وفك الأمثلة آليًا واختبارات behavior.
لم يجر استيراد في تطبيق Postman، ولا تشغيل HTTP أو رفع الحزمة إلى حساب خارجي.
خادم Laravel المقترح مسؤول عن التفويض، الهوية، التحقق، pagination، idempotency الدائم
وإشعارات التسليم/القراءة الحقيقية. لا تستنتج قراءة من نجاح POST أو من اتصال الجهاز.

المسودة وpending غير المقبول لا يُحفظان بعد مغادرة الصفحة في هذه الدفعة.
الرسائل التي قبلها الخادم/المحاكاة تستعاد من repository عند إعادة الفتح؛
لا outbox دائم ولا حفظ على القرص. retry داخل الصفحة يحتفظ بالمعرف الأصلي.
