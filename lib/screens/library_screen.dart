// screens/library_screen.dart
//
// Bibliothèque — large title + header tools, segmented control
// (Tout · Musique · Vidéos · Playlists), compact 64-pt list, playlists
// mosaic + "Créer une playlist". Téléchargements pushes from the
// downloads header tool.

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../data/models.dart';
import '../data/player_model.dart';
import '../data/store.dart';
import '../theme/tokens.dart';
import '../widgets/artwork.dart';
import '../widgets/buttons.dart';
import '../widgets/common.dart';
import '../widgets/icons.dart';
import 'downloads_screen.dart';

class LibraryScreen extends StatefulWidget {
  final void Function(Track) onPlay;
  final void Function(Track) onMenu;
  const LibraryScreen({super.key, required this.onPlay, required this.onMenu});

  @override
  State<LibraryScreen> createState() => _LibraryScreenState();
}

class _LibraryScreenState extends State<LibraryScreen> {
  String _seg = 'Tout';

  @override
  Widget build(BuildContext context) {
    final store = context.read<DataStore>();
    final player = context.watch<PlayerModel>();

    List<Track> items = store.library;
    if (_seg == 'Musique') items = items.where((t) => t.kind == TrackKind.audio).toList();
    if (_seg == 'Vidéos') items = items.where((t) => t.kind == TrackKind.video).toList();

    return ListView(
      padding: const EdgeInsets.only(bottom: 180),
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(Space.lg, 6, Space.lg, 14),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text('Bibliothèque', style: AppText.display(32).copyWith(letterSpacing: -0.6)),
              const Spacer(),
              HeaderTool('download', badge: store.downloadsBadge, onTap: () {
                Navigator.of(context).push(MaterialPageRoute(builder: (_) => const DownloadsScreen()));
              }),
              const SizedBox(width: 6),
              HeaderTool('sort', onTap: () {}),
              const SizedBox(width: 6),
              HeaderTool('filter', onTap: () {}),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(Space.md, 0, Space.md, 14),
          child: Segmented(
            items: const ['Tout', 'Musique', 'Vidéos', 'Playlists'],
            value: _seg,
            onChanged: (v) => setState(() => _seg = v),
          ),
        ),
        if (_seg != 'Playlists')
          for (int i = 0; i < items.length; i++)
            TrackCell(items[i],
                playing: items[i].id == player.current.id,
                separator: i < items.length - 1,
                onTap: () => widget.onPlay(items[i]),
                onMenu: () => widget.onMenu(items[i]))
        else
          ..._playlists(store),
      ],
    );
  }

  List<Widget> _playlists(DataStore store) {
    return [
      Pressable(
        onTap: () {},
        child: Container(
          height: 64,
          padding: const EdgeInsets.symmetric(horizontal: Space.md),
          decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: AppColors.separator, width: 0.5))),
          child: Row(
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(R.sm),
                  border: Border.all(color: AppColors.accent, width: 1.5),
                ),
                alignment: Alignment.center,
                child: const AppIcon('plus', size: 22, color: AppColors.accent),
              ),
              const SizedBox(width: 14),
              Text('Créer une playlist', style: AppText.trackTitle.copyWith(fontSize: 16, color: AppColors.accent)),
            ],
          ),
        ),
      ),
      for (int i = 0; i < store.playlists.length; i++)
        Pressable(
          onTap: () {},
          child: Container(
            height: 72,
            padding: const EdgeInsets.symmetric(horizontal: Space.md),
            decoration: BoxDecoration(
              border: i < store.playlists.length - 1
                  ? const Border(bottom: BorderSide(color: AppColors.separator, width: 0.5))
                  : null,
            ),
            child: Row(
              children: [
                Mosaic(store.playlists[i].arts, size: 52),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(store.playlists[i].name, style: AppText.trackTitle.copyWith(fontSize: 16)),
                      const SizedBox(height: 2),
                      Text('${store.playlists[i].count} titres · ${store.playlists[i].durationText}',
                          style: AppText.subtitle.copyWith(fontSize: 13)),
                    ],
                  ),
                ),
                const AppIcon('chevronRight', size: 16, color: AppColors.label3),
              ],
            ),
          ),
        ),
    ];
  }
}

/// 38-pt filled circle header tool with optional badge.
class HeaderTool extends StatelessWidget {
  final String icon;
  final int badge;
  final VoidCallback? onTap;
  const HeaderTool(this.icon, {super.key, this.badge = 0, this.onTap});

  @override
  Widget build(BuildContext context) {
    return Pressable(
      onTap: onTap,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: const BoxDecoration(color: AppColors.bg3, shape: BoxShape.circle),
            alignment: Alignment.center,
            child: AppIcon(icon, size: 19, color: AppColors.label),
          ),
          if (badge > 0)
            Positioned(
              top: 0,
              right: 0,
              child: Container(
                constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
                padding: const EdgeInsets.symmetric(horizontal: 4),
                decoration: BoxDecoration(color: AppColors.accent, borderRadius: BorderRadius.circular(8), border: Border.all(color: AppColors.bg, width: 2)),
                alignment: Alignment.center,
                child: Text('$badge',
                    style: AppText.metaSmall.copyWith(fontSize: 10, fontWeight: FontWeight.w700, color: Colors.white)),
              ),
            ),
        ],
      ),
    );
  }
}
