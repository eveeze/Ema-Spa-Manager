// lib/features/service_category/views/service_category_edit_view.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:emababyspa/common/theme/color_theme.dart';
import 'package:emababyspa/common/widgets/custom_appbar.dart';
import 'package:emababyspa/common/widgets/app_button.dart';
import 'package:emababyspa/common/widgets/app_text_field.dart';
import 'package:emababyspa/common/layouts/main_layout.dart';
import 'package:emababyspa/features/service_category/controllers/service_category_controller.dart';

class ServiceCategoryEditView extends GetView<ServiceCategoryController> {
  const ServiceCategoryEditView({super.key});

  @override
  Widget build(BuildContext context) {
    // Get the category ID from route params
    final categoryId = Get.parameters['id'] ?? '';

    // Form controllers - moved outside of build() for proper state management
    final nameController = TextEditingController();
    final descriptionController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadCategoryData(categoryId, nameController, descriptionController);
    });

    return MainLayout(
      child: PopScope(
        onPopInvokedWithResult: (didPop, result) {
          if (!didPop) {
            controller.navigateBackToServiceCategories();
          }
        },
        child: Scaffold(
          appBar: CustomAppBar(
            title: 'Edit Service Category',
            showBackButton: true,
            onBackPressed: () => controller.navigateBackToServiceCategories(),
          ),
          body: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
                  Text(
                    'Edit Category',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: ColorTheme.textPrimary,
                      fontFamily: 'JosefinSans',
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Update service category details',
                    style: TextStyle(
                      fontSize: 14,
                      color: ColorTheme.textSecondary,
                      fontFamily: 'JosefinSans',
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Form
                  Expanded(
                    child: Obx(() {
                      if (controller.isLoading.value) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      if (controller.errorMessage.isNotEmpty) {
                        return _buildErrorState(
                          'Error',
                          controller.errorMessage.value,
                          () => _loadCategoryData(
                            categoryId,
                            nameController,
                            descriptionController,
                          ),
                        );
                      }

                      if (controller.selectedCategory.value == null) {
                        return _buildErrorState(
                          'Category Not Found',
                          'The requested category could not be found.',
                          () => _loadCategoryData(
                            categoryId,
                            nameController,
                            descriptionController,
                          ),
                        );
                      }

                      // Form is ready to be displayed
                      return Form(
                        key: formKey,
                        child: ListView(
                          children: [
                            // Name Field
                            AppTextField(
                              controller: nameController,
                              label: 'Category Name',
                              placeholder: 'Enter category name',
                              prefix: Icon(Icons.category_outlined),
                              isRequired: true,
                              errorText:
                                  nameController.text.isEmpty &&
                                          formKey.currentState?.validate() ==
                                              false
                                      ? 'Please enter a category name'
                                      : null,
                            ),
                            const SizedBox(height: 16),

                            // Description Field
                            AppTextField(
                              controller: descriptionController,
                              label: 'Description',
                              placeholder: 'Enter category description',
                              prefix: Icon(Icons.description_outlined),
                              maxLines: 3,
                            ),
                            const SizedBox(height: 32),

                            // Submit Button
                            Obx(
                              () => AppButton(
                                text: 'Update Category',
                                isLoading: controller.isFormSubmitting.value,
                                onPressed: () {
                                  if (nameController.text.trim().isNotEmpty) {
                                    controller.updateServiceCategory(
                                      id: categoryId,
                                      name: nameController.text.trim(),
                                      description:
                                          descriptionController.text.trim(),
                                    );
                                  } else {
                                    formKey.currentState?.validate();
                                  }
                                },
                                type: AppButtonType.primary,
                                isFullWidth: true,
                              ),
                            ),
                            const SizedBox(height: 16),

                            // Delete Button
                            AppButton(
                              text: 'Delete Category',
                              type: AppButtonType.secondary,
                              isFullWidth: true,
                              icon: Icons.delete_outline,
                              onPressed: () {
                                final category =
                                    controller.selectedCategory.value;
                                if (category != null) {
                                  controller.showDeleteConfirmation(
                                    category.id,
                                    category.name,
                                  );
                                }
                              },
                            ),
                            const SizedBox(height: 16),

                            // Cancel Button
                            AppButton(
                              text: 'Cancel',
                              type: AppButtonType.outline,
                              isFullWidth: true,
                              onPressed: () {
                                controller.navigateBackToServiceCategories();
                              },
                            ),
                          ],
                        ),
                      );
                    }),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // Helper method to load category data
  Future<void> _loadCategoryData(
    String categoryId,
    TextEditingController nameController,
    TextEditingController descriptionController,
  ) async {
    // Clear previous state before loading new data
    controller.errorMessage.value = '';
    controller.isLoading.value = true;

    try {
      final category = await controller.getCategoryById(categoryId);

      if (category != null) {
        nameController.text = category.name;
        descriptionController.text = category.description ?? '';
      }
    } catch (e) {
      controller.errorMessage.value = 'Failed to load category data: $e';
    } finally {
      controller.isLoading.value = false;
    }
  }

  Widget _buildErrorState(String title, String message, VoidCallback onRetry) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline_rounded, size: 64, color: ColorTheme.error),
          const SizedBox(height: 16),
          Text(
            title,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: ColorTheme.textPrimary,
              fontFamily: 'JosefinSans',
            ),
          ),
          const SizedBox(height: 8),
          Text(
            message,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: ColorTheme.textSecondary,
              fontFamily: 'JosefinSans',
            ),
          ),
          const SizedBox(height: 24),
          AppButton(
            text: 'Try Again',
            icon: Icons.refresh,
            onPressed: onRetry,
            type: AppButtonType.primary,
          ),
        ],
      ),
    );
  }
}
