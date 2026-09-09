enum SessionKind { breathing, guided }

class MeditationSession {
  final String id;
  final String slug;
  final String title;
  final String guide;
  final String category;
  final SessionKind kind;
  final int durationSeconds;
  final String audioUrl;
  final String? imageUrl;
  final bool isFree;
  final String? seriesName;
  final int? seriesIndex;
  final int? seriesTotal;

  const MeditationSession({
    required this.id,
    required this.slug,
    required this.title,
    required this.guide,
    required this.category,
    required this.kind,
    required this.durationSeconds,
    required this.audioUrl,
    this.imageUrl,
    required this.isFree,
    this.seriesName,
    this.seriesIndex,
    this.seriesTotal,
  });

  factory MeditationSession.fromJson(Map<String, dynamic> json) {
    return MeditationSession(
      id: json['id'] as String,
      slug: json['slug'] as String,
      title: json['title'] as String,
      guide: json['guide'] as String,
      category: json['category'] as String,
      kind: json['kind'] == 'breathing' ? SessionKind.breathing : SessionKind.guided,
      durationSeconds: json['duration_seconds'] as int,
      audioUrl: json['audio_url'] as String,
      imageUrl: json['image_url'] as String?,
      isFree: json['is_free'] as bool,
      seriesName: json['series_name'] as String?,
      seriesIndex: json['series_index'] as int?,
      seriesTotal: json['series_total'] as int?,
    );
  }

  int get minutes => (durationSeconds / 60).round();
}
