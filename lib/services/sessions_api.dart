import 'dart:convert';

import 'package:http/http.dart' as http;

import '../config.dart';
import '../models/meditation_session.dart';
import '../models/mood.dart';

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

  /// One session recommended for a check-in's [mood] (dominant signal),
  /// [tags] (topic overlap) and [intensity] (1-10, soft fit range) — scored
  /// server-side against hidden per-session metadata, see
  /// backend/src/routes/sessions.js. Null if the catalog is empty.
  Future<MeditationSession?> recommend(Mood mood, {List<String> tags = const [], int? intensity}) async {
    final uri = Uri.parse('${AppConfig.apiBaseUrl}/v1/sessions/recommend').replace(queryParameters: {
      'mood': mood.name,
      if (tags.isNotEmpty) 'tags': tags.join(','),
      if (intensity != null) 'intensity': '$intensity',
    });
    final res = await http.get(uri).timeout(const Duration(seconds: 10));
    if (res.statusCode != 200) {
      throw Exception('failed to load recommendation (${res.statusCode})');
    }
    final body = jsonDecode(res.body) as Map<String, dynamic>;
    final session = body['session'] as Map<String, dynamic>?;
    return session == null ? null : MeditationSession.fromJson(session);
  }

  /// Absolute URL for a media path returned by the API (e.g. audio_url,
  /// image_url), which is server-relative ("/media/...").
  String resolve(String path) => '${AppConfig.apiBaseUrl}$path';
}
