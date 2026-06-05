// data/models.dart
//
// Domain models for AURA. Artwork keys map 1:1 to asset image names
// (assets/artwork/<key>.jpg) and to the dynamic-colour cache.

import 'package:flutter/foundation.dart';

enum TrackKind { audio, video }

@immutable
class Track {
  final String id;
  final String title;
  final String artist;
  final String album;
  final int duration; // seconds
  final TrackKind kind;
  final String art; // asset key
  final String? streamUrl; // remote URL for streaming
  final String? filePath;  // local file path

  const Track({
    required this.id,
    required this.title,
    required this.artist,
    required this.album,
    required this.duration,
    this.kind = TrackKind.audio,
    required this.art,
    this.streamUrl,
    this.filePath,
  });

  String get durationText => mmss(duration.toDouble());

  static String mmss(double sec) {
    final s = sec.round().clamp(0, 1 << 30);
    final m = s ~/ 60;
    final r = s % 60;
    return '$m:${r < 10 ? '0' : ''}$r';
  }
}

class Playlist {
  final String id;
  final String name;
  final List<String> arts; // up to 4 → mosaic
  final int count;
  final String durationText;
  const Playlist(this.id, this.name, this.arts, this.count, this.durationText);
}

enum DownloadState { queued, downloading, done, error }

class DownloadItem {
  final Track track;
  final DownloadState state;
  final double progress; // 0..1
  final String detail;
  const DownloadItem(this.track, this.state, this.progress, this.detail);
}

class DiscoveryArtist {
  final String name;
  final String art;
  final String? listeners;
  const DiscoveryArtist(this.name, this.art, [this.listeners]);
}

class ArtistPage {
  final String name;
  final String art;
  final String monthly;
  final String bio;
  final List<Track> discography;
  final List<DiscoveryArtist> similar;
  final List<({Track track, String plays})> top;
  const ArtistPage({
    required this.name,
    required this.art,
    required this.monthly,
    required this.bio,
    required this.discography,
    required this.similar,
    required this.top,
  });
}

class BrowserShortcut {
  final String name;
  final String host;
  final int hue; // 0xRRGGBB brand colour of the source
  const BrowserShortcut(this.name, this.host, this.hue);
}
