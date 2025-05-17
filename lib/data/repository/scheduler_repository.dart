// lib/data/repository/scheduler_repository.dart
import 'package:emababyspa/data/api/api_exception.dart';
import 'package:emababyspa/data/models/scheduler.dart';
import 'package:emababyspa/data/providers/scheduler_provider.dart';
import 'package:dio/dio.dart';

class SchedulerRepository {
  final SchedulerProvider _provider;

  SchedulerRepository({required SchedulerProvider provider})
    : _provider = provider;

  /// Generate full schedule (operating schedules, time slots, and sessions)
  Future<ScheduleGenerationResult> generateSchedule({
    String? startDate,
    int? days,
    List<String>? holidayDates,
    TimeConfig? timeConfig,
    int? timeZoneOffset,
  }) async {
    try {
      return await _provider.generateSchedule(
        startDate: startDate,
        days: days,
        holidayDates: holidayDates,
        timeConfig: timeConfig,
        timeZoneOffset: timeZoneOffset,
      );
    } on DioException catch (e) {
      throw ApiException(
        message: e.error?.toString() ?? 'Failed to generate schedule',
      );
    } catch (e) {
      throw ApiException(
        message:
            'Gagal membuat jadwal operasional dan sesi. Silakan coba lagi nanti.',
      );
    }
  }

  /// Generate specific schedule components (operating schedules, time slots, or sessions)
  Future<ComponentGenerationResult> generateOperatingSchedules({
    String? startDate,
    int? days,
    List<String>? holidayDates,
  }) async {
    try {
      return await _provider.generateScheduleComponents(
        component: 'operatingSchedules',
        startDate: startDate,
        days: days,
        holidayDates: holidayDates,
      );
    } on DioException catch (e) {
      throw ApiException(
        message:
            e.error?.toString() ?? 'Failed to generate operating schedules',
      );
    } catch (e) {
      throw ApiException(
        message: 'Gagal membuat jadwal operasional. Silakan coba lagi nanti.',
      );
    }
  }

  /// Generate time slots for specific operating schedules
  Future<ComponentGenerationResult> generateTimeSlots({
    required List<String> scheduleIds,
    TimeConfig? timeConfig,
    int? timeZoneOffset,
  }) async {
    try {
      return await _provider.generateScheduleComponents(
        component: 'timeSlots',
        scheduleIds: scheduleIds,
        timeConfig: timeConfig,
        timeZoneOffset: timeZoneOffset,
      );
    } on DioException catch (e) {
      throw ApiException(
        message: e.error?.toString() ?? 'Failed to generate time slots',
      );
    } catch (e) {
      throw ApiException(
        message:
            'Gagal membuat slot waktu untuk jadwal operasional. Silakan coba lagi nanti.',
      );
    }
  }

  /// Generate sessions for specified time slots
  Future<ComponentGenerationResult> generateSessions({
    required Map<String, List<String>> timeSlotsBySchedule,
  }) async {
    try {
      return await _provider.generateScheduleComponents(
        component: 'sessions',
        timeSlotsBySchedule: timeSlotsBySchedule,
      );
    } on DioException catch (e) {
      throw ApiException(
        message: e.error?.toString() ?? 'Failed to generate sessions',
      );
    } catch (e) {
      throw ApiException(
        message:
            'Gagal membuat sesi untuk slot waktu. Silakan coba lagi nanti.',
      );
    }
  }

  /// Run scheduled generation manually
  Future<ScheduleGenerationResult> runScheduledGeneration() async {
    try {
      return await _provider.runScheduledGeneration();
    } on DioException catch (e) {
      throw ApiException(
        message: e.error?.toString() ?? 'Failed to run scheduled generation',
      );
    } catch (e) {
      throw ApiException(
        message:
            'Gagal menjalankan pembuatan jadwal terjadwal. Silakan coba lagi nanti.',
      );
    }
  }

  /// Generate full schedule with custom configuration
  Future<ScheduleGenerationResult> generateCustomSchedule({
    required String startDate,
    required int days,
    required List<String> holidayDates,
    required TimeConfig timeConfig,
    int? timeZoneOffset,
  }) async {
    try {
      return await _provider.generateSchedule(
        startDate: startDate,
        days: days,
        holidayDates: holidayDates,
        timeConfig: timeConfig,
        timeZoneOffset: timeZoneOffset,
      );
    } on DioException catch (e) {
      throw ApiException(
        message: e.error?.toString() ?? 'Failed to generate custom schedule',
      );
    } catch (e) {
      throw ApiException(
        message: 'Gagal membuat jadwal kustom. Silakan coba lagi nanti.',
      );
    }
  }

  /// Generate full schedule for next day
  Future<ScheduleGenerationResult> generateNextDaySchedule() async {
    try {
      // Using default configuration but only for 1 day (next day)
      return await _provider.generateSchedule(days: 1);
    } on DioException catch (e) {
      throw ApiException(
        message:
            e.error?.toString() ?? 'Failed to generate schedule for next day',
      );
    } catch (e) {
      throw ApiException(
        message:
            'Gagal membuat jadwal untuk hari berikutnya. Silakan coba lagi nanti.',
      );
    }
  }

  /// Generate full schedule for next week
  Future<ScheduleGenerationResult> generateNextWeekSchedule() async {
    try {
      // Using default configuration for 7 days
      return await _provider.generateSchedule(days: 7);
    } on DioException catch (e) {
      throw ApiException(
        message:
            e.error?.toString() ?? 'Failed to generate schedule for next week',
      );
    } catch (e) {
      throw ApiException(
        message:
            'Gagal membuat jadwal untuk minggu berikutnya. Silakan coba lagi nanti.',
      );
    }
  }
}
