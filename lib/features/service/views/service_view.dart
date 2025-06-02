// lib/features/service/views/service_view.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:emababyspa/common/theme/color_theme.dart';
import 'package:emababyspa/common/widgets/custom_appbar.dart';
import 'package:emababyspa/common/widgets/empty_state_widget.dart';
import 'package:emababyspa/features/service/controllers/service_controller.dart';
import 'package:emababyspa/features/theme/controllers/theme_controller.dart';
import 'package:emababyspa/common/layouts/main_layout.dart';

class ServiceView extends GetView<ServiceController> {
  const ServiceView({super.key});

  @override
  Widget build(BuildContext context) {
    // Get theme controller instance
    final themeController = Get.find<ThemeController>();

    return MainLayout(
      child: Obx(() {
        final isDark = themeController.isDarkMode;

        return Scaffold(
          backgroundColor:
              isDark ? ColorTheme.backgroundDark : ColorTheme.background,
          appBar: CustomAppBar(
            title: 'Service Management',
            showBackButton: false,
            actions: [
              // Enhanced theme toggle button with cycle functionality
              Container(
                margin: const EdgeInsets.only(right: 8),
                decoration: BoxDecoration(
                  color: (isDark ? Colors.white : Colors.black).withValues(
                    alpha: 0.1,
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: PopupMenuButton<ThemeMode>(
                  onSelected: (ThemeMode themeMode) {
                    themeController.changeThemeMode(themeMode);
                  },
                  itemBuilder:
                      (context) => [
                        PopupMenuItem(
                          value: ThemeMode.system,
                          child: Row(
                            children: [
                              Icon(
                                Icons.brightness_auto,
                                color:
                                    themeController.isSystemMode
                                        ? (isDark
                                            ? ColorTheme.primaryLightDark
                                            : ColorTheme.primary)
                                        : (isDark
                                            ? ColorTheme.textSecondaryDark
                                            : ColorTheme.textSecondary),
                              ),
                              const SizedBox(width: 12),
                              Text(
                                'Sistem',
                                style: TextStyle(
                                  color:
                                      themeController.isSystemMode
                                          ? (isDark
                                              ? ColorTheme.primaryLightDark
                                              : ColorTheme.primary)
                                          : (isDark
                                              ? ColorTheme.textPrimaryDark
                                              : ColorTheme.textPrimary),
                                  fontWeight:
                                      themeController.isSystemMode
                                          ? FontWeight.w600
                                          : FontWeight.normal,
                                ),
                              ),
                            ],
                          ),
                        ),
                        PopupMenuItem(
                          value: ThemeMode.light,
                          child: Row(
                            children: [
                              Icon(
                                Icons.light_mode_rounded,
                                color:
                                    themeController.isLightMode &&
                                            !themeController.isSystemMode
                                        ? (isDark
                                            ? ColorTheme.primaryLightDark
                                            : ColorTheme.primary)
                                        : (isDark
                                            ? ColorTheme.textSecondaryDark
                                            : ColorTheme.textSecondary),
                              ),
                              const SizedBox(width: 12),
                              Text(
                                'Terang',
                                style: TextStyle(
                                  color:
                                      themeController.isLightMode &&
                                              !themeController.isSystemMode
                                          ? (isDark
                                              ? ColorTheme.primaryLightDark
                                              : ColorTheme.primary)
                                          : (isDark
                                              ? ColorTheme.textPrimaryDark
                                              : ColorTheme.textPrimary),
                                  fontWeight:
                                      themeController.isLightMode &&
                                              !themeController.isSystemMode
                                          ? FontWeight.w600
                                          : FontWeight.normal,
                                ),
                              ),
                            ],
                          ),
                        ),
                        PopupMenuItem(
                          value: ThemeMode.dark,
                          child: Row(
                            children: [
                              Icon(
                                Icons.dark_mode_rounded,
                                color:
                                    themeController.isDarkMode &&
                                            !themeController.isSystemMode
                                        ? (isDark
                                            ? ColorTheme.primaryLightDark
                                            : ColorTheme.primary)
                                        : (isDark
                                            ? ColorTheme.textSecondaryDark
                                            : ColorTheme.textSecondary),
                              ),
                              const SizedBox(width: 12),
                              Text(
                                'Gelap',
                                style: TextStyle(
                                  color:
                                      themeController.isDarkMode &&
                                              !themeController.isSystemMode
                                          ? (isDark
                                              ? ColorTheme.primaryLightDark
                                              : ColorTheme.primary)
                                          : (isDark
                                              ? ColorTheme.textPrimaryDark
                                              : ColorTheme.textPrimary),
                                  fontWeight:
                                      themeController.isDarkMode &&
                                              !themeController.isSystemMode
                                          ? FontWeight.w600
                                          : FontWeight.normal,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 300),
                      child: Icon(
                        themeController.themeModeIcon,
                        key: ValueKey(themeController.themeMode),
                        color: isDark ? Colors.white70 : Colors.white,
                        size: 22,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          body: SafeArea(
            child: RefreshIndicator(
              onRefresh: () async {
                await controller.refreshData();
              },
              color: isDark ? ColorTheme.primaryLightDark : ColorTheme.primary,
              backgroundColor: isDark ? ColorTheme.surfaceDark : Colors.white,
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors:
                        isDark
                            ? [
                              ColorTheme.primaryLightDark.withValues(
                                alpha: 0.05,
                              ),
                              Colors.transparent,
                            ]
                            : [
                              ColorTheme.primary.withValues(alpha: 0.03),
                              Colors.transparent,
                            ],
                    stops: const [0.0, 0.4],
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20.0,
                    vertical: 16.0,
                  ),
                  child: Obx(() {
                    if (controller.isLoading.value &&
                        controller.services.isEmpty &&
                        controller.serviceCategories.isEmpty &&
                        controller.staff.isEmpty) {
                      return _buildLoadingState(isDark);
                    }

                    if (controller.serviceError.isNotEmpty &&
                        controller.categoryError.isNotEmpty &&
                        controller.staffError.isNotEmpty) {
                      return EmptyStateWidget(
                        title: 'Connection Error',
                        message:
                            'Unable to load data. Please check your connection and try again.',
                        icon: Icons.error_outline_rounded,
                        buttonLabel: 'Refresh',
                        onButtonPressed: controller.refreshData,
                        fullScreen: true,
                      );
                    }

                    return _buildServiceContent(isDark);
                  }),
                ),
              ),
            ),
          ),
        );
      }),
    );
  }

  Widget _buildLoadingState(bool isDark) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: isDark ? ColorTheme.surfaceDark : Colors.white,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color:
                      isDark
                          ? Colors.black.withValues(alpha: 0.3)
                          : ColorTheme.primary.withValues(alpha: 0.08),
                  blurRadius: 24,
                  spreadRadius: 0,
                  offset: const Offset(0, 8),
                ),
              ],
              border:
                  isDark
                      ? Border.all(
                        color: ColorTheme.borderDark.withValues(alpha: 0.3),
                      )
                      : null,
            ),
            child: Column(
              children: [
                SizedBox(
                  width: 48,
                  height: 48,
                  child: CircularProgressIndicator(
                    strokeWidth: 3,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      isDark ? ColorTheme.primaryLightDark : ColorTheme.primary,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  'Loading Dashboard...',
                  style: TextStyle(
                    fontSize: 16,
                    color:
                        isDark
                            ? ColorTheme.textSecondaryDark
                            : ColorTheme.textSecondary,
                    fontFamily: 'JosefinSans',
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildServiceContent(bool isDark) {
    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Enhanced Header Section with better hierarchy
          _buildAnimatedSection(
            duration: const Duration(milliseconds: 600),
            delay: 0,
            child: _buildHeaderSection(isDark),
          ),

          const SizedBox(height: 28),

          // Statistics Section with improved visual hierarchy
          _buildAnimatedSection(
            duration: const Duration(milliseconds: 800),
            delay: 200,
            child: _buildStatsSection(isDark),
          ),

          const SizedBox(height: 32),

          // Management Section with modern cards
          _buildAnimatedSection(
            duration: const Duration(milliseconds: 1000),
            delay: 400,
            child: _buildManagementSection(isDark),
          ),

          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildAnimatedSection({
    required Duration duration,
    required int delay,
    required Widget child,
  }) {
    return TweenAnimationBuilder<double>(
      duration: duration,
      tween: Tween(begin: 0.0, end: 1.0),
      builder: (context, value, _) {
        return AnimatedOpacity(
          opacity: value,
          duration: Duration(milliseconds: delay),
          child: Transform.translate(
            offset: Offset(0, 30 * (1 - value)),
            child: child,
          ),
        );
      },
    );
  }

  Widget _buildHeaderSection(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors:
              isDark
                  ? [
                    ColorTheme.surfaceDark,
                    ColorTheme.surfaceDark.withValues(alpha: 0.8),
                  ]
                  : [Colors.white, ColorTheme.primary.withValues(alpha: 0.02)],
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color:
              isDark
                  ? ColorTheme.borderDark.withValues(alpha: 0.2)
                  : Colors.transparent,
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color:
                isDark
                    ? Colors.black.withValues(alpha: 0.2)
                    : Colors.black.withValues(alpha: 0.04),
            blurRadius: 20,
            offset: const Offset(0, 8),
            spreadRadius: 0,
          ),
          if (!isDark)
            BoxShadow(
              color: ColorTheme.primary.withValues(alpha: 0.05),
              blurRadius: 40,
              offset: const Offset(0, 16),
              spreadRadius: -4,
            ),
        ],
      ),
      child: Row(
        children: [
          // Enhanced icon container
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors:
                    isDark
                        ? [
                          ColorTheme.primaryLightDark,
                          ColorTheme.primaryLightDark.withValues(alpha: 0.8),
                        ]
                        : [ColorTheme.primary, ColorTheme.primaryDark],
              ),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: (isDark
                          ? ColorTheme.primaryLightDark
                          : ColorTheme.primary)
                      .withValues(alpha: 0.3),
                  blurRadius: 16,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: const Icon(
              Icons.dashboard_customize_rounded,
              color: Colors.white,
              size: 32,
            ),
          ),

          const SizedBox(width: 24),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Main title with better hierarchy
                Text(
                  'Service Dashboard',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.w700,
                    color:
                        isDark
                            ? ColorTheme.textPrimaryDark
                            : ColorTheme.textPrimary,
                    fontFamily: 'JosefinSans',
                    letterSpacing: -0.8,
                    height: 1.1,
                  ),
                ),

                const SizedBox(height: 12),

                // Subtitle with improved contrast
                Text(
                  'Comprehensive management of your spa services, staff, and categories',
                  style: TextStyle(
                    fontSize: 16,
                    color:
                        isDark
                            ? ColorTheme.textSecondaryDark
                            : ColorTheme.textSecondary,
                    fontFamily: 'JosefinSans',
                    fontWeight: FontWeight.w400,
                    height: 1.5,
                    letterSpacing: 0.2,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsSection(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section title with better hierarchy
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 20),
          child: Row(
            children: [
              Container(
                width: 4,
                height: 24,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors:
                        isDark
                            ? [
                              ColorTheme.primaryLightDark,
                              ColorTheme.primaryLightDark.withValues(
                                alpha: 0.6,
                              ),
                            ]
                            : [ColorTheme.primary, ColorTheme.primaryDark],
                  ),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'Analytics Overview',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color:
                      isDark
                          ? ColorTheme.textPrimaryDark
                          : ColorTheme.textPrimary,
                  fontFamily: 'JosefinSans',
                  letterSpacing: -0.3,
                ),
              ),
            ],
          ),
        ),

        // Stats cards with improved layout
        Row(
          children: [
            Expanded(
              child: Obx(
                () => _buildEnhancedStatCard(
                  title: 'Services',
                  count: controller.serviceCount.toString(),
                  icon: Icons.spa_rounded,
                  color:
                      isDark ? ColorTheme.primaryLightDark : ColorTheme.primary,
                  isLoading: controller.isLoadingServices.value,
                  hasError: controller.serviceError.isNotEmpty,
                  onRetry: controller.refreshServices,
                  isDark: isDark,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Obx(
                () => _buildEnhancedStatCard(
                  title: 'Staff',
                  count: controller.staffCount.toString(),
                  icon: Icons.people_rounded,
                  color: isDark ? ColorTheme.infoDark : ColorTheme.info,
                  isLoading: controller.isLoadingStaff.value,
                  hasError: controller.staffError.isNotEmpty,
                  onRetry: controller.refreshStaff,
                  isDark: isDark,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Obx(
                () => _buildEnhancedStatCard(
                  title: 'Categories',
                  count: controller.categoryCount.toString(),
                  icon: Icons.category_rounded,
                  color: isDark ? ColorTheme.successDark : ColorTheme.success,
                  isLoading: controller.isLoadingCategories.value,
                  hasError: controller.categoryError.isNotEmpty,
                  onRetry: controller.refreshCategories,
                  isDark: isDark,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildManagementSection(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section title
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 20),
          child: Row(
            children: [
              Container(
                width: 4,
                height: 24,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors:
                        isDark
                            ? [
                              ColorTheme.primaryLightDark,
                              ColorTheme.primaryLightDark.withValues(
                                alpha: 0.6,
                              ),
                            ]
                            : [ColorTheme.primary, ColorTheme.primaryDark],
                  ),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'Management Tools',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color:
                      isDark
                          ? ColorTheme.textPrimaryDark
                          : ColorTheme.textPrimary,
                  fontFamily: 'JosefinSans',
                  letterSpacing: -0.3,
                ),
              ),
            ],
          ),
        ),

        // Management cards
        _buildEnhancedManagementCard(
          title: 'Manage Services',
          subtitle: 'Add, edit, or delete spa services and treatments',
          icon: Icons.spa_rounded,
          color: isDark ? ColorTheme.primaryLightDark : ColorTheme.primary,
          onTap: controller.navigateToManageServices,
          isDark: isDark,
        ),
        const SizedBox(height: 12),
        _buildEnhancedManagementCard(
          title: 'Manage Staff',
          subtitle: 'Handle staff members and their assignments',
          icon: Icons.people_rounded,
          color: isDark ? ColorTheme.infoDark : ColorTheme.info,
          onTap: controller.navigateToManageStaff,
          isDark: isDark,
        ),
        const SizedBox(height: 12),
        _buildEnhancedManagementCard(
          title: 'Manage Categories',
          subtitle: 'Organize and categorize your service offerings',
          icon: Icons.category_rounded,
          color: isDark ? ColorTheme.successDark : ColorTheme.success,
          onTap: controller.navigateToManageCategories,
          isDark: isDark,
        ),
      ],
    );
  }

  Widget _buildEnhancedStatCard({
    required String title,
    required String count,
    required IconData icon,
    required Color color,
    required bool isLoading,
    required bool hasError,
    required VoidCallback onRetry,
    required bool isDark,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? ColorTheme.surfaceDark : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color:
              isDark
                  ? ColorTheme.borderDark.withValues(alpha: 0.3)
                  : color.withValues(alpha: 0.1),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color:
                isDark
                    ? Colors.black.withValues(alpha: 0.2)
                    : color.withValues(alpha: 0.08),
            blurRadius: 16,
            offset: const Offset(0, 4),
            spreadRadius: 0,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Icon container
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  color.withValues(alpha: 0.15),
                  color.withValues(alpha: 0.08),
                ],
              ),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, color: color, size: 24),
          ),

          const SizedBox(height: 16),

          // Count or loading/error state
          if (isLoading)
            SizedBox(
              height: 28,
              width: 28,
              child: CircularProgressIndicator(
                strokeWidth: 2.5,
                valueColor: AlwaysStoppedAnimation<Color>(color),
              ),
            )
          else if (hasError)
            GestureDetector(
              onTap: onRetry,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: (isDark ? ColorTheme.errorDark : ColorTheme.error)
                      .withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.refresh_rounded,
                      color: isDark ? ColorTheme.errorDark : ColorTheme.error,
                      size: 16,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'Retry',
                      style: TextStyle(
                        fontSize: 12,
                        color: isDark ? ColorTheme.errorDark : ColorTheme.error,
                        fontFamily: 'JosefinSans',
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            )
          else
            Text(
              count,
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w800,
                color:
                    isDark
                        ? ColorTheme.textPrimaryDark
                        : ColorTheme.textPrimary,
                fontFamily: 'JosefinSans',
                letterSpacing: -0.5,
              ),
            ),

          const SizedBox(height: 8),

          // Title
          Text(
            title,
            style: TextStyle(
              fontSize: 14,
              color:
                  isDark
                      ? ColorTheme.textSecondaryDark
                      : ColorTheme.textSecondary,
              fontFamily: 'JosefinSans',
              fontWeight: FontWeight.w600,
              letterSpacing: 0.3,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEnhancedManagementCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
    required bool isDark,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        splashColor: color.withValues(alpha: 0.1),
        highlightColor: color.withValues(alpha: 0.05),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: isDark ? ColorTheme.surfaceDark : Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color:
                  isDark
                      ? ColorTheme.borderDark.withValues(alpha: 0.3)
                      : color.withValues(alpha: 0.08),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color:
                    isDark
                        ? Colors.black.withValues(alpha: 0.15)
                        : Colors.black.withValues(alpha: 0.04),
                blurRadius: 16,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              // Enhanced icon container
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      color.withValues(alpha: 0.15),
                      color.withValues(alpha: 0.08),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(icon, color: color, size: 28),
              ),

              const SizedBox(width: 20),

              // Content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color:
                            isDark
                                ? ColorTheme.textPrimaryDark
                                : ColorTheme.textPrimary,
                        fontFamily: 'JosefinSans',
                        letterSpacing: -0.2,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 14,
                        color:
                            isDark
                                ? ColorTheme.textSecondaryDark
                                : ColorTheme.textSecondary,
                        fontFamily: 'JosefinSans',
                        fontWeight: FontWeight.w400,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),

              // Arrow icon
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: (isDark
                          ? ColorTheme.textSecondaryDark
                          : ColorTheme.textSecondary)
                      .withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  Icons.arrow_forward_ios_rounded,
                  color:
                      isDark
                          ? ColorTheme.textSecondaryDark
                          : ColorTheme.textSecondary,
                  size: 16,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
