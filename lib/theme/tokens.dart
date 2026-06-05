// theme/tokens.dart
//
// AURA design tokens — the Flutter mirror of the prototype's tokens.css
// and the SwiftUI AuraTokens.swift. Dark-first. One brand accent (Coral).
// Dynamic colour is separate (extracted from artwork — see
// core/dynamic_color.dart).

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Colour — iOS dark semantic palette + the single Coral accent.
class AppColors {
  // Surfaces (iOS systemBackground · dark)
  static const bg = Color(0xFF000000);
  static const bg2 = Color(0xFF1C1C1E);
  static const bg3 = Color(0xFF2C2C2E);

  // System fills (translucent grays)
  static const fill1 = Color(0x5C787880); // rgba(120,120,128,0.36)
  static const fill2 = Color(0x3D787880); // 0.24
  static const fill3 = Color(0x2E787880); // 0.18

  // Labels (iOS · dark)
  static const label = Color(0xFFFFFFFF);
  static const label2 = Color(0x99EBEBF5); // 0.60
  static const label3 = Color(0x4DEBEBF5); // 0.30
  static const label4 = Color(0x2EEBEBF5); // 0.18
  static const separator = Color(0x8C545458); // rgba(84,84,88,0.55)
  static const separatorOp = Color(0x14FFFFFF); // white 0.08

  // Status
  static const success = Color(0xFF30D158);
  static const error = Color(0xFFFF453A);
  static const warning = Color(0xFFFF9F0A);

  /// Brand accent (Coral, brightened for dark). Swap to Color(0xFF3B86FF)
  /// for the blue identity — keep exactly one accent app-wide. In a real
  /// app expose this through ThemeExtension or a settings provider.
  static const accent = Color(0xFFFF6E72);
  static const accentDeep = Color(0xFFFF5A5F);
  static const accentInk = Color(0xFFFFFFFF);
}

/// Radii — strict grammar, mirrors the prototype.
class R {
  static const double xs = 8; // cell artwork, small thumbs
  static const double sm = 10;
  static const double md = 12; // cards, grid art, buttons
  static const double art = 15; // player artwork
  static const double lg = 20; // sheets, fused chrome
  static const double xl = 28;
  static const double pill = 999;
}

/// Spacing — base-4 grid.
class Space {
  static const double xxs = 4;
  static const double xs = 8;
  static const double sm = 12;
  static const double md = 16; // standard side margin
  static const double lg = 20; // large-title margin
  static const double xl = 28;
}

/// Motion — durations + curves. No bounce, no infinite loops.
class Motion {
  static const fast = Duration(milliseconds: 160);
  static const base = Duration(milliseconds: 240);
  static const dynamicColor = Duration(milliseconds: 600); // crossfade on track change
  static const ease = Cubic(0.32, 0.72, 0, 1);
  static const easeOut = Cubic(0.22, 1, 0.36, 1);
  // SwiftUI spring(response:0.4, damping:0.7) ≈ this for the artwork scale.
  static const spring = Cubic(0.34, 1.2, 0.64, 1);
}

/// Typography — Inter (SF Pro substitute), tracking + sizes per the brief.
class AppText {
  static TextStyle _i(double size, FontWeight w,
          {double ls = 0, double height = 1.2, Color color = AppColors.label}) =>
      GoogleFonts.inter(
          fontSize: size, fontWeight: w, letterSpacing: ls, height: height, color: color);

  // Display / big page titles (28–34 Bold, tight tracking)
  static TextStyle display([double size = 28]) => _i(size, FontWeight.w700, ls: -0.5);
  static final trackTitle = _i(17, FontWeight.w600, ls: -0.2);
  static final subtitle = _i(15, FontWeight.w400, color: AppColors.label2);
  static final bodyRead = _i(17, FontWeight.w400, height: 1.4, color: AppColors.label2);
  static final sectionHeader =
      _i(13, FontWeight.w600, ls: 0.4, color: AppColors.label2); // UPPERCASE at call site
  static final metaSmall = _i(12.5, FontWeight.w400, color: AppColors.label2);
  // Timestamps — tabular figures.
  static final timestamp = GoogleFonts.robotoMono(
      fontSize: 12, fontWeight: FontWeight.w400, color: AppColors.label2);
}

/// The single allowed shadow in the system — artwork only.
const artworkShadow = [
  BoxShadow(color: Color(0x73000000), blurRadius: 30, offset: Offset(0, 10)), // 0.45
];

/// Frosted-glass recipe used by the chrome, sheets, and control chips.
/// Wrap a child in [BackdropFilter] with this blur + a translucent fill.
class Glass {
  static const blurSigma = 18.0; // ≈ CSS blur(28px)
  static const fill = Color(0x8C28282C); // rgba(40,40,44,0.55)
  static const fillThin = Color(0x6B3C3C42);
}
