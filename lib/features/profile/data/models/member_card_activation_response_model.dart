import 'package:json_annotation/json_annotation.dart';

part 'member_card_activation_response_model.g.dart';

/// Response of POST /api/CardActivation/member-card/activate.
/// On success `data` carries the activated card number (a String).
@JsonSerializable()
class MemberCardActivationResponseModel {
  final int? httpStatusCode;
  final List<String>? errors;
  final bool? succeeded;
  final String? message;
  final String? data;

  const MemberCardActivationResponseModel({
    this.httpStatusCode,
    this.errors,
    this.succeeded,
    this.message,
    this.data,
  });

  factory MemberCardActivationResponseModel.fromJson(
    Map<String, dynamic> json,
  ) =>
      _$MemberCardActivationResponseModelFromJson(json);

  Map<String, dynamic> toJson() => _$MemberCardActivationResponseModelToJson(
    this,
  );
}
