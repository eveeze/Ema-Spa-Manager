// lib/data/repository/service_repository.dart
import 'dart:io';
import 'package:emababyspa/data/api/api_exception.dart';
import 'package:emababyspa/data/providers/service_provider.dart';
import 'package:emababyspa/data/models/service.dart';
import 'package:emababyspa/utils/logger_utils.dart';
import 'package:emababyspa/utils/file_utils.dart';

class ServiceRepository {
  final ServiceProvider _provider;
  final LoggerUtils _logger = LoggerUtils();

  ServiceRepository({required ServiceProvider provider}) : _provider = provider;

  /// Create a new service
  // Updated code for ServiceRepository createService method
  Future<Service> createService({
    required String name,
    required String description,
    required int duration,
    required String categoryId,
    required bool hasPriceTiers,
    File? imageFile,
    String? imageUrl,
    double? price,
    int? minBabyAge,
    int? maxBabyAge,
    List<Map<String, dynamic>>? priceTiers,
  }) async {
    try {
      // Validate inputs
      if (hasPriceTiers) {
        if (priceTiers == null || priceTiers.isEmpty) {
          throw ApiException(
            message: 'Price tiers are required when hasPriceTiers is true',
          );
        }

        // Create a new list to avoid modifying the original list
        List<Map<String, dynamic>> validatedPriceTiers = [];

        // Ensure all price tiers have the required fields
        for (int i = 0; i < priceTiers.length; i++) {
          var tier = Map<String, dynamic>.from(priceTiers[i]);

          // Check for required fields
          if (tier['minBabyAge'] == null ||
              tier['maxBabyAge'] == null ||
              tier['price'] == null) {
            throw ApiException(
              message:
                  'Each price tier must have minBabyAge, maxBabyAge, and price',
            );
          }

          // Add tierName if not provided
          if (tier['tierName'] == null ||
              tier['tierName'].toString().trim().isEmpty) {
            tier['tierName'] = 'Tier ${i + 1}';
          }

          validatedPriceTiers.add(tier);
        }

        // Replace original priceTiers with validated ones
        priceTiers = validatedPriceTiers;
      } else {
        if (price == null || minBabyAge == null || maxBabyAge == null) {
          throw ApiException(
            message:
                'Price, minBabyAge, and maxBabyAge are required when hasPriceTiers is false',
          );
        }
      }

      // Validate image file if provided
      if (imageFile != null) {
        if (!FileUtils.isAllowedImageType(imageFile)) {
          throw ApiException(
            message: 'Only JPG, JPEG and PNG images are allowed',
          );
        }

        if (!FileUtils.isFileSizeWithinLimit(imageFile, 5.0)) {
          // Limit to 5MB like StaffRepository
          throw ApiException(message: 'Image size must be less than 5MB');
        }
      }

      final serviceData = await _provider.createService(
        name: name,
        description: description,
        duration: duration,
        categoryId: categoryId,
        hasPriceTiers: hasPriceTiers,
        imageFile: imageFile,
        imageUrl: imageUrl,
        price: price,
        minBabyAge: minBabyAge,
        maxBabyAge: maxBabyAge,
        priceTiers: priceTiers,
      );

      return Service.fromJson(serviceData);
    } catch (e) {
      _logger.error('Error creating service: $e');
      if (e is ApiException) rethrow;
      throw ApiException(
        message: 'Gagal membuat layanan baru. Silakan coba lagi nanti.',
      );
    }
  }

  /// Get all services with optional filtering
  Future<List<Service>> getAllServices({
    bool? isActive,
    String? categoryId,
    int? babyAge,
  }) async {
    try {
      final servicesData = await _provider.getAllServices(
        isActive: isActive,
        categoryId: categoryId,
        babyAge: babyAge,
      );

      if (servicesData is List) {
        return servicesData.map((json) => Service.fromJson(json)).toList();
      }

      throw ApiException(message: 'Invalid response format');
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException(
        message: 'Gagal mengambil data layanan. Silakan coba lagi nanti.',
      );
    }
  }

  /// Get service details by ID
  Future<Service> getServiceById(String id) async {
    try {
      final serviceData = await _provider.getServiceById(id);
      return Service.fromJson(serviceData);
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException(
        message: 'Gagal mengambil detail layanan. Silakan coba lagi nanti.',
      );
    }
  }

  /// Get services by category ID with optional baby age filter
  Future<List<Service>> getServicesByCategory(
    String categoryId, {
    int? babyAge,
  }) async {
    try {
      final servicesData = await _provider.getServicesByCategory(
        categoryId,
        babyAge: babyAge,
      );

      if (servicesData is List) {
        return servicesData.map((json) => Service.fromJson(json)).toList();
      }

      throw ApiException(message: 'Invalid response format');
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException(
        message:
            'Gagal mengambil layanan berdasarkan kategori. Silakan coba lagi nanti.',
      );
    }
  }

  /// Get service price tier based on baby age
  Future<Map<String, dynamic>> getServicePriceTier(
    String serviceId,
    int babyAge,
  ) async {
    try {
      final priceTierData = await _provider.getServicePriceTier(
        serviceId,
        babyAge,
      );

      // Ensure we have the expected fields
      if (priceTierData is Map<String, dynamic> &&
          priceTierData.containsKey('serviceId') &&
          priceTierData.containsKey('price')) {
        return {
          'serviceId': priceTierData['serviceId'],
          'price': priceTierData['price'],
          'minBabyAge': priceTierData['minBabyAge'],
          'maxBabyAge': priceTierData['maxBabyAge'],
          'tierName':
              priceTierData['tierName'], // Will be null for non-tiered services
        };
      }

      throw ApiException(message: 'Invalid price tier data format');
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException(
        message: 'Gagal mendapatkan informasi harga. Silakan coba lagi nanti.',
      );
    }
  }

  /// Update an existing service
  Future<Service> updateService({
    required String id,
    String? name,
    String? description,
    int? duration,
    String? categoryId,
    bool? hasPriceTiers,
    File? imageFile,
    String? imageUrl,
    double? price,
    int? minBabyAge,
    int? maxBabyAge,
    List<Map<String, dynamic>>? priceTiers,
    bool? isActive,
  }) async {
    try {
      // Get existing service to check current pricing model
      Service? existingService;
      try {
        existingService = await getServiceById(id);
      } catch (e) {
        // If we can't get the existing service, proceed with validation based on the parameters
      }

      // Validate inputs if we're changing the pricing model
      if (hasPriceTiers != null) {
        final usingPriceTiers = hasPriceTiers;

        if (usingPriceTiers && (priceTiers == null || priceTiers.isEmpty)) {
          throw ApiException(
            message: 'Price tiers are required when hasPriceTiers is true',
          );
        } else if (usingPriceTiers && priceTiers != null) {
          // Ensure all price tiers have the required fields
          for (var tier in priceTiers) {
            if (tier['minBabyAge'] == null ||
                tier['maxBabyAge'] == null ||
                tier['price'] == null) {
              throw ApiException(
                message:
                    'Each price tier must have minBabyAge, maxBabyAge, and price',
              );
            }

            // Add tierName if not provided
            if (tier['tierName'] == null) {
              tier['tierName'] = 'Tier ${priceTiers.indexOf(tier) + 1}';
            }
          }
        } else if (!usingPriceTiers &&
            (price == null || minBabyAge == null || maxBabyAge == null)) {
          throw ApiException(
            message:
                'Price, minBabyAge, and maxBabyAge are required when hasPriceTiers is false',
          );
        }
      } else if (existingService != null &&
          priceTiers != null &&
          existingService.hasPriceTiers) {
        // We're updating price tiers of a service that already uses them
        for (var tier in priceTiers) {
          if (tier['minBabyAge'] == null ||
              tier['maxBabyAge'] == null ||
              tier['price'] == null) {
            throw ApiException(
              message:
                  'Each price tier must have minBabyAge, maxBabyAge, and price',
            );
          }

          // Add tierName if not provided
          if (tier['tierName'] == null) {
            tier['tierName'] = 'Tier ${priceTiers.indexOf(tier) + 1}';
          }
        }
      }

      // Validate image file if provided
      if (imageFile != null) {
        if (!FileUtils.isAllowedImageType(imageFile)) {
          throw ApiException(
            message: 'Only JPG, JPEG and PNG images are allowed',
          );
        }

        if (!FileUtils.isFileSizeWithinLimit(imageFile, 5.0)) {
          throw ApiException(message: 'Image size must be less than 5MB');
        }
      }

      final serviceData = await _provider.updateService(
        id: id,
        name: name,
        description: description,
        duration: duration,
        categoryId: categoryId,
        hasPriceTiers: hasPriceTiers,
        imageFile: imageFile,
        imageUrl: imageUrl,
        price: price,
        minBabyAge: minBabyAge,
        maxBabyAge: maxBabyAge,
        priceTiers: priceTiers,
        isActive: isActive,
      );

      return Service.fromJson(serviceData);
    } catch (e) {
      _logger.error('Error updating service: $e');
      if (e is ApiException) rethrow;
      throw ApiException(
        message: 'Gagal memperbarui layanan. Silakan coba lagi nanti.',
      );
    }
  }

  /// Delete a service
  Future<bool> deleteService(String id) async {
    try {
      final result = await _provider.deleteService(id);
      return result != null; // If we get here, the operation was successful
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException(
        message: 'Gagal menghapus layanan. Silakan coba lagi nanti.',
      );
    }
  }

  /// Toggle service active status
  Future<Service> toggleServiceStatus(String id, bool isActive) async {
    try {
      final serviceData = await _provider.toggleServiceStatus(id, isActive);
      return Service.fromJson(serviceData);
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException(
        message: 'Gagal mengubah status layanan. Silakan coba lagi nanti.',
      );
    }
  }
}
