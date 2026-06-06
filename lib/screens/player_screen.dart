// screens/player_screen.dart
//
// Full-screen immersive player. Background = blurred artwork (crossfades
// on track change) + dark veil + dynamic ambient wash. Crisp artwork
// scales on play/pause. Lyrics / queue swap into the centre region.
// Presented as a draggable full-height sheet from main.dart.

import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/dynamic_color.dart';
import '../data/models.dart';
import '../data/player_model.dart';
import '../theme/tokens.dart';
import '../widgets/artwork.dart';
import '../widgets/buttons.dart';
import '../widgets/icons.dart';
import '../widgets/scrubber.dart';
import 'player_subviews.dart';

enum CentreView { cover, lyrics, queue }

class PlayerScreen extends StatefulWidget {
  final VoidCallback onClose;
  const PlayerScreen({super.key, required this.onClose});

  @override
  State<PlayerScreen> createState() => _PlayerScreenState();
}

class _PlayerScreenState extends State<PlayerScreen> {
  CentreView _view = CentreView.cover;

  @override
  Widget build(BuildContext context) {
    final player = context.watch<PlayerModel>();
    final dyn = context.watch<DynamicColor>();
    final track = player.current;
    final elapsed = track.duration * player.progress;

    return Material(
      color: Colors.black,
      child: Stack(
        children: [
          // crossfading blurred backdrop
          Positioned.fill(
            child: AnimatedSwitcher(
              duration: Motion.dynamicColor,
              child: SizedBox.expand(
                key: ValueKey(track.art),
                child: Image(
                  image: artProvider(track.art),
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
          Positioned.fill(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 34, sigmaY: 34),
              child: const SizedBox.expand(),
            ),
          ),
          // dynamic ambient wash + dark veil
          Positioned.fill(
            child: AnimatedContainer(duration: Motion.dynamicColor, color: dyn.ambient.withValues(alpha:0.5)),
          ),
          const Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Color(0x73000000), Color(0x33000000), Color(0x8C000000), Color(0xDB000000)],
                  stops: [0, 0.32, 0.72, 1],
                ),
              ),
            ),
          ),

          // content column
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 22),
              child: Column(
                children: [
                  _header(track, dyn),
                  Expanded(child: _centre(player, track)),
                  _titleRow(player, track),
                  const SizedBox(height: 6),
                  Scrubber(value: player.progress, onChanged: player.seek),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(Track.mmss(elapsed), style: AppText.timestamp.copyWith(color: Colors.white54)),
                      Text('-${Track.mmss(track.duration - elapsed)}',
                          style: AppText.timestamp.copyWith(color: Colors.white54)),
                    ],
                  ),
                  const SizedBox(height: 14),
                  _transport(player),
                  const SizedBox(height: 18),
                  _volume(player),
                  _footerTabs(),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _header(Track track, DynamicColor dyn) {
    return Padding(
      padding: const EdgeInsets.only(top: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          GlassIconButton('chevronDown', onTap: widget.onClose),
          Column(
            children: [
              Text(context.read<PlayerModel>().contextLabel,
                  style: AppText.metaSmall
                      .copyWith(fontSize: 11, fontWeight: FontWeight.w700, letterSpacing: 1, color: Colors.white.withValues(alpha:0.82))),
              Text('en lecture', style: AppText.metaSmall.copyWith(fontSize: 10.5, color: Colors.white.withValues(alpha:0.5))),
            ],
          ),
          GlassIconButton('ellipsis', onTap: () {}),
        ],
      ),
    );
  }

  Widget _centre(PlayerModel player, Track track) {
    switch (_view) {
      case CentreView.cover:
        return Center(
          child: AnimatedScale(
            scale: player.isPlaying ? 1.0 : 0.82,
            duration: const Duration(milliseconds: 420),
            curve: Motion.spring,
            child: LayoutBuilder(builder: (context, c) {
              final s = c.maxWidth.clamp(0.0, 320.0);
              return Artwork(track.art, size: s, radius: R.art, shadow: true);
            }),
          ),
        );
      case CentreView.lyrics:
        return LyricsView(progress: player.progress);
      case CentreView.queue:
        return QueueView(player: player, onJump: player.jumpTo);
    }
  }

  Widget _titleRow(PlayerModel player, track) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(track.title,
                  maxLines: 1, overflow: TextOverflow.ellipsis, style: AppText.display(27).copyWith(color: Colors.white)),
              const SizedBox(height: 2),
              Text(track.artist,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppText.trackTitle.copyWith(fontSize: 17, fontWeight: FontWeight.w400, color: Colors.white.withValues(alpha:0.62))),
            ],
          ),
        ),
        const SizedBox(width: 12),
        GlassIconButton(player.isLiked ? 'heartFill' : 'heart',
            bare: true, glyph: 26, color: player.isLiked ? AppColors.accent : Colors.white, onTap: player.toggleLike),
      ],
    );
  }

  Widget _transport(PlayerModel player) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        GlassIconButton('shuffle', bare: true, active: player.shuffle, onTap: player.toggleShuffle),
        GlassIconButton('backward', bare: true, glyph: 30, onTap: player.previous),
        Pressable(
          haptic: HapticKind.medium,
          onTap: player.togglePlay,
          child: Container(
            width: 70,
            height: 70,
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [BoxShadow(color: Color(0x66000000), blurRadius: 24, offset: Offset(0, 6))],
            ),
            alignment: Alignment.center,
            child: AppIcon(player.isPlaying ? 'pause' : 'play', size: 32, color: const Color(0xFF0A0A0B)),
          ),
        ),
        GlassIconButton('forward', bare: true, glyph: 30, onTap: player.next),
        GlassIconButton('repeat', bare: true, active: player.repeatOn, onTap: player.toggleRepeat),
      ],
    );
  }

  Widget _volume(PlayerModel player) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          AppIcon('speakerLow', size: 16, color: Colors.white.withValues(alpha:0.55)),
          const SizedBox(width: 12),
          Expanded(child: Scrubber(value: player.volume, onChanged: player.setVolume, track: const Color(0x2EFFFFFF))),
          const SizedBox(width: 12),
          AppIcon('speakerHigh', size: 18, color: Colors.white.withValues(alpha:0.55)),
        ],
      ),
    );
  }

  Widget _footerTabs() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _tab('Paroles', 'quote', CentreView.lyrics),
        GlassIconButton('airplay', bare: true, color: Colors.white.withValues(alpha:0.7), onTap: () {}),
        _tab("File d'attente", 'queue', CentreView.queue, right: true),
      ],
    );
  }

  Widget _tab(String label, String icon, CentreView target, {bool right = false}) {
    final active = _view == target;
    final color = active ? AppColors.accent : Colors.white.withValues(alpha:0.7);
    final children = [
      AppIcon(icon, size: 18, color: color),
      const SizedBox(width: 6),
      Text(label, style: AppText.subtitle.copyWith(fontSize: 13, fontWeight: FontWeight.w600, color: color)),
    ];
    return Pressable(
      haptic: HapticKind.light,
      onTap: () => setState(() => _view = active ? CentreView.cover : target),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Row(mainAxisSize: MainAxisSize.min, children: right ? children.reversed.toList() : children),
      ),
    );
  }
}
