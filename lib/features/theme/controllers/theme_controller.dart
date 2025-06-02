// lib/features/theme/controllers/theme_controller.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

class ThemeController extends GetxController {
  static const String _themeKey = 'theme_mode';

  final GetStorage _storage = GetStorage();

  // Observable theme mode
  final Rx<ThemeMode> _themeMode = ThemeMode.system.obs;
  ThemeMode get themeMode => _themeMode.value;

  // Computed property to check if dark mode is active
  bool get isDarkMode {
    if (_themeMode.value == ThemeMode.system) {
      final context = Get.context;
      if (context != null) {
        return MediaQuery.of(context).platformBrightness == Brightness.dark;
      }
      return false;
    }
    return _themeMode.value == ThemeMode.dark;
  }

  // Computed property to check if light mode is active
  bool get isLightMode {
    if (_themeMode.value == ThemeMode.system) {
      final context = Get.context;
      if (context != null) {
        return MediaQuery.of(context).platformBrightness == Brightness.light;
      }
      return true;
    }
    return _themeMode.value == ThemeMode.light;
  }

  // Computed property to check if system mode is active
  bool get isSystemMode => _themeMode.value == ThemeMode.system;

  @override
  void onInit() {
    super.onInit();
    _loadThemeFromStorage();
  }

  /// Load theme preference from storage
  void _loadThemeFromStorage() {
    final savedTheme = _storage.read(_themeKey);

    switch (savedTheme) {
      case 'light':
        _themeMode.value = ThemeMode.light;
        break;
      case 'dark':
        _themeMode.value = ThemeMode.dark;
        break;
      case 'system':
      default:
        _themeMode.value = ThemeMode.system;
        break;
    }

    // Update system UI overlay style
    _updateSystemUIOverlayStyle();
  }

  /// Save theme preference to storage
  void _saveThemeToStorage() {
    String themeString;
    switch (_themeMode.value) {
      case ThemeMode.light:
        themeString = 'light';
        break;
      case ThemeMode.dark:
        themeString = 'dark';
        break;
      case ThemeMode.system:
        themeString = 'system';
        break;
    }
    _storage.write(_themeKey, themeString);
  }

  /// Change theme mode
  void changeThemeMode(ThemeMode themeMode) {
    _themeMode.value = themeMode;
    Get.changeThemeMode(themeMode);
    _saveThemeToStorage();
    _updateSystemUIOverlayStyle();

    // Show feedback to user
    _showThemeChangeSnackbar();
  }

  /// Toggle between light and dark mode (skip system mode)
  void toggleTheme() {
    if (isDarkMode) {
      changeThemeMode(ThemeMode.light);
    } else {
      changeThemeMode(ThemeMode.dark);
    }
  }

  /// Cycle through all theme modes: System -> Light -> Dark -> System
  void cycleThemeMode() {
    switch (_themeMode.value) {
      case ThemeMode.system:
        changeThemeMode(ThemeMode.light);
        break;
      case ThemeMode.light:
        changeThemeMode(ThemeMode.dark);
        break;
      case ThemeMode.dark:
        changeThemeMode(ThemeMode.system);
        break;
    }
  }

  /// Set specific theme modes
  void setLightMode() => changeThemeMode(ThemeMode.light);
  void setDarkMode() => changeThemeMode(ThemeMode.dark);
  void setSystemMode() => changeThemeMode(ThemeMode.system);

  /// Update system UI overlay style based on current theme
  void _updateSystemUIOverlayStyle() {
    final bool isDark = isDarkMode;

    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
        statusBarBrightness: isDark ? Brightness.dark : Brightness.light,
        systemNavigationBarColor:
            isDark ? const Color(0xFF1E1E1E) : Colors.white,
        systemNavigationBarIconBrightness:
            isDark ? Brightness.light : Brightness.dark,
        systemNavigationBarDividerColor:
            isDark ? const Color(0xFF2D3748) : const Color(0xFFE0E4E8),
      ),
    );
  }

  /// Show snackbar when theme changes
  void _showThemeChangeSnackbar() {
    String message;
    IconData icon;

    switch (_themeMode.value) {
      case ThemeMode.light:
        message = 'Tema Terang Diaktifkan';
        icon = Icons.light_mode;
        break;
      case ThemeMode.dark:
        message = 'Tema Gelap Diaktifkan';
        icon = Icons.dark_mode;
        break;
      case ThemeMode.system:
        message = 'Mengikuti Sistem';
        icon = Icons.brightness_auto;
        break;
    }

    Get.showSnackbar(
      GetSnackBar(
        message: message,
        icon: Icon(icon, color: Colors.white),
        duration: const Duration(seconds: 2),
        snackPosition: SnackPosition.BOTTOM,
        margin: const EdgeInsets.all(16),
        borderRadius: 12,
        dismissDirection: DismissDirection.horizontal,
      ),
    );
  }

  /// Get theme mode display name
  String get themeModeDisplayName {
    switch (_themeMode.value) {
      case ThemeMode.light:
        return 'Terang';
      case ThemeMode.dark:
        return 'Gelap';
      case ThemeMode.system:
        return 'Sistem';
    }
  }

  /// Get theme mode icon
  IconData get themeModeIcon {
    switch (_themeMode.value) {
      case ThemeMode.light:
        return Icons.light_mode;
      case ThemeMode.dark:
        return Icons.dark_mode;
      case ThemeMode.system:
        return Icons.brightness_auto;
    }
  }
}
