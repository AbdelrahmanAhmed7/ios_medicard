import 'package:freezed_annotation/freezed_annotation.dart';
import '../../data/models/content_response_model.dart';

part 'content_state.freezed.dart';

@freezed
class ContentState with _$ContentState {
  const factory ContentState.initial() = _Initial;
  const factory ContentState.loading() = _Loading;
  const factory ContentState.success(ContentData data) = _Success;
  const factory ContentState.failed(String error) = _Failed;
}
