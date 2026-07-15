import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';

import '../dto/invoices_response_dto.dart';

part 'invoice_remote_data_source.g.dart';

@RestApi(baseUrl: 'https://medicard-api-v2.medicardeg.com/api/')
abstract class InvoiceRemoteDataSource {
  factory InvoiceRemoteDataSource(Dio dio, {String baseUrl}) =
      _InvoiceRemoteDataSource;

  @GET('Invoice/my-invoices')
  Future<InvoicesResponseDto> getMyInvoices();
}
