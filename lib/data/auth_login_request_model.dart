import 'package:json_annotation/json_annotation.dart';

part 'auth_login_request_model.g.dart';

@JsonSerializable(includeIfNull: false)
class AuthLoginRequestModel {
  final String? cardNumber;
  final String? phoneNumber;
  final String password;
  final int platformType;

  const AuthLoginRequestModel({
    this.cardNumber,
    this.phoneNumber,
    required this.password,
    this.platformType = 1,
  });

  factory AuthLoginRequestModel.fromJson(Map<String, dynamic> json) =>
      _$AuthLoginRequestModelFromJson(json);

  Map<String, dynamic> toJson() => _$AuthLoginRequestModelToJson(this);
}
