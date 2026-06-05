// widgets/progress_ring.dart
//
// Download progress ring — queued (grey + clock), downloading (accent arc
// + %), done (green check), error (coral exclamation). Drawn with a
// CustomPainter so the arc matches the prototype's SVG ring.

import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../data/models.dart';
import '../theme/tokens.dart';
import 'icons.dart';

class ProgressRing extends StatelessWidget {
  final DownloadState state;
  final double progress; // 0..1
  final double size;
  const ProgressRing({super.key, required this.state, this.progress = 0, this.size = 34});

  @override
  Widget build(BuildContext context) {
    switch (state) {
      case DownloadState.done:
        return AppIcon('checkCircle', size: size * 0.82, color: AppColors.success);
      case DownloadState.error:
        return AppIcon('errorCircle', size: size * 0.82, color: AppColors.accent);
      case DownloadState.queued:
        return Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: AppColors.separator, width: 3),
          ),
          alignment: Alignment.center,
          child: AppIcon('clock', size: size * 0.5, color: AppColors.label3, strokeWidth: 2.2),
        );
      case DownloadState.downloading:
        return SizedBox(
          width: size,
          height: size,
          child: Stack(
            alignment: Alignment.center,
            children: [
              CustomPaint(size: Size(size, size), painter: _RingPainter(progress)),
              Text('${(progress * 100).round()}',
                  style: AppText.metaSmall.copyWith(fontSize: 9.5, fontWeight: FontWeight.w600)),
            ],
          ),
        );
    }
  }
}

class _RingPainter extends CustomPainter {
  final double progress;
  _RingPainter(this.progress);

  @override
  void paint(Canvas canvas, Size size) {
    const sw = 3.0;
    final r = (size.width - sw) / 2;
    final c = size.center(Offset.zero);
    final track = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = sw
      ..color = AppColors.fill2;
    final arc = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = sw
      ..strokeCap = StrokeCap.round
      ..color = AppColors.accent;
    canvas.drawCircle(c, r, track);
    canvas.drawArc(Rect.fromCircle(center: c, radius: r), -math.pi / 2, 2 * math.pi * progress, false, arc);
  }

  @override
  bool shouldRepaint(_RingPainter old) => old.progress != progress;
}
