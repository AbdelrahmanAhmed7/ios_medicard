# دليل التطوير والصيانة

## إعداد بيئة التطوير

```bash
flutter pub get
dart run build_runner build --delete-conflicting-outputs
flutter run
```

لـ iOS عند تغير pods:

```bash
cd ios
pod install
cd ..
```

استخدم إعدادات Firebase الموجودة للمشروع الصحيح. لا تضع secrets أو tokens في source أو logs أو screenshots.

## إضافة Feature جديدة

البنية المقترحة:

```text
lib/features/example/
├── data/
│   ├── data_source/
│   ├── dto/ أو models/
│   └── repository/
├── domain/
│   ├── models/
│   ├── repository/
│   └── usecases/
└── presentation/
    ├── cubit/
    ├── pages/
    └── widgets/
```

الترتيب العملي:

1. عرّف domain model وعقد repository.
2. عرّف DTO وRetrofit data source.
3. نفّذ mapping داخل repository implementation وأعد `ApiResult<T>` أو النوع المتبع في feature.
4. أضف use case إذا كانت العملية business action مستقلة.
5. أنشئ state وCubit، مع guards للطلبات المتزامنة إذا كان الضغط المكرر ممكنًا.
6. سجّل data source/repository/use case/Cubit في `setupServiceLocator()` بالـ lifetime المناسب.
7. أضف route وأنشئ Cubit عند حدود الشاشة.
8. أضف مفاتيح `ar.json` و`en.json` واختبارات النجاح والفشل والحواف.
9. حدّث `FEATURES.md` و`API_AND_ROUTES.md` ثم ولّد `CODE_REFERENCE.md`.

## إضافة endpoint أو model

مثال مبسط:

```dart
@GET('Example/{id}')
Future<ExampleResponseDto> getExample(@Path('id') int id);
```

بعد تعديل Retrofit/JSON/Freezed:

```bash
dart run build_runner build --delete-conflicting-outputs
```

قواعد المشروع:

- لا تعدّل `*.g.dart` أو `*.freezed.dart`.
- DTO يعكس عقد الخادم ويتعامل مع null/اختلاف الأنواع دفاعيًا عند الحاجة.
- حوّل DTO إلى domain model في data layer.
- افحص `succeeded` و`data` ولا تعتبر HTTP 200 نجاحًا منطقيًا تلقائيًا.
- استخدم `parseApiError`/`AppFailure` بدل عرض `DioException.toString()` للمستخدم.
- لا تضف Authorization يدويًا إلا إذا كان client الحالي يتطلبه؛ افهم دور `AuthInterceptor` أولًا.
- استخدم `@Extras({'skipAuthInterceptor': true})` أو الآلية الموجودة فقط للـ endpoints العامة المقصودة.

## إضافة route

أضف `GoRoute` في `AppRouter.createRouter`، ووثّق:

- path الثابت.
- query parameters القابلة للتسلسل.
- نوع وشكل `state.extra`.
- من يملك Cubit ومن يغلقه.
- fallback عند فتح المسار دون extra، إن كان deep-link محتملًا.

تجنب cast مباشر غير محمي إذا كانت الشاشة قابلة للفتح من notification أو deep link. لا تمرّر كائنات domain داخل URL؛ استخدم identifier وأعد تحميل البيانات عند الحاجة.

## إدارة الحالة بصورة آمنة

- لا تصدر state بعد `close()`؛ افحص `isClosed` بعد العمليات الطويلة.
- احتفظ بالبيانات السابقة أثناء refresh عندما يكون إخفاؤها تجربة سيئة.
- امنع duplicate requests باستخدام in-flight future أو request id.
- عند optimistic update، خزّن snapshot لاسترجاعه عند الفشل.
- عند pagination، تجاهل response قديم إذا تغيّر query/filter أثناء الطلب.
- عملية مالية أو إنشاء invoice لا تُعاد تلقائيًا بعد timeout؛ صالح النتيجة مع الخادم أولًا.
- استخدم `CartSyncService` لتزامن السلة بدل استدعاء Cubit شاشة أخرى مباشرة.

## الترجمة والتنسيق

أي نص للمستخدم يجب أن يكون له مفتاح في الملفين:

- `assets/translations/ar.json`
- `assets/translations/en.json`

استخدم `AppTextStyles` و`AppColors` و`ScreenUtil` بدل أرقام وتصميمات متكررة. اختبر RTL وLTR والنص الطويل. تنسيق التاريخ يمر عبر `AppDateFormatter`/`intl`، والمبالغ عبر helpers الموجودة في feature.

## الاختبارات الحالية

الاختبارات الموجودة تغطي نقاطًا عالية المخاطر، منها:

- logout حتى عند فشل خطوات التنظيف.
- Cart checkout reliability، منع الإنشاء المكرر، unknown outcome، وترتيب responses.
- Invoice details/cancel/review.
- Search pagination/filter/location وتزامن السلة.
- Content parsing/link handling/retry.
- Notification optimistic read rollback وتسجيل FCM token.
- Profile summary دون كسر بيانات profile.
- Provider page scoped rebuilds وتفاصيل الباقة.

شغّل:

```bash
flutter test
```

ولاختبار ملف واحد:

```bash
flutter test test/features/cart/presentation/cubit/cart_cubit_test.dart
```

عند إصلاح bug، أضف test يفشل قبل الإصلاح إن أمكن، خصوصًا للـ Cubits وrepository mapping وحالات السباق.

## فحوصات قبل الدمج

```bash
dart format --set-exit-if-changed lib test tool
flutter analyze
flutter test
dart run tool/generate_code_reference.dart
git diff --check
```

ثم راجع يدويًا:

- لا يوجد token/password/PII في logs.
- ملفات التوليد متزامنة مع مصادرها.
- الترجمتان تحتويان المفاتيح الجديدة.
- loading/empty/error/success كلها قابلة للوصول.
- back navigation وdeep links لا تنهار عند missing extra.
- Android وiOS permissions/configs محدثة إذا أضيف plugin أو capability.

## مرجع الدوال المولّد

`tool/generate_code_reference.dart` يستخدم Dart analyzer لقراءة AST وليس regex، لذلك يفهرس التصريحات متعددة الأسطر والـ constructors/getters/private methods بصورة صحيحة. شغّله بعد أي تغيير في واجهات الكود:

```bash
dart run tool/generate_code_reference.dart
```

الناتج هو `docs/CODE_REFERENCE.md`. الوصف فيه مختصر ومبني على اسم الدالة ومسارها؛ أضف شرح التدفق والقرارات إلى المستند اليدوي المناسب بدل تعديل الناتج مباشرة.
