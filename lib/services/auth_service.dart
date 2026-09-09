import 'dart:convert';
import 'dart:io' show Platform;
import 'dart:math';

import 'package:crypto/crypto.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

import '../config.dart';
import 'auth_user.dart';

/// Handles the three SSO flows. Each `signInWith*` runs the provider's native
/// sheet, exchanges the result for a Firebase credential, and returns a
/// normalised [AuthUser] (with a fresh Firebase ID token for the backend).
///
/// Whether Firebase itself is wired up is a separate concern — see
/// [AuthService.available], set by `main()` after `Firebase.initializeApp`.
class AuthService {
  AuthService._();
  static final AuthService instance = AuthService._();

  /// False until Firebase has been initialised successfully (i.e. the native
  /// GoogleService-Info.plist / google-services.json are in place). The login
  /// screen uses this to show a "not configured yet" message instead of
  /// throwing.
  static bool available = false;

  bool _googleInitialised = false;

  FirebaseAuth get _fb => FirebaseAuth.instance;

  // --- Google --------------------------------------------------------------

  Future<AuthUser> signInWithGoogle() async {
    _ensureAvailable();
    try {
      if (!_googleInitialised) {
        await GoogleSignIn.instance.initialize(
          clientId: (Platform.isIOS && AppConfig.googleIosClientId.isNotEmpty)
              ? AppConfig.googleIosClientId
              : null,
          serverClientId: AppConfig.googleServerClientId.isNotEmpty
              ? AppConfig.googleServerClientId
              : null,
        );
        _googleInitialised = true;
      }

      final account = await GoogleSignIn.instance.authenticate();
      final idToken = account.authentication.idToken;
      if (idToken == null) {
        throw const AuthException('Không lấy được thông tin từ Google.');
      }

      final userCred = await _fb.signInWithCredential(
        GoogleAuthProvider.credential(idToken: idToken),
      );
      return await _toAuthUser(
        userCred,
        provider: 'google',
        fallbackEmail: account.email,
        fallbackName: account.displayName,
      );
    } on GoogleSignInException catch (e) {
      if (e.code == GoogleSignInExceptionCode.canceled) {
        throw const AuthCancelledException();
      }
      throw AuthException(_friendly(e));
    } on FirebaseAuthException catch (e) {
      throw AuthException(_friendly(e));
    }
  }

  // --- Apple ---------------------------------------------------------------

  Future<AuthUser> signInWithApple() async {
    _ensureAvailable();
    final rawNonce = _randomNonce();
    final hashedNonce = sha256.convert(utf8.encode(rawNonce)).toString();

    try {
      final apple = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
        nonce: hashedNonce,
      );

      final identityToken = apple.identityToken;
      if (identityToken == null) {
        throw const AuthException('Không lấy được thông tin từ Apple.');
      }

      final userCred = await _fb.signInWithCredential(
        OAuthProvider('apple.com').credential(
          idToken: identityToken,
          rawNonce: rawNonce,
          accessToken: apple.authorizationCode,
        ),
      );

      // Apple only returns the name/email on the *very first* authorization
      // for this app; persist whatever we get.
      final appleName = [
        apple.givenName,
        apple.familyName,
      ].whereType<String>().join(' ').trim();
      return await _toAuthUser(
        userCred,
        provider: 'apple',
        fallbackEmail: apple.email,
        fallbackName: appleName.isEmpty ? null : appleName,
      );
    } on SignInWithAppleAuthorizationException catch (e) {
      if (e.code == AuthorizationErrorCode.canceled) {
        throw const AuthCancelledException();
      }
      throw AuthException(_friendly(e));
    } on FirebaseAuthException catch (e) {
      throw AuthException(_friendly(e));
    }
  }

  // --- Facebook ----------------------------------------------------------

  Future<AuthUser> signInWithFacebook() async {
    _ensureAvailable();
    try {
      final result = await FacebookAuth.instance.login(
        permissions: const ['email', 'public_profile'],
      );

      switch (result.status) {
        case LoginStatus.cancelled:
          throw const AuthCancelledException();
        case LoginStatus.success:
          break;
        default:
          throw AuthException(result.message ?? 'Đăng nhập Facebook thất bại.');
      }

      final token = result.accessToken;
      if (token == null) {
        throw const AuthException('Không lấy được thông tin từ Facebook.');
      }

      // Facebook doesn't put the email in the token — ask the Graph API.
      final graph = await FacebookAuth.instance.getUserData(
        fields: 'email,name',
      );

      final userCred = await _fb.signInWithCredential(
        FacebookAuthProvider.credential(token.tokenString),
      );
      return await _toAuthUser(
        userCred,
        provider: 'facebook',
        fallbackEmail: graph['email'] as String?,
        fallbackName: graph['name'] as String?,
      );
    } on FirebaseAuthException catch (e) {
      throw AuthException(_friendly(e));
    }
  }

  // --- shared ------------------------------------------------------------

  Future<void> signOut() async {
    try {
      await GoogleSignIn.instance.signOut();
    } catch (_) {}
    try {
      await FacebookAuth.instance.logOut();
    } catch (_) {}
    if (available) await _fb.signOut();
  }

  /// A previously signed-in user restored by Firebase on launch, if any.
  Future<AuthUser?> restore() async {
    if (!available) return null;
    final user = _fb.currentUser;
    if (user == null) return null;
    final idToken = await user.getIdToken() ?? '';
    return AuthUser(
      uid: user.uid,
      email: user.email,
      name: user.displayName,
      provider: user.providerData.isNotEmpty
          ? _providerLabel(user.providerData.first.providerId)
          : 'unknown',
      idToken: idToken,
    );
  }

  Future<AuthUser> _toAuthUser(
    UserCredential cred, {
    required String provider,
    String? fallbackEmail,
    String? fallbackName,
  }) async {
    final user = cred.user;
    if (user == null) {
      throw const AuthException('Đăng nhập không thành công.');
    }
    if ((user.displayName == null || user.displayName!.isEmpty) &&
        fallbackName != null) {
      await user.updateDisplayName(fallbackName);
    }
    final idToken = await user.getIdToken() ?? '';
    return AuthUser(
      uid: user.uid,
      email: user.email ?? fallbackEmail,
      name: user.displayName ?? fallbackName,
      provider: provider,
      idToken: idToken,
    );
  }

  void _ensureAvailable() {
    if (!available) {
      throw const AuthException(
        'Đăng nhập chưa được cấu hình. Xem AUTH_SETUP.md.',
      );
    }
  }

  String _providerLabel(String providerId) {
    if (providerId.contains('google')) return 'google';
    if (providerId.contains('apple')) return 'apple';
    if (providerId.contains('facebook')) return 'facebook';
    return providerId;
  }

  String _randomNonce([int length = 32]) {
    const chars =
        '0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._';
    final rand = Random.secure();
    return List.generate(
      length,
      (_) => chars[rand.nextInt(chars.length)],
    ).join();
  }

  String _friendly(Object e) {
    if (kDebugMode) debugPrint('auth error: $e');
    return 'Có lỗi khi đăng nhập. Vui lòng thử lại.';
  }
}
