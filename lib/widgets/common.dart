// widgets/common.dart
//
// Shared building blocks: 64-pt TrackCell, SectionHeader, Pill badge,
// Segmented control, SearchField, sheet Handle, and Toast.

import 'package:flutter/material.dart';
import '../data/models.dart';
import '../theme/tokens.dart';
import 'artwork.dart';
import 'buttons.dart';
import 'icons.dart';

/// 64-pt list cell — artwork · title · artist · trailing (duration + menu).
class TrackCell extends StatelessWidget {
  final Track track;
  final bool playing;
  final bool separator;
  final double artSize;
  final VoidCallback? onTap;
  final VoidCallback? onMenu;
  final Widget? trailing;
  const TrackCell(this.track,
      {super.key,
      this.playing = false,
      this.separator = true,
      this.artSize = 52,
      this.onTap,
      this.onMenu,
      this.trailing});

  @override
  Widget build(BuildContext context) {
    return Pressable(
      onTap: onTap,
      child: Container(
        height: 64,
        padding: const EdgeInsets.symmetric(horizontal: Space.md),
        decoration: BoxDecoration(
          border: separator
              ? const Border(bottom: BorderSide(color: AppColors.separator, width: 0.5))
              : null,
        ),
        child: Row(
          children: [
            Artwork(track.art, size: artSize, radius: R.xs, videoBadge: track.kind == TrackKind.video),
            const SizedBox(width: Space.sm),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(track.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppText.trackTitle
                          .copyWith(fontSize: 16, color: playing ? AppColors.accent : AppColors.label)),
                  const SizedBox(height: 2),
                  Text(track.artist, maxLines: 1, overflow: TextOverflow.ellipsis, style: AppText.subtitle.copyWith(fontSize: 14)),
                ],
              ),
            ),
            if (trailing != null)
              trailing!
            else ...[
              Text(track.durationText, style: AppText.timestamp.copyWith(color: AppColors.label3)),
              Pressable(
                haptic: HapticKind.light,
                onTap: onMenu,
                child: const Padding(
                  padding: EdgeInsets.all(6),
                  child: AppIcon('ellipsis', size: 18, color: AppColors.label2),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class SectionHeader extends StatelessWidget {
  final String title;
  final String? action;
  final VoidCallback? onAction;
  const SectionHeader(this.title, {super.key, this.action, this.onAction});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(Space.md, 0, Space.md, 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(title.toUpperCase(), style: AppText.sectionHeader),
          const Spacer(),
          if (action != null)
            GestureDetector(
              onTap: onAction,
              child: Row(children: [
                Text(action!, style: AppText.trackTitle.copyWith(fontSize: 14, color: AppColors.accent)),
                const SizedBox(width: 2),
                const AppIcon('chevronRight', size: 13, color: AppColors.accent),
              ]),
            ),
        ],
      ),
    );
  }
}

class Pill extends StatelessWidget {
  final String label;
  final Color? color;
  final Color? background;
  const Pill(this.label, {super.key, this.color, this.background});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 22,
      padding: const EdgeInsets.symmetric(horizontal: 9),
      decoration: BoxDecoration(color: background ?? AppColors.fill3, borderRadius: BorderRadius.circular(R.pill)),
      alignment: Alignment.center,
      child: Text(label,
          style: AppText.metaSmall.copyWith(fontSize: 11.5, fontWeight: FontWeight.w600, color: color ?? AppColors.label2)),
    );
  }
}

/// iOS-style segmented control (sliding thumb).
class Segmented extends StatelessWidget {
  final List<String> items;
  final String value;
  final ValueChanged<String> onChanged;
  const Segmented({super.key, required this.items, required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final i = items.indexOf(value);
    return LayoutBuilder(builder: (context, c) {
      final innerW = c.maxWidth - 6;
      final segW = innerW / items.length;
      return Container(
        height: 36,
        padding: const EdgeInsets.all(3),
        decoration: BoxDecoration(color: AppColors.fill3, borderRadius: BorderRadius.circular(R.pill)),
        child: Stack(
          children: [
            AnimatedPositioned(
              duration: Motion.base,
              curve: Motion.ease,
              left: segW * i,
              top: 0,
              bottom: 0,
              width: segW,
              child: Container(
                decoration: BoxDecoration(
                  color: AppColors.fill1,
                  borderRadius: BorderRadius.circular(R.pill),
                  boxShadow: const [BoxShadow(color: Color(0x4D000000), blurRadius: 3, offset: Offset(0, 1))],
                ),
              ),
            ),
            Row(
              children: [
                for (final it in items)
                  Expanded(
                    child: GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: () {
                        fireHaptic(HapticKind.light);
                        onChanged(it);
                      },
                      child: Center(
                        child: Text(it,
                            style: AppText.subtitle.copyWith(
                                fontSize: 14,
                                fontWeight: it == value ? FontWeight.w600 : FontWeight.w500,
                                color: it == value ? AppColors.label : AppColors.label2)),
                      ),
                    ),
                  ),
              ],
            ),
          ],
        ),
      );
    });
  }
}

class SearchField extends StatelessWidget {
  final TextEditingController controller;
  final ValueChanged<String>? onChanged;
  final String placeholder;
  final bool mic;
  const SearchField({super.key, required this.controller, this.onChanged, this.placeholder = 'Rechercher', this.mic = true});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 40,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(color: AppColors.fill3, borderRadius: BorderRadius.circular(R.pill)),
      child: Row(
        children: [
          const AppIcon('search', size: 17, color: AppColors.label2, strokeWidth: 2.2),
          const SizedBox(width: 8),
          Expanded(
            child: TextField(
              controller: controller,
              onChanged: onChanged,
              style: AppText.trackTitle.copyWith(fontSize: 16, fontWeight: FontWeight.w400, color: AppColors.label),
              cursorColor: AppColors.accent,
              decoration: InputDecoration(
                isDense: true,
                border: InputBorder.none,
                hintText: placeholder,
                hintStyle: AppText.subtitle.copyWith(fontSize: 16),
              ),
            ),
          ),
          if (mic) const AppIcon('mic', size: 17, color: AppColors.label2, strokeWidth: 2.2),
        ],
      ),
    );
  }
}

class SheetHandle extends StatelessWidget {
  const SheetHandle({super.key});
  @override
  Widget build(BuildContext context) => Container(
        width: 36,
        height: 5,
        margin: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(color: AppColors.label3, borderRadius: BorderRadius.circular(3)),
      );
}

/// Brief in-app toast — pair with a ScaffoldMessenger or an OverlayEntry.
class Toast extends StatelessWidget {
  final String message;
  final String? icon;
  final Color iconColor;
  const Toast(this.message, {super.key, this.icon, this.iconColor = AppColors.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
      decoration: BoxDecoration(
        color: Glass.fill,
        borderRadius: BorderRadius.circular(R.pill),
        border: Border.all(color: AppColors.separatorOp),
        boxShadow: const [BoxShadow(color: Color(0x80000000), blurRadius: 30, offset: Offset(0, 8))],
      ),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        if (icon != null) ...[AppIcon(icon!, size: 18, color: iconColor), const SizedBox(width: 10)],
        Text(message, style: AppText.subtitle.copyWith(fontSize: 14, fontWeight: FontWeight.w500, color: AppColors.label)),
      ]),
    );
  }
}
