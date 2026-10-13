import '../../../home/data/home_mock_data.dart';
import '../../../home/domain/models/featured_service_model.dart';
import '../../../home/domain/models/provider_model.dart';
import '../../data/models/guest_home_response_model.dart';

List<ProviderModel> mapGuestProviders(List<GuestNearestProvider> raw) {
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
      mapUrl: _textOrEmpty(p.mapUrl),
      distanceKm: p.distanceKm,
    );
  }).toList();
}

List<PromoBanner> mapGuestPromoBanners(List<GuestSlider> raw) {
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

List<FeaturedServiceModel> mapGuestPackages(List<GuestPackage> raw) {
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
