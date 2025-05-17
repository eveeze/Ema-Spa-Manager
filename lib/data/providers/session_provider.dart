// lib/data/providers/session_provider.dart
import 'package:get/get.dart' hide Response;
import 'package:emababyspa/data/api/api_client.dart';
import 'package:emababyspa/data/api/api_endpoints.dart';

class SessionProvider {
  final ApiClient _apiClient = Get.find<ApiClient>();

  /// Create a new session
  Future<Map<String, dynamic>> createSession({
    required String timeSlotId,
    required String staffId,
    bool isBooked = false,
  }) async {
    try {
      Map<String, dynamic> data = {
        'timeSlotId': timeSlotId,
        'staffId': staffId,
        'isBooked': isBooked,
      };

      final response = await _apiClient.postValidated(
        ApiEndpoints.sessions,
        data: data,
      );
      return response['data'];
    } catch (e) {
      rethrow;
    }
  }

  /// Create multiple sessions at once
  Future<List<Map<String, dynamic>>> createManySessions({
    required List<Map<String, dynamic>> sessions,
  }) async {
    try {
      Map<String, dynamic> data = {'sessions': sessions};

      final response = await _apiClient.postValidated(
        '${ApiEndpoints.sessions}/batch',
        data: data,
      );

      return List<Map<String, dynamic>>.from(response['data']);
    } catch (e) {
      rethrow;
    }
  }

  /// Get all sessions with optional filtering
  Future<List<Map<String, dynamic>>> getAllSessions({
    bool? isBooked,
    String? staffId,
    String? timeSlotId,
    String? date,
  }) async {
    try {
      Map<String, dynamic> queryParameters = {};

      if (isBooked != null) {
        queryParameters['isBooked'] = isBooked.toString();
      }

      if (staffId != null) {
        queryParameters['staffId'] = staffId;
      }

      if (timeSlotId != null) {
        queryParameters['timeSlotId'] = timeSlotId;
      }

      if (date != null) {
        queryParameters['date'] = date;
      }

      final response = await _apiClient.getValidated(
        ApiEndpoints.sessions,
        queryParameters: queryParameters,
      );

      return List<Map<String, dynamic>>.from(response['data']);
    } catch (e) {
      rethrow;
    }
  }

  /// Get a session by ID
  Future<Map<String, dynamic>> getSessionById(String id) async {
    try {
      final response = await _apiClient.getValidated(
        '${ApiEndpoints.sessions}/$id',
      );
      return response['data'];
    } catch (e) {
      rethrow;
    }
  }

  /// Update a session
  Future<Map<String, dynamic>> updateSession({
    required String id,
    String? timeSlotId,
    String? staffId,
    bool? isBooked,
  }) async {
    try {
      Map<String, dynamic> data = {};

      if (timeSlotId != null) data['timeSlotId'] = timeSlotId;
      if (staffId != null) data['staffId'] = staffId;
      if (isBooked != null) data['isBooked'] = isBooked;

      final response = await _apiClient.putValidated(
        '${ApiEndpoints.sessions}/$id',
        data: data,
      );

      return response['data'];
    } catch (e) {
      rethrow;
    }
  }

  /// Delete a session
  Future<bool> deleteSession(String id) async {
    try {
      final response = await _apiClient.deleteValidated(
        '${ApiEndpoints.sessions}/$id',
      );
      return response['success'] == true;
    } catch (e) {
      rethrow;
    }
  }

  /// Get available sessions for a specific date and service duration
  Future<List<Map<String, dynamic>>> getAvailableSessions({
    required String date,
    int? duration,
  }) async {
    try {
      Map<String, dynamic> queryParameters = {'date': date};

      if (duration != null) {
        queryParameters['duration'] = duration.toString();
      }

      final response = await _apiClient.getValidated(
        '${ApiEndpoints.sessions}/available',
        queryParameters: queryParameters,
      );

      return List<Map<String, dynamic>>.from(response['data']);
    } catch (e) {
      rethrow;
    }
  }

  /// Update session booking status
  Future<Map<String, dynamic>> updateSessionBookingStatus(
    String id,
    bool isBooked,
  ) async {
    try {
      final response = await _apiClient.putValidated(
        '${ApiEndpoints.sessions}/$id/booking-status',
        data: {'isBooked': isBooked},
      );

      return response['data'];
    } catch (e) {
      rethrow;
    }
  }

  /// Get sessions by staff ID with optional date range
  Future<List<Map<String, dynamic>>> getSessionsByStaff(
    String staffId, {
    String? startDate,
    String? endDate,
  }) async {
    try {
      Map<String, dynamic> queryParameters = {};

      if (startDate != null) {
        queryParameters['startDate'] = startDate;
      }

      if (endDate != null) {
        queryParameters['endDate'] = endDate;
      }

      final response = await _apiClient.getValidated(
        '${ApiEndpoints.sessions}/staff/$staffId',
        queryParameters: queryParameters,
      );

      return List<Map<String, dynamic>>.from(response['data']);
    } catch (e) {
      rethrow;
    }
  }
}
