// screens/chrome.dart
//
// The fused MiniPlayer + TabBar — a single floating frosted block tinted
// live by the artwork's dominant colour. Mini-player above (with the 2-pt
// progress line hugging its bottom), 4-tab bar below. Swipe ←/→ skips;
// tap opens the full player.

import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/dynamic_color.dart';
import '../data/player_model.dart';
import '../theme/tokens.dart';
import '../widgets/artwork.dart';
import '../widgets/buttons.dart';
import '../widgets/icons.dart';

class AppTabDef {
  final String id, label, icon, fill;
  const AppTabDef(this.id, this.label, this.icon, this.fill);
}

const kTabs = [
  AppTabDef('browser', 'Browser', 'globe', 'globeFill'),
  AppTabDef('library', 'Bibliothèque', 'library', 'libraryFill'),
  AppTabDef('discovery', 'Découverte', 'compass', 'compassFill'),
  AppTabDef('player', 'Player', 'disc', 'discFill'),
];

class FusedChrome extends StatelessWidget {
  final String tab;
  final ValueChanged<String> onTab;
  final VoidCallback onOpenPlayer;
  final int downloadsBadge;
  const FusedChrome({
    super.key,
    required this.tab,
    required this.onTab,
    required this.onOpenPlayer,
    required this.downloadsBadge,
  });

  @override
  Widget build(BuildContext context) {
    final player = context.watch<PlayerModel>();
    final dyn = context.watch<DynamicColor>();
    final track = player.current;

    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 0, 8, 12),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(22),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 24, sigmaY: 24),
          child: Container(
            decoration: BoxDecoration(
              color: Glass.fill,
              borderRadius: BorderRadius.circular(22),
              border: Border.all(color: AppColors.separatorOp, width: 0.5),
              boxShadow: const [BoxShadow(color: Color(0x80000000), blurRadius: 40, offset: Offset(0, 10))],
            ),
            child: Stack(
              children: [
                // dynamic tint overlays (crossfade on track change)
                Positioned.fill(
                  child: AnimatedContainer(
                    duration: Motion.dynamicColor,
                    curve: Motion.ease,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [dyn.ambient.withValues(alpha: 0.45), Colors.transparent],
                      ),
                    ),
                  ),
                ),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _miniPlayer(player, track),
                    Divider(height: 0.5, thickness: 0.5, color: AppColors.separatorOp),
                    _tabBar(),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _miniPlayer(PlayerModel player, track) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onOpenPlayer,
      onHorizontalDragEnd: (d) {
        final v = d.primaryVelocity ?? 0;
        if (v < -200) {
          fireHaptic(HapticKind.medium);
          player.next();
        } else if (v > 200) {
          fireHaptic(HapticKind.medium);
          player.previous();
        }
      },
      child: SizedBox(
        height: 64,
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Row(
                children: [
                  Artwork(track.art, size: 44, radius: R.xs),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(track.title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: AppText.trackTitle.copyWith(fontSize: 15)),
                        Text(track.artist,
                            maxLines: 1, overflow: TextOverflow.ellipsis, style: AppText.subtitle.copyWith(fontSize: 13)),
                      ],
                    ),
                  ),
                  Pressable(
                    haptic: HapticKind.medium,
                    onTap: player.togglePlay,
                    child: Padding(
                      padding: const EdgeInsets.all(6),
                      child: AppIcon(player.isPlaying ? 'pause' : 'play', size: 22, color: AppColors.label),
                    ),
                  ),
                  Pressable(
                    haptic: HapticKind.medium,
                    onTap: player.next,
                    child: const Padding(
                      padding: EdgeInsets.all(6),
                      child: AppIcon('forward', size: 22, color: AppColors.label),
                    ),
                  ),
                ],
              ),
            ),
            // 2-pt progress hugging the bottom
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: Container(
                height: 2,
                color: const Color(0x1FFFFFFF),
                child: FractionallySizedBox(
                  alignment: Alignment.centerLeft,
                  widthFactor: player.progress.clamp(0.0, 1.0),
                  child: Container(color: AppColors.accent),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _tabBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 8, 4, 9),
      child: Row(
        children: [
          for (final t in kTabs)
            Expanded(
              child: Pressable(
                haptic: HapticKind.light,
                onTap: () => onTab(t.id),
                child: Builder(builder: (_) {
                  final active = tab == t.id;
                  final color = active ? AppColors.accent : AppColors.label2;
                  return Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Stack(
                        clipBehavior: Clip.none,
                        children: [
                          AppIcon(active ? t.fill : t.icon, size: 24, color: color, strokeWidth: 1.9),
                          if (t.id == 'library' && downloadsBadge > 0)
                            Positioned(
                              right: -6,
                              top: -2,
                              child: Container(
                                width: 8,
                                height: 8,
                                decoration: BoxDecoration(
                                  color: AppColors.accent,
                                  shape: BoxShape.circle,
                                  border: Border.all(color: const Color(0xE6141416), width: 2),
                                ),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(t.label,
                          style: AppText.metaSmall.copyWith(
                              fontSize: 10, fontWeight: active ? FontWeight.w600 : FontWeight.w500, color: color)),
                    ],
                  );
                }),
              ),
            ),
        ],
      ),
    );
  }
}
