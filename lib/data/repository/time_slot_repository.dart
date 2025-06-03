// lib/data/repository/time_slot_repository.dart
import 'package:emababyspa/data/api/api_exception.dart';
import 'package:emababyspa/data/providers/time_slot_provider.dart';
import 'package:emababyspa/data/models/time_slot.dart';
import 'package:intl/intl.dart'; // For date formatting

class TimeSlotRepository {
  final TimeSlotProvider _provider;

  TimeSlotRepository({required TimeSlotProvider provider})
    : _provider = provider;

  /// Helper to format DateTime to "YYYY-MM-DDTHH:mm:ss.SSS" (local time string)
  String _formatDateTimeToLocalApiString(DateTime dateTime) {
    return DateFormat("yyyy-MM-ddTHH:mm:ss.SSS").format(dateTime);
  }

  /// Create a new time slot
  Future<TimeSlot> createTimeSlot({
    required String operatingScheduleId,
    required DateTime startTime, // Expecting local DateTime from Controller
    required DateTime endTime, // Expecting local DateTime from Controller
  }) async {
    try {
      if (startTime.isAfter(endTime)) {
        throw ApiException(message: 'Waktu mulai harus sebelum waktu selesai');
      }
      // The provider should convert startTime and endTime (local DateTime)
      // to the specific string format the backend API expects.
      // For example, if "YYYY-MM-DDTHH:mm:ss.SSS" is needed:
      // final String startTimeString = _formatDateTimeToLocalApiString(startTime);
      // final String endTimeString = _formatDateTimeToLocalApiString(endTime);
      // Then pass these strings to the provider.
      // Here, we pass DateTime objects, assuming provider handles it.
      final data = await _provider.createTimeSlot(
        operatingScheduleId: operatingScheduleId,
        startTime: startTime, // Pass DateTime; provider formats if needed
        endTime: endTime, // Pass DateTime; provider formats if needed
      );
      return TimeSlot.fromJson(data);
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException(
        message: 'Gagal membuat jadwal baru. Silakan coba lagi nanti.',
      );
    }
  }

  /// Create multiple time slots at once
  Future<List<TimeSlot>> createMultipleTimeSlots({
    required String operatingScheduleId,
    required List<Map<String, dynamic>>
    timeSlots, // Expects 'startTime'/'endTime' as DateTime objects
  }) async {
    try {
      final List<Map<String, dynamic>> processedTimeSlots = [];
      for (final slotData in timeSlots) {
        if (!slotData.containsKey('startTime') ||
            slotData['startTime'] is! DateTime ||
            !slotData.containsKey('endTime') ||
            slotData['endTime'] is! DateTime) {
          throw ApiException(
            message:
                'Setiap time slot harus memiliki startTime dan endTime sebagai objek DateTime.',
          );
        }
        final DateTime slotStartTime = slotData['startTime'] as DateTime;
        final DateTime slotEndTime = slotData['endTime'] as DateTime;

        if (slotStartTime.isAfter(slotEndTime)) {
          throw ApiException(
            message:
                'Dalam batch: Waktu mulai harus sebelum waktu selesai untuk semua slot.',
          );
        }

        processedTimeSlots.add({
          'startTime': _formatDateTimeToLocalApiString(slotStartTime),
          'endTime': _formatDateTimeToLocalApiString(slotEndTime),
          // Include other properties from slotData if necessary
          ...slotData
            ..remove('startTime')
            ..remove('endTime'),
        });
      }

      final List<dynamic> timeSlotsJson = await _provider
          .createMultipleTimeSlots(
            operatingScheduleId: operatingScheduleId,
            timeSlots:
                processedTimeSlots, // List of maps with formatted date strings
          );
      return timeSlotsJson.map((json) => TimeSlot.fromJson(json)).toList();
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException(
        message: 'Gagal membuat beberapa jadwal baru. Silakan coba lagi nanti.',
      );
    }
  }

  /// Get all time slots with optional filtering
  Future<List<TimeSlot>> getAllTimeSlots({
    String? operatingScheduleId,
    String? date, // Expected "YYYY-MM-DD"
    String? startTime, // Filter criteria, format depends on backend API
    String? endTime,
  }) async {
    try {
      final List<dynamic> timeSlotsJson = await _provider.getAllTimeSlots(
        operatingScheduleId: operatingScheduleId,
        date: date,
        startTime: startTime,
        endTime: endTime,
      );
      return timeSlotsJson.map((json) => TimeSlot.fromJson(json)).toList();
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException(
        message: 'Gagal mengambil data jadwal. Silakan coba lagi nanti.',
      );
    }
  }

  /// Get time slot by ID
  Future<TimeSlot> getTimeSlotById(String id) async {
    try {
      final data = await _provider.getTimeSlotById(id);
      return TimeSlot.fromJson(data);
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException(
        message: 'Gagal mengambil detail jadwal. Silakan coba lagi nanti.',
      );
    }
  }

  /// Get time slots by operating schedule ID
  Future<List<TimeSlot>> getTimeSlotsByScheduleId(String scheduleId) async {
    try {
      final List<dynamic> timeSlotsJson = await _provider
          .getTimeSlotsByScheduleId(scheduleId);
      return timeSlotsJson.map((json) => TimeSlot.fromJson(json)).toList();
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException(
        message:
            'Gagal mengambil data jadwal berdasarkan ID jadwal operasi. Silakan coba lagi nanti.',
      );
    }
  }

  /// Get available time slots by date
  Future<List<TimeSlot>> getAvailableTimeSlots(String date) async {
    // date "YYYY-MM-DD"
    try {
      // Basic validation, more robust validation can be added
      DateTime.parse(date);
    } catch (e) {
      throw ApiException(
        message: 'Format tanggal tidak valid. Gunakan format YYYY-MM-DD.',
      );
    }
    try {
      final List<dynamic> timeSlotsJson = await _provider.getAvailableTimeSlots(
        date,
      );
      return timeSlotsJson.map((json) => TimeSlot.fromJson(json)).toList();
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException(
        message: 'Gagal mengambil jadwal tersedia. Silakan coba lagi nanti.',
      );
    }
  }

  /// Update time slot
  Future<TimeSlot> updateTimeSlot({
    required String id,
    String? operatingScheduleId,
    DateTime? startTime, // Expecting local DateTime from Controller
    DateTime? endTime, // Expecting local DateTime from Controller
  }) async {
    try {
      if (startTime != null && endTime != null) {
        if (startTime.isAfter(endTime)) {
          throw ApiException(
            message:
                'Waktu mulai harus sebelum waktu selesai saat memperbarui.',
          );
        }
      }
      // Similar to createTimeSlot, provider handles DateTime to String conversion for API.
      final data = await _provider.updateTimeSlot(
        id: id,
        operatingScheduleId: operatingScheduleId,
        startTime: startTime, // Pass DateTime; provider formats if needed
        endTime: endTime, // Pass DateTime; provider formats if needed
      );
      return TimeSlot.fromJson(data);
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException(
        message: 'Gagal memperbarui jadwal. Silakan coba lagi nanti.',
      );
    }
  }

  /// Delete time slot
  Future<bool> deleteTimeSlot(String id) async {
    try {
      final result = await _provider.deleteTimeSlot(id);
      return result != null; // Assuming provider returns non-null on success
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException(
        message: 'Gagal menghapus jadwal. Silakan coba lagi nanti.',
      );
    }
  }
}
