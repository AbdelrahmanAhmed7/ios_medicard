import '../models/content_type.dart';
import '../../data/models/content_response_model.dart';

abstract class ContentRepository {
  Future<ContentResponseModel> getContent(ContentType contentType);
}
