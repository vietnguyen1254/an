import 'dart:async';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:just_audio_background/just_audio_background.dart';
import 'package:provider/provider.dart';
import '../../models/mood.dart';
import '../../state/app_state.dart';
import '../../theme/colors.dart';
import '../../widgets/may.dart';

enum PlayerKind { breathing, guided }

class PlayerScreen extends StatefulWidget {
  final PlayerKind kind;
  final String title;
  final String? guide;
  final int minutes;

  /// Absolute URL of the recording. When null, the screen falls back to a
  /// silent visual-only timer (used before any real content exists).
  final String? audioUrl;
  final String? imageUrl;
  final String? seriesLabel;

  /// Backend id of the catalog session being played, when there is one —
  /// attached to each meditation-time log so the server can attribute
  /// listened time. Null for the standalone breathing timers.
  final String? sessionId;

  const PlayerScreen({
    super.key,
    required this.kind,
    required this.title,
    this.guide,
    this.minutes = 5,
    this.audioUrl,
    this.imageUrl,
    this.seriesLabel,
    this.sessionId,
  });

  @override
  State<PlayerScreen> createState() => _PlayerScreenState();
}

const _breaths = ['Hít vào…', 'Giữ…', 'Thở ra…'];

class _PlayerScreenState extends State<PlayerScreen> with SingleTickerProviderStateMixin {
  AudioPlayer? _player;
  StreamSubscription<Duration>? _positionSub;
  StreamSubscription<Duration?>? _durationSub;
  StreamSubscription<bool>? _playingSub;

  bool _playing = true;
  // Distinguishes "Phát" (never started yet — including the brief window
  // while audio is still loading, before the first real play() lands) from
  // "Tiếp" (was playing, now paused) — both would otherwise collapse to the
  // same "_playing == false" state.
  bool _hasStarted = false;
  int _phase = 0;
  Duration _elapsed = Duration.zero;
  Duration? _duration;
  Timer? _phaseTimer;
  Timer? _tickTimer;
  Timer? _trackTimer;
  late final AnimationController _breatheCtrl;
  late final AppState _appState;

  /// How much of _elapsed has already been persisted to AppState — logging
  /// incrementally during playback (not just once at dispose) means most of
  /// a session survives even if the app is killed mid-play.
  int _loggedSeconds = 0;

  void _flushMeditationLog() {
    final delta = _elapsed.inSeconds - _loggedSeconds;
    if (delta <= 0) return;
    _loggedSeconds = _elapsed.inSeconds;
    final appState = _appState;
    debugPrint('PlayerScreen: logging ${delta}s of meditation time (elapsed=${_elapsed.inSeconds}s)');
    WidgetsBinding.instance.addPostFrameCallback((_) => appState.addMeditationSeconds(delta, sessionId: widget.sessionId));
  }

  int get _totalSeconds => _duration?.inSeconds ?? widget.minutes * 60;

  @override
  void initState() {
    super.initState();
    _appState = context.read<AppState>();
    _breatheCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 4500))..repeat(reverse: true);
    _phaseTimer = Timer.periodic(const Duration(milliseconds: 4500), (_) {
      if (_playing) setState(() => _phase = (_phase + 1) % 3);
    });
    // Persist listened time as we go, not just once when the screen closes.
    _trackTimer = Timer.periodic(const Duration(seconds: 10), (_) => _flushMeditationLog());

    final url = widget.audioUrl;
    if (url != null) {
      final player = AudioPlayer();
      _player = player;
      _positionSub = player.positionStream.listen((p) => setState(() => _elapsed = p));
      _durationSub = player.durationStream.listen((d) => setState(() => _duration = d));
      _playingSub = player.playingStream.listen((p) => setState(() {
            _playing = p;
            if (p) _hasStarted = true;
          }));
      player
          .setAudioSource(LockCachingAudioSource(
            Uri.parse(url),
            tag: MediaItem(
              id: url,
              title: widget.title,
              artist: widget.guide ?? 'An',
              artUri: widget.imageUrl != null ? Uri.parse(widget.imageUrl!) : null,
            ),
          ))
          .then((_) => player.play())
          .catchError((Object e) => debugPrint('PlayerScreen: failed to load audio: $e'));
    } else {
      // No recording yet — keep the old silent countdown so the breathing
      // animation still works standalone. Starts immediately, no loading
      // gap, so it's genuinely "started" from the first frame.
      _hasStarted = true;
      _tickTimer = Timer.periodic(const Duration(seconds: 1), (_) {
        if (_playing && _elapsed.inSeconds < _totalSeconds) {
          setState(() => _elapsed += const Duration(seconds: 1));
        }
      });
    }
  }

  @override
  void dispose() {
    _flushMeditationLog();
    _phaseTimer?.cancel();
    _tickTimer?.cancel();
    _trackTimer?.cancel();
    _breatheCtrl.dispose();
    _positionSub?.cancel();
    _durationSub?.cancel();
    _playingSub?.cancel();
    _player?.dispose();
    super.dispose();
  }

  /// Only two guides exist app-wide and callers pass the already-resolved
  /// display name (not a stable key), so a small name match here is simpler
  /// than threading a guide key through every PlayerScreen call site.
  String? get _guidePhotoAsset {
    final g = widget.guide;
    if (g == null) return null;
    if (g.contains('Justin')) return 'assets/guides/justin.jpg';
    if (g.contains('Trâm')) return 'assets/guides/tram.jpg';
    return null;
  }

  String _fmt(int sec) {
    final m = sec ~/ 60;
    final s = sec % 60;
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  void _togglePlay() {
    final player = _player;
    if (player == null) {
      setState(() => _playing = !_playing);
      return;
    }
    if (player.playing) {
      player.pause();
    } else {
      player.play();
    }
  }

  void _seekBy(int deltaSeconds) {
    final player = _player;
    if (player == null) return;
    final target = _elapsed + Duration(seconds: deltaSeconds);
    final clamped = target < Duration.zero
        ? Duration.zero
        : (_duration != null && target > _duration! ? _duration! : target);
    player.seek(clamped);
  }

  @override
  Widget build(BuildContext context) {
    final pct = (_elapsed.inSeconds / _totalSeconds).clamp(0.0, 1.0);
    final breathLabel = _playing ? _breaths[_phase] : 'Tạm dừng';

    return Scaffold(
      backgroundColor: AppColors.sessionDarkC,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(26, 8, 26, 40),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  GestureDetector(
                    onTap: () => Navigator.of(context).pop(),
                    child: Text('Xong', style: TextStyle(fontFamily: 'BeVietnamPro', fontSize: 14, color: Colors.white.withValues(alpha: 0.5))),
                  ),
                  Text(
                    widget.kind == PlayerKind.guided ? 'Đang phát' : widget.title,
                    style: TextStyle(fontFamily: 'BeVietnamPro', fontSize: 13, color: Colors.white.withValues(alpha: 0.4)),
                  ),
                  Container(width: 22, height: 22, decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: Colors.white.withValues(alpha: 0.2)))),
                ],
              ),
              if (widget.kind == PlayerKind.breathing) ...[
                SizedBox(
                  height: 320,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      AnimatedBuilder(
                        animation: _breatheCtrl,
                        builder: (context, child) => Transform.scale(scale: 0.86 + 0.2 * _breatheCtrl.value, child: child),
                        child: Container(width: 300, height: 300, decoration: BoxDecoration(shape: BoxShape.circle, color: AppColors.rose.withValues(alpha: 0.16))),
                      ),
                      Container(width: 236, height: 236, decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: Colors.white.withValues(alpha: 0.14)))),
                      Container(width: 170, height: 170, decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: Colors.white.withValues(alpha: 0.08)))),
                      const May(mood: Mood.binhThuong, size: 110),
                    ],
                  ),
                ),
                const SizedBox(height: 6),
                Text(breathLabel, style: const TextStyle(fontFamily: 'Lora', fontSize: 30, color: Colors.white)),
                const SizedBox(height: 10),
                Text('Theo nhịp của Mây, không cần gắng', style: TextStyle(fontFamily: 'BeVietnamPro', fontWeight: FontWeight.w300, fontSize: 14, color: Colors.white.withValues(alpha: 0.45))),
              ] else ...[
                Container(
                  margin: const EdgeInsets.only(top: 20),
                  height: 260,
                  clipBehavior: Clip.hardEdge,
                  decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.06), borderRadius: BorderRadius.circular(28)),
                  child: widget.imageUrl != null
                      ? Image.network(widget.imageUrl!, fit: BoxFit.cover, errorBuilder: (_, _, _) => const SizedBox.expand())
                      : null,
                ),
                const SizedBox(height: 24),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(widget.title, style: const TextStyle(fontFamily: 'Lora', fontSize: 27, height: 36 / 27, color: Colors.white)),
                ),
                const SizedBox(height: 16),
                Row(children: [
                  Container(
                    width: 36,
                    height: 36,
                    clipBehavior: Clip.hardEdge,
                    decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.white.withValues(alpha: 0.14)),
                    child: _guidePhotoAsset != null ? Image.asset(_guidePhotoAsset!, fit: BoxFit.cover) : null,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Thiền dẫn · ${widget.guide}', style: const TextStyle(fontFamily: 'BeVietnamPro', fontWeight: FontWeight.w500, fontSize: 14, color: Colors.white)),
                        if (widget.seriesLabel != null) ...[
                          const SizedBox(height: 2),
                          Text(widget.seriesLabel!, style: TextStyle(fontFamily: 'BeVietnamPro', fontWeight: FontWeight.w300, fontSize: 12.5, color: Colors.white.withValues(alpha: 0.45))),
                        ],
                      ],
                    ),
                  ),
                ]),
              ],
              const Spacer(),
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                Text(_fmt(_elapsed.inSeconds), style: TextStyle(fontFamily: 'BeVietnamPro', fontWeight: FontWeight.w300, fontSize: 12, color: Colors.white.withValues(alpha: 0.45))),
                Text('-${_fmt((_totalSeconds - _elapsed.inSeconds).clamp(0, _totalSeconds))}', style: TextStyle(fontFamily: 'BeVietnamPro', fontWeight: FontWeight.w300, fontSize: 12, color: Colors.white.withValues(alpha: 0.45))),
              ]),
              const SizedBox(height: 8),
              ClipRRect(
                borderRadius: BorderRadius.circular(2),
                child: Container(
                  height: 3,
                  color: Colors.white.withValues(alpha: 0.14),
                  child: FractionallySizedBox(widthFactor: pct, alignment: Alignment.centerLeft, child: Container(color: Colors.white.withValues(alpha: 0.75))),
                ),
              ),
              const SizedBox(height: 28),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _skipBtn('15', () => _seekBy(-15)),
                  const SizedBox(width: 34),
                  GestureDetector(
                    onTap: _togglePlay,
                    child: Container(
                      width: 72,
                      height: 72,
                      alignment: Alignment.center,
                      decoration: const BoxDecoration(shape: BoxShape.circle, color: Colors.white),
                      child: Text(_playing ? 'Dừng' : (_hasStarted ? 'Tiếp' : 'Phát'), style: const TextStyle(fontFamily: 'BeVietnamPro', fontWeight: FontWeight.w500, fontSize: 13, color: Color(0xFF16201E))),
                    ),
                  ),
                  const SizedBox(width: 34),
                  _skipBtn('15', () => _seekBy(15)),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _skipBtn(String label, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 44,
        height: 44,
        alignment: Alignment.center,
        decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: Colors.white.withValues(alpha: 0.18))),
        child: Text(label, style: TextStyle(fontFamily: 'BeVietnamPro', fontSize: 12, color: Colors.white.withValues(alpha: 0.6))),
      ),
    );
  }
}
