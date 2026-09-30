import '../../../../core/constants/api_result.dart';
import '../repositories/invoice_repository.dart';

class CreateReviewUseCase {
  final InvoiceRepository _repository;

  CreateReviewUseCase(this._repository);

  Future<ApiResult<void>> call({
    required int invoiceId,
    int? rating,
    String? ratingText,
  }) => _repository.createReview(
    invoiceId: invoiceId,
    rating: rating,
    ratingText: ratingText,
  );
}
