// lib/features/theme/controllers/theme_controller.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

class ThemeController extends GetxController with WidgetsBindingObserver {
  static const String _themeKey = 'theme_mode';

  final GetStorage _storage = GetStorage();

  // Observable theme mode
  final Rx<ThemeMode> _themeMode = ThemeMode.system.obs;
  ThemeMode get themeMode => _themeMode.value;

  // Observable untuk system brightness detection
  final RxBool _systemBrightnessDark = false.obs;

  // Force rebuild observable - ini yang akan trigger UI rebuild
  final RxBool _forceRebuild = false.obs;
  bool get forceRebuild => _forceRebuild.value;

  // Computed property to check if dark mode is active
  bool get isDarkMode {
    if (_themeMode.value == ThemeMode.system) {
      return _systemBrightnessDark.value;
    }
    return _themeMode.value == ThemeMode.dark;
  }

  // Computed property to check if light mode is active
  bool get isLightMode {
    if (_themeMode.value == ThemeMode.system) {
      return !_systemBrightnessDark.value;
    }
    return _themeMode.value == ThemeMode.light;
  }

  // Computed property to check if system mode is active
  bool get isSystemMode => _themeMode.value == ThemeMode.system;

  @override
  void onInit() {
    super.onInit();

    // Register observer untuk listen system changes
    WidgetsBinding.instance.addObserver(this);

    _loadThemeFromStorage();
    _initSystemBrightnessListener();
  }

  @override
  void onClose() {
    // Cleanup observer
    WidgetsBinding.instance.removeObserver(this);
    super.onClose();
  }

  // Override didChangePlatformBrightness untuk handle system theme changes
  @override
  void didChangePlatformBrightness() {
    super.didChangePlatformBrightness();
    debugPrint('🌙 System brightness changed detected');

    // Update system brightness dengan delay untuk memastikan context tersedia
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _updateSystemBrightness();
    });
  }

  // Override didChangeAppLifecycleState untuk handle app resume
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);

    if (state == AppLifecycleState.resumed) {
      debugPrint('🌙 App resumed, checking system brightness');
      _updateSystemBrightness();
    }
  }

  /// Initialize system brightness listener
  void _initSystemBrightnessListener() {
    // Set initial system brightness
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _updateSystemBrightness();
    });
  }

  /// Update system brightness detection dengan force rebuild
  void _updateSystemBrightness() {
    final context = Get.context;
    if (context == null) {
      debugPrint('🌙 Context not available, scheduling retry');
      // Retry setelah delay jika context belum tersedia
      Future.delayed(const Duration(milliseconds: 100), () {
        _updateSystemBrightness();
      });
      return;
    }

    final brightness = MediaQuery.platformBrightnessOf(context);
    final wasDark = _systemBrightnessDark.value;
    final isDark = brightness == Brightness.dark;

    debugPrint(
      '🌙 System brightness: $brightness (was: ${wasDark ? 'dark' : 'light'}, now: ${isDark ? 'dark' : 'light'})',
    );

    // Update system brightness
    _systemBrightnessDark.value = isDark;

    // Force rebuild jika ada perubahan dan sedang menggunakan system mode
    if (wasDark != isDark && _themeMode.value == ThemeMode.system) {
      debugPrint('🌙 System theme changed, forcing UI rebuild');
      _triggerForceRebuild();
      _updateSystemUIOverlayStyle();
    }
  }

  /// Trigger force rebuild untuk memastikan UI update
  void _triggerForceRebuild() {
    _forceRebuild.value = !_forceRebuild.value;
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

    debugPrint('🌙 Loaded theme from storage: ${_themeMode.value}');

    // Update system UI overlay style
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _updateSystemUIOverlayStyle();
    });
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
    debugPrint('🌙 Saved theme to storage: $themeString');
  }

  /// Change theme mode dengan improved handling
  void changeThemeMode(ThemeMode themeMode) {
    final oldMode = _themeMode.value;
    _themeMode.value = themeMode;

    debugPrint('🌙 Theme mode changed: $oldMode -> $themeMode');

    // Update GetX theme
    Get.changeThemeMode(themeMode);

    // Save to storage
    _saveThemeToStorage();

    // Update system brightness detection jika beralih ke system mode
    if (themeMode == ThemeMode.system) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _updateSystemBrightness();
      });
    }

    // Update system UI
    _updateSystemUIOverlayStyle();

    // Force rebuild UI
    _triggerForceRebuild();

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

  /// Manually trigger system brightness update
  void updateSystemBrightness() {
    debugPrint('🌙 Manual system brightness update triggered');
    _updateSystemBrightness();
  }

  /// Check if system theme actually changed (untuk debugging)
  void checkSystemTheme() {
    final context = Get.context;
    if (context != null) {
      final brightness = MediaQuery.platformBrightnessOf(context);
      debugPrint('🌙 Current system brightness: $brightness');
      debugPrint(
        '🌙 Cached system brightness: ${_systemBrightnessDark.value ? 'dark' : 'light'}',
      );
      debugPrint('🌙 Current theme mode: ${_themeMode.value}');
      debugPrint('🌙 Computed isDarkMode: $isDarkMode');
    }
  }

  /// Update system UI overlay style based on current theme
  void _updateSystemUIOverlayStyle() {
    final bool isDark = isDarkMode;

    debugPrint(
      '🌙 Updating system UI overlay style: ${isDark ? 'dark' : 'light'}',
    );

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
        message = 'Mengikuti Sistem ${isDarkMode ? '(Gelap)' : '(Terang)'}';
        icon = Icons.brightness_auto;
        break;
    }

    // Cancel existing snackbar jika ada
    if (Get.isSnackbarOpen) {
      Get.closeCurrentSnackbar();
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
        backgroundColor:
            isDarkMode ? const Color(0xFF2D3748) : const Color(0xFF4A5568),
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
        return 'Sistem ${isDarkMode ? '(Gelap)' : '(Terang)'}';
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
