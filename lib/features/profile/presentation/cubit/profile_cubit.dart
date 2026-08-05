import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/foundation.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:medicard/core/constants/api_result.dart';
import 'package:medicard/core/theming/app_toast.dart';
import 'package:medicard/core/utils/api_error_parser.dart';
import '../../data/models/profile_response_model.dart';
import '../../domain/usecases/get_profile_usecase.dart';
import '../../domain/usecases/update_profile_v2_usecase.dart';
import '../../domain/usecases/change_language_usecase.dart';
import 'profile_state.dart';

class ProfileCubit extends Cubit<ProfileState> {
  final GetProfileUseCase _getProfileUseCase;
  final UpdateProfileV2UseCase _updateProfileUseCase;
  final ChangeLanguageUseCase _changeLanguageUseCase;
  Future<void>? _profileLoad;

  ProfileCubit(
    this._getProfileUseCase,
    this._updateProfileUseCase,
    this._changeLanguageUseCase,
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
      success: (_) => true,
      updating: (_) => true,
      updated: (_) => true,
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
    final isUpdating = state.maybeWhen(updating: (_) => true, orElse: () => false);
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
          emit(ProfileState.success(profile));
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
    required ProfileData currentData,
  }) async {
    if (isClosed) return false;
    emit(ProfileState.updating(currentData));
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
      );
      if (isClosed) return false;

      // Extract success/failure synchronously first.
      final failure = result.when(
        success: (_) => null,
        failure: (message) => message,
      );

      if (failure != null) {
        showErrorToast(failure);
        if (!isClosed) emit(ProfileState.success(currentData));
        return false;
      }

      // PUT succeeded — re-fetch from API so the state reflects exactly
      // what the backend persisted (imageUrl, cardNumber, etc.).
      showSuccessToast('profile.updated_successfully'.tr());
      await _performProfileLoad();
      return true;
    } catch (e) {
      if (isClosed) return false;
      showErrorToast(parseApiError(e));
      if (!isClosed) emit(ProfileState.success(currentData));
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
}
