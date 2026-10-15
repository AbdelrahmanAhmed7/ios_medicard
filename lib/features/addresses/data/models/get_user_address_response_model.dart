import 'package:json_annotation/json_annotation.dart';
import 'user_address_model.dart';

part 'get_user_address_response_model.g.dart';

@JsonSerializable()
class GetUserAddressResponseModel {
  final int? httpStatusCode;
  final List<String>? errors;
  final bool? succeeded;
  final String? message;
  final UserAddressModel? data;

  const GetUserAddressResponseModel({
    this.httpStatusCode,
    this.errors,
    this.succeeded,
    this.message,
    this.data,
  });

  factory GetUserAddressResponseModel.fromJson(Map<String, dynamic> json) =>
      _$GetUserAddressResponseModelFromJson(json);

  Map<String, dynamic> toJson() => _$GetUserAddressResponseModelToJson(this);
}
