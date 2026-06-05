// data/player_model.dart
//
// Playback state as a ChangeNotifier (Provider).
// Delegates all audio operations to AudioManager (just_audio).
// Progress and isPlaying are driven by AudioManager's streams.

import 'dart:async';
import 'dart:math';
import 'package:flutter/foundation.dart';
import '../core/audio_manager.dart';
import 'models.dart';

class PlayerModel extends ChangeNotifier {
  final List<Track> queue;
  final AudioManager _audio;

  int index;
  bool isPlaying;
  double progress; // 0..1
  double volume;
  bool shuffle;
  bool repeatOn;
  final Set<String> _liked;
  String contextLabel;

  StreamSubscription<bool>? _playingSub;
  StreamSubscription<Duration>? _positionSub;
  StreamSubscription<bool>? _completedSub;

  PlayerModel({
    required this.queue,
    required AudioManager audio,
    this.index = 0,
    this.isPlaying = false,
    this.progress = 0,
    this.volume = 0.62,
    this.shuffle = false,
    this.repeatOn = false,
    Set<String>? liked,
    this.contextLabel = 'BIBLIOTHÈQUE · NUITS FEUTRÉES',
  })  : _audio = audio, // ignore: prefer_initializing_formals
        _liked = liked ?? {'goldhour'} {
    _initStreams();
    _audio.setVolume(volume);
    _loadCurrent(autoPlay: false);
  }

  Track get current => queue[index];
  bool get isLiked => _liked.contains(current.id);

  // ── Stream wiring ──────────────────────────────────────────────────────────

  void _initStreams() {
    _playingSub = _audio.playingStream.listen((p) {
      isPlaying = p;
      notifyListeners();
    });
    _completedSub = _audio.completedStream.listen((_) => _handleCompleted());
  }

  void _listenPosition() {
    _positionSub?.cancel();
    _positionSub = _audio.positionStream.listen((pos) {
      final dur = current.duration;
      if (dur > 0) {
        progress = (pos.inMilliseconds / (dur * 1000)).clamp(0.0, 1.0);
        notifyListeners();
      }
    });
  }

  Future<void> _loadCurrent({bool autoPlay = true}) async {
    _positionSub?.cancel();
    progress = 0;
    notifyListeners();
    final loaded = await _audio.loadTrack(current);
    if (loaded) {
      _listenPosition();
      if (autoPlay) await _audio.play();
    }
  }

  void _handleCompleted() {
    if (repeatOn) {
      seek(0);
      _audio.play();
    } else {
      next();
    }
  }

  // ── Public API ─────────────────────────────────────────────────────────────

  void togglePlay() {
    isPlaying ? _audio.pause() : _audio.play();
  }

  void toggleLike() {
    _liked.contains(current.id)
        ? _liked.remove(current.id)
        : _liked.add(current.id);
    notifyListeners();
  }

  void next() {
    if (shuffle) {
      final rng = Random();
      int n;
      do { n = rng.nextInt(queue.length); } while (n == index && queue.length > 1);
      index = n;
    } else {
      index = (index + 1) % queue.length;
    }
    _loadCurrent(autoPlay: isPlaying);
    notifyListeners();
  }

  void previous() {
    if (progress > 0.04) {
      seek(0);
    } else {
      index = (index - 1 + queue.length) % queue.length;
      _loadCurrent(autoPlay: isPlaying);
      notifyListeners();
    }
  }

  void jumpTo(int i) {
    index = i % queue.length;
    _loadCurrent(autoPlay: true);
    notifyListeners();
  }

  void play(Track t) {
    final i = queue.indexWhere((q) => q.id == t.id);
    if (i >= 0) {
      index = i;
      _loadCurrent(autoPlay: true);
      notifyListeners();
    }
  }

  void seek(double v) {
    progress = v.clamp(0.0, 1.0);
    _audio.seekToProgress(progress, current.duration);
    notifyListeners();
  }

  void setVolume(double v) {
    volume = v.clamp(0.0, 1.0);
    _audio.setVolume(volume);
    notifyListeners();
  }

  void toggleShuffle() {
    shuffle = !shuffle;
    notifyListeners();
  }

  void toggleRepeat() {
    repeatOn = !repeatOn;
    notifyListeners();
  }

  @override
  void dispose() {
    _playingSub?.cancel();
    _positionSub?.cancel();
    _completedSub?.cancel();
    _audio.dispose();
    super.dispose();
  }
}
