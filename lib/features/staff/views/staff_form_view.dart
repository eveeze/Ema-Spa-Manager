// lib/features/staff/views/staff_form_view.dart
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:emababyspa/common/widgets/custom_appbar.dart';
import 'package:emababyspa/common/widgets/app_button.dart';
import 'package:emababyspa/common/widgets/app_text_field.dart';
import 'package:emababyspa/common/layouts/main_layout.dart';
import 'package:emababyspa/features/staff/controllers/staff_controller.dart';
import 'package:emababyspa/utils/permission_utils.dart'; // Import PermissionUtils
import 'package:permission_handler/permission_handler.dart';
import 'package:emababyspa/features/theme/controllers/theme_controller.dart'; // Import ThemeController

class StaffFormView extends GetView<StaffController> {
  const StaffFormView({super.key});

  @override
  Widget build(BuildContext context) {
    final ThemeController themeController =
        Get.find(); // Get ThemeController instance
    final ThemeData theme = Theme.of(context); // Get current theme data
    final ColorScheme colorScheme = theme.colorScheme; // Get color scheme

    // Form controllers
    final nameController = TextEditingController();
    final emailController = TextEditingController();
    final phoneController = TextEditingController();
    final addressController = TextEditingController();

    // Form key for validation
    final formKey = GlobalKey<FormState>();

    // Observable for profile picture
    final Rx<File?> profilePicture = Rx<File?>(null);

    // Field validators
    final nameError = RxString('');
    final emailError = RxString('');
    final phoneError = RxString('');

    // Create instance of PermissionUtils
    final permissionUtils = PermissionUtils();

    // Function to validate the form
    bool validateForm() {
      bool isValid = true;
      nameError.value = '';
      emailError.value = '';
      phoneError.value = '';

      if (nameController.text.trim().isEmpty) {
        nameError.value = 'Name is required';
        isValid = false;
      }
      if (emailController.text.trim().isEmpty) {
        emailError.value = 'Email is required';
        isValid = false;
      } else if (!GetUtils.isEmail(emailController.text.trim())) {
        emailError.value = 'Enter a valid email address';
        isValid = false;
      }
      if (phoneController.text.trim().isEmpty) {
        phoneError.value = 'Phone number is required';
        isValid = false;
      }
      return isValid;
    }

    const double fieldSpacing = 18.0;
    const double sectionSpacing = 28.0;
    const EdgeInsets inputErrorPadding = EdgeInsets.only(top: 6.0, left: 12.0);

    return MainLayout(
      child: Scaffold(
        // AppBar will use its theme settings from AppTheme
        appBar: const CustomAppBar(
          title: 'Add New Staff',
          showBackButton: true,
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Form(
                key: formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Form title
                    Text(
                      'Staff Information',
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: colorScheme.onSurface,
                        // fontFamily: 'JosefinSans', // Assuming TextTheme handles this
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Enter the details for the new staff member below.',
                      style: theme.textTheme.titleSmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                        // fontFamily: 'JosefinSans',
                      ),
                    ),
                    const SizedBox(height: sectionSpacing),

                    // Profile Picture Selection
                    Center(
                      child: Column(
                        children: [
                          Obx(
                            () => GestureDetector(
                              onTap:
                                  () => _selectImage(
                                    profilePicture,
                                    permissionUtils,
                                    context, // Pass context for theming bottom sheet
                                    themeController, // Pass theme controller
                                  ),
                              child: CircleAvatar(
                                radius: 55,
                                backgroundColor: colorScheme.primaryContainer,
                                backgroundImage:
                                    profilePicture.value != null
                                        ? FileImage(profilePicture.value!)
                                        : null,
                                child:
                                    profilePicture.value == null
                                        ? Icon(
                                          Icons.person_add_alt_1_rounded,
                                          size: 50,
                                          color: colorScheme.onPrimaryContainer,
                                        )
                                        : null,
                              ),
                            ),
                          ),
                          const SizedBox(height: 10),
                          TextButton.icon(
                            onPressed:
                                () => _selectImage(
                                  profilePicture,
                                  permissionUtils,
                                  context,
                                  themeController,
                                ),
                            icon: Icon(
                              profilePicture.value != null
                                  ? Icons.edit_outlined
                                  : Icons.add_a_photo_outlined,
                              color: colorScheme.primary,
                              size: 20,
                            ),
                            label: Text(
                              profilePicture.value != null
                                  ? 'Change Picture'
                                  : 'Add Profile Picture',
                              style: theme.textTheme.labelLarge?.copyWith(
                                color: colorScheme.primary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: sectionSpacing),

                    // Name field with validation
                    AppTextField(
                      controller: nameController,
                      label: 'Full Name',
                      placeholder: 'Enter staff full name',
                      prefix: const Icon(Icons.person_outline_rounded),
                      isRequired: true,
                      onChanged: (value) {
                        if (nameError.value.isNotEmpty &&
                            value.trim().isNotEmpty) {
                          nameError.value = '';
                        }
                      },
                    ),
                    Obx(
                      () =>
                          nameError.value.isNotEmpty
                              ? Padding(
                                padding: inputErrorPadding,
                                child: Text(
                                  nameError.value,
                                  style: TextStyle(
                                    color: colorScheme.error,
                                    fontSize: 12,
                                  ),
                                ),
                              )
                              : const SizedBox.shrink(),
                    ),
                    const SizedBox(height: fieldSpacing),

                    // Email field with validation
                    AppTextField(
                      controller: emailController,
                      label: 'Email Address',
                      placeholder: 'Enter staff email',
                      prefix: const Icon(Icons.email_outlined),
                      keyboardType: TextInputType.emailAddress,
                      isRequired: true,
                      onChanged: (value) {
                        if (emailError.value.isNotEmpty &&
                            value.trim().isNotEmpty &&
                            GetUtils.isEmail(value.trim())) {
                          emailError.value = '';
                        }
                      },
                    ),
                    Obx(
                      () =>
                          emailError.value.isNotEmpty
                              ? Padding(
                                padding: inputErrorPadding,
                                child: Text(
                                  emailError.value,
                                  style: TextStyle(
                                    color: colorScheme.error,
                                    fontSize: 12,
                                  ),
                                ),
                              )
                              : const SizedBox.shrink(),
                    ),
                    const SizedBox(height: fieldSpacing),

                    // Phone number field with validation
                    AppTextField(
                      controller: phoneController,
                      label: 'Phone Number',
                      placeholder: 'Enter staff phone number',
                      prefix: const Icon(Icons.phone_outlined),
                      keyboardType: TextInputType.phone,
                      isRequired: true,
                      onChanged: (value) {
                        if (phoneError.value.isNotEmpty &&
                            value.trim().isNotEmpty) {
                          phoneError.value = '';
                        }
                      },
                    ),
                    Obx(
                      () =>
                          phoneError.value.isNotEmpty
                              ? Padding(
                                padding: inputErrorPadding,
                                child: Text(
                                  phoneError.value,
                                  style: TextStyle(
                                    color: colorScheme.error,
                                    fontSize: 12,
                                  ),
                                ),
                              )
                              : const SizedBox.shrink(),
                    ),
                    const SizedBox(height: fieldSpacing),

                    // Address field
                    AppTextField(
                      controller: addressController,
                      label: 'Address (Optional)',
                      placeholder: 'Enter staff address',
                      prefix: const Icon(Icons.location_on_outlined),
                      maxLines: 3,
                    ),
                    const SizedBox(height: sectionSpacing * 1.5),

                    // Submit button
                    Obx(
                      () => AppButton(
                        text: 'Save Staff Member',
                        isLoading: controller.isFormSubmitting.value,
                        type:
                            AppButtonType
                                .primary, // AppButton should handle its own theming
                        size: AppButtonSize.large, // Make button more prominent
                        isFullWidth: true,
                        icon: Icons.save_alt_outlined,
                        onPressed: () async {
                          if (validateForm()) {
                            try {
                              await controller.addStaff(
                                name: nameController.text.trim(),
                                email: emailController.text.trim(),
                                phoneNumber: phoneController.text.trim(),
                                address:
                                    addressController.text.trim().isNotEmpty
                                        ? addressController.text.trim()
                                        : null,
                                profilePicture: profilePicture.value,
                              );
                              Get.back(); // Navigate back after successful submission
                            } catch (e) {
                              // Error is already handled in controller via snackbar
                            }
                          }
                        },
                      ),
                    ),
                    const SizedBox(height: fieldSpacing), // For bottom padding
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSheetOption({
    required IconData iconData,
    required String label,
    required VoidCallback onTap,
    required ThemeData theme,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 15.0, horizontal: 10.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircleAvatar(
              radius: 30,
              backgroundColor: theme.colorScheme.primaryContainer,
              child: Icon(
                iconData,
                size: 28,
                color: theme.colorScheme.onPrimaryContainer,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              label,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _selectImage(
    Rx<File?> profilePicture,
    PermissionUtils permissionUtils,
    BuildContext context, // Added context
    ThemeController themeCtl, // Added theme controller
  ) async {
    final ThemeData theme = Theme.of(
      context,
    ); // Get current theme data for bottom sheet

    try {
      await Get.bottomSheet(
        Container(
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
          decoration: BoxDecoration(
            color:
                theme.bottomSheetTheme.backgroundColor ??
                theme.cardColor, // Use themed background
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Choose Profile Picture',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 25),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildSheetOption(
                    iconData: Icons.camera_alt_outlined,
                    label: 'Camera',
                    theme: theme,
                    onTap: () async {
                      Get.back();
                      final status = await Permission.camera.request();
                      if (status.isGranted) {
                        _takePicture(profilePicture, permissionUtils);
                      } else if (status.isPermanentlyDenied) {
                        permissionUtils.showPermissionDialog(
                          title: 'Camera Permission Required',
                          message:
                              'Camera permission is required to take photos. Please enable it in app settings.',
                        );
                      } else {
                        permissionUtils.showToast('Camera permission denied.');
                      }
                    },
                  ),
                  _buildSheetOption(
                    iconData: Icons.photo_library_outlined,
                    label: 'Gallery',
                    theme: theme,
                    onTap: () async {
                      Get.back();
                      Permission permission;
                      if (Platform.isAndroid) {
                        if (await _isAndroid13OrAbove()) {
                          permission = Permission.photos;
                        } else {
                          permission = Permission.storage;
                        }
                      } else {
                        permission = Permission.photos;
                      }
                      final status = await permission.request();
                      if (status.isGranted) {
                        _pickFromGallery(profilePicture, permissionUtils);
                      } else if (status.isPermanentlyDenied) {
                        permissionUtils.showPermissionDialog(
                          title: 'Storage Permission Required',
                          message:
                              'Storage permission is required to select photos. Please enable it in app settings.',
                        );
                      } else {
                        permissionUtils.showToast('Storage permission denied.');
                      }
                    },
                  ),
                ],
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
        backgroundColor: Colors.transparent, // Allow container to provide bg
        elevation: 0,
      );
    } catch (e) {
      permissionUtils.showToast('Error selecting image: ${e.toString()}');
    }
  }

  Future<bool> _isAndroid13OrAbove() async {
    if (Platform.isAndroid) {
      final deviceInfo = DeviceInfoPlugin();
      final androidInfo = await deviceInfo.androidInfo;
      return androidInfo.version.sdkInt >= 33;
    }
    return false;
  }

  Future<void> _takePicture(
    Rx<File?> profilePicture,
    PermissionUtils permissionUtils,
  ) async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? photo = await picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 80,
        maxWidth: 800,
        maxHeight: 800,
      );
      if (photo != null) {
        profilePicture.value = File(photo.path);
        permissionUtils.showToast('Image captured successfully!');
      }
    } catch (e) {
      permissionUtils.showToast('Failed to capture image: $e');
    }
  }

  Future<void> _pickFromGallery(
    Rx<File?> profilePicture,
    PermissionUtils permissionUtils,
  ) async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
        maxWidth: 800,
        maxHeight: 800,
      );
      if (image != null) {
        profilePicture.value = File(image.path);
        permissionUtils.showToast('Image selected successfully!');
      }
    } catch (e) {
      permissionUtils.showToast('Failed to select image: $e');
    }
  }
}
