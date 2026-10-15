import 'package:medicard/features/addresses/data/models/get_user_address_response_model.dart';
import 'package:medicard/features/addresses/data/models/get_user_addresses_response_model.dart';
import 'package:medicard/features/addresses/data/models/save_user_address_request_model.dart';
import 'package:medicard/features/addresses/data/models/user_address_model.dart';
import 'package:medicard/features/addresses/data/models/user_address_operation_response_model.dart';
import 'package:medicard/features/addresses/domain/repository/addresses_repository.dart';
import 'package:medicard/features/search/data/models/lookup_model.dart';
import 'package:medicard/features/search/data/models/lookup_response_model.dart';
import 'package:medicard/service/medicard_api_service.dart';

class AddressesRepositoryImpl implements AddressesRepository {
  final MedicardApiService apiService;

  AddressesRepositoryImpl(this.apiService);

  @override
  Future<List<UserAddressModel>> getUserAddresses() async {
    // Token is injected automatically by AuthInterceptor.
    final GetUserAddressesResponseModel response = await apiService
        .getUserAddresses();
    if (response.succeeded == true) {
      return response.data?.items ?? [];
    }
    throw Exception(response.errors?.join(', ') ?? 'Failed to get addresses');
  }

  @override
  Future<UserAddressModel> getUserAddress(int id) async {
    final GetUserAddressResponseModel response = await apiService
        .getUserAddress(id);
    if (response.succeeded == true && response.data != null) {
      return response.data!;
    }
    throw Exception(response.errors?.join(', ') ?? 'Failed to get address');
  }

  @override
  Future<void> createUserAddress(SaveUserAddressRequestModel request) async {
    final UserAddressOperationResponseModel response = await apiService
        .createUserAddress(request);
    if (response.succeeded != true) {
      throw Exception(
        response.errors?.join(', ') ?? 'Failed to create address',
      );
    }
  }

  @override
  Future<void> updateUserAddress(
    int id,
    SaveUserAddressRequestModel request,
  ) async {
    final UserAddressOperationResponseModel response = await apiService
        .updateUserAddress(id, request);
    if (response.succeeded != true) {
      throw Exception(
        response.errors?.join(', ') ?? 'Failed to update address',
      );
    }
  }

  @override
  Future<void> deleteUserAddress(int id) async {
    final UserAddressOperationResponseModel response = await apiService
        .deleteUserAddress(id);
    if (response.succeeded != true) {
      throw Exception(
        response.errors?.join(', ') ?? 'Failed to delete address',
      );
    }
  }

  @override
  Future<List<LookupModel>> getGovernorates() async {
    final LookupResponseModel response = await apiService.getGovernorates();
    if (response.succeeded == true) {
      return response.data ?? [];
    }
    throw Exception(
      response.errors?.join(', ') ?? 'Failed to get governorates',
    );
  }

  @override
  Future<List<LookupModel>> getCities(int governorateId) async {
    final LookupResponseModel response = await apiService.getCities(
      governorateId,
    );
    if (response.succeeded == true) {
      return response.data ?? [];
    }
    throw Exception(response.errors?.join(', ') ?? 'Failed to get cities');
  }
}
