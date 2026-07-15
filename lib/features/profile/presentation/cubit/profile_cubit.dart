import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/foundation.dart';
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

  ProfileCubit(this._getProfileUseCase, this._updateProfileUseCase, this._changeLanguageUseCase)
    : super(const ProfileState.initial());

  Future<void> loadProfile({bool forceRefresh = false}) {
    if (isClosed) return Future.value();

    final activeLoad = _profileLoad;
    if (activeLoad != null) {
      if (kDebugMode) debugPrint('[ProfileCubit] loadProfile joined in-flight request');
      return activeLoad;
    }

    final hasProfile = state.maybeWhen(
      success: (_) => true,
      updating: (_) => true,
      updated: (_) => true,
      orElse: () => false,
    );
    if (hasProfile && !forceRefresh) {
      if (kDebugMode) debugPrint('[ProfileCubit] loadProfile skipped; cached data retained');
      return Future.value();
    }

    if (kDebugMode) {
      debugPrint('[ProfileCubit] loadProfile called (forceRefresh=$forceRefresh)');
    }
    final load = _performProfileLoad();
    _profileLoad = load;
    return load.whenComplete(() {
      if (identical(_profileLoad, load)) _profileLoad = null;
    });
  }

  Future<void> _performProfileLoad() async {
    if (isClosed) return;
    emit(const ProfileState.loading());
    try {
      final result = await _getProfileUseCase.call();
      if (isClosed) return;
      result.when(
        success: (data) {
          if (isClosed) return;
          final profile = data.data;
          if (profile == null) {
            if (kDebugMode) debugPrint('[ProfileCubit] response contained no profile data');
            emit(const ProfileState.failed('Profile data is unavailable.'));
            return;
          }
          if (kDebugMode) debugPrint('[ProfileCubit] profile loaded successfully');
          emit(ProfileState.success(profile));
        },
        failure: (message) {
          if (isClosed) return;
          if (kDebugMode) debugPrint('[ProfileCubit] profile load failed: $message');
          emit(ProfileState.failed(message));
        },
      );
    } catch (e) {
      if (isClosed) return;
      if (kDebugMode) debugPrint('[ProfileCubit] profile load exception: $e');
      emit(ProfileState.failed(parseApiError(e)));
    }
  }

  Future<void> updateProfile({
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
    if (isClosed) return;
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
      if (isClosed) return;
      result.when(
        success: (response) {
          if (isClosed) return;
          showSuccessToast('Profile updated successfully');
          if (isClosed) return;
          if (response.data != null) {
            emit(ProfileState.updated(response.data!));
          }
        },
        failure: (message) {
          if (isClosed) return;
          showErrorToast(message);
          if (isClosed) return;
          emit(ProfileState.success(currentData));
        },
      );
    } catch (e) {
      if (isClosed) return;
      showErrorToast(parseApiError(e));
      if (isClosed) return;
      emit(ProfileState.success(currentData));
    }
  }

  Future<void> changeLanguage({
    required String language,
  }) async {
    if (isClosed) return;
    try {
      final result = await _changeLanguageUseCase.call(
        language: language,
      );
      if (isClosed) return;
      result.when(
        success: (response) {
          if (isClosed) return;
          showSuccessToast('Language changed successfully');
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
