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
/// upserts the user / issues its own session.
///
/// There is no backend yet, so failures here are swallowed and logged — the
/// app keeps working locally. Once [AppConfig.hasBackend] is true, tighten
/// this up (throw on non-2xx, return the session payload, etc.).
class AuthApi {
  AuthApi._();
  static final AuthApi instance = AuthApi._();

  Future<void> syncSession(AuthUser user) async {
    if (!AppConfig.hasBackend) {
      if (kDebugMode) {
        debugPrint('AuthApi: no backend configured, skipping session sync');
      }
      return;
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
      } else {
        if (kDebugMode) {
          debugPrint('AuthApi: session sync failed ${res.statusCode}');
        }
      }
    } catch (e) {
      // Network down / backend not up yet — don't block sign-in.
      if (kDebugMode) debugPrint('AuthApi: session sync error $e');
    }
  }
}
