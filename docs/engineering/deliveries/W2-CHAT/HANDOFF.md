# W2-CHAT — تسليم المنفذ

التاريخ: 2026-11-09. الدور DEVELOPER، الفرع `codex/w2-chat`،
worktree `/home/hazem/.codex/worktrees/review-w2-addresses/mashwar`.
الأساس الوظيفي `a1199ef952f2f0f94c6088ff32d0609e0ec2b555`، ومدخل البطاقة
`4dde1e485fccdadc2c51c83e016fe3ff37797270`، نظيف عند الاستلام.
كود التسليم واختباراته وعقده وصوره عند
`8bf7964ef13e653399ada51c9e81f310aa090c88`؛ الكوميت اللاحق الذي يحمل هذا التقرير
توثيق فقط. checkpoint الداخلي الأول `53111e72eccdbeb12ee5efbfa5131a55b08d0d4e`
ليس اعتمادًا. لا مراجعة مستقلة بعد؛ يطلبها المشرف للـSHA المجمع مع ربطه.

## التنفيذ والملكية

التغيير محصور في `apps/customer/lib/features/chat/**` و
`apps/customer/test/features/chat/**` و`docs/api/chat/**` وهذا التسليم وصوره.
لا تعديل محفوظ في Auth/router/config/DI/theme/shared/ActiveTrip أو اللوحة.
قرأ المنفذ AGENTS والبروتوكول وخطة التوازي والبطاقة ومراجع الاتفاق والمعمارية
والثيم والتنقل وسياسة Mock/API وخطة المرحلتين وتسليم الباكند. فُتح UI-13 الأصلي
فعليًا: `apps/customer/Tam Cusstomer UI/WhatsApp Image 2026-11-04 at 3.03.02 PM.jpeg`.
Git وFlutter/Dart وrenderer وقراءة الصور متاحة؛ لا backend أو اتصال سائق فعلي.

- Domain خالص: ChatRepository وChatPolicy ونماذج immutable؛ لا use cases تمريرية.
- MockChatRepository يقرأ حالة الرحلة من MockTripStore في كل عملية، ويربط هوية
  السائق الأولى داخل جلسة repository. تغيير السائق يحجب الإرسال والسياق القديم.
- النص trim ثم1..1000 Unicode code points؛ أحدث30، cursor exclusive، ترتيب sequence.
- إرسال بمفتاح عشوائي24bytes مستقل عن الساعة وعمر الصفحة، وretry يحتفظ بالمفتاح والنص.
  فقد الرد يحفظ uncertain ويصالح GET أوretry دون تكرار. بعد إغلاق الرحلة يعيد نفس
  المعرف المقبول سابقًا الرسالة الأصلية بعد فحص الهوية، ولا يقبل كتابة جديدة.
- Cubit يحرس session/close/الطلبات القديمة/revision/receipts، ويؤكد أن sendack يطابق
  clientMessageId/body/author. ack مخالف يصير INVALID_RESPONSE/uncertain.
- polling5s والاستئناف وinvalidations يعيدون دمج الأحدث دون محو التاريخ. تُملأ فجوة
  أحدث30 إذا فاتت رسائل بين pollين؛ تحميل الأقدم لا يغير ترتيب أو يكرر التاريخ.
- markRead لا يصدر منpoll أوfetch نفسه؛ الصفحة تؤكده بعد الرسم عند الأحدث فقط، وهي
  current والتطبيق resumed. أخطاء التحميل توقفه، ولا ترد استجابة قراءة قديمة revision.
- نجاح الإرسال لا يدعي تسليمًا أو قراءة. أحداث mock حتمية: delivered2s/read4s/reply6s،
  مع استدراك الوقت عندfetch ومنع ردود سائق جديدة بعد الإغلاق. fixtures لا تسبق إنشاء
  الرحلة/حالتها الحالية، وتراجع الساعة لا يعكس توقيت آخر رسالة مقبولة.
- resetSession يحذف النصوص ومفاتيح العمليات ويخلي الصفحة فورًا؛ dispose يغلق الموارد.
- API mode هو UnavailableChatRepository بدونfallback أوcredentials أو جلسة Auth جديدة.

واجهة مبدئية بالثيم والتوكنات والمكونات المركزية، عربيةRTL وإنجليزيةLTR، جهة العميل
يمين والسائق يسار كماUI-13 (محاذاة المؤلف مقصودة وثابتة حتىRTL). أوقات وحالات
نصية وأيقوناتMaterial حقيقية، حقل متعدد الأسطر، عداد وحدود وإرسال قابل للوصول.
التمرير معكوس ليبقى الأحدث متاحًا قرب الحقل؛ إضافة رسائل عند قراءة التاريخ تحفظ
الموضع بدل سحب القارئ. يوجد تحميل أقدم/تحديث/عودة للأحدث عند الحاجة.

ChatCubit336 سطرًا، تجاوز محدود ومقصود لإبقاء دورة async واحدة قابلة للقراءة:
حراسepoch والطلبات والهوية والمصالحة والإرسال/القراءة تتشارك حالة واحدة. لا ضغط
للتنسيق ولاpart/طبقات تمريرية لتخفيض العدد. الصفحة184 سطرًا تقريبًا ومركبة من
ChatTimeline وChatStatusBanner وChatComposer وChatMessageBubble بمسؤوليات محددة.

## الواجهات للمشرف

- `chat_entry.dart`: `registerChatDependencies(GetIt)` يسجل factoryParam،
  و`buildChatFeature(repository:,tripId:,policy:,now:,onBack:)` يستخدمه معfallback
  للاختبار المعزول. لا خدمةlocator داخل widgets.
- `domain/chat_repository.dart`: ChatPolicy وChatRepository، ويصدرchat_models.
- `data/mock/mock_chat_repository.dart`: `MockChatRepository(MockTripStore,
  {now,scenario,policy})` و`resetSession()` و`dispose()`.
- `data/mock/chat_mock_scenario.dart`: enum success/empty/disconnect/sendFailure/lostResponse،
  وparse يقبل success/empty/disconnect/send_failure/lost_response.
- `data/unavailable_chat_repository.dart`: فشلSERVICE_UNAVAILABLE صريح.
- UI keys: chat-input/chat-send/chat-refresh/chat-load-older/chat-newest.
- root يملك route/AppConfig/DI/reset/navigation وActiveTrip entry واختبارات الربط
  والترجمات المولدة. تم تنسيق signatures وChatPolicy وX-Chat-Driver-Id معه.

العقد [chat-v1.md](../../../api/chat/chat-v1.md)،
[README.ar.md](../../../api/chat/README.ar.md)،
[Collection v2.1](../../../api/chat/chat-v1.postman_collection.json)،
و20 مثالJSON تحتexamples. X-Chat-Driver-Id بعد أولGET يحمي هوية السائق ذرّيًا فيAPI
المقترح، ومنع تكرار client_message_id مسؤوليةالخادم الدائمة. لم يجرHTTP حي أو
استيراد فعلي فيPostman أو رفعحزمة لحساب خارجي.

## التحقق الفعلي

شُغلت من `apps/customer`:

```bash
dart format --output=none --set-exit-if-changed lib test
flutter analyze --no-pub
flutter test --no-pub
flutter test --no-pub test/features/chat
flutter test --no-pub --dart-define=CAPTURE_CHAT_UI=true --update-goldens test/features/chat/chat_widget_test.dart
flutter test --no-pub --dart-define=CAPTURE_CHAT_UI=true test/features/chat/chat_widget_test.dart
```

النتائج النهائية: format254 ملفًا دون تغيير، analyze بلا مشكلات، **458 اختبارًا
كاملًا ناجحًا** على فرع الميزة (49 جديدًا)، و17 widget/golden ناجحة عند الالتقاط ثم
17 ناجحة عند المقارنة دون تحديث. شملت الاختبارات حدودrunes/ترقيم/تسلسل/receipts/
idempotency/فقدالرد/غلقالرحلة/تغييرالسائق/عزلالجلسة/late read-vs-send/close/
ackغيرمطابق/الصفحةالمخفية والخلفية/المسودةالأحدث/حفظموضعالتاريخ/ملءفجوةpoll.
اختبارات العقد تفك كل مثال، تقارن mockfetch/send/read، وتطابق saved responses
معالأمثلة وتمنعUTC/version/cursor/identity/ترتيب غيرصالح.

شُغلت أيضًا `python3 scripts/dev/sync_feature_l10n.py --check` و`git diff --check`،
وفُك21 JSON (20 مثالًا وCollection) باستخدامjson.loads؛ الكلناجح.
لأنsyncscript وgenerated ملكالمشرف، جرى دعمchatمؤقتًا محليًا لتوليدالترجمة
والتحقق، دونالتزامهذهالتغييرات، وأعيدتنسخالملفاتللأساسقبلالتسليم. لإعادةاختبار
SHAالميزة منفردًا يلزم تمكينfragmentchatفيsyncscript ثمsync/gen-l10n؛ المشرف
يملكذلكفيفرعالتكامل. النتائجالمذكورة تشملالترجماتالمولدة المطابقةللـARBالنهائية.
لا نقول إن root integration اختُبر فيworktreeالمنفذ؛ المشرف يفحص SHAالمجمع.

## الصور وحدودها

23 صورة تحت [screenshots/](screenshots/) منFlutterwidget-test renderer، بفونت
النظامNotoArabic/NotoLatin محملين محليًا للاختبار وMaterialIcons. لاخط جديد
فيالتطبيق أوdependency جديدة. فُحصتالصور فعليًا، أفرادًا وcontactsheet:
العربيةوالإنجليزية،320×640بـ2x،390×844بـ1x،800×1000بـ2x،800×390بـ1x،
معوبدونkeyboardinsets260dp (120dpبالاتجاهالأفقي)، وحالاتempty/loading/offline/
failed/uncertain/read-only/readreceipt. لاادعاءAndroid أوIMEحقيقي أوجهازفعلي.

عند320/2xمعالكيبورد تبقىالحقولوالإرسال ضمنالمساحة؛ الرسائل الطويلة/القديمة
تُراجع بالتمرير الطبيعي، وحقلالنص داخليًاقابلللتمريرعندضيقالمساحة. مؤشرالمحاكاة
مختصر Simulation/محاكاةتطوير لقراءته بوضوح. لاcapلتحجيمالنص.

## حدود وتسليم المرحلة الأولى

واجهةقابلةللاستخدام قريبةمنلغةUI-13 وليستتصميمًانهائيًا أوrelease-ready.
يؤجلللمرحلةالثانية الصقلالدقيق لأشكالذيولالفقاعاتوالخطوطوالمسافاتوتجميعالتواريخ
وتوزيعالرسائلفيالصفحةالقصيرة مقارنةبالمرجع. إطارالهاتفوصورالموكأب ليستمنالمنتج.

المسودة وpendingغيرالمقبول لا يُحفظان بعد مغادرة الصفحة، باتفاقالمشرف؛ لاoutbox
دائمولاحفظعلىالقرص. المقبوليستعادمنrepository عندإعادةالفتح، وretryداخلنفسالصفحة
يحفظالمعرفالأصلي. البياناتالمحاكاةلاتنشئتوكناتأوحجزًاأودفعًاأورسائلحقيقية.
مؤشرالمحاكاةثابتلهذهالمرحلة؛ يستبدلضمنتكليفliveintegrationلاحقًا، معبياناتreceipts
ومحركشبكةحقيقيين. لاbackend/HTTP/Postmanapp/deviceverification متاحضمنالمهمة.

لاpushأوmainأوActionsأوAndroidbuildأوتشغيلمحاكي. لاطلباتمشتركةمعلقة؛
بقيةالربطوفحصتكاملهوالترجمةالمولدةوالمراجعةالمستقلةتحتملكيةالمشرف.
المنفذيجمّدكودالتسليم حتىطلبإصلاحمحدد.
