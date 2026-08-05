import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';

import '../dto/add_cart_request_dto.dart';
import '../dto/cart_dto.dart';
import '../dto/category_services_dto.dart';
import '../dto/choose_providers_dto.dart';
import '../dto/update_cart_provider_request_dto.dart';
import '../dto/update_cart_provider_response_dto.dart';

part 'cart_remote_data_source.g.dart';

@RestApi(baseUrl: 'https://medicard-api-v2.medicardeg.com/api/')
abstract class CartRemoteDataSource {
  factory CartRemoteDataSource(Dio dio, {String baseUrl}) =
      _CartRemoteDataSource;

  @GET('Cart')
  Future<CartDto> getCart(@Header('Authorization') String token);

  @POST('Cart')
  Future<UpdateCartProviderResponseDto> addToCart(
    @Header('Authorization') String token,
    @Body() AddCartRequestDto request,
  );

  @DELETE('Cart')
  Future<UpdateCartProviderResponseDto> removeFromCart(
    @Header('Authorization') String token,
    @Query('ServiceId') int serviceId,
  );

  @GET('Cart/category/{categoryId}/services')
  Future<CategoryServicesDto> getCategoryServices(
    @Header('Authorization') String token,
    @Path('categoryId') int categoryId,
  );

  @DELETE('Cart/clear')
  Future<UpdateCartProviderResponseDto> clearCart(
    @Header('Authorization') String token,
  );

  @GET('Cart/choose-providers')
  Future<ChooseProvidersDto> getChooseProviders(
    @Header('Authorization') String token,
  );

  @PUT('https://medicard-api-v2.medicardeg.com/update')
  Future<UpdateCartProviderResponseDto> updateCartProvider(
    @Header('Authorization') String token,
    @Body() UpdateCartProviderRequestDto request,
  );
}