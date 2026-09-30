part of 'invoice_details_cubit.dart';

sealed class InvoiceDetailsState {
  const InvoiceDetailsState();
}

final class InvoiceDetailsInitial extends InvoiceDetailsState {
  const InvoiceDetailsInitial();
}

final class InvoiceDetailsLoading extends InvoiceDetailsState {
  const InvoiceDetailsLoading();
}

final class InvoiceDetailsLoaded extends InvoiceDetailsState {
  final InvoiceDetails details;

  const InvoiceDetailsLoaded(this.details);
}

final class InvoiceDetailsLoadFailure extends InvoiceDetailsState {
  final String message;

  const InvoiceDetailsLoadFailure(this.message);
}
