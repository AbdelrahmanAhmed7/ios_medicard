class AppointmentModel {
  final String providerLogoUrl;
  final String providerName;
  final String service;
  final String branch;
  final String status;
  final String date;

  const AppointmentModel({
    required this.providerLogoUrl,
    required this.providerName,
    required this.service,
    required this.branch,
    required this.status,
    required this.date,
  });
}
