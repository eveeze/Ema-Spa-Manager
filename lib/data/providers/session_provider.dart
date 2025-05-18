// lib/data/providers/session_provider.dart
import 'package:get/get.dart' hide Response;
import 'package:emababyspa/data/api/api_client.dart';
import 'package:emababyspa/data/api/api_endpoints.dart';
import 'package:emababyspa/data/api/api_exception.dart';

class SessionProvider {
  final ApiClient _apiClient = Get.find<ApiClient>();

  /// Helper method to extract data from API response
  dynamic _extractData(dynamic response) {
    if (response is Map<String, dynamic> && response.containsKey('data')) {
      return response['data'];
    }
    return response;
  }

  /// Format date to YYYY-MM-DD
  String _formatDate(String date) {
    try {
      return DateTime.parse(date).toIso8601String().split('T')[0];
    } catch (_) {
      // If the date is already formatted or invalid, return as is
      return date;
    }
  }

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

      return _extractData(response);
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

      final extractedData = _extractData(response);

      // Check if the extracted data is a list
      if (extractedData is List) {
        return List<Map<String, dynamic>>.from(extractedData);
      }

      throw ApiException(message: 'Unexpected response format from server');
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
        queryParameters['date'] = _formatDate(date);
      }

      final response = await _apiClient.getValidated(
        ApiEndpoints.sessions,
        queryParameters: queryParameters,
      );

      final extractedData = _extractData(response);

      // Check for the response structure
      if (extractedData is List) {
        return List<Map<String, dynamic>>.from(extractedData);
      } else if (extractedData is Map<String, dynamic> &&
          extractedData.containsKey('id')) {
        // If the response is itself a single item
        return [extractedData];
      }

      throw ApiException(message: 'Unexpected response format from server');
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
      return _extractData(response);
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

      return _extractData(response);
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

      // Check for success field in response
      if (response is Map<String, dynamic> && response.containsKey('success')) {
        return response['success'] == true;
      }

      return true; // Assume success if no specific indicator
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
      Map<String, dynamic> queryParameters = {'date': _formatDate(date)};

      if (duration != null) {
        queryParameters['duration'] = duration.toString();
      }

      final response = await _apiClient.getValidated(
        '${ApiEndpoints.sessions}/available',
        queryParameters: queryParameters,
      );

      final extractedData = _extractData(response);

      if (extractedData is List) {
        return List<Map<String, dynamic>>.from(extractedData);
      }

      throw ApiException(message: 'Unexpected response format from server');
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

      return _extractData(response);
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
        queryParameters['startDate'] = _formatDate(startDate);
      }

      if (endDate != null) {
        queryParameters['endDate'] = _formatDate(endDate);
      }

      final response = await _apiClient.getValidated(
        '${ApiEndpoints.sessions}/staff/$staffId',
        queryParameters: queryParameters,
      );

      final extractedData = _extractData(response);

      if (extractedData is List) {
        return List<Map<String, dynamic>>.from(extractedData);
      }

      throw ApiException(message: 'Unexpected response format from server');
    } catch (e) {
      rethrow;
    }
  }
}
