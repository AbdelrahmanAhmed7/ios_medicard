import '../../data/home_mock_data.dart';
import '../../data/models/home_response_model.dart';
import '../../domain/models/appointment_model.dart';
import '../../domain/models/featured_service_model.dart';
import '../../domain/models/provider_model.dart';

/// Maps raw API models to presentation-layer domain models.
/// Kept as top-level functions so they are pure, stateless, and testable.

List<ProviderModel> mapProviders(List<HomeNearestProvider> raw) {
  return raw.where((p) => _hasText(p.providerName)).map((p) {
    return ProviderModel(
      providerId: p.providerId,
      imageUrl: _textOrEmpty(p.providerImageUrl),
      name: _textOrEmpty(p.providerName),
      rating: 0.0,
      reviewCount: 0,
      type: _textOrEmpty(p.branchName),
      location: _textOrEmpty(p.fullAddress),
      badges: const [],
    );
  }).toList();
}

List<AppointmentModel> mapAppointments(List<HomePendingAppointment> raw) {
  return raw
      .where(
        (a) => _hasAnyText([
          a.providerName,
          a.service,
          a.branchName,
          a.status,
          a.date,
        ]),
      )
      .map((a) {
        return AppointmentModel(
          providerId: a.providerId,
          providerLogoUrl: _textOrEmpty(a.providerImageUrl),
          providerName: _textOrEmpty(a.providerName),
          service: _textOrEmpty(a.service),
          branch: _textOrEmpty(a.branchName),
          status: _appointmentStatusText(a.status),
          date: _textOrEmpty(a.date),
        );
      })
      .toList();
}

List<PromoBanner> mapPromoBanners(List<HomeSlider> raw) {
  return raw.where((slider) => _hasText(slider.imageUrl)).map((slider) {
    return PromoBanner(
      providerId: slider.providerId,
      imageUrl: _textOrEmpty(slider.imageUrl),
      providerLogoUrl: '',
      title: _textOrEmpty(slider.providerName),
      subtitle: '',
    );
  }).toList();
}

List<FeaturedServiceModel> mapPackages(List<HomePackage> raw) {
  return raw
      .where(
        (package) => _hasAnyText([
          package.name,
          package.providerName,
          package.imageUrl,
          package.description,
        ]),
      )
      .map((package) {
        return FeaturedServiceModel(
          packageId: package.packageId,
          providerId: package.providerId,
          providerBranchId: package.providerBranchId,
          imageUrl: _textOrEmpty(package.imageUrl),
          providerLogoUrl: '',
          providerName: _textOrEmpty(package.providerName),
          serviceName: _textOrEmpty(package.name),
          location: _textOrEmpty(package.description),
          originalPrice: package.priceBefore ?? 0,
          discountedPrice: package.priceAfter ?? 0,
          rating: 0,
          reviewCount: 0,
        );
      })
      .toList();
}

bool _hasAnyText(List<String?> values) => values.any(_hasText);

bool _hasText(String? value) => value != null && value.trim().isNotEmpty;

String _textOrEmpty(String? value) => value?.trim() ?? '';

String _appointmentStatusText(String? status) {
  final value = status?.trim();
  if (value == null || value.isEmpty) return '';

  switch (value.toLowerCase()) {
    case '2':
    case 'pending':
      return 'pending';
    default:
      return value;
  }
}
