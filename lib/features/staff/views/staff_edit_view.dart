// lib/features/staff/views/staff_edit_view.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:emababyspa/common/theme/color_theme.dart';
import 'package:emababyspa/common/widgets/custom_appbar.dart';
import 'package:emababyspa/common/widgets/app_button.dart';
import 'package:emababyspa/common/widgets/app_text_field.dart';
import 'package:emababyspa/common/layouts/main_layout.dart';
import 'package:emababyspa/features/staff/controllers/staff_controller.dart';
import 'package:emababyspa/data/models/staff.dart';

class StaffEditView extends GetView<StaffController> {
  const StaffEditView({super.key});

  @override
  Widget build(BuildContext context) {
    // Get the staff ID from route parameters
    final String staffId = Get.parameters['id'] ?? '';

    // Find the staff member in the controller's list
    final Staff? staff = controller.staffList.firstWhereOrNull(
      (staff) => staff.id == staffId,
    );

    if (staff == null) {
      // If staff not found, show an error and go back
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Get.snackbar(
          'Error',
          'Staff member not found',
          backgroundColor: ColorTheme.error.withOpacity(0.1),
          colorText: ColorTheme.error,
        );
        Get.back();
      });

      return const CircularProgressIndicator();
    }

    // Form controllers with initial values
    final nameController = TextEditingController(text: staff.name);
    final emailController = TextEditingController(text: staff.email);
    final phoneController = TextEditingController(text: staff.phoneNumber);
    final addressController = TextEditingController(text: staff.address ?? '');

    // Status flag
    final isActiveRx = staff.isActive.obs;

    // Form key for validation
    final formKey = GlobalKey<FormState>();

    return MainLayout(
      child: Scaffold(
        appBar: const CustomAppBar(title: 'Edit Staff', showBackButton: true),
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
                      'Edit Staff Information',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: ColorTheme.textPrimary,
                        fontFamily: 'JosefinSans',
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Update the details for this staff member',
                      style: TextStyle(
                        fontSize: 14,
                        color: ColorTheme.textSecondary,
                        fontFamily: 'JosefinSans',
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Profile picture placeholder
                    Center(
                      child: Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          color: ColorTheme.info.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(50),
                        ),
                        child:
                            staff.profilePicture != null &&
                                    staff.profilePicture!.isNotEmpty
                                ? ClipRRect(
                                  borderRadius: BorderRadius.circular(50),
                                  child: Image.network(
                                    staff.profilePicture!,
                                    width: 100,
                                    height: 100,
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) {
                                      return Icon(
                                        Icons.person,
                                        size: 50,
                                        color: ColorTheme.info,
                                      );
                                    },
                                  ),
                                )
                                : Icon(
                                  Icons.person,
                                  size: 50,
                                  color: ColorTheme.info,
                                ),
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
                    const SizedBox(height: 16),

                    // Status toggle
                    Obx(
                      () => SwitchListTile(
                        title: Text(
                          'Active Status',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color: ColorTheme.textPrimary,
                            fontFamily: 'JosefinSans',
                          ),
                        ),
                        subtitle: Text(
                          isActiveRx.value
                              ? 'Staff member is active'
                              : 'Staff member is inactive',
                          style: TextStyle(
                            fontSize: 14,
                            color: ColorTheme.textSecondary,
                            fontFamily: 'JosefinSans',
                          ),
                        ),
                        value: isActiveRx.value,
                        onChanged: (value) {
                          isActiveRx.value = value;
                        },
                        activeColor: ColorTheme.primary,
                        contentPadding: EdgeInsets.zero,
                      ),
                    ),
                    const SizedBox(height: 32),

                    // Submit button
                    Obx(
                      () => AppButton(
                        text: 'Update Staff',
                        isLoading: controller.isFormSubmitting.value,
                        type: AppButtonType.primary,
                        size: AppButtonSize.medium,
                        isFullWidth: true,
                        icon: Icons.save,
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

                          await controller.updateStaff(
                            id: staff.id,
                            name: nameController.text.trim(),
                            email: emailController.text.trim(),
                            phoneNumber: phoneController.text.trim(),
                            address:
                                addressController.text.trim().isNotEmpty
                                    ? addressController.text.trim()
                                    : null,
                            isActive: isActiveRx.value,
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
