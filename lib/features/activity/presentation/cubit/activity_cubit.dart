import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/api_result.dart';
import '../../domain/repositories/invoice_repository.dart';
import 'activity_state.dart';

class ActivityCubit extends Cubit<ActivityState> {
  final InvoiceRepository _repository;

  ActivityCubit(this._repository) : super(const ActivityState.initial());

  Future<void> loadInvoices() async {
    if (isClosed) return;
    emit(const ActivityState.loading());

    final result = await _repository.getMyInvoices();

    if (isClosed) return;
    result.when(
      success: (invoices) => emit(ActivityState.success(invoices)),
      failure: (message) => emit(ActivityState.failure(message)),
    );
  }
}
