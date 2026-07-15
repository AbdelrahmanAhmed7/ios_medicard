import 'package:medicard/core/constants/constants.dart';
import 'package:medicard/core/helpers/shared_pref_helper.dart';
import 'package:medicard/service/medicard_api_service.dart';
import '../../domain/models/content_type.dart';
import '../../domain/repositories/content_repository.dart';
import '../models/content_response_model.dart';

class ContentRepositoryImpl implements ContentRepository {
  final MedicardApiService apiService;

  ContentRepositoryImpl(this.apiService);

  @override
  Future<ContentResponseModel> getContent(ContentType contentType) async {
    final token = await SharedPrefHelper.getSecuredString(
      SharedPrefKeys.userToken,
    );
    switch (contentType) {
      case ContentType.privacyPolicy:
        return apiService.getPrivacyPolicy('Bearer $token');
      case ContentType.refundPolicy:
        return apiService.getRefundPolicy('Bearer $token');
      case ContentType.termsAndConditions:
        return apiService.getTermsAndConditions('Bearer $token');
    }
  }
}
