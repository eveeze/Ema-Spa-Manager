import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:emababyspa/common/theme/color_theme.dart';
import 'package:emababyspa/common/widgets/custom_appbar.dart';
import 'package:emababyspa/common/widgets/empty_state_widget.dart';
import 'package:emababyspa/features/service/controllers/service_controller.dart';
import 'package:emababyspa/common/layouts/main_layout.dart';

class ServiceView extends GetView<ServiceController> {
  const ServiceView({super.key});

  @override
  Widget build(BuildContext context) {
    return MainLayout(
      child: Scaffold(
        backgroundColor: ColorTheme.background,
        appBar: const CustomAppBar(
          title: 'Service Management',
          showBackButton: false,
        ),
        body: SafeArea(
          child: RefreshIndicator(
            onRefresh: () async {
              await controller.refreshData();
            },
            color: ColorTheme.primary,
            backgroundColor: Colors.white,
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    ColorTheme.primary.withValues(alpha: 0.02),
                    Colors.transparent,
                  ],
                  stops: const [0.0, 0.3],
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Obx(() {
                  if (controller.isLoading.value &&
                      controller.services.isEmpty &&
                      controller.serviceCategories.isEmpty &&
                      controller.staff.isEmpty) {
                    return _buildLoadingState();
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

                  return _buildServiceContent();
                }),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: ColorTheme.primary.withValues(alpha: 0.1),
                  blurRadius: 20,
                  spreadRadius: 5,
                ),
              ],
            ),
            child: CircularProgressIndicator(
              strokeWidth: 3,
              valueColor: AlwaysStoppedAnimation<Color>(ColorTheme.primary),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Loading Dashboard...',
            style: TextStyle(
              fontSize: 16,
              color: ColorTheme.textSecondary,
              fontFamily: 'JosefinSans',
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildServiceContent() {
    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Animated Header Section
          TweenAnimationBuilder<double>(
            duration: const Duration(milliseconds: 800),
            tween: Tween(begin: 0.0, end: 1.0),
            builder: (context, value, child) {
              return Transform.translate(
                offset: Offset(0, 20 * (1 - value)),
                child: Opacity(opacity: value, child: _buildHeaderSection()),
              );
            },
          ),

          const SizedBox(height: 32),

          // Animated Statistics Cards
          TweenAnimationBuilder<double>(
            duration: const Duration(milliseconds: 1000),
            tween: Tween(begin: 0.0, end: 1.0),
            builder: (context, value, child) {
              return Transform.translate(
                offset: Offset(0, 30 * (1 - value)),
                child: Opacity(opacity: value, child: _buildStatsSection()),
              );
            },
          ),

          const SizedBox(height: 40),

          // Animated Management Section
          TweenAnimationBuilder<double>(
            duration: const Duration(milliseconds: 1200),
            tween: Tween(begin: 0.0, end: 1.0),
            builder: (context, value, child) {
              return Transform.translate(
                offset: Offset(0, 40 * (1 - value)),
                child: Opacity(
                  opacity: value,
                  child: _buildManagementSection(),
                ),
              );
            },
          ),

          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildHeaderSection() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Colors.white, ColorTheme.primary.withValues(alpha: 0.02)],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  ColorTheme.primary,
                  ColorTheme.primary.withValues(alpha: 0.8),
                ],
              ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: ColorTheme.primary.withValues(alpha: 0.3),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: const Icon(
              Icons.dashboard_rounded,
              color: Colors.white,
              size: 28,
            ),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Service Dashboard',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: ColorTheme.textPrimary,
                    fontFamily: 'JosefinSans',
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Manage your spa services, staff, and categories with ease',
                  style: TextStyle(
                    fontSize: 15,
                    color: ColorTheme.textSecondary,
                    fontFamily: 'JosefinSans',
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 16),
          child: Text(
            'Quick Overview',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: ColorTheme.textPrimary,
              fontFamily: 'JosefinSans',
            ),
          ),
        ),
        Row(
          children: [
            Expanded(
              child: Obx(
                () => _buildStatCard(
                  title: 'Services',
                  count: controller.serviceCount.toString(),
                  icon: Icons.spa_rounded,
                  color: ColorTheme.primary,
                  isLoading: controller.isLoadingServices.value,
                  hasError: controller.serviceError.isNotEmpty,
                  onRetry: controller.refreshServices,
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Obx(
                () => _buildStatCard(
                  title: 'Staff',
                  count: controller.staffCount.toString(),
                  icon: Icons.people_rounded,
                  color: ColorTheme.info,
                  isLoading: controller.isLoadingStaff.value,
                  hasError: controller.staffError.isNotEmpty,
                  onRetry: controller.refreshStaff,
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Obx(
                () => _buildStatCard(
                  title: 'Categories',
                  count: controller.categoryCount.toString(),
                  icon: Icons.category_rounded,
                  color: ColorTheme.success,
                  isLoading: controller.isLoadingCategories.value,
                  hasError: controller.categoryError.isNotEmpty,
                  onRetry: controller.refreshCategories,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildManagementSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 20),
          child: Text(
            'Management Tools',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: ColorTheme.textPrimary,
              fontFamily: 'JosefinSans',
            ),
          ),
        ),
        _buildManagementCard(
          title: 'Manage Services',
          subtitle: 'Add, edit or delete spa services',
          icon: Icons.spa_rounded,
          color: ColorTheme.primary,
          onTap: controller.navigateToManageServices,
        ),
        const SizedBox(height: 16),
        _buildManagementCard(
          title: 'Manage Staff',
          subtitle: 'Add, edit or delete staff members',
          icon: Icons.people_rounded,
          color: ColorTheme.info,
          onTap: controller.navigateToManageStaff,
        ),
        const SizedBox(height: 16),
        _buildManagementCard(
          title: 'Manage Categories',
          subtitle: 'Add, edit or delete service categories',
          icon: Icons.category_rounded,
          color: ColorTheme.success,
          onTap: controller.navigateToManageCategories,
        ),
      ],
    );
  }

  Widget _buildStatCard({
    required String title,
    required String count,
    required IconData icon,
    required Color color,
    required bool isLoading,
    required bool hasError,
    required VoidCallback onRetry,
  }) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Colors.white, color.withValues(alpha: 0.02)],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.08),
            blurRadius: 15,
            offset: const Offset(0, 4),
            spreadRadius: 0,
          ),
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
        border: Border.all(color: color.withValues(alpha: 0.08), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  color.withValues(alpha: 0.15),
                  color.withValues(alpha: 0.08),
                ],
              ),
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: color.withValues(alpha: 0.2),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(height: 16),

          if (isLoading)
            Container(
              height: 28,
              width: 28,
              padding: const EdgeInsets.all(4),
              child: CircularProgressIndicator(
                strokeWidth: 2.5,
                valueColor: AlwaysStoppedAnimation<Color>(color),
              ),
            )
          else if (hasError)
            GestureDetector(
              onTap: onRetry,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: ColorTheme.error.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.refresh_rounded,
                      color: ColorTheme.error,
                      size: 16,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Retry',
                      style: TextStyle(
                        fontSize: 12,
                        color: ColorTheme.error,
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
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: ColorTheme.textPrimary,
                fontFamily: 'JosefinSans',
                letterSpacing: -0.5,
              ),
            ),

          const SizedBox(height: 8),
          Text(
            title,
            style: TextStyle(
              fontSize: 13,
              color: ColorTheme.textSecondary,
              fontFamily: 'JosefinSans',
              fontWeight: FontWeight.w500,
              letterSpacing: 0.2,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildManagementCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        splashColor: color.withValues(alpha: 0.1),
        highlightColor: color.withValues(alpha: 0.05),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Colors.white, color.withValues(alpha: 0.01)],
            ),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 12,
                offset: const Offset(0, 3),
              ),
              BoxShadow(
                color: color.withValues(alpha: 0.05),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
            border: Border.all(color: color.withValues(alpha: 0.06), width: 1),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      color.withValues(alpha: 0.15),
                      color.withValues(alpha: 0.08),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: color.withValues(alpha: 0.2),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Icon(icon, color: color, size: 28),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                        color: ColorTheme.textPrimary,
                        fontFamily: 'JosefinSans',
                        letterSpacing: -0.2,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 13,
                        color: ColorTheme.textSecondary,
                        fontFamily: 'JosefinSans',
                        height: 1.3,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: ColorTheme.textSecondary.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.arrow_forward_ios_rounded,
                  color: ColorTheme.textSecondary,
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
