import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';

import '../dto/create_invoice_response_dto.dart';
import '../dto/create_cart_invoice_request_dto.dart';
import '../dto/create_review_request_dto.dart';
import '../dto/invoice_details_response_dto.dart';
import '../dto/create_package_invoice_request_dto.dart';
import '../dto/invoices_response_dto.dart';

part 'invoice_remote_data_source.g.dart';

@RestApi(baseUrl: 'https://medicard-api-v2.medicardeg.com/api/')
abstract class InvoiceRemoteDataSource {
  factory InvoiceRemoteDataSource(Dio dio, {String baseUrl}) =
      _InvoiceRemoteDataSource;

  @GET('Invoice/my-invoices')
  Future<InvoicesResponseDto> getMyInvoices({
    @Header('Accept-Language') required String language,
    @Query('pageNumber') int pageNumber = 1,
    @Query('pageSize') int pageSize = 10,
    @Query('Tab') int? tab,
  });

  @POST('Invoice/from-package')
  Future<CreateInvoiceResponseDto> createFromPackage(
    @Body() CreatePackageInvoiceRequestDto request,
  );

  @POST('ProviderBranchView/invoices/create-from-cart')
  Future<CreateInvoiceResponseDto> createFromCart(
    @Body() CreateCartInvoiceRequestDto request,
  );

  @GET('ProviderBranchView/invoices/{invoiceId}/details')
  Future<InvoiceDetailsResponseDto> getInvoiceDetails(
    @Path('invoiceId') int invoiceId,
  );

  @POST('Review/reviews')
  Future<CreateInvoiceResponseDto> createReview(
    @Body() CreateReviewRequestDto request,
  );

  @PUT('Invoice/cancel/{invoiceId}')
  Future<CreateInvoiceResponseDto> cancelInvoice(
    @Path('invoiceId') int invoiceId,
  );
}
