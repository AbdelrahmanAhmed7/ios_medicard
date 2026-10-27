import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';

import '../../../../core/utils/api_error_parser.dart';
import '../../domain/repository/activate_card_repository.dart';
import '../models/activate_card_request_model.dart';
import '../models/activate_card_response_model.dart';

class ActivateCardRepositoryImpl implements ActivateCardRepository {
  final Dio _dio;

  ActivateCardRepositoryImpl(this._dio);

  @override
  Future<Either<String, ActivateCardResponseModel>> activateCard(
    ActivateCardRequestModel request,
  ) async {
    try {
      final response = await _dio.post(
        'CardActivation/activate',
        data: request.toJson(),
      );

      final dynamic data = response.data;
      if (data is! Map<String, dynamic>) {
        return Left(_backendMessageFrom(data) ?? parseApiError(''));
      }

      if (data['succeeded'] == false) {
        return Left(_backendMessageFrom(data) ?? parseApiError(''));
      }

      final decodedResponse = ActivateCardResponseModel.fromJson(data);

      if (decodedResponse.succeeded) {
        return Right(decodedResponse);
      } else {
        final errorMessage =
            _backendMessageFrom(data) ??
            (decodedResponse.message.isNotEmpty
                ? decodedResponse.message
                : parseApiError(''));
        return Left(errorMessage);
      }
    } on DioException catch (e) {
      if (e.response?.data != null) {
        final backendMessage = _backendMessageFrom(e.response!.data);
        if (backendMessage != null && backendMessage.isNotEmpty) {
          return Left(backendMessage);
        }
      }
      return Left(parseApiError(e));
    } catch (e) {
      return Left(parseApiError(e));
    }
  }

  String? _backendMessageFrom(dynamic value) {
    final message = _extractBackendMessages(value);
    return message.isEmpty ? null : friendlyApiMessage(message);
  }

  String _extractBackendMessages(dynamic value) {
    if (value == null) return '';
    if (value is String) return value.trim();
    if (value is num || value is bool) return value.toString();

    if (value is Iterable) {
      return value
          .map(_extractBackendMessages)
          .where((message) => message.isNotEmpty)
          .join('\n');
    }

    if (value is Map) {
      const preferredKeys = [
        'errors',
        'message',
        'Message',
        'title',
        'Title',
        'detail',
        'Detail',
        'error',
        'Error',
      ];

      final preferredMessages = preferredKeys
          .where(value.containsKey)
          .map((key) => _extractBackendMessages(value[key]))
          .where((message) => message.isNotEmpty)
          .join('\n');
      if (preferredMessages.isNotEmpty) return preferredMessages;

      return value.values
          .map(_extractBackendMessages)
          .where((message) => message.isNotEmpty)
          .join('\n');
    }

    return '';
  }
}
