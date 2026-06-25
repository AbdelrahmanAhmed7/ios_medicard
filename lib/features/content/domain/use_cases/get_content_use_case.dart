import '../models/content_type.dart';
import '../repositories/content_repository.dart';
import '../../data/models/content_response_model.dart';

class GetContentUseCase {
  final ContentRepository repository;

  GetContentUseCase(this.repository);

  Future<ContentResponseModel> call(ContentType contentType) => repository.getContent(contentType);
}
