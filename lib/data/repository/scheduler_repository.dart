import 'package:emababyspa/data/api/api_exception.dart';
import 'package:emababyspa/data/providers/scheduler_provider.dart';
import 'package:emababyspa/common/constants/app_constants.dart';
import 'package:dio/dio.dart';

class SchedulerRepository {
  final SchedulerProvider _provider;

  SchedulerRepository({required SchedulerProvider provider})
    : _provider = provider;

  Future<Map<String, dynamic>> generateSchedule({
    String? startDate,
    int? days,
    List<String>? holidayDates,
    Map<String, dynamic>? timeConfig,
    int? timeZoneOffset,
  }) async {
    try {
      final data = await _provider.generateSchedule(
        startDate: startDate,
        days: days,
        holidayDates: holidayDates,
        timeConfig: timeConfig,
        timeZoneOffset: timeZoneOffset,
      );

      return data;
    } on DioException catch (e) {
      throw ApiException(
        message: e.error?.toString() ?? 'Failed to generate schedule',
      );
    } catch (e) {
      throw ApiException(
        message: 'Gagal membuat jadwal. Silakan coba lagi nanti.',
      );
    }
  }

  /// Generate specific schedule components (operating schedules, time slots, or sessions)
  Future<Map<String, dynamic>> generateScheduleComponents({
    required String component,
    List<String>? scheduleIds,
    String? startDate,
    int? days,
    List<String>? holidayDates,
    Map<String, dynamic>? timeConfig,
    int? timeZoneOffset,
    Map<String, List<dynamic>>? timeSlotsBySchedule,
  }) async {
    try {
      final data = await _provider.generateScheduleComponents(
        component: component,
        scheduleIds: scheduleIds,
        startDate: startDate,
        days: days,
        holidayDates: holidayDates,
        timeConfig: timeConfig,
        timeZoneOffset: timeZoneOffset,
        timeSlotsBySchedule: timeSlotsBySchedule,
      );

      return data;
    } on DioException catch (e) {
      throw ApiException(
        message:
            e.error?.toString() ?? 'Failed to generate schedule components',
      );
    } catch (e) {
      throw ApiException(
        message: 'Gagal membuat komponen jadwal. Silakan coba lagi nanti.',
      );
    }
  }

  /// Trigger a scheduled generation (usually called by a cron job)
  Future<Map<String, dynamic>> runScheduledGeneration({String? secret}) async {
    try {
      // Use secret from app constants if not provided
      final schedulerSecret = secret ?? AppConstants.schedulerSecret;
      final data = await _provider.runScheduledGeneration(
        secret: schedulerSecret,
      );
      return data;
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
}
