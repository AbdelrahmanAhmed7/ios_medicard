import '../core/constants/api_result.dart';
import '../data/card_home_info_response_model.dart';
import '../data/card_personal_info_response_model.dart';
import '../data/card_support_contact_response_model.dart';
import '../data/card_update_profile_request_model.dart';
import '../data/card_update_profile_response_model.dart';
import '../data/auth_register_request_model.dart';
import '../data/auth_login_request_model.dart';
import '../data/auth_response_model.dart';
import '../features/home/data/models/home_response_model.dart';
import '../features/profile/data/models/change_password_response_model.dart';
import '../features/profile/data/models/change_language_response_model.dart';
import '../features/profile/data/models/profile_response_model.dart';

abstract class MedicardRepository {
  Future<ApiResult<AuthResponseModel>> register(
    AuthRegisterRequestModel request,
  );

  Future<ApiResult<AuthResponseModel>> login(AuthLoginRequestModel request);

  Future<ApiResult<CardHomeInfoResponseModel>> getHomeInfo(
    String cardNo,
    String lang,
  );

  Future<ApiResult<CardPersonalInfoResponseModel>> getPersonalInfo(
    String cardNo,
    String lang,
  );

  Future<ApiResult<CardSupportContactResponseModel>> getSupportContacts(
    String lang,
  );

  Future<ApiResult<CardUpdateProfileResponseModel>> updateProfile(
    CardUpdateProfileRequestModel request,
    String lang,
  );

  Future<ApiResult<HomeResponseModel>> getHomeData({
    double? latitude,
    double? longitude,
  });

  Future<ApiResult<ProfileResponseModel>> getProfile();
  Future<ApiResult<ProfileResponseModel>> updateProfileV2({
    required String firstName,
    required String lastName,
    required String phoneNumber,
    required String nationalId,
    String? passportNumber,
    required bool isMale,
    required String birthDate,
    String? imagePath,
  });

  Future<ApiResult<ChangePasswordResponseModel>> changePassword({
    required String currentPassword,
    required String newPassword,
    required String confirmNewPassword,
  });

  Future<ApiResult<ChangeLanguageResponseModel>> changeLanguage({
    required String language,
  });
}
