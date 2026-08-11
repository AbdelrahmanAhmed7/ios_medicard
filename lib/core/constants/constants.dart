bool isLoggedInUser = false;
bool shouldShowOnboarding = true;

const int kMaxFamilyMembers = 3;

class SharedPrefKeys {
  static const String userToken = 'userToken';
  static const String hasSeenOnboarding = 'hasSeenOnboarding';
  static const String medicardCardNo = 'medicardCardNo';
  static const String appLanguage = 'appLanguage';

  // ── Auth session (secure storage) ──────────────────────────────────────────
  static const String accessToken = 'access_token';
  static const String refreshToken = 'refresh_token';
  static const String accessTokenExpiresAt = 'access_token_expires_at';
  static const String refreshTokenExpiresAt = 'refresh_token_expires_at';
}
