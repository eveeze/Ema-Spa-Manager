// lib/features/service_category/controllers/service_category_controller.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:emababyspa/data/models/service_category.dart';
import 'package:emababyspa/data/repository/service_category_repository.dart';
import 'package:emababyspa/utils/app_routes.dart';
import 'package:emababyspa/common/theme/color_theme.dart';
import 'package:emababyspa/utils/logger_utils.dart';
import 'package:emababyspa/common/widgets/delete_confirmation_dialog.dart';

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

  // lock biar dialog confirm tidak bisa spam tap (dan mengurangi glitch overlay)
  final RxBool _isDeleting = false.obs;

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
      serviceCategories.assignAll(categories);
    } catch (e) {
      errorMessage.value =
          'Failed to load service categories. Please try again.';
      _logger.error('Error fetching service categories: $e');
      _showErrorSnackbar("Failed to load service categories");
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
      selectedCategory.value = category;
      return category;
    } catch (e) {
      errorMessage.value = 'Failed to load service category. Please try again.';
      _logger.error('Error fetching service category: $e');
      _showErrorSnackbar("Failed to load service category");
      return null;
    } finally {
      isLoading.value = false;
    }
  }

  // Refresh
  Future<void> refreshData() async {
    await fetchAllServiceCategories();
  }

  // Back helper: pop 1 page (page saja, bukan untuk dialog)
  void popPage({dynamic result}) {
    Get.back(result: result);
  }

  // =========================
  // NAVIGATION (snackbar result ditangani di LIST) ✅
  // =========================

  Future<void> navigateToAddServiceCategory() async {
    final result = await Get.toNamed(AppRoutes.serviceCategoryForm);

    if (result is Map && result['success'] == true) {
      final msg = result['message']?.toString() ?? 'Berhasil';

      // ✅ tampilkan snackbar setelah route pop settle
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _showSuccessSnackbar(msg);
      });
    }
  }

  Future<void> navigateToEditServiceCategory(String id) async {
    final result = await Get.toNamed('/service-categories/edit/$id');

    if (result is Map && result['success'] == true) {
      final msg = result['message']?.toString() ?? 'Berhasil';

      // ✅ tampilkan snackbar setelah route pop settle
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _showSuccessSnackbar(msg);
      });
    }
  }

  Future<dynamic> navigateToViewServiceCategory(String id) async {
    return Get.toNamed('${AppRoutes.serviceCategoryEdit}/$id');
  }

  // =========================
  // CRUD
  // =========================

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
        // update list lokal biar list langsung update
        serviceCategories.add(category);

        // snackbar jangan di sini, biar tidak hilang karena pop
        popPage(
          result: {'success': true, 'message': 'Kategori berhasil ditambahkan'},
        );
      } else {
        _showErrorSnackbar("Failed to add service category");
      }
    } catch (e) {
      _logger.error('Error adding service category: $e');
      _showErrorSnackbar("Failed to add service category");
    } finally {
      isFormSubmitting.value = false;
    }
  }

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
          serviceCategories.refresh();
        }

        popPage(
          result: {'success': true, 'message': 'Kategori berhasil diperbarui'},
        );
      } else {
        _showErrorSnackbar("Failed to update service category");
      }
    } catch (e) {
      _logger.error('Error updating service category: $e');
      _showErrorSnackbar("Failed to update service category");
    } finally {
      isFormSubmitting.value = false;
    }
  }

  Future<void> deleteServiceCategory(String id) async {
    // anti spam delete
    if (_isDeleting.value) return;

    try {
      _isDeleting.value = true;
      isLoading.value = true;
      errorMessage.value = '';

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
        serviceCategories.removeWhere((category) => category.id == id);

        // delete dari list/dialog -> snackbar aman
        _showSuccessSnackbar("Kategori berhasil dihapus");
      } else {
        _showErrorSnackbar("Failed to delete service category");
      }
    } catch (e) {
      _logger.error('Error deleting service category: $e');
      _showErrorSnackbar("Failed to delete service category");
    } finally {
      isLoading.value = false;
      _isDeleting.value = false;
    }
  }

  // =========================
  // DIALOG DELETE ✅ FIX: selalu tutup dialog dulu
  // =========================

  void showDeleteConfirmation(String id, String categoryName) {
    DeleteConfirmationDialog.show(
      title: "Hapus Kategori",
      itemName: categoryName,
      message:
          "Yakin ingin menghapus kategori ini? Tindakan ini tidak dapat dibatalkan.",
      confirmText: "Hapus",
      cancelText: "Batal",
      icon: Icons.category_outlined,
      onConfirm: () async {
        // ✅ tutup dialog konfirmasi secara pasti
        if (Get.isOverlaysOpen) Get.back();

        // ✅ delay kecil biar overlay settle, mengurangi glitch “kadang ketutup kadang tidak”
        await Future.delayed(const Duration(milliseconds: 80));

        await deleteServiceCategory(id);
      },
    );
  }

  // =========================
  // SNACKBAR HELPERS
  // =========================

  void _showSuccessSnackbar(String message, {Duration? duration}) {
    if (Get.isSnackbarOpen) Get.closeAllSnackbars();

    Get.snackbar(
      "Berhasil",
      message,
      snackPosition: SnackPosition.TOP,
      backgroundColor: ColorTheme.success.withValues(alpha: 0.14),
      colorText: ColorTheme.success,
      duration: duration ?? const Duration(seconds: 3),
      margin: const EdgeInsets.all(14),
      borderRadius: 16,
      icon: const Icon(Icons.check_circle_rounded, color: ColorTheme.success),
      shouldIconPulse: false,
    );
  }

  void _showErrorSnackbar(String message, {Duration? duration}) {
    if (Get.isSnackbarOpen) Get.closeAllSnackbars();

    Get.snackbar(
      "Gagal",
      message,
      snackPosition: SnackPosition.TOP,
      backgroundColor: ColorTheme.error.withValues(alpha: 0.14),
      colorText: ColorTheme.error,
      duration: duration ?? const Duration(seconds: 3),
      margin: const EdgeInsets.all(14),
      borderRadius: 16,
      icon: const Icon(Icons.error_rounded, color: ColorTheme.error),
      shouldIconPulse: false,
    );
  }

  void _showWarningSnackbar(String message, {Duration? duration}) {
    if (Get.isSnackbarOpen) Get.closeAllSnackbars();

    Get.snackbar(
      "Peringatan",
      message,
      snackPosition: SnackPosition.TOP,
      backgroundColor: ColorTheme.warning.withValues(alpha: 0.14),
      colorText: ColorTheme.warning,
      duration: duration ?? const Duration(seconds: 3),
      margin: const EdgeInsets.all(14),
      borderRadius: 16,
      icon: const Icon(Icons.warning_amber_rounded, color: ColorTheme.warning),
      shouldIconPulse: false,
    );
  }
}
