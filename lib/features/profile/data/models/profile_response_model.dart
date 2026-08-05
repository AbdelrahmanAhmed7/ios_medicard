import 'package:json_annotation/json_annotation.dart';

part 'profile_response_model.g.dart';

@JsonSerializable()
class ProfileResponseModel {
  final int? httpStatusCode;
  final List<String>? errors;
  final bool? succeeded;
  final String? message;
  final ProfileData? data;

  const ProfileResponseModel({
    this.httpStatusCode,
    this.errors,
    this.succeeded,
    this.message,
    this.data,
  });

  factory ProfileResponseModel.fromJson(Map<String, dynamic> json) =>
      _$ProfileResponseModelFromJson(json);

  Map<String, dynamic> toJson() => _$ProfileResponseModelToJson(this);
}

@JsonSerializable()
class ProfileData {
  final String? firstName;
  final String? lastName;
  final String? phoneNumber;
  final String? nationalId;
  final String? cardNumber;
  final String? passportNumber;
  final bool? isMale;
  final String? birthDate;
  final String? imageUrl;

  const ProfileData({
    this.firstName,
    this.lastName,
    this.phoneNumber,
    this.nationalId,
    this.cardNumber,
    this.passportNumber,
    this.isMale,
    this.birthDate,
    this.imageUrl,
  });

  factory ProfileData.fromJson(Map<String, dynamic> json) =>
      _$ProfileDataFromJson(json);

  Map<String, dynamic> toJson() => _$ProfileDataToJson(this);

  ProfileData copyWith({
    String? firstName,
    String? lastName,
    String? phoneNumber,
    String? nationalId,
    String? cardNumber,
    String? passportNumber,
    bool? isMale,
    String? birthDate,
    String? imageUrl,
  }) {
    return ProfileData(
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      nationalId: nationalId ?? this.nationalId,
      cardNumber: cardNumber ?? this.cardNumber,
      passportNumber: passportNumber ?? this.passportNumber,
      isMale: isMale ?? this.isMale,
      birthDate: birthDate ?? this.birthDate,
      imageUrl: imageUrl ?? this.imageUrl,
    );
  }
}
