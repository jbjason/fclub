// app_theme.dart
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fclub/core/constants/my_color.dart';
import 'package:fclub/core/constants/my_string.dart';

abstract class AppTheme {
  static final visualDensity = VisualDensity.adaptivePlatformDensity;

  // ─── Breakpoints ─────────────────────────────────────────
  static bool isMobile(BuildContext context) =>
      MediaQuery.of(context).size.width < 600;

  static bool isTablet(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    return w >= 600 && w < 1200;
  }

  static bool isDesktop(BuildContext context) =>
      MediaQuery.of(context).size.width >= 1200;

  // ─── Responsive helpers ──────────────────────────────────
  static double responsiveTextScale(BuildContext context) {
    if (isMobile(context)) return 1.0;
    if (isTablet(context)) return 0.85;
    return 1.2;
  }

  static double responsiveSpacing(BuildContext context) {
    if (isMobile(context)) return 1.0;
    if (isTablet(context)) return 0.85;
    return 1.5;
  }

  static double tabletSizeMultiplier(BuildContext context) =>
      isTablet(context) ? 0.85 : 1.0;

  static double getResponsiveSize(
    BuildContext context,
    double mobileSize,
    double tabletSize,
    double desktopSize,
  ) {
    if (isMobile(context)) return mobileSize;
    if (isTablet(context)) return tabletSize * tabletSizeMultiplier(context);
    return desktopSize;
  }

  static double getResponsiveTextSize(
    BuildContext context,
    double mobileSize,
    double tabletSize,
    double desktopSize,
  ) {
    if (isMobile(context)) return mobileSize;
    if (isTablet(context)) return tabletSize;
    return desktopSize;
  }

  // ═══════════════════════════════════════════════════════════
  //  LIGHT THEME — Aurora Soft
  // ═══════════════════════════════════════════════════════════
  static ThemeData light(BuildContext context) => ThemeData(
    useMaterial3: true,
    visualDensity: visualDensity,
    primaryColor: MyColor.primary,
    scaffoldBackgroundColor: MyColor.surface,
    cardColor: MyColor.surfaceContainer,

    iconTheme: IconThemeData(
      color: MyColor.onSurfaceVariant,
      size: getResponsiveSize(context, 20.w, 16.w, 24.w),
    ),

    appBarTheme: AppBarTheme(
      elevation: 0,
      centerTitle: isTablet(context),
      titleSpacing: getResponsiveSize(context, 16.w, 12.w, 24.w),
      backgroundColor: MyColor.surfaceContainerLowest,
      surfaceTintColor: Colors.transparent,
      iconTheme: IconThemeData(
        color: MyColor.onSurfaceVariant,
        size: getResponsiveSize(context, 20.w, 16.w, 24.w),
      ),
      titleTextStyle: TextStyle(
        color: MyColor.onSurface,
        fontSize: getResponsiveTextSize(context, 16.sp, 15.sp, 18.sp),
        fontFamily: MyString.poppinsMedium,
        fontWeight: FontWeight.w600,
      ),
      toolbarHeight: getResponsiveSize(context, 56.h, 75.h, 64.h),
    ),

    colorScheme: const ColorScheme(
      brightness: Brightness.light,
      // Primary — Teal Mint
      primary: MyColor.primary,
      onPrimary: MyColor.onPrimary,
      primaryContainer: MyColor.primaryContainer,
      onPrimaryContainer: MyColor.onPrimaryContainer,
      // Secondary — Lavender
      secondary: MyColor.secondary,
      onSecondary: MyColor.onSecondary,
      secondaryContainer: MyColor.secondaryContainer,
      onSecondaryContainer: MyColor.onSecondaryContainer,
      // Tertiary — Blush Pink
      tertiary: MyColor.tertiary,
      onTertiary: MyColor.onTertiary,
      tertiaryContainer: MyColor.tertiaryContainer,
      onTertiaryContainer: MyColor.onTertiaryContainer,
      // Error
      error: MyColor.error,
      onError: MyColor.onPrimary,
      errorContainer: MyColor.errorContainer,
      onErrorContainer: MyColor.onErrorContainer,
      // Surface
      surface: MyColor.surface,
      onSurface: MyColor.onSurface,
      surfaceContainerHighest: MyColor.surfaceContainerHighest,
      onSurfaceVariant: MyColor.onSurfaceVariant,
      // Outline
      outline: MyColor.outline,
      outlineVariant: MyColor.outlineVariant,
      // Misc
      shadow: MyColor.black,
      scrim: MyColor.black,
      inverseSurface: MyColor.darkSurface,
      onInverseSurface: MyColor.darkOnSurface,
      inversePrimary: MyColor.primaryFixedDim,
      surfaceTint: MyColor.primary,
    ),

    textTheme: _buildTextTheme(context, isDark: false),
    inputDecorationTheme: _buildInputDecoration(context, isDark: false),
    elevatedButtonTheme: _buildElevatedButton(context),
    outlinedButtonTheme: _buildOutlinedButton(context, isDark: false),
    textButtonTheme: _buildTextButton(context),
    chipTheme: _buildChipTheme(context, isDark: false),
    dividerTheme: DividerThemeData(
      color: MyColor.outlineVariant,
      thickness: 1.0.w * tabletSizeMultiplier(context),
      space: 1.0.h * responsiveSpacing(context),
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: MyColor.surfaceContainerLowest,
      selectedItemColor: MyColor.primary,
      unselectedItemColor: MyColor.outline,
      type: BottomNavigationBarType.fixed,
      elevation: 0,
    ),
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: MyColor.surfaceContainerLowest,
      indicatorColor: MyColor.primaryContainer,
      iconTheme: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return const IconThemeData(color: MyColor.onPrimaryContainer);
        }
        return const IconThemeData(color: MyColor.outline);
      }),
      labelTextStyle: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return const TextStyle(
            color: MyColor.primary,
            fontWeight: FontWeight.w600,
            fontSize: 12,
          );
        }
        return const TextStyle(color: MyColor.outline, fontSize: 12);
      }),
    ),
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: MyColor.primary,
      foregroundColor: MyColor.onPrimary,
      elevation: 2,
    ),
  );

  // ═══════════════════════════════════════════════════════════
  //  DARK THEME — Aurora Soft Night
  // ═══════════════════════════════════════════════════════════
  static ThemeData dark(BuildContext context) => ThemeData.dark().copyWith(
    visualDensity: visualDensity,
    primaryColor: MyColor.primary,
    scaffoldBackgroundColor: MyColor.darkSurface,
    cardColor: MyColor.darkSurfaceContainerHigh,

    iconTheme: IconThemeData(
      color: MyColor.darkOnSurfaceVariant,
      size: getResponsiveSize(context, 20.w, 16.w, 24.w),
    ),

    appBarTheme: AppBarTheme(
      elevation: 0,
      centerTitle: isTablet(context),
      backgroundColor: MyColor.darkSurfaceContainerLow,
      surfaceTintColor: Colors.transparent,
      iconTheme: IconThemeData(
        color: MyColor.darkOnSurfaceVariant,
        size: getResponsiveSize(context, 20.w, 16.w, 24.w),
      ),
      titleTextStyle: TextStyle(
        color: MyColor.darkOnSurface,
        fontSize: getResponsiveTextSize(context, 16.sp, 15.sp, 18.sp),
        fontFamily: MyString.poppinsMedium,
        fontWeight: FontWeight.w600,
      ),
      toolbarHeight: getResponsiveSize(context, 56.h, 75.h, 64.h),
    ),

    colorScheme: const ColorScheme(
      brightness: Brightness.dark,
      // Primary — Teal Mint (same hue, dark-adapted)
      primary: MyColor.primary,
      onPrimary: MyColor.gray900,
      primaryContainer: MyColor.onPrimaryFixed,   // #00352A deep teal
      onPrimaryContainer: MyColor.primaryFixed,   // #CCF5EC mint cream
      // Secondary — Lavender
      secondary: MyColor.secondaryFixedDim,       // muted lavender
      onSecondary: MyColor.gray900,
      secondaryContainer: MyColor.onSecondaryFixed, // #3A1A72 deep purple
      onSecondaryContainer: MyColor.secondaryFixed, // #F0EAFF
      // Tertiary — Blush Pink
      tertiary: MyColor.tertiary,
      onTertiary: MyColor.gray900,
      tertiaryContainer: MyColor.onTertiaryContainer, // #3D0020
      onTertiaryContainer: MyColor.tertiaryContainer, // #FFD6E2
      // Error
      error: MyColor.darkError,
      onError: MyColor.gray900,
      errorContainer: MyColor.darkErrorContainer,
      onErrorContainer: MyColor.darkOnErrorContainer,
      // Surface
      surface: MyColor.darkSurface,
      onSurface: MyColor.darkOnSurface,
      surfaceContainerHighest: MyColor.darkSurfaceContainerHighest,
      onSurfaceVariant: MyColor.darkOnSurfaceVariant,
      // Outline
      outline: MyColor.darkOutline,
      outlineVariant: MyColor.darkOutlineVariant,
      // Misc
      shadow: MyColor.black,
      scrim: MyColor.black,
      inverseSurface: MyColor.surface,
      onInverseSurface: MyColor.onSurface,
      inversePrimary: MyColor.onPrimaryFixed,
      surfaceTint: MyColor.primary,
    ),

    textTheme: _buildTextTheme(context, isDark: true),
    inputDecorationTheme: _buildInputDecoration(context, isDark: true),
    elevatedButtonTheme: _buildElevatedButton(context),
    outlinedButtonTheme: _buildOutlinedButton(context, isDark: true),
    textButtonTheme: _buildTextButton(context),
    chipTheme: _buildChipTheme(context, isDark: true),
    dividerTheme: DividerThemeData(
      color: MyColor.darkOutlineVariant,
      thickness: 1.0.w * tabletSizeMultiplier(context),
      space: 1.0.h * responsiveSpacing(context),
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: MyColor.darkSurfaceContainerLow,
      selectedItemColor: MyColor.primary,
      unselectedItemColor: MyColor.darkOutline,
      type: BottomNavigationBarType.fixed,
      elevation: 0,
    ),
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: MyColor.darkSurfaceContainerLow,
      indicatorColor: MyColor.onPrimaryFixed,
      iconTheme: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return const IconThemeData(color: MyColor.primaryFixed);
        }
        return const IconThemeData(color: MyColor.darkOutline);
      }),
      labelTextStyle: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return const TextStyle(
            color: MyColor.primary,
            fontWeight: FontWeight.w600,
            fontSize: 12,
          );
        }
        return const TextStyle(color: MyColor.darkOutline, fontSize: 12);
      }),
    ),
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: MyColor.primary,
      foregroundColor: MyColor.gray900,
      elevation: 2,
    ),
  );

  // ═══════════════════════════════════════════════════════════
  //  SHARED BUILDERS
  // ═══════════════════════════════════════════════════════════

  static TextTheme _buildTextTheme(
    BuildContext context, {
    required bool isDark,
  }) {
    final Color high  = isDark ? MyColor.darkOnSurface       : MyColor.onSurface;
    final Color mid   = isDark ? MyColor.darkOnSurfaceVariant: MyColor.onSurfaceVariant;
    final Color muted = isDark ? MyColor.darkOutline          : MyColor.outline;
    final double ts   = responsiveTextScale(context);

    return TextTheme(
      displayLarge: TextStyle(
        color: high, fontFamily: MyString.poppinsMedium,
        fontSize: getResponsiveTextSize(context, 32.sp, 30.sp, 40.sp) * ts,
        fontWeight: FontWeight.w700,
      ),
      displayMedium: TextStyle(
        color: high, fontFamily: MyString.poppinsMedium,
        fontSize: getResponsiveTextSize(context, 28.sp, 26.sp, 36.sp) * ts,
        fontWeight: FontWeight.w600,
      ),
      displaySmall: TextStyle(
        color: high, fontFamily: MyString.poppinsMedium,
        fontSize: getResponsiveTextSize(context, 24.sp, 22.sp, 32.sp) * ts,
        fontWeight: FontWeight.w600,
      ),
      titleLarge: TextStyle(
        color: high, fontFamily: MyString.poppinsMedium,
        fontSize: getResponsiveTextSize(context, 20.sp, 19.sp, 24.sp) * ts,
        fontWeight: FontWeight.w600,
      ),
      titleMedium: TextStyle(
        color: high, fontFamily: MyString.poppinsMedium,
        fontSize: getResponsiveTextSize(context, 16.sp, 15.sp, 18.sp) * ts,
        fontWeight: FontWeight.w500,
      ),
      titleSmall: TextStyle(
        color: mid, fontFamily: MyString.poppinsRegular,
        fontSize: getResponsiveTextSize(context, 14.sp, 13.sp, 16.sp) * ts,
        fontWeight: FontWeight.w400,
      ),
      bodyLarge: TextStyle(
        color: high, fontFamily: MyString.rubikRegular,
        fontSize: getResponsiveTextSize(context, 16.sp, 15.sp, 18.sp) * ts,
        fontWeight: FontWeight.w400,
      ),
      bodyMedium: TextStyle(
        color: high, fontFamily: MyString.rubikRegular,
        fontSize: getResponsiveTextSize(context, 14.sp, 13.sp, 16.sp) * ts,
        fontWeight: FontWeight.w400,
      ),
      bodySmall: TextStyle(
        color: mid, fontFamily: MyString.rubikRegular,
        fontSize: getResponsiveTextSize(context, 10.sp, 9.5.sp, 12.sp) * ts,
        fontWeight: FontWeight.w400,
      ),
      labelLarge: TextStyle(
        color: mid, fontFamily: MyString.poppinsMedium,
        fontSize: getResponsiveTextSize(context, 14.sp, 13.sp, 16.sp) * ts,
        fontWeight: FontWeight.w500,
      ),
      labelMedium: TextStyle(
        color: mid, fontFamily: MyString.poppinsRegular,
        fontSize: getResponsiveTextSize(context, 12.sp, 11.sp, 14.sp) * ts,
        fontWeight: FontWeight.w400,
      ),
      labelSmall: TextStyle(
        color: muted, fontFamily: MyString.poppinsRegular,
        fontSize: getResponsiveTextSize(context, 10.sp, 9.5.sp, 12.sp) * ts,
        fontWeight: FontWeight.w400,
      ),
    );
  }

  static InputDecorationTheme _buildInputDecoration(
    BuildContext context, {
    required bool isDark,
  }) {
    final double ts  = responsiveTextScale(context);
    final double sp  = responsiveSpacing(context);
    final double tm  = tabletSizeMultiplier(context);
    final Color hintColor  = isDark ? MyColor.darkOutline       : MyColor.outline;
    final Color labelColor = isDark ? MyColor.darkOnSurfaceVariant : MyColor.onSurfaceVariant;
    final Color fillColor  = isDark ? MyColor.darkSurfaceContainerHigh : MyColor.surfaceContainerLowest;
    final Color borderColor= isDark ? MyColor.darkOutlineVariant: MyColor.outlineVariant;
    final Color errColor   = isDark ? MyColor.darkError         : MyColor.error;

    return InputDecorationTheme(
      isDense: true,
      filled: true,
      fillColor: fillColor,
      prefixIconColor: isDark ? MyColor.darkOutline : MyColor.outline,
      labelStyle: TextStyle(
        fontSize: getResponsiveTextSize(context, 14.sp, 13.sp, 16.sp) * ts,
        color: labelColor, fontWeight: FontWeight.w400,
      ),
      hintStyle: TextStyle(
        fontSize: getResponsiveTextSize(context, 14.sp, 13.sp, 16.sp) * ts,
        color: hintColor, letterSpacing: 1.2, fontWeight: FontWeight.w400,
      ),
      contentPadding: EdgeInsets.symmetric(
        vertical: 10.h * sp, horizontal: 18.w * sp,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(8.r * tm)),
        borderSide: BorderSide(color: MyColor.primary, width: 1.5.w * tm),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(8.r * tm)),
        borderSide: BorderSide(color: borderColor, width: 1.0.w * tm),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(8.r * tm)),
        borderSide: BorderSide(color: errColor, width: 1.5.w * tm),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(8.r * tm)),
        borderSide: BorderSide(color: errColor, width: 1.5.w * tm),
      ),
    );
  }

  static ElevatedButtonThemeData _buildElevatedButton(BuildContext context) {
    final double ts = responsiveTextScale(context);
    final double sp = responsiveSpacing(context);
    final double tm = tabletSizeMultiplier(context);
    return ElevatedButtonThemeData(
      style: ButtonStyle(
        backgroundColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.disabled)) return MyColor.gray300;
          return MyColor.primary;
        }),
        foregroundColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.disabled)) return MyColor.gray500;
          return MyColor.onPrimary;
        }),
        overlayColor: WidgetStateProperty.all(MyColor.onPrimary.withOpacity(0.12)),
        shape: WidgetStateProperty.all(RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.r * tm),
        )),
        padding: WidgetStateProperty.all(EdgeInsets.symmetric(
          vertical: 16.h * sp, horizontal: 24.w * sp,
        )),
        textStyle: WidgetStateProperty.all(TextStyle(
          fontSize: getResponsiveTextSize(context, 16.sp, 15.sp, 18.sp) * ts,
          fontFamily: MyString.poppinsMedium,
          fontWeight: FontWeight.w600,
        )),
        elevation: WidgetStateProperty.all(0),
        minimumSize: WidgetStateProperty.all(Size(
          getResponsiveSize(context, 100.w, 85.w, 120.w),
          getResponsiveSize(context, 44.h, 40.h, 52.h),
        )),
      ),
    );
  }

  static OutlinedButtonThemeData _buildOutlinedButton(
    BuildContext context, {
    required bool isDark,
  }) {
    final double ts = responsiveTextScale(context);
    final double sp = responsiveSpacing(context);
    final double tm = tabletSizeMultiplier(context);
    final Color borderCol = isDark ? MyColor.darkOutlineVariant : MyColor.outlineVariant;
    return OutlinedButtonThemeData(
      style: ButtonStyle(
        foregroundColor: WidgetStateProperty.all(MyColor.primary),
        side: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.focused)) {
            return BorderSide(color: MyColor.primary, width: 1.5.w * tm);
          }
          return BorderSide(color: borderCol, width: 1.0.w * tm);
        }),
        shape: WidgetStateProperty.all(RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.r * tm),
        )),
        padding: WidgetStateProperty.all(EdgeInsets.symmetric(
          vertical: 14.h * sp, horizontal: 22.w * sp,
        )),
        textStyle: WidgetStateProperty.all(TextStyle(
          fontSize: getResponsiveTextSize(context, 15.sp, 14.sp, 17.sp) * ts,
          fontFamily: MyString.poppinsMedium,
          fontWeight: FontWeight.w500,
        )),
        minimumSize: WidgetStateProperty.all(Size(
          getResponsiveSize(context, 100.w, 85.w, 120.w),
          getResponsiveSize(context, 44.h, 40.h, 52.h),
        )),
      ),
    );
  }

  static TextButtonThemeData _buildTextButton(BuildContext context) {
    final double ts = responsiveTextScale(context);
    final double sp = responsiveSpacing(context);
    return TextButtonThemeData(
      style: ButtonStyle(
        foregroundColor: WidgetStateProperty.all(MyColor.secondary),
        overlayColor: WidgetStateProperty.all(MyColor.secondary.withOpacity(0.08)),
        textStyle: WidgetStateProperty.all(TextStyle(
          fontSize: getResponsiveTextSize(context, 14.sp, 13.sp, 16.sp) * ts,
          fontFamily: MyString.poppinsMedium,
          fontWeight: FontWeight.w500,
        )),
        padding: WidgetStateProperty.all(EdgeInsets.symmetric(
          vertical: 8.h * sp, horizontal: 16.w * sp,
        )),
      ),
    );
  }

  static ChipThemeData _buildChipTheme(
    BuildContext context, {
    required bool isDark,
  }) {
    return ChipThemeData(
      backgroundColor: isDark
          ? MyColor.darkSurfaceContainerHigh
          : MyColor.surfaceContainerLow,
      selectedColor: isDark
          ? MyColor.onPrimaryFixed
          : MyColor.primaryContainer,
      labelStyle: TextStyle(
        fontSize: 12.sp,
        color: isDark ? MyColor.darkOnSurface : MyColor.onSurface,
        fontFamily: MyString.poppinsRegular,
      ),
      secondaryLabelStyle: TextStyle(
        fontSize: 12.sp,
        color: MyColor.onPrimaryContainer,
        fontFamily: MyString.poppinsRegular,
      ),
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20.r),
        side: BorderSide(
          color: isDark ? MyColor.darkOutlineVariant : MyColor.outlineVariant,
          width: 0.5,
        ),
      ),
      elevation: 0,
      pressElevation: 0,
    );
  }
}