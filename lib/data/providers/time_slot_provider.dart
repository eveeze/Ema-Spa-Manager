// lib/data/providers/time_slot_provider.dart

import 'package:get/get.dart';
import 'package:emababyspa/data/api/api_client.dart';
import 'package:emababyspa/data/api/api_endpoints.dart';

class TimeSlotProvider {
  final ApiClient _apiClient = Get.find<ApiClient>();

  /// Format DateTime to ISO8601 string with Z suffix
  String _formatDateTimeToIso8601Z(DateTime dateTime) {
    String isoString = dateTime.toIso8601String();
    if (!isoString.endsWith('Z')) {
      // Add Z suffix if not present
      if (isoString.endsWith('.000')) {
        return "${isoString}Z";
      } else {
        return "$isoString.000Z";
      }
    }
    return isoString;
  }

  /// Replace template placeholders in endpoint URLs
  String _replaceUrlTemplate(String template, Map<String, String> params) {
    String url = template;
    params.forEach((key, value) {
      url = url.replaceAll('{$key}', value);
    });
    return url;
  }

  /// Create a new time slot
  Future<dynamic> createTimeSlot({
    required String operatingScheduleId,
    required DateTime startTime,
    required DateTime endTime,
  }) async {
    try {
      Map<String, dynamic> data = {
        'operatingScheduleId': operatingScheduleId,
        'startTime': _formatDateTimeToIso8601Z(startTime),
        'endTime': _formatDateTimeToIso8601Z(endTime),
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
      // Process each time slot to ensure proper format
      final formattedTimeSlots =
          timeSlots.map((slot) {
            final Map<String, dynamic> formattedSlot = {...slot};

            // Format startTime if it's a DateTime
            if (formattedSlot.containsKey('startTime')) {
              if (formattedSlot['startTime'] is DateTime) {
                formattedSlot['startTime'] = _formatDateTimeToIso8601Z(
                  formattedSlot['startTime'],
                );
              } else if (formattedSlot['startTime'] is String) {
                String startTime = formattedSlot['startTime'];
                if (!startTime.endsWith('Z')) {
                  if (startTime.endsWith('.000')) {
                    formattedSlot['startTime'] = "${startTime}Z";
                  } else {
                    formattedSlot['startTime'] = "$startTime.000Z";
                  }
                }
              }
            }

            // Format endTime if it's a DateTime
            if (formattedSlot.containsKey('endTime')) {
              if (formattedSlot['endTime'] is DateTime) {
                formattedSlot['endTime'] = _formatDateTimeToIso8601Z(
                  formattedSlot['endTime'],
                );
              } else if (formattedSlot['endTime'] is String) {
                String endTime = formattedSlot['endTime'];
                if (!endTime.endsWith('Z')) {
                  if (endTime.endsWith('.000')) {
                    formattedSlot['endTime'] = "${endTime}Z";
                  } else {
                    formattedSlot['endTime'] = "$endTime.000Z";
                  }
                }
              }
            }

            return formattedSlot;
          }).toList();

      Map<String, dynamic> data = {
        'operatingScheduleId': operatingScheduleId,
        'timeSlots': formattedTimeSlots,
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
        // Ensure Z suffix for query parameter
        if (!startTime.endsWith('Z')) {
          startTime =
              startTime.endsWith('.000') ? "${startTime}Z" : "$startTime.000Z";
        }
        queryParameters['startTime'] = startTime;
      }

      if (endTime != null) {
        // Ensure Z suffix for query parameter
        if (!endTime.endsWith('Z')) {
          endTime = endTime.endsWith('.000') ? "${endTime}Z" : "$endTime.000Z";
        }
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
      final endpoint = _replaceUrlTemplate(ApiEndpoints.timeSlotDetail, {
        'id': id,
      });
      return await _apiClient.getValidated(endpoint);
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
        data['startTime'] = _formatDateTimeToIso8601Z(startTime);
      }

      if (endTime != null) {
        data['endTime'] = _formatDateTimeToIso8601Z(endTime);
      }

      final endpoint = _replaceUrlTemplate(ApiEndpoints.timeSlotDetail, {
        'id': id,
      });

      return await _apiClient.putValidated(endpoint, data: data);
    } catch (e) {
      rethrow;
    }
  }

  /// Delete time slot
  Future<dynamic> deleteTimeSlot(String id) async {
    try {
      final endpoint = _replaceUrlTemplate(ApiEndpoints.timeSlotDetail, {
        'id': id,
      });
      return await _apiClient.deleteValidated(endpoint);
    } catch (e) {
      rethrow;
    }
  }
}
