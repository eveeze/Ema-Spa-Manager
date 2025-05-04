// lib/data/repositories/service_category_repository.dart
import 'package:get/get.dart';
import 'package:dio/dio.dart';
import 'package:emababyspa/data/models/service_category.dart';
import 'package:emababyspa/data/providers/service_category_provider.dart';
import 'package:emababyspa/utils/logger_utils.dart';

class ServiceCategoryRepository {
  final ServiceCategoryProvider _provider = Get.find<ServiceCategoryProvider>();
  final LoggerUtils _logger = LoggerUtils();

  /// Get all service categories
  ///
  /// Returns a list of service categories or an empty list if there's an error
  Future<List<ServiceCategory>> getAllCategories() async {
    try {
      return await _provider.getAllServiceCategories();
    } catch (e) {
      _logger.error('Failed to get service categories: $e');
      return [];
    }
  }

  /// Get a service category by ID
  ///
  /// Returns the category or null if not found
  Future<ServiceCategory?> getCategoryById(String id) async {
    try {
      return await _provider.getServiceCategoryById(id);
    } catch (e) {
      if (e is DioException && e.response?.statusCode == 404) {
        _logger.info('Service category not found: $id');
        return null;
      }
      _logger.error('Failed to get service category: $e');
      return null;
    }
  }

  /// Create a new service category
  ///
  /// Returns the created category or null if there's an error
  Future<ServiceCategory?> createCategory({
    required String name,
    String? description,
  }) async {
    try {
      return await _provider.createServiceCategory(
        name: name,
        description: description ?? '',
      );
    } catch (e) {
      _logger.error('Failed to create service category: $e');
      return null;
    }
  }

  /// Update a service category
  ///
  /// Returns the updated category or null if there's an error
  Future<ServiceCategory?> updateCategory({
    required String id,
    required String name,
    String? description,
  }) async {
    try {
      return await _provider.updateServiceCategory(
        id: id,
        name: name,
        description: description ?? '',
      );
    } catch (e) {
      _logger.error('Failed to update service category: $e');
      return null;
    }
  }

  /// Delete a service category
  ///
  /// Returns true if deletion was successful
  Future<bool> deleteCategory(String id) async {
    try {
      return await _provider.deleteServiceCategory(id);
    } catch (e) {
      if (e is DioException && e.response?.statusCode == 400) {
        // This is the error when category has associated services
        _logger.warning('Cannot delete category with associated services: $id');
      } else {
        _logger.error('Failed to delete service category: $e');
      }
      return false;
    }
  }

  /// Check if a category has associated services
  ///
  /// Returns true if the category has services
  Future<bool> categoryHasServices(String id) async {
    try {
      final category = await getCategoryById(id);
      return category?.services != null && category!.services!.isNotEmpty;
    } catch (e) {
      _logger.error('Failed to check if category has services: $e');
      return false;
    }
  }
}
