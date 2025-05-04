// lib/data/providers/staff_provider.dart
import 'package:get/get.dart' hide Response;
import 'package:emababyspa/data/api/api_client.dart';
import 'package:emababyspa/data/api/api_endpoints.dart';

class StaffProvider {
  final ApiClient _apiClient = Get.find<ApiClient>();

  /// Create a new staff member
  ///
  /// Returns the created staff data or throws an exception
  Future<Map<String, dynamic>> createStaff({
    required String name,
    required String email,
    required String phoneNumber,
    String? address,
  }) async {
    try {
      return await _apiClient.postValidated(
        ApiEndpoints.staffs,
        data: {
          'name': name,
          'email': email,
          'phoneNumber': phoneNumber,
          if (address != null) 'address': address,
        },
      );
    } catch (e) {
      rethrow;
    }
  }

  /// Get all staff members
  ///
  /// Returns a list of all staff or throws an exception
  Future<List<dynamic>> getAllStaffs() async {
    try {
      return await _apiClient.getValidated(ApiEndpoints.staffs);
    } catch (e) {
      rethrow;
    }
  }

  /// Get a staff member by ID
  ///
  /// Returns the staff data or throws an exception
  Future<Map<String, dynamic>> getStaffById(String id) async {
    try {
      return await _apiClient.getValidated(
        ApiEndpoints.staffDetail,
        pathParams: {'id': id},
      );
    } catch (e) {
      rethrow;
    }
  }

  /// Update a staff member
  ///
  /// Returns the updated staff data or throws an exception
  Future<Map<String, dynamic>> updateStaff({
    required String id,
    required String name,
    required String email,
    required String phoneNumber,
    String? address,
    required bool isActive,
  }) async {
    try {
      return await _apiClient.putValidated(
        ApiEndpoints.staffDetail,
        pathParams: {'id': id},
        data: {
          'name': name,
          'email': email,
          'phoneNumber': phoneNumber,
          if (address != null) 'address': address,
          'isActive': isActive,
        },
      );
    } catch (e) {
      rethrow;
    }
  }

  /// Update staff active status
  ///
  /// Returns the updated staff data or throws an exception
  Future<Map<String, dynamic>> updateStaffStatus({
    required String id,
    required bool isActive,
  }) async {
    try {
      return await _apiClient.patchValidated(
        ApiEndpoints.staffDetail,
        pathParams: {'id': id},
        data: {'isActive': isActive},
      );
    } catch (e) {
      rethrow;
    }
  }

  /// Delete a staff member
  ///
  /// Returns true if deletion was successful or throws an exception
  Future<bool> deleteStaff(String id) async {
    try {
      final result = await _apiClient.deleteValidated(
        ApiEndpoints.staffDetail,
        pathParams: {'id': id},
      );

      return result != null;
    } catch (e) {
      rethrow;
    }
  }
}
