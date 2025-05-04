// lib/data/providers/time_slot_provider.dart

import 'package:get/get.dart';
import 'package:emababyspa/data/api/api_client.dart';
import 'package:emababyspa/data/api/api_endpoints.dart';

class TimeSlotProvider {
  final ApiClient _apiClient = Get.find<ApiClient>();

  /// Create a new time slot
  Future<dynamic> createTimeSlot({
    required String operatingScheduleId,
    required DateTime startTime,
    required DateTime endTime,
  }) async {
    try {
      Map<String, dynamic> data = {
        'operatingScheduleId': operatingScheduleId,
        'startTime': startTime.toIso8601String(),
        'endTime': endTime.toIso8601String(),
      };

      return await _apiClient.postValidated(ApiEndpoints.timeSlots, data: data);
    } catch (e) {
      rethrow;
    }
  }

  /// Create multiple time slots at once
  Future<dynamic> createMultipleTimeSlots({
    required String operatingScheduleId,
    required List<Map<String, dynamic>> timeSlots,
  }) async {
    try {
      Map<String, dynamic> data = {
        'operatingScheduleId': operatingScheduleId,
        'timeSlots': timeSlots,
      };

      return await _apiClient.postValidated(
        '${ApiEndpoints.timeSlots}/bulk',
        data: data,
      );
    } catch (e) {
      rethrow;
    }
  }

  /// Get all time slots with optional filtering
  Future<dynamic> getAllTimeSlots({
    String? operatingScheduleId,
    String? date,
    String? startTime,
    String? endTime,
  }) async {
    try {
      Map<String, dynamic> queryParameters = {};

      if (operatingScheduleId != null) {
        queryParameters['operatingScheduleId'] = operatingScheduleId;
      }

      if (date != null) {
        queryParameters['date'] = date;
      }

      if (startTime != null) {
        queryParameters['startTime'] = startTime;
      }

      if (endTime != null) {
        queryParameters['endTime'] = endTime;
      }

      return await _apiClient.getValidated(
        ApiEndpoints.timeSlots,
        queryParameters: queryParameters,
      );
    } catch (e) {
      rethrow;
    }
  }

  /// Get time slot by ID
  Future<dynamic> getTimeSlotById(String id) async {
    try {
      return await _apiClient.getValidated('${ApiEndpoints.timeSlots}/$id');
    } catch (e) {
      rethrow;
    }
  }

  /// Get time slots by operating schedule ID
  Future<dynamic> getTimeSlotsByScheduleId(String scheduleId) async {
    try {
      return await _apiClient.getValidated(
        '${ApiEndpoints.timeSlots}/schedule/$scheduleId',
      );
    } catch (e) {
      rethrow;
    }
  }

  /// Get available time slots by date
  Future<dynamic> getAvailableTimeSlots(String date) async {
    try {
      return await _apiClient.getValidated(
        '${ApiEndpoints.timeSlots}/available/$date',
      );
    } catch (e) {
      rethrow;
    }
  }

  /// Update time slot
  Future<dynamic> updateTimeSlot({
    required String id,
    String? operatingScheduleId,
    DateTime? startTime,
    DateTime? endTime,
  }) async {
    try {
      Map<String, dynamic> data = {};

      if (operatingScheduleId != null) {
        data['operatingScheduleId'] = operatingScheduleId;
      }

      if (startTime != null) {
        data['startTime'] = startTime.toIso8601String();
      }

      if (endTime != null) {
        data['endTime'] = endTime.toIso8601String();
      }

      return await _apiClient.putValidated(
        '${ApiEndpoints.timeSlots}/$id',
        data: data,
      );
    } catch (e) {
      rethrow;
    }
  }

  /// Delete time slot
  Future<dynamic> deleteTimeSlot(String id) async {
    try {
      return await _apiClient.deleteValidated('${ApiEndpoints.timeSlots}/$id');
    } catch (e) {
      rethrow;
    }
  }
}
