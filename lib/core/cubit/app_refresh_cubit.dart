import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'app_refresh_state.dart';
part 'app_refresh_cubit.freezed.dart';

class AppRefreshCubit extends Cubit<AppRefreshState> {
  AppRefreshCubit() : super(const AppRefreshState.initial());

  void triggerLanguageRefresh() {
    emit(const AppRefreshState.languageChanged());
    emit(const AppRefreshState.initial());
  }
}
