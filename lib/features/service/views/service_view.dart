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
        appBar: const CustomAppBar(
          title: 'Service Management',
          showBackButton: false,
        ),
        body: SafeArea(
          child: RefreshIndicator(
            onRefresh: () async {
              await controller.refreshData();
            },
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Obx(() {
                // Only show loading spinner when initially loading everything
                if (controller.isLoading.value &&
                    controller.services.isEmpty &&
                    controller.serviceCategories.isEmpty &&
                    controller.staff.isEmpty) {
                  return const Center(child: CircularProgressIndicator());
                }

                // Show error state only if all three parts failed
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
    );
  }

  Widget _buildServiceContent() {
    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header title
          Text(
            'Service Dashboard',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: ColorTheme.textPrimary,
              fontFamily: 'JosefinSans',
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Manage your spa services, staff, and categories',
            style: TextStyle(
              fontSize: 14,
              color: ColorTheme.textSecondary,
              fontFamily: 'JosefinSans',
            ),
          ),
          const SizedBox(height: 24),

          // Statistics cards row
          Row(
            children: [
              // Services Card
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
              const SizedBox(width: 12),

              // Staff Card
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
              const SizedBox(width: 12),

              // Categories Card
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
          const SizedBox(height: 32),

          // Management section title
          Text(
            'Management',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: ColorTheme.textPrimary,
              fontFamily: 'JosefinSans',
            ),
          ),
          const SizedBox(height: 16),

          // Service Management Card
          _buildManagementCard(
            title: 'Manage Services',
            subtitle: 'Add, edit or delete spa services',
            icon: Icons.spa_rounded,
            color: ColorTheme.primary,
            onTap: controller.navigateToManageServices,
          ),
          const SizedBox(height: 16),

          // Staff Management Card
          _buildManagementCard(
            title: 'Manage Staff',
            subtitle: 'Add, edit or delete staff members',
            icon: Icons.people_rounded,
            color: ColorTheme.info,
            onTap: controller.navigateToManageStaff,
          ),
          const SizedBox(height: 16),

          // Category Management Card
          _buildManagementCard(
            title: 'Manage Categories',
            subtitle: 'Add, edit or delete service categories',
            icon: Icons.category_rounded,
            color: ColorTheme.success,
            onTap: controller.navigateToManageCategories,
          ),
        ],
      ),
    );
  }

  // Widget for stats cards with loading and error states
  Widget _buildStatCard({
    required String title,
    required String count,
    required IconData icon,
    required Color color,
    required bool isLoading,
    required bool hasError,
    required VoidCallback onRetry,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
      decoration: BoxDecoration(
        color: ColorTheme.surface,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(height: 12),

          if (isLoading)
            SizedBox(
              height: 24,
              width: 24,
              child: CircularProgressIndicator(strokeWidth: 2, color: color),
            )
          else if (hasError)
            GestureDetector(
              onTap: onRetry,
              child: Row(
                children: [
                  Icon(Icons.refresh, color: ColorTheme.error, size: 16),
                  const SizedBox(width: 4),
                  Text(
                    'Retry',
                    style: TextStyle(
                      fontSize: 12,
                      color: ColorTheme.error,
                      fontFamily: 'JosefinSans',
                    ),
                  ),
                ],
              ),
            )
          else
            Text(
              count,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: ColorTheme.textPrimary,
                fontFamily: 'JosefinSans',
              ),
            ),

          const SizedBox(height: 4),
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              color: ColorTheme.textSecondary,
              fontFamily: 'JosefinSans',
            ),
          ),
        ],
      ),
    );
  }

  // Widget for management action cards
  Widget _buildManagementCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: ColorTheme.surface,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: ColorTheme.textPrimary,
                      fontFamily: 'JosefinSans',
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 12,
                      color: ColorTheme.textSecondary,
                      fontFamily: 'JosefinSans',
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios_rounded,
              color: ColorTheme.textSecondary,
              size: 16,
            ),
          ],
        ),
      ),
    );
  }
}
