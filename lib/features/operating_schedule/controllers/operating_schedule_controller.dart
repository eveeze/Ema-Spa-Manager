import 'package:get/get.dart';
import 'package:intl/intl.dart';

import 'package:emababyspa/data/models/operating_schedule.dart';
import 'package:emababyspa/data/repository/operating_schedule_repository.dart';
import 'package:emababyspa/utils/app_routes.dart';
import 'package:emababyspa/common/theme/color_theme.dart';
import 'package:emababyspa/utils/logger_utils.dart';
import 'package:emababyspa/data/api/api_exception.dart';

class OperatingScheduleController extends GetxController {
  final OperatingScheduleRepository _operatingScheduleRepository;
  final LoggerUtils _logger = LoggerUtils();

  OperatingScheduleController({
    required OperatingScheduleRepository operatingScheduleRepository,
  }) : _operatingScheduleRepository = operatingScheduleRepository;

  // Observable state
  final RxList<OperatingSchedule> schedulesList = <OperatingSchedule>[].obs;
  final RxBool isLoading = false.obs;
  final RxBool isFormSubmitting = false.obs;
  final RxString errorMessage = ''.obs;

  // Currently viewed schedule
  final Rx<OperatingSchedule?> currentSchedule = Rx<OperatingSchedule?>(null);

  // ============
  // Calendar range cache (biar gak fetch berulang untuk range yang sama)
  // ============
  String? _lastRangeKey;

  @override
  void onInit() {
    super.onInit();
    // ❗ BEST PRACTICE:
    // Jangan fetchAllSchedules() di sini (bisa narik data banyak).
    // Biarkan ScheduleController yang memanggil fetchForCalendarRange().
  }

  // =========================
  // Calendar API (Best practice)
  // =========================

  /// Fetch khusus untuk kebutuhan kalender (marker/holiday status),
  /// WAJIB pakai startDate & endDate.
  ///
  /// - Ada cache rangeKey supaya kalau range sama, gak fetch ulang.
  /// - Tidak menampilkan snackbar ketika hanya refresh marker (biar UX bersih).
  Future<void> fetchForCalendarRange({
    required DateTime start,
    required DateTime end,
    bool silent = true,
  }) async {
    final startIso = _fmt(start);
    final endIso = _fmt(end);

    final rangeKey = '$startIso|$endIso';
    if (_lastRangeKey == rangeKey && schedulesList.isNotEmpty) return;

    _lastRangeKey = rangeKey;

    try {
      isLoading.value = true;
      errorMessage.value = '';

      final schedules = await _operatingScheduleRepository
          .getAllOperatingSchedules(startDate: startIso, endDate: endIso);

      schedulesList.value = schedules;
    } catch (e) {
      final message =
          e is ApiException
              ? e.message
              : 'Gagal memuat jadwal operasional. Silakan coba lagi.';

      errorMessage.value = message;
      _logger.error('Error fetchForCalendarRange ($startIso-$endIso): $e');

      if (!silent) {
        Get.snackbar(
          'Error',
          message,
          backgroundColor: ColorTheme.error.withValues(alpha: 0.1),
          colorText: ColorTheme.error,
        );
      }
    } finally {
      isLoading.value = false;
    }
  }

  /// Kalau kamu butuh paksa refresh range yang sama (misalnya setelah add/delete),
  /// panggil ini sebelum fetchForCalendarRange().
  void invalidateCalendarCache() {
    _lastRangeKey = null;
  }

  // =========================
  // Existing API (tetap dipertahankan biar tidak merusak file lain)
  // =========================

  Future<void> fetchAllSchedules({
    String? date,
    bool? isHoliday,
    String? startDate,
    String? endDate,
    bool showSnackbarOnError = true,
  }) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      final schedules = await _operatingScheduleRepository
          .getAllOperatingSchedules(
            date: date,
            isHoliday: isHoliday,
            startDate: startDate,
            endDate: endDate,
          );

      schedulesList.value = schedules;
    } catch (e) {
      final message =
          e is ApiException
              ? e.message
              : 'Gagal memuat jadwal operasional. Silakan coba lagi.';

      errorMessage.value = message;
      _logger.error('Error fetching operating schedules: $e');

      if (showSnackbarOnError) {
        Get.snackbar(
          'Error',
          message,
          backgroundColor: ColorTheme.error.withValues(alpha: 0.1),
          colorText: ColorTheme.error,
        );
      }
    } finally {
      isLoading.value = false;
    }
  }

  // Refresh data (hindari memanggil ini dari kalender kecuali memang mau fetch tanpa filter)
  void refreshData() {
    fetchAllSchedules();
  }

  void navigateToAddSchedule() {
    Get.toNamed(AppRoutes.operatingScheduleForm);
  }

  void navigateToEditSchedule(String id) {
    Get.toNamed('${AppRoutes.operatingScheduleForm}/$id');
  }

  Future<bool> addOperatingSchedule({
    required String date,
    bool isHoliday = false,
    String? notes,
  }) async {
    try {
      isFormSubmitting.value = true;

      final schedule = await _operatingScheduleRepository
          .createOperatingSchedule(
            date: date,
            isHoliday: isHoliday,
            notes: notes,
          );

      // Update list lokal
      schedulesList.add(schedule);
      schedulesList.refresh();

      // invalidate marker cache (biar range calendar nanti bisa refetch)
      invalidateCalendarCache();

      Get.snackbar(
        'Success',
        'Jadwal operasional berhasil ditambahkan',
        backgroundColor: ColorTheme.success.withValues(alpha: 0.1),
        colorText: ColorTheme.success,
      );

      Get.back();
      return true;
    } catch (e) {
      final message =
          e is ApiException
              ? e.message
              : 'Gagal menambahkan jadwal operasional';

      Get.snackbar(
        'Error',
        message,
        backgroundColor: ColorTheme.error.withValues(alpha: 0.1),
        colorText: ColorTheme.error,
      );
      _logger.error('Error adding operating schedule: $e');
      return false;
    } finally {
      isFormSubmitting.value = false;
    }
  }

  Future<bool> updateOperatingSchedule({
    required String id,
    String? date,
    bool? isHoliday,
    String? notes,
  }) async {
    try {
      isFormSubmitting.value = true;

      final schedule = await _operatingScheduleRepository
          .updateOperatingSchedule(
            id: id,
            date: date,
            isHoliday: isHoliday,
            notes: notes,
          );

      final index = schedulesList.indexWhere((s) => s.id == id);
      if (index != -1) {
        schedulesList[index] = schedule;
        schedulesList.refresh();
      }

      if (currentSchedule.value?.id == id) {
        currentSchedule.value = schedule;
      }

      invalidateCalendarCache();

      Get.snackbar(
        'Success',
        'Jadwal operasional berhasil diperbarui',
        backgroundColor: ColorTheme.success.withValues(alpha: 0.1),
        colorText: ColorTheme.success,
      );

      Get.back();
      return true;
    } catch (e) {
      final message =
          e is ApiException
              ? e.message
              : 'Gagal memperbarui jadwal operasional';

      Get.snackbar(
        'Error',
        message,
        backgroundColor: ColorTheme.error.withValues(alpha: 0.1),
        colorText: ColorTheme.error,
      );
      _logger.error('Error updating operating schedule: $e');
      return false;
    } finally {
      isFormSubmitting.value = false;
    }
  }

  Future<bool> toggleHolidayStatus(OperatingSchedule schedule) async {
    try {
      final updatedSchedule = await _operatingScheduleRepository
          .toggleHolidayStatus(schedule.id, !schedule.isHoliday);

      final index = schedulesList.indexWhere((s) => s.id == schedule.id);
      if (index != -1) {
        schedulesList[index] = updatedSchedule;
        schedulesList.refresh();
      }

      if (currentSchedule.value?.id == schedule.id) {
        currentSchedule.value = updatedSchedule;
      }

      invalidateCalendarCache();

      Get.snackbar(
        'Success',
        schedule.isHoliday
            ? 'Status hari libur berhasil dibatalkan'
            : 'Status hari libur berhasil diaktifkan',
        backgroundColor: ColorTheme.success.withValues(alpha: 0.1),
        colorText: ColorTheme.success,
      );

      return true;
    } catch (e) {
      final message =
          e is ApiException ? e.message : 'Gagal mengubah status hari libur';

      Get.snackbar(
        'Error',
        message,
        backgroundColor: ColorTheme.error.withValues(alpha: 0.1),
        colorText: ColorTheme.error,
      );
      _logger.error('Error toggling holiday status: $e');
      return false;
    }
  }

  Future<bool> deleteOperatingSchedule(String id) async {
    try {
      final isDeleted = await _operatingScheduleRepository
          .deleteOperatingSchedule(id);

      if (isDeleted) {
        schedulesList.removeWhere((schedule) => schedule.id == id);

        if (currentSchedule.value?.id == id) {
          currentSchedule.value = null;
        }

        invalidateCalendarCache();

        Get.snackbar(
          'Success',
          'Jadwal operasional berhasil dihapus',
          backgroundColor: ColorTheme.success.withValues(alpha: 0.1),
          colorText: ColorTheme.success,
        );

        return true;
      }
      return false;
    } catch (e) {
      final message =
          e is ApiException ? e.message : 'Gagal menghapus jadwal operasional';

      Get.snackbar(
        'Error',
        message,
        backgroundColor: ColorTheme.error.withValues(alpha: 0.1),
        colorText: ColorTheme.error,
      );
      _logger.error('Error deleting operating schedule: $e');
      return false;
    }
  }

  Future<OperatingSchedule?> fetchScheduleById(String id) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      if (id.isEmpty) {
        throw ApiException(message: "ID jadwal operasional diperlukan");
      }

      final schedule = await _operatingScheduleRepository
          .getOperatingScheduleById(id);
      currentSchedule.value = schedule;
      return schedule;
    } catch (e) {
      final message =
          e is ApiException ? e.message : 'Gagal mengambil jadwal operasional';

      errorMessage.value = message;
      _logger.error('Error fetching operating schedule by ID: $e');

      Get.snackbar(
        'Error',
        message,
        backgroundColor: ColorTheme.error.withValues(alpha: 0.1),
        colorText: ColorTheme.error,
      );

      return null;
    } finally {
      isLoading.value = false;
    }
  }

  Future<OperatingSchedule?> fetchScheduleByDate(String date) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      if (date.isEmpty) {
        throw ApiException(message: "Tanggal diperlukan");
      }

      final schedule = await _operatingScheduleRepository
          .getOperatingScheduleByDate(date);
      currentSchedule.value = schedule;
      return schedule;
    } catch (e) {
      final message =
          e is ApiException
              ? e.message
              : 'Gagal mengambil jadwal operasional untuk tanggal tersebut';

      errorMessage.value = message;
      _logger.error('Error fetching operating schedule by date: $e');

      // sesuai pattern kamu: jangan snackbar untuk kasus "tidak ditemukan"
      if (!(e is ApiException && message.contains('tidak ditemukan'))) {
        Get.snackbar(
          'Error',
          message,
          backgroundColor: ColorTheme.error.withValues(alpha: 0.1),
          colorText: ColorTheme.error,
        );
      }

      return null;
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> hasScheduleForDate(String date) async {
    try {
      await _operatingScheduleRepository.getOperatingScheduleByDate(date);
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<void> fetchHolidaySchedules() async {
    return fetchAllSchedules(isHoliday: true);
  }

  Future<void> fetchNonHolidaySchedules() async {
    return fetchAllSchedules(isHoliday: false);
  }

  // =========================
  // Helpers
  // =========================

  String _fmt(DateTime d) => DateFormat('yyyy-MM-dd').format(d);
}
