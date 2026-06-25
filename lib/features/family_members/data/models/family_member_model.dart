import 'package:json_annotation/json_annotation.dart';

part 'family_member_model.g.dart';

@JsonSerializable()
class FamilyMemberModel {
  final int? id;
  final String? fullName;
  final String? firstName;
  final String? lastName;
  final int? relation;
  final String? imageUrl;

  const FamilyMemberModel({
    this.id,
    this.fullName,
    this.firstName,
    this.lastName,
    this.relation,
    this.imageUrl,
  });

  factory FamilyMemberModel.fromJson(Map<String, dynamic> json) =>
      _$FamilyMemberModelFromJson(json);

  Map<String, dynamic> toJson() => _$FamilyMemberModelToJson(this);
}
