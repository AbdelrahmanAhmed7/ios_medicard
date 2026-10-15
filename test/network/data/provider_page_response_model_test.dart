import 'package:flutter_test/flutter_test.dart';
import 'package:medicard/network/data/provider_page_response_model.dart';

void main() {
  group('package provider mapping', () {
    test('package list item keeps its provider identity', () {
      final package = ProviderPackage.fromJson(const {
        'id': 21,
        'name': 'alfa lab package',
        'providerId': 80,
        'providerNameAr': 'الفا لاب',
        'providerNameEn': 'Alfa Labs',
        'image': 'https://example.com/package.webp',
        'priceBefore': 600.0,
        'priceAfter': 480.0,
      });

      expect(package.providerId, 80);
      expect(package.providerName(false), 'Alfa Labs');
      expect(package.providerName(true), 'الفا لاب');
      expect(package.imageUrl, 'https://example.com/package.webp');
    });

    test('package details keeps its provider identity', () {
      final details = PackageDetailsData.fromJson(const {
        'id': 21,
        'name': 'alfa lab package',
        'providerId': 80,
        'providerNameAr': 'الفا لاب',
        'providerNameEn': 'Alfa Labs',
        'image': 'https://example.com/package.webp',
        'serviceNames': ['ECG', 'CT Scan'],
      });

      expect(details.providerId, 80);
      expect(details.providerName(false), 'Alfa Labs');
      expect(details.providerName(true), 'الفا لاب');
    });

    test('package list remains compatible with imageUrl responses', () {
      final package = ProviderPackage.fromJson(const {
        'id': 20,
        'providerId': 85,
        'imageUrl': 'https://example.com/legacy.jpeg',
      });

      expect(package.imageUrl, 'https://example.com/legacy.jpeg');
    });
  });
}
