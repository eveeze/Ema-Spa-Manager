// lib/data/repository/operating_schedule_repository.dart
import 'package:emababyspa/data/api/api_exception.dart';
import 'package:emababyspa/data/models/operating_schedule.dart';
import 'package:emababyspa/data/providers/operating_schedule_provider.dart';
import 'package:dio/dio.dart';

class OperatingScheduleRepository {
  final OperatingScheduleProvider _provider;

  OperatingScheduleRepository({required OperatingScheduleProvider provider})
    : _provider = provider;

  /// Create a new operating schedule
  Future<OperatingSchedule> createOperatingSchedule({
    required String date,
    bool? isHoliday,
    String? notes,
  }) async {
    try {
      final data = await _provider.createOperatingSchedule(
        date: date,
        isHoliday: isHoliday,
        notes: notes,
      );

      return OperatingSchedule.fromJson(data);
    } on DioException catch (e) {
      throw ApiException(
        message: e.error?.toString() ?? 'Failed to create operating schedule',
      );
    } catch (e) {
      throw ApiException(
        message:
            'Gagal membuat jadwal operasional baru. Silakan coba lagi nanti.',
      );
    }
  }

  /// Get all operating schedules with optional filtering
  Future<List<OperatingSchedule>> getAllOperatingSchedules({
    String? date,
    bool? isHoliday,
    String? startDate,
    String? endDate,
  }) async {
    try {
      final List<dynamic> schedulesJson = await _provider
          .getAllOperatingSchedules(
            date: date,
            isHoliday: isHoliday,
            startDate: startDate,
            endDate: endDate,
          );

      return schedulesJson
          .map((json) => OperatingSchedule.fromJson(json))
          .toList();
    } on DioException catch (e) {
      throw ApiException(
        message:
            e.error?.toString() ?? 'Failed to retrieve operating schedules',
      );
    } catch (e) {
      throw ApiException(
        message:
            'Gagal mengambil data jadwal operasional. Silakan coba lagi nanti.',
      );
    }
  }

  /// Get operating schedule details by ID
  Future<OperatingSchedule> getOperatingScheduleById(String id) async {
    try {
      final data = await _provider.getOperatingScheduleById(id);
      return OperatingSchedule.fromJson(data);
    } on DioException catch (e) {
      throw ApiException(
        message: e.error?.toString() ?? 'Operating schedule not found',
      );
    } catch (e) {
      throw ApiException(
        message:
            'Gagal mengambil detail jadwal operasional. Silakan coba lagi nanti.',
      );
    }
  }

  /// Get operating schedule by date
  Future<OperatingSchedule> getOperatingScheduleByDate(String date) async {
    try {
      final data = await _provider.getOperatingScheduleByDate(date);
      return OperatingSchedule.fromJson(data);
    } on DioException catch (e) {
      throw ApiException(
        message: e.error?.toString() ?? 'Operating schedule not found for date',
      );
    } catch (e) {
      throw ApiException(
        message:
            'Gagal mengambil jadwal operasional untuk tanggal tersebut. Silakan coba lagi nanti.',
      );
    }
  }

  /// Update an existing operating schedule
  Future<OperatingSchedule> updateOperatingSchedule({
    required String id,
    String? date,
    bool? isHoliday,
    String? notes,
  }) async {
    try {
      final data = await _provider.updateOperatingSchedule(
        id: id,
        date: date,
        isHoliday: isHoliday,
        notes: notes,
      );

      return OperatingSchedule.fromJson(data);
    } on DioException catch (e) {
      throw ApiException(
        message: e.error?.toString() ?? 'Failed to update operating schedule',
      );
    } catch (e) {
      throw ApiException(
        message:
            'Gagal memperbarui jadwal operasional. Silakan coba lagi nanti.',
      );
    }
  }

  /// Delete an operating schedule
  Future<bool> deleteOperatingSchedule(String id) async {
    try {
      await _provider.deleteOperatingSchedule(id);
      return true;
    } on DioException catch (e) {
      throw ApiException(
        message: e.error?.toString() ?? 'Failed to delete operating schedule',
      );
    } catch (e) {
      throw ApiException(
        message: 'Gagal menghapus jadwal operasional. Silakan coba lagi nanti.',
      );
    }
  }

  /// Toggle holiday status for an operating schedule
  Future<OperatingSchedule> toggleHolidayStatus(
    String id,
    bool isHoliday,
  ) async {
    try {
      final data = await _provider.toggleHolidayStatus(id, isHoliday);
      return OperatingSchedule.fromJson(data);
    } on DioException catch (e) {
      throw ApiException(
        message:
            e.error?.toString() ??
            'Failed to update operating schedule holiday status',
      );
    } catch (e) {
      throw ApiException(
        message:
            'Gagal mengubah status hari libur jadwal operasional. Silakan coba lagi nanti.',
      );
    }
  }
}
