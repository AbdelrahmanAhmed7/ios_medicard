import 'package:flutter_test/flutter_test.dart';
import 'package:medicard/data/auth_response_model.dart';

void main() {
  test('parses the login envelope and token expirations', () {
    final response = AuthResponseModel.fromJson({
      'httpStatusCode': 200,
      'errors': null,
      'succeeded': true,
      'message': 'Operation completed successfully.',
      'data': {
        'success': true,
        'token': 'access-token',
        'message': 'Login successful.',
        'expiresAt': '2026-11-02T11:05:45.8136878+02:00',
        'refreshToken': 'refresh-token',
        'refreshTokenExpiresAt': '2026-11-03T10:05:45.8463588+02:00',
      },
    });

    expect(response.succeeded, isTrue);
    expect(response.data?.success, isTrue);
    expect(response.data?.token, 'access-token');
    expect(response.data?.refreshToken, 'refresh-token');
    expect(
      response.data?.expiresAt,
      DateTime.utc(2026, 11, 2, 9, 5, 45, 813, 687),
    );
    expect(
      response.data?.refreshTokenExpiresAt,
      DateTime.utc(2026, 11, 3, 8, 5, 45, 846, 358),
    );
  });
}
