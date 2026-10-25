import 'dart:convert';
import 'package:dartz/dartz.dart';
import 'package:http/http.dart' as http;
import '../../../../core/utils/api_error_parser.dart';
import '../../domain/repository/activate_card_repository.dart';
import '../models/activate_card_request_model.dart';
import '../models/activate_card_response_model.dart';

class ActivateCardRepositoryImpl implements ActivateCardRepository {
  static const String baseUrl = 'https://medicard-api-v2.medicardeg.com';

  @override
  Future<Either<String, ActivateCardResponseModel>> activateCard(
    ActivateCardRequestModel request,
  ) async {
    try {
      final response = await http
          .post(
            Uri.parse('$baseUrl/api/CardActivation/activate'),
            headers: {'accept': '*/*', 'content-type': 'application/json'},
            body: json.encode(request.toJson()),
          )
          .timeout(const Duration(seconds: 30));

      final decodedJson = json.decode(response.body);
      if (decodedJson is! Map<String, dynamic>) {
        return Left(_backendMessageFrom(decodedJson) ?? parseApiError(''));
      }

      if (response.statusCode < 200 || response.statusCode >= 300) {
        return Left(_backendMessageFrom(decodedJson) ?? parseApiError(''));
      }

      if (decodedJson['succeeded'] == false) {
        return Left(_backendMessageFrom(decodedJson) ?? parseApiError(''));
      }

      final decodedResponse = ActivateCardResponseModel.fromJson(decodedJson);

      if (decodedResponse.succeeded) {
        return Right(decodedResponse);
      } else {
        final errorMessage =
            _backendMessageFrom(decodedJson) ??
            (decodedResponse.message.isNotEmpty
                ? decodedResponse.message
                : parseApiError(''));
        return Left(errorMessage);
      }
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

    return value.toString().trim();
  }
}
