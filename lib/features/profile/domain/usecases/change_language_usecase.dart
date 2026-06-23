import '../../../../core/constants/api_result.dart';
import '../../../../domain/medicard_repository.dart';
import '../../data/models/change_language_response_model.dart';

class ChangeLanguageUseCase {
  final MedicardRepository repository;

  ChangeLanguageUseCase(this.repository);

  Future<ApiResult<ChangeLanguageResponseModel>> call({
    required String language,
  }) async {
    return await repository.changeLanguage(language: language);
  }
}
