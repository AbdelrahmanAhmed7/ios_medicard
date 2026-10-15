# دليل توثيق MediCard

هذا المجلد هو المرجع الفني للمشروع. ابدأ بالمستند المناسب لسؤالك:

| المستند | متى تستخدمه؟ |
|---|---|
| [MediCard_Project_Documentation.pdf](MediCard_Project_Documentation.pdf) | نسخة موحدة قابلة للبحث والطباعة تضم كل المستندات ومرجع الكود |
| [ARCHITECTURE.md](ARCHITECTURE.md) | لفهم بدء التشغيل، الطبقات، المصادقة، الشبكة، إدارة الحالة، والتخزين |
| [FEATURES.md](FEATURES.md) | لمعرفة مسؤولية كل Feature وأهم Cubits/Repositories والشاشات |
| [API_AND_ROUTES.md](API_AND_ROUTES.md) | لمعرفة endpoint أو GoRouter path ومدخلاته |
| [DEVELOPMENT.md](DEVELOPMENT.md) | عند إضافة ميزة، model، endpoint، route، ترجمة، أو اختبار |
| [CODE_REFERENCE.md](CODE_REFERENCE.md) | للبحث عن أي class/function/method والوصول مباشرة إلى سطر المصدر |

## حدود كل نوع من التوثيق

- المستندات اليدوية تشرح القرارات والتدفّقات والمسؤوليات.
- `CODE_REFERENCE.md` يغطي التصريحات البرمجية كاملة، بما فيها الأعضاء الخاصة، لكنه يقدّم وصفًا مختصرًا مولّدًا من الاسم والسياق.
- الكود والاختبارات هما المرجع النهائي عند اختلاف التفاصيل التنفيذية.
- ملفات `*.g.dart` و`*.freezed.dart` موثّقة من خلال مصادرها الأصلية ولا تظهر كملفات مستقلة في المرجع.

## تحديث التوثيق

عند تغيير السلوك:

1. حدّث المستند اليدوي المرتبط بالتغيير.
2. شغّل `dart run tool/generate_code_reference.dart` لتحديث فهرس التصريحات.
3. شغّل `flutter analyze` و`flutter test`.
4. راجع أن الروابط والأسماء والـ routes والـ endpoints ما زالت مطابقة للمصدر.

لا تعدّل `CODE_REFERENCE.md` يدويًا لأنه سيُستبدل في التشغيل التالي للمولّد.

لتحديث ملف الـ PDF بعد تعديل التوثيق:

```bash
dart run tool/generate_documentation_pdf.dart
```
