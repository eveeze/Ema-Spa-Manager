import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:emababyspa/common/theme/color_theme.dart';
import 'package:emababyspa/common/widgets/custom_bottom_navigation.dart';
import 'package:emababyspa/features/dashboard/controllers/dashboard_controller.dart';

class MainLayout extends GetView<DashboardController> {
  final Widget child;
  final String title;
  final bool showBackButton;
  final List<Widget>? actions;

  const MainLayout({
    super.key,
    required this.child,
    this.title = '',
    this.showBackButton = false,
    this.actions,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorTheme.background,
      body: child,
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
