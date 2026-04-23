import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

import 'design_tokens.dart';

/// FeastForged "Forge" design system.
///
/// Dark-first. Three fonts:
///   Fraunces  → display / hero numbers (serif)
///   Inter     → UI / body copy (sans)
///   JetBrains Mono → stats, timestamps, metadata
///
/// Every number visible on-screen must use [ForgeTextStyles.stat] or a
/// JetBrains Mono style with fontVariantNumeric: 'tabular-nums'.
class AppTheme {
  AppTheme._();

  // ── Dark (primary) ─────────────────────────────────────────────────────────

  static ThemeData get dark {
    final colorScheme = _colorScheme;
    final textTheme = _buildTextTheme();

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: DesignTokens.bg,
      textTheme: textTheme,

      // ── App bar ─────────────────────────────────────────────────────────
      // Spec: "Never centered app-bar title" / use eyebrow+serif pattern.
      // App bars are transparent and use system UI overlay.
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        foregroundColor: DesignTokens.ink,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        systemOverlayStyle: const SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.light,
        ),
        titleTextStyle: GoogleFonts.fraunces(
          textStyle: const TextStyle(
            color: DesignTokens.ink,
            fontSize: 22,
            fontWeight: FontWeight.w400,
            letterSpacing: -0.4,
          ),
        ),
      ),

      // ── Cards ────────────────────────────────────────────────────────────
      cardTheme: CardThemeData(
        color: DesignTokens.surface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(DesignTokens.r2),
          side: const BorderSide(color: DesignTokens.hairline),
        ),
        shadowColor: Colors.black.withValues(alpha: 0.35),
        margin: EdgeInsets.zero,
      ),

      // ── Buttons ──────────────────────────────────────────────────────────
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: DesignTokens.brand,
          foregroundColor: DesignTokens.brandInk,
          minimumSize: const Size.fromHeight(48),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(DesignTokens.r2),
          ),
          elevation: 0,
          textStyle: GoogleFonts.inter(
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),

      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: DesignTokens.brand,
          foregroundColor: DesignTokens.brandInk,
          minimumSize: const Size.fromHeight(48),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(DesignTokens.r2),
          ),
          elevation: 0,
          textStyle: GoogleFonts.inter(
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),

      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: DesignTokens.ink,
          side: const BorderSide(color: DesignTokens.hairline2),
          minimumSize: const Size.fromHeight(48),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(DesignTokens.r2),
          ),
          textStyle: GoogleFonts.inter(
            fontSize: 15,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),

      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: DesignTokens.brand,
          textStyle: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),

      iconButtonTheme: IconButtonThemeData(
        style: IconButton.styleFrom(
          foregroundColor: DesignTokens.ink2,
          backgroundColor: DesignTokens.surface,
          shape: const CircleBorder(
            side: BorderSide(color: DesignTokens.hairline),
          ),
          minimumSize: const Size(36, 36),
        ),
      ),

      // ── Inputs ──────────────────────────────────────────────────────────
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: DesignTokens.surface3,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(DesignTokens.r1),
          borderSide: const BorderSide(color: DesignTokens.hairline),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(DesignTokens.r1),
          borderSide: const BorderSide(color: DesignTokens.hairline),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(DesignTokens.r1),
          borderSide: const BorderSide(color: DesignTokens.brand, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(DesignTokens.r1),
          borderSide: const BorderSide(color: DesignTokens.danger),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(DesignTokens.r1),
          borderSide: const BorderSide(color: DesignTokens.danger, width: 1.5),
        ),
        labelStyle: GoogleFonts.inter(
          color: DesignTokens.ink3,
          fontSize: 14,
          fontWeight: FontWeight.w400,
        ),
        hintStyle: GoogleFonts.inter(color: DesignTokens.ink4, fontSize: 14),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
      ),

      // ── Chips ───────────────────────────────────────────────────────────
      chipTheme: ChipThemeData(
        backgroundColor: DesignTokens.surface3,
        selectedColor: DesignTokens.brand,
        side: const BorderSide(color: DesignTokens.hairline),
        shape: const StadiumBorder(),
        labelStyle: GoogleFonts.inter(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: DesignTokens.ink2,
        ),
        secondaryLabelStyle: GoogleFonts.inter(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: DesignTokens.brandInk,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      ),

      // ── Bottom nav ──────────────────────────────────────────────────────
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: DesignTokens.surface,
        selectedItemColor: DesignTokens.brand,
        unselectedItemColor: DesignTokens.ink3,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
      ),

      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: DesignTokens.surface,
        indicatorColor: DesignTokens.brandSoft,
        iconTheme: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return const IconThemeData(color: DesignTokens.brand);
          }
          return const IconThemeData(color: DesignTokens.ink3);
        }),
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return GoogleFonts.inter(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: DesignTokens.brand,
            );
          }
          return GoogleFonts.inter(
            fontSize: 11,
            fontWeight: FontWeight.w400,
            color: DesignTokens.ink3,
          );
        }),
      ),

      // ── Dividers ────────────────────────────────────────────────────────
      dividerTheme: const DividerThemeData(
        color: DesignTokens.hairline,
        thickness: 1,
        space: 1,
      ),

      // ── List tiles ──────────────────────────────────────────────────────
      listTileTheme: ListTileThemeData(
        tileColor: Colors.transparent,
        textColor: DesignTokens.ink,
        iconColor: DesignTokens.ink3,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(DesignTokens.r2),
        ),
      ),

      // ── Snackbar ────────────────────────────────────────────────────────
      snackBarTheme: SnackBarThemeData(
        backgroundColor: DesignTokens.surface2,
        contentTextStyle: GoogleFonts.inter(
          color: DesignTokens.ink,
          fontSize: 14,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(DesignTokens.r1),
        ),
        behavior: SnackBarBehavior.floating,
      ),

      // ── Bottom sheet ─────────────────────────────────────────────────────
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: DesignTokens.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(DesignTokens.r4),
          ),
        ),
        dragHandleColor: DesignTokens.ink4,
        showDragHandle: true,
      ),

      // ── Dialog ──────────────────────────────────────────────────────────
      dialogTheme: DialogThemeData(
        backgroundColor: DesignTokens.surface2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(DesignTokens.r4),
        ),
        titleTextStyle: GoogleFonts.fraunces(
          color: DesignTokens.ink,
          fontSize: 22,
          fontWeight: FontWeight.w400,
          letterSpacing: -0.4,
        ),
      ),

      // ── Progress ────────────────────────────────────────────────────────
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: DesignTokens.brand,
        linearTrackColor: DesignTokens.hairline2,
        circularTrackColor: DesignTokens.hairline2,
      ),

      // ── Search bar ──────────────────────────────────────────────────────
      searchBarTheme: SearchBarThemeData(
        backgroundColor: WidgetStatePropertyAll(DesignTokens.surface3),
        elevation: const WidgetStatePropertyAll(0),
        shape: WidgetStatePropertyAll(
          RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(DesignTokens.r1),
            side: const BorderSide(color: DesignTokens.hairline),
          ),
        ),
        hintStyle: WidgetStatePropertyAll(
          GoogleFonts.inter(color: DesignTokens.ink4, fontSize: 14),
        ),
        textStyle: WidgetStatePropertyAll(
          GoogleFonts.inter(color: DesignTokens.ink, fontSize: 14),
        ),
      ),
    );
  }

  // ── Light (system fallback only — Forge is dark-first) ─────────────────────
  // Minimal light theme that keeps the brand amber; used only when the OS
  // is in light mode and the user hasn't chosen a preference.
  static ThemeData get light => dark.copyWith(
    brightness: Brightness.light,
    scaffoldBackgroundColor: const Color(0xFFF7F2E8),
    colorScheme: _colorScheme.copyWith(
      brightness: Brightness.light,
      surface: Colors.white,
      onSurface: const Color(0xFF1A1107),
      onSurfaceVariant: const Color(0xFF5B5346),
    ),
  );

  // ── Color scheme ───────────────────────────────────────────────────────────

  static ColorScheme get _colorScheme => const ColorScheme(
    brightness: Brightness.dark,
    // Backgrounds
    surface: DesignTokens.surface,
    // Primary = brand amber
    primary: DesignTokens.brand,
    onPrimary: DesignTokens.brandInk,
    primaryContainer: DesignTokens.brandSoft,
    onPrimaryContainer: DesignTokens.brand,
    // Secondary = success green
    secondary: DesignTokens.success,
    onSecondary: Color(0xFF0D2B0C),
    secondaryContainer: Color(0xFF1A3D19),
    onSecondaryContainer: DesignTokens.success,
    // Tertiary = info blue
    tertiary: DesignTokens.info,
    onTertiary: Color(0xFF0C1E36),
    tertiaryContainer: Color(0xFF1A3050),
    onTertiaryContainer: DesignTokens.info,
    // Error = danger
    error: DesignTokens.danger,
    onError: Color(0xFF2D0A07),
    errorContainer: Color(0xFF4A1010),
    onErrorContainer: DesignTokens.danger,
    // Surface hierarchy
    onSurface: DesignTokens.ink,
    onSurfaceVariant: DesignTokens.ink2,
    surfaceContainerLowest: DesignTokens.bg,
    surfaceContainerLow: DesignTokens.surface,
    surfaceContainer: DesignTokens.surface2,
    surfaceContainerHigh: DesignTokens.surface3,
    surfaceContainerHighest: DesignTokens.surface3,
    // Outlines
    outline: DesignTokens.ink4,
    outlineVariant: DesignTokens.hairline2,
    // Misc
    inverseSurface: DesignTokens.ink,
    onInverseSurface: DesignTokens.bg,
    inversePrimary: DesignTokens.brandSoft,
    shadow: Color(0xFF000000),
    scrim: Color(0xFF000000),
  );

  // ── Text theme ─────────────────────────────────────────────────────────────
  // Fraunces for display/headline, Inter for everything else.
  // JetBrains Mono is used ad-hoc via [ForgeTextStyles] in widgets.

  static TextTheme _buildTextTheme() {
    final fraunces = GoogleFonts.fraunces;
    final inter = GoogleFonts.inter;

    return TextTheme(
      // Display — Fraunces
      displayLarge: fraunces(
        fontSize: 52,
        fontWeight: FontWeight.w400,
        color: DesignTokens.ink,
        letterSpacing: -1.2,
        height: 1.0,
      ),
      displayMedium: fraunces(
        fontSize: 44,
        fontWeight: FontWeight.w400,
        color: DesignTokens.ink,
        letterSpacing: -1.2,
        height: 1.05,
      ),
      displaySmall: fraunces(
        fontSize: 36,
        fontWeight: FontWeight.w400,
        color: DesignTokens.ink,
        letterSpacing: -0.8,
        height: 1.1,
      ),
      // Headline — Fraunces
      headlineLarge: fraunces(
        fontSize: 28,
        fontWeight: FontWeight.w400,
        color: DesignTokens.ink,
        letterSpacing: -0.4,
        height: 1.15,
      ),
      headlineMedium: fraunces(
        fontSize: 24,
        fontWeight: FontWeight.w400,
        color: DesignTokens.ink,
        letterSpacing: -0.4,
        height: 1.2,
      ),
      headlineSmall: fraunces(
        fontSize: 22,
        fontWeight: FontWeight.w400,
        color: DesignTokens.ink,
        letterSpacing: -0.4,
        height: 1.2,
      ),
      // Title — Fraunces large, Inter medium/small
      titleLarge: fraunces(
        fontSize: 20,
        fontWeight: FontWeight.w500,
        color: DesignTokens.ink,
        letterSpacing: -0.3,
        height: 1.3,
      ),
      titleMedium: inter(
        fontSize: 16,
        fontWeight: FontWeight.w500,
        color: DesignTokens.ink,
        height: 1.4,
      ),
      titleSmall: inter(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: DesignTokens.ink,
        height: 1.4,
      ),
      // Body — Inter
      bodyLarge: inter(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        color: DesignTokens.ink,
        height: 1.5,
      ),
      bodyMedium: inter(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        color: DesignTokens.ink,
        height: 1.5,
      ),
      bodySmall: inter(
        fontSize: 12,
        fontWeight: FontWeight.w400,
        color: DesignTokens.ink2,
        height: 1.4,
      ),
      // Label — Inter
      labelLarge: inter(
        fontSize: 15,
        fontWeight: FontWeight.w600,
        color: DesignTokens.ink,
        letterSpacing: 0.1,
      ),
      labelMedium: inter(
        fontSize: 13,
        fontWeight: FontWeight.w500,
        color: DesignTokens.ink,
      ),
      labelSmall: inter(
        fontSize: 11,
        fontWeight: FontWeight.w500,
        color: DesignTokens.ink2,
      ),
    );
  }
}

/// Convenience styles for the JetBrains Mono stat layer.
///
/// Use these wherever the spec says "JetBrains Mono + tabular-nums":
/// calorie counts, macro grams, timestamps, metadata rows.
abstract final class ForgeTextStyles {
  /// Large stat number — e.g. the center calorie count in the big ring.
  static TextStyle statHero({Color color = DesignTokens.ink}) =>
      GoogleFonts.jetBrainsMono(
        fontSize: 26,
        fontWeight: FontWeight.w400,
        color: color,
        letterSpacing: -0.3,
        fontFeatures: const [FontFeature.tabularFigures()],
      );

  /// Standard stat — macro grams, kcal labels, timestamps.
  static TextStyle stat({
    double fontSize = 13,
    FontWeight fontWeight = FontWeight.w500,
    Color color = DesignTokens.ink2,
  }) => GoogleFonts.jetBrainsMono(
    fontSize: fontSize,
    fontWeight: fontWeight,
    color: color,
    fontFeatures: const [FontFeature.tabularFigures()],
  );

  /// Eyebrow label — uppercase mono, +1.5 letter-spacing.
  static TextStyle eyebrow({Color color = DesignTokens.ink3}) =>
      GoogleFonts.jetBrainsMono(
        fontSize: 11,
        fontWeight: FontWeight.w500,
        color: color,
        letterSpacing: 1.5,
        fontFeatures: const [FontFeature.tabularFigures()],
      ).copyWith(
        // Uppercase is applied at the widget level via text.toUpperCase()
      );

  /// Serif hero title — Fraunces for screen headings.
  static TextStyle screenTitle({
    double fontSize = 24,
    Color color = DesignTokens.ink,
  }) => GoogleFonts.fraunces(
    fontSize: fontSize,
    fontWeight: FontWeight.w400,
    color: color,
    letterSpacing: -0.4,
    height: 1.2,
  );
}
