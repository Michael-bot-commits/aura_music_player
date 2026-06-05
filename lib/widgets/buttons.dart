// widgets/buttons.dart
//
// Pressable buttons with the system-wide scale(0.96) press feedback and
// haptics. Primary (accent pill), secondary (glass/outlined pill), and the
// 44-pt glass circular icon button.

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:ui';
import '../theme/tokens.dart';
import 'icons.dart';

/// Wraps any child with scale-on-press + a tap callback.
class Pressable extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;
  final HapticKind haptic;
  const Pressable({super.key, required this.child, this.onTap, this.haptic = HapticKind.light});

  @override
  State<Pressable> createState() => _PressableState();
}

enum HapticKind { none, light, medium, success, error }

void fireHaptic(HapticKind k) {
  switch (k) {
    case HapticKind.light:
      HapticFeedback.lightImpact();
    case HapticKind.medium:
      HapticFeedback.mediumImpact();
    case HapticKind.success:
      HapticFeedback.mediumImpact();
    case HapticKind.error:
      HapticFeedback.heavyImpact();
    case HapticKind.none:
      break;
  }
}

class _PressableState extends State<Pressable> {
  bool _down = false;
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _down = true),
      onTapCancel: () => setState(() => _down = false),
      onTapUp: (_) => setState(() => _down = false),
      onTap: widget.onTap == null
          ? null
          : () {
              fireHaptic(widget.haptic);
              widget.onTap!();
            },
      child: AnimatedScale(
        scale: _down ? 0.96 : 1,
        duration: Motion.fast,
        curve: Motion.easeOut,
        child: widget.child,
      ),
    );
  }
}

class PrimaryButton extends StatelessWidget {
  final String label;
  final String? icon;
  final VoidCallback? onTap;
  final double height;
  const PrimaryButton(this.label, {super.key, this.icon, this.onTap, this.height = 52});

  @override
  Widget build(BuildContext context) {
    final disabled = onTap == null;
    return Pressable(
      haptic: HapticKind.medium,
      onTap: onTap,
      child: Container(
        height: height,
        decoration: BoxDecoration(
          color: disabled ? AppColors.bg3 : AppColors.accent,
          borderRadius: BorderRadius.circular(R.pill),
        ),
        alignment: Alignment.center,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              AppIcon(icon!, size: 19, color: disabled ? AppColors.label3 : AppColors.accentInk),
              const SizedBox(width: 8),
            ],
            Text(label, style: AppText.trackTitle.copyWith(color: disabled ? AppColors.label3 : AppColors.accentInk)),
          ],
        ),
      ),
    );
  }
}

class SecondaryButton extends StatelessWidget {
  final String label;
  final String? icon;
  final VoidCallback? onTap;
  final double height;
  const SecondaryButton(this.label, {super.key, this.icon, this.onTap, this.height = 52});

  @override
  Widget build(BuildContext context) {
    return Pressable(
      onTap: onTap,
      child: Container(
        height: height,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        decoration: BoxDecoration(
          color: AppColors.fill3,
          borderRadius: BorderRadius.circular(R.pill),
          border: Border.all(color: AppColors.separator),
        ),
        alignment: Alignment.center,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              AppIcon(icon!, size: 18, color: AppColors.label),
              if (label.isNotEmpty) const SizedBox(width: 7),
            ],
            if (label.isNotEmpty)
              Text(label, style: AppText.trackTitle.copyWith(fontSize: 16, color: AppColors.label)),
          ],
        ),
      ),
    );
  }
}

/// 44-pt glass circular icon button (frosted unless [bare]).
class GlassIconButton extends StatelessWidget {
  final String icon;
  final double size;
  final double glyph;
  final VoidCallback? onTap;
  final bool active;
  final bool bare;
  final Color? color;
  const GlassIconButton(this.icon,
      {super.key, this.size = 44, this.glyph = 20, this.onTap, this.active = false, this.bare = false, this.color});

  @override
  Widget build(BuildContext context) {
    final fg = active ? AppColors.accent : (color ?? AppColors.label);
    final inner = Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      color: bare ? Colors.transparent : const Color(0x3D787880),
      child: AppIcon(icon, size: glyph, color: fg),
    );
    return Pressable(
      onTap: onTap,
      child: ClipOval(
        child: bare
            ? inner
            : BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
                child: inner,
              ),
      ),
    );
  }
}
