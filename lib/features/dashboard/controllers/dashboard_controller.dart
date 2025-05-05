// lib/features/dashboard/controllers/dashboard_controller.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:emababyspa/data/models/owner.dart';
import 'package:emababyspa/utils/storage_utils.dart';
import 'package:emababyspa/common/widgets/custom_bottom_navigation.dart';

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

  @override
  void onInit() {
    super.onInit();
    loadOwnerData();
  }

  void loadOwnerData() {
    owner.value = _storageUtils.getOwner();
  }

  void changeTab(int index) {
    selectedIndex.value = index;

    // Navigate to the appropriate page
    switch (index) {
      case 0:
        Get.offAllNamed('/dashboard');
        break;
      case 1:
        Get.offAllNamed('/schedule');
        break;
      case 2:
        Get.offAllNamed('/services');
        break;
      case 3:
        Get.offAllNamed('/statistics');
        break;
      case 4:
        Get.offAllNamed('/account');
        break;
    }
  }

  Future<void> signOut() async {
    await _storageUtils.clearAll();
    // Navigate to login screen
    Get.offAllNamed('/login');
  }
}
