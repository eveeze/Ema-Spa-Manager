// lib/features/time_slot/controllers/time_slot_controller.dart
import 'package:get/get.dart';
import 'package:emababyspa/data/api/api_exception.dart';
import 'package:emababyspa/data/models/time_slot.dart';
import 'package:emababyspa/data/repository/time_slot_repository.dart';
import 'package:emababyspa/utils/logger_utils.dart';

class TimeSlotController extends GetxController {
  final TimeSlotRepository _repository;
  final LoggerUtils _logger = LoggerUtils();

  // Observable variables
  final RxBool isLoading = false.obs;
  final RxBool isCreating = false.obs;
  final RxBool isUpdating = false.obs;
  final RxBool isDeleting = false.obs;
  final RxString errorMessage = ''.obs;
  final RxList<TimeSlot> timeSlots = <TimeSlot>[].obs;
  final Rx<TimeSlot?> selectedTimeSlot = Rx<TimeSlot?>(null);
  final RxList<TimeSlot> availableTimeSlots = <TimeSlot>[].obs;

  TimeSlotController({required TimeSlotRepository repository})
    : _repository = repository;

  @override
  void onInit() {
    super.onInit();
    _logger.debug('TimeSlotController initialized');
  }

  /// Create a new time slot
  Future<TimeSlot?> createTimeSlot({
    required String operatingScheduleId,
    required DateTime startTime,
    required DateTime endTime,
  }) async {
    isCreating.value = true;
    errorMessage.value = '';

    try {
      final timeSlot = await _repository.createTimeSlot(
        operatingScheduleId: operatingScheduleId,
        startTime: startTime,
        endTime: endTime,
      );

      // Add to list if successful
      timeSlots.add(timeSlot);

      // Return the created time slot
      return timeSlot;
    } on ApiException catch (e) {
      errorMessage.value = e.message;
      _logger.error('Failed to create time slot: ${e.message}');
      return null;
    } catch (e) {
      errorMessage.value = 'Terjadi kesalahan. Silakan coba lagi nanti.';
      _logger.error('Unexpected error creating time slot: $e');
      return null;
    } finally {
      isCreating.value = false;
    }
  }

  /// Create multiple time slots at once
  Future<List<TimeSlot>?> createMultipleTimeSlots({
    required String operatingScheduleId,
    required List<Map<String, dynamic>> timeSlotsData,
  }) async {
    isCreating.value = true;
    errorMessage.value = '';

    try {
      final createdTimeSlots = await _repository.createMultipleTimeSlots(
        operatingScheduleId: operatingScheduleId,
        timeSlots: timeSlotsData,
      );

      // Add all created time slots to the list
      timeSlots.addAll(createdTimeSlots);

      return createdTimeSlots;
    } on ApiException catch (e) {
      errorMessage.value = e.message;
      _logger.error('Failed to create multiple time slots: ${e.message}');
      return null;
    } catch (e) {
      errorMessage.value = 'Terjadi kesalahan. Silakan coba lagi nanti.';
      _logger.error('Unexpected error creating multiple time slots: $e');
      return null;
    } finally {
      isCreating.value = false;
    }
  }

  /// Fetch all time slots with optional filtering
  Future<void> fetchTimeSlots({
    String? operatingScheduleId,
    String? date,
    String? startTime,
    String? endTime,
  }) async {
    isLoading.value = true;
    errorMessage.value = '';

    try {
      final fetchedTimeSlots = await _repository.getAllTimeSlots(
        operatingScheduleId: operatingScheduleId,
        date: date,
        startTime: startTime,
        endTime: endTime,
      );

      timeSlots.assignAll(fetchedTimeSlots);
    } on ApiException catch (e) {
      errorMessage.value = e.message;
      _logger.error('Failed to fetch time slots: ${e.message}');
    } catch (e) {
      errorMessage.value = 'Terjadi kesalahan. Silakan coba lagi nanti.';
      _logger.error('Unexpected error fetching time slots: $e');
    } finally {
      isLoading.value = false;
    }
  }

  /// Fetch time slot by ID
  Future<void> fetchTimeSlotById(String id) async {
    isLoading.value = true;
    errorMessage.value = '';

    try {
      final timeSlot = await _repository.getTimeSlotById(id);
      selectedTimeSlot.value = timeSlot;
    } on ApiException catch (e) {
      errorMessage.value = e.message;
      _logger.error('Failed to fetch time slot by ID: ${e.message}');
    } catch (e) {
      errorMessage.value = 'Terjadi kesalahan. Silakan coba lagi nanti.';
      _logger.error('Unexpected error fetching time slot by ID: $e');
    } finally {
      isLoading.value = false;
    }
  }

  /// Fetch time slots by operating schedule ID
  Future<void> fetchTimeSlotsByScheduleId(String scheduleId) async {
    isLoading.value = true;
    errorMessage.value = '';

    try {
      final fetchedTimeSlots = await _repository.getTimeSlotsByScheduleId(
        scheduleId,
      );
      timeSlots.assignAll(fetchedTimeSlots);
    } on ApiException catch (e) {
      errorMessage.value = e.message;
      _logger.error('Failed to fetch time slots by schedule ID: ${e.message}');
    } catch (e) {
      errorMessage.value = 'Terjadi kesalahan. Silakan coba lagi nanti.';
      _logger.error('Unexpected error fetching time slots by schedule ID: $e');
    } finally {
      isLoading.value = false;
    }
  }

  /// Fetch available time slots by date
  Future<void> fetchAvailableTimeSlots(String date) async {
    isLoading.value = true;
    errorMessage.value = '';

    try {
      final fetchedTimeSlots = await _repository.getAvailableTimeSlots(date);
      availableTimeSlots.assignAll(fetchedTimeSlots);
    } on ApiException catch (e) {
      errorMessage.value = e.message;
      _logger.error('Failed to fetch available time slots: ${e.message}');
    } catch (e) {
      errorMessage.value = 'Terjadi kesalahan. Silakan coba lagi nanti.';
      _logger.error('Unexpected error fetching available time slots: $e');
    } finally {
      isLoading.value = false;
    }
  }

  /// Update time slot
  Future<TimeSlot?> updateTimeSlot({
    required String id,
    String? operatingScheduleId,
    DateTime? startTime,
    DateTime? endTime,
  }) async {
    isUpdating.value = true;
    errorMessage.value = '';

    try {
      final updatedTimeSlot = await _repository.updateTimeSlot(
        id: id,
        operatingScheduleId: operatingScheduleId,
        startTime: startTime,
        endTime: endTime,
      );

      // Update in list
      final index = timeSlots.indexWhere((slot) => slot.id == id);
      if (index >= 0) {
        timeSlots[index] = updatedTimeSlot;
      }

      // Update selected time slot if it's the same one
      if (selectedTimeSlot.value?.id == id) {
        selectedTimeSlot.value = updatedTimeSlot;
      }

      return updatedTimeSlot;
    } on ApiException catch (e) {
      errorMessage.value = e.message;
      _logger.error('Failed to update time slot: ${e.message}');
      return null;
    } catch (e) {
      errorMessage.value = 'Terjadi kesalahan. Silakan coba lagi nanti.';
      _logger.error('Unexpected error updating time slot: $e');
      return null;
    } finally {
      isUpdating.value = false;
    }
  }

  /// Delete time slot
  Future<bool> deleteTimeSlot(String id) async {
    isDeleting.value = true;
    errorMessage.value = '';

    try {
      final success = await _repository.deleteTimeSlot(id);

      if (success) {
        // Remove from list
        timeSlots.removeWhere((slot) => slot.id == id);

        // Clear selected time slot if it's the same one
        if (selectedTimeSlot.value?.id == id) {
          selectedTimeSlot.value = null;
        }
      }

      return success;
    } on ApiException catch (e) {
      errorMessage.value = e.message;
      _logger.error('Failed to delete time slot: ${e.message}');
      return false;
    } catch (e) {
      errorMessage.value = 'Terjadi kesalahan. Silakan coba lagi nanti.';
      _logger.error('Unexpected error deleting time slot: $e');
      return false;
    } finally {
      isDeleting.value = false;
    }
  }

  /// Clear all error messages
  void clearErrors() {
    errorMessage.value = '';
  }

  /// Clear selected time slot
  void clearSelectedTimeSlot() {
    selectedTimeSlot.value = null;
  }

  /// Format time for display
  String formatTimeRange(TimeSlot timeSlot) {
    final startHour = timeSlot.startTime.hour.toString().padLeft(2, '0');
    final startMinute = timeSlot.startTime.minute.toString().padLeft(2, '0');
    final endHour = timeSlot.endTime.hour.toString().padLeft(2, '0');
    final endMinute = timeSlot.endTime.minute.toString().padLeft(2, '0');

    return '$startHour:$startMinute - $endHour:$endMinute';
  }

  /// Check if a time slot is available (has no sessions)
  bool isTimeSlotAvailable(TimeSlot slot) {
    return slot.sessions == null || slot.sessions!.isEmpty;
  }
}
