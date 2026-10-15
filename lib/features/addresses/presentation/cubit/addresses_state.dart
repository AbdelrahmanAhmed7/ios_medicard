import 'package:freezed_annotation/freezed_annotation.dart';
import '../../data/models/user_address_model.dart';

part 'addresses_state.freezed.dart';

@freezed
class AddressesState with _$AddressesState {
  const factory AddressesState.initial() = _Initial;
  const factory AddressesState.loading() = _Loading;
  const factory AddressesState.success(List<UserAddressModel> addresses) =
      _Success;
  const factory AddressesState.failed(String error) = _Failed;
  const factory AddressesState.deleting() = _Deleting;
  const factory AddressesState.deleted() = _Deleted;
}
