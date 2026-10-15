import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:medicard/core/theming/app_toast.dart';
import 'package:medicard/core/utils/api_error_parser.dart';
import 'package:medicard/features/search/data/models/lookup_model.dart';
import '../../data/models/save_user_address_request_model.dart';
import '../../domain/repository/addresses_repository.dart';
import 'address_form_state.dart';

class AddressFormCubit extends Cubit<AddressFormState> {
  final AddressesRepository repository;

  AddressFormCubit(this.repository) : super(const AddressFormState());

  Future<void> loadGovernorates() async {
    if (isClosed) return;
    emit(state.copyWith(isLoadingGovernorates: true, clearError: true));
    try {
      final governorates = await repository.getGovernorates();
      if (isClosed) return;
      emit(
        state.copyWith(
          governorates: governorates,
          isLoadingGovernorates: false,
        ),
      );
    } catch (e) {
      if (isClosed) return;
      emit(
        state.copyWith(isLoadingGovernorates: false, error: parseApiError(e)),
      );
    }
  }

  Future<void> selectGovernorate(int? governorateId) async {
    if (isClosed) return;
    if (governorateId == null) {
      emit(state.copyWith(cities: const <LookupModel>[]));
      return;
    }
    emit(state.copyWith(isLoadingCities: true, cities: const <LookupModel>[]));
    try {
      final cities = await repository.getCities(governorateId);
      if (isClosed) return;
      emit(state.copyWith(cities: cities, isLoadingCities: false));
    } catch (e) {
      if (isClosed) return;
      emit(state.copyWith(isLoadingCities: false, error: parseApiError(e)));
    }
  }

  Future<void> save({
    required int governorateId,
    required int cityId,
    int? floor,
    int? buildingNumber,
    int? apartmentNumber,
    required int mainAddress,
    required bool isDefault,
    double? latitude,
    double? longitude,
    int? addressId,
  }) async {
    if (isClosed) return;

    emit(state.copyWith(isSaving: true, clearError: true));

    final request = SaveUserAddressRequestModel(
      governorateId: governorateId,
      cityId: cityId,
      floor: floor,
      buildingNumber: buildingNumber,
      apartmentNumber: apartmentNumber,
      lat: latitude,
      long: longitude,
      mainAddress: mainAddress,
      isDefault: isDefault,
    );

    try {
      if (addressId == null) {
        await repository.createUserAddress(request);
        if (isClosed) return;
        showSuccessToast('addresses.added_successfully'.tr());
      } else {
        await repository.updateUserAddress(addressId, request);
        if (isClosed) return;
        showSuccessToast('addresses.updated_successfully'.tr());
      }
      emit(state.copyWith(isSaving: false, saved: true));
    } catch (e) {
      if (isClosed) return;
      final message = parseApiError(e);
      showErrorToast(message);
      emit(state.copyWith(isSaving: false, error: message));
    }
  }
}
