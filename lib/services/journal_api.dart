import 'dart:convert';

import 'package:http/http.dart' as http;

import '../config.dart';
import '../models/journal_entry.dart';

/// Client for the An backend's journal entries API. Every call needs the app
/// JWT from [AuthApi.syncSession] — callers should catch failures and keep
/// working with the local copy (see AppState.saveDraftEntry).
class JournalApi {
  JournalApi._();
  static final JournalApi instance = JournalApi._();

  Map<String, String> _headers(String token) => {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      };

  Future<List<JournalEntry>> fetchAll(String token) async {
    final uri = Uri.parse('${AppConfig.apiBaseUrl}/v1/entries');
    final res = await http.get(uri, headers: _headers(token)).timeout(const Duration(seconds: 10));
    if (res.statusCode != 200) {
      throw Exception('failed to load entries (${res.statusCode})');
    }
    final body = jsonDecode(res.body) as Map<String, dynamic>;
    final rows = body['entries'] as List<dynamic>;
    return rows.map((r) => JournalEntry.fromJson(r as Map<String, dynamic>)).toList();
  }

  Future<JournalEntry> create(String token, JournalEntry draft) async {
    final uri = Uri.parse('${AppConfig.apiBaseUrl}/v1/entries');
    final res = await http.post(uri, headers: _headers(token), body: jsonEncode(draft.toJson())).timeout(const Duration(seconds: 10));
    if (res.statusCode != 201) {
      throw Exception('failed to create entry (${res.statusCode})');
    }
    return JournalEntry.fromJson(jsonDecode(res.body) as Map<String, dynamic>);
  }

  Future<JournalEntry> update(String token, String id, JournalEntry draft) async {
    final uri = Uri.parse('${AppConfig.apiBaseUrl}/v1/entries/$id');
    final res = await http.patch(uri, headers: _headers(token), body: jsonEncode(draft.toJson())).timeout(const Duration(seconds: 10));
    if (res.statusCode != 200) {
      throw Exception('failed to update entry (${res.statusCode})');
    }
    return JournalEntry.fromJson(jsonDecode(res.body) as Map<String, dynamic>);
  }

  Future<void> delete(String token, String id) async {
    final uri = Uri.parse('${AppConfig.apiBaseUrl}/v1/entries/$id');
    final res = await http.delete(uri, headers: _headers(token)).timeout(const Duration(seconds: 10));
    if (res.statusCode != 204 && res.statusCode != 404) {
      throw Exception('failed to delete entry (${res.statusCode})');
    }
  }
}
