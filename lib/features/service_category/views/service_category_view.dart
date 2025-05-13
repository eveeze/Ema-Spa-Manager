// lib/features/service_category/views/service_category_view.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:emababyspa/common/theme/color_theme.dart';
import 'package:emababyspa/common/widgets/custom_appbar.dart';
import 'package:emababyspa/common/widgets/empty_state_widget.dart';
import 'package:emababyspa/common/layouts/main_layout.dart';
import 'package:emababyspa/features/service_category/controllers/service_category_controller.dart';
import 'package:emababyspa/data/models/service_category.dart';

class ServiceCategoryView extends GetView<ServiceCategoryController> {
  const ServiceCategoryView({super.key});

  @override
  Widget build(BuildContext context) {
    return MainLayout(
      child: Scaffold(
        appBar: const CustomAppBar(
          title: 'Service Categories',
          showBackButton: true,
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () {
            controller.navigateToAddServiceCategory();
          },
          backgroundColor: ColorTheme.primary,
          icon: const Icon(Icons.add_circle_outline, color: Colors.white),
          label: const Text(
            'Add Category',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w600,
              fontFamily: 'JosefinSans',
            ),
          ),
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        body: SafeArea(
          child: RefreshIndicator(
            onRefresh: () async {
              controller.refreshData();
            },
            color: ColorTheme.primary,
            backgroundColor: Colors.white,
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
                            color: ColorTheme.border.withValues(alpha: 0.5),
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
                                      ColorTheme.primary.withValues(alpha: 0.2),
                                      ColorTheme.primary.withValues(
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
                                  color: ColorTheme.primary,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Text(
                                'Service Categories',
                                style: TextStyle(
                                  fontSize: 26,
                                  fontWeight: FontWeight.bold,
                                  color: ColorTheme.textPrimary,
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
                                    ColorTheme.primary.withValues(alpha: 0.1),
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
                                  color: ColorTheme.textSecondary,
                                  fontFamily: 'JosefinSans',
                                  fontStyle: FontStyle.italic,
                                  shadows: [
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
                                  color: ColorTheme.primary.withValues(
                                    alpha: 0.1,
                                  ),
                                  borderRadius: BorderRadius.circular(30),
                                  border: Border.all(
                                    color: ColorTheme.primary.withValues(
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
                                      color: ColorTheme.primary,
                                    ),
                                    const SizedBox(width: 8),
                                    TweenAnimationBuilder(
                                      duration: const Duration(
                                        milliseconds: 800,
                                      ),
                                      tween: IntTween(
                                        begin: 0,
                                        end:
                                            controller.serviceCategories.length,
                                      ),
                                      builder: (context, value, child) {
                                        return Text(
                                          '$value categories available',
                                          style: TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w600,
                                            color: ColorTheme.primary,
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
                                duration: const Duration(milliseconds: 1500),
                                builder: (context, value, child) {
                                  return Transform.scale(
                                    scale: 0.8 + (value * 0.2),
                                    child: Container(
                                      width: 80,
                                      height: 80,
                                      padding: const EdgeInsets.all(15),
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(20),
                                        boxShadow: [
                                          BoxShadow(
                                            color: ColorTheme.primary
                                                .withValues(alpha: 0.2),
                                            blurRadius: 20,
                                            spreadRadius: 0,
                                          ),
                                        ],
                                      ),
                                      child: CircularProgressIndicator(
                                        valueColor:
                                            AlwaysStoppedAnimation<Color>(
                                              ColorTheme.primary,
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
                                  color: ColorTheme.textSecondary,
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

                      return _buildCategoriesList();
                    }),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCategoriesList() {
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
                      child: _buildCategoryCard(category, index),
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

  Widget _buildCategoryCard(ServiceCategory category, int index) {
    // Enhanced pastel colors for each category
    final List<List<Color>> pastelGradients = [
      [Color(0xFFE6F7FF), Color(0xFFCCEBFF)], // Light Blue
      [Color(0xFFFFF3E6), Color(0xFFFFE6CC)], // Light Orange
      [Color(0xFFE6FFFA), Color(0xFFCCFFF5)], // Light Teal
      [Color(0xFFF5E6FF), Color(0xFFEBCCFF)], // Light Purple
      [Color(0xFFFFE6E6), Color(0xFFFFCCCC)], // Light Red
      [Color(0xFFE6FFE6), Color(0xFFCCFFCC)], // Light Green
    ];

    final List<Color> gradientColors =
        pastelGradients[index % pastelGradients.length];
    final Color iconColor = ColorTheme.primary;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 15,
            offset: const Offset(0, 8),
            spreadRadius: 0,
          ),
          BoxShadow(
            color: gradientColors[0].withValues(alpha: 0.5),
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
                        color: gradientColors[0].withValues(alpha: 0.5),
                        blurRadius: 8,
                        spreadRadius: 0,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Center(
                    child: Icon(Icons.spa_rounded, size: 36, color: iconColor),
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
                          color: ColorTheme.textPrimary,
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
                              color: ColorTheme.textSecondary,
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
                              color: iconColor,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              '${(index + 1) * 3} Services',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: iconColor,
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
                    color: Colors.white.withValues(alpha: 0.9),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.04),
                        blurRadius: 8,
                        offset: const Offset(0, 3),
                      ),
                    ],
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.8),
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
                              color: ColorTheme.info,
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
                              Colors.grey.withValues(alpha: 0.2),
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
                              color: ColorTheme.error,
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
