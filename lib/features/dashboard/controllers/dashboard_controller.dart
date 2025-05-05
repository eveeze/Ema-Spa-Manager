// lib/features/dashboard/controllers/dashboard_controller.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:emababyspa/data/models/owner.dart';
import 'package:emababyspa/utils/storage_utils.dart';
import 'package:emababyspa/common/widgets/custom_bottom_navigation.dart';
import 'package:emababyspa/features/dashboard/views/dashboard_view.dart';
import 'package:emababyspa/features/service/views/service_view.dart';
import 'package:emababyspa/common/theme/color_theme.dart';

class DashboardController extends GetxController {
  final StorageUtils _storageUtils = StorageUtils();

  // Track the currently selected tab
  final RxInt selectedIndex = 0.obs;

  // Owner data
  final Rx<Owner?> owner = Rx<Owner?>(null);

  // For controlling the bottom navigation
  final List<NavItem> navigationItems = [
    NavItem(
      label: 'Dashboard',
      icon: Icons.home_outlined,
      activeIcon: Icons.home_rounded,
    ),
    NavItem(
      label: 'Jadwal',
      icon: Icons.calendar_month_outlined,
      activeIcon: Icons.calendar_month_rounded,
    ),
    NavItem(
      label: 'Layanan',
      icon: Icons.spa_outlined,
      activeIcon: Icons.spa_rounded,
    ),
    NavItem(
      label: 'Statistik',
      icon: Icons.bar_chart_outlined,
      activeIcon: Icons.bar_chart_rounded,
    ),
    NavItem(
      label: 'Akun',
      icon: Icons.person_outline_rounded,
      activeIcon: Icons.person_rounded,
    ),
  ];

  // Pages to be displayed in the dashboard
  late List<Widget> pages;

  @override
  void onInit() {
    super.onInit();
    loadOwnerData();
    _initializePages();
  }

  void _initializePages() {
    // Initialize the pages with actual views
    pages = [
      const HomeView(), // Home dashboard
      _buildPlaceholderView("Jadwal"), // Appointments placeholder
      const ServiceView(), // Service page
      _buildPlaceholderView("Statistik"), // Statistics placeholder
      _buildPlaceholderView("Akun"), // Account settings placeholder
    ];
  }

  // Helper to build placeholder pages until they're implemented
  Widget _buildPlaceholderView(String title) {
    return Scaffold(
      appBar: AppBar(title: Text(title), centerTitle: true),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              _getIconForTitle(title),
              size: 64,
              color: ColorTheme.primary.withValues(alpha: 0.5),
            ),
            const SizedBox(height: 16),
            Text(
              '$title View',
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                fontFamily: 'JosefinSans',
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'This page is under development',
              style: TextStyle(
                fontSize: 16,
                color: ColorTheme.textSecondary,
                fontFamily: 'JosefinSans',
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Helper to get appropriate icons for placeholder views
  IconData _getIconForTitle(String title) {
    switch (title) {
      case 'Jadwal':
        return Icons.calendar_month_rounded;
      case 'Statistik':
        return Icons.bar_chart_rounded;
      case 'Akun':
        return Icons.person_rounded;
      default:
        return Icons.circle_outlined;
    }
  }

  void loadOwnerData() {
    owner.value = _storageUtils.getOwner();
  }

  void changeTab(int index) {
    selectedIndex.value = index;

    switch (index) {
      case 0:
        // Tetap di dashboard
        break;
      case 1:
        Get.toNamed('/jadwal');
        break;
      case 2:
        Get.toNamed('/services');
        break;
      case 3:
        Get.toNamed('/statistik');
        break;
      case 4:
        Get.toNamed('/akun');
        break;
    }
  }

  Future<void> signOut() async {
    await _storageUtils.clearAll();
    // Navigate to login screen
    // Get.offAllNamed(Routes.LOGIN);
  }
}
