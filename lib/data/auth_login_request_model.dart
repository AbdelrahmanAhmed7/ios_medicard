import 'package:json_annotation/json_annotation.dart';

part 'auth_login_request_model.g.dart';

@JsonSerializable(includeIfNull: false)
class AuthLoginRequestModel {
  final String? cardNumber;
  final String? phoneNumber;
  final String password;

  /// Backend `platformType` enum (Android = 0, Ios = 1, Web = 2).
  /// Prefer [PlatformType.current.value] at the call site; this default
  /// (iOS) is only a fallback for legacy constructions.
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
