// lib/data/providers/service_category_provider.dart

import 'package:get/get.dart' hide Response;
import 'package:emababyspa/data/api/api_client.dart';
import 'package:emababyspa/data/api/api_endpoints.dart';
import 'package:emababyspa/data/models/service_category.dart';

class ServiceCategoryProvider {
  final ApiClient _apiClient = Get.find<ApiClient>();

  /// Create a new service category
  ///
  /// Returns the created service category data
  Future<ServiceCategory?> createServiceCategory({
    required String name,
    required String description,
  }) async {
    try {
      final data = await _apiClient.postValidated<Map<String, dynamic>>(
        ApiEndpoints.serviceCategories,
        data: {"name": name, "description": description},
      );

      return data != null ? ServiceCategory.fromJson(data) : null;
    } catch (e) {
      rethrow;
    }
  }

  /// Get all service categories
  ///
  /// Returns a list of service categories
  Future<List<ServiceCategory>> getAllServiceCategories() async {
    try {
      final data = await _apiClient.getValidated<List<dynamic>>(
        ApiEndpoints.serviceCategories,
      );

      if (data == null) return [];

      return data
          .map((item) => ServiceCategory.fromJson(item as Map<String, dynamic>))
          .toList();
    } catch (e) {
      rethrow;
    }
  }

  /// Get a service category by ID
  ///
  /// Returns the service category data or null if not found
  Future<ServiceCategory?> getServiceCategoryById(String id) async {
    try {
      final data = await _apiClient.getValidated<Map<String, dynamic>>(
        ApiEndpoints.serviceCategoryDetail,
        pathParams: {"id": id},
      );

      return data != null ? ServiceCategory.fromJson(data) : null;
    } catch (e) {
      rethrow;
    }
  }

  /// Update a service category
  ///
  /// Returns the updated service category data
  Future<ServiceCategory?> updateServiceCategory({
    required String id,
    required String name,
    required String description,
  }) async {
    try {
      final data = await _apiClient.putValidated<Map<String, dynamic>>(
        ApiEndpoints.serviceCategoryDetail,
        pathParams: {"id": id},
        data: {"name": name, "description": description},
      );

      return data != null ? ServiceCategory.fromJson(data) : null;
    } catch (e) {
      rethrow;
    }
  }

  /// Delete a service category
  ///
  /// Returns true if deletion was successful
  Future<bool> deleteServiceCategory(String id) async {
    try {
      final result = await _apiClient.deleteValidated<Map<String, dynamic>>(
        ApiEndpoints.serviceCategoryDetail,
        pathParams: {"id": id},
      );

      return result != null;
    } catch (e) {
      rethrow;
    }
  }
}
