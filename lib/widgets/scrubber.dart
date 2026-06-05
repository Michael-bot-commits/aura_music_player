// widgets/scrubber.dart
//
// Audio scrubber — 4-pt track, 11-pt thumb that grows to 15 while
// dragging. Reports a 0..1 value. Used for progress and volume.

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/tokens.dart';

class Scrubber extends StatefulWidget {
  final double value; // 0..1
  final ValueChanged<double> onChanged;
  final Color accent;
  final Color track;
  const Scrubber({
    super.key,
    required this.value,
    required this.onChanged,
    this.accent = AppColors.accent,
    this.track = const Color(0x33FFFFFF),
  });

  @override
  State<Scrubber> createState() => _ScrubberState();
}

class _ScrubberState extends State<Scrubber> {
  bool _drag = false;

  void _set(double dx, double w) => widget.onChanged((dx / w).clamp(0.0, 1.0));

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, c) {
      final w = c.maxWidth;
      return GestureDetector(
        behavior: HitTestBehavior.opaque,
        onHorizontalDragStart: (d) {
          setState(() => _drag = true);
          HapticFeedback.lightImpact();
          _set(d.localPosition.dx, w);
        },
        onHorizontalDragUpdate: (d) => _set(d.localPosition.dx, w),
        onHorizontalDragEnd: (_) => setState(() => _drag = false),
        onTapDown: (d) => _set(d.localPosition.dx, w),
        child: SizedBox(
          height: 24,
          child: Center(
            child: Stack(
              clipBehavior: Clip.none,
              alignment: Alignment.centerLeft,
              children: [
                Container(
                  height: 4,
                  decoration: BoxDecoration(color: widget.track, borderRadius: BorderRadius.circular(2)),
                ),
                FractionallySizedBox(
                  widthFactor: widget.value.clamp(0.0, 1.0),
                  child: Container(
                    height: 4,
                    decoration: BoxDecoration(color: widget.accent, borderRadius: BorderRadius.circular(2)),
                  ),
                ),
                Positioned(
                  left: widget.value.clamp(0.0, 1.0) * w - (_drag ? 7.5 : 5.5),
                  child: AnimatedContainer(
                    duration: Motion.fast,
                    width: _drag ? 15 : 11,
                    height: _drag ? 15 : 11,
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [BoxShadow(color: Color(0x66000000), blurRadius: 4, offset: Offset(0, 1))],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    });
  }
}
