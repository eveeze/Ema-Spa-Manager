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

  // Navigation state management
  final RxBool isNavigating = false.obs;
  final RxString currentRoute = '/dashboard'.obs;

  // Owner data
  final Rx<Owner?> owner = Rx<Owner?>(null);

  // Performance optimization - cache navigation items
  late final List<NavItem> navigationItems;

  // Route mapping for faster lookup
  static const Map<int, String> _routeMap = {
    0: '/dashboard',
    1: '/schedule',
    2: '/services',
    3: '/statistics',
    4: '/account',
  };

  // Reverse mapping for route to index
  static const Map<String, int> _indexMap = {
    '/dashboard': 0,
    '/schedule': 1,
    '/services': 2,
    '/statistics': 3,
    '/account': 4,
  };

  @override
  void onInit() {
    super.onInit();
    _initializeNavigationItems();
    _initializeCurrentRoute();
    loadOwnerData();
    _setupRouteListener();
  }

  void _initializeNavigationItems() {
    navigationItems = [
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
  }

  void _initializeCurrentRoute() {
    final currentRouteName = Get.currentRoute;
    currentRoute.value = currentRouteName;
    selectedIndex.value = _indexMap[currentRouteName] ?? 0;
  }

  void _setupRouteListener() {
    // Listen to route changes to keep bottom nav in sync
    ever(currentRoute, (String route) {
      final index = _indexMap[route];
      if (index != null && selectedIndex.value != index) {
        selectedIndex.value = index;
      }
    });
  }

  void loadOwnerData() async {
    try {
      owner.value = _storageUtils.getOwner();
    } catch (e) {
      debugPrint('Error loading owner data: $e');
      // Handle error gracefully
    }
  }

  /// Enhanced tab change with better performance and error handling
  Future<void> changeTab(int index) async {
    // Validation checks
    if (!_isValidIndex(index)) {
      debugPrint('Invalid tab index: $index');
      return;
    }

    // Prevent duplicate navigation
    if (_isDuplicateNavigation(index)) {
      return;
    }

    // Set navigation state
    isNavigating.value = true;

    try {
      // Update selected index immediately for UI responsiveness
      selectedIndex.value = index;

      final targetRoute = _routeMap[index]!;
      currentRoute.value = targetRoute;

      // Use more efficient navigation method
      await _navigateToRoute(targetRoute);
    } catch (e) {
      debugPrint('Navigation error: $e');
      // Revert index on error
      _revertToCurrentRoute();
    } finally {
      // Reset navigation state
      isNavigating.value = false;
    }
  }

  bool _isValidIndex(int index) {
    return index >= 0 &&
        index < navigationItems.length &&
        _routeMap.containsKey(index);
  }

  bool _isDuplicateNavigation(int index) {
    return selectedIndex.value == index || isNavigating.value;
  }

  Future<void> _navigateToRoute(String route) async {
    // Use offNamed instead of offAllNamed for better performance
    // Only clear navigation stack if really necessary
    if (_shouldClearNavigationStack(route)) {
      await Get.offAllNamed(route);
    } else {
      await Get.offNamed(route);
    }
  }

  bool _shouldClearNavigationStack(String route) {
    // Only clear stack for major navigation changes
    // This improves performance by maintaining page state when possible
    return route == '/dashboard' || Get.previousRoute.isEmpty;
  }

  void _revertToCurrentRoute() {
    final currentRouteName = Get.currentRoute;
    final correctIndex = _indexMap[currentRouteName] ?? 0;
    selectedIndex.value = correctIndex;
    currentRoute.value = currentRouteName;
  }

  /// Quick navigation without full page replacement (for performance)
  void quickNavigateToTab(int index) {
    if (!_isValidIndex(index) || _isDuplicateNavigation(index)) {
      return;
    }

    selectedIndex.value = index;
    final targetRoute = _routeMap[index]!;

    // Use toNamed for faster navigation that doesn't replace the entire stack
    Get.toNamed(targetRoute);
  }

  /// Check if a specific tab is currently active
  bool isTabActive(int index) {
    return selectedIndex.value == index;
  }

  /// Get the route for a specific tab index
  String? getRouteForTab(int index) {
    return _routeMap[index];
  }

  /// Enhanced sign out with proper cleanup
  Future<void> signOut() async {
    try {
      isNavigating.value = true;

      // Clear storage
      await _storageUtils.clearAll();

      // Reset controller state
      selectedIndex.value = 0;
      owner.value = null;
      currentRoute.value = '/login';

      // Navigate to login
      await Get.offAllNamed('/login');
    } catch (e) {
      debugPrint('Sign out error: $e');
      // Handle error gracefully
    } finally {
      isNavigating.value = false;
    }
  }

  /// Refresh current page data
  Future<void> refreshCurrentPage() async {
    loadOwnerData();
    // Add other refresh logic as needed
  }

  @override
  void onClose() {
    // Clean up resources
    super.onClose();
  }
}
