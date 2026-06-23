import '../../../../core/constants/api_result.dart';
import '../../data/models/category_model.dart';
import '../repositories/search_repository.dart';

class GetCategoriesUseCase {
  final SearchRepository _repository;

  GetCategoriesUseCase(this._repository);

  Future<ApiResult<List<CategoryModel>>> call() async {
    return _repository.getCategories();
  }
}
