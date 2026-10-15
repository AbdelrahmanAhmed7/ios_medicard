# معمارية التطبيق

## الصورة العامة

MediCard تطبيق Flutter يعتمد على Feature-first Clean Architecture بصورة عملية وليست صارمة بالكامل. الميزات الحديثة داخل `lib/features` تفصل بين `data` و`domain` و`presentation`، بينما أجزاء المصادقة والبطاقة الأقدم ما زالت موزعة على مجلدات الجذر. إدارة الحالة تتم غالبًا بواسطة Cubit، وGetIt ينشئ الاعتماديات، وDio/Retrofit ينفّذان طلبات الشبكة.

```text
UI ──event──> Cubit ──> Use Case ──> Repository interface
 ^                                         │
 │                                         ▼
 └──state/result── Repository implementation ──> API / storage / device service
```

### مسؤولية الطبقات

- `presentation`: الشاشات والـ widgets والـ Cubits والـ states. لا يفترض أن تعرف تفاصيل HTTP أو شكل التخزين.
- `domain`: نماذج العمل، عقود repositories، والـ use cases. هذه الطبقة تصف ما يستطيع التطبيق فعله.
- `data`: Retrofit data sources وDTOs وتنفيذ repositories وتحويل DTO إلى domain model.
- `core`: بنية مشتركة مثل الشبكة، session، الأخطاء، routing، DI، اللغة، theme، والتخزين.

## بدء التشغيل

ينفّذ `main()` الخطوات التالية بالترتيب:

1. تهيئة Flutter bindings و`easy_localization` وبيانات تنسيق التاريخ للعربية والإنجليزية.
2. تهيئة Firebase باستخدام `DefaultFirebaseOptions`.
3. قراءة لغة التطبيق بواسطة `AppLanguageManager`.
4. تشغيل `setupServiceLocator()` لتسجيل الشبكة والمستودعات والـ use cases والـ Cubits.
5. تحديد أول route بواسطة `AppRouter.getInitialLocation()` مع timeout مدته 10 ثوانٍ.
6. تشغيل `MyApp` داخل `EasyLocalization`.
7. بعد أول frame، تشغيل مراقبة الاتصال وPush Notifications دون حجب ظهور الواجهة.
8. عرض فيديو splash فوق التطبيق إلى أن ينتهي أو يعمل fallback timer.

### اختيار أول شاشة

`AppRouter.getInitialLocation()` يطبّق القرار التالي:

- لا توجد session: يفتح onboarding لأول مرة، وإلا guest home.
- access token صالح: يفتح authenticated home.
- access token منتهي وrefresh token صالح: يحاول silent refresh ثم يفتح home عند النجاح.
- refresh token منتهي أو refresh فشل بشكل نهائي: يمسح session ويفتح login.
- خطأ غير متوقع: يعود إلى guest home بدل تعطيل بدء التطبيق.

## حقن الاعتماديات

الـ service locator العام هو `sl = GetIt.instance`. التسجيل مرتب لأن بعض الخدمات تعتمد على سابقتها:

1. `AppLanguageManager` و`AppRefreshCubit`.
2. `AuthSessionStorage` وDio منفصل للـ refresh و`AuthRefreshService`.
3. Dio الرئيسي ثم `AuthInterceptor`.
4. Retrofit API clients.
5. Repository implementations.
6. Use cases.
7. Cubits.

يستخدم المشروع ثلاثة lifetimes:

- `registerLazySingleton`: للخدمات المشتركة والعملاء والمستودعات التي يجب إعادة استخدامها.
- `registerFactory`: لـ Cubit/UseCase جديد عند كل طلب.
- `registerFactoryParam`: عندما يحتاج الإنشاء قيمة runtime؛ مثل `ProviderPageCubit(providerId)` و`CartCubit(providerId?)`.

## الشبكة والأخطاء

`DioFactory` ينشئ Dio واحدًا بالـ base URL الأساسي وtimeouts، ثم يضيف:

- `Accept-Language` من اللغة الحالية.
- logger في debug مع منع طباعة Authorization واستثناء payloads الحساسة.
- retry logic للطلبات المؤهلة.
- error mapping لتحويل أخطاء Dio إلى `AppFailure` مفهوم.
- `AuthInterceptor` بعد إنشاء خدمات session لمنع dependency cycle.

تُعاد نتائج معظم repositories كـ `ApiResult<T>`، إما `success(data)` أو `failure(message)`. واجهة المستخدم تتعامل مع حالات loading/success/failure من Cubit، بينما `parseApiError` وطبقة error mapping توحّدان الرسائل قدر الإمكان.

## دورة المصادقة والـ token refresh

- `AuthSession` يحمل access/refresh tokens وتواريخ انتهائهما بصيغة UTC.
- `AuthSessionStorage` يحفظ القيم الحساسة في `FlutterSecureStorage` ويحافظ على مفتاح `userToken` القديم للتوافق.
- يعتبر access token بحاجة للتجديد قبل انتهائه بدقيقتين.
- `AuthRefreshService` يستخدم Dio منفصلًا بلا `AuthInterceptor` لمنع loop، ويطبّق single-flight حتى تشترك الطلبات المتزامنة في refresh واحد.
- `AuthInterceptor` يضيف Bearer token، وينفّذ refresh عند الحاجة، ثم يعيد الطلب المناسب.
- عند انتهاء session، يطلق `AppRefreshCubit.sessionExpired`؛ يستمع `MyApp` للحدث، يمسح header القديم وينتقل إلى `/medicard-login`.
- لا ينبغي تسجيل token أو password أو refresh payload في console.

## إدارة الحالة والتزامن

كل شاشة كبيرة تقريبًا لها Cubit وحالة immutable أو Freezed. النمط المتوقع:

1. الواجهة ترسل intent مثل `loadProfile()` أو `addToCart()`.
2. Cubit يمنع التكرار إن كان هناك طلب مماثل قيد التنفيذ عند الحاجة.
3. Cubit يصدر loading/optimistic state.
4. Use case أو repository ينفّذ العملية.
5. Cubit يصدر success أو يعيد الحالة السابقة مع error.

حالات خاصة مهمة:

- `CartSyncService` يبث تغييرات السلة بين search/provider/cart دون ربط الـ Cubits ببعضها مباشرة.
- `CartCubit` يحتوي guards لإنشاء invoice وتعيين provider، ويعالج حالة timeout ذات النتيجة غير المعروفة بالمصالحة مع الخادم.
- `HomeCubit` و`ProfileCubit` و`ECardCubit` يمنعون تكرار الطلبات المتزامنة ويحتفظون ببيانات سابقة أثناء refresh.
- `ProviderPageCubit` يقسم الحالة لتقليل rebuilds بين header/content/search/cart bar/package sheet.
- `AppRefreshCubit` قناة أحداث عامة لانتهاء session وتغيير اللغة وتحديث ملخص الملف والفواتير.

## التخزين والكاش

- secure storage: access token، refresh token، وتواريخ الانتهاء.
- shared preferences: اللغة، onboarding، ورقم البطاقة أو مفاتيح legacy غير الحساسة.
- `NetworkCacheService`: يحفظ بيانات الدعم في shared preferences بصيغة JSON لمدة 48 ساعة؛ فشل الكاش لا يجب أن يمنع طلب الشبكة أو يعطل التطبيق.
- `cached_network_image`: كاش صور الشبكة على مستوى العرض.

## اللغة والاتجاه

- اللغات المدعومة: `ar` و`en`.
- ملفات النصوص: `assets/translations/ar.json` و`assets/translations/en.json`.
- `AppLanguageManager` يقرأ اللغة المحفوظة أو لغة الجهاز، ثم يضيف `Accept-Language` لكل طلب.
- `LocalizationCubit` يحدّث `EasyLocalization` ويطلق refresh للـ router حتى تعاد ترجمة الصفحات.
- الخط الافتراضي يتحدد عبر `FontManager`: Cairo للعربية وRoboto للإنجليزية.

## التنقل

`AppRouter` ينشئ `GoRouter` واحدًا. كل route مسؤول عن إنشاء Cubit الخاص به أو إعادة استخدام Cubit مرّرته الشاشة السابقة في `state.extra`. `normalizeLocation` يحافظ على روابط legacy مثل `/home` و`/login`. `currentLocation` يسمح لعناصر overlay مثل floating cart button بالاختفاء في شاشات محددة.

راجع [API_AND_ROUTES.md](API_AND_ROUTES.md) لقائمة المسارات ومدخلاتها.

## الإشعارات

`PushNotificationService` يهيّئ FCM وlocal notifications وقنوات Android، ويتعامل مع foreground/background/tap/token refresh. الرسالة التي تحتوي notification في الخلفية يترك عرضها للنظام لتجنب التكرار، بينما data-only message يمكن تحويلها إلى local notification إذا احتوت title/body. الضغط على الإشعار يُحوّل payload إلى `NotificationAction` ثم إلى route مناسب.

## الملفات المولّدة

- Retrofit وJSON serialization ينتجان `*.g.dart`.
- Freezed ينتج `*.freezed.dart`.
- `firebase_options.dart` ناتج FlutterFire ويُحدّث بواسطة أدوات Firebase.
- لا تعدّل هذه الملفات يدويًا. عدّل المصدر ثم شغّل:

```bash
dart run build_runner build --delete-conflicting-outputs
```

## مناطق legacy والانتباه عند التعديل

- يوجد Profile API قديم يعتمد `{lang}` و`CardNo` بجانب Profile v2 المعتمد على session.
- login/register الأساسيان تحت `lib/presentation` وrepository عام تحت `lib/repository`، وليس داخل `features/auth` بالكامل.
- بعض endpoints تستخدم URL كاملًا بدل الـ base URL؛ راجع جدول API قبل تغيير البيئة.
- توجد نماذج API وdomain منفصلة في cart/activity/search؛ حافظ على mapping داخل data layer ولا تمرر DTO مباشرة للواجهة.
