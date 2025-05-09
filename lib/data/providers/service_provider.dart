// lib/data/providers/service_provider.dart

import 'package:get/get.dart' hide Response, FormData, MultipartFile;
import 'package:emababyspa/data/api/api_client.dart';
import 'package:emababyspa/data/api/api_endpoints.dart';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:http_parser/http_parser.dart';
import 'package:path/path.dart' as path;
import 'package:emababyspa/utils/logger_utils.dart';

class ServiceProvider {
  final ApiClient _apiClient = Get.find<ApiClient>();
  final LoggerUtils _logger = LoggerUtils();

  // Updated code for ServiceProvider createService method
  Future<dynamic> createService({
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
      if (imageFile == null) {
        // Regular JSON request if no file is provided
        Map<String, dynamic> data = {
          'name': name,
          'description': description,
          'duration': duration,
          'categoryId': categoryId,
          'hasPriceTiers': hasPriceTiers,
        };

        if (imageUrl != null) {
          data['imageUrl'] = imageUrl;
        }

        if (!hasPriceTiers) {
          data['price'] = price;
          data['minBabyAge'] = minBabyAge;
          data['maxBabyAge'] = maxBabyAge;
        } else if (priceTiers != null) {
          // Make sure all priceTiers have the required fields
          List<Map<String, dynamic>> validatedTiers = [];
          for (int i = 0; i < priceTiers.length; i++) {
            var tier = Map<String, dynamic>.from(priceTiers[i]);
            // Check if fields are non-null
            if (tier['minBabyAge'] != null &&
                tier['maxBabyAge'] != null &&
                tier['price'] != null) {
              // Add tierName if not provided
              if (tier['tierName'] == null ||
                  tier['tierName'].toString().trim().isEmpty) {
                tier['tierName'] = 'Tier ${i + 1}';
              }
              validatedTiers.add(tier);
            }
          }

          // Only add priceTiers to data if we have valid tiers
          if (validatedTiers.isNotEmpty) {
            data['priceTiers'] = validatedTiers;
          }
        }

        return await _apiClient.postValidated(
          ApiEndpoints.services,
          data: data,
        );
      } else {
        // Multipart form data for file upload
        String fileName = path.basename(imageFile.path);

        // Create FormData map with all fields
        Map<String, dynamic> formFields = {
          'name': name,
          'description': description,
          'duration': duration.toString(),
          'categoryId': categoryId,
          'hasPriceTiers': hasPriceTiers.toString(),
        };

        // Add image file - Use the field name expected by the server (likely 'image')
        formFields['imageUrl'] = await MultipartFile.fromFile(
          imageFile.path,
          filename: fileName,
          contentType: MediaType.parse(_getContentType(fileName)),
        );

        // Add appropriate fields based on pricing model
        if (!hasPriceTiers) {
          formFields['price'] = price.toString();
          formFields['minBabyAge'] = minBabyAge.toString();
          formFields['maxBabyAge'] = maxBabyAge.toString();
        } else if (priceTiers != null) {
          // For price tiers, we need to format them for multipart form data
          // Only include tiers with all required fields
          int validTierIndex = 0;
          for (int i = 0; i < priceTiers.length; i++) {
            // Verify that all required fields are present
            if (priceTiers[i]['minBabyAge'] != null &&
                priceTiers[i]['maxBabyAge'] != null &&
                priceTiers[i]['price'] != null) {
              formFields['priceTiers[$validTierIndex][minBabyAge]'] =
                  priceTiers[i]['minBabyAge'].toString();
              formFields['priceTiers[$validTierIndex][maxBabyAge]'] =
                  priceTiers[i]['maxBabyAge'].toString();
              formFields['priceTiers[$validTierIndex][price]'] =
                  priceTiers[i]['price'].toString();
              // Ensure tierName is always included and properly formatted
              String tierName = priceTiers[i]['tierName']!.toString();
              formFields['priceTiers[$validTierIndex][tierName]'] =
                  (tierName.trim().isNotEmpty) ? tierName : 'Tier ${i + 1}';

              validTierIndex++;
            }
          }
        }

        _logger.debug('Creating FormData with fields: $formFields');
        FormData formData = FormData.fromMap(formFields);

        return await _apiClient.postMultipartValidated(
          ApiEndpoints.services,
          data: formData,
        );
      }
    } catch (e) {
      _logger.error('Creating service failed: $e');
      rethrow;
    }
  }

  Future<dynamic> getAllServices({
    bool? isActive,
    String? categoryId,
    int? babyAge,
  }) async {
    try {
      Map<String, dynamic> queryParameters = {};

      if (isActive != null) {
        queryParameters['isActive'] = isActive.toString();
      }

      if (categoryId != null) {
        queryParameters['categoryId'] = categoryId;
      }

      if (babyAge != null) {
        queryParameters['babyAge'] = babyAge.toString();
      }

      return await _apiClient.getValidated(
        ApiEndpoints.services,
        queryParameters: queryParameters,
      );
    } catch (e) {
      rethrow;
    }
  }

  Future<dynamic> getServiceById(String id) async {
    try {
      return await _apiClient.getValidated(
        ApiEndpoints.serviceDetail,
        pathParams: {'id': id},
      );
    } catch (e) {
      rethrow;
    }
  }

  Future<dynamic> updateService({
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
      if (imageFile == null) {
        // Regular JSON request if no file is provided
        Map<String, dynamic> data = {};

        if (name != null) data['name'] = name;
        if (description != null) data['description'] = description;
        if (duration != null) data['duration'] = duration;
        if (categoryId != null) data['categoryId'] = categoryId;
        if (hasPriceTiers != null) data['hasPriceTiers'] = hasPriceTiers;
        if (imageUrl != null) data['imageUrl'] = imageUrl;
        if (isActive != null) data['isActive'] = isActive;
        if (price != null) data['price'] = price;
        if (minBabyAge != null) data['minBabyAge'] = minBabyAge;
        if (maxBabyAge != null) data['maxBabyAge'] = maxBabyAge;
        if (priceTiers != null) data['priceTiers'] = priceTiers;

        return await _apiClient.putValidated(
          '${ApiEndpoints.services}/{id}',
          data: data,
          pathParams: {'id': id},
        );
      } else {
        // Multipart form data for file upload
        String fileName = path.basename(imageFile.path);

        Map<String, dynamic> formFields = {};

        if (name != null) formFields['name'] = name;
        if (description != null) formFields['description'] = description;
        if (duration != null) formFields['duration'] = duration.toString();
        if (categoryId != null) formFields['categoryId'] = categoryId;
        if (hasPriceTiers != null) {
          formFields['hasPriceTiers'] = hasPriceTiers.toString();
        }
        if (isActive != null) formFields['isActive'] = isActive.toString();
        if (price != null) formFields['price'] = price.toString();
        if (minBabyAge != null) {
          formFields['minBabyAge'] = minBabyAge.toString();
        }
        if (maxBabyAge != null) {
          formFields['maxBabyAge'] = maxBabyAge.toString();
        }

        // Make sure to use the correct field name for the file as expected by the server
        formFields['imageUrl'] = await MultipartFile.fromFile(
          imageFile.path,
          filename: fileName,
          contentType: MediaType.parse(_getContentType(fileName)),
        );

        if (priceTiers != null) {
          // Handle price tiers in multipart request
          for (int i = 0; i < priceTiers.length; i++) {
            formFields['priceTiers[$i][minBabyAge]'] =
                priceTiers[i]['minBabyAge'].toString();
            formFields['priceTiers[$i][maxBabyAge]'] =
                priceTiers[i]['maxBabyAge'].toString();
            formFields['priceTiers[$i][price]'] =
                priceTiers[i]['price'].toString();
            // Ensure tierName is always included and properly formatted
            formFields['priceTiers[$i][tierName]'] =
                priceTiers[i]['tierName']?.toString() ?? 'Tier ${i + 1}';
          }
        }

        FormData formData = FormData.fromMap(formFields);

        return await _apiClient.putMultipartValidated(
          '${ApiEndpoints.services}/{id}',
          data: formData,
          pathParams: {'id': id},
        );
      }
    } catch (e) {
      _logger.error('Updating service failed: $e');
      rethrow;
    }
  }

  Future<dynamic> deleteService(String id) async {
    try {
      return await _apiClient.deleteValidated(
        ApiEndpoints.serviceDetail,
        pathParams: {'id': id},
      );
    } catch (e) {
      rethrow;
    }
  }

  Future<dynamic> getServicesByCategory(
    String categoryId, {
    int? babyAge,
  }) async {
    try {
      Map<String, dynamic> queryParameters = {};

      if (babyAge != null) {
        queryParameters['babyAge'] = babyAge.toString();
      }

      return await _apiClient.getValidated(
        '${ApiEndpoints.serviceByCategory}/{categoryId}',
        pathParams: {'categoryId': categoryId},
        queryParameters: queryParameters,
      );
    } catch (e) {
      rethrow;
    }
  }

  Future<dynamic> getServicePriceTier(String serviceId, int babyAge) async {
    try {
      return await _apiClient.getValidated(
        '${ApiEndpoints.services}/{serviceId}/price',
        pathParams: {'serviceId': serviceId},
        queryParameters: {'babyAge': babyAge.toString()},
      );
    } catch (e) {
      rethrow;
    }
  }

  Future<dynamic> toggleServiceStatus(String id, bool isActive) async {
    try {
      return await _apiClient.patchValidated(
        '${ApiEndpoints.services}/{id}/status',
        data: {'isActive': isActive},
        pathParams: {'id': id},
      );
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
