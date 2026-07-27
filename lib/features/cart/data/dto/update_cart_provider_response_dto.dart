class UpdateCartProviderResponseDto {
  final int? httpStatusCode;
  final List<String>? errors;
  final bool? succeeded;
  final String? message;
  final String? data;

  const UpdateCartProviderResponseDto({
    this.httpStatusCode,
    this.errors,
    this.succeeded,
    this.message,
    this.data,
  });

  factory UpdateCartProviderResponseDto.fromJson(Map<String, dynamic> json) {
    final errors = json['errors'];
    return UpdateCartProviderResponseDto(
      httpStatusCode: (json['httpStatusCode'] as num?)?.toInt(),
      errors: errors is List ? errors.map((e) => e.toString()).toList() : null,
      succeeded: json['succeeded'] as bool?,
      message: json['message'] as String?,
      data: json['data']?.toString(),
    );
  }
}
