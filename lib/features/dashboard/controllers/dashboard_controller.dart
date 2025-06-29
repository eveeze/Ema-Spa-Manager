import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:emababyspa/data/models/owner.dart';
import 'package:emababyspa/data/models/reservation.dart';
import 'package:emababyspa/utils/storage_utils.dart';
import 'package:emababyspa/features/reservation/controllers/reservation_controller.dart';
import 'package:emababyspa/data/repository/reservation_repository.dart';

class DashboardController extends GetxController {
  final StorageUtils _storageUtils = StorageUtils();
  late final ReservationController _reservationController;

  // Data pemilik
  final Rx<Owner?> owner = Rx<Owner?>(null);

  // --- Data spesifik dasbor ---
  final RxString todayAppointments = '0'.obs;
  final RxString activeClients = '0'.obs;
  final RxString completedSessions = '0'.obs;
  final RxList<Map<String, dynamic>> recentActivities =
      <Map<String, dynamic>>[].obs;

  // --- Data ringkasan untuk HARI INI ---
  final RxString totalRevenueToday = 'Rp 0'.obs;
  final RxString upcomingReservationsTodayCount = '0'.obs;

  // Untuk carousel reservasi mendatang
  final RxList<Reservation> upcomingReservationsTodayList = <Reservation>[].obs;
  final RxInt currentUpcomingReservationIndex = 0.obs;
  final RxBool isLoadingUpcomingCarousel = false.obs;

  // State untuk Analitik Bulanan
  final RxString totalRevenueThisMonth = 'Rp 0'.obs;
  final RxString totalReservationsThisMonth = '0'.obs;
  final RxString completedReservationsThisMonth = '0'.obs;
  final RxString cancelledReservationsThisMonth = '0'.obs;

  // State Loading
  final RxBool isLoadingOwner = false.obs;
  final RxBool isLoadingStats = false.obs;
  final RxBool isLoadingActivities = false.obs;
  final RxBool isLoadingRevenue = false.obs;
  final RxBool isLoadingAnalytics = false.obs;

  @override
  void onInit() {
    super.onInit();
    // Inisialisasi ReservationController
    if (Get.isRegistered<ReservationController>()) {
      _reservationController = Get.find<ReservationController>();
    } else {
      _reservationController = Get.put(
        ReservationController(
          reservationRepository: Get.find<ReservationRepository>(),
        ),
      );
    }
    // Muat semua data saat controller diinisialisasi
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
    isLoadingStats.value = true;
    isLoadingActivities.value = true;
    isLoadingRevenue.value = true;
    isLoadingUpcomingCarousel.value = true;
    isLoadingAnalytics.value = true;

    try {
      // Menjalankan semua proses loading data secara paralel
      await Future.wait([
        _loadTodayAnalytics(),
        _loadDashboardStats(),
        _loadRecentActivities(),
        _loadUpcomingReservationsTodayForCarousel(),
        _loadCurrentMonthAnalytics(),
      ]);
    } catch (e) {
      debugPrint('Error loading dashboard data: $e');
      // Reset semua state jika terjadi error
      totalRevenueToday.value = 'Rp 0';
      todayAppointments.value = '0';
      upcomingReservationsTodayCount.value = '0';
      upcomingReservationsTodayList.clear();
      totalRevenueThisMonth.value = 'Rp 0';
      totalReservationsThisMonth.value = '0';
      completedReservationsThisMonth.value = '0';
      cancelledReservationsThisMonth.value = '0';
    } finally {
      isLoadingStats.value = false;
      isLoadingActivities.value = false;
      isLoadingRevenue.value = false;
      isLoadingUpcomingCarousel.value = false;
      isLoadingAnalytics.value = false;
    }
  }

  Future<void> _loadTodayAnalytics() async {
    try {
      final now = DateTime.now();
      // Tentukan waktu mulai (awal hari) dan waktu selesai (akhir hari)
      final startDate = DateTime(now.year, now.month, now.day);
      final endDate = DateTime(now.year, now.month, now.day, 23, 59, 59);

      final tempController = ReservationController(
        reservationRepository: Get.find<ReservationRepository>(),
      );
      await tempController.fetchReservationAnalytics(startDate, endDate);
      final analyticsData = tempController.reservationAnalytics;

      if (analyticsData.isNotEmpty) {
        todayAppointments.value =
            (analyticsData['totalReservations'] ?? 0).toString();
        final revenue = (analyticsData['totalRevenue'] ?? 0.0).toDouble();
        totalRevenueToday.value = NumberFormat.currency(
          locale: 'id_ID',
          symbol: 'Rp ',
          decimalDigits: 0,
        ).format(revenue);
      } else {
        todayAppointments.value = '0';
        totalRevenueToday.value = 'Rp 0';
      }
    } catch (e) {
      debugPrint('Error loading today\'s analytics: $e');
      todayAppointments.value = '0';
      totalRevenueToday.value = 'Rp 0';
    }
  }

  Future<void> _loadCurrentMonthAnalytics() async {
    try {
      final now = DateTime.now();
      final startDate = DateTime(now.year, now.month, 1);
      final endDate = DateTime(now.year, now.month + 1, 0);

      await _reservationController.fetchReservationAnalytics(
        startDate,
        endDate,
      );

      final analyticsData = _reservationController.reservationAnalytics;
      if (analyticsData.isNotEmpty) {
        totalReservationsThisMonth.value =
            (analyticsData['totalReservations'] ?? 0).toString();
        completedReservationsThisMonth.value =
            (analyticsData['completedReservations'] ?? 0).toString();
        cancelledReservationsThisMonth.value =
            (analyticsData['cancelledReservations'] ?? 0).toString();
        final revenue = (analyticsData['totalRevenue'] ?? 0.0).toDouble();
        totalRevenueThisMonth.value = NumberFormat.currency(
          locale: 'id_ID',
          symbol: 'Rp ',
          decimalDigits: 0,
        ).format(revenue);
      }
    } catch (e) {
      debugPrint('Error loading monthly analytics: $e');
      totalRevenueThisMonth.value = 'Rp 0';
      totalReservationsThisMonth.value = '0';
      completedReservationsThisMonth.value = '0';
      cancelledReservationsThisMonth.value = '0';
    }
  }

  Future<void> _loadDashboardStats() async {
    try {
      await Future.delayed(const Duration(milliseconds: 500));
      // Data statis/placeholder
      activeClients.value = '28';
      completedSessions.value = '142';
    } catch (e) {
      debugPrint('Error loading dashboard stats: $e');
      activeClients.value = '0';
      completedSessions.value = '0';
    }
  }

  Future<void> _loadRecentActivities() async {
    try {
      await Future.delayed(const Duration(milliseconds: 300));
      recentActivities.clear();
    } catch (e) {
      debugPrint('Error loading recent activities: $e');
      recentActivities.clear();
    }
  }

  Future<void> _loadUpcomingReservationsTodayForCarousel() async {
    isLoadingUpcomingCarousel.value = true;
    try {
      final now = DateTime.now();
      await _reservationController.fetchUpcomingReservationsForDay(
        date: now,
        limit: 50,
        isRefresh: true,
      );
      upcomingReservationsTodayList.assignAll(
        _reservationController.upcomingDayReservationList,
      );
      upcomingReservationsTodayCount.value =
          _reservationController.upcomingDayTotalItems.value.toString();
      if (upcomingReservationsTodayList.isNotEmpty) {
        currentUpcomingReservationIndex.value = 0;
      } else {
        currentUpcomingReservationIndex.value = -1;
      }
    } catch (e) {
      debugPrint('Error loading upcoming reservations for today carousel: $e');
      upcomingReservationsTodayList.clear();
      upcomingReservationsTodayCount.value = '0';
      currentUpcomingReservationIndex.value = -1;
    } finally {
      isLoadingUpcomingCarousel.value = false;
    }
  }

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
      upcomingReservationsTodayList.clear();
      currentUpcomingReservationIndex.value = 0;
      await Get.offAllNamed('/login');
    } catch (e) {
      debugPrint('Sign out error: $e');
    }
  }

  Future<void> refreshCurrentPage() async {
    await loadDashboardData();
  }

  bool get isLoading =>
      isLoadingOwner.value ||
      isLoadingStats.value ||
      isLoadingActivities.value ||
      isLoadingRevenue.value ||
      isLoadingUpcomingCarousel.value ||
      isLoadingAnalytics.value;
}
