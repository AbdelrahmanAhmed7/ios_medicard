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
import '../features/ecard/data/models/card_data_response_model.dart';
import '../features/content/data/models/content_response_model.dart';
import '../features/family_members/data/models/get_family_members_response_model.dart';
import '../features/family_members/data/models/get_family_member_response_model.dart';
import '../features/family_members/data/models/create_family_member_request_model.dart';
import '../features/family_members/data/models/family_member_operation_response_model.dart';
import '../features/guest_home/data/models/guest_home_response_model.dart';

part 'medicard_api_service.g.dart';

@RestApi(baseUrl: 'https://medicard-api-v2.medicardeg.com/api/')
abstract class MedicardApiService {
  factory MedicardApiService(Dio dio, {String baseUrl}) = _MedicardApiService;

  @POST("Auth/register")
  Future<AuthResponseModel> register(@Body() AuthRegisterRequestModel request);

  @POST("Auth/login")
  Future<AuthResponseModel> login(@Body() AuthLoginRequestModel request);

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

  @GET('/Profile')
  Future<ProfileResponseModel> getProfile();

  @GET('Profile/card-data')
  Future<CardDataResponseModel> getCardData();

  @PUT('/Profile')
  @MultiPart()
  Future<ProfileResponseModel> updateProfileV2(
    @Header('Authorization') String token,
    @Part(name: 'FirstName') String firstName,
    @Part(name: 'LastName') String lastName,
    @Part(name: 'PhoneNumber') String phoneNumber,
    @Part(name: 'NationalId') String nationalId,
    @Part(name: 'PassportNumber') String? passportNumber,
    @Part(name: 'IsMale') bool isMale,
    @Part(name: 'BirthDate') String birthDate,
    @Part(name: 'Image') MultipartFile? image,
  );

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

  @GET('/Content/{slug}')
  Future<ContentResponseModel> getContent(@Path('slug') String slug);

  @GET('/FamilyMembers')
  Future<GetFamilyMembersResponseModel> getFamilyMembers(
    @Header('Authorization') String token,
  );

  @GET('/FamilyMembers/{id}')
  Future<GetFamilyMemberResponseModel> getFamilyMember(
    @Header('Authorization') String token,
    @Path('id') int id,
  );

  @POST('/FamilyMembers')
  Future<FamilyMemberOperationResponseModel> createFamilyMember(
    @Header('Authorization') String token,
    @Body() CreateFamilyMemberRequestModel request,
  );

  @PUT('/FamilyMembers/{id}')
  Future<FamilyMemberOperationResponseModel> updateFamilyMember(
    @Header('Authorization') String token,
    @Path('id') int id,
    @Body() CreateFamilyMemberRequestModel request,
  );

  @DELETE('/FamilyMembers/{id}')
  Future<FamilyMemberOperationResponseModel> deleteFamilyMember(
    @Header('Authorization') String token,
    @Path('id') int id,
  );

  @GET('/GuestMobileHome/guest')
  Future<GuestHomeResponseModel> getGuestHomeData(
    @Query('latitude') double? latitude,
    @Query('longitude') double? longitude,
  );
}
