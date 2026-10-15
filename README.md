# MediCard Mobile

تطبيق Flutter لإدارة البطاقة الطبية والوصول إلى مقدمي الخدمات والباقات، البحث والحجز، السلة والدفع، الفواتير، أفراد الأسرة، الملف الشخصي، والإشعارات. يدعم التطبيق العربية والإنجليزية ويعمل على Android وiOS.

## ابدأ من هنا

المتطلبات المستخدمة حاليًا:

- Flutter `3.44.1` أو إصدار متوافق.
- Dart `3.10.7+` وفق `pubspec.yaml`.
- Xcode وCocoaPods لتشغيل iOS، وAndroid Studio/SDK لتشغيل Android.
- إعدادات Firebase الموجودة في `lib/firebase_options.dart` وملفات المنصات.

```bash
flutter pub get
dart run build_runner build --delete-conflicting-outputs
flutter run
```

للتحقق من المشروع:

```bash
flutter analyze
flutter test
```

## خريطة التوثيق

- [نسخة PDF الشاملة](docs/MediCard_Project_Documentation.pdf): كل التوثيق ومرجع الكود في ملف واحد قابل للبحث والطباعة.
- [دليل التوثيق](docs/README.md): نقطة الدخول لكل مستندات المشروع.
- [المعمارية وتدفّق البيانات](docs/ARCHITECTURE.md): طبقات التطبيق، بدء التشغيل، المصادقة، الشبكة، الحالة، والتخزين.
- [دليل الـ Features](docs/FEATURES.md): مسؤولية كل ميزة وأهم ملفاتها وتدفّقها.
- [REST API والـ Routes](docs/API_AND_ROUTES.md): جميع الـ endpoints ومسارات التنقل والمدخلات المطلوبة.
- [دليل التطوير والصيانة](docs/DEVELOPMENT.md): إضافة Feature أو endpoint، التوليد، الاختبارات، وقائمة التحقق.
- [مرجع الكود الكامل](docs/CODE_REFERENCE.md): فهرس مولّد لكل class/constructor/function/method في الملفات المكتوبة يدويًا، مع روابط للأسطر.

## المعمارية باختصار

المسار المعتاد للبيانات هو:

```text
Screen / Widget
      ↓ event
Cubit → Use Case → Repository contract → Repository implementation
                                           ↓
                                  Retrofit data source / local storage
                                           ↓
                                      REST API / device
```

تستخدم أغلب الميزات تقسيم `data/domain/presentation`. ما زالت بعض الأجزاء الأقدم موجودة في `lib/data` و`lib/domain` و`lib/presentation`، بينما صفحة مقدم الخدمة موجودة في `lib/medicard_network`. راجع [شرح المعمارية](docs/ARCHITECTURE.md) قبل نقل أو إضافة ملفات.

## أهم التقنيات

- `flutter_bloc` لإدارة الحالة.
- `get_it` لحقن الاعتماديات من `lib/core/di/service_locator.dart`.
- `dio` + `retrofit` للاتصال بالـ API.
- `freezed` لحالات Cubit و`json_serializable` للـ DTOs.
- `go_router` للتنقل.
- `easy_localization` للغتين العربية والإنجليزية.
- `flutter_secure_storage` لحفظ الـ tokens، و`shared_preferences` للإعدادات غير الحساسة.
- Firebase Messaging مع local notifications للإشعارات.

## بنية المشروع

```text
lib/
├── core/               # الشبكة، المصادقة، DI، routing، theme، وخدمات مشتركة
├── features/           # الميزات الحديثة مقسمة إلى data/domain/presentation
├── medicard_network/   # صفحة مقدم الخدمة والباقات والخدمات والتقييمات
├── data/ domain/       # نماذج وعقود/use cases أقدم مشتركة
├── presentation/       # شاشات login/register القديمة وحالتها
├── network/            # نماذج صفحة مقدم الخدمة
├── repository/         # تنفيذ المستودع الرئيسي
├── service/            # MedicardApiService الرئيسي
├── firebase_options.dart
└── main.dart

assets/                 # صور، خطوط، وترجمات ar/en
test/                   # unit وwidget tests
tool/                   # أدوات التوثيق والتوليد المحلية
docs/                   # توثيق المشروع
```

## توليد الملفات والمرجع

بعد تعديل model أو Retrofit service أو Freezed state:

```bash
dart run build_runner build --delete-conflicting-outputs
```

بعد إضافة أو إعادة تسمية class/function/method:

```bash
dart run tool/generate_code_reference.dart
```

ولتحديث نسخة الـ PDF الشاملة:

```bash
dart run tool/generate_documentation_pdf.dart
```

لا تعدّل يدويًا ملفات `*.g.dart` أو `*.freezed.dart` أو `docs/CODE_REFERENCE.md`.

## ملاحظات إعداد مهمة

- عنوان الـ API الأساسي الحالي هو `https://medicard-api-v2.medicardeg.com/api/` وموجود في أكثر من Retrofit service وفي `DioFactory`.
- التطبيق يستخدم صلاحيات الموقع، الإشعارات، والصور بحسب الـ feature والمنصة.
- مفاتيح الترجمة يجب إضافتها في `assets/translations/ar.json` و`assets/translations/en.json` معًا.
- بيانات الجلسة الحساسة تُحفظ في secure storage؛ لا تُطبع الـ tokens في logs.
- إصدار التطبيق الحالي في `pubspec.yaml` هو `1.0.0+2`.
