import 'package:flutter/material.dart';
import 'package:emababyspa/common/theme/text_theme.dart';
import 'package:emababyspa/common/theme/color_theme.dart';

class AppTheme {
  static final ThemeData lightTheme = ThemeData(
    brightness: Brightness.light,
    primaryColor: ColorTheme.primary,
    scaffoldBackgroundColor: ColorTheme.background,
    colorScheme: ColorScheme.light(
      primary: ColorTheme.primary,
      secondary: ColorTheme.secondary,
      error: ColorTheme.error,
      surface: ColorTheme.surface,
    ),
    textTheme: TextThemes.textTheme,
    appBarTheme: AppBarTheme(
      backgroundColor: ColorTheme.primary,
      elevation: 0,
      iconTheme: IconThemeData(color: Colors.white),
      titleTextStyle: TextThemes.textTheme.titleLarge?.copyWith(
        color: Colors.white,
        fontWeight: FontWeight.bold,
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: ColorTheme.primary,
        foregroundColor: Colors.white,
        padding: EdgeInsets.symmetric(vertical: 16, horizontal: 24),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: ColorTheme.primary,
        side: BorderSide(color: ColorTheme.primary),
        padding: EdgeInsets.symmetric(vertical: 16, horizontal: 24),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: ColorTheme.primary,
        padding: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.white,
      contentPadding: EdgeInsets.symmetric(vertical: 16, horizontal: 16),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: ColorTheme.border),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: ColorTheme.border),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: ColorTheme.primary, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: ColorTheme.error),
      ),
    ),
    cardTheme: CardTheme(
      color: Colors.white,
      elevation: 2,
      shadowColor: Colors.black.withValues(alpha: 0.1),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ),
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      backgroundColor: Colors.white,
      selectedItemColor: ColorTheme.primary,
      unselectedItemColor: ColorTheme.textSecondary,
      elevation: 8,
    ),
    dividerTheme: DividerThemeData(
      color: ColorTheme.border,
      thickness: 1,
      space: 24,
    ),
    bottomSheetTheme: BottomSheetThemeData(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
    ),
  );

  static final ThemeData darkTheme = ThemeData(
    brightness: Brightness.dark,
    primaryColor: ColorTheme.primaryDark,
    scaffoldBackgroundColor: ColorTheme.backgroundDark,
    colorScheme: ColorScheme.dark(
      primary: ColorTheme.primaryDark,
      secondary: ColorTheme.secondaryDark,
      error: ColorTheme.errorDark,
      surface: ColorTheme.surfaceDark,
    ),
    textTheme: TextThemes.darkTextTheme,
    appBarTheme: AppBarTheme(
      backgroundColor: ColorTheme.surfaceDark,
      elevation: 0,
      iconTheme: IconThemeData(color: Colors.white),
      titleTextStyle: TextThemes.darkTextTheme.titleLarge?.copyWith(
        color: Colors.white,
        fontWeight: FontWeight.bold,
      ),
    ),
  );
}
