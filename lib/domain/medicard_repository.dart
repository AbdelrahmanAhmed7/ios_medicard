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
import '../features/guest_home/data/models/guest_home_response_model.dart';
import '../features/profile/data/models/change_password_response_model.dart';
import '../features/profile/data/models/change_language_response_model.dart';
import '../features/profile/data/models/profile_response_model.dart';
import '../features/profile/data/models/profile_summary_response_model.dart';
import '../features/profile/data/models/member_card_activation_response_model.dart';
import '../features/auth/data/models/otp_response_model.dart';
import '../features/ecard/data/models/card_data_response_model.dart';

abstract class MedicardRepository {
  Future<ApiResult<AuthResponseModel>> register(
    AuthRegisterRequestModel request,
  );

  Future<ApiResult<AuthResponseModel>> login(AuthLoginRequestModel request);

  Future<ApiResult<OtpResponseModel>> sendOtp(String phoneNumber);

  Future<ApiResult<OtpResponseModel>> verifyOtp({
    required String phoneNumber,
    required String otp,
  });

  Future<ApiResult<OtpResponseModel>> resetPassword({
    required String phoneNumber,
    required String password,
    required String confirmPassword,
  });

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

  /// Profile summary (reward points, family count). Unlike [getProfile], a
  /// `succeeded` response with null `data` is valid (user has no summary
  /// yet) and arrives as success — the caller treats null data as empty.
  Future<ApiResult<ProfileSummaryResponseModel>> getProfileSummary();

  Future<ApiResult<ProfileResponseModel>> deleteProfileImage();

  Future<ApiResult<MemberCardActivationResponseModel>> activateMemberCard({
    required String cardNumber,
  });

  Future<ApiResult<CardDataResponseModel>> getCardData();

  Future<ApiResult<ProfileResponseModel>> updateProfileV2({
    required String firstName,
    required String lastName,
    required String phoneNumber,
    required String nationalId,
    String? passportNumber,
    required bool isMale,
    required String birthDate,
    String? imagePath,
    bool removeImage = false,
    String? currentImageUrl,
  });

  Future<ApiResult<ChangePasswordResponseModel>> changePassword({
    required String currentPassword,
    required String newPassword,
    required String confirmNewPassword,
  });

  Future<ApiResult<ChangeLanguageResponseModel>> changeLanguage({
    required String language,
  });

  Future<ApiResult<GuestHomeResponseModel>> getGuestHomeData({
    double? latitude,
    double? longitude,
  });
}
