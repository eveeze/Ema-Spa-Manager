// lib/features/service_category/views/service_category_form_view.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:emababyspa/common/theme/color_theme.dart';
import 'package:emababyspa/common/widgets/custom_appbar.dart';
import 'package:emababyspa/common/widgets/app_button.dart';
import 'package:emababyspa/common/widgets/app_text_field.dart';
import 'package:emababyspa/common/layouts/main_layout.dart';
import 'package:emababyspa/features/service_category/controllers/service_category_controller.dart';
import 'package:emababyspa/features/theme/controllers/theme_controller.dart';

class ServiceCategoryFormView extends GetView<ServiceCategoryController> {
  const ServiceCategoryFormView({super.key});

  @override
  Widget build(BuildContext context) {
    // Form controllers
    final nameController = TextEditingController();
    final descriptionController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    // Get theme controller
    final themeController = Get.find<ThemeController>();

    return MainLayout(
      child: PopScope(
        onPopInvokedWithResult: (didPop, result) {
          if (!didPop) {
            controller.navigateBackToServiceCategories();
          }
        },
        child: Obx(
          () => Scaffold(
            backgroundColor:
                themeController.isDarkMode
                    ? ColorTheme.backgroundDark
                    : ColorTheme.background,
            appBar: CustomAppBar(
              title: 'Add Service Category',
              showBackButton: true,
              onBackPressed: () => controller.navigateBackToServiceCategories(),
            ),
            body: SafeArea(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header Section with enhanced styling
                    _buildHeaderSection(themeController),
                    const SizedBox(height: 32),

                    // Main Form Card with improved design
                    _buildFormCard(
                      themeController,
                      formKey,
                      nameController,
                      descriptionController,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeaderSection(ThemeController themeController) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Icon with gradient background
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors:
                    themeController.isDarkMode
                        ? [
                          ColorTheme.primaryLightDark.withValues(alpha: 0.2),
                          ColorTheme.primaryLightDark.withValues(alpha: 0.1),
                        ]
                        : [
                          ColorTheme.primary.withValues(alpha: 0.1),
                          ColorTheme.primary.withValues(alpha: 0.05),
                        ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color:
                    themeController.isDarkMode
                        ? ColorTheme.primaryLightDark.withValues(alpha: 0.3)
                        : ColorTheme.primary.withValues(alpha: 0.2),
                width: 1,
              ),
            ),
            child: Icon(
              Icons.category_rounded,
              size: 28,
              color:
                  themeController.isDarkMode
                      ? ColorTheme.primaryLightDark
                      : ColorTheme.primary,
            ),
          ),
          const SizedBox(height: 16),

          // Title with better typography
          Text(
            'Add New Category',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w700,
              color:
                  themeController.isDarkMode
                      ? ColorTheme.textPrimaryDark
                      : ColorTheme.textPrimary,
              fontFamily: 'JosefinSans',
              letterSpacing: -0.5,
              height: 1.2,
            ),
          ),
          const SizedBox(height: 8),

          // Subtitle with improved styling
          Container(
            padding: const EdgeInsets.symmetric(vertical: 2),
            child: Text(
              'Create a new service category to organize your services',
              style: TextStyle(
                fontSize: 16,
                color:
                    themeController.isDarkMode
                        ? ColorTheme.textSecondaryDark
                        : ColorTheme.textSecondary,
                fontFamily: 'JosefinSans',
                height: 1.4,
                letterSpacing: 0.1,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFormCard(
    ThemeController themeController,
    GlobalKey<FormState> formKey,
    TextEditingController nameController,
    TextEditingController descriptionController,
  ) {
    return Container(
      decoration: BoxDecoration(
        color:
            themeController.isDarkMode ? ColorTheme.surfaceDark : Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color:
                themeController.isDarkMode
                    ? Colors.black.withValues(alpha: 0.4)
                    : Colors.black.withValues(alpha: 0.06),
            blurRadius: themeController.isDarkMode ? 16 : 20,
            offset: const Offset(0, 4),
            spreadRadius: themeController.isDarkMode ? 0 : 2,
          ),
          if (!themeController.isDarkMode)
            BoxShadow(
              color: ColorTheme.primary.withValues(alpha: 0.04),
              blurRadius: 40,
              offset: const Offset(0, 8),
              spreadRadius: -4,
            ),
        ],
        border:
            themeController.isDarkMode
                ? Border.all(
                  color: ColorTheme.primaryLightDark.withValues(alpha: 0.1),
                  width: 1,
                )
                : null,
      ),
      child: Padding(
        padding: const EdgeInsets.all(28.0),
        child: Form(
          key: formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Form title with accent
              Row(
                children: [
                  Container(
                    width: 4,
                    height: 24,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors:
                            themeController.isDarkMode
                                ? [
                                  ColorTheme.primaryLightDark,
                                  ColorTheme.primaryLightDark.withValues(
                                    alpha: 0.7,
                                  ),
                                ]
                                : [ColorTheme.primary, ColorTheme.primaryDark],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'Category Details',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color:
                          themeController.isDarkMode
                              ? ColorTheme.textPrimaryDark
                              : ColorTheme.textPrimary,
                      fontFamily: 'JosefinSans',
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Name Field with enhanced styling
              _buildFieldLabel('Category Name', true, themeController),
              const SizedBox(height: 8),
              AppTextField(
                controller: nameController,
                placeholder: 'Enter category name',
                prefix: Icon(
                  Icons.category_outlined,
                  color:
                      themeController.isDarkMode
                          ? ColorTheme.primaryLightDark.withValues(alpha: 0.8)
                          : ColorTheme.primary.withValues(alpha: 0.8),
                ),
                isRequired: true,
                errorText:
                    nameController.text.isEmpty &&
                            formKey.currentState?.validate() == false
                        ? 'Please enter a category name'
                        : null,
              ),
              const SizedBox(height: 24),

              // Description Field with enhanced styling
              _buildFieldLabel('Description', false, themeController),
              const SizedBox(height: 8),
              AppTextField(
                controller: descriptionController,
                placeholder: 'Enter category description (optional)',
                prefix: Icon(
                  Icons.description_outlined,
                  color:
                      themeController.isDarkMode
                          ? ColorTheme.primaryLightDark.withValues(alpha: 0.8)
                          : ColorTheme.primary.withValues(alpha: 0.8),
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 32),

              // Action Buttons with improved spacing and styling
              _buildActionButtons(
                themeController,
                formKey,
                nameController,
                descriptionController,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFieldLabel(
    String label,
    bool isRequired,
    ThemeController themeController,
  ) {
    return Row(
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color:
                themeController.isDarkMode
                    ? ColorTheme.textPrimaryDark
                    : ColorTheme.textPrimary,
            fontFamily: 'JosefinSans',
            letterSpacing: 0.2,
          ),
        ),
        if (isRequired) ...[
          const SizedBox(width: 4),
          Text(
            '*',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color:
                  themeController.isDarkMode
                      ? ColorTheme.errorDark
                      : ColorTheme.error,
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildActionButtons(
    ThemeController themeController,
    GlobalKey<FormState> formKey,
    TextEditingController nameController,
    TextEditingController descriptionController,
  ) {
    return Column(
      children: [
        // Save Button with enhanced styling
        Obx(
          () => AppButton(
            text: 'Save Category',
            icon: Icons.save_rounded,
            isLoading: controller.isFormSubmitting.value,
            onPressed: () {
              if (nameController.text.trim().isNotEmpty) {
                controller.addServiceCategory(
                  name: nameController.text.trim(),
                  description: descriptionController.text.trim(),
                );
              } else {
                formKey.currentState?.validate();
              }
            },
            type: AppButtonType.secondary,
            size: AppButtonSize.large,
            isFullWidth: true,
          ),
        ),
        const SizedBox(height: 12),

        // Cancel Button with subtle styling
        AppButton(
          text: 'Cancel',
          icon: Icons.close_rounded,
          type: AppButtonType.outline,
          size: AppButtonSize.large,
          isFullWidth: true,
          onPressed: () {
            controller.navigateBackToServiceCategories();
          },
        ),
        const SizedBox(height: 12),
      ],
    );
  }
}
