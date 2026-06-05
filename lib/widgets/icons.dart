// widgets/icons.dart
//
// Custom icon set — the SAME SVG path data as the prototype's ui.jsx
// glyphs, rendered through path_drawing so the icons are pixel-identical
// across HTML, and Flutter. Outline glyphs are stroked; *filled glyphs
// are filled (active / selected states), exactly as the brief specifies.
//
// SF Symbols equivalents are noted so a developer can swap to SF Symbols
// on iOS or Material Icons if preferred.

import 'package:flutter/material.dart';
import 'package:path_drawing/path_drawing.dart';
import '../theme/tokens.dart';

class _Glyph {
  final String path;
  final bool filled;
  const _Glyph(this.path, {this.filled = false});
}

const Map<String, _Glyph> _glyphs = {
  // media controls (filled)  ·  play.fill / pause.fill / backward.fill / forward.fill
  'play': _Glyph('M7 4.5v15a1 1 0 0 0 1.5.86l12-7.5a1 1 0 0 0 0-1.72l-12-7.5A1 1 0 0 0 7 4.5Z', filled: true),
  'pause': _Glyph('M7 4h3.2v16H7zM13.8 4H17v16h-3.2z', filled: true),
  'backward': _Glyph('M11 5.6 3.6 11.2a1 1 0 0 0 0 1.6L11 18.4A1 1 0 0 0 12.6 17.6V13l7.4 5.4A1 1 0 0 0 21.6 17.6V6.4A1 1 0 0 0 20 5.6L12.6 11V6.4A1 1 0 0 0 11 5.6Z', filled: true),
  'forward': _Glyph('M13 5.6 20.4 11.2a1 1 0 0 1 0 1.6L13 18.4A1 1 0 0 1 11.4 17.6V13L4 18.4A1 1 0 0 1 2.4 17.6V6.4A1 1 0 0 1 4 5.6L11.4 11V6.4A1 1 0 0 1 13 5.6Z', filled: true),
  // outline
  'shuffle': _Glyph('M16 4h4v4M20 4l-6 6M4 20l6.5-6.5M16 20h4v-4M4 4l5 5'),
  'repeat': _Glyph('M17 2l3 3-3 3M20 5H8a4 4 0 0 0-4 4v1M7 22l-3-3 3-3M4 19h12a4 4 0 0 0 4-4v-1'),
  'heart': _Glyph('M12 20s-7-4.6-9.3-9C1.2 8 2.6 4.5 6 4.5c2 0 3.2 1.3 4 2.3.8-1 2-2.3 4-2.3 3.4 0 4.8 3.5 3.3 6.5C19 15.4 12 20 12 20Z'),
  'heartFill': _Glyph('M12 20.5s-7.2-4.7-9.5-9.2C.7 7.8 2.2 4 6 4c2.1 0 3.3 1.3 4 2.4C10.7 5.3 11.9 4 14 4c3.8 0 5.3 3.8 3.5 7.3C19.2 15.8 12 20.5 12 20.5Z', filled: true),
  'chevronDown': _Glyph('M5 9l7 7 7-7'),
  'chevronUp': _Glyph('M5 15l7-7 7 7'),
  'chevronRight': _Glyph('M9 5l7 7-7 7'),
  'chevronLeft': _Glyph('M15 5l-7 7 7 7'),
  'ellipsis': _Glyph('M5 10a2 2 0 1 0 0 4 2 2 0 0 0 0-4Zm7 0a2 2 0 1 0 0 4 2 2 0 0 0 0-4Zm7 0a2 2 0 1 0 0 4 2 2 0 0 0 0-4Z', filled: true),
  'queue': _Glyph('M4 7h11M4 12h11M4 17h7M18 9v9M18 18a2 2 0 1 0 4 0 2 2 0 0 0-4 0Z'),
  'airplay': _Glyph('M5 17H4a1 1 0 0 1-1-1V5a1 1 0 0 1 1-1h16a1 1 0 0 1 1 1v11a1 1 0 0 1-1 1h-1M12 15l5 6H7l5-6Z'),
  'speakerLow': _Glyph('M4 9v6h3l5 4V5L7 9H4ZM16 9a4 4 0 0 1 0 6'),
  'speakerHigh': _Glyph('M4 9v6h3l5 4V5L7 9H4ZM16 8a5.5 5.5 0 0 1 0 8M19 5.5a9 9 0 0 1 0 13'),
  'quote': _Glyph('M9 8H6a2 2 0 0 0-2 2v3h5V8ZM19 8h-3a2 2 0 0 0-2 2v3h5V8ZM4 13c0 3 1.2 4.5 3 5M14 13c0 3 1.2 4.5 3 5'),
  // tab bar  ·  globe / books.vertical / safari / play.circle
  'globe': _Glyph('M12 3a9 9 0 1 0 0 18 9 9 0 0 0 0-18ZM3 12h18M12 3c2.5 2.4 3.8 5.6 3.8 9S14.5 18.6 12 21M12 3C9.5 5.4 8.2 8.6 8.2 12S9.5 18.6 12 21'),
  'globeFill': _Glyph('M12 2.5A9.5 9.5 0 1 0 12 21.5 9.5 9.5 0 0 0 12 2.5Zm0 2c1.9 1.8 3 4.6 3 7.5s-1.1 5.7-3 7.5c-1.9-1.8-3-4.6-3-7.5s1.1-5.7 3-7.5Z', filled: true),
  'library': _Glyph('M5 4h3v16H5zM10.5 4h3v16h-3zM16.2 5l3 .8-3.4 14-3-.8z'),
  'libraryFill': _Glyph('M4.5 4h4v16h-4zM10 4h4v16h-4zM16.3 4.6l3.7 1-3.5 15-3.7-1z', filled: true),
  'compass': _Glyph('M12 3a9 9 0 1 0 0 18 9 9 0 0 0 0-18ZM15.5 8.5l-2 5-5 2 2-5 5-2Z'),
  'compassFill': _Glyph('M12 2.5A9.5 9.5 0 1 0 12 21.5 9.5 9.5 0 0 0 12 2.5Zm4.2 6-1.8 5.4a1 1 0 0 1-.6.6L8.4 16.4a.4.4 0 0 1-.5-.5l1.7-5.5a1 1 0 0 1 .6-.6l5.5-1.8a.4.4 0 0 1 .5.5Z', filled: true),
  'disc': _Glyph('M12 3a9 9 0 1 0 0 18 9 9 0 0 0 0-18ZM12 10a2 2 0 1 0 0 4 2 2 0 0 0 0-4Z'),
  'discFill': _Glyph('M12 2.5A9.5 9.5 0 1 0 12 21.5 9.5 9.5 0 0 0 12 2.5Zm0 7a2.5 2.5 0 1 1 0 5 2.5 2.5 0 0 1 0-5Z', filled: true),
  // browser
  'arrowLeft': _Glyph('M19 12H5M11 6l-6 6 6 6'),
  'arrowRight': _Glyph('M5 12h14M13 6l6 6-6 6'),
  'refresh': _Glyph('M20 11a8 8 0 1 0-.5 4M20 5v6h-6'),
  'home': _Glyph('M4 11l8-7 8 7M6 10v9h12v-9'),
  'homeFill': _Glyph('M12 3.2 3.5 10.6a1 1 0 0 0-.3.7V20a1 1 0 0 0 1 1h5v-6h5.6v6h5a1 1 0 0 0 1-1v-8.7a1 1 0 0 0-.3-.7Z', filled: true),
  'lock': _Glyph('M7 10V8a5 5 0 0 1 10 0v2M5 10h14v10H5zM12 14v3'),
  'search': _Glyph('M11 4a7 7 0 1 0 0 14 7 7 0 0 0 0-14ZM16 16l4.5 4.5'),
  'mic': _Glyph('M12 3a3 3 0 0 0-3 3v6a3 3 0 0 0 6 0V6a3 3 0 0 0-3-3ZM5 11a7 7 0 0 0 14 0M12 18v3'),
  // library tools
  'sort': _Glyph('M7 4v16M7 4l-3 3M7 4l3 3M17 20V4M17 20l-3-3M17 20l3-3'),
  'filter': _Glyph('M4 6h16M7 12h10M10 18h4'),
  'video': _Glyph('M4 7a2 2 0 0 1 2-2h7a2 2 0 0 1 2 2v.5l3.5-2A1 1 0 0 1 21 6.4v11.2a1 1 0 0 1-1.5.9L16 16.5V17a2 2 0 0 1-2 2H6a2 2 0 0 1-2-2Z', filled: true),
  'videoBadge': _Glyph('M3 6.5A1.5 1.5 0 0 1 4.5 5h8A1.5 1.5 0 0 1 14 6.5v1l3-1.7a.8.8 0 0 1 1.2.7v7a.8.8 0 0 1-1.2.7L14 12.5v1A1.5 1.5 0 0 1 12.5 15h-8A1.5 1.5 0 0 1 3 13.5Z', filled: true),
  'plus': _Glyph('M12 5v14M5 12h14'),
  // downloads / status
  'download': _Glyph('M12 4v11M7 11l5 5 5-5M5 20h14'),
  'share': _Glyph('M16 6l-4-4-4 4M12 2v13M5 12v7a1 1 0 0 0 1 1h12a1 1 0 0 0 1-1v-7'),
  'checkCircle': _Glyph('M12 2a10 10 0 1 0 0 20 10 10 0 0 0 0-20Zm5 7.2-6 6.2-3.2-3.3 1.4-1.4 1.8 1.9 4.6-4.8Z', filled: true),
  'errorCircle': _Glyph('M12 2a10 10 0 1 0 0 20 10 10 0 0 0 0-20Zm1 5h-2v7h2Zm0 9h-2v2h2Z', filled: true),
  'clock': _Glyph('M12 3a9 9 0 1 0 0 18 9 9 0 0 0 0-18ZM12 7v5l3.5 2'),
  'x': _Glyph('M6 6l12 12M18 6 6 18'),
  'check': _Glyph('M5 12.5l5 5 9-11'),
  'playCircle': _Glyph('M12 2a10 10 0 1 0 0 20 10 10 0 0 0 0-20Zm-2 6.2 6 3.8-6 3.8Z', filled: true),
};

/// Draw a named glyph. Outline glyphs respect [strokeWidth].
class AppIcon extends StatelessWidget {
  final String name;
  final double size;
  final Color color;
  final double strokeWidth;
  const AppIcon(this.name, {super.key, this.size = 20, this.color = AppColors.label, this.strokeWidth = 2});

  @override
  Widget build(BuildContext context) {
    final g = _glyphs[name];
    if (g == null) return SizedBox(width: size, height: size);
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(painter: _GlyphPainter(g, color, strokeWidth)),
    );
  }
}

class _GlyphPainter extends CustomPainter {
  final _Glyph glyph;
  final Color color;
  final double strokeWidth;
  _GlyphPainter(this.glyph, this.color, this.strokeWidth);

  @override
  void paint(Canvas canvas, Size size) {
    final path = parseSvgPathData(glyph.path);
    final scale = size.width / 24.0; // glyphs are authored on a 24-unit grid
    canvas.save();
    canvas.scale(scale);
    final paint = Paint()..color = color..isAntiAlias = true;
    if (glyph.filled) {
      paint.style = PaintingStyle.fill;
    } else {
      paint
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round;
    }
    canvas.drawPath(path, paint);
    canvas.restore();
  }

  @override
  bool shouldRepaint(_GlyphPainter old) =>
      old.color != color || old.glyph != glyph || old.strokeWidth != strokeWidth;
}
