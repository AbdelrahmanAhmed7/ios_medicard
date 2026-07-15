import '../../../../core/network/app_failure.dart';

/// Home-specific, presentation-safe failure categories.
enum HomeFailureType {
  noInternet,
  connectionTimeout,
  transferTimeout,
  server,
  unauthorized,
  unknown,
}

const _failureCodePrefix = 'home_failure:';

extension HomeFailureTypeCode on HomeFailureType {
  String get code => '$_failureCodePrefix$name';
}

HomeFailureType homeFailureFromCode(String code) {
  if (!code.startsWith(_failureCodePrefix)) return HomeFailureType.unknown;
  return HomeFailureType.values.firstWhere(
    (type) => type.name == code.substring(_failureCodePrefix.length),
    orElse: () => HomeFailureType.unknown,
  );
}

HomeFailureType homeFailureFromAppFailure(AppFailure failure) {
  switch (failure.type) {
    case AppFailureType.network:
      return HomeFailureType.noInternet;
    case AppFailureType.connectionTimeout:
      return HomeFailureType.connectionTimeout;
    case AppFailureType.timeout:
    case AppFailureType.transferTimeout:
      return HomeFailureType.transferTimeout;
    case AppFailureType.unauthorized:
      return HomeFailureType.unauthorized;
    case AppFailureType.server:
      return HomeFailureType.server;
    case AppFailureType.forbidden:
    case AppFailureType.notFound:
    case AppFailureType.cancelled:
    case AppFailureType.unexpected:
      return HomeFailureType.unknown;
  }
}
