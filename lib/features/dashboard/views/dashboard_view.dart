// lib/features/dashboard/views/dashboard_view.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:emababyspa/common/theme/color_theme.dart';
import 'package:emababyspa/common/widgets/custom_appbar.dart';
import 'package:emababyspa/common/widgets/custom_bottom_navigation.dart';
import 'package:emababyspa/common/widgets/empty_state_widget.dart';
import 'package:emababyspa/features/dashboard/controllers/dashboard_controller.dart';

class DashboardView extends GetView<DashboardController> {
  const DashboardView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorTheme.background,
      body: const HomeView(), // Dashboard hanya tampil HomeView saja

      bottomNavigationBar: Obx(
        () => CustomBottomNavigation(
          items: controller.navigationItems,
          currentIndex: controller.selectedIndex.value,
          onTap: controller.changeTab,
          backgroundColor: ColorTheme.surface,
          elevation: 8,
        ),
      ),
    );
  }
}

// Home Page - This would typically be a separate file
class HomeView extends GetView<DashboardController> {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: 'Home',
        actions: [
          IconButton(
            icon: Icon(Icons.notifications_outlined),
            onPressed: () {
              // Navigate to notifications
            },
          ),
        ],
        showBackButton: false,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Obx(() {
            final owner = controller.owner.value;

            if (owner == null) {
              return const EmptyStateWidget(
                title: 'Welcome',
                message: 'Please complete your profile to get started.',
                icon: Icons.person_add_outlined,
                buttonLabel: 'Setup Profile',
                fullScreen: true,
              );
            }

            return SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Welcome section
                  Text(
                    'Welcome back,',
                    style: TextStyle(
                      fontSize: 14,
                      color: ColorTheme.textSecondary,
                      fontFamily: 'JosefinSans',
                    ),
                  ),
                  Text(
                    owner.name,
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: ColorTheme.textPrimary,
                      fontFamily: 'JosefinSans',
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Dashboard cards
                  _buildDashboardCard(
                    title: 'Today\'s Appointments',
                    value: '5',
                    icon: Icons.calendar_today_rounded,
                    color: ColorTheme.primary,
                    onTap:
                        () => controller.changeTab(1), // Go to appointments tab
                  ),
                  const SizedBox(height: 16),

                  _buildDashboardCard(
                    title: 'Active Clients',
                    value: '28',
                    icon: Icons.people_rounded,
                    color: ColorTheme.info,
                    onTap: () => controller.changeTab(2), // Go to clients tab
                  ),
                  const SizedBox(height: 16),

                  _buildDashboardCard(
                    title: 'Completed Sessions',
                    value: '142',
                    icon: Icons.check_circle_rounded,
                    color: ColorTheme.success,
                    onTap: () {},
                  ),
                  const SizedBox(height: 24),

                  // Recent activity section
                  Text(
                    'Recent Activity',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: ColorTheme.textPrimary,
                      fontFamily: 'JosefinSans',
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Placeholder for recent activities list
                  Container(
                    decoration: BoxDecoration(
                      color: ColorTheme.surface,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.05),
                          blurRadius: 10,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    child: const EmptyStateWidget(
                      title: 'No Recent Activity',
                      message: 'Your recent activities will appear here.',
                      icon: Icons.history_rounded,
                    ),
                  ),
                ],
              ),
            );
          }),
        ),
      ),
    );
  }

  Widget _buildDashboardCard({
    required String title,
    required String value,
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
              offset: Offset(0, 2),
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
                      fontSize: 14,
                      color: ColorTheme.textSecondary,
                      fontFamily: 'JosefinSans',
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    value,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: ColorTheme.textPrimary,
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
