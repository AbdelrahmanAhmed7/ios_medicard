import '../../../../core/constants/api_result.dart';
import '../../data/models/category_services_response_model.dart';
import '../repositories/search_repository.dart';

class GetCategoryServicesUseCase {
  final SearchRepository _repository;

  GetCategoryServicesUseCase(this._repository);

  Future<ApiResult<CategoryServicesDataModel>> call(int categoryId) async {
    return _repository.getCategoryServices(categoryId);
  }
}
