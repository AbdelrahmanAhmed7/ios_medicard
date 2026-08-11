import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
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
import '../features/home/domain/models/home_failure.dart';
import '../core/network/app_failure.dart';
import '../core/network/error_mapper.dart';
import '../features/profile/data/models/change_password_request_model.dart';
import '../features/profile/data/models/change_password_response_model.dart';
import '../features/profile/data/models/change_language_request_model.dart';
import '../features/profile/data/models/change_language_response_model.dart';
import '../features/guest_home/data/models/guest_home_response_model.dart';
import '../features/profile/data/models/profile_response_model.dart';
import '../features/profile/data/models/member_card_activation_response_model.dart';
import '../features/ecard/data/models/card_data_response_model.dart';
import '../service/medicard_api_service.dart';

class MedicardRepositoryImpl implements MedicardRepository {
  final MedicardApiService _apiService;

  MedicardRepositoryImpl(this._apiService);

  String _formatApiMessages(dynamic value) {
    if (value == null) return '';
    if (value is String) return value.trim();
    if (value is Iterable) {
      return value
          .map(_formatApiMessages)
          .where((message) => message.isNotEmpty)
          .join('\n');
    }
    if (value is Map) {
      return value.values
          .map(_formatApiMessages)
          .where((message) => message.isNotEmpty)
          .join('\n');
    }
    return value.toString().trim();
  }

  String _friendlyChangePasswordMessage(String message) {
    final lower = message.toLowerCase();
    if (lower.contains('password') &&
        (lower.contains('incorrect') ||
            lower.contains('invalid') ||
            lower.contains('wrong'))) {
      return parseApiError(message);
    }
    return message;
  }

  bool _isRegisterSuccess(AuthResponseModel response) {
    final hasToken = response.data?.token?.isNotEmpty == true;
    final innerSuccess = response.data?.success == true;
    final successfulStatus =
        response.httpStatusCode != null &&
        response.httpStatusCode! >= 200 &&
        response.httpStatusCode! < 300;

    return response.succeeded || innerSuccess || successfulStatus || hasToken;
  }

  bool _isLoginSuccess(AuthResponseModel response) {
    final hasToken = response.data?.token?.isNotEmpty == true;
    final innerSuccess = response.data?.success == true;
    final successfulStatus =
        response.httpStatusCode != null &&
        response.httpStatusCode! >= 200 &&
        response.httpStatusCode! < 300;

    return hasToken && (response.succeeded || innerSuccess || successfulStatus);
  }

  String _authFailureMessage(AuthResponseModel response) {
    return (response.errors != null && response.errors!.isNotEmpty)
        ? response.errors!.join('\n')
        : response.message?.isNotEmpty == true
        ? response.message!
        : response.data?.message?.isNotEmpty == true
        ? response.data!.message!
        : parseApiError('');
  }

  @override
  Future<ApiResult<AuthResponseModel>> register(
    AuthRegisterRequestModel request,
  ) async {
    try {
      final response = await _apiService.register(request);

      return _isRegisterSuccess(response)
          ? ApiResult.success(response)
          : ApiResult.failure(_authFailureMessage(response));
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

      return _isLoginSuccess(response)
          ? ApiResult.success(response)
          : ApiResult.failure(_authFailureMessage(response));
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
      if (kDebugMode) debugPrint('[HomeRepository] requesting Home data');
      final response = await _apiService.getHomeData(latitude, longitude);
      if (kDebugMode) {
        debugPrint(
          '[HomeRepository] Home response received (succeeded=${response.succeeded})',
        );
      }

      return (response.succeeded == true && response.data != null)
          ? ApiResult.success(response)
          : ApiResult.failure(HomeFailureType.server.code);
    } catch (error) {
      if (kDebugMode) {
        debugPrint(
          '[HomeRepository] Home request exception: ${error.runtimeType} $error',
        );
      }
      final appFailure = error is DioException
          ? (error.error is AppFailure
                ? error.error! as AppFailure
                : mapDioException(error))
          : const AppFailure.unexpected();
      final failure = homeFailureFromAppFailure(appFailure);
      if (kDebugMode) {
        debugPrint(
          '[HomeRepository] Home request failed (category=${failure.name})',
        );
      }
      return ApiResult.failure(failure.code);
    }
  }

  @override
  Future<ApiResult<ProfileResponseModel>> getProfile() async {
    try {
      if (kDebugMode) debugPrint('[ProfileRepository] requesting profile');
      final response = await _apiService.getProfile();
      if (kDebugMode) {
        debugPrint(
          '[ProfileRepository] profile response received (succeeded=${response.succeeded})',
        );
      }

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
      if (kDebugMode) {
        debugPrint('[ProfileRepository] profile request exception: $error');
      }
      return ApiResult.failure(parseApiError(error));
    }
  }

  @override
  Future<ApiResult<ProfileResponseModel>> deleteProfileImage() async {
    try {
      if (kDebugMode) debugPrint('[ProfileRepository] deleting profile image');
      final response = await _apiService.deleteProfileImage();
      if (kDebugMode) {
        debugPrint(
          '[ProfileRepository] delete image response received '
          '(succeeded=${response.succeeded}, message=${response.message})',
        );
      }
      // The DELETE endpoint returns succeeded=true with data=null on success.
      return (response.succeeded == true)
          ? ApiResult.success(response)
          : ApiResult.failure(
              (response.errors != null && response.errors!.isNotEmpty)
                  ? response.errors!.join('\n')
                  : response.message?.isNotEmpty == true
                  ? response.message!
                  : 'Failed to delete profile image.',
            );
    } catch (error) {
      if (kDebugMode) {
        debugPrint('[ProfileRepository] delete image exception: $error');
      }
      return ApiResult.failure(parseApiError(error));
    }
  }

  @override
  Future<ApiResult<MemberCardActivationResponseModel>> activateMemberCard({
    required String cardNumber,
  }) async {
    try {
      if (kDebugMode) {
        debugPrint('[ProfileRepository] activating member card');
      }
      final response = await _apiService.activateMemberCard({
        'cardNumber': cardNumber,
      });
      if (kDebugMode) {
        debugPrint(
          '[ProfileRepository] activate card response received '
          '(succeeded=${response.succeeded}, message=${response.message})',
        );
      }
      return (response.succeeded == true)
          ? ApiResult.success(response)
          : ApiResult.failure(
              (response.errors != null && response.errors!.isNotEmpty)
                  ? response.errors!.join('\n')
                  : response.message?.isNotEmpty == true
                  ? response.message!
                  : 'Failed to activate member card.',
            );
    } catch (error) {
      if (kDebugMode) {
        debugPrint('[ProfileRepository] activate card exception: $error');
      }
      return ApiResult.failure(parseApiError(error));
    }
  }

  @override
  Future<ApiResult<CardDataResponseModel>> getCardData() async {
    try {
      if (kDebugMode) debugPrint('[ECardRepository] requesting card data');
      final response = await _apiService.getCardData();
      if (kDebugMode) {
        debugPrint(
          '[ECardRepository] card-data received '
          '(succeeded=${response.succeeded}, hasData=${response.data != null})',
        );
      }

      // Backend may return card payload with succeeded=false; treat data presence
      // as success, and null data as an empty (no-card) result.
      final hasHardErrors =
          response.errors != null && response.errors!.isNotEmpty;
      if (hasHardErrors && response.data == null) {
        return ApiResult.failure(response.errors!.join('\n'));
      }

      return ApiResult.success(response);
    } catch (error) {
      if (kDebugMode) {
        debugPrint('[ECardRepository] card-data request exception: $error');
      }
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
    bool removeImage = false,
    String? currentImageUrl,
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
      if (imagePart == null) {
        // The backend always expects an Image part. An empty part removes the
        // photo; otherwise the current photo is re-sent so it is kept.
        if (removeImage) {
          imagePart = MultipartFile.fromBytes(const [], filename: '');
        } else if (currentImageUrl != null &&
            _hasValidImageUrl(currentImageUrl)) {
          imagePart = await _downloadImageFile(currentImageUrl);
          imagePart ??= MultipartFile.fromBytes(const [], filename: '');
        } else {
          imagePart = MultipartFile.fromBytes(const [], filename: '');
        }
      }
      final response = await _apiService.updateProfileV2(
        firstName.trim(),
        lastName.trim(),
        phoneNumber.trim(),
        nationalId.trim(),
        passportNumber?.trim(),
        isMale,
        birthDate,
        imagePart,
      );
      if (kDebugMode) {
        debugPrint(
          '[ProfileRepository] updateProfileV2 response: succeeded=${response.succeeded}, message=${response.message}, hasData=${response.data != null}',
        );
      }
      // The PUT endpoint returns succeeded=true with data=null on success.
      // Treat any 2xx with succeeded=true as a successful update.
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
      if (kDebugMode) {
        debugPrint('[ProfileRepository] updateProfileV2 error: ${error.runtimeType} $error');
      }
      return ApiResult.failure(parseApiError(error));
    }
  }

  bool _hasValidImageUrl(String? url) {
    if (url == null || url.isEmpty) return false;
    final uri = Uri.tryParse(url);
    if (uri == null) return false;
    final pathSegments = uri.pathSegments.where((s) => s.isNotEmpty).toList();
    return pathSegments.isNotEmpty;
  }

  Future<MultipartFile?> _downloadImageFile(String url) async {
    try {
      final response = await Dio().get<List<int>>(
        url,
        options: Options(
          responseType: ResponseType.bytes,
          headers: const {'Accept': 'image/*, */*;q=0.8'},
        ),
      );
      final bytes = response.data;
      if (bytes == null || bytes.isEmpty) return null;
      return MultipartFile.fromBytes(bytes, filename: 'profile_pic');
    } catch (error) {
      if (kDebugMode) {
        debugPrint('[ProfileRepository] download current image failed: $error');
      }
      return null;
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
      final isSuccess =
          (response.succeeded == true) || (response.success == true);
      return isSuccess
          ? ApiResult.success(response)
          : ApiResult.failure(
              _friendlyChangePasswordMessage(
                _formatApiMessages(response.errors).isNotEmpty
                    ? _formatApiMessages(response.errors)
                    : response.message?.trim().isNotEmpty == true
                    ? response.message!.trim()
                    : 'Failed to change password.',
              ),
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
      final request = ChangeLanguageRequestModel(language: language);
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
      final response = await _apiService.getGuestHomeData(latitude, longitude);

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
