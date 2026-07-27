import '../../../../core/constants/api_result.dart';
import '../models/cart.dart';
import '../models/category_services.dart';
import '../models/provider_option.dart';

abstract class CartRepository {
  Future<ApiResult<Cart>> getCart();
  Future<ApiResult<void>> addToCart({
    required int serviceId,
    required int categoryId,
    int? providerId,
    String? cardNumber,
    double? price,
  });
  Future<ApiResult<void>> removeFromCart(int serviceId);
  Future<ApiResult<void>> updateCartProvider({
    required int cartId,
    required int providerId,
  });
  Future<ApiResult<CategoryServices>> getCategoryServices(int categoryId);
  Future<ApiResult<void>> clearCart();
  Future<ApiResult<List<ProviderOption>>> getChooseProviders();
}
