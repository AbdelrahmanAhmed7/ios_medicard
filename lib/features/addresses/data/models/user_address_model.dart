import 'package:json_annotation/json_annotation.dart';

part 'user_address_model.g.dart';

@JsonSerializable()
class UserAddressModel {
  final int? id;
  final int? governorateId;
  final String? governorateNameAr;
  final String? governorateNameEn;
  final int? cityId;
  final String? cityNameAr;
  final String? cityNameEn;
  final int? floor;
  final int? buildingNumber;
  final int? apartmentNumber;
  final double? lat;
  final double? long;

  /// Doubles as the address type: 0 = home, 1 = work.
  final int? mainAddress;
  final bool? isDefault;
  final String? createdAt;

  const UserAddressModel({
    this.id,
    this.governorateId,
    this.governorateNameAr,
    this.governorateNameEn,
    this.cityId,
    this.cityNameAr,
    this.cityNameEn,
    this.floor,
    this.buildingNumber,
    this.apartmentNumber,
    this.lat,
    this.long,
    this.mainAddress,
    this.isDefault,
    this.createdAt,
  });

  factory UserAddressModel.fromJson(Map<String, dynamic> json) =>
      _$UserAddressModelFromJson(json);

  Map<String, dynamic> toJson() => _$UserAddressModelToJson(this);

  bool get isWork => mainAddress == 1;

  bool get isHome => !isWork;

  bool get hasCoordinates => lat != null && long != null;

  String localizedGovernorate(bool isArabic) {
    final ar = governorateNameAr?.trim() ?? '';
    final en = governorateNameEn?.trim() ?? '';
    if (isArabic) return ar.isNotEmpty ? ar : en;
    return en.isNotEmpty ? en : ar;
  }

  String localizedCity(bool isArabic) {
    final ar = cityNameAr?.trim() ?? '';
    final en = cityNameEn?.trim() ?? '';
    if (isArabic) return ar.isNotEmpty ? ar : en;
    return en.isNotEmpty ? en : ar;
  }
}
