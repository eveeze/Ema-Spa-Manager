// lib/features/service_category/views/service_category_form_view.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:emababyspa/common/theme/color_theme.dart';
import 'package:emababyspa/common/widgets/custom_appbar.dart';
import 'package:emababyspa/common/widgets/app_button.dart';
import 'package:emababyspa/common/widgets/app_text_field.dart';
import 'package:emababyspa/common/layouts/main_layout.dart';
import 'package:emababyspa/features/service_category/controllers/service_category_controller.dart';

class ServiceCategoryFormView extends GetView<ServiceCategoryController> {
  const ServiceCategoryFormView({super.key});

  @override
  Widget build(BuildContext context) {
    // Form controllers
    final nameController = TextEditingController();
    final descriptionController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    return MainLayout(
      child: PopScope(
        onPopInvokedWithResult: (didPop, result) {
          if (!didPop) {
            controller.navigateBackToServiceCategories();
          }
        },
        child: Scaffold(
          appBar: CustomAppBar(
            title: 'Add Service Category',
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
                    'Add New Category',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: ColorTheme.textPrimary,
                      fontFamily: 'JosefinSans',
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Create a new service category',
                    style: TextStyle(
                      fontSize: 14,
                      color: ColorTheme.textSecondary,
                      fontFamily: 'JosefinSans',
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Form
                  Expanded(
                    child: Form(
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
                              text: 'Save Category',
                              isLoading: controller.isFormSubmitting.value,
                              onPressed: () {
                                if (nameController.text.trim().isNotEmpty) {
                                  controller.addServiceCategory(
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
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
