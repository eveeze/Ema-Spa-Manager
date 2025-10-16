// lib/data/providers/analytics_provider.dart
import 'package:get/get.dart' hide Response;
import 'package:emababyspa/data/api/api_client.dart';
import 'package:emababyspa/data/api/api_endpoints.dart';

class AnalyticsProvider {
  final ApiClient _apiClient = Get.find<ApiClient>();

  /// Fetches real-time KPI data for the main dashboard overview.
  Future<Map<String, dynamic>> getAnalyticsOverview() async {
    try {
      return await _apiClient.getValidated(ApiEndpoints.analyticsOverview);
    } catch (e) {
      rethrow;
    }
  }

  /// Fetches detailed insights like trend charts, top services, and top staff.
  /// The [days] parameter specifies the time range (e.g., last 7 days).
  Future<Map<String, dynamic>> getAnalyticsDetails({int? days}) async {
    try {
      final Map<String, dynamic> queryParameters = {};
      if (days != null) {
        queryParameters['days'] = days.toString();
      }

      return await _apiClient.getValidated(
        ApiEndpoints.analyticsDetails,
        queryParameters: queryParameters.isNotEmpty ? queryParameters : null,
      );
    } catch (e) {
      rethrow;
    }
  }
}
