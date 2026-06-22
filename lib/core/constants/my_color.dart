import 'package:flutter/material.dart';

/// Aurora Soft Color System
/// Primary:   Teal-Mint   (#00C9A7)
/// Secondary: Lavender    (#7C5CBF)
/// Accent:    Blush Pink  (#FF8FAB)
/// Light bg:  Cream White (#F8FAF9)
/// Dark bg:   Deep Slate  (#0E1A1F)

class MyColor {
  static const logBackColor = Color(0xFF0A0E27);
  static const logGradient1Color = Color(0xFF6502FE);
  static const logGradient2Color = Color(0xFFE71B6A);
  static const logGradient3Color = Color(
    0xFFFF6B35,
  ); // Additional gradient stop

  // ─── Base ───────────────────────────────────────────────
  static const Color black = Color(0xFF000000);
  static const Color white = Color(0xFFFFFFFF);

  // ─── Gray Scale ─────────────────────────────────────────
  static const Color gray25 = Color(0xFFFCFDFC);
  static const Color gray50 = Color(0xFFF8FAF9);
  static const Color gray100 = Color(0xFFEEF2F0);
  static const Color gray200 = Color(0xFFDDE5E2);
  static const Color gray300 = Color(0xFFC2CEC9);
  static const Color gray400 = Color(0xFF8FA49D);
  static const Color gray500 = Color(0xFF637A73);
  static const Color gray600 = Color(0xFF475C55);
  static const Color gray700 = Color(0xFF314039);
  static const Color gray800 = Color(0xFF1E2832);
  static const Color gray900 = Color(0xFF111C20);

  // ─── Semantic ────────────────────────────────────────────
  static const Color error = Color(0xFFE05464);
  static const Color errorContainer = Color(0xFFFFE8EB);
  static const Color onErrorContainer = Color(0xFF000000);

  static const Color warning = Color(0xFFE8870A);
  static const Color success = Color(0xFF00A87A);

  // ─── Primary — Teal Mint ─────────────────────────────────
  static const Color primary = Color(0xFF00C9A7);
  static const Color onPrimary = Color(0xFFFFFFFF);
  static const Color primaryContainer = Color(0xFFB3F0E4);
  static const Color onPrimaryContainer = Color(0xFF003D30);
  static const Color primaryFixed = Color(0xFFCCF5EC);
  static const Color primaryFixedDim = Color(0xFF5EE0C5);
  static const Color onPrimaryFixed = Color(0xFF00352A);
  static const Color onPrimaryFixedVariant = Color(0xFF007A63);

  // ─── Secondary — Lavender ────────────────────────────────
  static const Color secondary = Color(0xFF7C5CBF);
  static const Color onSecondary = Color(0xFFFFFFFF);
  static const Color secondaryContainer = Color(0xFFE8DEFF);
  static const Color onSecondaryContainer = Color(0xFF1E003F);
  static const Color secondaryFixed = Color(0xFFF0EAFF);
  static const Color secondaryFixedDim = Color(0xFFBBA8E0);
  static const Color onSecondaryFixed = Color(0xFF3A1A72);
  static const Color onSecondaryFixedVariant = Color(0xFF5A3EA0);

  // ─── Tertiary — Blush Pink (accent) ──────────────────────
  static const Color tertiary = Color(0xFFFF8FAB);
  static const Color onTertiary = Color(0xFFFFFFFF);
  static const Color tertiaryContainer = Color(0xFFFFD6E2);
  static const Color onTertiaryContainer = Color(0xFF3D0020);

  // ─── Light Surface ───────────────────────────────────────
  static const Color surface = Color(0xFFF8FAF9);
  static const Color onSurface = Color(0xFF1E2832);
  static const Color surfaceDim = Color(0xFFDDE5E2);
  static const Color surfaceBright = Color(0xFFFDFEFE);
  static const Color surfaceContainerLowest = Color(0xFFFFFFFF);
  static const Color surfaceContainerLow = Color(0xFFF3F7F5);
  static const Color surfaceContainer = Color(0xFFEDF2F0);
  static const Color surfaceContainerHigh = Color(0xFFE5EDEA);
  static const Color surfaceContainerHighest = Color(0xFFDDE5E2);
  static const Color onSurfaceVariant = Color(0xFF3D5550);

  // ─── Light Outline ───────────────────────────────────────
  static const Color outline = Color(0xFF7A9991);
  static const Color outlineVariant = Color(0xFFBDD0CB);

  // ─── Dark Surface ────────────────────────────────────────
  static const Color darkSurface = Color(0xFF0E1A1F);
  static const Color darkOnSurface = Color(0xFFDCEDE8);
  static const Color darkSurfaceDim = Color(0xFF090F12);
  static const Color darkSurfaceBright = Color(0xFF243038);
  static const Color darkSurfaceContainerLowest = Color(0xFF070D10);
  static const Color darkSurfaceContainerLow = Color(0xFF141F24);
  static const Color darkSurfaceContainer = Color(0xFF1A272D);
  static const Color darkSurfaceContainerHigh = Color(0xFF223038); // cards
  static const Color darkSurfaceContainerHighest = Color(0xFF2C3D45);
  static const Color darkOnSurfaceVariant = Color(0xFF9BBDB7);

  // ─── Dark Outline ────────────────────────────────────────
  static const Color darkOutline = Color(0xFF5A7E78);
  static const Color darkOutlineVariant = Color(0xFF2E4A45);

  // ─── Dark Semantic ───────────────────────────────────────
  static const Color darkError = Color(0xFFFF8090);
  static const Color darkErrorContainer = Color(0xFF5C1020);
  static const Color darkOnErrorContainer = Color(0xFFFFD7DB);

  // ─── MaterialColor for primary ───────────────────────────
  static const MaterialColor primaryMaterial =
      MaterialColor(_primaryValue, <int, Color>{
        50: Color(0xFFCCF5EC),
        100: Color(0xFFB3F0E4),
        200: Color(0xFF5EE0C5),
        300: Color(0xFF29D4B3),
        400: Color(0xFF00C9A7),
        500: Color(_primaryValue),
        600: Color(0xFF00A78C),
        700: Color(0xFF008570),
        800: Color(0xFF006354),
        900: Color(0xFF00352A),
      });
  static const int _primaryValue = 0xFF00C9A7;

  static const MaterialColor primaryAccent =
      MaterialColor(_primaryAccentValue, <int, Color>{
        100: Color(0xFF5EE0C5),
        200: Color(_primaryAccentValue),
        400: Color(0xFF00B898),
        700: Color(0xFF007A63),
      });
  static const int _primaryAccentValue = 0xFF29D4B3;

  // ─── Convenience getters (theme-aware) ───────────────────
  /// Use inside widgets: MyColor.adaptiveSurface(context)
  static Color adaptiveSurface(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark ? darkSurface : surface;

  static Color adaptiveOnSurface(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark
      ? darkOnSurface
      : onSurface;
}
