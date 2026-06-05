// screens/discovery_screen.dart
//
// Découverte — three states: empty (recents chips, trending carousel,
// popular artists) → grouped results (Deezer · SoundCloud · Jamendo,
// staggered) → artist page (parallax header, bio, top, discography,
// similar). The row ellipsis opens an options sheet.

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../data/models.dart';
import '../data/store.dart';
import '../theme/tokens.dart';
import '../widgets/artwork.dart';
import '../widgets/buttons.dart';
import '../widgets/common.dart';
import '../widgets/icons.dart';

class DiscoveryScreen extends StatefulWidget {
  final void Function(Track) onPlay;
  final void Function(String) onToast;
  const DiscoveryScreen({super.key, required this.onPlay, required this.onToast});

  @override
  State<DiscoveryScreen> createState() => _DiscoveryScreenState();
}

class _DiscoveryScreenState extends State<DiscoveryScreen> {
  final _controller = TextEditingController();
  String _query = '';
  ArtistPage? _artist;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _openOptions(Track t) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.bg2,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(22))),
      builder: (_) => _OptionsSheet(
        track: t,
        onPlay: () { Navigator.pop(context); widget.onPlay(t); },
        onDownload: (fmt) { Navigator.pop(context); widget.onToast('Téléchargement $fmt lancé'); },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final store = context.read<DataStore>();
    if (_artist != null) {
      return ArtistPageView(page: _artist!, onPlay: widget.onPlay, onBack: () => setState(() => _artist = null));
    }
    final showResults = _query.trim().isNotEmpty;
    return ListView(
      padding: const EdgeInsets.only(bottom: 180),
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(Space.lg, 6, Space.lg, 14),
          child: Text('Découverte', style: AppText.display(32).copyWith(letterSpacing: -0.6)),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(Space.md, 0, Space.md, 16),
          child: SearchField(
            controller: _controller,
            placeholder: 'Artistes, titres, sons…',
            onChanged: (v) => setState(() => _query = v),
          ),
        ),
        if (!showResults) ..._empty(store) else ..._results(store),
      ],
    );
  }

  List<Widget> _empty(DataStore store) {
    return [
      Padding(padding: const EdgeInsets.fromLTRB(Space.md, 0, Space.md, 10), child: Text('RECHERCHES RÉCENTES', style: AppText.sectionHeader)),
      SizedBox(
        height: 34,
        child: ListView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: Space.md),
          children: [
            for (final r in store.recents)
              Padding(
                padding: const EdgeInsets.only(right: 8),
                child: Pressable(
                  onTap: () { _controller.text = r; setState(() => _query = r); },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(color: AppColors.fill3, borderRadius: BorderRadius.circular(R.pill)),
                    child: Text(r, style: AppText.subtitle.copyWith(fontSize: 14, color: AppColors.label)),
                  ),
                ),
              ),
          ],
        ),
      ),
      const SizedBox(height: 26),
      SectionHeader('Tendances', action: 'Tout voir', onAction: () {}),
      SizedBox(
        height: 210,
        child: ListView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: Space.md),
          children: [
            for (int i = 0; i < store.trending.length; i++)
              Padding(padding: const EdgeInsets.only(right: 14), child: _trendCard(store.trending[i], i + 1)),
          ],
        ),
      ),
      const SizedBox(height: 26),
      SectionHeader('Artistes populaires'),
      SizedBox(
        height: 132,
        child: ListView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: Space.md),
          children: [
            for (final a in store.popularArtists)
              Padding(
                padding: const EdgeInsets.only(right: 18),
                child: _artistBubble(a, 92, onTap: () => setState(() => _artist = store.artistPage)),
              ),
          ],
        ),
      ),
    ];
  }

  Widget _trendCard(Track t, int rank) {
    return Pressable(
      onTap: () => widget.onPlay(t),
      child: SizedBox(
        width: 150,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                Artwork(t.art, size: 150, radius: R.md, shadow: true),
                Positioned(
                  left: 8,
                  top: 8,
                  child: Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(color: const Color(0x8C000000), borderRadius: BorderRadius.circular(7)),
                    alignment: Alignment.center,
                    child: Text('$rank', style: AppText.trackTitle.copyWith(fontSize: 13, fontWeight: FontWeight.w700, color: Colors.white)),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(t.title, maxLines: 1, overflow: TextOverflow.ellipsis, style: AppText.trackTitle.copyWith(fontSize: 15)),
            Text(t.artist, maxLines: 1, overflow: TextOverflow.ellipsis, style: AppText.subtitle.copyWith(fontSize: 13)),
          ],
        ),
      ),
    );
  }

  Widget _artistBubble(DiscoveryArtist a, double size, {VoidCallback? onTap}) {
    return Pressable(
      onTap: onTap,
      child: SizedBox(
        width: size,
        child: Column(
          children: [
            ClipOval(child: Image(image: artProvider(a.art), width: size, height: size, fit: BoxFit.cover)),
            const SizedBox(height: 8),
            Text(a.name, maxLines: 1, overflow: TextOverflow.ellipsis, style: AppText.subtitle.copyWith(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.label)),
            if (a.listeners != null) Text(a.listeners!, style: AppText.metaSmall.copyWith(fontSize: 11.5)),
          ],
        ),
      ),
    );
  }

  List<Widget> _results(DataStore store) {
    return [
      for (final group in store.groupedResults) ...[
        SectionHeader(group.source, action: 'Tout voir', onAction: () {}),
        for (int i = 0; i < group.tracks.length; i++)
          _StaggeredItem(
            delayMs: (store.groupedResults.indexOf(group) * 3 + i) * 50,
            child: TrackCell(
              group.tracks[i],
              separator: i < group.tracks.length - 1,
              onTap: () => widget.onPlay(group.tracks[i]),
              onMenu: () => _openOptions(group.tracks[i]),
            ),
          ),
        const SizedBox(height: 14),
      ],
    ];
  }
}

/// Fade+rise entrance, staggered by delay — mirrors the search cascade.
class _StaggeredItem extends StatefulWidget {
  final int delayMs;
  final Widget child;
  const _StaggeredItem({required this.delayMs, required this.child});
  @override
  State<_StaggeredItem> createState() => _StaggeredItemState();
}

class _StaggeredItemState extends State<_StaggeredItem> {
  bool _shown = false;
  @override
  void initState() {
    super.initState();
    Future.delayed(Duration(milliseconds: widget.delayMs), () {
      if (mounted) setState(() => _shown = true);
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedSlide(
      offset: _shown ? Offset.zero : const Offset(0, 0.18),
      duration: Motion.base,
      curve: Motion.easeOut,
      child: AnimatedOpacity(opacity: _shown ? 1 : 0, duration: Motion.base, child: widget.child),
    );
  }
}

class _OptionsSheet extends StatelessWidget {
  final Track track;
  final VoidCallback onPlay;
  final void Function(String) onDownload;
  const _OptionsSheet({required this.track, required this.onPlay, required this.onDownload});

  @override
  Widget build(BuildContext context) {
    final rows = [
      ('playCircle', 'Aperçu 30 s', onPlay),
      ('globe', 'Écouter sur YouTube Music', () => Navigator.pop(context)),
      ('download', 'Télécharger audio', () => onDownload('audio')),
      ('video', 'Télécharger vidéo', () => onDownload('vidéo')),
    ];
    return SafeArea(
      top: false,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SheetHandle(),
          Padding(
            padding: const EdgeInsets.fromLTRB(18, 6, 18, 14),
            child: Row(
              children: [
                Artwork(track.art, size: 46, radius: 9),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(track.title, style: AppText.trackTitle.copyWith(fontSize: 16)),
                    Text(track.artist, style: AppText.subtitle.copyWith(fontSize: 13)),
                  ],
                ),
              ],
            ),
          ),
          for (final r in rows)
            Pressable(
              onTap: r.$3,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                decoration: const BoxDecoration(border: Border(top: BorderSide(color: AppColors.separator, width: 0.5))),
                child: Row(children: [
                  AppIcon(r.$1, size: 20, color: AppColors.accent),
                  const SizedBox(width: 14),
                  Text(r.$2, style: AppText.trackTitle.copyWith(fontSize: 16, fontWeight: FontWeight.w400)),
                ]),
              ),
            ),
          const SizedBox(height: 12),
        ],
      ),
    );
  }
}

/// Artist page with a parallax header.
class ArtistPageView extends StatefulWidget {
  final ArtistPage page;
  final void Function(Track) onPlay;
  final VoidCallback onBack;
  const ArtistPageView({super.key, required this.page, required this.onPlay, required this.onBack});

  @override
  State<ArtistPageView> createState() => _ArtistPageViewState();
}

class _ArtistPageViewState extends State<ArtistPageView> {
  final _scroll = ScrollController();
  double _offset = 0;
  bool _expanded = false;

  @override
  void initState() {
    super.initState();
    _scroll.addListener(() => setState(() => _offset = _scroll.offset));
  }

  @override
  void dispose() {
    _scroll.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final p = widget.page;
    return Stack(
      children: [
        ListView(
          controller: _scroll,
          padding: const EdgeInsets.only(bottom: 180),
          children: [
            // parallax header
            SizedBox(
              height: 320,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Transform.translate(
                    offset: Offset(0, _offset * 0.4),
                    child: Transform.scale(scale: 1.1, child: Image(image: artProvider(p.art), fit: BoxFit.cover)),
                  ),
                  const DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [Color(0x66000000), Colors.transparent, AppColors.bg],
                        stops: [0, 0.4, 1],
                      ),
                    ),
                  ),
                  Positioned(
                    left: 20,
                    right: 20,
                    bottom: 16,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(p.name, style: AppText.display(38).copyWith(letterSpacing: -0.8, color: Colors.white)),
                        const SizedBox(height: 2),
                        Text(p.monthly, style: AppText.subtitle.copyWith(fontSize: 13, color: Colors.white.withValues(alpha: 0.7))),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            // actions
            Padding(
              padding: const EdgeInsets.fromLTRB(Space.lg, 16, Space.lg, 0),
              child: Row(
                children: [
                  Expanded(child: PrimaryButton('Lire', icon: 'play', height: 48, onTap: () => widget.onPlay(p.top.first.track))),
                  const SizedBox(width: 10),
                  SizedBox(width: 48, child: SecondaryButton('', icon: 'shuffle', height: 48, onTap: () => widget.onPlay(p.discography[2]))),
                  const SizedBox(width: 10),
                  SizedBox(width: 48, child: SecondaryButton('', icon: 'plus', height: 48, onTap: () {})),
                ],
              ),
            ),
            // bio
            Padding(
              padding: const EdgeInsets.fromLTRB(Space.lg, 20, Space.lg, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(p.bio,
                      maxLines: _expanded ? null : 3,
                      overflow: _expanded ? TextOverflow.visible : TextOverflow.ellipsis,
                      style: AppText.subtitle.copyWith(fontSize: 15, height: 1.5)),
                  const SizedBox(height: 4),
                  Pressable(
                    onTap: () => setState(() => _expanded = !_expanded),
                    child: Text(_expanded ? 'Réduire' : 'Lire la suite',
                        style: AppText.trackTitle.copyWith(fontSize: 14, color: AppColors.accent)),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            SectionHeader('Titres populaires'),
            for (int i = 0; i < p.top.length; i++)
              Pressable(
                onTap: () => widget.onPlay(p.top[i].track),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: Space.md, vertical: 8),
                  child: Row(
                    children: [
                      SizedBox(width: 18, child: Text('${i + 1}', textAlign: TextAlign.center, style: AppText.timestamp.copyWith(color: AppColors.label3))),
                      const SizedBox(width: 12),
                      Artwork(p.top[i].track.art, size: 44, radius: R.xs),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(p.top[i].track.title, maxLines: 1, overflow: TextOverflow.ellipsis, style: AppText.trackTitle.copyWith(fontSize: 15)),
                            Text('${p.top[i].plays} écoutes', style: AppText.metaSmall),
                          ],
                        ),
                      ),
                      const AppIcon('ellipsis', size: 18, color: AppColors.label2),
                    ],
                  ),
                ),
              ),
            const SizedBox(height: 24),
            SectionHeader('Discographie'),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: Space.md),
              child: GridView.count(
                crossAxisCount: 3,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                childAspectRatio: 0.82,
                children: [
                  for (final t in p.discography)
                    Pressable(
                      onTap: () => widget.onPlay(t),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          LayoutBuilder(builder: (context, c) => Artwork(t.art, size: c.maxWidth, radius: R.sm)),
                          const SizedBox(height: 6),
                          Text(t.album, maxLines: 1, overflow: TextOverflow.ellipsis, style: AppText.metaSmall.copyWith(fontSize: 12.5, fontWeight: FontWeight.w600, color: AppColors.label)),
                        ],
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            SectionHeader('Artistes similaires'),
            SizedBox(
              height: 116,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: Space.md),
                children: [
                  for (final a in p.similar)
                    Padding(
                      padding: const EdgeInsets.only(right: 18),
                      child: SizedBox(
                        width: 80,
                        child: Column(
                          children: [
                            ClipOval(child: Image(image: artProvider(a.art), width: 80, height: 80, fit: BoxFit.cover)),
                            const SizedBox(height: 8),
                            Text(a.name, maxLines: 1, overflow: TextOverflow.ellipsis, style: AppText.subtitle.copyWith(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.label)),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
        // back button over the header
        Positioned(
          top: MediaQuery.of(context).padding.top + 8,
          left: 12,
          child: GlassIconButton('chevronLeft', glyph: 22, onTap: widget.onBack),
        ),
      ],
    );
  }
}
