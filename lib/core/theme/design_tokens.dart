import 'package:flutter/material.dart';

/// All design tokens from the FeastForged "Forge" design spec.
/// Every value here is sourced directly from the handoff document.
abstract final class DesignTokens {
  // ── Surfaces ───────────────────────────────────────────────────────────────
  static const Color bg = Color(0xFF12100E);
  static const Color surface = Color(0xFF1B1815);
  static const Color surface2 = Color(0xFF231F1B);
  static const Color surface3 = Color(0xFF2C2822);

  /// rgba(255,240,220,.08) — borders at rest
  static const Color hairline = Color(0x14FFF0DC);

  /// rgba(255,240,220,.14) — hover borders
  static const Color hairline2 = Color(0x24FFF0DC);

  // ── Text ───────────────────────────────────────────────────────────────────
  static const Color ink = Color(0xFFF5EFE6);
  static const Color ink2 = Color(0xFFC9BDAB);
  static const Color ink3 = Color(0xFF8B8170);
  static const Color ink4 = Color(0xFF5B5346);

  // ── Brand & semantic ───────────────────────────────────────────────────────
  static const Color brand = Color(0xFFF4A340);
  static const Color brandSoft = Color(0xFF3A2A17);
  static const Color brandInk = Color(0xFF1A1107);
  static const Color success = Color(0xFF7EC17A);
  static const Color danger = Color(0xFFE87B6B);
  static const Color info = Color(0xFF8FB4E8);

  /// rgba(244,163,64,.22) — radial glow on hero surfaces
  static const Color brandGlow = Color(0x38F4A340);

  /// rgba(244,163,64,.44) — streak badge border
  static const Color brandBorder = Color(0x70F4A340);

  /// rgba(244,163,64,.10) — streak badge bg bottom
  static const Color brandBgBottom = Color(0x1AF4A340);

  /// rgba(244,163,64,.22) — streak badge bg top
  static const Color brandBgTop = Color(0x38F4A340);

  // ── Border radius ──────────────────────────────────────────────────────────
  /// Small chips, inputs
  static const double r1 = 10;

  /// Cards, buttons
  static const double r2 = 14;

  /// Hero cards
  static const double r3 = 20;

  /// Sheets, modals
  static const double r4 = 28;

  // ── Shadows ────────────────────────────────────────────────────────────────
  static const List<BoxShadow> shadow1 = [
    BoxShadow(color: Color(0x59000000), blurRadius: 24, offset: Offset(0, 8)),
    BoxShadow(
      color: Color(0x0AFFF0DC),
      blurRadius: 0,
      spreadRadius: -1,
      offset: Offset(0, 1),
    ),
  ];

  static const List<BoxShadow> shadow2 = [
    BoxShadow(color: Color(0x80000000), blurRadius: 50, offset: Offset(0, 20)),
    BoxShadow(
      color: Color(0x0FFFF0DC),
      blurRadius: 0,
      spreadRadius: -1,
      offset: Offset(0, 1),
    ),
  ];

  // ── Macro ring sizes (from spec) ───────────────────────────────────────────
  static const double bigRingDiameter = 110;
  static const double bigRingStroke = 10;
  static const double macroRingDiameter = 44;
  static const double macroRingStroke = 4;

  // ── Animation durations ────────────────────────────────────────────────────
  static const Duration ringAnimDuration = Duration(milliseconds: 900);
  static const Duration fadeDuration = Duration(milliseconds: 380);
  static const Curve ringAnimCurve = Cubic(0.2, 0.7, 0.2, 1.0);
  static const Curve fadeCurve = Cubic(0.2, 0.7, 0.2, 1.0);
}
