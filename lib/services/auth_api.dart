import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../config.dart';
import 'auth_user.dart';

/// Thin client for the An backend's auth endpoint.
///
/// After every successful SSO sign-in the app calls [syncSession] with the
/// Firebase ID token; the backend verifies it (Firebase Admin SDK) and
/// upserts the user, returning an app JWT used as the Bearer token for every
/// other authenticated call (journal entries, etc). Failures are swallowed
/// and logged — the app keeps working locally/offline either way.
class AuthApi {
  AuthApi._();
  static final AuthApi instance = AuthApi._();

  /// Returns the app JWT on success, null if the backend isn't reachable
  /// (or not configured) — callers should keep working offline in that case.
  Future<String?> syncSession(AuthUser user) async {
    if (!AppConfig.hasBackend) {
      if (kDebugMode) {
        debugPrint('AuthApi: no backend configured, skipping session sync');
      }
      return null;
    }

    final uri = Uri.parse('${AppConfig.apiBaseUrl}/v1/auth/session');
    try {
      final res = await http
          .post(
            uri,
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer ${user.idToken}',
            },
            body: jsonEncode({
              'provider': user.provider,
              'email': user.email,
              'name': user.name,
              'firebase_uid': user.uid,
            }),
          )
          .timeout(const Duration(seconds: 8));

      if (res.statusCode >= 200 && res.statusCode < 300) {
        if (kDebugMode) debugPrint('AuthApi: session synced');
        final body = jsonDecode(res.body) as Map<String, dynamic>;
        return body['token'] as String?;
      }
      if (kDebugMode) {
        debugPrint('AuthApi: session sync failed ${res.statusCode}');
      }
      return null;
    } catch (e) {
      // Network down / backend not up yet — don't block sign-in.
      if (kDebugMode) debugPrint('AuthApi: session sync error $e');
      return null;
    }
  }
}
