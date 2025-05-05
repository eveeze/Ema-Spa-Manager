// lib/data/providers/service_provider.dart

import 'package:get/get.dart' hide Response;
import 'package:emababyspa/data/api/api_client.dart';
import 'package:emababyspa/data/api/api_endpoints.dart';

class ServiceProvider {
  final ApiClient _apiClient = Get.find<ApiClient>();

  Future<dynamic> createService({
    required String name,
    required String description,
    required int duration,
    required String categoryId,
    required bool hasPriceTiers,
    required String? imageUrl,
    required double? price,
    required int? minBabyAge,
    required int? maxBabyAge,
    List<Map<String, dynamic>>? priceTiers,
  }) async {
    try {
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
        data['priceTiers'] = priceTiers;
      }

      return await _apiClient.postValidated(ApiEndpoints.services, data: data);
    } catch (e) {
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
    String? imageUrl,
    double? price,
    int? minBabyAge,
    int? maxBabyAge,
    List<Map<String, dynamic>>? priceTiers,
    bool? isActive,
  }) async {
    try {
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
    } catch (e) {
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
}
