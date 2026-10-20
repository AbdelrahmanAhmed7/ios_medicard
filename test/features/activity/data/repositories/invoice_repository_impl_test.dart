import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:medicard/core/constants/api_result.dart';
import 'package:medicard/core/services/app_language_manager.dart';
import 'package:medicard/features/activity/data/data_source/invoice_remote_data_source.dart';
import 'package:medicard/features/activity/data/dto/create_cart_invoice_request_dto.dart';
import 'package:medicard/features/activity/data/dto/create_invoice_response_dto.dart';
import 'package:medicard/features/activity/data/dto/invoice_item_dto.dart';
import 'package:medicard/features/activity/data/dto/invoice_details_response_dto.dart';
import 'package:medicard/features/activity/data/dto/invoices_response_dto.dart';
import 'package:medicard/features/activity/data/repositories/invoice_repository_impl.dart';
import 'package:medicard/features/activity/domain/repositories/invoice_repository.dart';
import 'package:medicard/features/activity/domain/models/created_invoice.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    SharedPreferences.setMockInitialValues(const {});
    await AppLanguageManager.instance.initialize();
  });

  group('InvoiceRepositoryImpl getMyInvoices mapping', () {
    test('preserves every invoice value supplied by the backend', () async {
      final dto = InvoiceItemDto.fromJson(const <String, dynamic>{
        'invoiceId': 340,
        'providerName': 'Dar Al Fouad Hospital',
        'branchName': 'October branch',
        'status': 'Pending',
        'date': '2026-10-14T16:01:38.7520113',
        'providerImageUrl': '/uploads/providers/provider.png',
        'isReviewed': false,
        'points': 17,
        'isFromPackage': true,
        'priceAfter': 0.10,
        'priceBefore': 1.00,
        'discountPercentage': 90.25,
        'familyId': 44,
        'familyFirstName': 'First',
        'familyLastName': 'Last',
      });
      final repository = InvoiceRepositoryImpl(
        _InvoicesDataSource(
          InvoicesResponseDto(
            succeeded: true,
            data: InvoicesPageDto(
              items: [dto],
              pageNumber: 1,
              pageSize: 10,
              totalCount: 15,
              totalPages: 2,
            ),
          ),
        ),
      );

      final result = await repository.getMyInvoices();

      result.when(
        success: (page) {
          final invoice = page.items.single;
          expect(invoice.invoiceId, 340);
          expect(invoice.providerName, 'Dar Al Fouad Hospital');
          expect(invoice.branchName, 'October branch');
          expect(invoice.status, 'Pending');
          expect(invoice.providerImageUrl, '/uploads/providers/provider.png');
          expect(invoice.isReviewed, isFalse);
          expect(invoice.points, 17);
          expect(invoice.isFromPackage, isTrue);
          expect(invoice.priceAfter, 0.10);
          expect(invoice.priceBefore, 1.00);
          expect(invoice.discountPercentage, 90.25);
          expect(invoice.familyId, 44);
          expect(invoice.beneficiaryName, 'First Last');
          expect(page.pageNumber, 1);
          expect(page.pageSize, 10);
          expect(page.totalCount, 15);
          expect(page.totalPages, 2);
        },
        failure: fail,
      );
    });
  });

  group('InvoiceRepositoryImpl getInvoiceDetails mapping', () {
    test('preserves all displayed invoice detail fields', () async {
      final response = InvoiceDetailsResponseDto.fromJson(
        const <String, dynamic>{
          'httpStatusCode': 200,
          'errors': null,
          'succeeded': true,
          'message': 'Invoice details retrieved successfully.',
          'data': <String, dynamic>{
            'invoiceId': 358,
            'status': 'Used',
            'familyId': null,
            'familyFirstName': null,
            'familyLastName': null,
            'date': '2026-10-19T13:52:37.7647869',
            'totalBefore': 165.00,
            'totalAfter': 132.00,
            'discountPercentage': 0.00,
            'items': <String, dynamic>{
              'items': <Map<String, dynamic>>[
                <String, dynamic>{
                  'id': 543,
                  'serviceName': 'Annual subscription',
                  'serviceNameAr': 'اشتراك سنوي',
                  'serviceNameEn': 'Annual subscription',
                  'priceBefore': 165.00,
                  'priceAfter': 132.00,
                  'discountPercentage': 20.00,
                },
              ],
              'pageNumber': 1,
              'pageSize': 12,
              'totalCount': 1,
              'totalPages': 1,
            },
          },
        },
      );
      final repository = InvoiceRepositoryImpl(
        _InvoiceDetailsDataSource(response),
      );

      final result = await repository.getInvoiceDetails(358);

      result.when(
        success: (details) {
          expect(details.invoiceId, 358);
          expect(details.status, 'Used');
          expect(details.familyId, isNull);
          expect(details.familyFirstName, isNull);
          expect(details.familyLastName, isNull);
          expect(details.apiDate, '2026-10-19T13:52:37.7647869');
          expect(details.totalBefore, 165.00);
          expect(details.totalAfter, 132.00);
          expect(details.discountPercentage, 0.00);
          final service = details.services.single;
          expect(service.id, 543);
          expect(service.serviceName, 'Annual subscription');
          expect(service.serviceNameAr, 'اشتراك سنوي');
          expect(service.serviceNameEn, 'Annual subscription');
          expect(service.priceBefore, 165.00);
          expect(service.priceAfter, 132.00);
          expect(service.discountPercentage, 20.00);
        },
        failure: fail,
      );
    });
  });

  group('InvoiceRepositoryImpl createFromCart response validation', () {
    test('accepts valid map response and preserves payment link', () async {
      final dataSource = _FakeInvoiceDataSource(
        const CreateInvoiceResponseDto(
          succeeded: true,
          data: {'invoiceId': 123, 'paymentLink': 'https://pay.example/123'},
        ),
      );
      final repository = InvoiceRepositoryImpl(dataSource);

      final result = await _create(repository);

      result.when(
        success: (invoice) {
          expect(invoice.invoiceId, '123');
          expect(invoice.paymentLink, 'https://pay.example/123');
        },
        failure: fail,
      );
    });

    test('keeps compatible primitive invoice identifier response', () async {
      final repository = InvoiceRepositoryImpl(
        _FakeInvoiceDataSource(
          const CreateInvoiceResponseDto(succeeded: true, data: 'INV-42'),
        ),
      );

      final result = await _create(repository);

      expect(
        result.when(success: (invoice) => invoice.invoiceId, failure: fail),
        'INV-42',
      );
    });

    test('returns declared server failure', () async {
      final repository = InvoiceRepositoryImpl(
        _FakeInvoiceDataSource(
          const CreateInvoiceResponseDto(succeeded: false, message: 'Rejected'),
        ),
      );

      final result = await _create(repository);

      expect(
        result.when(success: (_) => null, failure: (error) => error),
        'Rejected',
      );
    });

    for (final malformed in <dynamic>[
      null,
      const <String, dynamic>{},
      const <String, dynamic>{'invoiceId': null},
      const <String, dynamic>{'invoiceId': ''},
      const <String, dynamic>{'invoiceId': '   '},
      const <String, dynamic>{
        'invoiceId': <String, dynamic>{'bad': true},
      },
      const <dynamic>['unexpected'],
      0,
      -1,
    ]) {
      test('rejects malformed successful data: $malformed', () async {
        final repository = InvoiceRepositoryImpl(
          _FakeInvoiceDataSource(
            CreateInvoiceResponseDto(succeeded: true, data: malformed),
          ),
        );

        final result = await _create(repository);

        expect(
          result.when(success: (_) => 'success', failure: (_) => 'failure'),
          'failure',
        );
      });
    }

    test('classifies response timeout as an unknown outcome', () async {
      final dataSource = _FakeInvoiceDataSource(null)
        ..error = DioException(
          requestOptions: RequestOptions(path: '/create-from-cart'),
          type: DioExceptionType.receiveTimeout,
        );
      final repository = InvoiceRepositoryImpl(dataSource);

      final result = await _create(repository);

      expect(
        result.when(success: (_) => null, failure: (error) => error),
        invoiceOutcomeUnknownFailure,
      );
      expect(dataSource.createCalls, 1);
    });
  });
}

class _InvoicesDataSource implements InvoiceRemoteDataSource {
  _InvoicesDataSource(this.response);

  final InvoicesResponseDto response;

  @override
  Future<InvoicesResponseDto> getMyInvoices({
    required String language,
    int pageNumber = 1,
    int pageSize = 10,
    int? tab,
  }) async {
    return response;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _InvoiceDetailsDataSource implements InvoiceRemoteDataSource {
  _InvoiceDetailsDataSource(this.response);

  final InvoiceDetailsResponseDto response;

  @override
  Future<InvoiceDetailsResponseDto> getInvoiceDetails(int invoiceId) async {
    return response;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

Future<ApiResult<CreatedInvoice>> _create(InvoiceRepositoryImpl repository) {
  return repository.createFromCart(
    providerId: 7,
    providerBranchId: 70,
    isCash: true,
  );
}

class _FakeInvoiceDataSource implements InvoiceRemoteDataSource {
  _FakeInvoiceDataSource(this.response);

  final CreateInvoiceResponseDto? response;
  Object? error;
  int createCalls = 0;

  @override
  Future<CreateInvoiceResponseDto> createFromCart(
    CreateCartInvoiceRequestDto request,
  ) async {
    createCalls++;
    final currentError = error;
    if (currentError != null) throw currentError;
    return response!;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}
