// lib/data/repository/operating_schedule_repository.dart

import 'package:emababyspa/data/models/operating_schedule.dart';
import 'package:emababyspa/data/providers/operating_schedule_provider.dart';
import 'package:emababyspa/data/api/api_exception.dart';
import 'package:dio/dio.dart';

class OperatingScheduleRepository {
  final OperatingScheduleProvider _provider;

  OperatingScheduleRepository({required OperatingScheduleProvider provider})
    : _provider = provider;

  Future<List<OperatingSchedule>> getAllOperatingSchedules({
    String? date,
    bool? isHoliday,
    String? startDate,
    String? endDate,
  }) async {
    try {
      final response = await _provider.getAllOperatingSchedules(
        date: date,
        isHoliday: isHoliday,
        startDate: startDate,
        endDate: endDate,
      );

      // Convert each item in the response list to OperatingSchedule
      return response.map((item) => OperatingSchedule.fromJson(item)).toList();
    } on DioException catch (e) {
      throw ApiException(
        message:
            e.message ??
            'Gagal mengambil data jadwal operasional. Silakan coba lagi nanti.',
        code: e.response?.statusCode,
      );
    } catch (e) {
      if (e is ApiException) {
        rethrow;
      }
      throw ApiException(
        message:
            'Gagal mengambil data jadwal operasional. Silakan coba lagi nanti.',
      );
    }
  }

  Future<OperatingSchedule> createOperatingSchedule({
    required String date,
    bool? isHoliday,
    String? notes,
  }) async {
    try {
      final response = await _provider.createOperatingSchedule(
        date: date,
        isHoliday: isHoliday,
        notes: notes,
      );

      return OperatingSchedule.fromJson(response);
    } on DioException catch (e) {
      throw ApiException(
        message:
            e.message ??
            'Gagal membuat jadwal operasional. Silakan coba lagi nanti.',
        code: e.response?.statusCode,
      );
    } catch (e) {
      if (e is ApiException) {
        rethrow;
      }
      throw ApiException(
        message: 'Gagal membuat jadwal operasional. Silakan coba lagi nanti.',
      );
    }
  }

  Future<OperatingSchedule> updateOperatingSchedule({
    required String id,
    String? date,
    bool? isHoliday,
    String? notes,
  }) async {
    try {
      final response = await _provider.updateOperatingSchedule(
        id: id,
        date: date,
        isHoliday: isHoliday,
        notes: notes,
      );

      return OperatingSchedule.fromJson(response);
    } on DioException catch (e) {
      throw ApiException(
        message:
            e.message ??
            'Gagal memperbarui jadwal operasional. Silakan coba lagi nanti.',
        code: e.response?.statusCode,
      );
    } catch (e) {
      if (e is ApiException) {
        rethrow;
      }
      throw ApiException(
        message:
            'Gagal memperbarui jadwal operasional. Silakan coba lagi nanti.',
      );
    }
  }

  Future<OperatingSchedule> getOperatingScheduleById(String id) async {
    try {
      final response = await _provider.getOperatingScheduleById(id);

      return OperatingSchedule.fromJson(response);
    } on DioException catch (e) {
      throw ApiException(
        message:
            e.message ??
            'Jadwal operasional dengan ID tersebut tidak ditemukan.',
        code: e.response?.statusCode,
      );
    } catch (e) {
      if (e is ApiException) {
        rethrow;
      }
      throw ApiException(
        message: 'Gagal mengambil jadwal operasional. Silakan coba lagi nanti.',
      );
    }
  }

  Future<OperatingSchedule> getOperatingScheduleByDate(String date) async {
    try {
      final response = await _provider.getOperatingScheduleByDate(date);

      return OperatingSchedule.fromJson(response);
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        throw ApiException(
          message: 'Jadwal operasional untuk tanggal tersebut tidak ditemukan.',
          code: 404,
        );
      }
      throw ApiException(
        message:
            e.message ??
            'Gagal mengambil jadwal operasional. Silakan coba lagi nanti.',
        code: e.response?.statusCode,
      );
    } catch (e) {
      if (e is ApiException) {
        rethrow;
      }
      throw ApiException(
        message: 'Gagal mengambil jadwal operasional. Silakan coba lagi nanti.',
      );
    }
  }

  Future<bool> deleteOperatingSchedule(String id) async {
    try {
      final result = await _provider.deleteOperatingSchedule(id);
      return result;
    } on DioException catch (e) {
      throw ApiException(
        message:
            e.message ??
            'Gagal menghapus jadwal operasional. Silakan coba lagi nanti.',
        code: e.response?.statusCode,
      );
    } catch (e) {
      if (e is ApiException) {
        rethrow;
      }
      throw ApiException(
        message: 'Gagal menghapus jadwal operasional. Silakan coba lagi nanti.',
      );
    }
  }

  Future<OperatingSchedule> toggleHolidayStatus(
    String id,
    bool isHoliday,
  ) async {
    try {
      final response = await _provider.toggleHolidayStatus(id, isHoliday);

      return OperatingSchedule.fromJson(response);
    } on DioException catch (e) {
      throw ApiException(
        message:
            e.message ??
            'Gagal mengubah status hari libur. Silakan coba lagi nanti.',
        code: e.response?.statusCode,
      );
    } catch (e) {
      if (e is ApiException) {
        rethrow;
      }
      throw ApiException(
        message: 'Gagal mengubah status hari libur. Silakan coba lagi nanti.',
      );
    }
  }
}
