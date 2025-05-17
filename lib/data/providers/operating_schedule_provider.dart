// lib/data/providers/operating_schedule_provider.dart

import 'package:get/get.dart' hide Response;
import 'package:emababyspa/data/api/api_client.dart';
import 'package:emababyspa/data/api/api_endpoints.dart';
import 'package:emababyspa/data/api/api_exception.dart';

class OperatingScheduleProvider {
  final ApiClient _apiClient = Get.find<ApiClient>();

  /// Helper method to extract data from API response
  dynamic _extractData(dynamic response) {
    if (response is Map<String, dynamic> && response.containsKey('data')) {
      return response['data'];
    }
    return response;
  }

  Future<dynamic> createOperatingSchedule({
    required String date,
    bool? isHoliday,
    String? notes,
  }) async {
    try {
      // Ensure date is in ISO format (YYYY-MM-DD)
      final formattedDate =
          DateTime.parse(date).toIso8601String().split('T')[0];

      Map<String, dynamic> data = {'date': formattedDate};

      if (isHoliday != null) {
        data['isHoliday'] = isHoliday;
      }

      if (notes != null) {
        data['notes'] = notes;
      }

      final response = await _apiClient.postValidated(
        ApiEndpoints.operatingSchedules,
        data: data,
      );

      return _extractData(response);
    } catch (e) {
      rethrow;
    }
  }

  Future<List<dynamic>> getAllOperatingSchedules({
    String? date,
    bool? isHoliday,
    String? startDate,
    String? endDate,
  }) async {
    try {
      Map<String, dynamic> queryParameters = {};

      if (date != null) {
        // Format date to YYYY-MM-DD
        queryParameters['date'] =
            DateTime.parse(date).toIso8601String().split('T')[0];
      }

      if (isHoliday != null) {
        queryParameters['isHoliday'] = isHoliday.toString();
      }

      if (startDate != null) {
        queryParameters['startDate'] =
            DateTime.parse(startDate).toIso8601String().split('T')[0];
      }

      if (endDate != null) {
        queryParameters['endDate'] =
            DateTime.parse(endDate).toIso8601String().split('T')[0];
      }

      final response = await _apiClient.getValidated(
        ApiEndpoints.operatingSchedules,
        queryParameters: queryParameters,
      );

      // Check for the response structure
      if (response is Map<String, dynamic>) {
        // Check if it has data field and if it's a list
        if (response.containsKey('data') && response['data'] is List) {
          return response['data'] as List<dynamic>;
        }
        // If it has success field but unexpected structure
        else if (response.containsKey('success')) {
          throw ApiException(
            message: 'Response format does not contain valid data array',
          );
        }
        // If the response is itself a list item
        else if (response.containsKey('id')) {
          return [response];
        }
      } else if (response is List) {
        // If response is already a list
        return response;
      }

      throw ApiException(message: 'Unexpected response format from server');
    } catch (e) {
      rethrow;
    }
  }

  Future<dynamic> getOperatingScheduleById(String id) async {
    try {
      final response = await _apiClient.getValidated(
        ApiEndpoints.operatingScheduleDetail,
        pathParams: {'id': id},
      );

      return _extractData(response);
    } catch (e) {
      rethrow;
    }
  }

  Future<dynamic> getOperatingScheduleByDate(String date) async {
    try {
      // Format date to YYYY-MM-DD if it's a DateTime object
      String formattedDate = date;
      try {
        formattedDate = DateTime.parse(date).toIso8601String().split('T')[0];
      } catch (_) {}

      final response = await _apiClient.getValidated(
        ApiEndpoints.operatingScheduleByDate,
        pathParams: {'date': formattedDate},
      );

      return _extractData(response);
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

      if (date != null) {
        // Format date to YYYY-MM-DD
        data['date'] = DateTime.parse(date).toIso8601String().split('T')[0];
      }

      if (isHoliday != null) data['isHoliday'] = isHoliday;
      if (notes != null) data['notes'] = notes;

      final response = await _apiClient.putValidated(
        ApiEndpoints.operatingScheduleDetail,
        data: data,
        pathParams: {'id': id},
      );

      return _extractData(response);
    } catch (e) {
      rethrow;
    }
  }

  Future<bool> deleteOperatingSchedule(String id) async {
    try {
      final response = await _apiClient.deleteValidated(
        ApiEndpoints.operatingScheduleDetail,
        pathParams: {'id': id},
      );

      // Check for success field in response
      if (response is Map<String, dynamic> && response.containsKey('success')) {
        return response['success'] == true;
      }

      return true; // Assume success if no specific indicator
    } catch (e) {
      rethrow;
    }
  }

  Future<dynamic> toggleHolidayStatus(String id, bool isHoliday) async {
    try {
      final response = await _apiClient.patchValidated(
        '${ApiEndpoints.operatingSchedules}/$id/toggle-holiday',
        data: {'isHoliday': isHoliday},
      );

      return _extractData(response);
    } catch (e) {
      rethrow;
    }
  }
}
