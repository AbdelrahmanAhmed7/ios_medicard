import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/foundation.dart';
import 'dart:async';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:medicard/core/constants/api_result.dart';
import 'package:medicard/core/theming/app_toast.dart';
import 'package:medicard/core/utils/api_error_parser.dart';
import '../../data/models/profile_response_model.dart';
import '../../data/models/profile_summary_response_model.dart';
import '../../domain/usecases/get_profile_usecase.dart';
import '../../domain/usecases/get_profile_summary_usecase.dart';
import '../../domain/usecases/update_profile_v2_usecase.dart';
import '../../domain/usecases/delete_profile_image_usecase.dart';
import '../../domain/usecases/change_language_usecase.dart';
import '../../domain/usecases/activate_member_card_usecase.dart';
import '../../../../domain/usecases/logout_usecase.dart';
import 'profile_state.dart';

class ProfileCubit extends Cubit<ProfileState> {
  final GetProfileUseCase _getProfileUseCase;
  final GetProfileSummaryUseCase _getProfileSummaryUseCase;
  final UpdateProfileV2UseCase _updateProfileUseCase;
  final DeleteProfileImageUseCase _deleteProfileImageUseCase;
  final ChangeLanguageUseCase _changeLanguageUseCase;
  final ActivateMemberCardUseCase _activateMemberCardUseCase;
  final LogoutUseCase _logoutUseCase;
  Future<void>? _profileLoad;
  ProfileSummaryData? _summary;

  ProfileCubit(
    this._getProfileUseCase,
    this._getProfileSummaryUseCase,
    this._updateProfileUseCase,
    this._deleteProfileImageUseCase,
    this._changeLanguageUseCase,
    this._activateMemberCardUseCase,
    this._logoutUseCase,
  ) : super(const ProfileState.initial());

  Future<void> loadProfile({bool forceRefresh = false}) {
    if (isClosed) return Future.value();

    final activeLoad = _profileLoad;
    if (activeLoad != null) {
      if (kDebugMode) {
        debugPrint('[ProfileCubit] loadProfile joined in-flight request');
      }
      return activeLoad;
    }

    final hasProfile = state.maybeWhen(
      success: (_, _) => true,
      updating: (_, _) => true,
      updated: (_, _) => true,
      orElse: () => false,
    );
    if (hasProfile && !forceRefresh) {
      if (kDebugMode) {
        debugPrint('[ProfileCubit] loadProfile skipped; cached data retained');
      }
      return Future.value();
    }

    if (kDebugMode) {
      debugPrint(
        '[ProfileCubit] loadProfile called (forceRefresh=$forceRefresh)',
      );
    }
    final load = _performProfileLoad();
    _profileLoad = load;
    return load.whenComplete(() {
      if (identical(_profileLoad, load)) _profileLoad = null;
    });
  }

  Future<void> _performProfileLoad() async {
    if (isClosed) return;
    // Don't flash loading shimmer when called after an update — the ProfileContent
    // is already visible with the current data. Only show loading on a cold fetch.
    final isUpdating = state.maybeWhen(
      updating: (_, _) => true,
      orElse: () => false,
    );
    if (!isUpdating) {
      emit(const ProfileState.loading());
    }
    try {
      final result = await _getProfileUseCase.call();
      if (isClosed) return;
      result.when(
        success: (data) {
          if (isClosed) return;
          final profile = data.data;
          if (profile == null) {
            if (kDebugMode) {
              debugPrint('[ProfileCubit] response contained no profile data');
            }
            emit(ProfileState.failed('profile.profile_data_unavailable'.tr()));
            return;
          }
          if (kDebugMode) {
            debugPrint('[ProfileCubit] profile loaded successfully');
          }
          // Keep the last known summary visible while its independent request
          // is refreshed. This prevents points/counts flashing back to zero
          // after returning from a child page or refreshing profile details.
          emit(ProfileState.success(profile, _summary));
          // Secondary fetch: must never block or toast; failures stay silent
          // (logged) and null data keeps the zero defaults on screen.
          unawaited(_loadSummary(profile));
        },
        failure: (message) {
          if (isClosed) return;
          if (kDebugMode) {
            debugPrint('[ProfileCubit] profile load failed: $message');
          }
          emit(ProfileState.failed(message));
        },
      );
    } catch (e) {
      if (isClosed) return;
      if (kDebugMode) debugPrint('[ProfileCubit] profile load exception: $e');
      emit(ProfileState.failed(parseApiError(e)));
    }
  }

  Future<bool> updateProfile({
    required String firstName,
    required String lastName,
    required String phoneNumber,
    required String nationalId,
    String? passportNumber,
    required bool isMale,
    required String birthDate,
    String? imagePath,
    bool removeImage = false,
    required ProfileData currentData,
  }) async {
    if (isClosed) return false;
    final optimisticData = ProfileData(
      firstName: firstName,
      lastName: lastName,
      phoneNumber: phoneNumber,
      nationalId: nationalId,
      cardNumber: currentData.cardNumber,
      passportNumber: passportNumber,
      isMale: isMale,
      birthDate: birthDate,
      // ProfileAvatar supports local file paths. Keeping the selected file in
      // state makes the new photo visible immediately after a slow upload,
      // instead of waiting for the server URL and its stale image cache.
      imageUrl: removeImage ? null : imagePath ?? currentData.imageUrl,
    );
    emit(ProfileState.updating(optimisticData, _summary));
    try {
      final result = await _updateProfileUseCase.call(
        firstName: firstName,
        lastName: lastName,
        phoneNumber: phoneNumber,
        nationalId: nationalId,
        passportNumber: passportNumber,
        isMale: isMale,
        birthDate: birthDate,
        imagePath: imagePath,
        removeImage: removeImage,
        currentImageUrl: currentData.imageUrl,
      );
      if (isClosed) return false;

      // Extract success/failure synchronously first.
      final failure = result.when(
        success: (_) => null,
        failure: (message) => message,
      );

      if (failure != null) {
        showErrorToast(failure);
        if (!isClosed) emit(ProfileState.success(currentData, _summary));
        return false;
      }

      if (imagePath != null &&
          currentData.imageUrl?.trim().isNotEmpty == true) {
        // The backend can keep the same URL after replacing the file. Remove
        // both memory/disk cached copies so the next cold profile load cannot
        // display the old photo under that URL.
        await CachedNetworkImage.evictFromCache(currentData.imageUrl!.trim());
      }
      if (isClosed) return false;

      // The update request already succeeded. Publishing the submitted data
      // avoids a second network round-trip and keeps the selected local image
      // visible immediately; the next normal profile load reconciles with the
      // backend response.
      emit(ProfileState.success(optimisticData, _summary));
      showSuccessToast('profile.updated_successfully'.tr());
      return true;
    } catch (e) {
      if (isClosed) return false;
      showErrorToast(parseApiError(e));
      if (!isClosed) emit(ProfileState.success(currentData, _summary));
      return false;
    }
  }

  Future<void> changeLanguage({required String language}) async {
    if (isClosed) return;
    try {
      final result = await _changeLanguageUseCase.call(language: language);
      if (isClosed) return;
      result.when(
        success: (response) {
          if (isClosed) return;
          showSuccessToast('profile.language_changed_successfully'.tr());
        },
        failure: (message) {
          if (isClosed) return;
          showErrorToast(message);
        },
      );
    } catch (e) {
      if (isClosed) return;
      showErrorToast(parseApiError(e));
    }
  }

  Future<bool> deleteProfileImage(ProfileData currentData) async {
    if (isClosed) return false;
    emit(ProfileState.updating(currentData, _summary));
    try {
      final result = await _deleteProfileImageUseCase.call();
      if (isClosed) return false;

      final failure = result.when(
        success: (_) => null,
        failure: (message) => message,
      );
      if (failure != null) {
        if (failure.trim().isNotEmpty) {
          showErrorToast(failure);
        }
        if (!isClosed) emit(ProfileState.success(currentData, _summary));
        return false;
      }

      showSuccessToast('profile.image_deleted_successfully'.tr());
      await _performProfileLoad();
      return true;
    } catch (e) {
      if (isClosed) return false;
      final message = parseApiError(e);
      if (message.trim().isNotEmpty) {
        showErrorToast(message);
      }
      if (!isClosed) emit(ProfileState.success(currentData, _summary));
      return false;
    }
  }

  Future<bool> activateMemberCard({
    required String cardNumber,
    required ProfileData currentData,
  }) async {
    if (isClosed) return false;
    emit(ProfileState.updating(currentData, _summary));
    try {
      final result = await _activateMemberCardUseCase.call(
        cardNumber: cardNumber,
      );
      if (isClosed) return false;

      final failure = result.when(
        success: (_) => null,
        failure: (message) => message,
      );
      if (failure != null) {
        showErrorToast(failure);
        if (!isClosed) emit(ProfileState.success(currentData, _summary));
        return false;
      }

      showSuccessToast('profile.card_activated_successfully'.tr());
      await _performProfileLoad();
      return true;
    } catch (e) {
      if (isClosed) return false;
      showErrorToast(parseApiError(e));
      if (!isClosed) emit(ProfileState.success(currentData, _summary));
      return false;
    }
  }

  /// Silently re-fetches the summary (family count + reward points) and
  /// re-emits it on the current profile — no shimmer, no toast, no action
  /// required from the user. Used when another screen mutates data that the
  /// summary reflects (e.g. family member added/deleted).
  Future<void> refreshSummary() async {
    if (isClosed) return;
    final profile = state.maybeWhen(
      success: (data, _) => data,
      updating: (data, _) => data,
      updated: (data, _) => data,
      orElse: () => null,
    );
    // TEMP-PROFILE-REFRESH: remove after verifying on device.
    debugPrint('[TEMP] refreshSummary called, hasProfile=${profile != null}');
    if (profile == null) return;
    await _loadSummary(profile);
  }

  /// Loads reward points + family count after the profile is shown.
  /// Never throws, never toasts: the profile is already visible and this is
  /// additive data. Null data (backend has no summary yet) keeps defaults.
  Future<void> _loadSummary(ProfileData profile) async {
    final result = await _getProfileSummaryUseCase.call();
    if (isClosed) return;
    result.when(
      success: (response) {
        if (isClosed) return;
        final summary = response.data;
        if (summary == null) {
          if (kDebugMode) {
            debugPrint('[ProfileCubit] summary empty; keeping defaults');
          }
          return;
        }
        _summary = summary;
        // Re-emit only if the profile hasn't moved on meanwhile (e.g. an
        // update started) so we never clobber fresher state.
        final same = state.maybeWhen(
          success: (data, _) => identical(data, profile),
          updating: (data, _) => identical(data, profile),
          updated: (data, _) => identical(data, profile),
          orElse: () => false,
        );
        // TEMP-PROFILE-REFRESH: remove after verifying on device.
        debugPrint(
          '[TEMP] summary arrived: count=${summary.familyMembersCount} '
          'points=${summary.rewardPoints} same=$same',
        );
        if (!same) return;
        state.maybeWhen(
          success: (data, _) => emit(ProfileState.success(data, summary)),
          updating: (data, _) => emit(ProfileState.updating(data, summary)),
          updated: (data, _) => emit(ProfileState.updated(data, summary)),
          orElse: () {},
        );
      },
      failure: (message) {
        if (kDebugMode) {
          debugPrint('[ProfileCubit] summary failed: $message');
        }
      },
    );
  }

  /// Single teardown point for a user-initiated sign-out. Screens navigate,
  /// never clear: the credential-storage details live in [LogoutUseCase].
  Future<void> logout() => _logoutUseCase();
}
