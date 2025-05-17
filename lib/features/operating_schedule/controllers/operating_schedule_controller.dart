// lib/features/operating_schedule/controllers/operating_schedule_controller.dart
// lib/features/operating_schedule/controllers/operating_schedule_controller.dart
import 'package:get/get.dart';
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

  @override
  void onInit() {
    super.onInit();
    fetchAllSchedules();
  }

  // Fetch all operating schedules with comprehensive filtering options
  Future<void> fetchAllSchedules({
    String? date,
    bool? isHoliday,
    String? startDate,
    String? endDate,
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
      String message =
          e is ApiException
              ? e.message
              : 'Gagal memuat jadwal operasional. Silakan coba lagi.';

      errorMessage.value = message;
      _logger.error('Error fetching operating schedules: $e');

      // Show error snackbar for better UX
      Get.snackbar(
        'Error',
        message,
        backgroundColor: ColorTheme.error.withValues(alpha: 0.1),
        colorText: ColorTheme.error,
      );
    } finally {
      isLoading.value = false;
    }
  }

  // Fetch schedules for a specific date range
  Future<void> fetchSchedulesForRange(DateTime start, DateTime end) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      // Format dates to ISO string and take only the date part
      final startIso = start.toIso8601String().split('T')[0];
      final endIso = end.toIso8601String().split('T')[0];

      final schedules = await _operatingScheduleRepository
          .getAllOperatingSchedules(startDate: startIso, endDate: endIso);

      schedulesList.value = schedules;
    } catch (e) {
      String message =
          e is ApiException
              ? e.message
              : 'Gagal memuat jadwal untuk rentang tanggal yang dipilih.';

      errorMessage.value = message;
      _logger.error('Error fetching schedules for date range: $e');

      Get.snackbar(
        'Error',
        message,
        backgroundColor: ColorTheme.error.withValues(alpha: 0.1),
        colorText: ColorTheme.error,
      );
    } finally {
      isLoading.value = false;
    }
  }

  // Refresh data
  void refreshData() {
    fetchAllSchedules();
  }

  // Navigate to add schedule screen
  void navigateToAddSchedule() {
    Get.toNamed(AppRoutes.operatingScheduleForm);
  }

  // Navigate to edit schedule screen
  void navigateToEditSchedule(String id) {
    Get.toNamed('${AppRoutes.operatingScheduleForm}/$id');
  }

  // Add new operating schedule
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

      // Add to list if successful
      schedulesList.add(schedule);
      schedulesList.refresh(); // Ensure UI updates

      // Show success message
      Get.snackbar(
        'Success',
        'Jadwal operasional berhasil ditambahkan',
        backgroundColor: ColorTheme.success.withValues(alpha: 0.1),
        colorText: ColorTheme.success,
      );

      // Navigate back
      Get.back();
      return true;
    } catch (e) {
      // Show error message
      String message =
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

  // Update operating schedule
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

      // Update list item if successful
      final index = schedulesList.indexWhere((s) => s.id == id);
      if (index != -1) {
        schedulesList[index] = schedule;
        schedulesList.refresh();
      }

      // Update current schedule if it's the one being edited
      if (currentSchedule.value?.id == id) {
        currentSchedule.value = schedule;
      }

      // Show success message
      Get.snackbar(
        'Success',
        'Jadwal operasional berhasil diperbarui',
        backgroundColor: ColorTheme.success.withValues(alpha: 0.1),
        colorText: ColorTheme.success,
      );

      // Navigate back
      Get.back();
      return true;
    } catch (e) {
      // Show error message
      String message =
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

  // Toggle holiday status
  Future<bool> toggleHolidayStatus(OperatingSchedule schedule) async {
    try {
      final updatedSchedule = await _operatingScheduleRepository
          .toggleHolidayStatus(schedule.id, !schedule.isHoliday);

      // Update list item if successful
      final index = schedulesList.indexWhere((s) => s.id == schedule.id);
      if (index != -1) {
        schedulesList[index] = updatedSchedule;
        schedulesList.refresh();
      }

      // Update current schedule if it's the one being modified
      if (currentSchedule.value?.id == schedule.id) {
        currentSchedule.value = updatedSchedule;
      }

      // Show success message
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
      // Show error message
      String message =
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

  // Delete operating schedule
  Future<bool> deleteOperatingSchedule(String id) async {
    try {
      final isDeleted = await _operatingScheduleRepository
          .deleteOperatingSchedule(id);

      if (isDeleted) {
        // Remove from list if successful
        schedulesList.removeWhere((schedule) => schedule.id == id);

        // Clear current schedule if it's the one being deleted
        if (currentSchedule.value?.id == id) {
          currentSchedule.value = null;
        }

        // Show success message
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
      // Show error message
      String message =
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

  // Fetch operating schedule by ID
  Future<OperatingSchedule?> fetchScheduleById(String id) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      // Validate id
      if (id.isEmpty) {
        throw ApiException(message: "ID jadwal operasional diperlukan");
      }

      final schedule = await _operatingScheduleRepository
          .getOperatingScheduleById(id);
      currentSchedule.value = schedule;
      return schedule;
    } catch (e) {
      String message =
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

  // Fetch operating schedule by date
  Future<OperatingSchedule?> fetchScheduleByDate(String date) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      // Validate date
      if (date.isEmpty) {
        throw ApiException(message: "Tanggal diperlukan");
      }

      final schedule = await _operatingScheduleRepository
          .getOperatingScheduleByDate(date);
      currentSchedule.value = schedule;
      return schedule;
    } catch (e) {
      String message =
          e is ApiException
              ? e.message
              : 'Gagal mengambil jadwal operasional untuk tanggal tersebut';

      errorMessage.value = message;
      _logger.error('Error fetching operating schedule by date: $e');

      // Don't show snackbar for 404 errors when checking for schedule existence
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

  // Check if a date has an operating schedule
  Future<bool> hasScheduleForDate(String date) async {
    try {
      await _operatingScheduleRepository.getOperatingScheduleByDate(date);
      return true;
    } catch (e) {
      return false;
    }
  }

  // Get holiday schedules
  Future<void> fetchHolidaySchedules() async {
    return fetchAllSchedules(isHoliday: true);
  }

  // Get non-holiday schedules
  Future<void> fetchNonHolidaySchedules() async {
    return fetchAllSchedules(isHoliday: false);
  }
}
