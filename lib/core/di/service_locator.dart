import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';

import '../../core/cubit/app_refresh_cubit.dart';
import '../../core/cubit/localization_cubit.dart';
import '../../core/services/app_language_manager.dart';
import '../../domain/medicard_repository.dart';
import '../../domain/usecases/get_home_info_usecase.dart';
import '../../domain/usecases/get_personal_info_usecase.dart';
import '../../domain/usecases/get_support_contacts_usecase.dart';
import '../../domain/usecases/get_top_providers_slider_usecase.dart';
import '../../domain/usecases/login_card_usecase.dart';
import '../../domain/usecases/register_usecase.dart';
import '../../domain/usecases/update_profile_usecase.dart';
import '../../features/home/domain/usecases/get_home_data_usecase.dart';
import '../../features/home/presentation/cubit/home_cubit.dart';
import '../../features/home/presentation/cubit/location_cubit.dart';
import '../../features/notifications/data/domain/notification_repo.dart';
import '../../features/notifications/data/domain/notification_service.dart';
import '../../features/notifications/data/domain/use_cases/get_notifications_use_case.dart';
import '../../features/notifications/data/domain/use_cases/mark_all_notifications_read_use_case.dart';
import '../../features/notifications/data/domain/use_cases/mark_notification_read_use_case.dart';
import '../../features/notifications/data/notification_client.dart';
import '../../features/notifications/presentation/cubit/notifivation_cubit.dart';
import '../../features/profile/domain/usecases/change_password_usecase.dart';
import '../../features/search/data/data_sources/search_remote_data_source.dart';
import '../../features/search/data/repositories/search_repository_impl.dart';
import '../../features/search/domain/repositories/search_repository.dart';
import '../../features/search/domain/use_cases/get_categories_use_case.dart';
import '../../features/search/domain/use_cases/get_cities_use_case.dart';
import '../../features/search/domain/use_cases/get_governorates_use_case.dart';
import '../../features/search/domain/use_cases/search_providers_use_case.dart';
import '../../features/search/presentation/cubit/filter_cubit.dart';
import '../../features/search/presentation/cubit/search_cubit.dart';
import '../../features/profile/domain/usecases/get_profile_usecase.dart';
import '../../features/profile/domain/usecases/update_profile_v2_usecase.dart';
import '../../features/profile/domain/usecases/change_language_usecase.dart';
import '../../features/profile/presentation/cubit/change_password_cubit.dart';
import '../../features/profile/presentation/cubit/profile_cubit.dart';
import '../../features/content/data/repositories/content_repository_impl.dart';
import '../../features/content/domain/repositories/content_repository.dart';
import '../../features/content/domain/use_cases/get_content_use_case.dart';
import '../../features/content/presentation/cubit/content_cubit.dart';
import '../../features/family_members/data/repository/family_members_repository_impl.dart';
import '../../features/family_members/domain/repository/family_members_repository.dart';
import '../../features/family_members/presentation/cubit/family_members_cubit.dart';
import '../../features/guest_home/domain/usecases/get_guest_home_data_usecase.dart';
import '../../features/guest_home/presentation/cubit/guest_home_cubit.dart';
import '../../medicard_network/logic/medicard_network_cubit.dart';
import '../../medicard_network/logic/provider_page_cubit.dart';
import '../../medicard_network/repository/medicard_network_repository.dart';
import '../../medicard_network/service/medicard_network_api_service.dart';
import '../../presentation/logic/medicard_home_cubit.dart';
import '../../presentation/logic/medicard_login_cubit.dart';
import '../../presentation/logic/medicard_support_cubit.dart';
import '../../presentation/logic/register_cubit.dart';
import '../../repository/medicard_repository_impl.dart';
import '../../service/medicard_api_service.dart';
import '../network/dio_factory.dart';
import '../services/location_service.dart';
import '../services/location_repository.dart';

final GetIt sl = GetIt.instance;

Future<void> setupServiceLocator() async {
  // Initialize AppLanguageManager first
  await AppLanguageManager.instance.initialize();

  final Dio medicardDio = await DioFactory.getDioForMedicard();

  sl.registerLazySingleton<AppLanguageManager>(
    () => AppLanguageManager.instance,
  );
  sl.registerLazySingleton<AppRefreshCubit>(
    () => AppRefreshCubit(),
  );
  sl.registerFactory<LocalizationCubit>(
    () => LocalizationCubit(
      languageManager: sl<AppLanguageManager>(),
      appRefreshCubit: sl<AppRefreshCubit>(),
    ),
  );

  sl.registerLazySingleton<MedicardApiService>(
    () => MedicardApiService(medicardDio),
  );
  sl.registerLazySingleton<MedicardNetworkApiService>(
    () => MedicardNetworkApiService(medicardDio),
  );
  sl.registerLazySingleton<SearchRemoteDataSource>(
    () => SearchRemoteDataSource(medicardDio),
  );
  sl.registerLazySingleton<NotificationClient>(
    () => NotificationClient(medicardDio),
  );

  sl.registerLazySingleton<MedicardRepository>(
    () => MedicardRepositoryImpl(sl()),
  );
  sl.registerLazySingleton<MedicardNetworkRepository>(
    () => MedicardNetworkRepository(sl()),
  );
  sl.registerLazySingleton<SearchRepository>(() => SearchRepositoryImpl(sl()));
  sl.registerLazySingleton<NotificationService>(() => NotificationService(sl()));
  sl.registerLazySingleton<NotificationRepository>(
    () => NotificationRepository(sl()),
  );
  sl.registerLazySingleton<ContentRepository>(
    () => ContentRepositoryImpl(sl()),
  );
  sl.registerLazySingleton<FamilyMembersRepository>(
    () => FamilyMembersRepositoryImpl(sl()),
  );
  sl.registerLazySingleton<LocationService>(() => LocationService());
  sl.registerLazySingleton<LocationRepository>(() => LocationRepository());

  // UseCases
  sl.registerFactory<LoginCardUseCase>(() => LoginCardUseCase(sl()));
  sl.registerFactory<RegisterUseCase>(() => RegisterUseCase(sl()));
  sl.registerFactory<GetHomeInfoUseCase>(() => GetHomeInfoUseCase(sl()));
  sl.registerFactory<GetPersonalInfoUseCase>(
    () => GetPersonalInfoUseCase(sl()),
  );
  sl.registerFactory<GetSupportContactsUseCase>(
    () => GetSupportContactsUseCase(sl()),
  );
  sl.registerFactory<UpdateProfileUseCase>(() => UpdateProfileUseCase(sl()));
  sl.registerFactory<GetTopProvidersForSliderUseCase>(
    () => GetTopProvidersForSliderUseCase(sl()),
  );
  sl.registerFactory<GetHomeDataUseCase>(() => GetHomeDataUseCase(sl()));
  sl.registerFactory<GetProfileUseCase>(() => GetProfileUseCase(sl()));
  sl.registerFactory<UpdateProfileV2UseCase>(
    () => UpdateProfileV2UseCase(sl()),
  );
  sl.registerFactory<ChangeLanguageUseCase>(() => ChangeLanguageUseCase(sl()));
  sl.registerFactory<ChangePasswordUseCase>(() => ChangePasswordUseCase(sl()));
  sl.registerFactory<GetContentUseCase>(() => GetContentUseCase(sl()));
  sl.registerFactory<GetGuestHomeDataUseCase>(() => GetGuestHomeDataUseCase(sl()));

  // Search use cases
  sl.registerFactory<SearchProvidersUseCase>(
    () => SearchProvidersUseCase(sl()),
  );
  sl.registerFactory<GetCategoriesUseCase>(() => GetCategoriesUseCase(sl()));
  sl.registerFactory<GetGovernoratesUseCase>(
    () => GetGovernoratesUseCase(sl()),
  );
  sl.registerFactory<GetCitiesUseCase>(() => GetCitiesUseCase(sl()));

  // Notification use cases
  sl.registerFactory<GetNotificationsUseCase>(
    () => GetNotificationsUseCase(sl()),
  );
  sl.registerFactory<MarkNotificationReadUseCase>(
    () => MarkNotificationReadUseCase(sl()),
  );
  sl.registerFactory<MarkAllNotificationsReadUseCase>(
    () => MarkAllNotificationsReadUseCase(sl()),
  );

  // Cubits
  sl.registerFactory<MedicardLoginCubit>(() => MedicardLoginCubit(sl()));
  sl.registerFactory<RegisterCubit>(() => RegisterCubit(sl()));
  sl.registerFactory<MedicardHomeCubit>(
    () => MedicardHomeCubit(sl(), sl(), sl()),
  );
  sl.registerFactory<MedicardSupportCubit>(() => MedicardSupportCubit(sl()));
  sl.registerFactory<MedicardNetworkCubit>(() => MedicardNetworkCubit(sl()));
  sl.registerFactoryParam<ProviderPageCubit, int, void>(
    (providerId, _) => ProviderPageCubit(sl(), providerId),
  );
  sl.registerFactory<HomeCubit>(() => HomeCubit(sl(), sl()));
  sl.registerFactory<LocationCubit>(() => LocationCubit(sl(), sl()));
  sl.registerFactory<ProfileCubit>(() => ProfileCubit(sl(), sl(), sl()));
  sl.registerFactory<ChangePasswordCubit>(() => ChangePasswordCubit(sl()));
  sl.registerFactory<ContentCubit>(() => ContentCubit(sl()));
  sl.registerLazySingleton<FamilyMembersCubit>(() => FamilyMembersCubit(sl()));
  sl.registerFactory<GuestHomeCubit>(() => GuestHomeCubit(sl(), sl()));

  // Search cubits
  sl.registerFactory<SearchCubit>(() => SearchCubit(sl(), sl()));
  sl.registerFactory<FilterCubit>(() => FilterCubit(sl(), sl()));

  // Notification cubits
  sl.registerFactory<NotificationCubit>(
    () => NotificationCubit(sl(), sl(), sl()),
  );
}
