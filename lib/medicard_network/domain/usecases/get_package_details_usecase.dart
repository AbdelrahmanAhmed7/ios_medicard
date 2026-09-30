import '../../../core/constants/api_result.dart';
import '../../../network/data/provider_page_response_model.dart';
import '../../repository/medicard_network_repository.dart';

/// Single entry point for loading package details: if the endpoint or its
/// parameters change, this file — not every widget — is updated.
class GetPackageDetailsUseCase {
  final MedicardNetworkRepository _repository;

  GetPackageDetailsUseCase(this._repository);

  Future<ApiResult<PackageDetailsResponse>> call({required int packageId}) =>
      _repository.getPackageDetails(packageId: packageId);
}
