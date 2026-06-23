import 'package:json_annotation/json_annotation.dart';

part 'activate_card_response_model.g.dart';

@JsonSerializable()
class ActivateCardResponseModel {
  @JsonKey(name: 'httpStatusCode')
  final int httpStatusCode;
  @JsonKey(name: 'errors')
  final dynamic errors;
  @JsonKey(name: 'succeeded')
  final bool succeeded;
  @JsonKey(name: 'message')
  final String message;
  @JsonKey(name: 'data')
  final ActivateCardData? data;

  const ActivateCardResponseModel({
    required this.httpStatusCode,
    this.errors,
    required this.succeeded, required this.message, this.data});

  factory ActivateCardResponseModel.fromJson(Map<String, dynamic> json) =>
      _$ActivateCardResponseModelFromJson(json);

  Map<String, dynamic> toJson() => _$ActivateCardResponseModelToJson(this);
}

@JsonSerializable()
class ActivateCardData {
  @JsonKey(name: 'token')
  final String token;
  @JsonKey(name: 'expiresAt')
  final String expiresAt;

  const ActivateCardData({
    required this.token, required this.expiresAt});

  factory ActivateCardData.fromJson(Map<String, dynamic> json) =>
      _$ActivateCardDataFromJson(json);

  Map<String, dynamic> toJson() => _$ActivateCardDataToJson(this);
}