import 'package:json_annotation/json_annotation.dart';

part 'card_data_response_model.g.dart';

@JsonSerializable()
class CardDataResponseModel {
  final int? httpStatusCode;
  final List<String>? errors;
  final bool? succeeded;
  final String? message;
  final CardData? data;

  const CardDataResponseModel({
    this.httpStatusCode,
    this.errors,
    this.succeeded,
    this.message,
    this.data,
  });

  factory CardDataResponseModel.fromJson(Map<String, dynamic> json) =>
      _$CardDataResponseModelFromJson(json);

  Map<String, dynamic> toJson() => _$CardDataResponseModelToJson(this);
}

@JsonSerializable()
class CardData {
  final String? cardNumber;
  final String? expireAt;
  final String? firstName;
  final String? lastName;
  final String? planType;

  const CardData({
    this.cardNumber,
    this.expireAt,
    this.firstName,
    this.lastName,
    this.planType,
  });

  factory CardData.fromJson(Map<String, dynamic> json) =>
      _$CardDataFromJson(json);

  Map<String, dynamic> toJson() => _$CardDataToJson(this);

  String get fullName {
    final parts = [
      firstName?.trim(),
      lastName?.trim(),
    ].whereType<String>().where((part) => part.isNotEmpty);
    return parts.join(' ');
  }

  String get formattedCardNumber {
    return (cardNumber ?? '').replaceAll(RegExp(r'\s+'), '');
  }

  String get formattedExpiry {
    final raw = expireAt;
    if (raw == null || raw.isEmpty) return '—';
    final parsed = DateTime.tryParse(raw);
    if (parsed == null) return raw;
    final month = parsed.month.toString().padLeft(2, '0');
    return '$month/${parsed.year}';
  }
}
