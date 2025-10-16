// lib/features/analytics/controllers/analytics_controller.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:emababyspa/data/models/analytics.dart';
import 'package:emababyspa/data/repository/analytics_repository.dart';

// Enum untuk mempermudah pemilihan filter tanggal di UI
enum DateRangeFilter { last7Days, thisMonth, last3Months, custom }

class AnalyticsController extends GetxController {
  final AnalyticsRepository _analyticsRepository;

  AnalyticsController({required AnalyticsRepository analyticsRepository})
    : _analyticsRepository = analyticsRepository;

  // === STATE MANAGEMENT ===

  // State utama untuk loading dan error
  final RxBool isLoading = true.obs;
  final Rx<String?> errorMessage = Rx<String?>(null);

  // State untuk menampung data dari API
  final Rx<AnalyticsDetails?> detailsData = Rx<AnalyticsDetails?>(null);

  // State untuk mengelola filter tanggal
  final Rx<DateRangeFilter> selectedFilter = DateRangeFilter.last7Days.obs;
  late Rx<DateTimeRange> selectedDateRange;

  @override
  void onInit() {
    super.onInit();
    // Inisialisasi rentang tanggal default (7 hari terakhir) dan langsung fetch data
    _initializeDefaultDateRange();
    fetchAnalyticsData();
  }

  /// Inisialisasi rentang tanggal ke "7 Hari Terakhir" secara default.
  void _initializeDefaultDateRange() {
    final now = DateTime.now();
    final startDate = now.subtract(const Duration(days: 6));
    selectedDateRange = DateTimeRange(start: startDate, end: now).obs;
  }

  // === LOGIKA PENGAMBILAN DATA ===

  /// Fungsi utama untuk mengambil semua data analytics berdasarkan rentang tanggal yang dipilih.
  Future<void> fetchAnalyticsData() async {
    isLoading.value = true;
    errorMessage.value = null;

    try {
      // Menghitung jumlah hari berdasarkan rentang tanggal yang dipilih
      final duration = selectedDateRange.value.duration;

      // Ambil data detail. Data overview tidak diperlukan di halaman ini.
      detailsData.value = await _analyticsRepository.getAnalyticsDetails(
        days: duration.inDays + 1, // +1 untuk membuat rentang inklusif
      );
    } catch (e) {
      errorMessage.value = "Gagal memuat data analitik: ${e.toString()}";
      detailsData.value = null;
    } finally {
      isLoading.value = false;
    }
  }

  // === AKSI PENGGUNA ===

  /// Mengubah filter tanggal dan memicu pengambilan data baru.
  /// Dipanggil dari UI ketika pengguna memilih filter baru.
  void changeDateFilter(DateRangeFilter filter, [DateTimeRange? customRange]) {
    selectedFilter.value = filter;
    final now = DateTime.now();

    switch (filter) {
      case DateRangeFilter.last7Days:
        selectedDateRange.value = DateTimeRange(
          start: now.subtract(const Duration(days: 6)),
          end: now,
        );
        break;
      case DateRangeFilter.thisMonth:
        selectedDateRange.value = DateTimeRange(
          start: DateTime(now.year, now.month, 1),
          end: DateTime(now.year, now.month + 1, 0, 23, 59, 59),
        );
        break;
      case DateRangeFilter.last3Months:
        selectedDateRange.value = DateTimeRange(
          start: DateTime(now.year, now.month - 2, 1),
          end: DateTime(now.year, now.month + 1, 0, 23, 59, 59),
        );
        break;
      case DateRangeFilter.custom:
        if (customRange != null) {
          selectedDateRange.value = customRange;
        }
        break;
    }
    fetchAnalyticsData();
  }

  /// Fungsi untuk pull-to-refresh.
  Future<void> refreshData() async {
    await fetchAnalyticsData();
  }
}
