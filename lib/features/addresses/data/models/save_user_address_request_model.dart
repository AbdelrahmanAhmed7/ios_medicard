import 'package:json_annotation/json_annotation.dart';

part 'save_user_address_request_model.g.dart';

@JsonSerializable()
class SaveUserAddressRequestModel {
  final int? governorateId;
  final int? cityId;
  final int? floor;
  final int? buildingNumber;
  final int? apartmentNumber;
  final double? lat;
  final double? long;

  /// Doubles as the address type: 0 = home, 1 = work.
  final int? mainAddress;
  final bool? isDefault;

  const SaveUserAddressRequestModel({
    this.governorateId,
    this.cityId,
    this.floor,
    this.buildingNumber,
    this.apartmentNumber,
    this.lat,
    this.long,
    this.mainAddress,
    this.isDefault,
  });

  factory SaveUserAddressRequestModel.fromJson(Map<String, dynamic> json) =>
      _$SaveUserAddressRequestModelFromJson(json);

  Map<String, dynamic> toJson() => _$SaveUserAddressRequestModelToJson(this);
}
