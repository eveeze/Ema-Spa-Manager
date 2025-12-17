import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

class ThemeController extends GetxController with WidgetsBindingObserver {
  static const String _themeKey = 'theme_mode';

  final GetStorage _storage = GetStorage();

  // Theme mode
  final Rx<ThemeMode> _themeMode = ThemeMode.system.obs;
  Rx<ThemeMode> get themeModeRx => _themeMode;
  ThemeMode get themeMode => _themeMode.value;

  // System brightness cache
  final RxBool _systemBrightnessDark = false.obs;
  RxBool get systemBrightnessDarkRx => _systemBrightnessDark;

  // Force rebuild toggle (keep for compat)
  final RxBool _forceRebuild = false.obs;
  RxBool get forceRebuildRx => _forceRebuild;
  bool get forceRebuild => _forceRebuild.value;

  // ✅ NEW: tick counter (lebih “pasti” memicu rebuild Obx)
  final RxInt _themeTick = 0.obs;
  RxInt get themeTickRx => _themeTick;
  int get themeTick => _themeTick.value;

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

    _systemBrightnessDark.value = isDark;

    if (wasDark != isDark && _themeMode.value == ThemeMode.system) {
      _triggerForceRebuild();
    }
  }

  void _triggerForceRebuild() {
    _forceRebuild.value = !_forceRebuild.value;
    _themeTick.value++; // ✅ paling penting untuk bottomsheet realtime
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
  }

  void changeThemeMode(ThemeMode themeMode) {
    final oldMode = _themeMode.value;
    if (oldMode == themeMode) return;

    _themeMode.value = themeMode;

    debugPrint('🌙 Theme mode changed: $oldMode -> $themeMode');

    // ✅ update GetMaterialApp
    Get.changeThemeMode(themeMode);

    _saveThemeToStorage();

    if (themeMode == ThemeMode.system) {
      _updateSystemBrightness();
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _updateSystemUIOverlayStyle();
    });

    // ✅ TRIGGER rebuild everywhere (including bottomsheet)
    _triggerForceRebuild();

    _showThemeChangeSnackbar();
  }

  void toggleTheme() =>
      changeThemeMode(isDarkMode ? ThemeMode.light : ThemeMode.dark);

  void setLightMode() => changeThemeMode(ThemeMode.light);
  void setDarkMode() => changeThemeMode(ThemeMode.dark);
  void setSystemMode() => changeThemeMode(ThemeMode.system);

  void updateSystemBrightness() {
    _updateSystemBrightness();
    if (_themeMode.value == ThemeMode.system) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _updateSystemUIOverlayStyle();
      });
    }
  }

  void _updateSystemUIOverlayStyle() {
    final bool isDark = isDarkMode;

    final ctx = Get.context;
    final cs = ctx != null ? Theme.of(ctx).colorScheme : null;

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

    if (Get.isSnackbarOpen) Get.closeCurrentSnackbar();

    final ctx = Get.context;
    final cs = ctx != null ? Theme.of(ctx).colorScheme : null;

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
