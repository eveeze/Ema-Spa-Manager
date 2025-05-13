// lib/features/operating_schedule/controllers/operating_schedule_controller.dart
import 'package:get/get.dart';
import 'package:emababyspa/data/models/operating_schedule.dart';
import 'package:emababyspa/data/repository/operating_schedule_repository.dart';
import 'package:emababyspa/utils/app_routes.dart';
import 'package:emababyspa/common/theme/color_theme.dart';
import 'package:emababyspa/utils/logger_utils.dart';

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

  @override
  void onInit() {
    super.onInit();
    fetchAllSchedules();
  }

  // Fetch all operating schedules
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
      errorMessage.value =
          'Failed to load operating schedules. Please try again.';
      _logger.error('Error fetching operating schedules: $e');
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
    Get.toNamed('/operating-schedules/edit/$id');
  }

  // Add new operating schedule
  Future<void> addOperatingSchedule({
    required String date,
    bool? isHoliday,
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

      // Show success message
      Get.snackbar(
        'Success',
        'Operating schedule added successfully',
        backgroundColor: ColorTheme.success.withValues(alpha: 0.1),
        colorText: ColorTheme.success,
      );

      // Navigate back
      Get.back();
    } catch (e) {
      // Show error message
      Get.snackbar(
        'Error',
        'Failed to add operating schedule',
        backgroundColor: ColorTheme.error.withValues(alpha: 0.1),
        colorText: ColorTheme.error,
      );
      _logger.error('Error adding operating schedule: $e');
    } finally {
      isFormSubmitting.value = false;
    }
  }

  // Update operating schedule
  Future<void> updateOperatingSchedule({
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

      // Show success message
      Get.snackbar(
        'Success',
        'Operating schedule updated successfully',
        backgroundColor: ColorTheme.success.withValues(alpha: 0.1),
        colorText: ColorTheme.success,
      );

      // Navigate back
      Get.back();
    } catch (e) {
      // Show error message
      Get.snackbar(
        'Error',
        'Failed to update operating schedule',
        backgroundColor: ColorTheme.error.withValues(alpha: 0.1),
        colorText: ColorTheme.error,
      );
      _logger.error('Error updating operating schedule: $e');
    } finally {
      isFormSubmitting.value = false;
    }
  }

  // Toggle holiday status
  Future<void> toggleHolidayStatus(OperatingSchedule schedule) async {
    try {
      final updatedSchedule = await _operatingScheduleRepository
          .toggleHolidayStatus(schedule.id, !schedule.isHoliday);

      // Update list item if successful
      final index = schedulesList.indexWhere((s) => s.id == schedule.id);
      if (index != -1) {
        schedulesList[index] = updatedSchedule;
        schedulesList.refresh();
      }

      // Show success message
      Get.snackbar(
        'Success',
        'Holiday status updated successfully',
        backgroundColor: ColorTheme.success.withValues(alpha: 0.1),
        colorText: ColorTheme.success,
      );
    } catch (e) {
      // Show error message
      Get.snackbar(
        'Error',
        'Failed to update holiday status',
        backgroundColor: ColorTheme.error.withValues(alpha: 0.1),
        colorText: ColorTheme.error,
      );
      _logger.error('Error toggling holiday status: $e');
    }
  }

  // Delete operating schedule
  Future<void> deleteOperatingSchedule(String id) async {
    try {
      final isDeleted = await _operatingScheduleRepository
          .deleteOperatingSchedule(id);

      if (isDeleted) {
        // Remove from list if successful
        schedulesList.removeWhere((schedule) => schedule.id == id);

        // Show success message
        Get.snackbar(
          'Success',
          'Operating schedule deleted successfully',
          backgroundColor: ColorTheme.success.withValues(alpha: 0.1),
          colorText: ColorTheme.success,
        );
      }
    } catch (e) {
      // Show error message
      Get.snackbar(
        'Error',
        'Failed to delete operating schedule',
        backgroundColor: ColorTheme.error.withValues(alpha: 0.1),
        colorText: ColorTheme.error,
      );
      _logger.error('Error deleting operating schedule: $e');
    }
  }

  // Fetch operating schedule by ID
  Future<OperatingSchedule?> fetchScheduleById(String id) async {
    try {
      isLoading.value = true;

      // Validate id
      if (id.isEmpty) {
        throw Exception("Operating schedule ID is required");
      }

      return await _operatingScheduleRepository.getOperatingScheduleById(id);
    } catch (e) {
      errorMessage.value =
          'Failed to fetch operating schedule: ${e.toString()}';
      _logger.error('Error fetching operating schedule by ID: $e');
      return null;
    } finally {
      isLoading.value = false;
    }
  }

  // Fetch operating schedule by date
  Future<OperatingSchedule?> fetchScheduleByDate(String date) async {
    try {
      isLoading.value = true;

      // Validate date
      if (date.isEmpty) {
        throw Exception("Date is required");
      }

      return await _operatingScheduleRepository.getOperatingScheduleByDate(
        date,
      );
    } catch (e) {
      errorMessage.value =
          'Failed to fetch operating schedule: ${e.toString()}';
      _logger.error('Error fetching operating schedule by date: $e');
      return null;
    } finally {
      isLoading.value = false;
    }
  }
}
