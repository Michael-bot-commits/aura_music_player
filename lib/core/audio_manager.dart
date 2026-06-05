// core/audio_manager.dart
//
// Wraps just_audio's AudioPlayer and audio_session configuration.
// Exposes clean streams consumed by PlayerModel — PlayerModel never
// imports just_audio directly.

import 'dart:async';
import 'package:just_audio/just_audio.dart';
import 'package:just_audio_background/just_audio_background.dart';
import 'package:audio_session/audio_session.dart';
import '../data/models.dart';

class AudioManager {
  final _player = AudioPlayer();

  // ── Streams ────────────────────────────────────────────────────────────────

  /// Emits true while the player is actively playing.
  Stream<bool> get playingStream => _player.playingStream;

  /// Raw position stream — PlayerModel maps this to 0..1 progress.
  Stream<Duration> get positionStream => _player.positionStream;

  /// Emits once each time a track finishes naturally.
  Stream<bool> get completedStream => _player.processingStateStream
      .where((s) => s == ProcessingState.completed)
      .map((_) => true);

  // ── Synchronous state ──────────────────────────────────────────────────────

  bool get playing => _player.playing;
  Duration get position => _player.position;

  // ── Lifecycle ──────────────────────────────────────────────────────────────

  /// Call once at app start (before runApp).
  Future<void> init() async {
    try {
      final session = await AudioSession.instance;
      await session.configure(const AudioSessionConfiguration.music());
    } catch (_) {
      // audio_session is best-effort; not critical if it fails on web
    }
  }

  // ── Playback control ───────────────────────────────────────────────────────

  /// Loads a track from its [filePath] or [streamUrl].
  /// Tags the source with MediaItem so the lock screen / Control Center
  /// shows the correct title and artist. artUri will be populated in
  /// step 12 once cached_network_image / MusicBrainz is in place.
  Future<bool> loadTrack(Track track) async {
    try {
      await _player.stop();
      final tag = MediaItem(
        id: track.id,
        title: track.title,
        artist: track.artist,
        album: track.album,
        duration: Duration(seconds: track.duration),
      );
      if (track.filePath != null && track.filePath!.isNotEmpty) {
        await _player.setAudioSource(
          AudioSource.uri(Uri.file(track.filePath!), tag: tag),
        );
        return true;
      }
      if (track.streamUrl != null && track.streamUrl!.isNotEmpty) {
        await _player.setAudioSource(
          AudioSource.uri(Uri.parse(track.streamUrl!), tag: tag),
        );
        return true;
      }
      return false;
    } catch (_) {
      return false;
    }
  }

  Future<void> play() async {
    try { await _player.play(); } catch (_) {}
  }

  Future<void> pause() async {
    try { await _player.pause(); } catch (_) {}
  }

  /// Seeks to a normalised [progress] (0..1) given the track's [durationSeconds].
  Future<void> seekToProgress(double progress, int durationSeconds) async {
    try {
      final ms = (progress * durationSeconds * 1000).round();
      await _player.seek(Duration(milliseconds: ms));
    } catch (_) {}
  }

  Future<void> setVolume(double volume) async {
    try { await _player.setVolume(volume.clamp(0.0, 1.0)); } catch (_) {}
  }

  void dispose() => _player.dispose();
}
