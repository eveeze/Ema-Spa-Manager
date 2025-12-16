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

  // Observable untuk system brightness detection (KEEP agar kompatibel)
  final RxBool _systemBrightnessDark = false.obs;

  // Force rebuild observable - KEEP agar tidak merusak file lain yang depend
  final RxBool _forceRebuild = false.obs;
  bool get forceRebuild => _forceRebuild.value;

  bool get isDarkMode {
    if (_themeMode.value == ThemeMode.system) {
      return _systemBrightnessDark.value;
    }
    return _themeMode.value == ThemeMode.dark;
  }

  bool get isLightMode {
    if (_themeMode.value == ThemeMode.system) {
      return !_systemBrightnessDark.value;
    }
    return _themeMode.value == ThemeMode.light;
  }

  bool get isSystemMode => _themeMode.value == ThemeMode.system;

  @override
  void onInit() {
    super.onInit();

    WidgetsBinding.instance.addObserver(this);

    _loadThemeFromStorage();

    _updateSystemBrightness();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _updateSystemUIOverlayStyle();
    });
  }

  @override
  void onClose() {
    WidgetsBinding.instance.removeObserver(this);
    super.onClose();
  }

  @override
  void didChangePlatformBrightness() {
    super.didChangePlatformBrightness();
    debugPrint('🌙 System brightness changed detected');

    _updateSystemBrightness();

    if (_themeMode.value == ThemeMode.system) {
      _triggerForceRebuild();
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _updateSystemUIOverlayStyle();
      });
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);

    if (state == AppLifecycleState.resumed) {
      debugPrint('🌙 App resumed, checking system brightness');
      _updateSystemBrightness();

      if (_themeMode.value == ThemeMode.system) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _updateSystemUIOverlayStyle();
        });
      }
    }
  }

  void _updateSystemBrightness() {
    final brightness =
        WidgetsBinding.instance.platformDispatcher.platformBrightness;

    final wasDark = _systemBrightnessDark.value;
    final isDark = brightness == Brightness.dark;

    debugPrint(
      '🌙 System brightness: $brightness (was: ${wasDark ? 'dark' : 'light'}, now: ${isDark ? 'dark' : 'light'})',
    );

    _systemBrightnessDark.value = isDark;

    if (wasDark != isDark && _themeMode.value == ThemeMode.system) {
      debugPrint('🌙 System theme changed, forcing UI rebuild');
      _triggerForceRebuild();
    }
  }

  void _triggerForceRebuild() {
    _forceRebuild.value = !_forceRebuild.value;
  }

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
  }

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

  void changeThemeMode(ThemeMode themeMode) {
    final oldMode = _themeMode.value;
    if (oldMode == themeMode) return;

    _themeMode.value = themeMode;

    debugPrint('🌙 Theme mode changed: $oldMode -> $themeMode');

    Get.changeThemeMode(themeMode);

    _saveThemeToStorage();

    if (themeMode == ThemeMode.system) {
      _updateSystemBrightness();
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _updateSystemUIOverlayStyle();
    });
    _triggerForceRebuild();

    _showThemeChangeSnackbar();
  }

  void toggleTheme() {
    if (isDarkMode) {
      changeThemeMode(ThemeMode.light);
    } else {
      changeThemeMode(ThemeMode.dark);
    }
  }

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

  void setLightMode() => changeThemeMode(ThemeMode.light);
  void setDarkMode() => changeThemeMode(ThemeMode.dark);
  void setSystemMode() => changeThemeMode(ThemeMode.system);

  void updateSystemBrightness() {
    debugPrint('🌙 Manual system brightness update triggered');
    _updateSystemBrightness();

    if (_themeMode.value == ThemeMode.system) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _updateSystemUIOverlayStyle();
      });
    }
  }

  void checkSystemTheme() {
    final brightness =
        WidgetsBinding.instance.platformDispatcher.platformBrightness;

    debugPrint('🌙 Current system brightness: $brightness');
    debugPrint(
      '🌙 Cached system brightness: ${_systemBrightnessDark.value ? 'dark' : 'light'}',
    );
    debugPrint('🌙 Current theme mode: ${_themeMode.value}');
    debugPrint('🌙 Computed isDarkMode: $isDarkMode');
  }

  // =========================================================
  // ✅ M3 COLORS ONLY CHANGE (no API change)
  // =========================================================

  void _updateSystemUIOverlayStyle() {
    final bool isDark = isDarkMode;

    // Ambil dari M3 theme (colorScheme) biar ngikut AppTheme.m3...
    final ctx = Get.context;
    final cs = ctx?.colorScheme;

    // Fallback aman (kalau ctx null di early boot)
    final navBg =
        cs?.surface ??
        (isDark ? const Color(0xFF191C1E) : const Color(0xFFFBFCFD));
    final navDivider =
        cs?.outlineVariant ??
        (isDark ? const Color(0xFF40484C) : const Color(0xFFC0C8CC));

    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
        statusBarBrightness: isDark ? Brightness.dark : Brightness.light,
        systemNavigationBarColor: navBg,
        systemNavigationBarIconBrightness:
            isDark ? Brightness.light : Brightness.dark,
        systemNavigationBarDividerColor: navDivider,
      ),
    );
  }

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

    if (Get.isSnackbarOpen) {
      Get.closeCurrentSnackbar();
    }

    // ✅ ambil warna snackbar dari M3 scheme
    final ctx = Get.context;
    final cs = ctx?.colorScheme;

    // Material 3 best pairing: inverseSurface / inversePrimary
    final bg =
        cs?.inverseSurface ??
        (isDarkMode ? const Color(0xFFE1E2E4) : const Color(0xFF191C1E));
    final fg =
        cs?.onInverseSurface ??
        (isDarkMode ? const Color(0xFF191C1E) : const Color(0xFFFBFCFD));

    Get.showSnackbar(
      GetSnackBar(
        messageText: Text(
          message,
          style: TextStyle(color: fg, fontWeight: FontWeight.w700),
        ),
        icon: Icon(icon, color: fg),
        duration: const Duration(seconds: 2),
        snackPosition: SnackPosition.BOTTOM,
        margin: const EdgeInsets.all(16),
        borderRadius: 12,
        dismissDirection: DismissDirection.horizontal,
        backgroundColor: bg,
      ),
    );
  }

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

// tiny helper biar ctx?.colorScheme bisa
extension _ColorSchemeX on BuildContext {
  ColorScheme get colorScheme => Theme.of(this).colorScheme;
}
