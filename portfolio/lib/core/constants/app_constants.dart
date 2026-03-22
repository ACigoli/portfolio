import 'package:flutter/material.dart';

class AppColors {
  static const Color background = Color(0xFF050816);
  static const Color surface = Color(0xFF0D1224);
  static const Color card = Color(0xFF151D35);
  static const Color cardBorder = Color(0xFF1E2D4A);

  static const Color primary = Color(0xFF915EFF);
  static const Color primaryLight = Color(0xFFAB85FF);
  static const Color secondary = Color(0xFF00D4AA);
  static const Color accent = Color(0xFFFF6B6B);

  static const Color text = Color(0xFFF3F4F6);
  static const Color textMuted = Color(0xFF8892A4);
  static const Color textDisabled = Color(0xFF4A5568);

  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primary, secondary],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient heroGradient = LinearGradient(
    colors: [Color(0xFF915EFF), Color(0xFF00D4AA)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static LinearGradient cardGradient = LinearGradient(
    colors: [card, card.withValues(alpha: 0.7)],
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

  static const EdgeInsets sectionPadding =
      EdgeInsets.symmetric(horizontal: 28, vertical: 96);
}

class AppRadius {
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 24;
  static const double full = 100;
}

class AppDurations {
  static const Duration fast = Duration(milliseconds: 300);
  static const Duration medium = Duration(milliseconds: 500);
  static const Duration slow = Duration(milliseconds: 800);
}
