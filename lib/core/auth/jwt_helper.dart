import 'dart:convert';

/// Decodes the `exp` claim from a JWT and returns it as a UTC [DateTime].
///
/// Returns `null` if the token is malformed or the claim is absent.
///
/// NOTE: This function intentionally does NOT log the token value.
DateTime? getJwtExpiryDate(String token) {
  try {
    final parts = token.split('.');
    if (parts.length != 3) return null;

    // Base64url-decode the payload (second segment).
    final payload = parts[1];
    final normalized = base64Url.normalize(payload);
    final decoded = utf8.decode(base64Url.decode(normalized));
    final payloadMap = jsonDecode(decoded) as Map<String, dynamic>;

    final exp = payloadMap['exp'];
    if (exp == null) return null;

    return DateTime.fromMillisecondsSinceEpoch(
      (exp as int) * 1000,
      isUtc: true,
    );
  } catch (_) {
    return null;
  }
}
