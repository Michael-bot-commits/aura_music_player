// core/dynamic_color.dart
//
// Live dominant-colour extraction from the current artwork — the
// signature mechanic. Uses palette_generator, then applies the same
// legibility correction as the prototype: a vivid [dominant] for chrome
// tint + accent halo, and a darkened/desaturated [ambient] wash that
// keeps overlaid text readable. Notifies listeners so chrome + player
// crossfade together (drive the crossfade with an AnimatedContainer /
// implicit colour tween over Motion.dynamicColor).

import 'package:flutter/material.dart';
import 'package:palette_generator/palette_generator.dart';

class DynamicColor extends ChangeNotifier {
  Color dominant = const Color(0xFF3A3A40);
  Color ambient = const Color(0xFF16161A);

  final _cache = <String, (Color, Color)>{};
  String? _current;

  /// Extract from an artwork [ImageProvider], keyed for caching.
  Future<void> update(ImageProvider image, String key) async {
    _current = key;
    if (_cache.containsKey(key)) {
      _apply(_cache[key]!);
      return;
    }
    try {
      final palette = await PaletteGenerator.fromImageProvider(
        image,
        size: const Size(64, 64),
        maximumColorCount: 16,
      );
      final seed = palette.vibrantColor?.color ??
          palette.dominantColor?.color ??
          const Color(0xFF3A3A40);
      final pair = _correct(seed);
      _cache[key] = pair;
      if (_current == key) _apply(pair);
    } catch (_) {
      _apply((const Color(0xFF3A3A40), const Color(0xFF16161A)));
    }
  }

  void _apply((Color, Color) pair) {
    dominant = pair.$1;
    ambient = pair.$2;
    notifyListeners();
  }

  /// Legibility correction — mirrors color.js:
  /// dominant = clamp(sat 0.40–0.72, light 0.32–0.50)
  /// ambient  = darkened (light 0.14) + desaturated for the wash.
  static (Color, Color) _correct(Color c) {
    final hsl = HSLColor.fromColor(c);
    final dominant = HSLColor.fromAHSL(
      1,
      hsl.hue,
      hsl.saturation.clamp(0.40, 0.72),
      hsl.lightness.clamp(0.32, 0.50),
    ).toColor();
    final ambient = HSLColor.fromAHSL(
      1,
      hsl.hue,
      (hsl.saturation * 0.7).clamp(0.0, 0.50),
      0.14,
    ).toColor();
    return (dominant, ambient);
  }
}
