import 'package:flutter/material.dart';

/// Dark Luxury Color System — "Violet Reign"
/// Primary:   Violet Blaze  (#A855F7)
/// Secondary: Electric Cyan (#06B6D4)
/// Tertiary:  Rose Red      (#F43F5E)
/// Light bg:  Pale Violet   (#F8F7FC)
/// Dark bg:   Void Black    (#09090F)

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

  // ─── Neutral Scale (cool violet-tinted) ─────────────────
  static const Color gray25 = Color(0xFFFCFBFE);
  static const Color gray50 = Color(0xFFF8F7FC);
  static const Color gray100 = Color(0xFFEFEDF7);
  static const Color gray200 = Color(0xFFDDDAEF);
  static const Color gray300 = Color(0xFFBBB8D4);
  static const Color gray400 = Color(0xFF8885A8);
  static const Color gray500 = Color(0xFF5E5B7A);
  static const Color gray600 = Color(0xFF433F5C);
  static const Color gray700 = Color(0xFF2B2840);
  static const Color gray800 = Color(0xFF181626);
  static const Color gray900 = Color(0xFF0D0C18);

  // ─── Semantic ────────────────────────────────────────────
  static const Color error = Color(0xFFE53E5A);
  static const Color errorContainer = Color(0xFFFFE8EC);
  static const Color onErrorContainer = Color(0xFF4A0015);

  static const Color warning = Color(0xFFD97706);
  static const Color success = Color(0xFF10B981);

  // ─── Primary — Violet Blaze ──────────────────────────────
  static const Color primary = Color(0xFFA855F7);
  static const Color onPrimary = Color(0xFFFFFFFF);
  static const Color primaryContainer = Color(0xFFEDD9FF);
  static const Color onPrimaryContainer = Color(0xFF2D0060);
  static const Color primaryFixed = Color(0xFFF5EEFF);
  static const Color primaryFixedDim = Color(0xFFC084FC);
  static const Color onPrimaryFixed = Color(0xFF20004A);
  static const Color onPrimaryFixedVariant = Color(0xFF7C3AED);

  // ─── Secondary — Electric Cyan ───────────────────────────
  static const Color secondary = Color(0xFF06B6D4);
  static const Color onSecondary = Color(0xFF001E26);
  static const Color secondaryContainer = Color(0xFFCCF5FC);
  static const Color onSecondaryContainer = Color(0xFF00363F);
  static const Color secondaryFixed = Color(0xFFE0FAFE);
  static const Color secondaryFixedDim = Color(0xFF67E8F9);
  static const Color onSecondaryFixed = Color(0xFF002A33);
  static const Color onSecondaryFixedVariant = Color(0xFF0891B2);

  // ─── Tertiary — Rose Red ─────────────────────────────────
  static const Color tertiary = Color(0xFFF43F5E);
  static const Color onTertiary = Color(0xFFFFFFFF);
  static const Color tertiaryContainer = Color(0xFFFFE4E9);
  static const Color onTertiaryContainer = Color(0xFF4A0018);

  // ─── Light Surface (Pale Violet White) ──────────────────
  static const Color surface = Color(0xFFF8F7FC);
  static const Color onSurface = Color(0xFF0D0C18);
  static const Color surfaceDim = Color(0xFFDDDAEF);
  static const Color surfaceBright = Color(0xFFFEFEFF);
  static const Color surfaceContainerLowest = Color(0xFFFFFFFF);
  static const Color surfaceContainerLow = Color(0xFFF3F1FA);
  static const Color surfaceContainer = Color(0xFFECEAF5);
  static const Color surfaceContainerHigh = Color(0xFFE4E1F0);
  static const Color surfaceContainerHighest = Color(0xFFDDDAEF);
  static const Color onSurfaceVariant = Color(0xFF433F5C);

  // ─── Light Outline ───────────────────────────────────────
  static const Color outline = Color(0xFF8885A8);
  static const Color outlineVariant = Color(0xFFBBB8D4);

  // ─── Dark Surface (Void Black) ───────────────────────────
  static const Color darkSurface = Color(0xFF09090F);
  static const Color darkOnSurface = Color(0xFFECEAF5);
  static const Color darkSurfaceDim = Color(0xFF05050A);
  static const Color darkSurfaceBright = Color(0xFF171524);
  static const Color darkSurfaceContainerLowest = Color(0xFF040409);
  static const Color darkSurfaceContainerLow = Color(0xFF0E0D1A);
  static const Color darkSurfaceContainer = Color(0xFF131220);
  static const Color darkSurfaceContainerHigh = Color(0xFF1A1828); // cards
  static const Color darkSurfaceContainerHighest = Color(0xFF222034);
  static const Color darkOnSurfaceVariant = Color(0xFFADABC8);

  // ─── Dark Outline ────────────────────────────────────────
  static const Color darkOutline = Color(0xFF5E5B7A);
  static const Color darkOutlineVariant = Color(0xFF2B2840);

  // ─── Dark Semantic ───────────────────────────────────────
  static const Color darkError = Color(0xFFFF7090);
  static const Color darkErrorContainer = Color(0xFF5C0018);
  static const Color darkOnErrorContainer = Color(0xFFFFD7E1);

  // ─── Violet glow (special accent for premium UI moments) ─
  /// Use sparingly: selected tab indicator, active border, badge highlight
  static const Color violetGlow = Color(0xFFBF7FFF);
  static const Color violetSubtle = Color(0xFF7C3AED);
  static const Color violetOnDark = Color(0xFFC084FC);
  static const Color cyanGlow = Color(0xFF22D3EE);

  // ─── MaterialColor for primary ───────────────────────────
  static const MaterialColor primaryMaterial =
      MaterialColor(_primaryValue, <int, Color>{
        50: Color(0xFFF5EEFF),
        100: Color(0xFFEDD9FF),
        200: Color(0xFFC084FC),
        300: Color(0xFFB670F8),
        400: Color(0xFFA855F7),
        500: Color(_primaryValue),
        600: Color(0xFF9333EA),
        700: Color(0xFF7C3AED),
        800: Color(0xFF5B21B6),
        900: Color(0xFF20004A),
      });
  static const int _primaryValue = 0xFFA855F7;

  static const MaterialColor primaryAccent =
      MaterialColor(_primaryAccentValue, <int, Color>{
        100: Color(0xFFC084FC),
        200: Color(_primaryAccentValue),
        400: Color(0xFFA040F0),
        700: Color(0xFF7C3AED),
      });
  static const int _primaryAccentValue = 0xFFB670F8;

  // ─── Convenience getters (theme-aware) ───────────────────
  static Color adaptiveSurface(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark ? darkSurface : surface;

  static Color adaptiveOnSurface(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark
      ? darkOnSurface
      : onSurface;

  /// Violet accent adjusted for readability in both modes
  static Color adaptiveViolet(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark
      ? violetOnDark
      : violetSubtle;
}
