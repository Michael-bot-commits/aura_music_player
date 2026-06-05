// screens/browser_screen.dart
//
// In-app browser: custom nav bar, shortcut grid, recents, a faux watch
// page, and the media-detection interception bottom sheet.

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../data/models.dart';
import '../data/store.dart';
import '../theme/tokens.dart';
import '../widgets/artwork.dart';
import '../widgets/buttons.dart';
import '../widgets/common.dart';
import '../widgets/icons.dart';

class BrowserScreen extends StatefulWidget {
  final void Function(Track) onPlay;
  final void Function(String) onToast;
  const BrowserScreen({super.key, required this.onPlay, required this.onToast});

  @override
  State<BrowserScreen> createState() => _BrowserScreenState();
}

class _BrowserScreenState extends State<BrowserScreen> {
  String _url = 'aura://accueil';
  bool _loading = false;
  ({String source, Track track})? _page;

  void _openSource(BrowserShortcut s, DataStore store) {
    setState(() {
      _url = '${s.host}/watch';
      _loading = true;
      _page = null;
    });
    Future.delayed(const Duration(milliseconds: 850), () {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _page = (source: s.name, track: store.t('distorted'));
      });
      Future.delayed(const Duration(milliseconds: 750), () {
        if (mounted) _showIntercept(store.t('distorted'), s.name);
      });
    });
  }

  void _showIntercept(Track track, String source) {
    fireHaptic(HapticKind.medium);
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.bg2,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(22))),
      builder: (_) => InterceptSheet(
        source: source,
        track: track,
        onPlay: () {
          Navigator.pop(context);
          widget.onPlay(track);
        },
        onDownload: (fmt) {
          Navigator.pop(context);
          widget.onToast('Téléchargement $fmt lancé');
        },
        onShare: () {
          Navigator.pop(context);
          widget.onToast('Lien copié');
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final store = context.read<DataStore>();
    return Column(
      children: [
        _navBar(),
        if (_loading)
          Container(
            height: 2,
            margin: const EdgeInsets.symmetric(horizontal: 16),
            child: const LinearProgressIndicator(backgroundColor: AppColors.fill2, color: AppColors.accent),
          ),
        Expanded(
          child: _page == null ? _home(store) : _watchPage(_page!),
        ),
      ],
    );
  }

  Widget _navBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 4, 12, 10),
      child: Row(
        children: [
          _navBtn('arrowLeft', onTap: () => setState(() { _page = null; _url = 'aura://accueil'; })),
          _navBtn('arrowRight', disabled: true),
          Expanded(
            child: Container(
              height: 38,
              margin: const EdgeInsets.symmetric(horizontal: 4),
              padding: const EdgeInsets.symmetric(horizontal: 14),
              decoration: BoxDecoration(color: AppColors.bg3, borderRadius: BorderRadius.circular(R.pill)),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const AppIcon('lock', size: 12, color: AppColors.label2, strokeWidth: 2.2),
                  const SizedBox(width: 6),
                  Flexible(child: Text(_url, maxLines: 1, overflow: TextOverflow.ellipsis, style: AppText.subtitle.copyWith(fontSize: 14, color: AppColors.label))),
                ],
              ),
            ),
          ),
          _navBtn('refresh'),
          _navBtn('homeFill', color: AppColors.accent, onTap: () => setState(() { _page = null; _url = 'aura://accueil'; })),
        ],
      ),
    );
  }

  Widget _navBtn(String icon, {bool disabled = false, Color? color, VoidCallback? onTap}) {
    return Pressable(
      onTap: disabled ? null : onTap,
      child: SizedBox(
        width: 34,
        height: 38,
        child: Center(child: AppIcon(icon, size: 20, color: disabled ? AppColors.label4 : (color ?? AppColors.label))),
      ),
    );
  }

  Widget _home(DataStore store) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 6, 16, 180),
      children: [
        Padding(padding: const EdgeInsets.only(bottom: 12), child: Text('RACCOURCIS', style: AppText.sectionHeader)),
        GridView.count(
          crossAxisCount: 4,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: 0.78,
          children: [for (final s in store.shortcuts) _shortcut(s, store)],
        ),
        const SizedBox(height: 28),
        Padding(padding: const EdgeInsets.only(bottom: 4), child: Text('RÉCEMMENT VISITÉS', style: AppText.sectionHeader)),
        for (final r in const ['youtube.com/watch · distorted', 'soundcloud.com/vela · Coral Coast', 'vimeo.com/nightswim'])
          Container(
            padding: const EdgeInsets.symmetric(vertical: 12),
            decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: AppColors.separator, width: 0.5))),
            child: Row(children: [
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(color: AppColors.fill3, borderRadius: BorderRadius.circular(R.xs)),
                alignment: Alignment.center,
                child: const AppIcon('globe', size: 17, color: AppColors.label2),
              ),
              const SizedBox(width: 12),
              Expanded(child: Text(r, maxLines: 1, overflow: TextOverflow.ellipsis, style: AppText.subtitle.copyWith(fontSize: 14))),
            ]),
          ),
      ],
    );
  }

  Widget _shortcut(BrowserShortcut s, DataStore store) {
    final hue = Color(0xFF000000 | s.hue);
    return Pressable(
      haptic: HapticKind.light,
      onTap: () => _openSource(s, store),
      child: Column(
        children: [
          AspectRatio(
            aspectRatio: 1,
            child: Container(
              decoration: BoxDecoration(color: AppColors.bg3, borderRadius: BorderRadius.circular(14)),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Container(decoration: BoxDecoration(color: hue.withValues(alpha: 0.16), borderRadius: BorderRadius.circular(14))),
                  Text(s.name[0], style: AppText.display(22).copyWith(color: hue)),
                ],
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(s.name, style: AppText.metaSmall.copyWith(fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  Widget _watchPage(({String source, Track track}) p) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 6, 16, 180),
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(14),
          child: AspectRatio(
            aspectRatio: 16 / 10,
            child: Stack(
              fit: StackFit.expand,
              children: [
                ColorFiltered(
                  colorFilter: const ColorFilter.mode(Color(0x33000000), BlendMode.darken),
                  child: Image(image: artProvider(p.track.art), fit: BoxFit.cover),
                ),
                const Center(child: AppIcon('playCircle', size: 56, color: Colors.white)),
                Positioned(left: 10, bottom: 10, child: Pill('vidéo détectée', color: Colors.white, background: const Color(0x80000000))),
              ],
            ),
          ),
        ),
        const SizedBox(height: 14),
        Text('${p.track.title} — ${p.track.artist}', style: AppText.trackTitle),
        const SizedBox(height: 4),
        Text('${p.source} · 4:32 · 48 M vues', style: AppText.subtitle.copyWith(fontSize: 13)),
        const SizedBox(height: 16),
        for (final w in const [1.0, 0.8, 0.9, 0.6])
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: FractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor: w,
              child: Container(height: 11, decoration: BoxDecoration(color: AppColors.fill3, borderRadius: BorderRadius.circular(6))),
            ),
          ),
      ],
    );
  }
}

class InterceptSheet extends StatelessWidget {
  final String source;
  final Track track;
  final VoidCallback onPlay;
  final void Function(String) onDownload;
  final VoidCallback onShare;
  const InterceptSheet({
    super.key,
    required this.source,
    required this.track,
    required this.onPlay,
    required this.onDownload,
    required this.onShare,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(18, 0, 18, 28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Center(child: SheetHandle()),
            Row(
              children: [
                Text('DÉTECTÉ · ${source.toUpperCase()}',
                    style: AppText.metaSmall.copyWith(fontSize: 12, fontWeight: FontWeight.w700, letterSpacing: 0.6, color: AppColors.accent)),
                const Spacer(),
                GlassIconButton('x', bare: true, glyph: 18, size: 32, color: AppColors.label2, onTap: () => Navigator.pop(context)),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Artwork(track.art, size: 56, radius: R.sm, shadow: true),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(track.title, style: AppText.display(18).copyWith(letterSpacing: -0.3)),
                    Text(track.artist, style: AppText.subtitle.copyWith(fontSize: 14)),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 18),
            PrimaryButton('Lire maintenant', icon: 'play', onTap: onPlay),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(child: SecondaryButton('Audio', icon: 'download', onTap: () => onDownload('audio'))),
                const SizedBox(width: 10),
                Expanded(child: SecondaryButton('Vidéo', icon: 'download', onTap: () => onDownload('vidéo'))),
              ],
            ),
            const SizedBox(height: 14),
            Center(
              child: Pressable(
                onTap: onShare,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const AppIcon('share', size: 16, color: AppColors.label2),
                    const SizedBox(width: 7),
                    Text('Partager le lien', style: AppText.subtitle.copyWith(fontSize: 14, fontWeight: FontWeight.w600)),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
