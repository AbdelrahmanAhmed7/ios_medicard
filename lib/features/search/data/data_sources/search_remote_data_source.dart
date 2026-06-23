import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';

import '../models/category_response_model.dart';
import '../models/lookup_response_model.dart';
import '../models/search_response_model.dart';

part 'search_remote_data_source.g.dart';

@RestApi(baseUrl: 'https://medicard-api-v2.medicardeg.com/api/')
abstract class SearchRemoteDataSource {
  factory SearchRemoteDataSource(Dio dio, {String baseUrl}) =
      _SearchRemoteDataSource;

  @GET('Search/providers')
  Future<SearchResponseModel> searchProviders(
    @Header('Authorization') String token, {
    @Query('Keyword') String? keyword,
    @Query('CategoryId') int? categoryId,
    @Query('GovernorateId') int? governorateId,
    @Query('CityId') int? cityId,
    @Query('ProviderId') int? providerId,
    @Query('BranchId') int? branchId,
    @Query('SortBy') int? sortBy,
    @Query('UserLatitude') double? userLatitude,
    @Query('UserLongitude') double? userLongitude,
    @Query('PageNumber') int? pageNumber,
    @Query('PageSize') int? pageSize,
  });

  @GET('Lookups/categories')
  Future<CategoryResponseModel> getCategories(
    @Header('Authorization') String token,
  );

  @GET('Lookups/governorates')
  Future<LookupResponseModel> getGovernorates(
    @Header('Authorization') String token,
  );

  @GET('Lookups/cities')
  Future<LookupResponseModel> getCities(
    @Header('Authorization') String token,
    @Query('governorateId') int governorateId,
  );
}
