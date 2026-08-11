import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';

import '../../network/data/provider_page_response_model.dart';
import '../../network/data/provider_services_response_model.dart';

part 'medicard_network_api_service.g.dart';

@RestApi(baseUrl: 'https://medicard-api-v2.medicardeg.com/api/')
abstract class MedicardNetworkApiService {
  factory MedicardNetworkApiService(Dio dio, {String baseUrl}) =
      _MedicardNetworkApiService;

  @GET("ProviderPage/{providerId}")
  Future<ProviderPageResponse> getProviderPage(
    @Path("providerId") int providerId,
  );

  @GET("ProviderPage/{providerId}/branchLocations")
  Future<ProviderBranchesResponse> getProviderBranchLocations(
    @Path("providerId") int providerId,
  );

  @GET("https://medicard-api-v2.medicardeg.com/services")
  Future<ProviderServicesResponse> getProviderServices(
    @Query("providerId") int providerId, {
    @Query("search") String? search,
    @Query("pageNumber") int? pageNumber,
    @Query("pageSize") int? pageSize,
  });

  @GET("ProviderPage/{providerId}/reviews")
  Future<ProviderReviewsResponse> getProviderReviews(
    @Path("providerId") int providerId, {
    @Query("pageNumber") int? pageNumber,
    @Query("pageSize") int? pageSize,
  });

  @GET("ProviderPage/{providerId}/packages")
  Future<ProviderPackagesResponse> getProviderPackages(
    @Path("providerId") int providerId, {
    @Query("pageNumber") int? pageNumber,
    @Query("pageSize") int? pageSize,
  });

  @GET("Package/{packageId}")
  Future<PackageDetailsResponse> getPackageDetails(
    @Path("packageId") int packageId,
  );
}
