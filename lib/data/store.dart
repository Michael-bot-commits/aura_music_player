// data/store.dart
//
// Sample content model — the Flutter equivalent of the prototype's
// data.js. Replace the seed with your real catalogue / network layer.

import 'models.dart';

class DataStore {
  static const _t = _tracksSeed;
  final Map<String, Track> tracks = {for (final t in _t) t.id: t};

  static const _order = [
    'distorted', 'nightswim', 'goldhour', 'violetstatic', 'coralcoast', 'magenta',
    'amberdusk', 'indigowave', 'fernyard', 'slatebloom', 'rosequartz', 'tealglass',
  ];

  Track t(String id) => tracks[id]!;
  List<Track> get library => _order.map(t).toList();
  List<Track> get queue => library;

  List<Playlist> get playlists => const [
        Playlist('pl1', 'Nuits feutrées', ['distorted', 'violetstatic', 'magenta', 'indigowave'], 24, '1 h 18'),
        Playlist('pl2', 'Focus / lo-fi', ['slatebloom', 'goldhour', 'tealglass', 'amberdusk'], 18, '58 min'),
        Playlist('pl3', 'Pluie & verre', ['nightswim', 'tealglass', 'indigowave', 'rosequartz'], 31, '1 h 52'),
        Playlist('pl4', 'Rouge sombre', ['coralcoast', 'distorted', 'magenta', 'amberdusk'], 12, '41 min'),
      ];

  List<DownloadItem> get downloadsActive => [
        DownloadItem(t('indigowave'), DownloadState.downloading, 0.68, 'audio · m4a'),
        DownloadItem(t('fernyard'), DownloadState.downloading, 0.34, 'vidéo · 1080p'),
        DownloadItem(t('amberdusk'), DownloadState.queued, 0, 'En attente de téléchargement'),
        DownloadItem(t('magenta'), DownloadState.error, 0.12, 'Échec — on réessaiera tout seul. Vérifie ta connexion.'),
      ];
  List<DownloadItem> get downloadsDone => [
        DownloadItem(t('distorted'), DownloadState.done, 1, 'audio · m4a · 4.8 Mo'),
        DownloadItem(t('goldhour'), DownloadState.done, 1, 'audio · m4a · 5.1 Mo'),
        DownloadItem(t('coralcoast'), DownloadState.done, 1, 'audio · m4a · 4.6 Mo'),
        DownloadItem(t('tealglass'), DownloadState.done, 1, 'vidéo · 720p · 38 Mo'),
      ];
  int get downloadsBadge => downloadsActive.where((d) => d.state != DownloadState.done).length;

  // Discovery
  List<String> get recents => const ['øneheart', 'lo-fi pluie', 'Vela', 'phonk doux', 'Mooncircuit'];
  List<Track> get trending =>
      const ['distorted', 'tealglass', 'magenta', 'goldhour', 'indigowave', 'coralcoast'].map(t).toList();
  List<DiscoveryArtist> get popularArtists => [
        DiscoveryArtist('øneheart', 'distorted', '2,4 M'),
        DiscoveryArtist('Lune', 'rosequartz', '880 k'),
        DiscoveryArtist('Marin', 'tealglass', '1,1 M'),
        DiscoveryArtist('NEØN', 'magenta', '640 k'),
        DiscoveryArtist('Halna', 'goldhour', '430 k'),
      ];
  List<({String source, List<Track> tracks})> get groupedResults => [
        (source: 'Deezer', tracks: const ['distorted', 'coralcoast', 'amberdusk'].map(t).toList()),
        (source: 'SoundCloud', tracks: const ['violetstatic', 'magenta', 'nightswim'].map(t).toList()),
        (source: 'Jamendo', tracks: const ['slatebloom', 'goldhour'].map(t).toList()),
      ];

  ArtistPage get artistPage => ArtistPage(
        name: 'øneheart',
        art: 'distorted',
        monthly: '2 412 880 auditeurs / mois',
        bio:
            "Producteur ambient et phonk atmosphérique, øneheart compose des paysages sonores feutrés où la basse se dissout dans le grain. Son morceau « distorted », né d'une collaboration avec reidenshi, est devenu l'hymne discret d'une génération nocturne — des millions d'écoutes, presque aucun mot.",
        discography:
            const ['distorted', 'magenta', 'violetstatic', 'indigowave', 'amberdusk', 'slatebloom'].map(t).toList(),
        similar: const [
          DiscoveryArtist('reidenshi', 'violetstatic'),
          DiscoveryArtist('Mooncircuit', 'magenta'),
          DiscoveryArtist('Lune', 'rosequartz'),
          DiscoveryArtist('Aris Pell', 'slatebloom'),
        ],
        top: [
          (track: t('distorted'), plays: '48,2 M'),
          (track: t('amberdusk'), plays: '12,9 M'),
          (track: t('indigowave'), plays: '9,1 M'),
          (track: t('magenta'), plays: '7,4 M'),
        ],
      );

  List<BrowserShortcut> get shortcuts => const [
        BrowserShortcut('YouTube', 'youtube.com', 0xFF0033),
        BrowserShortcut('SoundCloud', 'soundcloud.com', 0xFF5500),
        BrowserShortcut('Vimeo', 'vimeo.com', 0x17D5FF),
        BrowserShortcut('Instagram', 'instagram.com', 0xE1306C),
      ];
}

// Demo stream URLs — free public-domain audio (SoundHelix).
// Replace with real tracks at Step 6 (local library) or Step 9 (yt-dlp backend).
// On iOS/Android these stream directly. On Chrome, CORS may block them —
// test audio on mobile for full Step 3 validation.
const _tracksSeed = <Track>[
  Track(id: 'distorted',    title: 'Distorted',    artist: 'øneheart, reidenshi', album: 'snowfall',       duration: 372, art: 'distorted',    streamUrl: 'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-1.mp3'),
  Track(id: 'nightswim',    title: 'Nightswim',    artist: 'Lytham',              album: 'Tidal',           duration: 382, kind: TrackKind.video, art: 'nightswim',    streamUrl: 'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-2.mp3'),
  Track(id: 'goldhour',     title: 'Gold Hour',    artist: 'Halna',               album: 'Low Sun',         duration: 338, art: 'goldhour',     streamUrl: 'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-3.mp3'),
  Track(id: 'violetstatic', title: 'Violet Static',artist: 'Mooncircuit',         album: 'Noise Bloom',     duration: 290, art: 'violetstatic', streamUrl: 'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-4.mp3'),
  Track(id: 'coralcoast',   title: 'Coral Coast',  artist: 'Vela',                album: 'Saltwater',       duration: 421, art: 'coralcoast',   streamUrl: 'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-5.mp3'),
  Track(id: 'magenta',      title: 'Magenta',      artist: 'NEØN',               album: 'After Image',     duration: 311, art: 'magenta',      streamUrl: 'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-6.mp3'),
  Track(id: 'amberdusk',    title: 'Amber Dusk',   artist: 'Hollow Pines',        album: 'Long Light',      duration: 361, art: 'amberdusk',    streamUrl: 'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-7.mp3'),
  Track(id: 'indigowave',   title: 'Indigo Wave',  artist: 'Tessellate',          album: 'Deep Field',      duration: 444, kind: TrackKind.video, art: 'indigowave',   streamUrl: 'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-8.mp3'),
  Track(id: 'fernyard',     title: 'Fernyard',     artist: 'Cobalt Hours',        album: 'Greenhouse',      duration: 458, kind: TrackKind.video, art: 'fernyard',     streamUrl: 'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-9.mp3'),
  Track(id: 'slatebloom',   title: 'Slate Bloom',  artist: 'Aris Pell',           album: 'Quiet Concrete',  duration: 355, art: 'slatebloom',   streamUrl: 'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-10.mp3'),
  Track(id: 'rosequartz',   title: 'Rose Quartz',  artist: 'Lune',                album: 'Soft Geometry',   duration: 287, art: 'rosequartz',   streamUrl: 'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-11.mp3'),
  Track(id: 'tealglass',    title: 'Teal Glass',   artist: 'Marin',               album: 'Atoll',           duration: 398, art: 'tealglass',    streamUrl: 'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-12.mp3'),
];
