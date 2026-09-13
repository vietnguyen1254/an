/// One chunk of listened meditation/breathing time. The player flushes these
/// incrementally during playback (see PlayerScreen), so a session can produce
/// several. Persisted locally (SharedPreferences) for offline use and synced
/// to the backend via [MeditationApi] — [id] is the backend id, null until a
/// row has been created server-side.
class MeditationLog {
  final String? id;
  final DateTime date;
  final int seconds;
  final String? sessionId;

  const MeditationLog(this.date, this.seconds, {this.id, this.sessionId});

  Map<String, dynamic> toJson() => {
        if (id != null) 'id': id,
        'date': date.toIso8601String(),
        'seconds': seconds,
        if (sessionId != null) 'session_id': sessionId,
      };

  factory MeditationLog.fromJson(Map<String, dynamic> j) => MeditationLog(
        // Local cache uses 'date' (already local wall-clock, .toLocal() is a
        // no-op on it); the backend returns 'logged_at' as UTC ('Z'-suffixed).
        // Without converting the latter, callers that bucket by calendar day
        // (e.g. weekly/monthly meditation totals) read the UTC day instead of
        // the local one — wrong for any session between local midnight and
        // 07:00 in Vietnam (UTC+7), where the UTC day is still "yesterday".
        DateTime.parse((j['date'] ?? j['logged_at']) as String).toLocal(),
        j['seconds'] as int,
        id: j['id'] as String?,
        sessionId: j['session_id'] as String?,
      );
}
