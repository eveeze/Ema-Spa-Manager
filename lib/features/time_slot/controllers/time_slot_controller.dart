// lib/features/time_slot/controllers/time_slot_controller.dart
import 'package:flutter/material.dart' show TimeOfDay;
import 'package:get/get.dart';
import 'package:emababyspa/data/api/api_exception.dart';
import 'package:emababyspa/data/models/time_slot.dart';
import 'package:emababyspa/data/repository/time_slot_repository.dart';
import 'package:emababyspa/utils/logger_utils.dart';
// import 'package:intl/intl.dart'; // Not strictly needed here if repository handles final formatting

class TimeSlotController extends GetxController {
  final TimeSlotRepository _repository;
  final LoggerUtils _logger = LoggerUtils();

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

  void resetTimeSlotState() {
    timeSlots.clear();
    selectedTimeSlot.value = null;
    availableTimeSlots.clear();
    errorMessage.value = '';
    isLoading.value = false;
    isCreating.value = false;
    isUpdating.value = false;
    isDeleting.value = false;
  }

  Future<TimeSlot?> createTimeSlot({
    required String operatingScheduleId,
    required DateTime startTime, // Expecting local DateTime from Dialog
    required DateTime endTime, // Expecting local DateTime from Dialog
  }) async {
    isCreating.value = true;
    errorMessage.value = '';
    try {
      _logger.debug(
        'Controller: Creating time slot for schedule $operatingScheduleId. Start: ${startTime.toIso8601String()} (local), End: ${endTime.toIso8601String()} (local)',
      );
      final timeSlot = await _repository.createTimeSlot(
        operatingScheduleId: operatingScheduleId,
        startTime: startTime, // Pass local DateTime
        endTime: endTime, // Pass local DateTime
      );
      timeSlots.add(timeSlot);
      await fetchTimeSlotsByScheduleId(operatingScheduleId); // Refresh list
      return timeSlot;
    } on ApiException catch (e) {
      errorMessage.value = e.message;
      _logger.error('Controller: Failed to create time slot: ${e.message}');
      return null;
    } catch (e) {
      errorMessage.value =
          'Terjadi kesalahan tidak terduga. Silakan coba lagi nanti.';
      _logger.error('Controller: Unexpected error creating time slot: $e');
      return null;
    } finally {
      isCreating.value = false;
    }
  }

  Future<List<TimeSlot>?> createMultipleTimeSlots({
    required String operatingScheduleId,
    required List<Map<String, dynamic>>
    timeSlotsData, // Expects maps with 'startTime'/'endTime' as DateTime
  }) async {
    isCreating.value = true;
    errorMessage.value = '';
    try {
      _logger.debug(
        'Controller: Creating multiple time slots for schedule $operatingScheduleId with data: $timeSlotsData',
      );
      final createdTimeSlots = await _repository.createMultipleTimeSlots(
        operatingScheduleId: operatingScheduleId,
        timeSlots: timeSlotsData, // Pass list of maps with DateTime objects
      );
      timeSlots.addAll(createdTimeSlots);
      await fetchTimeSlotsByScheduleId(operatingScheduleId); // Refresh list
      return createdTimeSlots;
    } on ApiException catch (e) {
      errorMessage.value = e.message;
      _logger.error(
        'Controller: Failed to create multiple time slots: ${e.message}',
      );
      return null;
    } catch (e) {
      errorMessage.value =
          'Terjadi kesalahan tidak terduga. Silakan coba lagi nanti.';
      _logger.error(
        'Controller: Unexpected error creating multiple time slots: $e',
      );
      return null;
    } finally {
      isCreating.value = false;
    }
  }

  Future<List<TimeSlot>?> generateFixedIntervalTimeSlots({
    required String operatingScheduleId,
    required DateTime startDate, // Base date for the slots
    required TimeOfDay firstSlotStart,
    required TimeOfDay lastSlotEnd,
    required Duration slotDuration,
  }) async {
    errorMessage.value = '';
    try {
      final List<Map<String, dynamic>> timeSlotsToCreate = [];
      DateTime currentIterationStartTime = DateTime(
        startDate.year,
        startDate.month,
        startDate.day,
        firstSlotStart.hour,
        firstSlotStart.minute,
      );
      final DateTime overallEndTimeLimit = DateTime(
        startDate.year,
        startDate.month,
        startDate.day,
        lastSlotEnd.hour,
        lastSlotEnd.minute,
      );

      if (currentIterationStartTime.isAfter(overallEndTimeLimit) ||
          slotDuration.isNegative ||
          slotDuration.inMinutes <= 0) {
        errorMessage.value = 'Pengaturan interval waktu tidak valid.';
        _logger.warning(
          'Controller: Invalid interval settings for fixed generation.',
        );
        return null;
      }

      while (currentIterationStartTime
              .add(slotDuration)
              .isBefore(overallEndTimeLimit) ||
          currentIterationStartTime
              .add(slotDuration)
              .isAtSameMomentAs(overallEndTimeLimit)) {
        final DateTime currentIterationEndTime = currentIterationStartTime.add(
          slotDuration,
        );
        timeSlotsToCreate.add({
          'startTime': currentIterationStartTime, // DateTime object
          'endTime': currentIterationEndTime, // DateTime object
        });
        currentIterationStartTime = currentIterationEndTime;
      }

      if (timeSlotsToCreate.isNotEmpty) {
        return await createMultipleTimeSlots(
          operatingScheduleId: operatingScheduleId,
          timeSlotsData: timeSlotsToCreate,
        );
      }
      return []; // No slots generated
    } catch (e) {
      errorMessage.value = 'Gagal membuat jadwal interval tetap.';
      _logger.error(
        'Controller: Error generating fixed interval time slots: $e',
      );
      return null;
    }
  }

  Future<List<TimeSlot>?> generateCustomTimeSlots({
    required String operatingScheduleId,
    required DateTime date, // The specific date for these custom slots
    required List<Map<String, dynamic>>
    timeRanges, // Expects maps like [{'start': TimeOfDay, 'end': TimeOfDay}]
  }) async {
    errorMessage.value = '';
    try {
      final List<Map<String, dynamic>> timeSlotsToCreate = [];
      for (final range in timeRanges) {
        if (!(range['start'] is TimeOfDay && range['end'] is TimeOfDay)) {
          errorMessage.value = 'Format rentang waktu kustom tidak valid.';
          _logger.warning(
            'Controller: Invalid custom time range format: $range',
          );
          return null; // Or skip this range
        }
        final TimeOfDay todStart = range['start'] as TimeOfDay;
        final TimeOfDay todEnd = range['end'] as TimeOfDay;

        final DateTime slotStartTime = DateTime(
          date.year,
          date.month,
          date.day,
          todStart.hour,
          todStart.minute,
        );
        final DateTime slotEndTime = DateTime(
          date.year,
          date.month,
          date.day,
          todEnd.hour,
          todEnd.minute,
        );

        if (slotStartTime.isBefore(slotEndTime)) {
          timeSlotsToCreate.add({
            'startTime': slotStartTime, // DateTime object
            'endTime': slotEndTime, // DateTime object
          });
        } else {
          _logger.warning(
            'Controller: Skipping invalid custom time range (start not before end): $slotStartTime to $slotEndTime',
          );
        }
      }

      if (timeSlotsToCreate.isNotEmpty) {
        return await createMultipleTimeSlots(
          operatingScheduleId: operatingScheduleId,
          timeSlotsData: timeSlotsToCreate,
        );
      }
      return []; // No slots generated
    } catch (e) {
      errorMessage.value = 'Gagal membuat jadwal interval kustom.';
      _logger.error('Controller: Error generating custom time slots: $e');
      return null;
    }
  }

  bool hasOverlap(List<TimeSlot> slotsToCheck) {
    if (slotsToCheck.length <= 1) return false;
    // Ensure we are comparing apples to apples. TimeSlot model has UTC DateTime.
    final sortedSlots = List<TimeSlot>.from(slotsToCheck)..sort(
      (a, b) => a.startTime.compareTo(b.startTime),
    ); // Sort by UTC start times

    for (int i = 0; i < sortedSlots.length - 1; i++) {
      final currentSlot = sortedSlots[i]; // Has UTC times
      final nextSlot = sortedSlots[i + 1]; // Has UTC times
      // Overlap if current UTC end time is after next UTC start time
      // (excluding cases where they are exactly back-to-back)
      if (currentSlot.endTime.isAtSameMomentAs(nextSlot.startTime)) {
        continue; // Back-to-back is not an overlap
      }
      if (currentSlot.endTime.isAfter(nextSlot.startTime)) {
        return true; // Genuine overlap
      }
    }
    return false;
  }

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
      _logger.error('Controller: Failed to fetch time slots: ${e.message}');
    } catch (e) {
      errorMessage.value =
          'Terjadi kesalahan tidak terduga. Silakan coba lagi nanti.';
      _logger.error('Controller: Unexpected error fetching time slots: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> fetchTimeSlotById(String id) async {
    isLoading.value = true;
    errorMessage.value = '';
    try {
      final timeSlot = await _repository.getTimeSlotById(id);
      selectedTimeSlot.value = timeSlot;
    } on ApiException catch (e) {
      errorMessage.value = e.message;
      _logger.error(
        'Controller: Failed to fetch time slot by ID $id: ${e.message}',
      );
      selectedTimeSlot.value = null;
    } catch (e) {
      errorMessage.value =
          'Terjadi kesalahan tidak terduga. Silakan coba lagi nanti.';
      _logger.error(
        'Controller: Unexpected error fetching time slot by ID $id: $e',
      );
      selectedTimeSlot.value = null;
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> fetchTimeSlotsByScheduleId(String scheduleId) async {
    isLoading.value = true;
    errorMessage.value = '';
    // timeSlots.clear(); // Clear before fetching for this specific schedule
    try {
      final fetchedTimeSlots = await _repository.getTimeSlotsByScheduleId(
        scheduleId,
      );
      // Replace only slots for this schedule ID or assignAll if this is the main list being viewed
      timeSlots.assignAll(
        fetchedTimeSlots,
      ); // Assuming this replaces the whole list for the current view
    } on ApiException catch (e) {
      errorMessage.value = e.message;
      _logger.error(
        'Controller: Failed to fetch time slots for schedule $scheduleId: ${e.message}',
      );
    } catch (e) {
      errorMessage.value =
          'Terjadi kesalahan tidak terduga. Silakan coba lagi nanti.';
      _logger.error(
        'Controller: Unexpected error fetching time slots for schedule $scheduleId: $e',
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> fetchAvailableTimeSlots(String date) async {
    // date "YYYY-MM-DD"
    isLoading.value = true;
    errorMessage.value = '';
    availableTimeSlots.clear();
    try {
      final fetchedTimeSlots = await _repository.getAvailableTimeSlots(date);
      availableTimeSlots.assignAll(fetchedTimeSlots);
    } on ApiException catch (e) {
      errorMessage.value = e.message;
      _logger.error(
        'Controller: Failed to fetch available time slots for date $date: ${e.message}',
      );
    } catch (e) {
      errorMessage.value =
          'Terjadi kesalahan tidak terduga. Silakan coba lagi nanti.';
      _logger.error(
        'Controller: Unexpected error fetching available time slots for date $date: $e',
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<TimeSlot?> updateTimeSlot({
    required String id,
    String? operatingScheduleId, // Usually not updated, but can be included
    DateTime? startTime, // Expecting local DateTime from Dialog
    DateTime? endTime, // Expecting local DateTime from Dialog
  }) async {
    isUpdating.value = true;
    errorMessage.value = '';
    try {
      _logger.debug(
        'Controller: Updating time slot ID $id. Start: ${startTime?.toIso8601String()}, End: ${endTime?.toIso8601String()}',
      );
      final updatedTimeSlot = await _repository.updateTimeSlot(
        id: id,
        operatingScheduleId: operatingScheduleId,
        startTime: startTime,
        endTime: endTime,
      );

      final index = timeSlots.indexWhere((slot) => slot.id == id);
      if (index != -1) {
        timeSlots[index] = updatedTimeSlot;
      }
      if (selectedTimeSlot.value?.id == id) {
        selectedTimeSlot.value = updatedTimeSlot;
      }
      // If the update changed the operatingScheduleId, the old list might need specific refresh.
      // For simplicity, refresh the current view or based on operatingScheduleId if provided.
      if (operatingScheduleId != null) {
        await fetchTimeSlotsByScheduleId(operatingScheduleId);
      } else if (timeSlots.isNotEmpty && index != -1) {
        // If operatingScheduleId wasn't changed, get it from the updated slot
        await fetchTimeSlotsByScheduleId(updatedTimeSlot.operatingScheduleId);
      }
      return updatedTimeSlot;
    } on ApiException catch (e) {
      errorMessage.value = e.message;
      _logger.error('Controller: Failed to update time slot $id: ${e.message}');
      return null;
    } catch (e) {
      errorMessage.value =
          'Terjadi kesalahan tidak terduga. Silakan coba lagi nanti.';
      _logger.error('Controller: Unexpected error updating time slot $id: $e');
      return null;
    } finally {
      isUpdating.value = false;
    }
  }

  Future<void> refreshSelectedTimeSlot(String id) async {
    await fetchTimeSlotById(id);
  }

  Future<bool> deleteTimeSlot(String id) async {
    isDeleting.value = true;
    errorMessage.value = '';
    String? scheduleIdToDeleteFrom;
    try {
      final slotToRemove = _FirstWhereOrNull(
        timeSlots,
      ).firstWhereOrNull((s) => s.id == id);
      if (slotToRemove != null) {
        scheduleIdToDeleteFrom = slotToRemove.operatingScheduleId;
      }

      final success = await _repository.deleteTimeSlot(id);
      if (success) {
        timeSlots.removeWhere((slot) => slot.id == id);
        if (selectedTimeSlot.value?.id == id) {
          selectedTimeSlot.value = null;
        }
        if (scheduleIdToDeleteFrom != null) {
          await fetchTimeSlotsByScheduleId(
            scheduleIdToDeleteFrom,
          ); // Refresh list
        }
      }
      return success;
    } on ApiException catch (e) {
      errorMessage.value = e.message;
      _logger.error('Controller: Failed to delete time slot $id: ${e.message}');
      return false;
    } catch (e) {
      errorMessage.value =
          'Terjadi kesalahan tidak terduga. Silakan coba lagi nanti.';
      _logger.error('Controller: Unexpected error deleting time slot $id: $e');
      return false;
    } finally {
      isDeleting.value = false;
    }
  }

  void clearErrors() {
    errorMessage.value = '';
  }

  void clearSelectedTimeSlot() {
    selectedTimeSlot.value = null;
  }

  String formatTimeRange(TimeSlot timeSlot) {
    // TimeSlot times are UTC, convert to local for display.
    final DateTime startTimeLocal = timeSlot.startTime.toLocal();
    final DateTime endTimeLocal = timeSlot.endTime.toLocal();

    final String startHour = startTimeLocal.hour.toString().padLeft(2, '0');
    final String startMinute = startTimeLocal.minute.toString().padLeft(2, '0');
    final String endHour = endTimeLocal.hour.toString().padLeft(2, '0');
    final String endMinute = endTimeLocal.minute.toString().padLeft(2, '0');

    return '$startHour:$startMinute - $endHour:$endMinute';
  }

  bool isTimeSlotAvailable(TimeSlot slot) {
    return slot.sessions == null || slot.sessions!.isEmpty;
  }

  int getTimeSlotDurationMinutes(TimeSlot slot) {
    // Duration is absolute, difference between UTC DateTimes is correct.
    return slot.endTime.difference(slot.startTime).inMinutes;
  }

  List<TimeSlot> getSortedTimeSlots(List<TimeSlot> slotsToSort) {
    final sortedList = List<TimeSlot>.from(slotsToSort);
    // Sort by UTC start times from the TimeSlot objects.
    sortedList.sort((a, b) => a.startTime.compareTo(b.startTime));
    return sortedList;
  }
}

extension _FirstWhereOrNull<T> on List<T> {
  T? firstWhereOrNull(bool Function(T element) test) {
    for (var element in this) {
      if (test(element)) return element;
    }
    return null;
  }
}
