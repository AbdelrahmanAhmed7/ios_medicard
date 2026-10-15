import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';
import '../data/card_home_info_response_model.dart';
import '../data/card_personal_info_response_model.dart';
import '../data/card_support_contact_response_model.dart';
import '../data/card_update_profile_response_model.dart';
import '../data/auth_register_request_model.dart';
import '../data/auth_login_request_model.dart';
import '../data/auth_response_model.dart';
import '../features/home/data/models/home_response_model.dart';
import '../features/profile/data/models/change_language_response_model.dart';
import '../features/profile/data/models/change_password_response_model.dart';
import '../features/profile/data/models/change_language_request_model.dart';
import '../features/profile/data/models/profile_response_model.dart';
import '../features/profile/data/models/profile_summary_response_model.dart';
import '../features/profile/data/models/member_card_activation_response_model.dart';
import '../features/auth/data/models/send_otp_request_model.dart';
import '../features/auth/data/models/verify_otp_request_model.dart';
import '../features/auth/data/models/reset_password_request_model.dart';
import '../features/auth/data/models/otp_response_model.dart';
import '../features/ecard/data/models/card_data_response_model.dart';
import '../features/content/data/models/content_response_model.dart';
import '../features/family_members/data/models/get_family_members_response_model.dart';
import '../features/family_members/data/models/get_family_member_response_model.dart';
import '../features/family_members/data/models/create_family_member_request_model.dart';
import '../features/family_members/data/models/family_member_operation_response_model.dart';
import '../features/addresses/data/models/get_user_addresses_response_model.dart';
import '../features/addresses/data/models/get_user_address_response_model.dart';
import '../features/addresses/data/models/save_user_address_request_model.dart';
import '../features/addresses/data/models/user_address_operation_response_model.dart';
import '../features/search/data/models/lookup_response_model.dart';
import '../features/guest_home/data/models/guest_home_response_model.dart';

part 'medicard_api_service.g.dart';

@RestApi(baseUrl: 'https://medicard-api-v2.medicardeg.com/api/')
abstract class MedicardApiService {
  factory MedicardApiService(Dio dio, {String baseUrl}) = _MedicardApiService;

  @POST("Auth/register")
  Future<AuthResponseModel> register(@Body() AuthRegisterRequestModel request);

  @POST("Auth/login")
  Future<AuthResponseModel> login(@Body() AuthLoginRequestModel request);

  @POST('Auth/forgot-password/send-otp')
  Future<OtpResponseModel> sendOtp(@Body() SendOtpRequestModel request);

  @POST('Auth/forgot-password/verify-otp')
  Future<OtpResponseModel> verifyOtp(@Body() VerifyOtpRequestModel request);

  @POST('Auth/forgot-password/reset')
  Future<OtpResponseModel> resetPassword(
    @Body() ResetPasswordRequestModel request,
  );

  @GET("{lang}/Home/GetHomeInfo")
  Future<CardHomeInfoResponseModel> getHomeInfo(
    @Path("lang") String lang,
    @Query("CardNo") String cardNo,
  );

  @GET("{lang}/Profile/GetPersonalInfo")
  Future<CardPersonalInfoResponseModel> getPersonalInfo(
    @Path("lang") String lang,
    @Query("CardNo") String cardNo,
  );

  @GET("{lang}/ContactUs/Get")
  Future<CardSupportContactResponseModel> getSupportContacts(
    @Path("lang") String lang,
  );

  @GET("mobile/MobileHome")
  Future<HomeResponseModel> getHomeData(
    @Query("latitude") double? latitude,
    @Query("longitude") double? longitude,
  );

  @PUT("{lang}/Profile/UpdateProfile")
  @MultiPart()
  Future<CardUpdateProfileResponseModel> updateProfile(
    @Path("lang") String lang,
    @Part(name: "CardNo") String cardNo,
    @Part(name: "FirstName") String? firstName,
    @Part(name: "LastName") String? lastName,
    @Part(name: "PhoneNumber") String? phoneNumber,
    @Part(name: "Email") String? email,
    @Part(name: "NationalId") String? nationalId,
    @Part(name: "PassportNumber") String? passportNumber,
    @Part(name: "Birthdate") String? birthdate,
    @Part(name: "IsMale") bool? isMale,
    @Part(name: "ProfileImage") MultipartFile? profileImage,
  );

  // ── Profile v2 endpoints (new API) ────────────────────────────────────────

  @GET('Profile')
  Future<ProfileResponseModel> getProfile();

  @GET('Profile/summary')
  Future<ProfileSummaryResponseModel> getProfileSummary();

  @GET('Profile/card-data')
  Future<CardDataResponseModel> getCardData();

  @DELETE('Profile/profile/image')
  Future<ProfileResponseModel> deleteProfileImage();

  @POST('CardActivation/member-card/activate')
  Future<MemberCardActivationResponseModel> activateMemberCard(
    @Body() Map<String, dynamic> body,
  );

  @PUT('Profile')
  @MultiPart()
  Future<ProfileResponseModel> updateProfileV2(
    @Part(name: 'FirstName') String firstName,
    @Part(name: 'LastName') String lastName,
    @Part(name: 'PhoneNumber') String phoneNumber,
    @Part(name: 'NationalId') String nationalId,
    @Part(name: 'PassportNumber') String? passportNumber,
    @Part(name: 'IsMale') bool isMale,
    @Part(name: 'BirthDate') String birthDate,
    @Part(name: 'Image') MultipartFile? image,
  );

  // ── Auth ──────────────────────────────────────────────────────────────────

  @POST('Auth/change-password')
  Future<ChangePasswordResponseModel> changePassword(
    @Header('Authorization') String token,
    @Body() Map<String, dynamic> body,
  );

  @PUT('Profile/language')
  Future<ChangeLanguageResponseModel> changeLanguage(
    @Header('Authorization') String token,
    @Body() ChangeLanguageRequestModel body,
  );

  // ── Content ───────────────────────────────────────────────────────────────

  @GET('/Content/{slug}')
  Future<ContentResponseModel> getContent(@Path('slug') String slug);

  // ── Family Members ────────────────────────────────────────────────────────

  @GET('/FamilyMembers')
  Future<GetFamilyMembersResponseModel> getFamilyMembers();

  @GET('/FamilyMembers/{id}')
  Future<GetFamilyMemberResponseModel> getFamilyMember(
    @Path('id') int id,
  );

  @POST('/FamilyMembers')
  Future<FamilyMemberOperationResponseModel> createFamilyMember(
    @Body() CreateFamilyMemberRequestModel request,
  );

  @PUT('/FamilyMembers/{id}')
  Future<FamilyMemberOperationResponseModel> updateFamilyMember(
    @Path('id') int id,
    @Body() CreateFamilyMemberRequestModel request,
  );

  @DELETE('/FamilyMembers/{id}')
  Future<FamilyMemberOperationResponseModel> deleteFamilyMember(
    @Path('id') int id,
  );

  // ── User Addresses ────────────────────────────────────────────────────────

  @GET('/UserAddress')
  Future<GetUserAddressesResponseModel> getUserAddresses();

  @GET('/UserAddress/{id}')
  Future<GetUserAddressResponseModel> getUserAddress(@Path('id') int id);

  @POST('/UserAddress')
  Future<UserAddressOperationResponseModel> createUserAddress(
    @Body() SaveUserAddressRequestModel request,
  );

  @PUT('/UserAddress/{id}')
  Future<UserAddressOperationResponseModel> updateUserAddress(
    @Path('id') int id,
    @Body() SaveUserAddressRequestModel request,
  );

  @DELETE('/UserAddress/{id}')
  Future<UserAddressOperationResponseModel> deleteUserAddress(
    @Path('id') int id,
  );

  // ── Lookups (governorates / cities) ───────────────────────────────────────

  @GET('/Lookups/governorates')
  Future<LookupResponseModel> getGovernorates();

  @GET('/Lookups/cities')
  Future<LookupResponseModel> getCities(@Query('governorateId') int governorateId);

  // ── Guest Home ────────────────────────────────────────────────────────────

  @GET('/GuestMobileHome/guest')
  Future<GuestHomeResponseModel> getGuestHomeData(
    @Query('latitude') double? latitude,
    @Query('longitude') double? longitude,
  );
}
