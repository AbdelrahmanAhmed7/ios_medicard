class AppointmentModel {
  final int? invoiceId;
  final int? providerId;
  final String providerLogoUrl;
  final String providerName;
  final String service;
  final String branch;
  final String status;
  final String date;

  const AppointmentModel({
    this.invoiceId,
    this.providerId,
    required this.providerLogoUrl,
    required this.providerName,
    required this.service,
    required this.branch,
    required this.status,
    required this.date,
  });
}
