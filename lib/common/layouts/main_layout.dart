// lib/common/layouts/main_layout.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:emababyspa/common/theme/color_theme.dart';
import 'package:emababyspa/common/widgets/custom_bottom_navigation.dart';
import 'package:emababyspa/features/theme/controllers/theme_controller.dart';
import 'package:emababyspa/utils/app_routes.dart';

class MainLayout extends StatefulWidget {
  final Widget child;
  final bool showBottomNavigation;
  final bool enablePullToRefresh;
  final VoidCallback? onRefresh;
  final String? appBarTitle;
  final List<Widget>? appBarActions;
  final bool showAppBar;
  final PreferredSizeWidget? customAppBar;
  final Color? backgroundColor;
  // NEW: Parameter untuk override parent route
  final String? parentRoute;
  // NEW: FloatingActionButton parameter
  final Widget? floatingActionButton;
  final FloatingActionButtonLocation? floatingActionButtonLocation;

  const MainLayout({
    super.key,
    required this.child,
    this.showBottomNavigation = true,
    this.enablePullToRefresh = false,
    this.onRefresh,
    this.appBarTitle,
    this.appBarActions,
    this.showAppBar = false,
    this.customAppBar,
    this.backgroundColor,
    this.parentRoute, // NEW
    this.floatingActionButton, // NEW
    this.floatingActionButtonLocation, // NEW
  });

  @override
  State<MainLayout> createState() => _MainLayoutState();
}

class _MainLayoutState extends State<MainLayout> {
  // Navigation state management
  final RxInt selectedIndex = 0.obs;
  final RxBool isNavigating = false.obs;

  // Theme controller
  late ThemeController _themeController;

  // Navigation items definition
  late final List<NavItem> navigationItems;

  // Route mapping for main navigation tabs
  static const Map<int, String> _routeMap = {
    0: AppRoutes.dashboard,
    1: AppRoutes.schedule,
    2: AppRoutes.services,
    3: AppRoutes.analytics,
    4: '/account', // Account page route (to be defined)
  };

  // Reverse mapping for route to index
  static const Map<String, int> _indexMap = {
    AppRoutes.dashboard: 0,
    AppRoutes.schedule: 1,
    AppRoutes.services: 2,
    AppRoutes.analytics: 3,
    '/account': 4,
  };

  // NEW: Parent route mapping untuk child routes
  static const Map<String, String> _parentRouteMap = {
    // Service related routes
    AppRoutes.serviceManage: AppRoutes.services,
    AppRoutes.serviceForm: AppRoutes.services,
    AppRoutes.serviceEdit: AppRoutes.services,

    // Service Category routes
    AppRoutes.serviceCategoryList: AppRoutes.services,
    AppRoutes.serviceCategoryForm: AppRoutes.services,
    AppRoutes.serviceCategoryEdit: AppRoutes.services,

    // Staff routes
    AppRoutes.staffList:
        AppRoutes.services, // atau bisa ke route lain sesuai kebutuhan
    AppRoutes.staffForm: AppRoutes.services,
    AppRoutes.staffEdit: AppRoutes.services,

    // Time slot routes
    AppRoutes.timeSlotDetail: AppRoutes.schedule,
    AppRoutes.timeSlotEdit: AppRoutes.schedule,

    // Session routes
    AppRoutes.sessionForm: AppRoutes.schedule,
    AppRoutes.sessionDetail: AppRoutes.schedule,

    // Reservation routes
    AppRoutes.reservationForm: AppRoutes.schedule,
    AppRoutes.reservationList: AppRoutes.schedule,
    AppRoutes.reservationDetail: AppRoutes.schedule,
  };

  @override
  void initState() {
    super.initState();
    _themeController = Get.find<ThemeController>();
    _initializeNavigationItems();
    _initializeCurrentRoute();
    _setupRouteListener();
  }

  void _initializeNavigationItems() {
    navigationItems = [
      NavItem(
        label: 'Dashboard',
        icon: Icons.home_outlined,
        activeIcon: Icons.home_rounded,
      ),
      NavItem(
        label: 'Jadwal',
        icon: Icons.calendar_month_outlined,
        activeIcon: Icons.calendar_month_rounded,
      ),
      NavItem(
        label: 'Layanan',
        icon: Icons.spa_outlined,
        activeIcon: Icons.spa_rounded,
      ),
      NavItem(
        label: 'Statistik',
        icon: Icons.bar_chart_outlined,
        activeIcon: Icons.bar_chart_rounded,
      ),
      NavItem(
        label: 'Akun',
        icon: Icons.person_outline_rounded,
        activeIcon: Icons.person_rounded,
      ),
    ];
  }

  void _initializeCurrentRoute() {
    // NEW: Enhanced route initialization with parent route support
    String routeToCheck = widget.parentRoute ?? Get.currentRoute;

    // Check if current route has a parent route mapping
    if (_parentRouteMap.containsKey(routeToCheck)) {
      routeToCheck = _parentRouteMap[routeToCheck]!;
    }

    // Remove parameters from route (e.g., /services/edit/123 -> /services/edit)
    final cleanRoute = _cleanRoute(routeToCheck);
    if (_parentRouteMap.containsKey(cleanRoute)) {
      routeToCheck = _parentRouteMap[cleanRoute]!;
    }

    selectedIndex.value = _indexMap[routeToCheck] ?? 0;
  }

  // NEW: Helper method to clean route parameters
  String _cleanRoute(String route) {
    // Remove IDs from routes like /services/edit/123
    final segments = route.split('/');
    if (segments.length > 3) {
      // Check if last segment is likely an ID (numeric)
      final lastSegment = segments.last;
      if (RegExp(r'^\d+$').hasMatch(lastSegment)) {
        segments.removeLast();
        return segments.join('/');
      }
    }
    return route;
  }

  void _setupRouteListener() {
    // Listen to route changes to keep bottom nav in sync
    ever(selectedIndex, (int index) {
      // This will be called when selectedIndex changes
    });
  }

  // Theme-aware color getters (unchanged)
  Color _getBackgroundColor() {
    if (widget.backgroundColor != null) return widget.backgroundColor!;

    return _themeController.isDarkMode
        ? ColorTheme.backgroundDark
        : ColorTheme.background;
  }

  Color _getSurfaceColor() {
    return _themeController.isDarkMode
        ? ColorTheme.surfaceDark
        : ColorTheme.surface;
  }

  Color _getTextPrimaryColor() {
    return _themeController.isDarkMode
        ? ColorTheme.textPrimaryDark
        : ColorTheme.textPrimary;
  }

  Color _getTextSecondaryColor() {
    return _themeController.isDarkMode
        ? ColorTheme.textSecondaryDark
        : ColorTheme.textSecondary;
  }

  Color _getPrimaryColor() {
    return _themeController.isDarkMode
        ? ColorTheme.primaryLightDark
        : ColorTheme.primary;
  }

  Color _getErrorColor() {
    return _themeController.isDarkMode
        ? ColorTheme.errorDark
        : ColorTheme.error;
  }

  SystemUiOverlayStyle _getSystemUIOverlayStyle() {
    return SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness:
          _themeController.isDarkMode ? Brightness.light : Brightness.dark,
      statusBarBrightness:
          _themeController.isDarkMode ? Brightness.dark : Brightness.light,
      systemNavigationBarColor:
          _themeController.isDarkMode
              ? ColorTheme.surfaceDark
              : ColorTheme.surface,
      systemNavigationBarIconBrightness:
          _themeController.isDarkMode ? Brightness.light : Brightness.dark,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      // Listen to theme changes to trigger rebuild
      _themeController.isDarkMode;

      return _buildMainScaffold(context);
    });
  }

  Widget _buildMainScaffold(BuildContext context) {
    return Scaffold(
      backgroundColor: _getBackgroundColor(),
      appBar: _buildAppBar(),
      body: _buildBody(context),
      bottomNavigationBar:
          widget.showBottomNavigation ? _buildBottomNavigation() : null,
      floatingActionButton: widget.floatingActionButton, // NEW
      floatingActionButtonLocation: widget.floatingActionButtonLocation, // NEW
      resizeToAvoidBottomInset: true,
    );
  }

  PreferredSizeWidget? _buildAppBar() {
    if (widget.customAppBar != null) return widget.customAppBar;
    if (!widget.showAppBar) return null;

    return AppBar(
      title:
          widget.appBarTitle != null
              ? Text(
                widget.appBarTitle!,
                style: TextStyle(
                  fontFamily: 'JosefinSans',
                  fontWeight: FontWeight.w600,
                  color: _getTextPrimaryColor(),
                ),
              )
              : null,
      backgroundColor: _getSurfaceColor(),
      elevation: 0,
      systemOverlayStyle: _getSystemUIOverlayStyle(),
      iconTheme: IconThemeData(color: _getTextPrimaryColor()),
      actions: widget.appBarActions,
      centerTitle: true,
      surfaceTintColor: Colors.transparent,
      shadowColor:
          _themeController.isDarkMode
              ? Colors.transparent
              : Colors.black.withValues(alpha: 0.1),
      shape:
          _themeController.isDarkMode
              ? Border(
                bottom: BorderSide(
                  color: ColorTheme.borderDark.withValues(alpha: 0.3),
                  width: 0.5,
                ),
              )
              : null,
    );
  }

  Widget _buildBody(BuildContext context) {
    Widget body = widget.child;

    if (widget.enablePullToRefresh) {
      body = RefreshIndicator(
        onRefresh: _handleRefresh,
        color: _getPrimaryColor(),
        backgroundColor: _getSurfaceColor(),
        child: body,
      );
    }

    body = SafeArea(bottom: widget.showBottomNavigation, child: body);

    return body;
  }

  Widget _buildBottomNavigation() {
    return Obx(
      () => CustomBottomNavigation(
        items: navigationItems,
        currentIndex: selectedIndex.value,
        onTap: _handleBottomNavTap,
        backgroundColor: _getSurfaceColor(),
        activeColor: _getPrimaryColor(),
        inactiveColor: _getTextSecondaryColor(),
        elevation: _themeController.isDarkMode ? 8 : 12,
        iconSize: 26,
        showLabels: true,
        isNavigating: isNavigating.value,
      ),
    );
  }

  void _handleBottomNavTap(int index) {
    if (_themeController.isDarkMode) {
      HapticFeedback.mediumImpact();
    } else {
      HapticFeedback.lightImpact();
    }

    try {
      _navigateToTab(index);
    } catch (e) {
      debugPrint('Navigation error in MainLayout: $e');
      _showNavigationError();
    }
  }

  Future<void> _navigateToTab(int index) async {
    if (!_isValidIndex(index) || _isDuplicateNavigation(index)) {
      return;
    }

    isNavigating.value = true;

    try {
      selectedIndex.value = index;
      final targetRoute = _routeMap[index]!;
      await _navigateToRoute(targetRoute);
    } catch (e) {
      debugPrint('Navigation error: $e');
      _revertToCurrentRoute();
    } finally {
      Future.delayed(const Duration(milliseconds: 300), () {
        if (mounted) {
          isNavigating.value = false;
        }
      });
    }
  }

  bool _isValidIndex(int index) {
    return index >= 0 &&
        index < navigationItems.length &&
        _routeMap.containsKey(index);
  }

  bool _isDuplicateNavigation(int index) {
    return selectedIndex.value == index || isNavigating.value;
  }

  Future<void> _navigateToRoute(String route) async {
    final routeExists = AppRoutes.pages.any((page) => page.name == route);

    if (!routeExists) {
      debugPrint('Route $route does not exist in AppRoutes');
      return;
    }

    await Get.offNamed(route);
  }

  void _revertToCurrentRoute() {
    final currentRouteName = Get.currentRoute;
    final correctIndex = _indexMap[currentRouteName] ?? 0;
    selectedIndex.value = correctIndex;
  }

  Future<void> _handleRefresh() async {
    if (widget.onRefresh != null) {
      widget.onRefresh!();
    } else {
      debugPrint('Refreshing current page...');
    }
  }

  void _showNavigationError() {
    if (Get.isSnackbarOpen) return;

    Get.showSnackbar(
      GetSnackBar(
        message: 'Navigation failed. Please try again.',
        duration: const Duration(seconds: 2),
        backgroundColor: _getErrorColor(),
        margin: const EdgeInsets.all(16),
        borderRadius: 8,
        isDismissible: true,
        snackPosition: SnackPosition.BOTTOM,
        messageText: Text(
          'Navigation failed. Please try again.',
          style: TextStyle(
            color: _themeController.isDarkMode ? Colors.black : Colors.white,
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
  }
}

// Enhanced extension dengan method baru
extension MainLayoutExtensions on MainLayout {
  static MainLayout dashboard({
    required Widget child,
    VoidCallback? onRefresh,
    Widget? floatingActionButton,
    FloatingActionButtonLocation? floatingActionButtonLocation,
  }) {
    return MainLayout(
      showBottomNavigation: true,
      enablePullToRefresh: onRefresh != null,
      onRefresh: onRefresh,
      floatingActionButton: floatingActionButton,
      floatingActionButtonLocation: floatingActionButtonLocation,
      child: child,
    );
  }

  static MainLayout form({
    required Widget child,
    String? title,
    List<Widget>? actions,
    String? parentRoute,
    Widget? floatingActionButton,
    FloatingActionButtonLocation? floatingActionButtonLocation,
  }) {
    return MainLayout(
      showBottomNavigation: true,
      showAppBar: true,
      appBarTitle: title,
      appBarActions: actions,
      parentRoute: parentRoute,
      floatingActionButton: floatingActionButton,
      floatingActionButtonLocation: floatingActionButtonLocation,
      child: child,
    );
  }

  static MainLayout subPage({
    required Widget child,
    required String parentRoute,
    String? title,
    List<Widget>? actions,
    bool showAppBar = true,
    Widget? floatingActionButton,
    FloatingActionButtonLocation? floatingActionButtonLocation,
  }) {
    return MainLayout(
      showBottomNavigation: true,
      showAppBar: showAppBar,
      appBarTitle: title,
      appBarActions: actions,
      parentRoute: parentRoute,
      floatingActionButton: floatingActionButton,
      floatingActionButtonLocation: floatingActionButtonLocation,
      child: child,
    );
  }

  static MainLayout withCustomAppBar({
    required Widget child,
    required PreferredSizeWidget appBar,
    bool showBottomNav = true,
    String? parentRoute,
    Widget? floatingActionButton,
    FloatingActionButtonLocation? floatingActionButtonLocation,
  }) {
    return MainLayout(
      customAppBar: appBar,
      showBottomNavigation: showBottomNav,
      parentRoute: parentRoute,
      floatingActionButton: floatingActionButton,
      floatingActionButtonLocation: floatingActionButtonLocation,
      child: child,
    );
  }
}
