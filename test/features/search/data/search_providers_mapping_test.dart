import 'package:flutter_test/flutter_test.dart';
import 'package:medicard/features/search/data/models/search_response_model.dart';

void main() {
  group('Search providers response mapping', () {
    Map<String, dynamic> payload() => {
      'httpStatusCode': 200,
      'errors': null,
      'succeeded': true,
      'message': 'Providers retrieved successfully.',
      'data': {
        'items': [
          {
            'providerId': 80,
            'providerName': 'Alfa Labs',
            'categoryName': 'Labs',
            'imageUrl':
                'https://medicard-api-v2.medicardeg.com/uploads/providers/7798d69e-2142-471f-b96d-28f1c937d6f8.png',
            'hotLine': '12345',
            'whatsApp': '01006007245',
            'maxDiscountPercentage': 40.00,
            'averageRating': 4.5,
            'totalReviews': 12,
            'distanceKm': 2.3,
          },
          {
            'providerId': 81,
            'providerName': 'Golds Gym',
            'categoryName': 'Gyms',
            'imageUrl':
                'https://medicard-api-v2.medicardeg.com/uploads/providers/ceba639b-c239-489e-bc12-c1ce3b408e5e.webp',
            'hotLine': '12341',
            'maxDiscountPercentage': 50.00,
            'averageRating': 0,
            'totalReviews': 0,
            'distanceKm': null,
          },
        ],
        'totalCount': 5,
        'pageNumber': 1,
        'pageSize': 15,
        'totalPages': 1,
      },
    };

    test('every backend field lands on the model', () {
      final data = SearchResponseModel.fromJson(payload()).data!;
      expect(data.totalCount, 5);
      expect(data.items!.length, 2);

      final first = data.items!.first;
      expect(first.providerId, 80);
      expect(first.providerName, 'Alfa Labs');
      expect(first.categoryName, 'Labs');
      expect(first.imageUrl, contains('7798d69e'));
      expect(first.hotline, '12345');
      expect(first.whatsApp, '01006007245');
      expect(first.maxDiscountPercentage, 40.0);
      expect(first.averageRating, 4.5);
      expect(first.totalReviews, 12);
      expect(first.distanceKm, 2.3);
    });

    test('zero rating and null distance stay null-safe for the card', () {
      final second = SearchResponseModel.fromJson(payload()).data!.items![1];
      expect(second.averageRating, 0);
      expect(second.totalReviews, 0);
      expect(second.distanceKm, isNull);
      // The card hides the rating row when average is 0 and the
      // distance row when null — nothing to display, nothing crashes.
      expect((second.averageRating ?? 0) > 0, isFalse);
    });

    test('WhatsApp does not fall back to the hotline', () {
      final second = SearchResponseModel.fromJson(payload()).data!.items![1];

      expect(second.hotline, '12341');
      expect(second.whatsApp, isNull);
    });
  });
}
