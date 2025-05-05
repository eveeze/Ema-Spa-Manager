// lib/features/staff/views/staff_form_view.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:emababyspa/common/theme/color_theme.dart';
import 'package:emababyspa/common/widgets/custom_appbar.dart';
import 'package:emababyspa/common/widgets/app_button.dart';
import 'package:emababyspa/common/widgets/app_text_field.dart';
import 'package:emababyspa/common/layouts/main_layout.dart';
import 'package:emababyspa/features/staff/controllers/staff_controller.dart';

class StaffFormView extends GetView<StaffController> {
  const StaffFormView({super.key});

  @override
  Widget build(BuildContext context) {
    // Form controllers
    final nameController = TextEditingController();
    final emailController = TextEditingController();
    final phoneController = TextEditingController();
    final addressController = TextEditingController();

    // Form key for validation
    final formKey = GlobalKey<FormState>();

    return MainLayout(
      child: Scaffold(
        appBar: const CustomAppBar(title: 'Add Staff', showBackButton: true),
        body: SafeArea(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Form title
                    Text(
                      'Staff Information',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: ColorTheme.textPrimary,
                        fontFamily: 'JosefinSans',
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Enter the details for the new staff member',
                      style: TextStyle(
                        fontSize: 14,
                        color: ColorTheme.textSecondary,
                        fontFamily: 'JosefinSans',
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Name field
                    AppTextField(
                      controller: nameController,
                      label: 'Name',
                      placeholder: 'Enter staff name',
                      prefix: Icon(Icons.person_outline_rounded),
                      isRequired: true,
                      helperText:
                          nameController.text.isEmpty
                              ? 'Please enter staff name'
                              : null,
                    ),
                    const SizedBox(height: 16),

                    // Email field
                    AppTextField(
                      controller: emailController,
                      label: 'Email',
                      placeholder: 'Enter staff email',
                      prefix: Icon(Icons.email_outlined),
                      keyboardType: TextInputType.emailAddress,
                      isRequired: true,
                      helperText:
                          !GetUtils.isEmail(emailController.text) &&
                                  emailController.text.isNotEmpty
                              ? 'Please enter a valid email'
                              : null,
                    ),
                    const SizedBox(height: 16),

                    // Phone number field
                    AppTextField(
                      controller: phoneController,
                      label: 'Phone Number',
                      placeholder: 'Enter staff phone number',
                      prefix: Icon(Icons.phone_outlined),
                      keyboardType: TextInputType.phone,
                      isRequired: true,
                      helperText:
                          phoneController.text.isEmpty
                              ? 'Please enter staff phone number'
                              : null,
                    ),
                    const SizedBox(height: 16),

                    // Address field
                    AppTextField(
                      controller: addressController,
                      label: 'Address (Optional)',
                      placeholder: 'Enter staff address',
                      prefix: Icon(Icons.location_on_outlined),
                      maxLines: 3,
                    ),
                    const SizedBox(height: 32),

                    // Submit button
                    Obx(
                      () => AppButton(
                        text: 'Add Staff',
                        isLoading: controller.isFormSubmitting.value,
                        type: AppButtonType.primary,
                        size: AppButtonSize.medium,
                        isFullWidth: true,
                        icon: Icons.person_add,
                        onPressed: () async {
                          // Simple validation before form submission
                          if (nameController.text.trim().isEmpty ||
                              emailController.text.trim().isEmpty ||
                              !GetUtils.isEmail(emailController.text.trim()) ||
                              phoneController.text.trim().isEmpty) {
                            // Show validation message
                            Get.snackbar(
                              'Validation Error',
                              'Please check the form fields',
                              backgroundColor: ColorTheme.error.withOpacity(
                                0.1,
                              ),
                              colorText: ColorTheme.error,
                            );
                            return;
                          }

                          await controller.addStaff(
                            name: nameController.text.trim(),
                            email: emailController.text.trim(),
                            phoneNumber: phoneController.text.trim(),
                            address:
                                addressController.text.trim().isNotEmpty
                                    ? addressController.text.trim()
                                    : null,
                          );
                        },
                      ),
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
}
