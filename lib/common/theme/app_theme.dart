import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:emababyspa/common/theme/text_theme.dart';
import 'package:emababyspa/common/theme/color_theme.dart';

class AppTheme {
  static const double _defaultRadius = 16.0;
  static const double _buttonRadius = 12.0;

  // --- LIGHT THEME ---
  static final ThemeData lightTheme = ThemeData(
    brightness: Brightness.light,
    useMaterial3: true,
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

    appBarTheme: AppBarTheme(
      backgroundColor: ColorTheme.m3Surface,
      foregroundColor: ColorTheme.m3OnSurface,
      elevation: 0,
      centerTitle: true,
      scrolledUnderElevation: 2,
      systemOverlayStyle: SystemUiOverlayStyle.dark,
      titleTextStyle: TextThemes.textTheme.titleLarge?.copyWith(
        color: ColorTheme.m3OnSurface,
        fontWeight: FontWeight.bold,
        fontSize: 20,
      ),
      iconTheme: const IconThemeData(color: ColorTheme.m3OnSurface),
    ),

    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: ColorTheme.m3Primary,
        foregroundColor: ColorTheme.m3OnPrimary,
        elevation: 2,
        shadowColor: ColorTheme.m3Primary.withOpacity(0.4),
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(_buttonRadius),
        ),
        textStyle: const TextStyle(
          fontFamily: 'JosefinSans',
          fontWeight: FontWeight.w600,
          fontSize: 16,
          letterSpacing: 0.5,
        ),
      ),
    ),

    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: ColorTheme.m3Primary,
        side: const BorderSide(color: ColorTheme.m3OutlineVariant, width: 1.5),
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(_buttonRadius),
        ),
        textStyle: const TextStyle(
          fontFamily: 'JosefinSans',
          fontWeight: FontWeight.w600,
          fontSize: 16,
        ),
      ),
    ),

    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: ColorTheme.m3Primary,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      ),
    ),

    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: ColorTheme.m3SurfaceVariant.withOpacity(0.3),
      contentPadding: const EdgeInsets.symmetric(vertical: 18, horizontal: 20),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(_defaultRadius),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(_defaultRadius),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(_defaultRadius),
        borderSide: const BorderSide(color: ColorTheme.m3Primary, width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(_defaultRadius),
        borderSide: const BorderSide(color: ColorTheme.m3Error),
      ),
      labelStyle: const TextStyle(color: ColorTheme.m3OnSurfaceVariant),
      hintStyle: TextStyle(
        color: ColorTheme.m3OnSurfaceVariant.withOpacity(0.7),
      ),
      prefixIconColor: ColorTheme.m3OnSurfaceVariant,
      suffixIconColor: ColorTheme.m3OnSurfaceVariant,
    ),

    cardTheme: CardThemeData(
      color: ColorTheme.m3Surface,
      surfaceTintColor: ColorTheme.m3Primary,
      elevation: 2,
      shadowColor: Colors.black.withOpacity(0.1),
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(_defaultRadius),
      ),
      clipBehavior: Clip.antiAlias,
    ),

    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: ColorTheme.m3Surface,
      selectedItemColor: ColorTheme.m3Primary,
      unselectedItemColor: ColorTheme.m3Outline,
      selectedLabelStyle: TextStyle(fontWeight: FontWeight.w600, fontSize: 12),
      unselectedLabelStyle: TextStyle(
        fontWeight: FontWeight.w500,
        fontSize: 12,
      ),
      type: BottomNavigationBarType.fixed,
      elevation: 8,
    ),

    dividerTheme: const DividerThemeData(
      color: ColorTheme.m3OutlineVariant,
      thickness: 1,
      space: 1,
    ),

    dialogTheme: DialogThemeData(
      backgroundColor: ColorTheme.m3Surface,
      surfaceTintColor: ColorTheme.m3Primary,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      titleTextStyle: TextThemes.textTheme.titleLarge?.copyWith(
        fontWeight: FontWeight.bold,
        color: ColorTheme.m3OnSurface,
      ),
    ),

    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: ColorTheme.m3PrimaryContainer,
      foregroundColor: ColorTheme.m3OnPrimaryContainer,
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    ),

    checkboxTheme: CheckboxThemeData(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
      fillColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) return ColorTheme.m3Primary;
        return null;
      }),
    ),
  );

  // --- DARK THEME ---
  static final ThemeData darkTheme = ThemeData(
    brightness: Brightness.dark,
    useMaterial3: true,
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
      error: ColorTheme.m3ErrorDark,
      onError: ColorTheme.m3OnErrorDark,
      surface: ColorTheme.m3SurfaceDark,
      onSurface: ColorTheme.m3OnSurfaceDark,
      surfaceContainerHighest: ColorTheme.m3SurfaceVariantDark,
      onSurfaceVariant: ColorTheme.m3OnSurfaceVariantDark,
      outline: ColorTheme.m3OutlineDark,
    ),

    scaffoldBackgroundColor: ColorTheme.m3BackgroundDark,
    textTheme: TextThemes.darkTextTheme, // Sudah berisi teks terang

    appBarTheme: AppBarTheme(
      backgroundColor: ColorTheme.m3SurfaceDark,
      foregroundColor: ColorTheme.m3OnSurfaceDark,
      elevation: 0,
      centerTitle: true,
      scrolledUnderElevation: 2,
      systemOverlayStyle: SystemUiOverlayStyle.light,
      titleTextStyle: TextThemes.darkTextTheme.titleLarge?.copyWith(
        color: ColorTheme.m3OnSurfaceDark,
        fontWeight: FontWeight.bold,
        fontSize: 20,
      ),
    ),

    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: ColorTheme.m3PrimaryDark,
        foregroundColor: ColorTheme.m3OnPrimaryDark,
        elevation: 0,
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(_buttonRadius),
        ),
        textStyle: const TextStyle(
          fontFamily: 'JosefinSans',
          fontWeight: FontWeight.w600,
          fontSize: 16,
        ),
      ),
    ),

    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: ColorTheme.m3PrimaryDark,
        side: const BorderSide(color: ColorTheme.m3OutlineDark),
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(_buttonRadius),
        ),
      ),
    ),

    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: ColorTheme.m3SurfaceVariantDark.withOpacity(0.2),
      contentPadding: const EdgeInsets.symmetric(vertical: 18, horizontal: 20),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(_defaultRadius),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(_defaultRadius),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(_defaultRadius),
        borderSide: const BorderSide(
          color: ColorTheme.m3PrimaryDark,
          width: 1.5,
        ),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(_defaultRadius),
        borderSide: const BorderSide(color: ColorTheme.m3ErrorDark),
      ),
      labelStyle: const TextStyle(color: ColorTheme.m3OnSurfaceVariantDark),
      hintStyle: TextStyle(
        color: ColorTheme.m3OnSurfaceVariantDark.withOpacity(
          0.8,
        ), // Lebih terang
      ),
      prefixIconColor: ColorTheme.m3OnSurfaceVariantDark,
      suffixIconColor: ColorTheme.m3OnSurfaceVariantDark,
    ),

    cardTheme: CardThemeData(
      color: ColorTheme.m3SurfaceVariantDark.withOpacity(0.3),
      elevation: 0,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(_defaultRadius),
        side: BorderSide(color: ColorTheme.m3OutlineDark.withOpacity(0.2)),
      ),
    ),

    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: ColorTheme.m3SurfaceDark,
      selectedItemColor: ColorTheme.m3PrimaryDark,
      unselectedItemColor: ColorTheme.m3OnSurfaceVariantDark,
      type: BottomNavigationBarType.fixed,
    ),

    dialogTheme: DialogThemeData(
      backgroundColor: ColorTheme.m3SurfaceContainerDark,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
    ),
  );
}
