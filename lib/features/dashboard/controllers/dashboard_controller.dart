// lib/features/dashboard/controllers/dashboard_controller.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:emababyspa/data/models/owner.dart';
import 'package:emababyspa/data/models/reservation.dart'; // Import Reservation model
import 'package:emababyspa/utils/storage_utils.dart';
import 'package:emababyspa/features/reservation/controllers/reservation_controller.dart';

class DashboardController extends GetxController {
  final StorageUtils _storageUtils = StorageUtils();
  late final ReservationController _reservationController;

  // Owner data
  final Rx<Owner?> owner = Rx<Owner?>(null);

  // Dashboard specific data
  final RxString todayAppointments = '0'.obs;
  final RxString activeClients = '0'.obs;
  final RxString completedSessions = '0'.obs;
  final RxList<Map<String, dynamic>> recentActivities =
      <Map<String, dynamic>>[].obs;

  // Dashboard summary data
  final RxString totalRevenueToday = 'Rp 0'.obs;
  final RxString upcomingReservationsTodayCount = '0'.obs;

  // NEW: For the upcoming reservations carousel
  final RxList<Reservation> upcomingReservationsTodayList = <Reservation>[].obs;
  final RxInt currentUpcomingReservationIndex = 0.obs;
  final RxBool isLoadingUpcomingCarousel =
      false.obs; // Specific loader for this section

  // Loading states
  final RxBool isLoadingOwner = false.obs;
  final RxBool isLoadingStats = false.obs;
  final RxBool isLoadingActivities = false.obs;
  final RxBool isLoadingRevenue = false.obs;
  // isLoadingUpcomingReservationsToday can be reused or use isLoadingUpcomingCarousel

  @override
  void onInit() {
    super.onInit();
    _reservationController = Get.find<ReservationController>();
    loadOwnerData();
    loadDashboardData();
  }

  void loadOwnerData() async {
    try {
      isLoadingOwner.value = true;
      owner.value = _storageUtils.getOwner();
    } catch (e) {
      debugPrint('Error loading owner data: $e');
    } finally {
      isLoadingOwner.value = false;
    }
  }

  Future<void> loadDashboardData() async {
    // Set all relevant loading flags to true at the beginning
    isLoadingStats.value = true;
    isLoadingActivities.value = true;
    isLoadingRevenue.value = true;
    isLoadingUpcomingCarousel.value = true; // Use specific loader

    try {
      // Parallelize fetching where possible, or sequence if dependent
      await Future.wait([
        _loadDashboardStats(),
        _loadRecentActivities(),
        _loadTodayRevenue(),
        _loadUpcomingReservationsTodayForCarousel(), // Updated method name
      ]);
    } catch (e) {
      debugPrint('Error loading dashboard data: $e');
      // Set default/error values for each piece of data if needed
      totalRevenueToday.value = 'Rp 0';
      upcomingReservationsTodayCount.value = '0';
      upcomingReservationsTodayList.clear();
      // etc.
    } finally {
      // Set all relevant loading flags to false at the end
      isLoadingStats.value = false;
      isLoadingActivities.value = false;
      isLoadingRevenue.value = false;
      isLoadingUpcomingCarousel.value = false; // Use specific loader
    }
  }

  Future<void> _loadDashboardStats() async {
    try {
      await Future.delayed(const Duration(milliseconds: 500));
      todayAppointments.value = '5';
      activeClients.value = '28';
      completedSessions.value = '142';
    } catch (e) {
      debugPrint('Error loading dashboard stats: $e');
      todayAppointments.value = '0';
      activeClients.value = '0';
      completedSessions.value = '0';
    }
  }

  Future<void> _loadRecentActivities() async {
    try {
      await Future.delayed(const Duration(milliseconds: 300));
      recentActivities.clear();
      // Add example data if needed
    } catch (e) {
      debugPrint('Error loading recent activities: $e');
      recentActivities.clear();
    }
  }

  Future<void> _loadTodayRevenue() async {
    try {
      await Future.delayed(const Duration(milliseconds: 400));
      totalRevenueToday.value = 'Rp 1.250.000';
    } catch (e) {
      debugPrint('Error loading today\'s revenue: $e');
      totalRevenueToday.value = 'Rp 0';
    }
  }

  // UPDATED: Load upcoming reservations for today for the carousel
  Future<void> _loadUpcomingReservationsTodayForCarousel() async {
    isLoadingUpcomingCarousel.value = true; // Set specific loader
    try {
      final now = DateTime.now();
      // Fetch all reservations for the day (or a reasonable limit like 20-30 if there could be too many)
      // The ReservationController will store them in upcomingDayReservationList
      await _reservationController.fetchUpcomingReservationsForDay(
        date: now,
        limit: 50, // Fetch more items for the carousel
        isRefresh: true,
      );
      upcomingReservationsTodayList.assignAll(
        _reservationController.upcomingDayReservationList,
      );
      upcomingReservationsTodayCount.value =
          _reservationController.upcomingDayTotalItems.value
              .toString(); // This can still be used for the summary card
      if (upcomingReservationsTodayList.isNotEmpty) {
        currentUpcomingReservationIndex.value = 0;
      } else {
        currentUpcomingReservationIndex.value = -1; // Indicate no items
      }
    } catch (e) {
      debugPrint('Error loading upcoming reservations for today carousel: $e');
      upcomingReservationsTodayList.clear();
      upcomingReservationsTodayCount.value = '0';
      currentUpcomingReservationIndex.value = -1;
    } finally {
      isLoadingUpcomingCarousel.value = false; // Clear specific loader
    }
  }

  // NEW: Methods for carousel navigation
  void nextUpcomingReservation() {
    if (upcomingReservationsTodayList.isNotEmpty) {
      currentUpcomingReservationIndex.value =
          (currentUpcomingReservationIndex.value + 1) %
          upcomingReservationsTodayList.length;
    }
  }

  void previousUpcomingReservation() {
    if (upcomingReservationsTodayList.isNotEmpty) {
      currentUpcomingReservationIndex.value =
          (currentUpcomingReservationIndex.value -
              1 +
              upcomingReservationsTodayList.length) %
          upcomingReservationsTodayList.length;
    }
  }

  // NEW: Getter for the currently selected reservation for the carousel
  Rx<Reservation?> get currentReservationForCarousel {
    if (upcomingReservationsTodayList.isNotEmpty &&
        currentUpcomingReservationIndex.value >= 0 &&
        currentUpcomingReservationIndex.value <
            upcomingReservationsTodayList.length) {
      return Rx<Reservation?>(
        upcomingReservationsTodayList[currentUpcomingReservationIndex.value],
      );
    }
    return Rx<Reservation?>(null);
  }

  Future<void> signOut() async {
    try {
      await _storageUtils.clearAll();
      owner.value = null;
      todayAppointments.value = '0';
      activeClients.value = '0';
      completedSessions.value = '0';
      totalRevenueToday.value = 'Rp 0';
      upcomingReservationsTodayCount.value = '0';
      recentActivities.clear();
      upcomingReservationsTodayList.clear(); // NEW
      currentUpcomingReservationIndex.value = 0; // NEW
      await Get.offAllNamed('/login');
    } catch (e) {
      debugPrint('Sign out error: $e');
    }
  }

  Future<void> refreshCurrentPage() async {
    await loadDashboardData();
  }

  bool get isLoading => // Combined loading state
      isLoadingOwner.value ||
      isLoadingStats.value ||
      isLoadingActivities.value ||
      isLoadingRevenue.value ||
      isLoadingUpcomingCarousel.value; // Include the new loader
}
