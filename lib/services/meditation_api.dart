import 'dart:convert';

import 'package:http/http.dart' as http;

import '../config.dart';
import '../models/meditation_log.dart';

/// Client for the An backend's meditation-time log. Every call needs the app
/// JWT from [AuthApi.syncSession]; callers should catch failures and keep
/// working with the local copy (see AppState.addMeditationSeconds).
class MeditationApi {
  MeditationApi._();
  static final MeditationApi instance = MeditationApi._();

  Map<String, String> _headers(String token) => {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      };

  Future<List<MeditationLog>> fetchAll(String token) async {
    final uri = Uri.parse('${AppConfig.apiBaseUrl}/v1/meditation-logs');
    final res = await http.get(uri, headers: _headers(token)).timeout(const Duration(seconds: 10));
    if (res.statusCode != 200) {
      throw Exception('failed to load meditation logs (${res.statusCode})');
    }
    final body = jsonDecode(res.body) as Map<String, dynamic>;
    final rows = body['logs'] as List<dynamic>;
    return rows.map((r) => MeditationLog.fromJson(r as Map<String, dynamic>)).toList();
  }

  Future<MeditationLog> create(String token, MeditationLog log) async {
    final uri = Uri.parse('${AppConfig.apiBaseUrl}/v1/meditation-logs');
    final res = await http
        .post(
          uri,
          headers: _headers(token),
          body: jsonEncode({
            'seconds': log.seconds,
            'logged_at': log.date.toUtc().toIso8601String(),
            if (log.sessionId != null) 'session_id': log.sessionId,
          }),
        )
        .timeout(const Duration(seconds: 10));
    if (res.statusCode != 201) {
      throw Exception('failed to create meditation log (${res.statusCode})');
    }
    return MeditationLog.fromJson(jsonDecode(res.body) as Map<String, dynamic>);
  }
}
