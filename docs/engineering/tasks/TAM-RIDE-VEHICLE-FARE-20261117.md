# TAM-RIDE-VEHICLE-FARE-20261117

READY → IMPLEMENTING؛ root / SUPERVISOR + DEVELOPER.
أساس cb4e2e3: جمع main795f999 وorigin/main4bf964f في فرع معزول.
الملكية: ride_request (UI/state/domain/data/tests/l10n/API docs)؛ حقول دفع وكوبون
اختيارية في shared Trip/WireCodec، وترجمات مولدة عند التجميع.
المراجع: AGENTS، task protocol، working agreement، ADR، design system، navigation، mock/API policy.
التصميم: النموذج المعتمد tam-ride-scroll-payments.html والصورة generated exec-bd83630d.
الهدف: مسار بمراحل مكان ثم مركبة/تأكيد مدموجة، فئات بتمرير أفقي، سعر رقمي
متحرك من quote الفعلي، نقد/محفظة، حقل كوبون وحسم من repository لا من UI.
الدفع والكوبون محاكاة موثقة؛ لا محفظة حقيقية أو خصم مال، API mode يبقى unavailable.
الحفاظ على الجلسات والخرائط والحجز idempotency/expiry والجدولة وrebooking.
التحقق عند التسليم: format/analyze/tests، حالات race/errors/payment/coupon،
RTL/LTR و320/هاتف/تابلت وخط كبير/لوحة مفاتيح، عرض Android المتاح.
لا push أو دمج main تلقائي. لا سياق خلفي أو أصول خارج المتاح؛ المحاكي موجود.

الحالة: READY_FOR_REVIEW؛ التنفيذ وبناءAndroid والتشغيل مكتملة. راجع تقرير التسليم للنتائج والقيود؛ لا دمج أوpush.
