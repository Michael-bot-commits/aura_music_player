// screens/player_subviews.dart
//
// Lyrics + queue panels that swap into the player's centre region.

import 'package:flutter/material.dart';
import '../data/player_model.dart';
import '../theme/tokens.dart';
import '../widgets/artwork.dart';
import '../widgets/icons.dart';

const kLyrics = [
  '(instrumental)', 'snow falls on the empty line', 'a signal lost in the white',
  'i hear you breaking up, distorted', 'static where your voice should be',
  'hold on — the carrier fades', 'every word a little softer now',
  'we drift between the frequencies', 'and the night keeps tuning out',
  'distorted, distorted', 'i keep you in the noise', 'where nothing else can reach',
  '(instrumental)', 'fading', 'fading', '—',
];

class LyricsView extends StatelessWidget {
  final double progress;
  const LyricsView({super.key, required this.progress});

  @override
  Widget build(BuildContext context) {
    final current = (progress * kLyrics.length).floor().clamp(0, kLyrics.length - 1);
    return ShaderMask(
      shaderCallback: (rect) => const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [Colors.transparent, Colors.black, Colors.black, Colors.transparent],
        stops: [0, 0.14, 0.86, 1],
      ).createShader(rect),
      blendMode: BlendMode.dstIn,
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(vertical: 20),
        itemCount: kLyrics.length,
        itemBuilder: (context, i) {
          final isCurrent = i == current;
          final color = isCurrent
              ? Colors.white
              : i < current
                  ? Colors.white.withValues(alpha:0.4)
                  : Colors.white.withValues(alpha:0.32);
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 9),
            child: Text(
              kLyrics[i],
              style: AppText.display(22).copyWith(color: color, letterSpacing: -0.4),
            ),
          );
        },
      ),
    );
  }
}

class QueueView extends StatelessWidget {
  final PlayerModel player;
  final ValueChanged<int> onJump;
  const QueueView({super.key, required this.player, required this.onJump});

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: Text('À SUIVRE', style: AppText.sectionHeader),
        ),
        for (int i = 0; i < player.queue.length; i++)
          if (i > player.index)
            GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () => onJump(i),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Row(
                  children: [
                    Artwork(player.queue[i].art, size: 42, radius: 7),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(player.queue[i].title,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: AppText.trackTitle.copyWith(fontSize: 15)),
                          Text(player.queue[i].artist,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: AppText.subtitle.copyWith(fontSize: 13, color: Colors.white.withValues(alpha:0.55))),
                        ],
                      ),
                    ),
                    AppIcon('queue', size: 18, color: Colors.white.withValues(alpha:0.4)),
                  ],
                ),
              ),
            ),
      ],
    );
  }
}
