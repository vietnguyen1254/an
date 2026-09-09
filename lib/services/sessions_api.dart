import 'dart:convert';

import 'package:http/http.dart' as http;

import '../config.dart';
import '../models/meditation_session.dart';

/// Read-only client for the meditation/breathing catalog. Content is added
/// by hand on the server (see backend/README.md) — there is no write path.
class SessionsApi {
  SessionsApi._();
  static final SessionsApi instance = SessionsApi._();

  Future<List<MeditationSession>> fetchAll({String? guide, String? category}) async {
    final query = <String, String>{
      if (guide != null) 'guide': guide,
      if (category != null) 'category': category,
    };
    final uri = Uri.parse('${AppConfig.apiBaseUrl}/v1/sessions').replace(queryParameters: query.isEmpty ? null : query);

    final res = await http.get(uri).timeout(const Duration(seconds: 10));
    if (res.statusCode != 200) {
      throw Exception('failed to load sessions (${res.statusCode})');
    }
    final body = jsonDecode(res.body) as Map<String, dynamic>;
    final rows = body['sessions'] as List<dynamic>;
    return rows.map((r) => MeditationSession.fromJson(r as Map<String, dynamic>)).toList();
  }

  /// Absolute URL for a media path returned by the API (e.g. audio_url,
  /// image_url), which is server-relative ("/media/...").
  String resolve(String path) => '${AppConfig.apiBaseUrl}$path';
}
