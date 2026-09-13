import 'dart:convert';

import 'package:http/http.dart' as http;

import '../config.dart';

/// Client for the An backend's `/v1/me` — the signed-in user's server-side
/// profile (name, avatar id, plan tier). These are authoritative on the
/// server and synced to every device. Every call needs the app JWT from
/// [AuthApi.syncSession]; failures are the caller's to swallow.
class MeApi {
  MeApi._();
  static final MeApi instance = MeApi._();

  Map<String, String> _headers(String token) => {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      };

  /// The raw `/v1/me` object (`{name, avatar, plan_tier, …}`), or null if it
  /// can't be fetched.
  Future<Map<String, dynamic>?> fetchMe(String token) async {
    final uri = Uri.parse('${AppConfig.apiBaseUrl}/v1/me');
    final res = await http.get(uri, headers: _headers(token)).timeout(const Duration(seconds: 8));
    if (res.statusCode != 200) return null;
    return jsonDecode(res.body) as Map<String, dynamic>;
  }

  /// PATCHes any subset of the mutable profile fields. Only non-null values
  /// are sent (the server coalesces the rest).
  Future<void> updateProfile(
    String token, {
    String? name,
    String? avatar,
    String? planTier,
  }) async {
    final body = <String, dynamic>{};
    if (name != null) body['name'] = name;
    if (avatar != null) body['avatar'] = avatar;
    if (planTier != null) body['plan_tier'] = planTier;
    if (body.isEmpty) return;
    final uri = Uri.parse('${AppConfig.apiBaseUrl}/v1/me');
    final res = await http
        .patch(uri, headers: _headers(token), body: jsonEncode(body))
        .timeout(const Duration(seconds: 8));
    if (res.statusCode != 200) {
      throw Exception('failed to update profile (${res.statusCode})');
    }
  }

  /// Permanently deletes the user and everything owned by it (journal
  /// entries + meditation logs cascade on the server). Throws on anything but
  /// 200/204 — including 404, which means the endpoint isn't deployed yet, so
  /// the caller must NOT treat that as a successful deletion.
  Future<void> deleteAccount(String token) async {
    final uri = Uri.parse('${AppConfig.apiBaseUrl}/v1/me');
    final res = await http.delete(uri, headers: _headers(token)).timeout(const Duration(seconds: 10));
    if (res.statusCode != 204 && res.statusCode != 200) {
      throw Exception('failed to delete account (${res.statusCode})');
    }
  }
}
