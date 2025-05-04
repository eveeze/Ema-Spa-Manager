// lib/data/providers/auth_provider.dart
import 'package:get/get.dart' hide Response;
import 'package:emababyspa/data/api/api_client.dart';
import 'package:emababyspa/data/api/api_endpoints.dart';

class AuthProvider {
  final ApiClient _apiClient = Get.find<ApiClient>();

  Future<Map<String, dynamic>?> login({
    required String email,
    required String password,
  }) async {
    try {
      // Use postValidated to automatically handle response validation
      return await _apiClient.postValidated(
        ApiEndpoints.login,
        data: {'email': email, 'password': password},
        // Don't need to specify dataField as we want the entire response
        throwOnError: true,
      );
    } catch (e) {
      rethrow;
    }
  }

  /// Get user profile data
  ///
  /// Returns validated response with owner profile information
  Future<Map<String, dynamic>?> getProfile() async {
    try {
      // Use getValidated to automatically handle response validation
      return await _apiClient.getValidated(
        ApiEndpoints.profile,
        dataField: 'data', // Extract only the data field
        throwOnError: true,
      );
    } catch (e) {
      rethrow;
    }
  }
}
