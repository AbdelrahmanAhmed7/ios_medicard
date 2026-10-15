# دليل الـ Features

## خريطة سريعة

| Feature | المسؤولية | إدارة الحالة / المدخل الرئيسي | مصدر البيانات |
|---|---|---|---|
| `activate_card` | تفعيل بطاقة المستخدم | `ActivateCardCubit` | `ActivateCardRepository` |
| `activity` | قائمة الفواتير، التفاصيل، الإلغاء، والتقييم | `ActivityCubit`, `InvoiceDetailsCubit` | `InvoiceRepository` |
| `auth` | نسيت كلمة المرور وOTP وإعادة التعيين | `ForgotPasswordCubit` | `MedicardRepository` |
| `cart` | السلة، اختيار مقدم الخدمة والفرع، checkout | `CartCubit` | `CartRepository`, `InvoiceRepository` |
| `content` | السياسات والشروط من HTML | `ContentCubit` | `ContentRepository` |
| `ecard` | البطاقة الطبية الرقمية | `ECardCubit` | `MedicardRepository` |
| `family_members` | إضافة/تعديل/حذف أفراد الأسرة | `FamilyMembersCubit` | `FamilyMembersRepository` |
| `guest_home` | الصفحة الرئيسية بدون تسجيل | `GuestHomeCubit` | `MedicardRepository` |
| `help_center` | واجهة قنوات المساعدة | `HelpCenterScreen` | URL/WhatsApp launcher |
| `home` | الصفحة الرئيسية للمستخدم والموقع | `HomeCubit`, `LocationCubit` | `MedicardRepository`, location services |
| `notifications` | قائمة الإشعارات وFCM وحالة القراءة | `NotificationCubit`, `PushNotificationService` | `NotificationRepository` |
| `packages` | عرض كل الباقات والبحث التدريجي | `AllPackagesScreen` | `MedicardNetworkRepository` |
| `profile` | الملف، الصورة، اللغة، كلمة المرور، تفعيل بطاقة عضو | `ProfileCubit`, `ChangePasswordCubit` | `MedicardRepository` |
| `search` | بحث مقدمي الخدمة والخدمات والفلاتر | `SearchCubit`, `FilterCubit` | `SearchRepository`, `CartRepository` |
| `medicard_network` | صفحة مقدم الخدمة وفروعه وخدماته وباقاته وتقييماته | `ProviderPageCubit` | `MedicardNetworkRepository` |

## المصادقة والتسجيل

### Login وRegister

الجزء الأساسي موجود في `lib/presentation` مع `MedicardLoginCubit` و`RegisterCubit`. كلاهما يستدعي use cases في `lib/domain/usecases`، والتي تمر عبر `MedicardRepository`. نجاح الدخول يحفظ `AuthSession` وبيانات التوافق القديمة ثم يسمح بالانتقال إلى home.

### Forgot password

التدفّق ثلاثي المراحل:

1. `sendOtp(phoneNumber)` ثم الانتقال إلى `/forgot-password/verify` مع `phoneNumber` و`otp`.
2. `verifyOtp(...)` ثم الانتقال إلى `/forgot-password/reset` مع token التحقق.
3. `resetPassword(...)` ثم العودة إلى login عند النجاح.

الـ OTP الظاهر في الاستجابة/الشاشة مرتبط بسلوك الخادم الحالي ويجب عدم اعتباره آلية production آمنة إن تغيّر عقد الـ API.

## Home وGuest Home

`HomeCubit` يجمع home payload المحمي مع الموقع، ويحوّل DTOs إلى نماذج عرض عبر `home_mappers.dart`. الشاشة تعرض البطاقة، الخدمات المميزة، أقرب مقدمي الخدمة، المواعيد المعلقة، البنرات، والتنقل السفلي. `LocationCubit` يدير الإذن والموقع والعنوان.

`GuestHomeCubit` يحمّل نسخة عامة من الصفحة ويعيد استخدام نماذج العرض عبر `guest_home_mappers.dart`. البحث من وضع guest يمرر `enableCartFeatures: false` ويستخدم endpoint الخدمات العام عند الحاجة.

## Search

`SearchCubit` يدير مسارين داخل الشاشة نفسها:

- Providers: keyword، category، governorate، city، sort، الموقع، pagination.
- Services: service categories ثم خدمات الفئة، مع كاش لكل فئة وpagination.

`FilterCubit` يحمّل lookups ويحتفظ بالاختيارات المؤقتة. عند sort بالأقرب يمكن طلب الموقع. عمليات إضافة/حذف خدمة من السلة optimistic وتمنع تكرار نفس العملية؛ `CartSyncService` يبث النتيجة لباقي الشاشات.

## صفحة مقدم الخدمة والباقات

`ProviderPageCubit` يبدأ بـ `providerId` ويحمّل معلومات مقدم الخدمة، الفروع، والخدمات. يستطيع المستخدم التبديل بين الخدمات والباقات والتقييمات، البحث، التحميل التدريجي، تصفح فئات الخدمات، وإضافة/حذف خدمات من السلة. تفاصيل الباقة تُحمّل عند الطلب، ويمكن إنشاء invoice لباقة مباشرة بعد اختيار الفرع وطريقة الدفع.

`AllPackagesScreen` يعرض كل الباقات بصفحات مع search. عند فتح مقدم خدمة من notification يمكن تمرير `autoOpenPackageId` لفتح تفاصيل باقة تلقائيًا.

## Cart وCheckout

السلة تستخدم domain models منفصلة عن DTOs. أهم العمليات في `CartCubit`:

- تحميل السلة وخدمات الفئة وإضافة/حذف خدمة ومسح السلة.
- تحميل مقدمي الخدمة القادرين على تغطية عناصر السلة.
- تعيين provider ومصالحة العناصر غير المغطاة.
- تحميل الفروع وأفراد الأسرة واختيار طريقة الدفع.
- إنشاء invoice من cart أو package.
- منع POST مكرر عند الضغط المتزامن.
- عند timeout بعد إرسال الإنشاء، اعتبار النتيجة “unknown” ثم فحص قائمة الفواتير بدل إعادة POST عشوائيًا.

`CartSyncService` يرسل snapshot أو تغيير عنصر بين `SearchCubit` و`ProviderPageCubit` و`CartCubit`. يجب بث التغيير بعد أي mutation ناجح حتى تظل badges والـ floating button متطابقة.

## Activity والفواتير

`ActivityCubit` يحمّل invoices حسب tab مع pagination ويمنع تداخل load/loadMore. `InvoiceDetailsCubit` يحمّل التفاصيل، يلغي invoice، ويرسل review مع الاحتفاظ بالتفاصيل المعروضة عند فشل mutation. بعد إنشاء أو إلغاء invoice يمكن استخدام `AppRefreshCubit.triggerInvoicesRefresh()` لتحديث القائمة.

## Profile وE-Card

`ProfileCubit` يحمل profile كاملًا ثم يحمّل summary بصورة مستقلة؛ فشل summary لا يخفي بيانات الملف. العمليات: تعديل البيانات والصورة، حذف الصورة، تغيير اللغة، تفعيل بطاقة عضو، refresh للملخص، وlogout. `ChangePasswordCubit` منفصل لأن له شاشة وحالة عملية مستقلة.

`ECardCubit` يحمّل `Profile/card-data` ويحافظ على طلب واحد قيد التنفيذ. البطاقة تظهر داخل home preview ويمكن تحديثها بقوة عند تغير بيانات المستخدم.

## أفراد الأسرة

`FamilyMembersCubit` ينفّذ list/create/update/delete. الحد المحلي الحالي `kMaxFamilyMembers = 3`. بعد create/delete يطلق تحديث ملخص profile حتى يتغير العداد والنقاط في الواجهة. شاشة add/edit مشتركة، ويُعاد استخدام نفس Cubit عند الانتقال من القائمة للحفاظ على البيانات.

## الإشعارات

هناك جزآن:

- `NotificationCubit`: pagination، optimistic mark-as-read/mark-all مع rollback عند الفشل، والاستماع للرسائل الجديدة.
- `PushNotificationService`: صلاحيات النظام، FCM token، تسجيل token لدى الخادم، local display، والتعامل مع الضغط/deep links.

الـ repository لا يحاول تسجيل device token إذا لم توجد session. payload الإشعار يجب أن يُحلل دفاعيًا لأن القيم قد تصل كنصوص أو أرقام.

## Content وHelp Center

`ContentType` يربط privacy/refund/terms بـ slug ومفتاح عنوان. `ContentCubit` يمنع تكرار نفس الطلب ويدعم force retry. `ContentScreen` يعرض HTML، و`ContentLinkHandler` يسمح بالروابط الداخلية المعروفة ويفتح http/https/tel/mailto خارجيًا ويرفض schemes غير المدعومة.

`HelpCenterScreen` يعرض قنوات الدعم ويستخدم `UrlLauncherService` لفتح الهاتف والبريد وWhatsApp مع رسائل خطأ مفهومة إذا تعذر الفتح.

## أين أضيف كودًا جديدًا؟

- API DTO: `features/<name>/data/dto` أو `data/models`.
- Retrofit interface: `data/data_source` أو `data/api`.
- business model/contract/use case: `domain`.
- state and user actions: `presentation/cubit`.
- full page: `presentation/pages` أو `screens` بحسب النمط الموجود في feature.
- reusable UI: `presentation/widgets`.
- سلوك مشترك لكل الميزات: `core` فقط إذا كان مستقلًا فعلًا عن feature بعينها.
