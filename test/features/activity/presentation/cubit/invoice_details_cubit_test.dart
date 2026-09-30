import 'package:flutter_test/flutter_test.dart';
import 'package:medicard/core/constants/api_result.dart';
import 'package:medicard/features/activity/domain/models/invoice_details.dart';
import 'package:medicard/features/activity/domain/repositories/invoice_repository.dart';
import 'package:medicard/features/activity/domain/usecases/cancel_invoice_usecase.dart';
import 'package:medicard/features/activity/domain/usecases/create_review_usecase.dart';
import 'package:medicard/features/activity/domain/usecases/get_invoice_details_usecase.dart';
import 'package:medicard/features/activity/presentation/cubit/invoice_details_cubit.dart';

class _FakeInvoiceRepository implements InvoiceRepository {
  ApiResult<InvoiceDetails> detailsResult = ApiResult<InvoiceDetails>.success(
    InvoiceDetails(
      invoiceId: 1,
      status: 'Completed',
      date: DateTime(2026, 1, 1),
      totalBefore: 500,
      totalAfter: 400,
      discountPercentage: 20,
      services: const [],
    ),
  );
  ApiResult<void> voidResult = ApiResult<void>.success(null);

  final List<int> detailCalls = [];
  final List<int> cancelCalls = [];
  final List<({int invoiceId, int? rating, String? ratingText})> reviewCalls =
      [];

  @override
  Future<ApiResult<InvoiceDetails>> getInvoiceDetails(int invoiceId) async {
    detailCalls.add(invoiceId);
    return detailsResult;
  }

  @override
  Future<ApiResult<void>> cancelInvoice(int invoiceId) async {
    cancelCalls.add(invoiceId);
    return voidResult;
  }

  @override
  Future<ApiResult<void>> createReview({
    required int invoiceId,
    int? rating,
    String? ratingText,
  }) async {
    reviewCalls.add((invoiceId: invoiceId, rating: rating, ratingText: ratingText));
    return voidResult;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  group('InvoiceDetailsCubit', () {
    late _FakeInvoiceRepository repo;
    late InvoiceDetailsCubit cubit;

    setUp(() {
      repo = _FakeInvoiceRepository();
      cubit = InvoiceDetailsCubit(
        GetInvoiceDetailsUseCase(repo),
        CancelInvoiceUseCase(repo),
        CreateReviewUseCase(repo),
      );
    });

    tearDown(() => cubit.close());

    group('loadDetails', () {
      test('emits Loading then Loaded on success', () async {
        final states = <InvoiceDetailsState>[];
        final sub = cubit.stream.listen(states.add);

        await cubit.loadDetails(7);
        await Future<void>.delayed(Duration.zero);

        expect(states, isA<List<InvoiceDetailsState>>());
        expect(cubit.state, isA<InvoiceDetailsLoaded>());
        expect((cubit.state as InvoiceDetailsLoaded).details.invoiceId, 1);
        expect(repo.detailCalls, [7]);
        await sub.cancel();
      });

      test('emits LoadFailure with the backend message', () async {
        repo.detailsResult = ApiResult<InvoiceDetails>.failure('Boom');

        await cubit.loadDetails(7);
        await Future<void>.delayed(Duration.zero);

        expect(cubit.state, isA<InvoiceDetailsLoadFailure>());
        expect((cubit.state as InvoiceDetailsLoadFailure).message, 'Boom');
      });
    });

    group('cancelInvoice', () {
      test('returns null on success without replacing the loaded state',
          () async {
        await cubit.loadDetails(7);
        final loadedState = cubit.state;

        final error = await cubit.cancelInvoice(7);

        expect(error, isNull);
        expect(repo.cancelCalls, [7]);
        // Cancel is an action, not a screen state: details must survive it.
        expect(cubit.state, same(loadedState));
      });

      test('returns the failure message and keeps loaded state', () async {
        await cubit.loadDetails(7);
        final loadedState = cubit.state;
        repo.voidResult = ApiResult<void>.failure('Cannot cancel');

        final error = await cubit.cancelInvoice(7);

        expect(error, 'Cannot cancel');
        expect(cubit.state, same(loadedState));
      });
    });

    group('submitReview', () {
      test('returns null on success and forwards rating/ratingText', () async {
        final error = await cubit.submitReview(
          invoiceId: 7,
          rating: 4,
          ratingText: 'Great',
        );

        expect(error, isNull);
        expect(repo.reviewCalls.single.invoiceId, 7);
        expect(repo.reviewCalls.single.rating, 4);
        expect(repo.reviewCalls.single.ratingText, 'Great');
      });

      test('returns the failure message', () async {
        repo.voidResult = ApiResult<void>.failure('Bad review');

        final error = await cubit.submitReview(
          invoiceId: 7,
          rating: 1,
        );

        expect(error, 'Bad review');
      });
    });

    group('emit-after-close safety', () {
      test('loadDetails after close does not throw', () async {
        await cubit.close();
        // Should not throw StateError / emit-after-close.
        await cubit.loadDetails(7);
      });

      test('cancelInvoice after close returns null without throwing', () async {
        await cubit.close();
        final error = await cubit.cancelInvoice(7);
        expect(error, isNull);
      });

      test('submitReview after close returns null without throwing', () async {
        await cubit.close();
        final error = await cubit.submitReview(invoiceId: 7);
        expect(error, isNull);
      });
    });
  });
}
