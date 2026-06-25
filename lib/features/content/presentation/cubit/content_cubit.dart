import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:medicard/core/utils/api_error_parser.dart';
import '../../domain/models/content_type.dart';
import '../../domain/use_cases/get_content_use_case.dart';
import 'content_state.dart';

class ContentCubit extends Cubit<ContentState> {
  final GetContentUseCase _getContentUseCase;

  ContentCubit(this._getContentUseCase) : super(const ContentState.initial());

  Future<void> loadContent(ContentType contentType) async {
    if (isClosed) return;
    emit(const ContentState.loading());
    try {
      final result = await _getContentUseCase.call(contentType);
      if (isClosed) return;
      if (result.succeeded == true && result.data != null) {
        emit(ContentState.success(result.data!));
      } else {
        emit(ContentState.failed(result.errors?.join(', ') ?? 'Unknown error'));
      }
    } catch (e) {
      if (isClosed) return;
      emit(ContentState.failed(parseApiError(e)));
    }
  }
}
