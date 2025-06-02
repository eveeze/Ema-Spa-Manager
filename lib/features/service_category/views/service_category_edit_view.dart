// lib/features/service_category/views/service_category_edit_view.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:emababyspa/common/theme/color_theme.dart';
import 'package:emababyspa/common/widgets/custom_appbar.dart';
import 'package:emababyspa/common/widgets/app_button.dart';
import 'package:emababyspa/common/widgets/app_text_field.dart';
import 'package:emababyspa/common/layouts/main_layout.dart';
import 'package:emababyspa/features/service_category/controllers/service_category_controller.dart';
import 'package:emababyspa/features/theme/controllers/theme_controller.dart';
import 'package:emababyspa/utils/app_routes.dart';

class ServiceCategoryEditView extends GetView<ServiceCategoryController> {
  const ServiceCategoryEditView({super.key});

  @override
  Widget build(BuildContext context) {
    // Get the category ID from route params
    final categoryId = Get.parameters['id'] ?? '';
    Get.find<ThemeController>();

    // Form controllers - moved outside of build() for proper state management
    final nameController = TextEditingController();
    final descriptionController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadCategoryData(categoryId, nameController, descriptionController);
    });

    return GetBuilder<ThemeController>(
      builder: (themeCtrl) {
        final isDark = themeCtrl.isDarkMode;

        return MainLayout(
          // Set parent route to services untuk menjaga state bottom navbar
          parentRoute: AppRoutes.services,
          // Gunakan custom app bar
          customAppBar: CustomAppBar(
            title: 'Edit Service Category',
            showBackButton: true,
            onBackPressed: () => controller.navigateBackToServiceCategories(),
          ),
          child: PopScope(
            onPopInvokedWithResult: (didPop, result) {
              if (!didPop) {
                controller.navigateBackToServiceCategories();
              }
            },
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors:
                      isDark
                          ? [
                            ColorTheme.backgroundDark,
                            ColorTheme.backgroundDark.withOpacity(0.95),
                          ]
                          : [
                            ColorTheme.background,
                            ColorTheme.background.withOpacity(0.98),
                          ],
                ),
              ),
              child: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 16,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Enhanced Header Section
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color:
                              isDark
                                  ? ColorTheme.surfaceDark.withOpacity(0.6)
                                  : Colors.white.withOpacity(0.8),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color:
                                isDark
                                    ? ColorTheme.primaryLightDark.withOpacity(
                                      0.2,
                                    )
                                    : ColorTheme.primary.withOpacity(0.1),
                            width: 1,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color:
                                  isDark
                                      ? Colors.black.withOpacity(0.3)
                                      : ColorTheme.primary.withOpacity(0.08),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                              spreadRadius: 0,
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            // Icon Container
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors:
                                      isDark
                                          ? [
                                            ColorTheme.primaryLightDark,
                                            ColorTheme.primaryLightDark
                                                .withOpacity(0.8),
                                          ]
                                          : [
                                            ColorTheme.primary,
                                            ColorTheme.primaryDark,
                                          ],
                                ),
                                borderRadius: BorderRadius.circular(12),
                                boxShadow: [
                                  BoxShadow(
                                    color: (isDark
                                            ? ColorTheme.primaryLightDark
                                            : ColorTheme.primary)
                                        .withOpacity(0.3),
                                    blurRadius: 8,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Icon(
                                Icons.edit_outlined,
                                color: isDark ? Colors.black : Colors.white,
                                size: 24,
                              ),
                            ),
                            const SizedBox(width: 16),
                            // Header Text
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Edit Category',
                                    style: TextStyle(
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold,
                                      color:
                                          isDark
                                              ? ColorTheme.textPrimaryDark
                                              : ColorTheme.textPrimary,
                                      fontFamily: 'JosefinSans',
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Update service category details',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color:
                                          isDark
                                              ? ColorTheme.textSecondaryDark
                                              : ColorTheme.textSecondary,
                                      fontFamily: 'JosefinSans',
                                      height: 1.3,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Form Section
                      Expanded(
                        child: Obx(() {
                          if (controller.isLoading.value) {
                            return _buildLoadingState(isDark);
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
                              isDark,
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
                              isDark,
                            );
                          }

                          // Form is ready to be displayed
                          return Container(
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color:
                                  isDark
                                      ? ColorTheme.surfaceDark.withOpacity(0.6)
                                      : Colors.white.withOpacity(0.9),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color:
                                    isDark
                                        ? ColorTheme.primaryLightDark
                                            .withOpacity(0.15)
                                        : ColorTheme.primary.withOpacity(0.08),
                                width: 1,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color:
                                      isDark
                                          ? Colors.black.withOpacity(0.2)
                                          : ColorTheme.primary.withOpacity(
                                            0.06,
                                          ),
                                  blurRadius: 16,
                                  offset: const Offset(0, 6),
                                  spreadRadius: 0,
                                ),
                              ],
                            ),
                            child: Form(
                              key: formKey,
                              child: ListView(
                                children: [
                                  // Name Field
                                  _buildFormField(
                                    child: AppTextField(
                                      controller: nameController,
                                      placeholder: 'Enter category name',
                                      prefix: Icon(
                                        Icons.category_outlined,
                                        color:
                                            isDark
                                                ? ColorTheme.primaryLightDark
                                                : ColorTheme.primary,
                                      ),
                                      isRequired: true,
                                      errorText:
                                          nameController.text.isEmpty &&
                                                  formKey.currentState
                                                          ?.validate() ==
                                                      false
                                              ? 'Please enter a category name'
                                              : null,
                                    ),
                                    label: 'Category Name',
                                    isRequired: true,
                                    isDark: isDark,
                                  ),
                                  const SizedBox(height: 20),

                                  // Description Field
                                  _buildFormField(
                                    child: AppTextField(
                                      controller: descriptionController,
                                      placeholder:
                                          'Enter category description (optional)',
                                      prefix: Icon(
                                        Icons.description_outlined,
                                        color:
                                            isDark
                                                ? ColorTheme.primaryLightDark
                                                : ColorTheme.primary,
                                      ),
                                      maxLines: 3,
                                    ),
                                    label: 'Description',
                                    isDark: isDark,
                                  ),
                                  const SizedBox(height: 32),

                                  // Action Buttons Section
                                  _buildActionButtonsSection(
                                    categoryId: categoryId,
                                    nameController: nameController,
                                    descriptionController:
                                        descriptionController,
                                    formKey: formKey,
                                    isDark: isDark,
                                  ),
                                ],
                              ),
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
      },
    );
  }

  Widget _buildFormField({
    required Widget child,
    required String label,
    required bool isDark,
    bool isRequired = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color:
                    isDark
                        ? ColorTheme.textPrimaryDark
                        : ColorTheme.textPrimary,
                fontFamily: 'JosefinSans',
              ),
            ),
            if (isRequired) ...[
              const SizedBox(width: 4),
              Text(
                '*',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: ColorTheme.error,
                ),
              ),
            ],
          ],
        ),
        const SizedBox(height: 8),
        child,
      ],
    );
  }

  Widget _buildActionButtonsSection({
    required String categoryId,
    required TextEditingController nameController,
    required TextEditingController descriptionController,
    required GlobalKey<FormState> formKey,
    required bool isDark,
  }) {
    return Column(
      children: [
        // Primary Action - Update Button
        Obx(
          () => AppButton(
            text: 'Update Category',
            isLoading: controller.isFormSubmitting.value,
            onPressed: () {
              if (nameController.text.trim().isNotEmpty) {
                controller.updateServiceCategory(
                  id: categoryId,
                  name: nameController.text.trim(),
                  description: descriptionController.text.trim(),
                );
              } else {
                formKey.currentState?.validate();
              }
            },
            type: AppButtonType.primary,
            size: AppButtonSize.large,
            isFullWidth: true,
            icon: Icons.check_circle_outline,
          ),
        ),
        const SizedBox(height: 16),

        // Divider
        Container(
          height: 1,
          margin: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Colors.transparent,
                isDark
                    ? ColorTheme.primaryLightDark.withOpacity(0.3)
                    : ColorTheme.primary.withOpacity(0.2),
                Colors.transparent,
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),

        // Secondary Actions
        Row(
          children: [
            // Delete Button
            Expanded(
              child: AppButton(
                text: 'Delete',
                type: AppButtonType.secondary,
                size: AppButtonSize.medium,
                isFullWidth: true,
                icon: Icons.delete_outline,
                onPressed: () {
                  final category = controller.selectedCategory.value;
                  if (category != null) {
                    controller.showDeleteConfirmation(
                      category.id,
                      category.name,
                    );
                  }
                },
              ),
            ),
            const SizedBox(width: 12),
            // Cancel Button
            Expanded(
              child: AppButton(
                text: 'Cancel',
                type: AppButtonType.outline,
                size: AppButtonSize.medium,
                isFullWidth: true,
                icon: Icons.close_outlined,
                onPressed: () {
                  controller.navigateBackToServiceCategories();
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildLoadingState(bool isDark) {
    return Center(
      child: Container(
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          color:
              isDark
                  ? ColorTheme.surfaceDark.withOpacity(0.6)
                  : Colors.white.withOpacity(0.9),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color:
                  isDark
                      ? Colors.black.withOpacity(0.3)
                      : ColorTheme.primary.withOpacity(0.1),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: 48,
              height: 48,
              child: CircularProgressIndicator(
                strokeWidth: 3,
                valueColor: AlwaysStoppedAnimation<Color>(
                  isDark ? ColorTheme.primaryLightDark : ColorTheme.primary,
                ),
                strokeCap: StrokeCap.round,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Loading category data...',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color:
                    isDark
                        ? ColorTheme.textPrimaryDark
                        : ColorTheme.textPrimary,
                fontFamily: 'JosefinSans',
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState(
    String title,
    String message,
    VoidCallback onRetry,
    bool isDark,
  ) {
    return Center(
      child: Container(
        padding: const EdgeInsets.all(32),
        margin: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color:
              isDark
                  ? ColorTheme.surfaceDark.withOpacity(0.8)
                  : Colors.white.withOpacity(0.95),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: ColorTheme.error.withOpacity(0.2),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color:
                  isDark
                      ? Colors.black.withOpacity(0.4)
                      : ColorTheme.error.withOpacity(0.1),
              blurRadius: 20,
              offset: const Offset(0, 8),
              spreadRadius: 0,
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Error Icon
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: ColorTheme.error.withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(
                Icons.error_outline_rounded,
                size: 48,
                color: ColorTheme.error,
              ),
            ),
            const SizedBox(height: 20),

            // Error Title
            Text(
              title,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color:
                    isDark
                        ? ColorTheme.textPrimaryDark
                        : ColorTheme.textPrimary,
                fontFamily: 'JosefinSans',
              ),
            ),
            const SizedBox(height: 8),

            // Error Message
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color:
                    isDark
                        ? ColorTheme.textSecondaryDark
                        : ColorTheme.textSecondary,
                fontFamily: 'JosefinSans',
                height: 1.4,
              ),
            ),
            const SizedBox(height: 24),

            // Retry Button
            AppButton(
              text: 'Try Again',
              icon: Icons.refresh_rounded,
              onPressed: onRetry,
              type: AppButtonType.primary,
              size: AppButtonSize.medium,
            ),
          ],
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
}
