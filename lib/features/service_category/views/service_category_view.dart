// lib/features/service_category/views/service_category_view.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:emababyspa/common/theme/color_theme.dart';
import 'package:emababyspa/common/widgets/custom_appbar.dart';
import 'package:emababyspa/common/widgets/empty_state_widget.dart';
import 'package:emababyspa/common/layouts/main_layout.dart';
import 'package:emababyspa/features/service_category/controllers/service_category_controller.dart';
import 'package:emababyspa/features/theme/controllers/theme_controller.dart';
import 'package:emababyspa/data/models/service_category.dart';
import 'package:emababyspa/utils/app_routes.dart';

class ServiceCategoryView extends GetView<ServiceCategoryController> {
  const ServiceCategoryView({super.key});

  @override
  Widget build(BuildContext context) {
    final ThemeController themeController = Get.find<ThemeController>();

    return MainLayout(
      // Set parent route to services untuk menjaga state bottom navbar
      parentRoute: AppRoutes.services,
      // Gunakan custom app bar
      customAppBar: const CustomAppBar(
        title: 'Service Categories',
        showBackButton: true,
      ),
      // Floating Action Button
      floatingActionButton: Obx(() {
        final ThemeController themeController = Get.find<ThemeController>();
        final bool isDarkMode = themeController.isDarkMode;
        final Color primaryColor =
            isDarkMode ? ColorTheme.primaryLightDark : ColorTheme.primary;

        return FloatingActionButton.extended(
          onPressed: () {
            controller.navigateToAddServiceCategory();
          },
          backgroundColor: primaryColor,
          icon: Icon(
            Icons.add_circle_outline,
            color: isDarkMode ? Colors.black : Colors.white,
          ),
          label: Text(
            'Add Category',
            style: TextStyle(
              color: isDarkMode ? Colors.black : Colors.white,
              fontWeight: FontWeight.w600,
              fontFamily: 'JosefinSans',
            ),
          ),
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        );
      }),
      child: Obx(() {
        final bool isDarkMode = themeController.isDarkMode;
        final Color backgroundColor =
            isDarkMode ? ColorTheme.backgroundDark : ColorTheme.background;
        final Color surfaceColor =
            isDarkMode ? ColorTheme.surfaceDark : Colors.white;
        final Color textPrimaryColor =
            isDarkMode ? ColorTheme.textPrimaryDark : ColorTheme.textPrimary;
        final Color textSecondaryColor =
            isDarkMode
                ? ColorTheme.textSecondaryDark
                : ColorTheme.textSecondary;
        final Color borderColor =
            isDarkMode ? ColorTheme.borderDark : ColorTheme.border;
        final Color primaryColor =
            isDarkMode ? ColorTheme.primaryLightDark : ColorTheme.primary;

        return Container(
          color: backgroundColor,
          child: Column(
            children: [
              // Main content
              Expanded(
                child: RefreshIndicator(
                  onRefresh: () async {
                    controller.refreshData();
                  },
                  color: primaryColor,
                  backgroundColor: surfaceColor,
                  strokeWidth: 2.5,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20.0,
                      vertical: 16.0,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Enhanced Animated Header
                        TweenAnimationBuilder(
                          tween: Tween<double>(begin: 0, end: 1),
                          duration: const Duration(milliseconds: 800),
                          curve: Curves.easeOutQuart,
                          builder: (context, value, child) {
                            return Opacity(
                              opacity: value,
                              child: Transform.translate(
                                offset: Offset(0, 20 * (1 - value)),
                                child: child,
                              ),
                            );
                          },
                          child: Container(
                            padding: const EdgeInsets.only(
                              left: 8,
                              right: 8,
                              bottom: 16,
                            ),
                            decoration: BoxDecoration(
                              border: Border(
                                bottom: BorderSide(
                                  color: borderColor.withValues(alpha: 0.5),
                                  width: 1,
                                ),
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Prettier header with gradient icon background
                                Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(10),
                                      decoration: BoxDecoration(
                                        gradient: LinearGradient(
                                          colors: [
                                            primaryColor.withValues(alpha: 0.2),
                                            primaryColor.withValues(
                                              alpha: 0.05,
                                            ),
                                          ],
                                          begin: Alignment.topLeft,
                                          end: Alignment.bottomRight,
                                        ),
                                        borderRadius: BorderRadius.circular(14),
                                      ),
                                      child: Icon(
                                        Icons.spa_rounded,
                                        size: 28,
                                        color: primaryColor,
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Text(
                                      'Service Categories',
                                      style: TextStyle(
                                        fontSize: 26,
                                        fontWeight: FontWeight.bold,
                                        color: textPrimaryColor,
                                        fontFamily: 'JosefinSans',
                                        letterSpacing: 0.5,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 10),
                                // Subtitle with shadow and gradient
                                Padding(
                                  padding: const EdgeInsets.only(left: 50.0),
                                  child: Container(
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        colors: [
                                          primaryColor.withValues(alpha: 0.1),
                                          Colors.transparent,
                                        ],
                                        begin: Alignment.centerLeft,
                                        end: Alignment.centerRight,
                                      ),
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 6,
                                    ),
                                    child: Text(
                                      'Manage your spa service categories',
                                      style: TextStyle(
                                        fontSize: 15,
                                        color: textSecondaryColor,
                                        fontFamily: 'JosefinSans',
                                        fontStyle: FontStyle.italic,
                                        shadows:
                                            isDarkMode
                                                ? []
                                                : [
                                                  Shadow(
                                                    color: Colors.white,
                                                    offset: Offset(0, 1),
                                                    blurRadius: 1,
                                                  ),
                                                ],
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),

                        // Categories count with animated counter
                        Obx(
                          () =>
                              !controller.isLoading.value &&
                                      controller.serviceCategories.isNotEmpty
                                  ? Padding(
                                    padding: const EdgeInsets.only(
                                      left: 12.0,
                                      top: 16.0,
                                      bottom: 16.0,
                                    ),
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 16,
                                        vertical: 8,
                                      ),
                                      decoration: BoxDecoration(
                                        color: primaryColor.withValues(
                                          alpha: 0.1,
                                        ),
                                        borderRadius: BorderRadius.circular(30),
                                        border: Border.all(
                                          color: primaryColor.withValues(
                                            alpha: 0.3,
                                          ),
                                          width: 1,
                                        ),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Icon(
                                            Icons.category_rounded,
                                            size: 18,
                                            color: primaryColor,
                                          ),
                                          const SizedBox(width: 8),
                                          TweenAnimationBuilder(
                                            duration: const Duration(
                                              milliseconds: 800,
                                            ),
                                            tween: IntTween(
                                              begin: 0,
                                              end:
                                                  controller
                                                      .serviceCategories
                                                      .length,
                                            ),
                                            builder: (context, value, child) {
                                              return Text(
                                                '$value categories available',
                                                style: TextStyle(
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.w600,
                                                  color: primaryColor,
                                                  fontFamily: 'JosefinSans',
                                                ),
                                              );
                                            },
                                          ),
                                        ],
                                      ),
                                    ),
                                  )
                                  : const SizedBox.shrink(),
                        ),

                        // Categories list with improved loading animation
                        Expanded(
                          child: Obx(() {
                            if (controller.isLoading.value) {
                              return Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    // Enhanced loading spinner
                                    TweenAnimationBuilder(
                                      tween: Tween<double>(begin: 0, end: 1),
                                      duration: const Duration(
                                        milliseconds: 1500,
                                      ),
                                      builder: (context, value, child) {
                                        return Transform.scale(
                                          scale: 0.8 + (value * 0.2),
                                          child: Container(
                                            width: 80,
                                            height: 80,
                                            padding: const EdgeInsets.all(15),
                                            decoration: BoxDecoration(
                                              color: surfaceColor,
                                              borderRadius:
                                                  BorderRadius.circular(20),
                                              boxShadow: [
                                                BoxShadow(
                                                  color: primaryColor
                                                      .withValues(alpha: 0.2),
                                                  blurRadius: 20,
                                                  spreadRadius: 0,
                                                ),
                                              ],
                                            ),
                                            child: CircularProgressIndicator(
                                              valueColor:
                                                  AlwaysStoppedAnimation<Color>(
                                                    primaryColor,
                                                  ),
                                              strokeWidth: 3,
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                                    const SizedBox(height: 24),
                                    Text(
                                      'Loading categories...',
                                      style: TextStyle(
                                        color: textSecondaryColor,
                                        fontFamily: 'JosefinSans',
                                        fontSize: 16,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }

                            if (controller.errorMessage.isNotEmpty) {
                              return EmptyStateWidget(
                                title: 'Oops!',
                                message: controller.errorMessage.value,
                                icon: Icons.error_outline_rounded,
                                buttonLabel: 'Refresh',
                                onButtonPressed: controller.refreshData,
                                fullScreen: false,
                              );
                            }

                            if (controller.serviceCategories.isEmpty) {
                              return EmptyStateWidget(
                                title: 'No Categories Found',
                                message:
                                    'You haven\'t added any service categories yet.',
                                icon: Icons.category_outlined,
                                buttonLabel: 'Add Category',
                                onButtonPressed: () {
                                  controller.navigateToAddServiceCategory();
                                },
                                fullScreen: false,
                              );
                            }

                            return _buildCategoriesList(
                              isDarkMode: isDarkMode,
                              surfaceColor: surfaceColor,
                              textPrimaryColor: textPrimaryColor,
                              textSecondaryColor: textSecondaryColor,
                              primaryColor: primaryColor,
                            );
                          }),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildCategoriesList({
    required bool isDarkMode,
    required Color surfaceColor,
    required Color textPrimaryColor,
    required Color textSecondaryColor,
    required Color primaryColor,
  }) {
    return ListView.builder(
      physics: const BouncingScrollPhysics(),
      itemCount: controller.serviceCategories.length,
      padding: const EdgeInsets.only(
        top: 8,
        bottom: 100,
      ), // Add padding at bottom for FAB
      itemBuilder: (context, index) {
        final category = controller.serviceCategories[index];
        // Enhanced staggered animation
        return AnimatedBuilder(
          animation: AlwaysStoppedAnimation((index * 0.2).clamp(0.0, 1.0)),
          builder: (context, child) {
            return TweenAnimationBuilder(
              tween: Tween<double>(begin: 0, end: 1),
              duration: Duration(milliseconds: 600 + (index * 100)),
              curve: Curves.easeOutQuint,
              builder: (context, value, _) {
                return Opacity(
                  opacity: value,
                  child: Transform.translate(
                    offset: Offset(0, 30 * (1 - value)),
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 16.0),
                      child: _buildCategoryCard(
                        category,
                        index,
                        isDarkMode: isDarkMode,
                        surfaceColor: surfaceColor,
                        textPrimaryColor: textPrimaryColor,
                        textSecondaryColor: textSecondaryColor,
                        primaryColor: primaryColor,
                      ),
                    ),
                  ),
                );
              },
            );
          },
        );
      },
    );
  }

  Widget _buildCategoryCard(
    ServiceCategory category,
    int index, {
    required bool isDarkMode,
    required Color surfaceColor,
    required Color textPrimaryColor,
    required Color textSecondaryColor,
    required Color primaryColor,
  }) {
    // Enhanced pastel colors for each category - adjusted for dark mode
    final List<List<Color>> lightGradients = [
      [Color(0xFFE6F7FF), Color(0xFFCCEBFF)], // Light Blue
      [Color(0xFFFFF3E6), Color(0xFFFFE6CC)], // Light Orange
      [Color(0xFFE6FFFA), Color(0xFFCCFFF5)], // Light Teal
      [Color(0xFFF5E6FF), Color(0xFFEBCCFF)], // Light Purple
      [Color(0xFFFFE6E6), Color(0xFFFFCCCC)], // Light Red
      [Color(0xFFE6FFE6), Color(0xFFCCFFCC)], // Light Green
    ];

    final List<List<Color>> darkGradients = [
      [Color(0xFF1A365D), Color(0xFF2C5282)], // Dark Blue
      [Color(0xFF7C2D12), Color(0xFF9A2B00)], // Dark Orange
      [Color(0xFF134E4A), Color(0xFF0F766E)], // Dark Teal
      [Color(0xFF581C87), Color(0xFF7C3AED)], // Dark Purple
      [Color(0xFF7F1D1D), Color(0xFF991B1B)], // Dark Red
      [Color(0xFF14532D), Color(0xFF15803D)], // Dark Green
    ];

    final List<Color> gradientColors =
        isDarkMode
            ? darkGradients[index % darkGradients.length]
            : lightGradients[index % lightGradients.length];

    final Color iconColor = primaryColor;
    final Color cardShadowColor =
        isDarkMode
            ? Colors.black.withValues(alpha: 0.3)
            : Colors.black.withValues(alpha: 0.05);

    return Container(
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: cardShadowColor,
            blurRadius: 15,
            offset: const Offset(0, 8),
            spreadRadius: 0,
          ),
          BoxShadow(
            color: gradientColors[0].withValues(alpha: isDarkMode ? 0.3 : 0.5),
            blurRadius: 8,
            offset: const Offset(0, 2),
            spreadRadius: -2,
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(20),
        child: InkWell(
          onTap: () {
            controller.navigateToEditServiceCategory(category.id);
          },
          borderRadius: BorderRadius.circular(20),
          splashColor: gradientColors[0].withValues(alpha: 0.3),
          highlightColor: gradientColors[0].withValues(alpha: 0.1),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                // Prettier category icon with gradient background
                Container(
                  width: 75,
                  height: 75,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: gradientColors,
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(18),
                    boxShadow: [
                      BoxShadow(
                        color: gradientColors[0].withValues(
                          alpha: isDarkMode ? 0.4 : 0.5,
                        ),
                        blurRadius: 8,
                        spreadRadius: 0,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Center(
                    child: Icon(
                      Icons.spa_rounded,
                      size: 36,
                      color: isDarkMode ? Colors.white : iconColor,
                    ),
                  ),
                ),
                const SizedBox(width: 20),

                // Enhanced category info with better typography
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        category.name,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: textPrimaryColor,
                          fontFamily: 'JosefinSans',
                          letterSpacing: 0.2,
                        ),
                      ),
                      const SizedBox(height: 6),
                      if (category.description != null &&
                          category.description!.isNotEmpty)
                        Container(
                          padding: const EdgeInsets.symmetric(vertical: 4),
                          child: Text(
                            category.description!,
                            style: TextStyle(
                              fontSize: 14,
                              color: textSecondaryColor,
                              fontFamily: 'JosefinSans',
                              height: 1.3,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      const SizedBox(height: 8),

                      // Enhanced service count indicator
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [gradientColors[0], gradientColors[1]],
                            begin: Alignment.centerLeft,
                            end: Alignment.centerRight,
                          ),
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: gradientColors[0].withValues(alpha: 0.4),
                              blurRadius: 4,
                              spreadRadius: 0,
                              offset: const Offset(0, 1),
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.check_circle_outline,
                              size: 14,
                              color: isDarkMode ? Colors.white : iconColor,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              '${(index + 1) * 3} Services',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: isDarkMode ? Colors.white : iconColor,
                                fontFamily: 'JosefinSans',
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                // Prettier action buttons with glass effect
                Container(
                  decoration: BoxDecoration(
                    color: surfaceColor.withValues(alpha: 0.9),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color:
                            isDarkMode
                                ? Colors.black.withValues(alpha: 0.2)
                                : Colors.black.withValues(alpha: 0.04),
                        blurRadius: 8,
                        offset: const Offset(0, 3),
                      ),
                    ],
                    border: Border.all(
                      color:
                          isDarkMode
                              ? Colors.white.withValues(alpha: 0.1)
                              : Colors.white.withValues(alpha: 0.8),
                      width: 1.5,
                    ),
                  ),
                  child: Column(
                    children: [
                      // Edit button with hover effect
                      Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: () {
                            controller.navigateToEditServiceCategory(
                              category.id,
                            );
                          },
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(16),
                            topRight: Radius.circular(16),
                          ),
                          child: Padding(
                            padding: EdgeInsets.all(12),
                            child: Icon(
                              Icons.edit_outlined,
                              color:
                                  isDarkMode
                                      ? ColorTheme.primaryLightDark
                                      : ColorTheme.info,
                              size: 24,
                            ),
                          ),
                        ),
                      ),
                      // Divider with gradient
                      Container(
                        height: 1.5,
                        width: 36,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Colors.grey.withValues(alpha: 0),
                              Colors.grey.withValues(
                                alpha: isDarkMode ? 0.4 : 0.2,
                              ),
                              Colors.grey.withValues(alpha: 0),
                            ],
                            begin: Alignment.centerLeft,
                            end: Alignment.centerRight,
                          ),
                        ),
                      ),
                      // Delete button with hover effect
                      Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap:
                              () => controller.showDeleteConfirmation(
                                category.id,
                                category.name,
                              ),
                          borderRadius: BorderRadius.only(
                            bottomLeft: Radius.circular(16),
                            bottomRight: Radius.circular(16),
                          ),
                          child: Padding(
                            padding: EdgeInsets.all(12),
                            child: Icon(
                              Icons.delete_outline_rounded,
                              color:
                                  isDarkMode
                                      ? ColorTheme.errorDark
                                      : ColorTheme.error,
                              size: 24,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
