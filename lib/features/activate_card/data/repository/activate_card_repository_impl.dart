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

      final decodedResponse = ActivateCardResponseModel.fromJson(
        json.decode(response.body),
      );

      if (decodedResponse.succeeded) {
        return Right(decodedResponse);
      } else {
        final errors = decodedResponse.errors;
        final errorsList = (errors is List && errors.isNotEmpty)
            ? errors.map((e) => e.toString()).join('\n')
            : null;
        final errorMessage =
            errorsList ??
            (decodedResponse.message.isNotEmpty
                ? decodedResponse.message
                : parseApiError(''));
        return Left(errorMessage);
      }
    } catch (e) {
      return Left(parseApiError(e));
    }
  }
}
