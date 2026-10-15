import 'package:json_annotation/json_annotation.dart';

part 'family_member_operation_response_model.g.dart';

@JsonSerializable()
class FamilyMemberOperationResponseModel {
  final int? httpStatusCode;
  final List<String>? errors;
  final bool? succeeded;
  final String? message;
  final dynamic data;

  const FamilyMemberOperationResponseModel({
    this.httpStatusCode,
    this.errors,
    this.succeeded,
    this.message,
    this.data,
  });

  factory FamilyMemberOperationResponseModel.fromJson(
    Map<String, dynamic> json,
  ) => _$FamilyMemberOperationResponseModelFromJson(json);

  Map<String, dynamic> toJson() =>
      _$FamilyMemberOperationResponseModelToJson(this);
}
