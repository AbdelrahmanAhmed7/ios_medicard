class ManualPrescriptionResponseModel {
  final bool succeeded;
  final String? message;

  const ManualPrescriptionResponseModel({
    required this.succeeded,
    this.message,
  });

  factory ManualPrescriptionResponseModel.fromJson(Map<String, dynamic> json) =>
      ManualPrescriptionResponseModel(
        succeeded: json['succeeded'] == true,
        message: json['message']?.toString(),
      );
}
