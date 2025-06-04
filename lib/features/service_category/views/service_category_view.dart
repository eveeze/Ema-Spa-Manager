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
            size: 20,
          ),
          label: Text(
            'Add Category',
            style: TextStyle(
              color: isDarkMode ? Colors.black : Colors.white,
              fontWeight: FontWeight.w600,
              fontFamily: 'JosefinSans',
              fontSize: 15,
            ),
          ),
          elevation: 8,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
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
                      horizontal: 24.0,
                      vertical: 20.0,
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
                            padding: const EdgeInsets.only(bottom: 24),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Modern header with improved spacing
                                Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(12),
                                      decoration: BoxDecoration(
                                        gradient: LinearGradient(
                                          colors: [
                                            primaryColor.withValues(
                                              alpha: 0.15,
                                            ),
                                            primaryColor.withValues(
                                              alpha: 0.05,
                                            ),
                                          ],
                                          begin: Alignment.topLeft,
                                          end: Alignment.bottomRight,
                                        ),
                                        borderRadius: BorderRadius.circular(16),
                                        border: Border.all(
                                          color: primaryColor.withValues(
                                            alpha: 0.2,
                                          ),
                                          width: 1.5,
                                        ),
                                      ),
                                      child: Icon(
                                        Icons.spa_rounded,
                                        size: 32,
                                        color: primaryColor,
                                      ),
                                    ),
                                    const SizedBox(width: 16),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'Service Categories',
                                            style: TextStyle(
                                              fontSize: 28,
                                              fontWeight: FontWeight.bold,
                                              color: textPrimaryColor,
                                              fontFamily: 'JosefinSans',
                                              letterSpacing: 0.3,
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            'Manage your spa service categories',
                                            style: TextStyle(
                                              fontSize: 16,
                                              color: textSecondaryColor,
                                              fontFamily: 'JosefinSans',
                                              fontWeight: FontWeight.w400,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),

                        // Categories count with modern design
                        Obx(
                          () =>
                              !controller.isLoading.value &&
                                      controller.serviceCategories.isNotEmpty
                                  ? Padding(
                                    padding: const EdgeInsets.only(
                                      bottom: 20.0,
                                    ),
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 20,
                                        vertical: 12,
                                      ),
                                      decoration: BoxDecoration(
                                        color: primaryColor.withValues(
                                          alpha: 0.08,
                                        ),
                                        borderRadius: BorderRadius.circular(16),
                                        border: Border.all(
                                          color: primaryColor.withValues(
                                            alpha: 0.2,
                                          ),
                                          width: 1,
                                        ),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Container(
                                            padding: const EdgeInsets.all(6),
                                            decoration: BoxDecoration(
                                              color: primaryColor.withValues(
                                                alpha: 0.15,
                                              ),
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                            ),
                                            child: Icon(
                                              Icons.category_rounded,
                                              size: 18,
                                              color: primaryColor,
                                            ),
                                          ),
                                          const SizedBox(width: 12),
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
                                                  fontSize: 15,
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
                      padding: const EdgeInsets.only(bottom: 20.0),
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
    // Modern minimal colors for each category
    final List<Color> accentColors = [
      Color(0xFF6366F1), // Indigo
      Color(0xFF8B5CF6), // Violet
      Color(0xFF06B6D4), // Cyan
      Color(0xFF10B981), // Emerald
      Color(0xFFF59E0B), // Amber
      Color(0xFFEF4444), // Red
      Color(0xFFEC4899), // Pink
      Color(0xFF84CC16), // Lime
    ];

    final Color accentColor = accentColors[index % accentColors.length];
    final Color cardShadowColor =
        isDarkMode
            ? Colors.black.withValues(alpha: 0.4)
            : Colors.black.withValues(alpha: 0.08);

    return Container(
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color:
              isDarkMode
                  ? Colors.white.withValues(alpha: 0.08)
                  : Colors.black.withValues(alpha: 0.06),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: cardShadowColor,
            blurRadius: 20,
            offset: const Offset(0, 10),
            spreadRadius: 0,
          ),
          BoxShadow(
            color: accentColor.withValues(alpha: isDarkMode ? 0.1 : 0.05),
            blurRadius: 15,
            offset: const Offset(0, 5),
            spreadRadius: -3,
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
          splashColor: accentColor.withValues(alpha: 0.1),
          highlightColor: accentColor.withValues(alpha: 0.05),
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Row(
              children: [
                // Modern category icon
                Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    color: accentColor.withValues(
                      alpha: isDarkMode ? 0.2 : 0.1,
                    ),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: accentColor.withValues(
                        alpha: isDarkMode ? 0.3 : 0.2,
                      ),
                      width: 1.5,
                    ),
                  ),
                  child: Center(
                    child: Icon(
                      Icons.spa_rounded,
                      size: 28,
                      color: accentColor,
                    ),
                  ),
                ),
                const SizedBox(width: 20),

                // Enhanced category info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        category.name,
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: textPrimaryColor,
                          fontFamily: 'JosefinSans',
                          letterSpacing: 0.2,
                        ),
                      ),
                      if (category.description != null &&
                          category.description!.isNotEmpty) ...[
                        const SizedBox(height: 8),
                        Text(
                          category.description!,
                          style: TextStyle(
                            fontSize: 15,
                            color: textSecondaryColor,
                            fontFamily: 'JosefinSans',
                            height: 1.4,
                            fontWeight: FontWeight.w400,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ],
                  ),
                ),

                // Modern action buttons
                Container(
                  decoration: BoxDecoration(
                    color:
                        isDarkMode
                            ? Colors.white.withValues(alpha: 0.05)
                            : Colors.black.withValues(alpha: 0.02),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color:
                          isDarkMode
                              ? Colors.white.withValues(alpha: 0.1)
                              : Colors.black.withValues(alpha: 0.08),
                      width: 1,
                    ),
                  ),
                  child: Column(
                    children: [
                      // Edit button
                      Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: () {
                            controller.navigateToEditServiceCategory(
                              category.id,
                            );
                          },
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(14),
                            topRight: Radius.circular(14),
                          ),
                          child: Container(
                            padding: EdgeInsets.all(14),
                            child: Icon(
                              Icons.edit_outlined,
                              color:
                                  isDarkMode
                                      ? ColorTheme.primaryLightDark
                                      : ColorTheme.info,
                              size: 22,
                            ),
                          ),
                        ),
                      ),
                      // Divider
                      Container(
                        height: 1,
                        margin: EdgeInsets.symmetric(horizontal: 8),
                        color:
                            isDarkMode
                                ? Colors.white.withValues(alpha: 0.1)
                                : Colors.black.withValues(alpha: 0.08),
                      ),
                      // Delete button
                      Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap:
                              () => controller.showDeleteConfirmation(
                                category.id,
                                category.name,
                              ),
                          borderRadius: BorderRadius.only(
                            bottomLeft: Radius.circular(14),
                            bottomRight: Radius.circular(14),
                          ),
                          child: Container(
                            padding: EdgeInsets.all(14),
                            child: Icon(
                              Icons.delete_outline_rounded,
                              color:
                                  isDarkMode
                                      ? ColorTheme.errorDark
                                      : ColorTheme.error,
                              size: 22,
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
