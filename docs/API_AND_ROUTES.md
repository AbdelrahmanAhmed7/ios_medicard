# REST API والـ Routes

## إعداد الشبكة العام

- Base URL: `https://medicard-api-v2.medicardeg.com/api/`
- `Accept-Language`: يضاف تلقائيًا بقيمة `ar` أو `en`.
- `Authorization`: يضيفه `AuthInterceptor` عند وجود session. بعض clients القديمة تمرره صراحة كـ `Bearer <token>`.
- timeout الافتراضي في `DioFactory`: راجع المصدر عند تعديل سياسة المهلة أو retry.
- URLs الكاملة الموضحة في الجداول تتجاوز الـ base URL ويجب تغييرها صراحة عند تبديل البيئة.

## Endpoints الرئيسية

المصدر: `lib/service/medicard_api_service.dart`.

| Method | Path | Function | الغرض |
|---|---|---|---|
| POST | `Auth/register` | `register` | إنشاء حساب |
| POST | `Auth/login` | `login` | تسجيل الدخول وإرجاع session |
| POST | `Auth/forgot-password/send-otp` | `sendOtp` | إرسال OTP |
| POST | `Auth/forgot-password/verify-otp` | `verifyOtp` | التحقق من OTP |
| POST | `Auth/forgot-password/reset` | `resetPassword` | تعيين كلمة مرور جديدة |
| GET | `{lang}/Home/GetHomeInfo` | `getHomeInfo` | بيانات home القديمة بالبطاقة |
| GET | `{lang}/Profile/GetPersonalInfo` | `getPersonalInfo` | بيانات الملف القديمة |
| GET | `{lang}/ContactUs/Get` | `getSupportContacts` | قنوات الدعم |
| GET | `mobile/MobileHome` | `getHomeData` | home للمستخدم مع الموقع الاختياري |
| PUT multipart | `{lang}/Profile/UpdateProfile` | `updateProfile` | تحديث profile القديم |
| GET | `Profile` | `getProfile` | profile v2 |
| GET | `Profile/summary` | `getProfileSummary` | العدادات والنقاط والملخص |
| GET | `Profile/card-data` | `getCardData` | بيانات البطاقة الرقمية |
| DELETE | `Profile/profile/image` | `deleteProfileImage` | حذف صورة الملف |
| POST | `CardActivation/member-card/activate` | `activateMemberCard` | تفعيل بطاقة عضو |
| PUT multipart | `Profile` | `updateProfileV2` | تحديث profile v2 والصورة |
| POST | `Auth/change-password` | `changePassword` | تغيير كلمة المرور |
| PUT | `Profile/language` | `changeLanguage` | حفظ لغة المستخدم على الخادم |
| GET | `Content/{slug}` | `getContent` | HTML للسياسات والشروط |
| GET | `FamilyMembers` | `getFamilyMembers` | قائمة أفراد الأسرة |
| GET | `FamilyMembers/{id}` | `getFamilyMember` | فرد واحد |
| POST | `FamilyMembers` | `createFamilyMember` | إضافة فرد |
| PUT | `FamilyMembers/{id}` | `updateFamilyMember` | تعديل فرد |
| DELETE | `FamilyMembers/{id}` | `deleteFamilyMember` | حذف فرد |
| GET | `GuestMobileHome/guest` | `getGuestHomeData` | home العام مع الموقع الاختياري |

## Provider وPackages

المصدر: `lib/medicard_network/service/medicard_network_api_service.dart`.

| Method | Path | Function | الغرض |
|---|---|---|---|
| GET | `ProviderPage/{providerId}` | `getProviderPage` | تفاصيل مقدم الخدمة |
| GET | `ProviderPage/{providerId}/branchLocations` | `getProviderBranchLocations` | الفروع والمواقع |
| GET | `https://medicard-api-v2.medicardeg.com/services` | `getProviderServices` | خدمات مقدم الخدمة مع search/paging |
| GET | `ProviderPage/{providerId}/reviews` | `getProviderReviews` | التقييمات |
| GET | `ProviderPage/{providerId}/packages` | `getProviderPackages` | باقات مقدم الخدمة |
| GET | `Package/{packageId}` | `getPackageDetails` | تفاصيل باقة |
| GET | `Package` | `getAllPackages` | كل الباقات مع search/paging |
| GET | `CategoryService/providerCategories` | `getProviderCategories` | فئات خدمات مقدم الخدمة |
| GET | `ProviderPage/servicesByCategory` | `getServicesByCategory` | خدمات فئة لدى مقدم محدد |

## Search

المصدر: `lib/features/search/data/data_sources/search_remote_data_source.dart`.

| Method | Path | Function | أهم المدخلات |
|---|---|---|---|
| GET | `Search/providers` | `searchProviders` | keyword/category/location/sort/page |
| GET | `Lookups/categories` | `getCategories` | لا يوجد |
| GET | `CategoryService/categories` | `getServiceCategories` | لا يوجد |
| GET | `Lookups/governorates` | `getGovernorates` | لا يوجد |
| GET | `Lookups/cities` | `getCities` | `governorateId` |
| GET | `Cart/category/{categoryId}/services` | `getCategoryServices` | category/page؛ يمكن تخطي auth للعرض العام |
| GET | `GuestMobileHome/servicesByCategory` | `getGuestCategoryServices` | category/search/page |

## Cart

المصدر: `lib/features/cart/data/api/cart_remote_data_source.dart`.

| Method | Path | Function | الغرض |
|---|---|---|---|
| GET | `Cart` | `getCart` | السلة الحالية |
| POST | `Cart` | `addToCart` | إضافة خدمة |
| DELETE | `Cart?ServiceId=...` | `removeFromCart` | حذف خدمة |
| GET | `Cart/category/{categoryId}/services` | `getCategoryServices` | خدمات الفئة وحالة الاختيار |
| DELETE | `Cart/clear` | `clearCart` | مسح السلة |
| GET | `Cart/choose-providers` | `getChooseProviders` | مقدمو الخدمة وتغطية العناصر |
| PUT | `https://medicard-api-v2.medicardeg.com/update` | `updateCartProvider` | تعيين provider للسلة؛ URL كامل خارج `/api/` |

## Invoices وReviews

المصدر: `lib/features/activity/data/data_source/invoice_remote_data_source.dart`.

| Method | Path | Function | الغرض |
|---|---|---|---|
| GET | `Invoice/my-invoices` | `getMyInvoices` | invoices حسب tab مع pagination |
| POST | `Invoice/from-package` | `createFromPackage` | إنشاء invoice من باقة |
| POST | `ProviderBranchView/invoices/create-from-cart` | `createFromCart` | إنشاء invoice من السلة |
| GET | `ProviderBranchView/invoices/{invoiceId}/details` | `getInvoiceDetails` | تفاصيل invoice |
| POST | `Review/reviews` | `createReview` | إرسال تقييم |
| PUT | `Invoice/cancel/{invoiceId}` | `cancelInvoice` | إلغاء invoice |

## Notifications

المصدر: `lib/features/notifications/data/notification_client.dart`.

| Method | Path | Function | الغرض |
|---|---|---|---|
| GET | `Notification` | `getNotifications` | القائمة مع pagination |
| POST | `Notification/send` | `sendNotification` | إرسال إشعار عبر API |
| PUT | `Notification/{id}/read` | `markAsRead` | تعليم إشعار كمقروء |
| PUT | `Notification/read-all` | `markAllAsRead` | تعليم الكل كمقروء |
| POST | `Notification/register-device-token` | `registerDeviceToken` | ربط FCM token بالمستخدم والمنصة |

## GoRouter paths

المصدر: `lib/core/routing/app_router.dart`.

| Path | الشاشة / السلوك | `state.extra` أو query |
|---|---|---|
| `/`, `/Home`, `/home` | redirect | إلى guest أو authenticated home حسب alias |
| `/onboarding` | redirect حاليًا | إلى `/guest-home` |
| `/guest-home` | `GuestHomeScreen` | لا يوجد |
| `/medicard-login` | `MediCardLoginScreen` | لا يوجد |
| `/medicard-register` | `RegisterScreen` | لا يوجد |
| `/forgot-password` | `ForgotPasswordScreen` | لا يوجد |
| `/forgot-password/verify` | `OtpVerificationScreen` | map: `phoneNumber`, `otp` |
| `/forgot-password/reset` | `ResetPasswordScreen` | map: `phoneNumber`, `token` |
| `/medicard-activation` | `ActivateCardScreen` | لا يوجد |
| `/medicard-home` | `HomeScreen` | query `tab=activity` يفتح تبويب النشاط |
| `/notifications` | `NotificationsScreen` | لا يوجد |
| `/medicard-profile` | `ProfileScreen` | لا يوجد |
| `/medicard-edit-profile-new` | `EditProfileScreen` | map: `profileData`, و`profileCubit?` |
| `/change-password` | `ChangePasswordScreen` | لا يوجد |
| `/search` | `SearchScreen` | map اختياري: `userLatitude`, `userLongitude`, `categoryId`, `initialTabIndex`, `enableCartFeatures` |
| `/search/providers` | providers tab | نفس مدخلات search عدا tab ثابت 0 |
| `/search/services` | services tab | نفس مدخلات search عدا tab ثابت 1 |
| `/packages` | `AllPackagesScreen` | لا يوجد |
| `/privacy-policy` | `ContentScreen` | النوع ثابت |
| `/refund-policy` | `ContentScreen` | النوع ثابت |
| `/terms-and-conditions` | `ContentScreen` | النوع ثابت |
| `/family-members` | القائمة | لا يوجد |
| `/family-members/add` | add screen | `FamilyMembersCubit?` لإعادة الاستخدام |
| `/family-members/edit` | edit screen | `FamilyMemberModel` أو map: `member`, `cubit?` |
| `/cart` | `CartScreen` | map اختياري: `providerId`, `selectedBranch` |
| `/checkout` | `CheckoutScreen` | map اختياري: `cubit`, `providerId`, `selectedBranch`, وبيانات package |
| `/invoice-details` | `InvoiceDetailsScreen` | map: `invoice`, `tab?` |
| `/choose-provider` | `ChooseProviderScreen` | `CartCubit?` |
| `/pending-appointment-details` | تفاصيل الموعد | `AppointmentModel` |
| `/provider-page` | `ProviderPageScreen` | `int providerId` أو map: `providerId`, `autoOpenPackageId?` |
| `/provider-branches` | `BranchesScreen` | list فروع أو map: `branches`, `providerName?` |
| `/provider-reviews` | `ReviewsScreen` | map: `cubit`, `providerId`, `providerName?` |

### قواعد مهمة عند التنقل

- `state.extra` غير متسلسل؛ لا تعتمد عليه وحده في deep links خارج التطبيق.
- افحص النوع قبل cast عندما يسمح route بأكثر من شكل، كما يحدث في provider/family routes.
- استخدم `BlocProvider.value` فقط لإعادة استخدام Cubit موجود ولا تغلقه الشاشة الجديدة.
- أضف alias داخل `normalizeLocation` إذا كان تغيير path يجب أن يحافظ على روابط قديمة.
