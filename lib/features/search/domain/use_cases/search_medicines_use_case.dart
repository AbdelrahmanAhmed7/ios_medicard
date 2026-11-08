import '../../../../core/constants/api_result.dart';
import '../../data/models/medicine_response_model.dart';
import '../repositories/search_repository.dart';

class SearchMedicinesUseCase {
  final SearchRepository _repository;

  SearchMedicinesUseCase(this._repository);

  Future<ApiResult<MedicinePage>> call({
    String? search,
    int? pageNumber,
    int? pageSize,
  }) => _repository.searchMedicines(
    search: search,
    pageNumber: pageNumber,
    pageSize: pageSize,
  );
}
