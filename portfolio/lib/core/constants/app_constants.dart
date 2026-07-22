import 'package:flutter/material.dart';

/// Consolidated palette — single accent pair (violet → emerald) instead of the
/// four loosely-used accents the old theme had. Semantic colors (success/danger)
/// replace ad-hoc inline hex values that used to live in individual widgets.
class AppColors {
  static const Color background = Color(0xFF050816);
  static const Color surface = Color(0xFF0A0E1F);
  static const Color card = Color(0xFF10152B);
  static const Color cardBorder = Color(0xFF1E2748);

  static const Color primary = Color(0xFF8B6BFF);
  static const Color primaryLight = Color(0xFFAB94FF);
  static const Color secondary = Color(0xFF19D3A2);

  static const Color success = Color(0xFF22C55E);
  static const Color danger = Color(0xFFE5484D);

  static const Color text = Color(0xFFF4F5F8);
  static const Color textMuted = Color(0xFF8E96AC);
  static const Color textDisabled = Color(0xFF4A5170);

  /// Hairline borders on glass surfaces — replaces solid `cardBorder` on any
  /// element meant to read as translucent/glass rather than a flat card.
  static Color hairline = Colors.white.withValues(alpha: 0.08);
  static Color hairlineStrong = Colors.white.withValues(alpha: 0.14);
  static Color innerHighlight = Colors.white.withValues(alpha: 0.06);

  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primary, secondary],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient heroGradient = LinearGradient(
    colors: [primary, secondary],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}

class AppSpacing {
  static const double xs = 4;
  static const double sm = 8;
  static const double md = 16;
  static const double lg = 24;
  static const double xl = 36;
  static const double xxl = 52;
  static const double xxxl = 96;

  static const EdgeInsets screenPadding =
      EdgeInsets.symmetric(horizontal: 28, vertical: 0);

  /// Macro-whitespace: sections breathe heavily (py-24..py-40 equivalent).
  static const EdgeInsets sectionPadding =
      EdgeInsets.symmetric(horizontal: 28, vertical: 112);
}

class AppRadius {
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 24;
  static const double full = 100;

  /// Double-bezel outer shell radius (squircle-like, large).
  static const double shellOuter = 32;
  static const double shellPadding = 6;
  static double get shellInner => shellOuter - shellPadding;
}

/// Motion tokens. UI interactions stay under ~250ms with strong custom
/// easing (no default `ease-in`/`linear`); section entrances are slower and
/// treated as "marketing" motion, per the emil-design-eng / high-end-visual
/// guidance this redesign follows.
class AppMotion {
  static const Duration press = Duration(milliseconds: 140);
  static const Duration fast = Duration(milliseconds: 200);
  static const Duration medium = Duration(milliseconds: 320);
  static const Duration modal = Duration(milliseconds: 320);
  static const Duration reveal = Duration(milliseconds: 700);

  /// Strong ease-out — entrances, hovers, presses.
  static const Curve easeOut = Cubic(0.16, 1, 0.3, 1);

  /// Ease-in-out — on-screen movement / morphing.
  static const Curve easeInOut = Cubic(0.65, 0, 0.35, 1);

  static const double pressScale = 0.97;
  static const double stagger = 0.05; // 50ms between staggered items
}
