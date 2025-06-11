// lib/features/staff/views/staff_form_view.dart
import 'package:device_info_plus/device_info_plus.dart';
import 'package:emababyspa/common/theme/color_theme.dart'; // Import ColorTheme
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
    // No longer need ThemeData or ColorScheme here, will use themeController directly for consistency
    // final ThemeData theme = Theme.of(context);
    // final ColorScheme colorScheme = theme.colorScheme;

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
    final EdgeInsets inputErrorPadding = const EdgeInsets.only(
      top: 6.0,
      left: 12.0,
      bottom: 6.0,
    ); // Added bottom padding

    return MainLayout(
      child: Obx(
        () => Scaffold(
          // *** ✨ UI/UX Improvement ✨ ***
          // Applying the consistent, theme-aware background.
          backgroundColor:
              themeController.isDarkMode
                  ? ColorTheme.backgroundDark
                  : ColorTheme.background,
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
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color:
                              themeController.isDarkMode
                                  ? ColorTheme.textPrimaryDark
                                  : ColorTheme.textPrimary,
                          fontFamily: 'JosefinSans',
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Enter the details for the new staff member below.',
                        style: TextStyle(
                          fontSize: 15,
                          color:
                              themeController.isDarkMode
                                  ? ColorTheme.textSecondaryDark
                                  : ColorTheme.textSecondary,
                          fontFamily: 'JosefinSans',
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
                                      context,
                                      themeController,
                                    ),
                                child: Container(
                                  width: 120,
                                  height: 120,
                                  decoration: BoxDecoration(
                                    color:
                                        themeController.isDarkMode
                                            ? ColorTheme.surfaceDark
                                            : ColorTheme.surface,
                                    borderRadius: BorderRadius.circular(60),
                                    border: Border.all(
                                      color: (themeController.isDarkMode
                                              ? ColorTheme.primaryLightDark
                                              : ColorTheme.primary)
                                          .withOpacity(0.5),
                                      width: 2.5,
                                    ),
                                    image:
                                        profilePicture.value != null
                                            ? DecorationImage(
                                              image: FileImage(
                                                profilePicture.value!,
                                              ),
                                              fit: BoxFit.cover,
                                            )
                                            : null,
                                  ),
                                  child:
                                      profilePicture.value == null
                                          ? Icon(
                                            Icons.person_add_alt_1_rounded,
                                            size: 50,
                                            color:
                                                themeController.isDarkMode
                                                    ? ColorTheme
                                                        .textTertiaryDark
                                                    : ColorTheme.textTertiary,
                                          )
                                          : null,
                                ),
                              ),
                            ),
                            const SizedBox(height: 12),
                            TextButton.icon(
                              onPressed:
                                  () => _selectImage(
                                    profilePicture,
                                    permissionUtils,
                                    context,
                                    themeController,
                                  ),
                              icon: Obx(
                                () => Icon(
                                  profilePicture.value != null
                                      ? Icons.edit_outlined
                                      : Icons.add_a_photo_outlined,
                                  color:
                                      themeController.isDarkMode
                                          ? ColorTheme.primaryLightDark
                                          : ColorTheme.primary,
                                  size: 20,
                                ),
                              ),
                              label: Obx(
                                () => Text(
                                  profilePicture.value != null
                                      ? 'Change Picture'
                                      : 'Add Profile Picture',
                                  style: TextStyle(
                                    color:
                                        themeController.isDarkMode
                                            ? ColorTheme.primaryLightDark
                                            : ColorTheme.primary,
                                    fontWeight: FontWeight.w600,
                                    fontFamily: 'JosefinSans',
                                    fontSize: 15,
                                  ),
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
                                      color:
                                          themeController.isDarkMode
                                              ? ColorTheme.errorDark
                                              : ColorTheme.error,
                                      fontSize: 12,
                                    ),
                                  ),
                                )
                                : const SizedBox(height: fieldSpacing - 6),
                      ),

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
                                      color:
                                          themeController.isDarkMode
                                              ? ColorTheme.errorDark
                                              : ColorTheme.error,
                                      fontSize: 12,
                                    ),
                                  ),
                                )
                                : const SizedBox(height: fieldSpacing - 6),
                      ),

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
                                      color:
                                          themeController.isDarkMode
                                              ? ColorTheme.errorDark
                                              : ColorTheme.error,
                                      fontSize: 12,
                                    ),
                                  ),
                                )
                                : const SizedBox(height: fieldSpacing - 6),
                      ),

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
                          type: AppButtonType.primary,
                          size: AppButtonSize.large,
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
                                Get.back();
                              } catch (e) {
                                // Error is already handled in controller
                              }
                            }
                          },
                        ),
                      ),
                      const SizedBox(height: fieldSpacing),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ... rest of the functions (_selectImage, _isAndroid13OrAbove, etc.) remain the same
  // But I will update _selectImage to use the more modern design from StaffEditView for consistency

  Future<void> _selectImage(
    Rx<File?> profilePicture,
    PermissionUtils permissionUtils,
    BuildContext context,
    ThemeController themeController,
  ) async {
    try {
      await Get.bottomSheet(
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color:
                themeController.isDarkMode
                    ? ColorTheme.surfaceDark
                    : Colors.white,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(24),
              topRight: Radius.circular(24),
            ),
            boxShadow: [
              BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 15),
                decoration: BoxDecoration(
                  color: Colors.grey[400],
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              Text(
                'Choose Profile Picture',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color:
                      themeController.isDarkMode
                          ? ColorTheme.textPrimaryDark
                          : ColorTheme.textPrimary,
                  fontFamily: 'JosefinSans',
                ),
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildImageSourceOption(
                    icon: Icons.camera_alt_outlined,
                    label: 'Camera',
                    themeController: themeController,
                    color:
                        themeController.isDarkMode
                            ? ColorTheme.primaryLightDark
                            : ColorTheme.primary,
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
                        permissionUtils.showToast('Camera permission denied');
                      }
                    },
                  ),
                  _buildImageSourceOption(
                    icon: Icons.photo_library_outlined,
                    label: 'Gallery',
                    themeController: themeController,
                    color:
                        themeController.isDarkMode
                            ? ColorTheme.infoDark
                            : ColorTheme.info,
                    onTap: () async {
                      Get.back();
                      Permission permission;
                      if (Platform.isAndroid) {
                        permission =
                            await _isAndroid13OrAbove()
                                ? Permission.photos
                                : Permission.storage;
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
                        permissionUtils.showToast('Storage permission denied');
                      }
                    },
                  ),
                ],
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
      );
    } catch (e) {
      permissionUtils.showToast('Error selecting image: ${e.toString()}');
    }
  }

  Widget _buildImageSourceOption({
    required IconData icon,
    required String label,
    required ThemeController themeController,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(100),
                border: Border.all(color: color.withOpacity(0.3)),
              ),
              child: Icon(icon, color: color, size: 32),
            ),
            const SizedBox(height: 10),
            Text(
              label,
              style: TextStyle(
                color:
                    themeController.isDarkMode
                        ? ColorTheme.textSecondaryDark
                        : ColorTheme.textSecondary,
                fontFamily: 'JosefinSans',
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
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
        maxWidth: 1024,
        maxHeight: 1024,
      );
      if (photo != null) {
        profilePicture.value = File(photo.path);
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
        maxWidth: 1024,
        maxHeight: 1024,
      );
      if (image != null) {
        profilePicture.value = File(image.path);
      }
    } catch (e) {
      permissionUtils.showToast('Failed to select image: $e');
    }
  }
}
