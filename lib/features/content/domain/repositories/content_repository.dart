import '../../../../core/constants/api_result.dart';
import '../models/content_type.dart';
import '../../data/models/content_response_model.dart';

abstract class ContentRepository {
  Future<ApiResult<ContentData>> getContent(ContentType contentType);
}
