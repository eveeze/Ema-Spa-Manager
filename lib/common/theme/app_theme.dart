import 'package:flutter/material.dart';
import 'package:emababyspa/common/theme/text_theme.dart'; // Assuming TextThemes is correctly set up
import 'package:emababyspa/common/theme/color_theme.dart';

class AppTheme {
  // --- LIGHT THEME ---
  static final ThemeData lightTheme = ThemeData(
    brightness: Brightness.light,
    // Use the M3 ColorScheme for all core colors
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
    primaryColor: ColorTheme.m3Primary, // Legacy support
    scaffoldBackgroundColor: ColorTheme.m3Background,
    textTheme:
        TextThemes.textTheme, // Ensure this uses colors from the new scheme

    appBarTheme: AppBarTheme(
      backgroundColor: ColorTheme.m3Primary,
      foregroundColor: ColorTheme.m3OnPrimary, // Use OnPrimary for text/icons
      elevation: 0,
      titleTextStyle: TextThemes.textTheme.titleLarge?.copyWith(
        color: ColorTheme.m3OnPrimary, // Explicitly use OnPrimary
        fontWeight: FontWeight.bold,
      ),
    ),

    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: ColorTheme.m3Primary,
        foregroundColor: ColorTheme.m3OnPrimary, // Text color on the button
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    ),

    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: ColorTheme.m3Primary,
        side: const BorderSide(
          color: ColorTheme.m3Outline,
        ), // Use outline color for borders
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    ),

    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: ColorTheme.m3Primary,
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      ),
    ),

    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: ColorTheme.m3Surface, // Use surface color
      contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: ColorTheme.m3Outline),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: ColorTheme.m3Outline),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: ColorTheme.m3Primary, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: ColorTheme.m3Error),
      ),
      labelStyle: const TextStyle(color: ColorTheme.m3OnSurfaceVariant),
      hintStyle: const TextStyle(color: ColorTheme.m3OnSurfaceVariant),
    ),

    cardTheme: CardThemeData(
      color: ColorTheme.m3Surface,
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: ColorTheme.m3OutlineVariant),
      ),
    ),

    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: ColorTheme.m3Surface, // M3 uses surface color
      selectedItemColor: ColorTheme.m3OnSurface, // More aligned with M3 nav
      unselectedItemColor: ColorTheme.m3OnSurfaceVariant,
      elevation: 2,
      type: BottomNavigationBarType.fixed,
    ),

    dividerTheme: const DividerThemeData(
      color: ColorTheme.m3OutlineVariant, // Use outline variant for dividers
      thickness: 1,
    ),

    // Other component themes updated for M3
    dialogTheme: DialogThemeData(
      backgroundColor: ColorTheme.m3Surface,
      titleTextStyle: TextStyle(
        color: ColorTheme.m3OnSurface,
        fontSize: 22,
        fontWeight: FontWeight.bold,
      ),
      contentTextStyle: TextStyle(
        color: ColorTheme.m3OnSurfaceVariant,
        fontSize: 16,
      ),
    ),

    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: ColorTheme.m3PrimaryContainer,
      foregroundColor: ColorTheme.m3OnPrimaryContainer,
      elevation: 4,
    ),
  );

  // --- DARK THEME ---
  static final ThemeData darkTheme = ThemeData(
    brightness: Brightness.dark,
    // Use the M3 Dark ColorScheme for all core colors
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
      // Note: M3 dark error containers are not defined in your list, so we map them logically
      // errorContainer: ColorTheme.m3ErrorContainerDark,
      // onErrorContainer: ColorTheme.m3OnErrorContainerDark,
      surface: ColorTheme.m3SurfaceDark,
      onSurface: ColorTheme.m3OnSurfaceDark,
      surfaceContainerHighest: ColorTheme.m3SurfaceVariantDark,
      onSurfaceVariant: ColorTheme.m3OnSurfaceVariantDark,
      outline: ColorTheme.m3OutlineDark,
    ),
    primaryColor: ColorTheme.m3PrimaryDark, // Legacy support
    scaffoldBackgroundColor: ColorTheme.m3BackgroundDark,
    textTheme:
        TextThemes.darkTextTheme, // Ensure this uses colors from the new scheme

    appBarTheme: AppBarTheme(
      backgroundColor:
          ColorTheme.m3SurfaceDark, // Dark app bars are typically surface color
      foregroundColor: ColorTheme.m3OnSurfaceDark, // Text/icons on surface
      elevation: 0,
      titleTextStyle: TextThemes.darkTextTheme.titleLarge?.copyWith(
        color:
            ColorTheme.m3OnSurfaceDark, // Use OnSurface for high emphasis text
        fontWeight: FontWeight.bold,
      ),
    ),

    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: ColorTheme.m3PrimaryDark,
        foregroundColor: ColorTheme.m3OnPrimaryDark,
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    ),

    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: ColorTheme.m3PrimaryDark,
        side: const BorderSide(color: ColorTheme.m3OutlineDark),
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    ),

    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: ColorTheme.m3PrimaryDark,
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      ),
    ),

    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor:
          ColorTheme
              .m3SurfaceVariantDark, // A subtle contrast against the background
      contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: ColorTheme.m3OutlineDark),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: ColorTheme.m3OutlineDark),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: ColorTheme.m3PrimaryDark, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: ColorTheme.m3ErrorDark),
      ),
      labelStyle: const TextStyle(color: ColorTheme.m3OnSurfaceVariantDark),
      hintStyle: const TextStyle(color: ColorTheme.m3OnSurfaceVariantDark),
    ),

    cardTheme: CardThemeData(
      color: ColorTheme.m3SurfaceDark,
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: ColorTheme.m3OutlineDark),
      ),
    ),

    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: ColorTheme.m3SurfaceDark,
      selectedItemColor: ColorTheme.m3OnSurfaceDark,
      unselectedItemColor: ColorTheme.m3OnSurfaceVariantDark,
      elevation: 2,
      type: BottomNavigationBarType.fixed,
    ),

    dividerTheme: const DividerThemeData(
      color: ColorTheme.m3OutlineDark,
      thickness: 1,
    ),

    // Other component themes updated for M3
    dialogTheme: DialogThemeData(
      backgroundColor: ColorTheme.m3SurfaceDark,
      titleTextStyle: TextStyle(
        color: ColorTheme.m3OnSurfaceDark,
        fontSize: 22,
        fontWeight: FontWeight.bold,
      ),
      contentTextStyle: TextStyle(
        color: ColorTheme.m3OnSurfaceVariantDark,
        fontSize: 16,
      ),
    ),

    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: ColorTheme.m3PrimaryContainerDark,
      foregroundColor: ColorTheme.m3OnPrimaryContainerDark,
      elevation: 4,
    ),
  );
}
