// lib/data/repository/time_slot_repository.dart
import 'package:emababyspa/data/api/api_exception.dart';
import 'package:emababyspa/data/providers/time_slot_provider.dart';
import 'package:emababyspa/data/models/time_slot.dart';

class TimeSlotRepository {
  final TimeSlotProvider _provider;

  TimeSlotRepository({required TimeSlotProvider provider})
    : _provider = provider;

  /// Create a new time slot
  Future<TimeSlot> createTimeSlot({
    required String operatingScheduleId,
    required DateTime startTime,
    required DateTime endTime,
  }) async {
    try {
      // Validate inputs
      if (startTime.isAfter(endTime)) {
        throw ApiException(message: 'Waktu mulai harus sebelum waktu selesai');
      }

      final data = await _provider.createTimeSlot(
        operatingScheduleId: operatingScheduleId,
        startTime: startTime,
        endTime: endTime,
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
    required List<Map<String, dynamic>> timeSlots,
  }) async {
    try {
      // Validate time slot format
      for (var slot in timeSlots) {
        if (!slot.containsKey('startTime') || !slot.containsKey('endTime')) {
          throw ApiException(
            message: 'Setiap time slot harus memiliki startTime dan endTime',
          );
        }
      }

      final List<dynamic> timeSlotsJson = await _provider
          .createMultipleTimeSlots(
            operatingScheduleId: operatingScheduleId,
            timeSlots: timeSlots,
          );

      return timeSlotsJson.map((json) => TimeSlot.fromJson(json)).toList();
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException(
        message: 'Gagal membuat jadwal baru. Silakan coba lagi nanti.',
      );
    }
  }

  /// Get all time slots with optional filtering
  Future<List<TimeSlot>> getAllTimeSlots({
    String? operatingScheduleId,
    String? date,
    String? startTime,
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
        message: 'Gagal mengambil data jadwal. Silakan coba lagi nanti.',
      );
    }
  }

  /// Get available time slots by date
  Future<List<TimeSlot>> getAvailableTimeSlots(String date) async {
    try {
      // Validate date format
      try {
        DateTime.parse(date);
      } catch (e) {
        throw ApiException(
          message: 'Format tanggal tidak valid. Gunakan format YYYY-MM-DD',
        );
      }

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
    DateTime? startTime,
    DateTime? endTime,
  }) async {
    try {
      // Validate times if both are provided
      if (startTime != null && endTime != null) {
        if (startTime.isAfter(endTime)) {
          throw ApiException(
            message: 'Waktu mulai harus sebelum waktu selesai',
          );
        }
      }

      final data = await _provider.updateTimeSlot(
        id: id,
        operatingScheduleId: operatingScheduleId,
        startTime: startTime,
        endTime: endTime,
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
      return result !=
          null; // If we got a non-null result, deletion was successful
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException(
        message: 'Gagal menghapus jadwal. Silakan coba lagi nanti.',
      );
    }
  }
}
