import 'package:json_annotation/json_annotation.dart';
import 'user_address_model.dart';

part 'get_user_addresses_response_model.g.dart';

/// GET /UserAddress envelope.
///
/// The backend nests the page under `data`:
/// `{..., "succeeded": true, "data": {"items": [...], "pageNumber": 1, ...}}`.
@JsonSerializable()
class GetUserAddressesResponseModel {
  final int? httpStatusCode;
  final List<String>? errors;
  final bool? succeeded;
  final String? message;
  final UserAddressesPageData? data;

  const GetUserAddressesResponseModel({
    this.httpStatusCode,
    this.errors,
    this.succeeded,
    this.message,
    this.data,
  });

  factory GetUserAddressesResponseModel.fromJson(Map<String, dynamic> json) =>
      _$GetUserAddressesResponseModelFromJson(json);

  Map<String, dynamic> toJson() => _$GetUserAddressesResponseModelToJson(this);
}

@JsonSerializable()
class UserAddressesPageData {
  final List<UserAddressModel>? items;
  final int? pageNumber;
  final int? pageSize;
  final int? totalCount;
  final int? totalPages;

  const UserAddressesPageData({
    this.items,
    this.pageNumber,
    this.pageSize,
    this.totalCount,
    this.totalPages,
  });

  factory UserAddressesPageData.fromJson(Map<String, dynamic> json) =>
      _$UserAddressesPageDataFromJson(json);

  Map<String, dynamic> toJson() => _$UserAddressesPageDataToJson(this);
}
