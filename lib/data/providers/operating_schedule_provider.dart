// lib/data/providers/operating_schedule_provider.dart

import 'package:get/get.dart' hide Response;
import 'package:emababyspa/data/api/api_client.dart';
import 'package:emababyspa/data/api/api_endpoints.dart';

class OperatingScheduleProvider {
  final ApiClient _apiClient = Get.find<ApiClient>();

  Future<dynamic> createOperatingSchedule({
    required String date,
    bool? isHoliday,
    String? notes,
  }) async {
    try {
      Map<String, dynamic> data = {'date': date};

      if (isHoliday != null) {
        data['isHoliday'] = isHoliday;
      }

      if (notes != null) {
        data['notes'] = notes;
      }

      return await _apiClient.postValidated(
        ApiEndpoints.operatingSchedules,
        data: data,
      );
    } catch (e) {
      rethrow;
    }
  }

  Future<dynamic> getAllOperatingSchedules({
    String? date,
    bool? isHoliday,
    String? startDate,
    String? endDate,
  }) async {
    try {
      Map<String, dynamic> queryParameters = {};

      if (date != null) {
        queryParameters['date'] = date;
      }

      if (isHoliday != null) {
        queryParameters['isHoliday'] = isHoliday.toString();
      }

      if (startDate != null) {
        queryParameters['startDate'] = startDate;
      }

      if (endDate != null) {
        queryParameters['endDate'] = endDate;
      }

      return await _apiClient.getValidated(
        ApiEndpoints.operatingSchedules,
        queryParameters: queryParameters,
      );
    } catch (e) {
      rethrow;
    }
  }

  Future<dynamic> getOperatingScheduleById(String id) async {
    try {
      return await _apiClient.getValidated(
        ApiEndpoints.operatingScheduleDetail,
        pathParams: {'id': id},
      );
    } catch (e) {
      rethrow;
    }
  }

  Future<dynamic> getOperatingScheduleByDate(String date) async {
    try {
      return await _apiClient.getValidated(
        ApiEndpoints.operatingScheduleByDate,
        pathParams: {'date': date},
      );
    } catch (e) {
      rethrow;
    }
  }

  Future<dynamic> updateOperatingSchedule({
    required String id,
    String? date,
    bool? isHoliday,
    String? notes,
  }) async {
    try {
      Map<String, dynamic> data = {};

      if (date != null) data['date'] = date;
      if (isHoliday != null) data['isHoliday'] = isHoliday;
      if (notes != null) data['notes'] = notes;

      return await _apiClient.putValidated(
        ApiEndpoints.operatingScheduleDetail,
        data: data,
        pathParams: {'id': id},
      );
    } catch (e) {
      rethrow;
    }
  }

  Future<dynamic> deleteOperatingSchedule(String id) async {
    try {
      return await _apiClient.deleteValidated(
        ApiEndpoints.operatingScheduleDetail,
        pathParams: {'id': id},
      );
    } catch (e) {
      rethrow;
    }
  }

  Future<dynamic> toggleHolidayStatus(String id, bool isHoliday) async {
    try {
      return await _apiClient.patchValidated(
        '${ApiEndpoints.operatingSchedules}/$id/toggle-holiday',
        data: {'isHoliday': isHoliday},
      );
    } catch (e) {
      rethrow;
    }
  }
}
