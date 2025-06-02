// lib/features/time_slot/controllers/time_slot_controller.dart
import 'package:flutter/material.dart'
    show TimeOfDay; // Import TimeOfDay from Flutter
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

  /// Format DateTime to ISO8601 string with Z suffix
  String _formatDateTimeToIso8601(DateTime dateTime) {
    return "${dateTime.toIso8601String()}Z";
  }

  void resetTimeSlotState() {
    timeSlots.clear();
    selectedTimeSlot.value = null;
    availableTimeSlots.clear();
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
      // Ensure we use ISO8601 format with Z suffix
      final formattedStartTime = _formatDateTimeToIso8601(startTime);
      final formattedEndTime = _formatDateTimeToIso8601(endTime);

      _logger.debug(
        'Creating time slot with startTime: $formattedStartTime, endTime: $formattedEndTime',
      );

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
      // Ensure all ISO strings have the Z suffix
      final formattedTimeSlotsData =
          timeSlotsData.map((slot) {
            final Map<String, dynamic> formattedSlot = {...slot};
            if (formattedSlot.containsKey('startTime') &&
                formattedSlot['startTime'] is String) {
              final startTime = formattedSlot['startTime'] as String;
              if (!startTime.endsWith('Z')) {
                formattedSlot['startTime'] =
                    "$startTime${startTime.endsWith('.000') ? 'Z' : '.000Z'}";
              }
            }
            if (formattedSlot.containsKey('endTime') &&
                formattedSlot['endTime'] is String) {
              final endTime = formattedSlot['endTime'] as String;
              if (!endTime.endsWith('Z')) {
                formattedSlot['endTime'] =
                    "$endTime${endTime.endsWith('.000') ? 'Z' : '.000Z'}";
              }
            }
            return formattedSlot;
          }).toList();

      _logger.debug('Creating multiple time slots: $formattedTimeSlotsData');

      final createdTimeSlots = await _repository.createMultipleTimeSlots(
        operatingScheduleId: operatingScheduleId,
        timeSlots: formattedTimeSlotsData,
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

  /// Generate time slots with fixed intervals
  /// Example: 7:00-8:00, 8:00-9:00, 9:00-10:00
  Future<List<TimeSlot>?> generateFixedIntervalTimeSlots({
    required String operatingScheduleId,
    required DateTime startDate,
    required TimeOfDay firstSlotStart,
    required TimeOfDay lastSlotEnd,
    required Duration slotDuration,
  }) async {
    try {
      // Generate time slot data
      final List<Map<String, dynamic>> timeSlotsData = [];

      DateTime currentStart = DateTime(
        startDate.year,
        startDate.month,
        startDate.day,
        firstSlotStart.hour,
        firstSlotStart.minute,
      );

      final DateTime endLimit = DateTime(
        startDate.year,
        startDate.month,
        startDate.day,
        lastSlotEnd.hour,
        lastSlotEnd.minute,
      );

      while (currentStart.add(slotDuration).isBefore(endLimit) ||
          currentStart.add(slotDuration).isAtSameMomentAs(endLimit)) {
        final DateTime slotEnd = currentStart.add(slotDuration);

        timeSlotsData.add({
          'startTime': _formatDateTimeToIso8601(currentStart),
          'endTime': _formatDateTimeToIso8601(slotEnd),
        });

        // Move to next slot
        currentStart = slotEnd;
      }

      // Create the time slots if we have any
      if (timeSlotsData.isNotEmpty) {
        return await createMultipleTimeSlots(
          operatingScheduleId: operatingScheduleId,
          timeSlotsData: timeSlotsData,
        );
      }

      return [];
    } catch (e) {
      errorMessage.value = 'Gagal membuat jadwal dengan interval tetap.';
      _logger.error('Error generating fixed interval time slots: $e');
      return null;
    }
  }

  /// Generate time slots with custom intervals
  /// Example: 7:00-8:00, 8:30-9:30, 10:00-11:00
  Future<List<TimeSlot>?> generateCustomTimeSlots({
    required String operatingScheduleId,
    required DateTime date,
    required List<Map<String, dynamic>> timeRanges,
  }) async {
    try {
      // Validate time ranges format
      for (var range in timeRanges) {
        if (!range.containsKey('start') || !range.containsKey('end')) {
          errorMessage.value = 'Format rentang waktu tidak valid.';
          return null;
        }
      }

      // Generate time slot data
      final List<Map<String, dynamic>> timeSlotsData = [];

      for (var range in timeRanges) {
        final TimeOfDay start = range['start'];
        final TimeOfDay end = range['end'];

        final DateTime startTime = DateTime(
          date.year,
          date.month,
          date.day,
          start.hour,
          start.minute,
        );

        final DateTime endTime = DateTime(
          date.year,
          date.month,
          date.day,
          end.hour,
          end.minute,
        );

        // Ensure start time is before end time
        if (startTime.isBefore(endTime)) {
          timeSlotsData.add({
            'startTime': _formatDateTimeToIso8601(startTime),
            'endTime': _formatDateTimeToIso8601(endTime),
          });
        }
      }

      // Create the time slots if we have any
      if (timeSlotsData.isNotEmpty) {
        return await createMultipleTimeSlots(
          operatingScheduleId: operatingScheduleId,
          timeSlotsData: timeSlotsData,
        );
      }

      return [];
    } catch (e) {
      errorMessage.value = 'Gagal membuat jadwal dengan interval kustom.';
      _logger.error('Error generating custom time slots: $e');
      return null;
    }
  }

  /// Check if time slots overlap
  bool hasOverlap(List<TimeSlot> slots) {
    if (slots.length <= 1) return false;

    // Sort by start time
    final sortedSlots = [...slots]
      ..sort((a, b) => a.startTime.compareTo(b.startTime));

    for (int i = 0; i < sortedSlots.length - 1; i++) {
      // For each pair of adjacent slots
      final currentSlot = sortedSlots[i];
      final nextSlot = sortedSlots[i + 1];

      // Check for overlap: current slot ends after or exactly when next slot starts
      if (currentSlot.endTime.isAfter(nextSlot.startTime) ||
          currentSlot.endTime.isAtSameMomentAs(nextSlot.startTime)) {
        // Exception for back-to-back slots (e.g. 8:00-9:00 and 9:00-10:00)
        // These shouldn't count as overlaps
        if (currentSlot.endTime.isAtSameMomentAs(nextSlot.startTime)) {
          continue;
        }
        return true;
      }
    }

    return false;
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
    timeSlots.clear(); // Clear existing data

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
      // Ensure we format the dates properly with Z suffix
      DateTime? formattedStartTime = startTime;
      DateTime? formattedEndTime = endTime;

      _logger.debug('Updating time slot with ID: $id');
      if (startTime != null) {
        _logger.debug('Start time: ${_formatDateTimeToIso8601(startTime)}');
      }
      if (endTime != null) {
        _logger.debug('End time: ${_formatDateTimeToIso8601(endTime)}');
      }

      final updatedTimeSlot = await _repository.updateTimeSlot(
        id: id,
        operatingScheduleId: operatingScheduleId,
        startTime: formattedStartTime,
        endTime: formattedEndTime,
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

  Future<void> refreshSelectedTimeSlot(String id) async {
    await fetchTimeSlotById(id);
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

  /// Get duration of a time slot in minutes
  int getTimeSlotDurationMinutes(TimeSlot slot) {
    return slot.endTime.difference(slot.startTime).inMinutes;
  }

  /// Sort time slots by start time
  List<TimeSlot> getSortedTimeSlots(List<TimeSlot> slots) {
    final sortedSlots = [...slots];
    sortedSlots.sort((a, b) => a.startTime.compareTo(b.startTime));
    return sortedSlots;
  }
}
