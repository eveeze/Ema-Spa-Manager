// lib/data/providers/staff_provider.dart
import 'package:get/get.dart' hide Response, FormData, MultipartFile;
import 'package:emababyspa/data/api/api_client.dart';
import 'package:emababyspa/data/api/api_endpoints.dart';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:http_parser/http_parser.dart';
import 'package:path/path.dart' as path;
import 'package:emababyspa/utils/logger_utils.dart';

class StaffProvider {
  final ApiClient _apiClient = Get.find<ApiClient>();
  final LoggerUtils _logger = LoggerUtils();

  /// Create a new staff member
  ///
  /// Returns the created staff data or throws an exception
  Future<Map<String, dynamic>> createStaff({
    required String name,
    required String email,
    required String phoneNumber,
    String? address,
    File? profilePicture,
  }) async {
    try {
      if (profilePicture == null) {
        // If no profile picture, use regular JSON request
        return await _apiClient.postValidated(
          ApiEndpoints.staffs,
          data: {
            'name': name,
            'email': email,
            'phoneNumber': phoneNumber,
            if (address != null) 'address': address,
          },
        );
      } else {
        // If profile picture exists, use multipart form data
        // Get just the file name from the path
        String fileName = path.basename(profilePicture.path);

        // Create multipart form data with content type
        FormData formData = FormData.fromMap({
          'name': name,
          'email': email,
          'phoneNumber': phoneNumber,
          if (address != null && address.isNotEmpty) 'address': address,
          'profilePicture': await MultipartFile.fromFile(
            profilePicture.path,
            filename: fileName,
            contentType: MediaType.parse(_getContentType(fileName)),
          ),
        });

        return await _apiClient.postMultipartValidated(
          ApiEndpoints.staffs,
          data: formData,
        );
      }
    } catch (e) {
      rethrow;
    }
  }

  /// Get all staff members
  ///
  /// Returns a list of all staff or throws an exception
  Future<List<dynamic>> getAllStaffs({bool? isActive}) async {
    try {
      Map<String, dynamic>? queryParams;
      if (isActive != null) {
        queryParams = {'isActive': isActive.toString()};
      }

      return await _apiClient.getValidated(
        ApiEndpoints.staffs,
        queryParameters: queryParams,
      );
    } catch (e) {
      rethrow;
    }
  }

  /// Get a staff member by ID
  ///
  /// Returns the staff data or throws an exception
  Future<Map<String, dynamic>> getStaffById(String id) async {
    try {
      _logger.debug('Fetching staff with id: $id');

      if (id.isEmpty) {
        throw Exception('Staff ID cannot be empty');
      }

      // Ensure we're passing the ID as a path parameter correctly
      final result = await _apiClient.getValidated(
        ApiEndpoints.staffDetail, // This should be '/staff/{id}'
        pathParams: {'id': id}, // This will replace {id} with the actual ID
      );

      _logger.debug('Successfully fetched staff data');
      return result;
    } catch (e) {
      _logger.error('Error fetching staff with id $id: $e');
      rethrow;
    }
  }

  /// Update a staff member
  ///
  /// Returns the updated staff data or throws an exception
  Future<Map<String, dynamic>> updateStaff({
    required String id,
    String? name,
    String? email,
    String? phoneNumber,
    String? address,
    bool? isActive,
    File? profilePicture,
  }) async {
    try {
      if (profilePicture == null) {
        // If no profile picture, use regular JSON request
        return await _apiClient.putValidated(
          ApiEndpoints.staffDetail,
          pathParams: {'id': id},
          data: {
            if (name != null) 'name': name,
            if (email != null) 'email': email,
            if (phoneNumber != null) 'phoneNumber': phoneNumber,
            if (address != null && address.isNotEmpty) 'address': address,
            if (isActive != null) 'isActive': isActive,
          },
        );
      } else {
        // If profile picture exists, use multipart form data
        // Get just the file name from the path
        String fileName = path.basename(profilePicture.path);

        FormData formData = FormData.fromMap({
          if (name != null) 'name': name,
          if (email != null) 'email': email,
          if (phoneNumber != null) 'phoneNumber': phoneNumber,
          if (address != null && address.isNotEmpty) 'address': address,
          if (isActive != null)
            'isActive': isActive.toString(), // Convert boolean to string
          'profilePicture': await MultipartFile.fromFile(
            profilePicture.path,
            filename: fileName,
            contentType: MediaType.parse(_getContentType(fileName)),
          ),
        });

        return await _apiClient.putMultipartValidated(
          ApiEndpoints.staffDetail,
          pathParams: {'id': id},
          data: formData,
        );
      }
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
        '${ApiEndpoints.staffDetail}/status',
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

  // Helper method to determine the content type based on file extension
  String _getContentType(String fileName) {
    final ext = path.extension(fileName).toLowerCase();
    switch (ext) {
      case '.jpg':
      case '.jpeg':
        return 'image/jpeg';
      case '.png':
        return 'image/png';
      default:
        return 'application/octet-stream'; // Default content type
    }
  }
}
