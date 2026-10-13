import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:medicard/core/constants/api_result.dart';
import 'package:medicard/features/activity/data/data_source/invoice_remote_data_source.dart';
import 'package:medicard/features/activity/data/dto/create_cart_invoice_request_dto.dart';
import 'package:medicard/features/activity/data/dto/create_invoice_response_dto.dart';
import 'package:medicard/features/activity/data/repositories/invoice_repository_impl.dart';
import 'package:medicard/features/activity/domain/repositories/invoice_repository.dart';
import 'package:medicard/features/activity/domain/models/created_invoice.dart';

void main() {
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
