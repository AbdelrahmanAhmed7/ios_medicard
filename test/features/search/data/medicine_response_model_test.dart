import 'package:flutter_test/flutter_test.dart';
import 'package:medicard/features/search/data/models/medicine_response_model.dart';

void main() {
  test('parses medicines response and pagination fields', () {
    final response = MedicineResponseModel.fromJson({
      'httpStatusCode': 200,
      'succeeded': true,
      'message': 'Medicines retrieved successfully.',
      'data': {
        'items': [
          {
            'id': 166,
            'arName': 'كابتوبريل',
            'enName': 'Captopril',
            'medicinePrice': 80.00,
            'medicineImageUrl': 'https://example.com/medicine.webp',
            'medicineForm': 'capsule',
            'unit': 'Bottle',
          },
        ],
        'pageNumber': 1,
        'pageSize': 15,
        'totalCount': 1,
        'totalPages': 1,
      },
    });

    expect(response.succeeded, isTrue);
    expect(response.data?.items.single.id, 166);
    expect(response.data?.items.single.enName, 'Captopril');
    expect(response.data?.items.single.medicinePrice, 80);
    expect(response.data?.items.single.unit, 'Bottle');
    expect(response.data?.totalCount, 1);
  });
}
