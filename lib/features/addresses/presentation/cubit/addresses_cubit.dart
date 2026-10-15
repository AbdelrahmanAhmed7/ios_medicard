import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:medicard/core/theming/app_toast.dart';
import 'package:medicard/core/utils/api_error_parser.dart';
import '../../data/models/user_address_model.dart';
import '../../domain/repository/addresses_repository.dart';
import 'addresses_state.dart';

class AddressesCubit extends Cubit<AddressesState> {
  final AddressesRepository repository;

  AddressesCubit(this.repository) : super(const AddressesState.initial());

  Future<void> loadAddresses() async {
    if (isClosed) return;
    emit(const AddressesState.loading());
    try {
      final addresses = await repository.getUserAddresses();
      if (isClosed) return;
      if (kDebugMode) {
        debugPrint(
          '[Addresses] loaded ${addresses.length} '
          '(ids: ${addresses.map((a) => a.id).join(',')})',
        );
      }
      emit(AddressesState.success(addresses));
    } catch (e) {
      if (isClosed) return;
      emit(AddressesState.failed(parseApiError(e)));
    }
  }

  Future<void> deleteAddress({required int id}) async {
    if (isClosed) return;

    // Keep a snapshot so the list can be restored if the delete fails.
    final currentAddresses = state.maybeWhen(
      success: (addresses) => addresses,
      orElse: () => <UserAddressModel>[],
    );

    emit(const AddressesState.deleting());
    try {
      await repository.deleteUserAddress(id);
      if (isClosed) return;
      showSuccessToast('addresses.deleted_successfully'.tr());
      emit(const AddressesState.deleted());
      loadAddresses();
    } catch (e) {
      if (isClosed) return;
      showErrorToast(parseApiError(e));
      emit(AddressesState.success(currentAddresses));
    }
  }
}
