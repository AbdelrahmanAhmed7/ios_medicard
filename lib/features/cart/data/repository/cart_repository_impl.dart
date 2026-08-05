import '../../../../core/constants/api_result.dart';
import '../../../../core/constants/constants.dart';
import '../../../../core/helpers/shared_pref_helper.dart';
import '../../../../core/utils/api_error_parser.dart';
import 'package:flutter/foundation.dart';
import '../api/cart_remote_data_source.dart';
import '../dto/add_cart_request_dto.dart';
import '../dto/cart_dto.dart';
import '../dto/cart_item_dto.dart';
import '../dto/category_counter_dto.dart';
import '../dto/category_service_dto.dart';
import '../dto/category_services_dto.dart';
import '../dto/choose_providers_dto.dart';
import '../dto/update_cart_provider_request_dto.dart';
import '../../domain/models/cart.dart';
import '../../domain/models/cart_item.dart';
import '../../domain/models/category_counter.dart';
import '../../domain/models/category_service.dart';
import '../../domain/models/category_services.dart';
import '../../domain/models/provider_covered_service.dart';
import '../../domain/models/provider_option.dart';
import '../../domain/repository/cart_repository.dart';

class CartRepositoryImpl implements CartRepository {
  final CartRemoteDataSource _dataSource;

  CartRepositoryImpl(this._dataSource);

  Future<String> get _bearerToken async {
    final token = await SharedPrefHelper.getSecuredString(
      SharedPrefKeys.userToken,
    );
    return 'Bearer $token';
  }

  String _failureMessage({
    List<String>? errors,
    String? message,
    required String fallback,
  }) {
    final raw = (errors != null && errors.isNotEmpty)
        ? errors.join('\n')
        : message?.isNotEmpty == true
        ? message!
        : fallback;
    return parseApiError(raw);
  }

  Cart _mapCartDtoToDomain(CartDto dto) {
    return Cart(
      items: (dto.data?.items ?? []).map(_mapCartItemDtoToDomain).toList(),
      totalCount: dto.data?.totalCount ?? 0,
      categoryCounters: (dto.data?.categoryCounters ?? [])
          .map(_mapCategoryCounterDtoToDomain)
          .toList(),
    );
  }

  CartItem _mapCartItemDtoToDomain(CartItemDto dto) {
    return CartItem(
      cartItemId: dto.cartItemId ?? 0,
      serviceId: dto.serviceId ?? 0,
      serviceName: dto.serviceName ?? '',
      categoryId: dto.categoryId ?? 0,
      categoryName: dto.categoryName ?? '',
      providerId: dto.providerId,
      providerName: dto.providerName,
      priceAfter: dto.priceAfter,
      priceBefore: dto.priceBefore,
      discountPercentage: dto.discountPercentage,
    );
  }

  CategoryCounter _mapCategoryCounterDtoToDomain(CategoryCounterDto dto) {
    return CategoryCounter(
      categoryId: dto.categoryId ?? 0,
      categoryName: dto.categoryName ?? '',
      count: dto.count ?? 0,
    );
  }

  CategoryServices _mapCategoryServicesDtoToDomain(CategoryServicesDto dto) {
    return CategoryServices(
      items: (dto.data?.items ?? [])
          .map(_mapCategoryServiceDtoToDomain)
          .toList(),
      totalSelectedCount: dto.data?.totalSelectedCount ?? 0,
    );
  }

  CategoryService _mapCategoryServiceDtoToDomain(CategoryServiceDto dto) {
    return CategoryService(
      serviceId: dto.serviceId ?? 0,
      serviceName: dto.serviceName ?? '',
      isSelected: dto.isSelected ?? false,
    );
  }

  @override
  Future<ApiResult<Cart>> getCart() async {
    try {
      final token = await _bearerToken;
      final response = await _dataSource.getCart(token);
      // If the backend returns `succeeded: true` with `data: null` for an
      // empty cart, treat it as an empty cart instead of an error.
      if (response.succeeded == true) {
        return ApiResult.success(_mapCartDtoToDomain(response));
      }

      return ApiResult.failure(
        _failureMessage(
          errors: response.errors,
          message: response.message,
          fallback: 'Failed to load cart.',
        ),
      );
    } catch (error) {
      if (kDebugMode) {
        debugPrint(
          '[CartRepository] addToCart failed: ${error.runtimeType} $error',
        );
      }
      return ApiResult.failure(parseApiError(error));
    }
  }

  @override
  Future<ApiResult<void>> addToCart({
    required int serviceId,
    required int categoryId,
    int? providerId,
    String? cardNumber,
    double? price,
  }) async {
    try {
      final token = await _bearerToken;
      final request = AddCartRequestDto(
        serviceId: serviceId,
        categoryId: categoryId,
        providerId: providerId,
        cardNumber: cardNumber,
        price: price,
      );
      final response = await _dataSource.addToCart(token, request);
      return (response.succeeded == true)
          ? const ApiResult.success(null)
          : ApiResult.failure(
              _failureMessage(
                errors: response.errors,
                message: response.message,
                fallback: 'Failed to add item to cart.',
              ),
            );
    } catch (error) {
      return ApiResult.failure(parseApiError(error));
    }
  }

  @override
  Future<ApiResult<void>> removeFromCart(int serviceId) async {
    try {
      final token = await _bearerToken;
      final response = await _dataSource.removeFromCart(token, serviceId);
      return (response.succeeded == true)
          ? const ApiResult.success(null)
          : ApiResult.failure(
              _failureMessage(
                errors: response.errors,
                message: response.message,
                fallback: 'Failed to remove item from cart.',
              ),
            );
    } catch (error) {
      return ApiResult.failure(parseApiError(error));
    }
  }

  @override
  Future<ApiResult<void>> updateCartProvider({
    required int cartId,
    required int providerId,
  }) async {
    try {
      final token = await _bearerToken;
      final response = await _dataSource.updateCartProvider(
        token,
        UpdateCartProviderRequestDto(cartId: cartId, providerId: providerId),
      );
      return (response.succeeded == true)
          ? const ApiResult.success(null)
          : ApiResult.failure(
              _failureMessage(
                errors: response.errors,
                message: response.message,
                fallback: 'Failed to update cart provider.',
              ),
            );
    } catch (error) {
      return ApiResult.failure(parseApiError(error));
    }
  }

  @override
  Future<ApiResult<CategoryServices>> getCategoryServices(
    int categoryId,
  ) async {
    try {
      final token = await _bearerToken;
      final response = await _dataSource.getCategoryServices(token, categoryId);
      return (response.succeeded == true && response.data != null)
          ? ApiResult.success(_mapCategoryServicesDtoToDomain(response))
          : ApiResult.failure(
              _failureMessage(
                errors: response.errors,
                message: response.message,
                fallback: 'Failed to load category services.',
              ),
            );
    } catch (error) {
      return ApiResult.failure(parseApiError(error));
    }
  }

  @override
  Future<ApiResult<void>> clearCart() async {
    try {
      final token = await _bearerToken;
      final response = await _dataSource.clearCart(token);
      if (kDebugMode) {
        debugPrint(
          '[CartRepository] clearCart response: succeeded=${response.succeeded}, message=${response.message}',
        );
      }
      return (response.succeeded == true)
          ? const ApiResult.success(null)
          : ApiResult.failure(
              _failureMessage(
                errors: response.errors,
                message: response.message,
                fallback: 'Failed to clear cart.',
              ),
            );
    } catch (error) {
      if (kDebugMode) {
        debugPrint('[CartRepository] clearCart error: ${error.runtimeType} $error');
      }
      return ApiResult.failure(parseApiError(error));
    }
  }

  @override
  Future<ApiResult<List<ProviderOption>>> getChooseProviders() async {
    try {
      final token = await _bearerToken;
      final response = await _dataSource.getChooseProviders(token);
      if (response.succeeded == true && response.data != null) {
        final providers = (response.data!.items ?? [])
            .map(_mapProviderOptionDtoToDomain)
            .toList();
        return ApiResult.success(providers);
      }
      return ApiResult.failure(
        _failureMessage(
          errors: response.errors,
          message: response.message,
          fallback: 'Failed to load providers.',
        ),
      );
    } catch (error) {
      return ApiResult.failure(parseApiError(error));
    }
  }

  ProviderOption _mapProviderOptionDtoToDomain(ProviderOptionDto dto) {
    return ProviderOption(
      providerId: dto.providerId ?? 0,
      providerName: dto.providerName ?? '',
      providerImageUrl: dto.providerImageUrl,
      coveredCount: dto.coveredCount ?? 0,
      uncoveredCount: dto.uncoveredCount ?? 0,
      totalCount: dto.totalCount ?? 0,
      totalPriceBefore: dto.totalPriceBefore ?? 0,
      totalPriceAfter: dto.totalPriceAfter ?? 0,
      coveredServices: (dto.coveredServices ?? [])
          .map(_mapProviderCoveredServiceDtoToDomain)
          .toList(),
      uncoveredServices: (dto.uncoveredServices ?? [])
          .map(_mapProviderCoveredServiceDtoToDomain)
          .toList(),
    );
  }

  ProviderCoveredService _mapProviderCoveredServiceDtoToDomain(
    ProviderCoveredServiceDto dto,
  ) {
    return ProviderCoveredService(
      cartItemId: dto.cartItemId ?? 0,
      serviceId: dto.serviceId ?? 0,
      serviceName: dto.serviceName ?? '',
      priceBefore: dto.priceBefore,
      priceAfter: dto.priceAfter,
      discountPercentage: dto.discountPercentage,
    );
  }
}
