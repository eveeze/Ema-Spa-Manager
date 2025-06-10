// lib/features/service/views/service_view.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:emababyspa/common/theme/color_theme.dart';
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
        final backgroundColor =
            isDark ? ColorTheme.backgroundDark : ColorTheme.background;

        return Scaffold(
          backgroundColor: backgroundColor,

          body: RefreshIndicator(
            onRefresh: () async {
              await controller.refreshData();
            },
            color: ColorTheme.primary,
            backgroundColor: isDark ? ColorTheme.surfaceDark : Colors.white,
            child: Container(
              color: backgroundColor,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
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
            padding: const EdgeInsets.all(40),
            decoration: BoxDecoration(
              color: isDark ? ColorTheme.surfaceDark : Colors.white,
              borderRadius: BorderRadius.circular(32),
              border: Border.all(
                color: ColorTheme.primary.withValues(alpha: 0.1),
                width: 1,
              ),
            ),
            child: Column(
              children: [
                SizedBox(
                  width: 52,
                  height: 52,
                  child: CircularProgressIndicator(
                    strokeWidth: 4,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      ColorTheme.primary,
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  'Loading Dashboard...',
                  style: TextStyle(
                    fontSize: 18,
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
      physics: const AlwaysScrollableScrollPhysics(
        parent: ClampingScrollPhysics(),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 8),
          // Analytics Overview with Clean Design
          _buildAnimatedSection(
            duration: const Duration(milliseconds: 800),
            delay: 200,
            child: _buildCleanStatsSection(isDark),
          ),

          const SizedBox(height: 12),
          // Management Section with proper spacing
          _buildAnimatedSection(
            duration: const Duration(milliseconds: 1000),
            delay: 400,
            child: _buildCleanManagementSection(isDark),
          ),

          // Bottom padding to prevent content being cut off by bottom navbar
          SizedBox(height: MediaQuery.of(Get.context!).padding.bottom + 16),
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

  Widget _buildCleanStatsSection(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section header with clean styling
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 16),
          child: Row(
            children: [
              Container(
                width: 6,
                height: 24,
                decoration: BoxDecoration(
                  color: ColorTheme.primary,
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
              const SizedBox(width: 16),
              Text(
                'Analytics Overview',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                  color:
                      isDark
                          ? ColorTheme.textPrimaryDark
                          : ColorTheme.textPrimary,
                  fontFamily: 'JosefinSans',
                  letterSpacing: -0.5,
                ),
              ),
            ],
          ),
        ),

        // NEW Layout: 2 cards on left, 1 larger card on right
        LayoutBuilder(
          builder: (context, constraints) {
            final screenWidth = constraints.maxWidth;

            return SizedBox(
              height: 220, // Fixed height for the entire analytics section
              child: Row(
                children: [
                  // Left side: 2 smaller cards stacked vertically (60% width)
                  Expanded(
                    flex: 6,
                    child: Column(
                      children: [
                        // Services card
                        Expanded(
                          child: Container(
                            margin: const EdgeInsets.only(right: 8, bottom: 6),
                            child: Obx(
                              () => _buildCleanStatCard(
                                title: 'Total Services',
                                count: controller.serviceCount.toString(),
                                isLoading: controller.isLoadingServices.value,
                                hasError: controller.serviceError.isNotEmpty,
                                onRetry: controller.refreshServices,
                                isDark: isDark,
                                screenWidth: screenWidth,
                                cardType: CardType.primary,
                                isCompact: true,
                              ),
                            ),
                          ),
                        ),

                        // Staff card
                        Expanded(
                          child: Container(
                            margin: const EdgeInsets.only(right: 8, top: 6),
                            child: Obx(
                              () => _buildCleanStatCard(
                                title: 'Staff Members',
                                count: controller.staffCount.toString(),
                                isLoading: controller.isLoadingStaff.value,
                                hasError: controller.staffError.isNotEmpty,
                                onRetry: controller.refreshStaff,
                                isDark: isDark,
                                screenWidth: screenWidth,
                                cardType: CardType.secondary,
                                isCompact: true,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Right side: 1 larger card (40% width)
                  Expanded(
                    flex: 4,
                    child: Container(
                      margin: const EdgeInsets.only(left: 8),
                      child: Obx(
                        () => _buildCleanStatCard(
                          title: 'Categories',
                          count: controller.categoryCount.toString(),
                          isLoading: controller.isLoadingCategories.value,
                          hasError: controller.categoryError.isNotEmpty,
                          onRetry: controller.refreshCategories,
                          isDark: isDark,
                          screenWidth: screenWidth,
                          cardType: CardType.accent,
                          isCompact: false,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildCleanStatCard({
    required String title,
    required String count,
    required bool isLoading,
    required bool hasError,
    required VoidCallback onRetry,
    required bool isDark,
    required double screenWidth,
    required CardType cardType,
    bool isCompact = false,
  }) {
    // Consistent card styling for all cards - NO SHADOWS
    final cardPadding = isCompact ? 12.0 : 16.0;
    final countFontSize =
        isCompact
            ? (screenWidth > 360 ? 20.0 : 18.0)
            : (screenWidth > 360 ? 32.0 : 28.0);
    final titleFontSize =
        isCompact
            ? (screenWidth > 360 ? 11.0 : 10.0)
            : (screenWidth > 360 ? 14.0 : 13.0);

    // Define colors based on card type - clean design
    Color backgroundColor;
    Color textColor;
    Color secondaryTextColor;
    Gradient? gradient;
    Border? border;

    switch (cardType) {
      case CardType.primary:
        // Clean blue gradient card
        backgroundColor = ColorTheme.primary;
        textColor = Colors.white;
        secondaryTextColor = Colors.white.withValues(alpha: 0.9);
        gradient = LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [ColorTheme.primary, ColorTheme.secondary],
          stops: const [0.0, 1.0],
        );
        border = null;
        break;

      case CardType.accent:
        // Clean secondary blue card
        backgroundColor = ColorTheme.secondary;
        textColor = Colors.white;
        secondaryTextColor = Colors.white.withValues(alpha: 0.9);
        gradient = LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [ColorTheme.secondary, ColorTheme.primaryDark],
          stops: const [0.0, 1.0],
        );
        border = null;
        break;

      case CardType.secondary:
        // Clean light card with subtle border
        backgroundColor = isDark ? ColorTheme.surfaceDark : Colors.white;
        textColor =
            isDark ? ColorTheme.textPrimaryDark : ColorTheme.textPrimary;
        secondaryTextColor =
            isDark ? ColorTheme.textSecondaryDark : ColorTheme.textSecondary;
        gradient = null;
        border = Border.all(
          color: ColorTheme.primary.withValues(alpha: 0.08),
          width: 1,
        );
        break;
    }

    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: BoxDecoration(
        color: gradient == null ? backgroundColor : null,
        gradient: gradient,
        borderRadius: BorderRadius.circular(20),
        border: border,
        // NO BOX SHADOW - completely clean design
      ),
      child: Container(
        padding: EdgeInsets.all(cardPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            // Count or loading/error state
            if (isLoading)
              Center(
                child: SizedBox(
                  height: isCompact ? 20 : 24,
                  width: isCompact ? 20 : 24,
                  child: CircularProgressIndicator(
                    strokeWidth: 3,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      gradient != null ? Colors.white : ColorTheme.primary,
                    ),
                  ),
                ),
              )
            else if (hasError)
              Center(
                child: GestureDetector(
                  onTap: onRetry,
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: isCompact ? 8 : 12,
                      vertical: isCompact ? 4 : 6,
                    ),
                    decoration: BoxDecoration(
                      color: (gradient != null
                              ? Colors.white
                              : ColorTheme.error)
                          .withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.refresh_rounded,
                          color:
                              gradient != null
                                  ? Colors.white
                                  : ColorTheme.error,
                          size: isCompact ? 12 : 14,
                        ),
                        SizedBox(width: isCompact ? 4 : 6),
                        Text(
                          'Retry',
                          style: TextStyle(
                            fontSize: isCompact ? 10 : 11,
                            color:
                                gradient != null
                                    ? Colors.white
                                    : ColorTheme.error,
                            fontFamily: 'JosefinSans',
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              )
            else
              Text(
                count,
                style: TextStyle(
                  fontSize: countFontSize,
                  fontWeight: FontWeight.w900,
                  color: textColor,
                  fontFamily: 'JosefinSans',
                  letterSpacing: -1.2,
                  height: 1.0,
                ),
              ),

            // Title with flexible layout
            Flexible(
              child: Text(
                title,
                style: TextStyle(
                  fontSize: titleFontSize,
                  color: secondaryTextColor,
                  fontFamily: 'JosefinSans',
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.2,
                  height: 1.2,
                ),
                maxLines: isCompact ? 1 : 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCleanManagementSection(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section title
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 16),
          child: Row(
            children: [
              Container(
                width: 6,
                height: 24,
                decoration: BoxDecoration(
                  color: ColorTheme.primary,
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
              const SizedBox(width: 16),
              Text(
                'Management Tools',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                  color:
                      isDark
                          ? ColorTheme.textPrimaryDark
                          : ColorTheme.textPrimary,
                  fontFamily: 'JosefinSans',
                  letterSpacing: -0.5,
                ),
              ),
            ],
          ),
        ),

        // Management cards with clean design
        _buildCleanManagementCard(
          title: 'Manage Services',
          subtitle: 'Add, edit, or delete spa services and treatments',
          imagePath: 'assets/icons/service.png',
          onTap: controller.navigateToManageServices,
          isDark: isDark,
        ),
        const SizedBox(height: 12),
        _buildCleanManagementCard(
          title: 'Manage Staff',
          subtitle: 'Handle staff members and their assignments',
          imagePath: 'assets/icons/staff.png',
          onTap: controller.navigateToManageStaff,
          isDark: isDark,
        ),
        const SizedBox(height: 12),
        _buildCleanManagementCard(
          title: 'Manage Categories',
          subtitle: 'Organize and categorize your service offerings',
          imagePath: 'assets/icons/service_category.png',
          onTap: controller.navigateToManageCategories,
          isDark: isDark,
        ),
      ],
    );
  }

  Widget _buildCleanManagementCard({
    required String title,
    required String subtitle,
    required String imagePath,
    required VoidCallback onTap,
    required bool isDark,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        splashColor: ColorTheme.primary.withValues(alpha: 0.1),
        highlightColor: ColorTheme.primary.withValues(alpha: 0.05),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: isDark ? ColorTheme.surfaceDark : Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: ColorTheme.primary.withValues(alpha: 0.08),
              width: 1,
            ),
            // NO BOX SHADOW - completely clean design
          ),
          child: Row(
            children: [
              // Image instead of icon with container background
              SizedBox(
                width:
                    52, // Same total size as previous container (padding 14*2 + icon 24)
                height: 52,
                child: Image.asset(
                  imagePath,
                  width: 100,
                  height: 100,
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) {
                    // Fallback to original icon if image fails to load
                    return Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: ColorTheme.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Icon(
                        title.contains('Service')
                            ? Icons.spa_rounded
                            : title.contains('Staff')
                            ? Icons.people_rounded
                            : Icons.category_rounded,
                        color: ColorTheme.primary,
                        size: 24,
                      ),
                    );
                  },
                ),
              ),

              const SizedBox(width: 16),

              // Content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color:
                            isDark
                                ? ColorTheme.textPrimaryDark
                                : ColorTheme.textPrimary,
                        fontFamily: 'JosefinSans',
                        letterSpacing: -0.2,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 13,
                        color:
                            isDark
                                ? ColorTheme.textSecondaryDark
                                : ColorTheme.textSecondary,
                        fontFamily: 'JosefinSans',
                        fontWeight: FontWeight.w500,
                        height: 1.3,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),

              // Arrow with clean design
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: ColorTheme.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  Icons.arrow_forward_ios_rounded,
                  color: ColorTheme.primary,
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

// Enum for card types
enum CardType { primary, secondary, accent }
