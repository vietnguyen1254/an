/// App-wide configuration for the backend and OAuth providers.
///
/// Everything here is overridable at build time with --dart-define so real
/// secrets never have to live in source control:
///
///   flutter run \
///     --dart-define=AN_API_BASE_URL=https://api.an.app \
///     --dart-define=AN_GOOGLE_SERVER_CLIENT_ID=xxxx.apps.googleusercontent.com \
///     --dart-define=AN_GOOGLE_IOS_CLIENT_ID=yyyy.apps.googleusercontent.com
///
/// See AUTH_SETUP.md for the full checklist (Firebase project, provider
/// consoles, native config).
class AppConfig {
  AppConfig._();

  /// Base URL of the An backend. The client sends the Firebase ID token here
  /// after every successful sign-in (see [AuthApi]). Points at a placeholder
  /// until the real backend is live — calls fail quietly so the app still
  /// works offline in the meantime.
  static const apiBaseUrl = String.fromEnvironment(
    'AN_API_BASE_URL',
    defaultValue: 'https://api.example.com',
  );

  /// Google "Web application" OAuth client ID. Used as the `serverClientId`
  /// so the backend can verify the Google ID token, and required on Android.
  static const googleServerClientId = String.fromEnvironment(
    'AN_GOOGLE_SERVER_CLIENT_ID',
  );

  /// Google "iOS" OAuth client ID. On iOS this can also be supplied through
  /// `GIDClientID` in Info.plist; passing it here keeps it in one place.
  static const googleIosClientId = String.fromEnvironment(
    'AN_GOOGLE_IOS_CLIENT_ID',
  );

  static bool get hasBackend =>
      apiBaseUrl.isNotEmpty && !apiBaseUrl.contains('example.com');
}
