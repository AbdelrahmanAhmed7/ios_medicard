import 'package:json_annotation/json_annotation.dart';

part 'auth_register_request_model.g.dart';

@JsonSerializable()
class AuthRegisterRequestModel {
  final String firstName;
  final String lastName;
  final String phoneNumber;
  final bool isMale;
  final String birthDate;
  final String password;
  final String confirmPassword;
  final String? nationalId;
  final String? passportNumber;

  const AuthRegisterRequestModel({
    required this.firstName,
    required this.lastName,
    required this.phoneNumber,
    required this.isMale,
    required this.birthDate,
    required this.password,
    required this.confirmPassword,
    this.nationalId,
    this.passportNumber,
  });

  factory AuthRegisterRequestModel.fromJson(Map<String, dynamic> json) =>
      _$AuthRegisterRequestModelFromJson(json);

  Map<String, dynamic> toJson() => _$AuthRegisterRequestModelToJson(this);
}
