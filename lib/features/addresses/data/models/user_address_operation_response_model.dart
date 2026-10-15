import 'package:json_annotation/json_annotation.dart';

part 'user_address_operation_response_model.g.dart';

@JsonSerializable()
class UserAddressOperationResponseModel {
  final int? httpStatusCode;
  final List<String>? errors;
  final bool? succeeded;
  final String? message;
  final dynamic data;

  const UserAddressOperationResponseModel({
    this.httpStatusCode,
    this.errors,
    this.succeeded,
    this.message,
    this.data,
  });

  factory UserAddressOperationResponseModel.fromJson(
    Map<String, dynamic> json,
  ) => _$UserAddressOperationResponseModelFromJson(json);

  Map<String, dynamic> toJson() =>
      _$UserAddressOperationResponseModelToJson(this);
}
