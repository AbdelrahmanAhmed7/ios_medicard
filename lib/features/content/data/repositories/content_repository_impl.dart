import 'package:dio/dio.dart';
import 'package:medicard/core/constants/api_result.dart';
import 'package:medicard/core/network/app_failure.dart';
import 'package:medicard/core/network/error_mapper.dart';
import 'package:medicard/service/medicard_api_service.dart';
import '../../domain/models/content_type.dart';
import '../../domain/repositories/content_repository.dart';
import '../models/content_response_model.dart';

class ContentRepositoryImpl implements ContentRepository {
  final MedicardApiService apiService;

  ContentRepositoryImpl(this.apiService);

  @override
  Future<ApiResult<ContentData>> getContent(ContentType contentType) async {
    try {
      final response = await apiService.getContent(contentType.slug);
      if (response.succeeded == true && response.data != null) {
        return ApiResult.success(response.data!);
      }

      return ApiResult.failure(
        (response.errors != null && response.errors!.isNotEmpty)
            ? response.errors!.join('\n')
            : response.message?.isNotEmpty == true
            ? response.message!
            : 'content.load_failed',
      );
    } catch (error) {
      final appFailure = error is DioException
          ? (error.error is AppFailure
                ? error.error! as AppFailure
                : mapDioException(error))
          : const AppFailure.unexpected();
      return ApiResult.failure(_messageForFailure(appFailure));
    }
  }

  String _messageForFailure(AppFailure failure) {
    if (failure.message?.isNotEmpty == true) return failure.message!;
    switch (failure.type) {
      case AppFailureType.network:
        return 'home.no_internet_message';
      case AppFailureType.connectionTimeout:
      case AppFailureType.timeout:
        return 'home.connection_timeout_message';
      case AppFailureType.transferTimeout:
        return 'home.transfer_timeout_message';
      case AppFailureType.unauthorized:
        return 'home.unauthorized_message';
      case AppFailureType.server:
      case AppFailureType.forbidden:
      case AppFailureType.notFound:
        return 'content.load_failed';
      case AppFailureType.cancelled:
      case AppFailureType.unexpected:
        return 'home.unknown_error_message';
    }
  }
}
