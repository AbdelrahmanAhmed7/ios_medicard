import 'package:json_annotation/json_annotation.dart';

part 'lookup_model.g.dart';

@JsonSerializable()
class LookupModel {
  final int? id;
  final String? name;

  const LookupModel({this.id, this.name});

  factory LookupModel.fromJson(Map<String, dynamic> json) =>
      _$LookupModelFromJson(json);

  Map<String, dynamic> toJson() => _$LookupModelToJson(this);
}
