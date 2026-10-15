import 'package:medicard/features/addresses/data/models/save_user_address_request_model.dart';
import 'package:medicard/features/addresses/data/models/user_address_model.dart';
import 'package:medicard/features/search/data/models/lookup_model.dart';

abstract class AddressesRepository {
  Future<List<UserAddressModel>> getUserAddresses();
  Future<UserAddressModel> getUserAddress(int id);
  Future<void> createUserAddress(SaveUserAddressRequestModel request);
  Future<void> updateUserAddress(int id, SaveUserAddressRequestModel request);
  Future<void> deleteUserAddress(int id);
  Future<List<LookupModel>> getGovernorates();
  Future<List<LookupModel>> getCities(int governorateId);
}
