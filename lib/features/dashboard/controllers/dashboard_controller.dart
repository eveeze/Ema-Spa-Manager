// lib/features/dashboard/controllers/dashboard_controller.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:emababyspa/data/models/owner.dart';
import 'package:emababyspa/data/models/reservation.dart';
import 'package:emababyspa/utils/storage_utils.dart';
import 'package:emababyspa/features/reservation/controllers/reservation_controller.dart';
import 'package:emababyspa/data/repository/reservation_repository.dart';
import 'package:emababyspa/data/repository/analytics_repository.dart';
import 'package:emababyspa/data/models/analytics.dart';

class DashboardController extends GetxController {
  // --- DEPENDENCIES ---
  final StorageUtils _storageUtils = StorageUtils();
  late final ReservationController _reservationController;
  final AnalyticsRepository _analyticsRepository;

  DashboardController({required AnalyticsRepository analyticsRepository})
    : _analyticsRepository = analyticsRepository;

  // --- STATE VARIABLES ---

  final Rx<Owner?> owner = Rx<Owner?>(null);

  // State untuk data dari endpoint baru
  final Rx<AnalyticsOverview?> overviewData = Rx<AnalyticsOverview?>(null);
  final Rx<AnalyticsDetails?> detailsDataThisMonth = Rx<AnalyticsDetails?>(
    null,
  );

  // State untuk carousel reservasi mendatang
  final RxList<Reservation> upcomingReservationsTodayList = <Reservation>[].obs;
  final RxInt currentUpcomingReservationIndex = 0.obs;
  final RxBool isLoadingUpcomingCarousel = false.obs;
  final RxString upcomingReservationsTodayCount = '0'.obs;

  // State Loading
  final RxBool isLoadingOwner = false.obs;
  final RxBool isLoadingAnalytics = false.obs;

  // --- LIFECYCLE & CORE LOGIC ---

  @override
  void onInit() {
    super.onInit();
    if (Get.isRegistered<ReservationController>()) {
      _reservationController = Get.find<ReservationController>();
    } else {
      _reservationController = Get.put(
        ReservationController(
          reservationRepository: Get.find<ReservationRepository>(),
        ),
      );
    }
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
    isLoadingAnalytics.value = true;
    isLoadingUpcomingCarousel.value = true;

    try {
      // Panggil semua data secara paralel
      await Future.wait([
        _loadOverviewAnalytics(),
        _loadCurrentMonthAnalytics(),
        _loadUpcomingReservationsTodayForCarousel(),
      ]);
    } catch (e) {
      debugPrint('Error loading dashboard data: $e');
      _resetAnalyticsState();
    } finally {
      isLoadingAnalytics.value = false;
      isLoadingUpcomingCarousel.value = false;
    }
  }

  /// Memuat data KPI real-time dari endpoint /overview.
  Future<void> _loadOverviewAnalytics() async {
    try {
      overviewData.value = await _analyticsRepository.getAnalyticsOverview();
    } catch (e) {
      debugPrint("Error loading today's overview analytics: $e");
      overviewData.value = null; // Reset jika error
    }
  }

  /// Memuat data analitik detail untuk BULAN INI.
  Future<void> _loadCurrentMonthAnalytics() async {
    try {
      final now = DateTime.now();
      // Hitung jumlah hari di bulan ini untuk dijadikan parameter `days`
      final daysInMonth = DateTime(now.year, now.month + 1, 0).day;
      detailsDataThisMonth.value = await _analyticsRepository
          .getAnalyticsDetails(days: daysInMonth);
    } catch (e) {
      debugPrint("Error loading monthly analytics details: $e");
      detailsDataThisMonth.value = null; // Reset jika error
    }
  }

  // ================================================================
  // BAGIAN RESERVASI MENDATANG (TIDAK ADA PERUBAHAN)
  // ================================================================
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
  // ================================================================

  /// Fungsi untuk pull-to-refresh.
  Future<void> refreshCurrentPage() async {
    await loadDashboardData();
  }

  /// Getter untuk state loading gabungan.
  bool get isLoading =>
      isLoadingOwner.value ||
      isLoadingAnalytics.value ||
      isLoadingUpcomingCarousel.value;

  /// Helper untuk mereset state analitik jika terjadi error.
  void _resetAnalyticsState() {
    overviewData.value = null;
    detailsDataThisMonth.value = null;
    upcomingReservationsTodayList.clear();
    upcomingReservationsTodayCount.value = '0';
  }

  // --- HELPER GETTERS UNTUK UI ---

  String get totalRevenueTodayFormatted => NumberFormat.currency(
    locale: 'id_ID',
    symbol: 'Rp ',
    decimalDigits: 0,
  ).format(overviewData.value?.revenueToday ?? 0);

  String get totalAppointmentsToday =>
      (detailsDataThisMonth.value?.reservationStats.total ?? 0).toString();

  String get totalRevenueThisMonthFormatted => NumberFormat.currency(
    locale: 'id_ID',
    symbol: 'Rp ',
    decimalDigits: 0,
  ).format(
    detailsDataThisMonth.value?.revenueChartData.fold(
          0.0,
          (sum, item) => sum + item.revenue,
        ) ??
        0,
  );

  String get totalReservationsThisMonth =>
      (detailsDataThisMonth.value?.reservationStats.total ?? 0).toString();

  String get completedReservationsThisMonth =>
      (detailsDataThisMonth.value?.reservationStats.completed ?? 0).toString();

  String get cancelledReservationsThisMonth =>
      (detailsDataThisMonth.value?.reservationStats.cancelled ?? 0).toString();
}
