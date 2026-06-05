// screens/downloads_screen.dart
//
// Téléchargements — grouped EN COURS / TERMINÉS with circular progress
// rings. Non-technical error copy. Pushed from the Bibliothèque header.

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../data/models.dart';
import '../data/store.dart';
import '../theme/tokens.dart';
import '../widgets/artwork.dart';
import '../widgets/buttons.dart';
import '../widgets/common.dart';
import '../widgets/progress_ring.dart';

class DownloadsScreen extends StatelessWidget {
  const DownloadsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final store = context.read<DataStore>();
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: ListView(
        padding: const EdgeInsets.only(bottom: 180),
        children: [
          SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(12, 4, 12, 10),
              child: Row(
                children: [
                  GlassIconButton('chevronLeft', bare: true, glyph: 22, size: 38, onTap: () => Navigator.of(context).pop()),
                  Text('Téléchargements', style: AppText.trackTitle.copyWith(fontSize: 17)),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(Space.lg, 0, Space.lg, 16),
            child: Text('En cours & terminés', style: AppText.display(30).copyWith(letterSpacing: -0.6)),
          ),
          SectionHeader('En cours · ${store.downloadsActive.length}'),
          for (int i = 0; i < store.downloadsActive.length; i++)
            _DownloadRow(store.downloadsActive[i], last: i == store.downloadsActive.length - 1),
          const SizedBox(height: 28),
          SectionHeader('Terminés · ${store.downloadsDone.length}'),
          for (int i = 0; i < store.downloadsDone.length; i++)
            _DownloadRow(store.downloadsDone[i], last: i == store.downloadsDone.length - 1),
        ],
      ),
    );
  }
}

class _DownloadRow extends StatelessWidget {
  final DownloadItem item;
  final bool last;
  const _DownloadRow(this.item, {this.last = false});

  @override
  Widget build(BuildContext context) {
    final isError = item.state == DownloadState.error;
    return Pressable(
      onTap: isError ? () {} : null,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: Space.md, vertical: 12),
        decoration: BoxDecoration(
          border: last ? null : const Border(bottom: BorderSide(color: AppColors.separator, width: 0.5)),
        ),
        child: Row(
          children: [
            Artwork(item.track.art, size: 40, radius: R.xs),
            const SizedBox(width: Space.sm),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(item.track.title, maxLines: 1, overflow: TextOverflow.ellipsis, style: AppText.trackTitle.copyWith(fontSize: 15)),
                  const SizedBox(height: 2),
                  Text(item.detail,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppText.metaSmall.copyWith(color: isError ? AppColors.accent : AppColors.label2)),
                ],
              ),
            ),
            const SizedBox(width: 8),
            ProgressRing(state: item.state, progress: item.progress),
          ],
        ),
      ),
    );
  }
}
