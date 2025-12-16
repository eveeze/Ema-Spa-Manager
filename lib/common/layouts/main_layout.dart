import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
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
  final String? parentRoute;
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
    this.parentRoute,
    this.floatingActionButton,
    this.floatingActionButtonLocation,
  });

  factory MainLayout.dashboard({
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

  factory MainLayout.form({
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

  factory MainLayout.subPage({
    required Widget child,
    required String parentRoute,
    String? title,
    List<Widget>? actions,
    bool showAppBar = true,
    bool showBottomNavigation = true,
    Widget? floatingActionButton,
    FloatingActionButtonLocation? floatingActionButtonLocation,
  }) {
    return MainLayout(
      showBottomNavigation: showBottomNavigation,
      showAppBar: showAppBar,
      appBarTitle: title,
      appBarActions: actions,
      parentRoute: parentRoute,
      floatingActionButton: floatingActionButton,
      floatingActionButtonLocation: floatingActionButtonLocation,
      child: child,
    );
  }

  factory MainLayout.withCustomAppBar({
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

  @override
  State<MainLayout> createState() => _MainLayoutState();
}

class _MainLayoutState extends State<MainLayout> with WidgetsBindingObserver {
  final RxInt selectedIndex = 0.obs;
  final RxBool isNavigating = false.obs;

  late ThemeController _themeController;
  late final List<NavItem> navigationItems;

  static const Map<int, String> _routeMap = {
    0: AppRoutes.dashboard,
    1: AppRoutes.schedule,
    2: AppRoutes.services,
    3: AppRoutes.analyticsView,
    4: '/account',
  };

  static const Map<String, int> _indexMap = {
    AppRoutes.dashboard: 0,
    AppRoutes.schedule: 1,
    AppRoutes.services: 2,
    AppRoutes.analyticsView: 3,
    '/account': 4,
  };

  static const Map<String, String> _parentRouteMap = {
    AppRoutes.serviceManage: AppRoutes.services,
    AppRoutes.serviceForm: AppRoutes.services,
    AppRoutes.serviceEdit: AppRoutes.services,
    AppRoutes.serviceCategoryList: AppRoutes.services,
    AppRoutes.serviceCategoryForm: AppRoutes.services,
    AppRoutes.serviceCategoryEdit: AppRoutes.services,
    AppRoutes.staffList: AppRoutes.services,
    AppRoutes.staffForm: AppRoutes.services,
    AppRoutes.staffEdit: AppRoutes.services,
    AppRoutes.timeSlotDetail: AppRoutes.schedule,
    AppRoutes.timeSlotEdit: AppRoutes.schedule,
    AppRoutes.sessionForm: AppRoutes.schedule,
    AppRoutes.sessionDetail: AppRoutes.schedule,
    AppRoutes.reservationForm: AppRoutes.schedule,
    AppRoutes.reservationList: AppRoutes.schedule,
    AppRoutes.reservationDetail: AppRoutes.schedule,
  };

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    _themeController = Get.find<ThemeController>();

    _initializeNavigationItems();
    _initializeCurrentRoute();
    _setupRouteListener();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangePlatformBrightness() {
    super.didChangePlatformBrightness();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _themeController.updateSystemBrightness();
    });
  }

  void _initializeNavigationItems() {
    // ❌ JANGAN const (NavItem kamu bukan const)
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
    final String currentRoutePattern = Get.routing.current;

    String? routeToEvaluate = _parentRouteMap[currentRoutePattern];
    routeToEvaluate ??= currentRoutePattern;

    routeToEvaluate = widget.parentRoute ?? routeToEvaluate;

    selectedIndex.value = _indexMap[routeToEvaluate] ?? 0;
  }

  void _setupRouteListener() {
    ever(selectedIndex, (int index) {});
  }

  // ✅ Semua warna ambil dari Theme (M3) -> realtime & konsisten
  Color _backgroundColor(BuildContext context) {
    if (widget.backgroundColor != null) return widget.backgroundColor!;
    return Theme.of(context).colorScheme.surface;
  }

  Color _surfaceColor(BuildContext context) {
    return Theme.of(context).colorScheme.surface;
  }

  Color _primary(BuildContext context) {
    return Theme.of(context).colorScheme.primary;
  }

  Color _textPrimary(BuildContext context) {
    return Theme.of(context).colorScheme.onSurface;
  }

  Color _textSecondary(BuildContext context) {
    return Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.72);
  }

  SystemUiOverlayStyle _systemUi(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isDark = _themeController.isDarkMode;

    return SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
      statusBarBrightness: isDark ? Brightness.dark : Brightness.light,
      systemNavigationBarColor: cs.surface,
      systemNavigationBarIconBrightness:
          isDark ? Brightness.light : Brightness.dark,
      systemNavigationBarDividerColor: cs.outlineVariant,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      // ✅ Cukup baca 1 Rx untuk “paksa” rebuild tiap theme change
      _themeController.forceRebuildRx.value;

      return AnnotatedRegion<SystemUiOverlayStyle>(
        value: _systemUi(context),
        child: _buildMainScaffold(context),
      );
    });
  }

  Widget _buildMainScaffold(BuildContext context) {
    return Scaffold(
      backgroundColor: _backgroundColor(context),
      appBar: _buildAppBar(context),
      body: _buildBody(context),
      bottomNavigationBar:
          widget.showBottomNavigation ? _buildBottomNavigation(context) : null,
      floatingActionButton: widget.floatingActionButton,
      floatingActionButtonLocation: widget.floatingActionButtonLocation,
      resizeToAvoidBottomInset: true,
    );
  }

  PreferredSizeWidget? _buildAppBar(BuildContext context) {
    if (widget.customAppBar != null) return widget.customAppBar;
    if (!widget.showAppBar) return null;

    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return AppBar(
      title:
          widget.appBarTitle != null
              ? Text(
                widget.appBarTitle!,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontFamily: 'JosefinSans',
                  fontWeight: FontWeight.w700,
                  color: _textPrimary(context),
                ),
              )
              : null,
      backgroundColor: _surfaceColor(context),
      elevation: 0,
      iconTheme: IconThemeData(color: _textPrimary(context)),
      actions: widget.appBarActions,
      centerTitle: true,
      surfaceTintColor: Colors.transparent,
      shadowColor: Colors.black.withValues(alpha: 0.06),
      shape: Border(
        bottom: BorderSide(
          color: cs.outlineVariant.withValues(alpha: 0.45),
          width: 0.5,
        ),
      ),
    );
  }

  Widget _buildBody(BuildContext context) {
    Widget body = widget.child;

    if (widget.enablePullToRefresh) {
      body = RefreshIndicator(
        onRefresh: _handleRefresh,
        color: _primary(context),
        backgroundColor: _surfaceColor(context),
        child: body,
      );
    }

    body = SafeArea(
      top: !widget.showAppBar && widget.customAppBar == null,
      bottom: widget.showBottomNavigation,
      child: body,
    );

    return body;
  }

  Widget _buildBottomNavigation(BuildContext context) {
    return Obx(() {
      _themeController.forceRebuildRx.value;

      return CustomBottomNavigation(
        items: navigationItems,
        currentIndex: selectedIndex.value,
        onTap: (i) => _handleBottomNavTap(context, i),
        backgroundColor: _surfaceColor(context),
        activeColor: _primary(context),
        inactiveColor: _textSecondary(context),
        elevation: _themeController.isDarkMode ? 8 : 12,
        iconSize: 26,
        showLabels: true,
        isNavigating: isNavigating.value,
      );
    });
  }

  void _handleBottomNavTap(BuildContext context, int index) {
    HapticFeedback.selectionClick();
    try {
      _navigateToTab(index);
    } catch (e) {
      debugPrint('Navigation error in MainLayout: $e');
      _showNavigationError(context);
    }
  }

  Future<void> _navigateToTab(int index) async {
    if (!_isValidIndex(index) || _isDuplicateNavigation(index)) return;

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
        if (mounted) isNavigating.value = false;
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

  void _showNavigationError(BuildContext context) {
    if (Get.isSnackbarOpen) return;

    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    Get.showSnackbar(
      GetSnackBar(
        duration: const Duration(seconds: 2),
        snackPosition: SnackPosition.BOTTOM,
        margin: const EdgeInsets.all(16),
        borderRadius: 12,
        backgroundColor: cs.error,
        messageText: Text(
          'Navigation failed. Please try again.',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: cs.onError,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}
