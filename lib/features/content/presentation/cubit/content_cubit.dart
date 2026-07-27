import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:medicard/core/constants/api_result.dart';
import '../../domain/models/content_type.dart';
import '../../domain/use_cases/get_content_use_case.dart';
import 'content_state.dart';

class ContentCubit extends Cubit<ContentState> {
  final GetContentUseCase _getContentUseCase;
  Future<void>? _activeLoad;
  ContentType? _activeType;

  ContentCubit(this._getContentUseCase) : super(const ContentState.initial());

  Future<void> loadContent(ContentType contentType, {bool force = false}) {
    if (isClosed) return Future.value();
    if (!force && _activeLoad != null && _activeType == contentType) {
      return _activeLoad!;
    }

    final load = _performLoad(contentType);
    _activeType = contentType;
    _activeLoad = load;
    return load.whenComplete(() {
      if (identical(_activeLoad, load)) {
        _activeLoad = null;
        _activeType = null;
      }
    });
  }

  Future<void> retry(ContentType contentType) =>
      loadContent(contentType, force: true);

  Future<void> _performLoad(ContentType contentType) async {
    if (isClosed) return;
    emit(const ContentState.loading());
    final result = await _getContentUseCase.call(contentType);
    if (isClosed) return;
    result.when(
      success: (data) => emit(ContentState.success(data)),
      failure: (message) => emit(ContentState.failed(message)),
    );
  }
}
