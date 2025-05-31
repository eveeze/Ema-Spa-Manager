// lib/common/layouts/main_layout.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:emababyspa/common/theme/color_theme.dart';
import 'package:emababyspa/common/widgets/custom_bottom_navigation.dart';
import 'package:emababyspa/features/dashboard/controllers/dashboard_controller.dart';

class MainLayout extends GetView<DashboardController> {
  final Widget child;
  final bool showBottomNavigation;
  final bool enablePullToRefresh;
  final VoidCallback? onRefresh;
  final String? appBarTitle;
  final List<Widget>? appBarActions;
  final bool showAppBar;
  final PreferredSizeWidget? customAppBar;
  final Color? backgroundColor;

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
  });

  @override
  Widget build(BuildContext context) {
    return _buildMainScaffold(context);
  }

  Widget _buildMainScaffold(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor ?? ColorTheme.background,
      appBar: _buildAppBar(),
      body: _buildBody(context),
      bottomNavigationBar:
          showBottomNavigation ? _buildBottomNavigation() : null,
      resizeToAvoidBottomInset: true,
    );
  }

  PreferredSizeWidget? _buildAppBar() {
    if (customAppBar != null) return customAppBar;
    if (!showAppBar) return null;

    return AppBar(
      title:
          appBarTitle != null
              ? Text(
                appBarTitle!,
                style: TextStyle(
                  fontFamily: 'JosefinSans',
                  fontWeight: FontWeight.w600,
                  color: ColorTheme.textPrimary,
                ),
              )
              : null,
      backgroundColor: ColorTheme.surface,
      elevation: 0,
      systemOverlayStyle: SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness:
            Theme.of(Get.context!).brightness == Brightness.light
                ? Brightness.dark
                : Brightness.light,
        statusBarBrightness: Theme.of(Get.context!).brightness,
      ),
      iconTheme: IconThemeData(color: ColorTheme.textPrimary),
      actions: appBarActions,
      centerTitle: true,
      surfaceTintColor: Colors.transparent,
    );
  }

  Widget _buildBody(BuildContext context) {
    Widget body = child;

    // Add pull to refresh if enabled
    if (enablePullToRefresh) {
      body = RefreshIndicator(
        onRefresh: _handleRefresh,
        color: ColorTheme.primary,
        backgroundColor: ColorTheme.surface,
        child: body,
      );
    }

    // Add safe area padding
    body = SafeArea(bottom: showBottomNavigation, child: body);

    return body;
  }

  Widget _buildBottomNavigation() {
    return Obx(() {
      // Only rebuild when necessary values change
      final selectedIndex = controller.selectedIndex.value;
      final isNavigating = controller.isNavigating.value;
      final navigationItems = controller.navigationItems;

      return AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        transform: Matrix4.translationValues(
          0,
          isNavigating ? 2 : 0, // Subtle shift during navigation
          0,
        ),
        child: CustomBottomNavigation(
          items: navigationItems,
          currentIndex: selectedIndex,
          onTap: _handleBottomNavTap,
          backgroundColor: ColorTheme.surface,
          activeColor: ColorTheme.primary,
          inactiveColor: ColorTheme.textSecondary,
          elevation: 12,
          iconSize: 26,
          showLabels: true,
          isNavigating: isNavigating,
        ),
      );
    });
  }

  void _handleBottomNavTap(int index) {
    // Add haptic feedback for better UX
    HapticFeedback.lightImpact();

    // Delegate to controller with error handling
    try {
      controller.changeTab(index);
    } catch (e) {
      debugPrint('Navigation error in MainLayout: $e');
      // Could show a snackbar or handle error gracefully
      _showNavigationError();
    }
  }

  Future<void> _handleRefresh() async {
    if (onRefresh != null) {
      onRefresh!();
    } else {
      await controller.refreshCurrentPage();
    }
  }

  void _showNavigationError() {
    if (Get.isSnackbarOpen) return;

    Get.showSnackbar(
      GetSnackBar(
        message: 'Navigation failed. Please try again.',
        duration: const Duration(seconds: 2),
        backgroundColor: ColorTheme.error,
        margin: const EdgeInsets.all(16),
        borderRadius: 8,
        isDismissible: true,
        snackPosition: SnackPosition.BOTTOM,
      ),
    );
  }
}

// Extension for easier MainLayout usage with common configurations
extension MainLayoutExtensions on MainLayout {
  /// Creates a MainLayout with dashboard configuration
  static MainLayout dashboard({
    required Widget child,
    VoidCallback? onRefresh,
  }) {
    return MainLayout(
      showBottomNavigation: true,
      enablePullToRefresh: onRefresh != null,
      onRefresh: onRefresh,
      backgroundColor: ColorTheme.background,
      child: child,
    );
  }

  /// Creates a MainLayout with form/detail page configuration
  static MainLayout form({
    required Widget child,
    String? title,
    List<Widget>? actions,
  }) {
    return MainLayout(
      showBottomNavigation: false,
      showAppBar: true,
      appBarTitle: title,
      appBarActions: actions,
      backgroundColor: ColorTheme.background,
      child: child,
    );
  }

  /// Creates a MainLayout with custom app bar
  static MainLayout withCustomAppBar({
    required Widget child,
    required PreferredSizeWidget appBar,
    bool showBottomNav = true,
  }) {
    return MainLayout(
      customAppBar: appBar,
      showBottomNavigation: showBottomNav,
      backgroundColor: ColorTheme.background,
      child: child,
    );
  }
}

// Utility class for consistent layout configurations
class LayoutConfig {
  static const EdgeInsets defaultPadding = EdgeInsets.all(16.0);
  static const EdgeInsets horizontalPadding = EdgeInsets.symmetric(
    horizontal: 16.0,
  );
  static const EdgeInsets verticalPadding = EdgeInsets.symmetric(
    vertical: 16.0,
  );

  // Bottom navigation safe area height
  static double getBottomNavHeight(BuildContext context) {
    return MediaQuery.of(context).padding.bottom + 80; // Nav height + padding
  }

  // Content padding that accounts for bottom navigation
  static EdgeInsets getContentPadding(
    BuildContext context, {
    bool hasBottomNav = true,
  }) {
    return EdgeInsets.only(
      left: 16,
      right: 16,
      top: 16,
      bottom: hasBottomNav ? getBottomNavHeight(context) : 16,
    );
  }
}
