// lib/features/service_category/controllers/service_category_controller.dart

import 'package:get/get.dart';
import 'package:emababyspa/data/models/service_category.dart';
import 'package:emababyspa/data/repository/service_category_repository.dart';
import 'package:emababyspa/utils/app_routes.dart';
import 'package:emababyspa/common/theme/color_theme.dart';
import 'package:emababyspa/utils/logger_utils.dart';

class ServiceCategoryController extends GetxController {
  final ServiceCategoryRepository _serviceCategoryRepository;
  final LoggerUtils _logger = LoggerUtils();

  ServiceCategoryController({
    required ServiceCategoryRepository serviceCategoryRepository,
  }) : _serviceCategoryRepository = serviceCategoryRepository;

  // Observable state
  final RxList<ServiceCategory> serviceCategories = <ServiceCategory>[].obs;
  final RxBool isLoading = false.obs;
  final RxBool isFormSubmitting = false.obs;
  final RxString errorMessage = ''.obs;
  final Rx<ServiceCategory?> selectedCategory = Rx<ServiceCategory?>(null);

  @override
  void onInit() {
    super.onInit();
    fetchAllServiceCategories();
  }

  // Fetch all service categories
  Future<void> fetchAllServiceCategories() async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      final categories = await _serviceCategoryRepository.getAllCategories();
      serviceCategories.value = categories;
    } catch (e) {
      _showErrorSnackbar("Failed to load service categories");
      errorMessage.value =
          'Failed to load service categories. Please try again.';
      _logger.error('Error fetching service categories: $e');
    } finally {
      isLoading.value = false;
    }
  }

  // Get a service category by ID
  Future<ServiceCategory?> getCategoryById(String id) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      final category = await _serviceCategoryRepository.getCategoryById(id);
      if (category != null) {
        selectedCategory.value = category;
      }
      return category;
    } catch (e) {
      _showErrorSnackbar("Failed to load service category");
      errorMessage.value = 'Failed to load service category. Please try again.';
      _logger.error('Error fetching service category: $e');
      return null;
    } finally {
      isLoading.value = false;
    }
  }

  // Function to refresh data
  void refreshData() {
    fetchAllServiceCategories();
  }

  // Navigate to add service category screen
  void navigateToAddServiceCategory() {
    Get.toNamed(AppRoutes.serviceCategoryForm);
  }

  // Navigate to edit service category screen
  void navigateToEditServiceCategory(String id) {
    Get.toNamed('/service-categories/edit/$id');
  }
  
  // Navigate to view service category details
  void navigateToViewServiceCategory(String id) {
    Get.toNamed('${AppRoutes.serviceCategoryEdit}/$id');
  }

  // Navigate back to service categories list
  void navigateBackToServiceCategories() {
    Get.until((route) => route.settings.name == AppRoutes.serviceCategoryList);
  }

  // Add a new service category
  Future<void> addServiceCategory({
    required String name,
    String? description,
  }) async {
    try {
      isFormSubmitting.value = true;
      errorMessage.value = '';

      final category = await _serviceCategoryRepository.createCategory(
        name: name,
        description: description,
      );

      if (category != null) {
        serviceCategories.add(category);
        _showSuccessSnackbar("Service category added successfully");
        // Use navigateBackToServiceCategories instead of Get.back()
        navigateBackToServiceCategories();
      }
    } catch (e) {
      _showErrorSnackbar("Failed to add service category");
      _logger.error('Error adding service category: $e');
    } finally {
      isFormSubmitting.value = false;
    }
  }

  // Update an existing service category
  Future<void> updateServiceCategory({
    required String id,
    required String name,
    String? description,
  }) async {
    try {
      isFormSubmitting.value = true;
      errorMessage.value = '';

      final category = await _serviceCategoryRepository.updateCategory(
        id: id,
        name: name,
        description: description,
      );

      if (category != null) {
        final index = serviceCategories.indexWhere((cat) => cat.id == id);
        if (index != -1) {
          serviceCategories[index] = category;
        }
        _showSuccessSnackbar("Service category updated successfully");
        // Use navigateBackToServiceCategories instead of Get.back()
        navigateBackToServiceCategories();
      }
    } catch (e) {
      _showErrorSnackbar("Failed to update service category");
      _logger.error('Error updating service category: $e');
    } finally {
      isFormSubmitting.value = false;
    }
  }

  // Delete a service category
  Future<void> deleteServiceCategory(String id) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      // Check if category has services before deleting
      final hasServices = await _serviceCategoryRepository.categoryHasServices(
        id,
      );
      if (hasServices) {
        _showWarningSnackbar(
          "Cannot delete category with associated services",
          duration: const Duration(seconds: 4),
        );
        return;
      }

      final success = await _serviceCategoryRepository.deleteCategory(id);
      if (success) {
        // Remove from the list if deleted successfully
        serviceCategories.removeWhere((category) => category.id == id);
        _showSuccessSnackbar("Service category deleted successfully");
        // Navigate back to service categories after deletion
        navigateBackToServiceCategories();
      } else {
        _showErrorSnackbar("Failed to delete service category");
      }
    } catch (e) {
      _showErrorSnackbar("Failed to delete service category");
      _logger.error('Error deleting service category: $e');
    } finally {
      isLoading.value = false;
    }
  }

  // Confirm delete dialog
  void showDeleteConfirmation(String id, String categoryName) {
    Get.defaultDialog(
      title: "Confirm Delete",
      middleText:
          "Are you sure you want to delete the category '$categoryName'?",
      textConfirm: "Delete",
      textCancel: "Cancel",
      confirmTextColor: ColorTheme.primary,
      cancelTextColor: ColorTheme.secondary,
      buttonColor: ColorTheme.error,
      barrierDismissible: false,
      onConfirm: () {
        Get.back(); // Close dialog
        deleteServiceCategory(id);
      },
    );
  }

  // Helper methods for showing snackbars
  void _showSuccessSnackbar(String message, {Duration? duration}) {
    Get.snackbar(
      "Success",
      message,
      backgroundColor: ColorTheme.success,
      colorText: ColorTheme.primary,
      duration: duration ?? const Duration(seconds: 3),
    );
  }

  void _showErrorSnackbar(String message, {Duration? duration}) {
    Get.snackbar(
      "Error",
      message,
      backgroundColor: ColorTheme.error,
      colorText: ColorTheme.primary,
      duration: duration ?? const Duration(seconds: 3),
    );
  }

  void _showWarningSnackbar(String message, {Duration? duration}) {
    Get.snackbar(
      "Warning",
      message,
      backgroundColor: ColorTheme.warning,
      colorText: ColorTheme.primary,
      duration: duration ?? const Duration(seconds: 3),
    );
  }
}
