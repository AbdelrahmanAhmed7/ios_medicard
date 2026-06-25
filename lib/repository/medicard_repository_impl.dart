import 'dart:io';
import 'package:dio/dio.dart';
import 'package:path/path.dart' show basename;
import '../core/constants/api_result.dart';
import '../core/constants/constants.dart';
import '../core/helpers/shared_pref_helper.dart';
import '../core/utils/api_error_parser.dart';
import '../core/cache/cache_service.dart';
import '../data/card_home_info_response_model.dart';
import '../data/card_personal_info_response_model.dart';
import '../data/card_support_contact_response_model.dart';
import '../data/card_update_profile_request_model.dart';
import '../data/card_update_profile_response_model.dart';
import '../data/auth_register_request_model.dart';
import '../data/auth_login_request_model.dart';
import '../data/auth_response_model.dart';
import '../domain/medicard_repository.dart';
import '../features/home/data/models/home_response_model.dart';
import '../features/profile/data/models/change_password_request_model.dart';
import '../features/profile/data/models/change_password_response_model.dart';
import '../features/profile/data/models/change_language_request_model.dart';
import '../features/profile/data/models/change_language_response_model.dart';
import '../features/guest_home/data/models/guest_home_response_model.dart';
import '../features/profile/data/models/profile_response_model.dart';
import '../service/medicard_api_service.dart';

class MedicardRepositoryImpl implements MedicardRepository {
  final MedicardApiService _apiService;

  MedicardRepositoryImpl(this._apiService);

  @override
  Future<ApiResult<AuthResponseModel>> register(
    AuthRegisterRequestModel request,
  ) async {
    try {
      final response = await _apiService.register(request);

      return (response.succeeded && response.data != null)
          ? ApiResult.success(response)
          : ApiResult.failure(
              (response.errors != null && response.errors!.isNotEmpty)
                  ? response.errors!.join('\n')
                  : response.message?.isNotEmpty == true
                  ? response.message!
                  : 'Something went wrong',
            );
    } catch (error) {
      return ApiResult.failure(parseApiError(error));
    }
  }

  @override
  Future<ApiResult<AuthResponseModel>> login(
    AuthLoginRequestModel request,
  ) async {
    try {
      final response = await _apiService.login(request);

      return (response.succeeded && response.data != null)
          ? ApiResult.success(response)
          : ApiResult.failure(
              (response.errors != null && response.errors!.isNotEmpty)
                  ? response.errors!.join('\n')
                  : response.message?.isNotEmpty == true
                  ? response.message!
                  : 'Something went wrong',
            );
    } catch (error) {
      return ApiResult.failure(parseApiError(error));
    }
  }

  @override
  Future<ApiResult<CardHomeInfoResponseModel>> getHomeInfo(
    String cardNo,
    String lang,
  ) async {
    try {
      final response = await _apiService.getHomeInfo(lang, cardNo);

      return (response.success && response.data != null)
          ? ApiResult.success(response)
          : ApiResult.failure(
              response.message.isNotEmpty
                  ? response.message
                  : 'Failed to get home info.',
            );
    } catch (error) {
      return ApiResult.failure(parseApiError(error));
    }
  }

  @override
  Future<ApiResult<CardPersonalInfoResponseModel>> getPersonalInfo(
    String cardNo,
    String lang,
  ) async {
    try {
      final response = await _apiService.getPersonalInfo(lang, cardNo);

      return (response.success && response.data != null)
          ? ApiResult.success(response)
          : ApiResult.failure(
              response.message.isNotEmpty
                  ? response.message
                  : 'Failed to get personal info.',
            );
    } catch (error) {
      return ApiResult.failure(parseApiError(error));
    }
  }

  @override
  Future<ApiResult<CardSupportContactResponseModel>> getSupportContacts(
    String lang,
  ) async {
    try {
      final cachedData = await CacheService.getCachedSupportContactsData();
      if (cachedData != null) {
        return ApiResult.success(
          CardSupportContactResponseModel.fromJson(cachedData),
        );
      }

      final response = await _apiService.getSupportContacts(lang);

      if (response.success && response.data != null) {
        await CacheService.cacheSupportContactsData(response.toJson());
        return ApiResult.success(response);
      } else {
        return ApiResult.failure(
          response.message.isNotEmpty
              ? response.message
              : 'Failed to get support contacts.',
        );
      }
    } catch (error) {
      return ApiResult.failure(parseApiError(error));
    }
  }

  @override
  Future<ApiResult<CardUpdateProfileResponseModel>> updateProfile(
    CardUpdateProfileRequestModel request,
    String lang,
  ) async {
    try {
      MultipartFile? imagePart;

      if (request.profileImage != null &&
          request.profileImage!.isNotEmpty &&
          !request.profileImage!.startsWith('http')) {
        final file = File(request.profileImage!);

        if (await file.exists()) {
          imagePart = await MultipartFile.fromFile(
            file.path,
            filename: file.path.split('/').last,
          );
        }
      }

      final response = await _apiService.updateProfile(
        lang,
        request.cardNo,
        request.firstName?.trim() ?? "",
        request.lastName?.trim() ?? "",
        request.phoneNumber?.trim() ?? "",
        request.email?.trim() ?? "",
        request.nationalId?.trim() ?? "",
        request.passportNumber?.trim() ?? "",
        request.birthdate,
        request.isMale,
        imagePart,
      );

      if (response.success) {
        return ApiResult.success(response);
      } else {
        return ApiResult.failure(
          response.message.isNotEmpty
              ? response.message
              : 'Failed to update profile.',
        );
      }
    } catch (error) {
      return ApiResult.failure(parseApiError(error));
    }
  }

  @override
  Future<ApiResult<HomeResponseModel>> getHomeData({
    double? latitude,
    double? longitude,
  }) async {
    try {
      final token = await SharedPrefHelper.getSecuredString(
        SharedPrefKeys.userToken,
      );
      final response = await _apiService.getHomeData(
        'Bearer $token',
        latitude,
        longitude,
      );

      return (response.succeeded == true && response.data != null)
          ? ApiResult.success(response)
          : ApiResult.failure(
              (response.errors != null && response.errors!.isNotEmpty)
                  ? response.errors!.join('\n')
                  : response.message?.isNotEmpty == true
                  ? response.message!
                  : 'Failed to get home data.',
            );
    } catch (error) {
      return ApiResult.failure(parseApiError(error));
    }
  }

  @override
  Future<ApiResult<ProfileResponseModel>> getProfile() async {
    try {
      final token = await SharedPrefHelper.getSecuredString(
        SharedPrefKeys.userToken,
      );
      final response = await _apiService.getProfile('Bearer $token');

      return (response.succeeded == true && response.data != null)
          ? ApiResult.success(response)
          : ApiResult.failure(
              (response.errors != null && response.errors!.isNotEmpty)
                  ? response.errors!.join('\n')
                  : response.message?.isNotEmpty == true
                  ? response.message!
                  : 'Failed to get profile.',
            );
    } catch (error) {
      return ApiResult.failure(parseApiError(error));
    }
  }

  @override
  Future<ApiResult<ProfileResponseModel>> updateProfileV2({
    required String firstName,
    required String lastName,
    required String phoneNumber,
    required String nationalId,
    String? passportNumber,
    required bool isMale,
    required String birthDate,
    String? imagePath,
  }) async {
    try {
      MultipartFile? imagePart;
      if (imagePath != null) {
        final file = File(imagePath);
        if (await file.exists()) {
          imagePart = await MultipartFile.fromFile(
            imagePath,
            filename: basename(imagePath),
          );
        }
      }
      final token = await SharedPrefHelper.getSecuredString(
        SharedPrefKeys.userToken,
      );
      final response = await _apiService.updateProfileV2(
        'Bearer $token',
        firstName.trim(),
        lastName.trim(),
        phoneNumber.trim(),
        nationalId.trim(),
        passportNumber?.trim(),
        isMale,
        birthDate,
        imagePart,
      );
      return (response.succeeded == true)
          ? ApiResult.success(response)
          : ApiResult.failure(
              (response.errors != null && response.errors!.isNotEmpty)
                  ? response.errors!.join('\n')
                  : response.message?.isNotEmpty == true
                  ? response.message!
                  : 'Failed to update profile.',
            );
    } catch (error) {
      return ApiResult.failure(parseApiError(error));
    }
  }

  @override
  Future<ApiResult<ChangePasswordResponseModel>> changePassword({
    required String currentPassword,
    required String newPassword,
    required String confirmNewPassword,
  }) async {
    try {
      final token = await SharedPrefHelper.getSecuredString(
        SharedPrefKeys.userToken,
      );
      final request = ChangePasswordRequestModel(
        currentPassword: currentPassword,
        newPassword: newPassword,
        confirmNewPassword: confirmNewPassword,
      );
      final response = await _apiService.changePassword(
        'Bearer $token',
        request.toJson(),
      );
      final isSuccess = (response.succeeded == true) || (response.success == true);
      return isSuccess
          ? ApiResult.success(response)
          : ApiResult.failure(
              (response.errors != null && response.errors!.isNotEmpty)
                  ? response.errors!.join('\n')
                  : response.message?.isNotEmpty == true
                  ? response.message!
                  : 'Failed to change password.',
            );
    } catch (error) {
      return ApiResult.failure(parseApiError(error));
    }
  }

  @override
  Future<ApiResult<ChangeLanguageResponseModel>> changeLanguage({
    required String language,
  }) async {
    try {
      final token = await SharedPrefHelper.getSecuredString(
        SharedPrefKeys.userToken,
      );
      final request = ChangeLanguageRequestModel(
        language: language,
      );
      final response = await _apiService.changeLanguage(
        'Bearer $token',
        request,
      );
      return (response.succeeded == true)
          ? ApiResult.success(response)
          : ApiResult.failure(
              (response.errors != null && response.errors!.isNotEmpty)
                  ? response.errors!.join('\n')
                  : response.message?.isNotEmpty == true
                  ? response.message!
                  : 'Failed to change language.',
            );
    } catch (error) {
      return ApiResult.failure(parseApiError(error));
    }
  }

  @override
  Future<ApiResult<GuestHomeResponseModel>> getGuestHomeData({
    double? latitude,
    double? longitude,
  }) async {
    try {
      final response = await _apiService.getGuestHomeData(
        latitude,
        longitude,
      );

      return (response.succeeded == true && response.data != null)
          ? ApiResult.success(response)
          : ApiResult.failure(
              (response.errors != null && response.errors!.isNotEmpty)
                  ? response.errors!.join('\n')
                  : response.message?.isNotEmpty == true
                  ? response.message!
                  : 'Failed to get guest home data.',
            );
    } catch (error) {
      return ApiResult.failure(parseApiError(error));
    }
  }
}
