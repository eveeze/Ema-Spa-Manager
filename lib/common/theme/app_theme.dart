// lib/common/theme/app_theme.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:emababyspa/common/theme/text_theme.dart';
import 'package:emababyspa/common/theme/color_theme.dart';
import 'package:emababyspa/common/theme/semantic_colors.dart';

/// Global spacing tokens (biar layout antar page konsisten).
@immutable
class AppSpacing extends ThemeExtension<AppSpacing> {
  final double xxs;
  final double xs;
  final double sm;
  final double md;
  final double lg;
  final double xl;
  final double xxl;

  const AppSpacing({
    this.xxs = 6,
    this.xs = 10,
    this.sm = 14,
    this.md = 16,
    this.lg = 24,
    this.xl = 32,
    this.xxl = 44,
  });

  @override
  AppSpacing copyWith({
    double? xxs,
    double? xs,
    double? sm,
    double? md,
    double? lg,
    double? xl,
    double? xxl,
  }) {
    return AppSpacing(
      xxs: xxs ?? this.xxs,
      xs: xs ?? this.xs,
      sm: sm ?? this.sm,
      md: md ?? this.md,
      lg: lg ?? this.lg,
      xl: xl ?? this.xl,
      xxl: xxl ?? this.xxl,
    );
  }

  @override
  AppSpacing lerp(ThemeExtension<AppSpacing>? other, double t) {
    if (other is! AppSpacing) return this;
    return AppSpacing(
      xxs: _lerpDouble(xxs, other.xxs, t),
      xs: _lerpDouble(xs, other.xs, t),
      sm: _lerpDouble(sm, other.sm, t),
      md: _lerpDouble(md, other.md, t),
      lg: _lerpDouble(lg, other.lg, t),
      xl: _lerpDouble(xl, other.xl, t),
      xxl: _lerpDouble(xxl, other.xxl, t),
    );
  }

  double _lerpDouble(double a, double b, double t) => a + (b - a) * t;
}

/// Radius system (biar bentuk UI konsisten dan terasa modern).
class AppRadii {
  static const double sm = 12;
  static const double md = 16;
  static const double lg = 20;
  static const double xl = 28;
}

/// Shadow yang “diffused” (lebih spa, less corporate).
class AppShadows {
  static List<BoxShadow> soft(Color c) => [
    BoxShadow(
      color: c.withValues(alpha: 0.08),
      blurRadius: 20,
      spreadRadius: 0,
      offset: const Offset(0, 10),
    ),
    BoxShadow(
      color: c.withValues(alpha: 0.05),
      blurRadius: 8,
      spreadRadius: 0,
      offset: const Offset(0, 3),
    ),
  ];
}

class AppTheme {
  // ---------- LIGHT ----------
  static ThemeData lightTheme = ThemeData(
    brightness: Brightness.light,
    useMaterial3: true,

    splashFactory: InkSparkle.splashFactory,
    pageTransitionsTheme: const PageTransitionsTheme(
      builders: {
        TargetPlatform.android: CupertinoPageTransitionsBuilder(),
        TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
      },
    ),

    fontFamily: 'JosefinSans',

    colorScheme: const ColorScheme.light(
      primary: ColorTheme.m3Primary,
      onPrimary: ColorTheme.m3OnPrimary,
      primaryContainer: ColorTheme.m3PrimaryContainer,
      onPrimaryContainer: ColorTheme.m3OnPrimaryContainer,
      secondary: ColorTheme.m3Secondary,
      onSecondary: ColorTheme.m3OnSecondary,
      secondaryContainer: ColorTheme.m3SecondaryContainer,
      onSecondaryContainer: ColorTheme.m3OnSecondaryContainer,

      // ✅ NEW (aman): pink accent halus
      tertiary: ColorTheme.m3Tertiary,
      onTertiary: ColorTheme.m3OnTertiary,
      tertiaryContainer: ColorTheme.m3TertiaryContainer,
      onTertiaryContainer: ColorTheme.m3OnTertiaryContainer,

      error: ColorTheme.m3Error,
      onError: ColorTheme.m3OnError,
      errorContainer: ColorTheme.m3ErrorContainer,
      onErrorContainer: ColorTheme.m3OnErrorContainer,
      surface: ColorTheme.m3Surface,
      onSurface: ColorTheme.m3OnSurface,
      surfaceContainerHighest: ColorTheme.m3SurfaceVariant,
      onSurfaceVariant: ColorTheme.m3OnSurfaceVariant,
      outline: ColorTheme.m3Outline,
      outlineVariant: ColorTheme.m3OutlineVariant,
    ),

    scaffoldBackgroundColor: ColorTheme.m3Background,

    textTheme: TextThemes.textTheme.apply(
      bodyColor: ColorTheme.m3OnSurface,
      displayColor: ColorTheme.m3OnSurface,
    ),

    extensions: const [
      AppSpacing(),
      AppSemanticColors(
        revenue: ColorTheme.m3Primary,
        success: ColorTheme.success,
        warning: ColorTheme.warning,
        info: ColorTheme.m3Secondary,
        danger: ColorTheme.m3Error,
      ),
    ],

    appBarTheme: AppBarTheme(
      backgroundColor: ColorTheme.m3Surface,
      foregroundColor: ColorTheme.m3OnSurface,
      elevation: 0,
      centerTitle: true,
      scrolledUnderElevation: 1.5,
      systemOverlayStyle: SystemUiOverlayStyle.dark,
      titleTextStyle: TextThemes.textTheme.titleLarge?.copyWith(
        fontWeight: FontWeight.w700,
        fontSize: 19,
        letterSpacing: 0.1,
      ),
      iconTheme: const IconThemeData(color: ColorTheme.m3OnSurface),
    ),

    dividerTheme: const DividerThemeData(
      color: ColorTheme.m3OutlineVariant,
      thickness: 1,
      space: 1,
    ),

    cardTheme: CardThemeData(
      color: ColorTheme.m3Surface,
      elevation: 1.5,
      shadowColor: Colors.black.withValues(alpha: 0.10),
      surfaceTintColor: Colors.transparent,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadii.lg),
        side: BorderSide(
          color: ColorTheme.m3OutlineVariant.withValues(alpha: 0.55),
          width: 1,
        ),
      ),
      clipBehavior: Clip.antiAlias,
    ),

    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      backgroundColor: ColorTheme.m3Surface,
      selectedItemColor: ColorTheme.m3Primary,
      unselectedItemColor: ColorTheme.m3OnSurfaceVariant.withValues(
        alpha: 0.70,
      ),
      selectedLabelStyle: const TextStyle(
        fontWeight: FontWeight.w700,
        fontSize: 12,
      ),
      unselectedLabelStyle: const TextStyle(
        fontWeight: FontWeight.w600,
        fontSize: 12,
      ),
      type: BottomNavigationBarType.fixed,
      elevation: 10,
    ),

    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: ColorTheme.m3PrimaryContainer,
      foregroundColor: ColorTheme.m3OnPrimaryContainer,
      elevation: 6,
      highlightElevation: 10,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadii.lg),
      ),
    ),

    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ButtonStyle(
        padding: const WidgetStatePropertyAll(
          EdgeInsets.symmetric(vertical: 16, horizontal: 18),
        ),
        minimumSize: const WidgetStatePropertyAll(Size(0, 52)),
        shape: WidgetStatePropertyAll(
          RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadii.md),
          ),
        ),
        backgroundColor: const WidgetStatePropertyAll(ColorTheme.m3Primary),
        foregroundColor: const WidgetStatePropertyAll(ColorTheme.m3OnPrimary),
        textStyle: WidgetStatePropertyAll(
          TextThemes.textTheme.labelLarge?.copyWith(
            fontWeight: FontWeight.w700,
            letterSpacing: 0.2,
          ),
        ),
        elevation: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.disabled)) return 0;
          if (states.contains(WidgetState.pressed)) return 0;
          return 2;
        }),
        shadowColor: WidgetStatePropertyAll(
          ColorTheme.m3Primary.withValues(alpha: 0.25),
        ),
        overlayColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.pressed)) {
            return ColorTheme.m3OnPrimary.withValues(alpha: 0.10);
          }
          if (states.contains(WidgetState.hovered) ||
              states.contains(WidgetState.focused)) {
            return ColorTheme.m3OnPrimary.withValues(alpha: 0.06);
          }
          return null;
        }),
      ),
    ),

    outlinedButtonTheme: OutlinedButtonThemeData(
      style: ButtonStyle(
        padding: const WidgetStatePropertyAll(
          EdgeInsets.symmetric(vertical: 16, horizontal: 18),
        ),
        minimumSize: const WidgetStatePropertyAll(Size(0, 52)),
        shape: WidgetStatePropertyAll(
          RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadii.md),
          ),
        ),
        foregroundColor: const WidgetStatePropertyAll(ColorTheme.m3Primary),
        side: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.pressed)) {
            return BorderSide(
              color: ColorTheme.m3Primary.withValues(alpha: 0.75),
              width: 1.5,
            );
          }
          return BorderSide(
            color: ColorTheme.m3OutlineVariant.withValues(alpha: 0.95),
            width: 1.25,
          );
        }),
        textStyle: WidgetStatePropertyAll(
          TextThemes.textTheme.labelLarge?.copyWith(
            fontWeight: FontWeight.w700,
            letterSpacing: 0.2,
          ),
        ),
        overlayColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.pressed)) {
            return ColorTheme.m3Primary.withValues(alpha: 0.10);
          }
          if (states.contains(WidgetState.hovered) ||
              states.contains(WidgetState.focused)) {
            return ColorTheme.m3Primary.withValues(alpha: 0.06);
          }
          return null;
        }),
      ),
    ),

    textButtonTheme: TextButtonThemeData(
      style: ButtonStyle(
        padding: const WidgetStatePropertyAll(
          EdgeInsets.symmetric(vertical: 10, horizontal: 14),
        ),
        shape: WidgetStatePropertyAll(
          RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadii.sm),
          ),
        ),
        foregroundColor: const WidgetStatePropertyAll(ColorTheme.m3Primary),
        textStyle: WidgetStatePropertyAll(
          TextThemes.textTheme.labelLarge?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
        overlayColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.pressed)) {
            return ColorTheme.m3Primary.withValues(alpha: 0.10);
          }
          if (states.contains(WidgetState.hovered) ||
              states.contains(WidgetState.focused)) {
            return ColorTheme.m3Primary.withValues(alpha: 0.06);
          }
          return null;
        }),
      ),
    ),

    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: ColorTheme.m3SurfaceVariant.withValues(alpha: 0.28),
      contentPadding: const EdgeInsets.symmetric(vertical: 18, horizontal: 16),
      floatingLabelBehavior: FloatingLabelBehavior.auto,
      isDense: false,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadii.lg),
        borderSide: BorderSide(
          color: ColorTheme.m3OutlineVariant.withValues(alpha: 0.55),
          width: 1,
        ),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadii.lg),
        borderSide: BorderSide(
          color: ColorTheme.m3OutlineVariant.withValues(alpha: 0.55),
          width: 1,
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadii.lg),
        borderSide: const BorderSide(color: ColorTheme.m3Primary, width: 1.6),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadii.lg),
        borderSide: const BorderSide(color: ColorTheme.m3Error, width: 1.4),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadii.lg),
        borderSide: const BorderSide(color: ColorTheme.m3Error, width: 1.6),
      ),
      labelStyle: TextThemes.textTheme.bodyMedium?.copyWith(
        color: ColorTheme.m3OnSurfaceVariant.withValues(alpha: 0.85),
        fontWeight: FontWeight.w600,
      ),
      hintStyle: TextThemes.textTheme.bodyMedium?.copyWith(
        color: ColorTheme.m3OnSurfaceVariant.withValues(alpha: 0.60),
        fontWeight: FontWeight.w500,
      ),
      prefixIconColor: ColorTheme.m3OnSurfaceVariant.withValues(alpha: 0.80),
      suffixIconColor: ColorTheme.m3OnSurfaceVariant.withValues(alpha: 0.80),
    ),

    dialogTheme: DialogThemeData(
      backgroundColor: ColorTheme.m3Surface,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadii.xl),
      ),
      titleTextStyle: TextThemes.textTheme.titleLarge?.copyWith(
        fontWeight: FontWeight.w800,
        color: ColorTheme.m3OnSurface,
      ),
      contentTextStyle: TextThemes.textTheme.bodyMedium?.copyWith(
        color: ColorTheme.m3OnSurfaceVariant.withValues(alpha: 0.90),
      ),
    ),

    listTileTheme: ListTileThemeData(
      iconColor: ColorTheme.m3OnSurfaceVariant.withValues(alpha: 0.85),
      textColor: ColorTheme.m3OnSurface,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadii.lg),
      ),
    ),

    snackBarTheme: SnackBarThemeData(
      behavior: SnackBarBehavior.floating,
      elevation: 6,
      backgroundColor: ColorTheme.m3OnSurface,
      contentTextStyle: TextThemes.textTheme.bodyMedium?.copyWith(
        color: ColorTheme.m3Surface,
        fontWeight: FontWeight.w600,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadii.lg),
      ),
    ),

    checkboxTheme: CheckboxThemeData(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
      fillColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) return ColorTheme.m3Primary;
        return null;
      }),
    ),
  );

  // ---------- DARK ----------
  static ThemeData darkTheme = ThemeData(
    brightness: Brightness.dark,
    useMaterial3: true,
    splashFactory: InkSparkle.splashFactory,
    pageTransitionsTheme: const PageTransitionsTheme(
      builders: {
        TargetPlatform.android: CupertinoPageTransitionsBuilder(),
        TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
      },
    ),
    fontFamily: 'JosefinSans',

    colorScheme: const ColorScheme.dark(
      primary: ColorTheme.m3PrimaryDark,
      onPrimary: ColorTheme.m3OnPrimaryDark,
      primaryContainer: ColorTheme.m3PrimaryContainerDark,
      onPrimaryContainer: ColorTheme.m3OnPrimaryContainerDark,
      secondary: ColorTheme.m3SecondaryDark,
      onSecondary: ColorTheme.m3OnSecondaryDark,
      secondaryContainer: ColorTheme.m3SecondaryContainerDark,
      onSecondaryContainer: ColorTheme.m3OnSecondaryContainerDark,

      // ✅ NEW (aman)
      tertiary: ColorTheme.m3TertiaryDark,
      onTertiary: ColorTheme.m3OnTertiaryDark,
      tertiaryContainer: ColorTheme.m3TertiaryContainerDark,
      onTertiaryContainer: ColorTheme.m3OnTertiaryContainerDark,

      error: ColorTheme.m3ErrorDark,
      onError: ColorTheme.m3OnErrorDark,
      surface: ColorTheme.m3SurfaceDark,
      onSurface: ColorTheme.m3OnSurfaceDark,
      surfaceContainerHighest: ColorTheme.m3SurfaceVariantDark,
      onSurfaceVariant: ColorTheme.m3OnSurfaceVariantDark,
      outline: ColorTheme.m3OutlineDark,
    ),

    scaffoldBackgroundColor: ColorTheme.m3BackgroundDark,
    textTheme: TextThemes.darkTextTheme,

    extensions: const [
      AppSpacing(),
      AppSemanticColors(
        revenue: ColorTheme.m3PrimaryDark,
        success: ColorTheme.successDark,
        warning: ColorTheme.warningDark,
        info: ColorTheme.m3SecondaryDark,
        danger: ColorTheme.m3ErrorDark,
      ),
    ],

    appBarTheme: AppBarTheme(
      backgroundColor: ColorTheme.m3SurfaceDark,
      foregroundColor: ColorTheme.m3OnSurfaceDark,
      elevation: 0,
      centerTitle: true,
      scrolledUnderElevation: 1.5,
      systemOverlayStyle: SystemUiOverlayStyle.light,
      titleTextStyle: TextThemes.darkTextTheme.titleLarge?.copyWith(
        fontWeight: FontWeight.w700,
        fontSize: 19,
        letterSpacing: 0.1,
      ),
    ),

    cardTheme: CardThemeData(
      color: ColorTheme.m3SurfaceVariantDark.withValues(alpha: 0.22),
      elevation: 0,
      surfaceTintColor: Colors.transparent,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadii.lg),
        side: BorderSide(
          color: ColorTheme.m3OutlineDark.withValues(alpha: 0.22),
          width: 1,
        ),
      ),
      clipBehavior: Clip.antiAlias,
    ),

    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      backgroundColor: ColorTheme.m3SurfaceDark,
      selectedItemColor: ColorTheme.m3PrimaryDark,
      unselectedItemColor: ColorTheme.m3OnSurfaceVariantDark.withValues(
        alpha: 0.70,
      ),
      type: BottomNavigationBarType.fixed,
      elevation: 10,
    ),

    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: ColorTheme.m3PrimaryContainerDark,
      foregroundColor: ColorTheme.m3OnPrimaryContainerDark,
      elevation: 6,
      highlightElevation: 10,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadii.lg),
      ),
    ),

    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ButtonStyle(
        padding: const WidgetStatePropertyAll(
          EdgeInsets.symmetric(vertical: 16, horizontal: 18),
        ),
        minimumSize: const WidgetStatePropertyAll(Size(0, 52)),
        shape: WidgetStatePropertyAll(
          RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadii.md),
          ),
        ),
        backgroundColor: const WidgetStatePropertyAll(ColorTheme.m3PrimaryDark),
        foregroundColor: const WidgetStatePropertyAll(
          ColorTheme.m3OnPrimaryDark,
        ),
        textStyle: WidgetStatePropertyAll(
          TextThemes.darkTextTheme.labelLarge?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
        elevation: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.disabled)) return 0;
          if (states.contains(WidgetState.pressed)) return 0;
          return 1;
        }),
        overlayColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.pressed)) {
            return ColorTheme.m3OnPrimaryContainerDark.withValues(alpha: 0.10);
          }
          if (states.contains(WidgetState.hovered) ||
              states.contains(WidgetState.focused)) {
            return ColorTheme.m3OnPrimaryContainerDark.withValues(alpha: 0.06);
          }
          return null;
        }),
      ),
    ),

    outlinedButtonTheme: OutlinedButtonThemeData(
      style: ButtonStyle(
        padding: const WidgetStatePropertyAll(
          EdgeInsets.symmetric(vertical: 16, horizontal: 18),
        ),
        minimumSize: const WidgetStatePropertyAll(Size(0, 52)),
        shape: WidgetStatePropertyAll(
          RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadii.md),
          ),
        ),
        foregroundColor: const WidgetStatePropertyAll(ColorTheme.m3PrimaryDark),
        side: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.pressed)) {
            return BorderSide(
              color: ColorTheme.m3PrimaryDark.withValues(alpha: 0.70),
              width: 1.5,
            );
          }
          return BorderSide(
            color: ColorTheme.m3OutlineDark.withValues(alpha: 0.55),
            width: 1.25,
          );
        }),
        textStyle: WidgetStatePropertyAll(
          TextThemes.darkTextTheme.labelLarge?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
        overlayColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.pressed)) {
            return ColorTheme.m3PrimaryDark.withValues(alpha: 0.12);
          }
          if (states.contains(WidgetState.hovered) ||
              states.contains(WidgetState.focused)) {
            return ColorTheme.m3PrimaryDark.withValues(alpha: 0.07);
          }
          return null;
        }),
      ),
    ),

    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: ColorTheme.m3SurfaceVariantDark.withValues(alpha: 0.22),
      contentPadding: const EdgeInsets.symmetric(vertical: 18, horizontal: 16),
      floatingLabelBehavior: FloatingLabelBehavior.auto,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadii.lg),
        borderSide: BorderSide(
          color: ColorTheme.m3OutlineDark.withValues(alpha: 0.35),
          width: 1,
        ),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadii.lg),
        borderSide: BorderSide(
          color: ColorTheme.m3OutlineDark.withValues(alpha: 0.35),
          width: 1,
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadii.lg),
        borderSide: const BorderSide(
          color: ColorTheme.m3PrimaryDark,
          width: 1.6,
        ),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadii.lg),
        borderSide: const BorderSide(color: ColorTheme.m3ErrorDark, width: 1.4),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadii.lg),
        borderSide: const BorderSide(color: ColorTheme.m3ErrorDark, width: 1.6),
      ),
      labelStyle: TextThemes.darkTextTheme.bodyMedium?.copyWith(
        color: ColorTheme.m3OnSurfaceVariantDark.withValues(alpha: 0.90),
        fontWeight: FontWeight.w600,
      ),
      hintStyle: TextThemes.darkTextTheme.bodyMedium?.copyWith(
        color: ColorTheme.m3OnSurfaceVariantDark.withValues(alpha: 0.65),
        fontWeight: FontWeight.w500,
      ),
      prefixIconColor: ColorTheme.m3OnSurfaceVariantDark.withValues(
        alpha: 0.80,
      ),
      suffixIconColor: ColorTheme.m3OnSurfaceVariantDark.withValues(
        alpha: 0.80,
      ),
    ),

    dialogTheme: DialogThemeData(
      backgroundColor: ColorTheme.m3SurfaceDark,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadii.xl),
      ),
    ),

    snackBarTheme: SnackBarThemeData(
      behavior: SnackBarBehavior.floating,
      elevation: 6,
      backgroundColor: ColorTheme.m3OnSurfaceDark,
      contentTextStyle: TextThemes.darkTextTheme.bodyMedium?.copyWith(
        color: ColorTheme.m3SurfaceDark,
        fontWeight: FontWeight.w600,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadii.lg),
      ),
    ),

    checkboxTheme: CheckboxThemeData(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
      fillColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return ColorTheme.m3PrimaryDark;
        }
        return null;
      }),
    ),
  );
}
