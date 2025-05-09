// lib/features/service/controllers/service_controller.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:emababyspa/data/repository/service_repository.dart';
import 'package:emababyspa/data/models/service.dart';
import 'package:emababyspa/data/repository/service_category_repository.dart';
import 'package:emababyspa/utils/logger_utils.dart';
import 'package:emababyspa/data/models/service_category.dart';
import 'package:emababyspa/data/repository/staff_repository.dart';
import 'package:emababyspa/data/models/staff.dart';
import 'package:emababyspa/data/api/api_exception.dart';

class ServiceController extends GetxController {
  final ServiceRepository _serviceRepository;
  late ServiceCategoryRepository _serviceCategoryRepository;
  late StaffRepository _staffRepository;
  final LoggerUtils _logger = LoggerUtils();

  // Observable variables
  final RxList<Service> services = <Service>[].obs;
  final RxList<ServiceCategory> serviceCategories = <ServiceCategory>[].obs;
  final RxList<Staff> staff = <Staff>[].obs;
  final RxBool isLoading = false.obs;

  // Add individual loading state variables for each resource type
  final RxBool isLoadingServices = false.obs;
  final RxBool isLoadingStaff = false.obs;
  final RxBool isLoadingCategories = false.obs;

  // Loading states for service operations
  final RxBool isCreatingService = false.obs;
  final RxBool isUpdatingService = false.obs;
  final RxBool isDeletingService = false.obs;
  final RxBool isTogglingServiceStatus = false.obs;
  final RxBool isFetchingServiceDetail = false.obs;
  final RxBool isFetchingPriceTier = false.obs;

  final RxString errorMessage = ''.obs;
  final RxString serviceError = ''.obs;
  final RxString categoryError = ''.obs;
  final RxString staffError = ''.obs;

  // dashboard counter
  final RxInt serviceCount = 0.obs;
  final RxInt staffCount = 0.obs;
  final RxInt categoryCount = 0.obs;

  // Selected service for detail view
  final Rx<Service?> selectedService = Rx<Service?>(null);

  // Price tier data
  final Rx<Map<String, dynamic>?> priceTierData = Rx<Map<String, dynamic>?>(
    null,
  );

  ServiceController({required ServiceRepository serviceRepository})
    : _serviceRepository = serviceRepository {
    _serviceCategoryRepository = Get.find<ServiceCategoryRepository>();
    _staffRepository = Get.find<StaffRepository>();
  }

  @override
  void onInit() {
    super.onInit();
    fetchAllData();
  }

  Future<void> fetchAllData() async {
    isLoading.value = true;
    errorMessage.value = '';
    await fetchServices();
    await fetchCategories();
    await fetchStaff();
    isLoading.value = false;
  }

  // Navigate to service management page
  void navigateToManageServices() {
    Get.toNamed('/services/manage');
  }

  // Navigate to staff management page
  void navigateToManageStaff() {
    // Navigate to staff management view
    Get.toNamed('/staffs');
  }

  // Navigate to category management page
  void navigateToManageCategories() {
    // This will be implemented to navigate to the category management page
    Get.toNamed('/service-categories');
  }

  void navigateToEditService(String id) {
    Get.toNamed("/services/edit/$id");
  }

  // Fetch all services
  Future<void> fetchServices({
    bool? isActive,
    String? categoryId,
    int? babyAge,
  }) async {
    try {
      isLoadingServices.value = true;
      serviceError.value = '';

      final fetchedServices = await _serviceRepository.getAllServices(
        isActive: isActive,
        categoryId: categoryId,
        babyAge: babyAge,
      );

      services.value = fetchedServices;
      serviceCount.value = fetchedServices.length;
    } catch (e) {
      serviceError.value = e.toString();
      _logger.error('Error fetching services: $e');
    } finally {
      isLoadingServices.value = false;
    }
  }

  // Fetch categories
  Future<void> fetchCategories() async {
    try {
      isLoadingCategories.value = true;
      categoryError.value = '';

      final categories = await _serviceCategoryRepository.getAllCategories();
      serviceCategories.value = categories;
      categoryCount.value = categories.length;
    } catch (e) {
      categoryError.value = e.toString();
      _logger.error('Error fetching service categories: $e');
    } finally {
      isLoadingCategories.value = false;
    }
  }

  // Fetch Staff
  Future<void> fetchStaff() async {
    try {
      isLoadingStaff.value = true;
      staffError.value = '';

      final staffMembers = await _staffRepository.getAllStaffs(isActive: true);
      staff.value = staffMembers;
      staffCount.value = staffMembers.length;
    } catch (e) {
      staffError.value = e.toString();
      _logger.error('Error fetching staff: $e');
    } finally {
      isLoadingStaff.value = false;
    }
  }

  // Refresh the dashboard data
  Future<void> refreshServices() async {
    await fetchServices();
  }

  Future<void> refreshCategories() async {
    await fetchCategories();
  }

  Future<void> refreshStaff() async {
    await fetchStaff();
  }

  Future<void> refreshData() async {
    await fetchAllData();
  }

  // Create a new service
  // Updated code for ServiceController createService method
  // Updated createService method with better validation
  Future<Service?> createService({
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
      isCreatingService.value = true;
      serviceError.value = '';

      // First, validate input
      if (hasPriceTiers && priceTiers != null) {
        // Create a validated copy with all required fields
        List<Map<String, dynamic>> validatedTiers = [];

        for (int i = 0; i < priceTiers.length; i++) {
          var tier = Map<String, dynamic>.from(priceTiers[i]);

          // Log what we received to debug
          _logger.debug('Processing tier $i: $tier');

          // Check for required fields (with both naming patterns)
          if ((tier['minBabyAge'] == null && tier['minAge'] == null) ||
              (tier['maxBabyAge'] == null && tier['maxAge'] == null) ||
              tier['price'] == null) {
            throw ApiException(
              message:
                  'Each price tier must have minBabyAge, maxBabyAge, and price',
            );
          }

          // Map keys if they use the alternative naming
          if (tier['minAge'] != null && tier['minBabyAge'] == null) {
            tier['minBabyAge'] = tier['minAge'];
          }
          if (tier['maxAge'] != null && tier['maxBabyAge'] == null) {
            tier['maxBabyAge'] = tier['maxAge'];
          }

          // Add tierName if not provided
          if (tier['tierName'] == null ||
              tier['tierName'].toString().trim().isEmpty) {
            tier['tierName'] = 'Tier ${i + 1}';
          }

          validatedTiers.add(tier);
        }

        // Replace original priceTiers with validated ones
        priceTiers = validatedTiers;
      }

      final service = await _serviceRepository.createService(
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

      // Add the new service to the list or refresh the list
      await fetchServices();

      Get.snackbar(
        'Sukses',
        'Layanan berhasil dibuat',
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );

      return service;
    } catch (e) {
      serviceError.value = e is ApiException ? e.message : e.toString();
      _logger.error('Error creating service: $e');

      Get.snackbar(
        'Gagal',
        serviceError.value,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );

      return null;
    } finally {
      isCreatingService.value = false;
    }
  }

  // Get service by ID
  Future<void> getServiceById(String id) async {
    try {
      isFetchingServiceDetail.value = true;
      serviceError.value = '';

      final service = await _serviceRepository.getServiceById(id);
      selectedService.value = service;
    } catch (e) {
      serviceError.value = e is ApiException ? e.message : e.toString();
      _logger.error('Error fetching service detail: $e');

      Get.snackbar(
        'Gagal',
        serviceError.value,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isFetchingServiceDetail.value = false;
    }
  }

  // Get services by category
  Future<List<Service>> getServicesByCategory(
    String categoryId, {
    int? babyAge,
  }) async {
    try {
      isLoadingServices.value = true;
      serviceError.value = '';

      final categoryServices = await _serviceRepository.getServicesByCategory(
        categoryId,
        babyAge: babyAge,
      );

      return categoryServices;
    } catch (e) {
      serviceError.value = e is ApiException ? e.message : e.toString();
      _logger.error('Error fetching services by category: $e');

      Get.snackbar(
        'Gagal',
        serviceError.value,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );

      return [];
    } finally {
      isLoadingServices.value = false;
    }
  }

  // Get service price tier
  Future<void> getServicePriceTier(String serviceId, int babyAge) async {
    try {
      isFetchingPriceTier.value = true;
      serviceError.value = '';

      final priceTier = await _serviceRepository.getServicePriceTier(
        serviceId,
        babyAge,
      );
      priceTierData.value = priceTier;
    } catch (e) {
      serviceError.value = e is ApiException ? e.message : e.toString();
      _logger.error('Error fetching price tier: $e');

      Get.snackbar(
        'Gagal',
        serviceError.value,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isFetchingPriceTier.value = false;
    }
  }

  // Update a service
  Future<Service?> updateService({
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
      isUpdatingService.value = true;
      serviceError.value = '';

      final updatedService = await _serviceRepository.updateService(
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

      // Update the list after successful update
      await fetchServices();

      // If this was the selected service, update it as well
      if (selectedService.value != null && selectedService.value!.id == id) {
        selectedService.value = updatedService;
      }

      Get.snackbar(
        'Sukses',
        'Layanan berhasil diperbarui',
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );

      return updatedService;
    } catch (e) {
      serviceError.value = e is ApiException ? e.message : e.toString();
      _logger.error('Error updating service: $e');

      Get.snackbar(
        'Gagal',
        serviceError.value,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );

      return null;
    } finally {
      isUpdatingService.value = false;
    }
  }

  // Delete a service
  Future<bool> deleteService(String id) async {
    try {
      isDeletingService.value = true;
      serviceError.value = '';

      final success = await _serviceRepository.deleteService(id);

      if (success) {
        // Remove from the list if successful
        await fetchServices();

        // Clear selected service if it was the deleted one
        if (selectedService.value != null && selectedService.value!.id == id) {
          selectedService.value = null;
        }

        Get.snackbar(
          'Sukses',
          'Layanan berhasil dihapus',
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
      }

      return success;
    } catch (e) {
      serviceError.value = e is ApiException ? e.message : e.toString();
      _logger.error('Error deleting service: $e');

      Get.snackbar(
        'Gagal',
        serviceError.value,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );

      return false;
    } finally {
      isDeletingService.value = false;
    }
  }

  // Toggle service status (active/inactive)
  Future<Service?> toggleServiceStatus(String id, bool isActive) async {
    try {
      isTogglingServiceStatus.value = true;
      serviceError.value = '';

      final updatedService = await _serviceRepository.toggleServiceStatus(
        id,
        isActive,
      );

      // Update the list after successful toggle
      await fetchServices();

      // If this was the selected service, update it as well
      if (selectedService.value != null && selectedService.value!.id == id) {
        selectedService.value = updatedService;
      }

      Get.snackbar(
        'Sukses',
        'Status layanan berhasil diubah',
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );

      return updatedService;
    } catch (e) {
      serviceError.value = e is ApiException ? e.message : e.toString();
      _logger.error('Error toggling service status: $e');

      Get.snackbar(
        'Gagal',
        serviceError.value,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );

      return null;
    } finally {
      isTogglingServiceStatus.value = false;
    }
  }

  // Clear selected service
  void clearSelectedService() {
    selectedService.value = null;
  }

  // Clear price tier data
  void clearPriceTierData() {
    priceTierData.value = null;
  }
}
