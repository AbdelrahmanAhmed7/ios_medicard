import 'package:json_annotation/json_annotation.dart';

part 'change_language_request_model.g.dart';

@JsonSerializable()
class ChangeLanguageRequestModel {
  final String language;

  const ChangeLanguageRequestModel({required this.language});

  factory ChangeLanguageRequestModel.fromJson(Map<String, dynamic> json) =>
      _$ChangeLanguageRequestModelFromJson(json);

  Map<String, dynamic> toJson() => _$ChangeLanguageRequestModelToJson(this);
}
