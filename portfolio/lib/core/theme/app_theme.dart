import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../constants/app_constants.dart';

/// Display/headline type in Space Grotesk (geometric grotesk, distinctive at
/// large sizes), body/UI type in Plus Jakarta Sans. Deliberately not Inter —
/// see high-end-visual-design skill's banned-fonts list.
class AppTheme {
  static TextTheme get _textTheme {
    final display = GoogleFonts.spaceGroteskTextTheme();
    final body = GoogleFonts.plusJakartaSansTextTheme();

    return TextTheme(
      displayLarge: display.displayLarge?.copyWith(
        color: AppColors.text,
        fontSize: 64,
        fontWeight: FontWeight.w700,
        letterSpacing: -2.0,
        height: 1.05,
      ),
      displayMedium: display.displayMedium?.copyWith(
        color: AppColors.text,
        fontSize: 40,
        fontWeight: FontWeight.w700,
        letterSpacing: -1.2,
      ),
      displaySmall: display.displaySmall?.copyWith(
        color: AppColors.text,
        fontSize: 30,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.6,
      ),
      headlineMedium: display.headlineMedium?.copyWith(
        color: AppColors.text,
        fontSize: 22,
        fontWeight: FontWeight.w600,
      ),
      titleLarge: body.titleLarge?.copyWith(
        color: AppColors.text,
        fontSize: 18,
        fontWeight: FontWeight.w600,
      ),
      titleMedium: body.titleMedium?.copyWith(
        color: AppColors.text,
        fontSize: 16,
        fontWeight: FontWeight.w500,
      ),
      bodyLarge: body.bodyLarge?.copyWith(
        color: AppColors.textMuted,
        fontSize: 16,
        height: 1.7,
      ),
      bodyMedium: body.bodyMedium?.copyWith(
        color: AppColors.textMuted,
        fontSize: 14,
        height: 1.6,
      ),
      labelLarge: body.labelLarge?.copyWith(
        color: AppColors.text,
        fontSize: 14,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.3,
      ),
      labelSmall: body.labelSmall?.copyWith(
        color: AppColors.textMuted,
        fontSize: 11,
        fontWeight: FontWeight.w700,
        letterSpacing: 2.2,
      ),
    );
  }

  static ThemeData get darkTheme => ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: AppColors.background,
        colorScheme: ColorScheme.dark(
          primary: AppColors.primary,
          secondary: AppColors.secondary,
          surface: AppColors.surface,
          error: AppColors.danger,
        ),
        textTheme: _textTheme,
        cardTheme: CardThemeData(
          color: AppColors.card,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.lg),
            side: BorderSide(color: AppColors.hairline),
          ),
        ),
        dividerTheme: DividerThemeData(
          color: AppColors.hairline,
          thickness: 1,
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.transparent,
          elevation: 0,
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: AppColors.surface,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppRadius.md),
            borderSide: BorderSide(color: AppColors.hairline),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppRadius.md),
            borderSide: BorderSide(color: AppColors.hairline),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppRadius.md),
            borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
          ),
          labelStyle: const TextStyle(color: AppColors.textMuted),
          hintStyle: TextStyle(color: AppColors.textMuted.withValues(alpha: 0.6)),
        ),
        dialogTheme: DialogThemeData(
          backgroundColor: AppColors.card,
          surfaceTintColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.xl),
            side: BorderSide(color: AppColors.hairline),
          ),
        ),
        switchTheme: SwitchThemeData(
          thumbColor: WidgetStateProperty.resolveWith(
            (states) => states.contains(WidgetState.selected)
                ? AppColors.primary
                : AppColors.textMuted,
          ),
          trackColor: WidgetStateProperty.resolveWith(
            (states) => states.contains(WidgetState.selected)
                ? AppColors.primary.withValues(alpha: 0.4)
                : AppColors.cardBorder,
          ),
        ),
        splashFactory: NoSplash.splashFactory,
        highlightColor: Colors.transparent,
      );
}
