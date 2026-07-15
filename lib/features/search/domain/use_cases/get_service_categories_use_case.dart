import '../../../../core/constants/api_result.dart';
import '../../data/models/category_model.dart';
import '../repositories/search_repository.dart';

/// Fetches the category list from GET /CategoryService/categories.
/// Used exclusively by the Services tab — distinct from the provider-search
/// categories which come from GET /Lookups/categories.
class GetServiceCategoriesUseCase {
  final SearchRepository _repository;

  GetServiceCategoriesUseCase(this._repository);

  Future<ApiResult<List<CategoryModel>>> call() =>
      _repository.getServiceCategories();
}
