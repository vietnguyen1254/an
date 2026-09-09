/// The signed-in user, normalised across every provider.
class AuthUser {
  /// Firebase UID — stable across providers and app reinstalls.
  final String uid;

  /// Email address. Can be `null` when a provider doesn't return one
  /// (e.g. Facebook accounts without a verified email, or an Apple user who
  /// hides their email and no relay address is exposed).
  final String? email;

  /// Display name, when the provider supplies one.
  final String? name;

  /// 'google' | 'apple' | 'facebook'
  final String provider;

  /// Firebase ID token (JWT) — hand this to the backend to establish a
  /// session; the backend verifies it with the Firebase Admin SDK.
  final String idToken;

  const AuthUser({
    required this.uid,
    required this.email,
    required this.name,
    required this.provider,
    required this.idToken,
  });
}

/// Thrown when the user backs out of the provider sheet. Callers should treat
/// this as a no-op (no error UI).
class AuthCancelledException implements Exception {
  const AuthCancelledException();
}

/// Any other sign-in failure, with a Vietnamese message safe to show.
class AuthException implements Exception {
  final String message;
  const AuthException(this.message);

  @override
  String toString() => 'AuthException: $message';
}
