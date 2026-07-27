import '../../../../core/constants/api_result.dart';
import '../models/content_type.dart';
import '../repositories/content_repository.dart';
import '../../data/models/content_response_model.dart';

class GetContentUseCase {
  final ContentRepository repository;

  GetContentUseCase(this.repository);

  Future<ApiResult<ContentData>> call(ContentType contentType) =>
      repository.getContent(contentType);
}
