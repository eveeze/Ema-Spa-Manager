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
      onPrimary: Colors.white,
      onSecondary: Colors.white,
      onSurface: ColorTheme.textPrimary,
      onError: Colors.white,
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
      labelStyle: TextStyle(color: ColorTheme.textSecondary),
      hintStyle: TextStyle(color: ColorTheme.textTertiary),
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
      type: BottomNavigationBarType.fixed, // Add this for consistent behavior
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
    // Add missing light theme components
    dialogTheme: DialogTheme(
      backgroundColor: Colors.white,
      titleTextStyle: TextStyle(
        color: ColorTheme.textPrimary,
        fontSize: 20,
        fontWeight: FontWeight.bold,
      ),
      contentTextStyle: TextStyle(
        color: ColorTheme.textSecondary,
        fontSize: 16,
      ),
    ),
    snackBarTheme: SnackBarThemeData(
      backgroundColor: ColorTheme.textPrimary,
      contentTextStyle: TextStyle(color: Colors.white),
    ),
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: ColorTheme.primary,
      foregroundColor: Colors.white,
    ),
    switchTheme: SwitchThemeData(
      thumbColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return ColorTheme.primary;
        }
        return ColorTheme.textTertiary;
      }),
      trackColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return ColorTheme.primary.withValues(alpha: 0.5);
        }
        return ColorTheme.border;
      }),
    ),
    checkboxTheme: CheckboxThemeData(
      fillColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return ColorTheme.primary;
        }
        return Colors.transparent;
      }),
      checkColor: WidgetStateProperty.all(Colors.white),
    ),
  );

  static final ThemeData darkTheme = ThemeData(
    brightness: Brightness.dark,
    primaryColor: ColorTheme.primaryLightDark,
    scaffoldBackgroundColor: ColorTheme.backgroundDark,
    colorScheme: ColorScheme.dark(
      primary: ColorTheme.primaryLightDark,
      secondary: ColorTheme.secondaryDark,
      error: ColorTheme.errorDark,
      surface: ColorTheme.surfaceDark,
      onPrimary: Colors.black,
      onSecondary: Colors.white,
      onSurface: ColorTheme.textPrimaryDark,
      onError: Colors.black,
    ),
    textTheme: TextThemes.darkTextTheme,
    appBarTheme: AppBarTheme(
      backgroundColor: ColorTheme.surfaceDark,
      elevation: 0,
      iconTheme: IconThemeData(color: ColorTheme.textPrimaryDark),
      titleTextStyle: TextThemes.darkTextTheme.titleLarge?.copyWith(
        color: ColorTheme.textPrimaryDark,
        fontWeight: FontWeight.bold,
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: ColorTheme.primaryLightDark,
        foregroundColor: Colors.black,
        padding: EdgeInsets.symmetric(vertical: 16, horizontal: 24),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: ColorTheme.primaryLightDark,
        side: BorderSide(color: ColorTheme.primaryLightDark),
        padding: EdgeInsets.symmetric(vertical: 16, horizontal: 24),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: ColorTheme.primaryLightDark,
        padding: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: ColorTheme.surfaceDark,
      contentPadding: EdgeInsets.symmetric(vertical: 16, horizontal: 16),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: ColorTheme.borderDark),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: ColorTheme.borderDark),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: ColorTheme.primaryLightDark, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: ColorTheme.errorDark),
      ),
      labelStyle: TextStyle(color: ColorTheme.textSecondaryDark),
      hintStyle: TextStyle(color: ColorTheme.textTertiaryDark),
    ),
    cardTheme: CardTheme(
      color: ColorTheme.surfaceDark,
      elevation: 2,
      shadowColor: Colors.black.withValues(alpha: 0.3),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ),
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      backgroundColor: ColorTheme.surfaceDark,
      selectedItemColor: ColorTheme.primaryLightDark,
      unselectedItemColor: ColorTheme.textSecondaryDark,
      elevation: 8,
      type: BottomNavigationBarType.fixed, // Add this for consistent behavior
    ),
    dividerTheme: DividerThemeData(
      color: ColorTheme.borderDark,
      thickness: 1,
      space: 24,
    ),
    bottomSheetTheme: BottomSheetThemeData(
      backgroundColor: ColorTheme.surfaceDark,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
    ),
    dialogTheme: DialogTheme(
      backgroundColor: ColorTheme.surfaceDark,
      titleTextStyle: TextStyle(
        color: ColorTheme.textPrimaryDark,
        fontSize: 20,
        fontWeight: FontWeight.bold,
      ),
      contentTextStyle: TextStyle(
        color: ColorTheme.textSecondaryDark,
        fontSize: 16,
      ),
    ),
    snackBarTheme: SnackBarThemeData(
      backgroundColor: ColorTheme.surfaceDark,
      contentTextStyle: TextStyle(color: ColorTheme.textPrimaryDark),
    ),
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: ColorTheme.primaryLightDark,
      foregroundColor: Colors.black,
    ),
    switchTheme: SwitchThemeData(
      thumbColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return ColorTheme.primaryLightDark;
        }
        return ColorTheme.textTertiaryDark;
      }),
      trackColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return ColorTheme.primaryLightDark.withValues(alpha: 0.5);
        }
        return ColorTheme.borderDark;
      }),
    ),
    checkboxTheme: CheckboxThemeData(
      fillColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return ColorTheme.primaryLightDark;
        }
        return Colors.transparent;
      }),
      checkColor: WidgetStateProperty.all(Colors.black),
    ),
  );
}
