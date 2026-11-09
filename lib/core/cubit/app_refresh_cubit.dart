import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'app_refresh_state.dart';
part 'app_refresh_cubit.freezed.dart';

class AppRefreshCubit extends Cubit<AppRefreshState> {
  AppRefreshCubit() : super(const AppRefreshState.initial());

  /// Notifies GoRouter to rebuild all route pages after the locale has been
  /// updated so every translation re-evaluates against the new language.
  final ValueNotifier<int> languageRefresh = ValueNotifier(0);

  /// Notifies GoRouter when the persisted session changes.
  final ValueNotifier<int> authRefresh = ValueNotifier(0);

  void triggerAuthRefresh() {
    if (isClosed) return;
    authRefresh.value++;
  }

  void triggerLanguageRefresh() {
    if (isClosed) return;
    emit(const AppRefreshState.languageChanged());
    emit(const AppRefreshState.initial());
    languageRefresh.value++;
  }

  /// Emitted by [AuthInterceptor] when the session is definitively expired
  /// (refresh token missing, expired, or refresh API call failed).
  /// The UI layer should listen for this and redirect to the login screen.
  void triggerSessionExpired() {
    if (isClosed) return;
    emit(const AppRefreshState.sessionExpired());
    emit(const AppRefreshState.initial());
    triggerAuthRefresh();
  }

  /// Counter bumped whenever the profile summary (family count + reward
  /// points) must be re-fetched — e.g. after a family member is added or
  /// deleted on another screen. Profile screens listen to
  /// [profileSummaryRefresh] and silently reload the summary.
  final ValueNotifier<int> profileSummaryRefresh = ValueNotifier(0);

  void triggerProfileSummaryRefresh() {
    if (isClosed) return;
    profileSummaryRefresh.value++;
  }

  /// Counter bumped whenever the invoices list must be re-fetched — e.g.
  /// right after an invoice is created on the checkout screen. The invoices
  /// tab listens to [invoicesRefresh] and reloads its current tab.
  final ValueNotifier<int> invoicesRefresh = ValueNotifier(0);

  void triggerInvoicesRefresh() {
    if (isClosed) return;
    invoicesRefresh.value++;
  }
}
