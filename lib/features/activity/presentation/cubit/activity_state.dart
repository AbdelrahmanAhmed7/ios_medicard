import 'package:freezed_annotation/freezed_annotation.dart';
import '../../domain/models/invoice_item.dart';

part 'activity_state.freezed.dart';

@freezed
class ActivityState with _$ActivityState {
  const factory ActivityState.initial() = _Initial;
  const factory ActivityState.loading() = _Loading;
  const factory ActivityState.success({
    required List<InvoiceItem> invoices,
    @Default(false) bool isLoadingMore,
    @Default(false) bool hasMore,
  }) = _Success;
  const factory ActivityState.failure(String error) = _Failure;
}
