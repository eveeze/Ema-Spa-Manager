// lib/features/staff/views/staff_form_view.dart
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:emababyspa/common/theme/color_theme.dart';
import 'package:emababyspa/common/widgets/custom_appbar.dart';
import 'package:emababyspa/common/widgets/app_button.dart';
import 'package:emababyspa/common/widgets/app_text_field.dart';
import 'package:emababyspa/common/layouts/main_layout.dart';
import 'package:emababyspa/features/staff/controllers/staff_controller.dart';
import 'package:emababyspa/utils/permission_utils.dart'; // Import PermissionUtils
import 'package:permission_handler/permission_handler.dart';

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

      // Validate name
      if (nameController.text.trim().isEmpty) {
        nameError.value = 'Name is required';
        isValid = false;
      } else {
        nameError.value = '';
      }

      // Validate email
      if (emailController.text.trim().isEmpty) {
        emailError.value = 'Email is required';
        isValid = false;
      } else if (!GetUtils.isEmail(emailController.text.trim())) {
        emailError.value = 'Enter a valid email address';
        isValid = false;
      } else {
        emailError.value = '';
      }

      // Validate phone
      if (phoneController.text.trim().isEmpty) {
        phoneError.value = 'Phone number is required';
        isValid = false;
      } else {
        phoneError.value = '';
      }

      return isValid;
    }

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
                                  ),
                              child: Container(
                                width: 100,
                                height: 100,
                                decoration: BoxDecoration(
                                  color: ColorTheme.info.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(50),
                                  border: Border.all(
                                    color: ColorTheme.primary.withValues(
                                      alpha: 0.3,
                                    ),
                                    width: 2,
                                  ),
                                ),
                                child:
                                    profilePicture.value != null
                                        ? ClipRRect(
                                          borderRadius: BorderRadius.circular(
                                            50,
                                          ),
                                          child: Image.file(
                                            profilePicture.value!,
                                            width: 100,
                                            height: 100,
                                            fit: BoxFit.cover,
                                          ),
                                        )
                                        : Icon(
                                          Icons.person,
                                          size: 50,
                                          color: ColorTheme.info,
                                        ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          TextButton.icon(
                            onPressed:
                                () => _selectImage(
                                  profilePicture,
                                  permissionUtils,
                                ),
                            icon: Icon(
                              Icons.add_a_photo,
                              color: ColorTheme.primary,
                              size: 18,
                            ),
                            label: Text(
                              profilePicture.value != null
                                  ? 'Change Profile Picture'
                                  : 'Add Profile Picture',
                              style: TextStyle(
                                color: ColorTheme.primary,
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Name field with validation
                    AppTextField(
                      controller: nameController,
                      label: 'Name',
                      placeholder: 'Enter staff name',
                      prefix: const Icon(Icons.person_outline_rounded),
                      isRequired: true,
                      onChanged: (value) {
                        if (nameError.value.isNotEmpty) {
                          if (value.trim().isNotEmpty) {
                            nameError.value = '';
                          }
                        }
                      },
                    ),
                    Obx(
                      () =>
                          nameError.value.isNotEmpty
                              ? Padding(
                                padding: const EdgeInsets.only(
                                  top: 4.0,
                                  left: 12.0,
                                ),
                                child: Text(
                                  nameError.value,
                                  style: TextStyle(
                                    color: ColorTheme.error,
                                    fontSize: 12,
                                  ),
                                ),
                              )
                              : const SizedBox.shrink(),
                    ),
                    const SizedBox(height: 16),

                    // Email field with validation
                    AppTextField(
                      controller: emailController,
                      label: 'Email',
                      placeholder: 'Enter staff email',
                      prefix: const Icon(Icons.email_outlined),
                      keyboardType: TextInputType.emailAddress,
                      isRequired: true,
                      onChanged: (value) {
                        if (emailError.value.isNotEmpty) {
                          if (value.trim().isNotEmpty &&
                              GetUtils.isEmail(value.trim())) {
                            emailError.value = '';
                          }
                        }
                      },
                    ),
                    Obx(
                      () =>
                          emailError.value.isNotEmpty
                              ? Padding(
                                padding: const EdgeInsets.only(
                                  top: 4.0,
                                  left: 12.0,
                                ),
                                child: Text(
                                  emailError.value,
                                  style: TextStyle(
                                    color: ColorTheme.error,
                                    fontSize: 12,
                                  ),
                                ),
                              )
                              : const SizedBox.shrink(),
                    ),
                    const SizedBox(height: 16),

                    // Phone number field with validation
                    AppTextField(
                      controller: phoneController,
                      label: 'Phone Number',
                      placeholder: 'Enter staff phone number',
                      prefix: const Icon(Icons.phone_outlined),
                      keyboardType: TextInputType.phone,
                      isRequired: true,
                      onChanged: (value) {
                        if (phoneError.value.isNotEmpty) {
                          if (value.trim().isNotEmpty) {
                            phoneError.value = '';
                          }
                        }
                      },
                    ),
                    Obx(
                      () =>
                          phoneError.value.isNotEmpty
                              ? Padding(
                                padding: const EdgeInsets.only(
                                  top: 4.0,
                                  left: 12.0,
                                ),
                                child: Text(
                                  phoneError.value,
                                  style: TextStyle(
                                    color: ColorTheme.error,
                                    fontSize: 12,
                                  ),
                                ),
                              )
                              : const SizedBox.shrink(),
                    ),
                    const SizedBox(height: 16),

                    // Address field
                    AppTextField(
                      controller: addressController,
                      label: 'Address (Optional)',
                      placeholder: 'Enter staff address',
                      prefix: const Icon(Icons.location_on_outlined),
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
                              // Navigate to staff view after successful submission
                              Get.back();
                            } catch (e) {
                              // Error is already handled in controller
                            }
                          }
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

  Future<void> _selectImage(
    Rx<File?> profilePicture,
    PermissionUtils permissionUtils,
  ) async {
    try {
      // Show a bottom sheet to select image source
      await Get.bottomSheet(
        Container(
          padding: const EdgeInsets.all(16),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Select Image Source',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: ColorTheme.textPrimary,
                  fontFamily: 'JosefinSans',
                ),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  // Camera option
                  InkWell(
                    onTap: () async {
                      Get.back();

                      // Request camera permission
                      final status = await Permission.camera.request();

                      if (status.isGranted) {
                        _takePicture(profilePicture, permissionUtils);
                      } else if (status.isPermanentlyDenied) {
                        // Show dialog if permanently denied
                        permissionUtils.showPermissionDialog(
                          title: 'Camera Permission Required',
                          message:
                              'Camera permission is required to take photos. Please enable it in app settings.',
                          cancelButtonText: 'Cancel',
                          settingsButtonText: 'Open Settings',
                        );
                      } else {
                        permissionUtils.showToast('Camera permission denied');
                      }
                    },
                    child: Column(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: ColorTheme.primary.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(50),
                          ),
                          child: Icon(
                            Icons.camera_alt,
                            color: ColorTheme.primary,
                            size: 30,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Camera',
                          style: TextStyle(
                            color: ColorTheme.textPrimary,
                            fontFamily: 'JosefinSans',
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Gallery option
                  InkWell(
                    onTap: () async {
                      Get.back();

                      // Request storage permission for Android below 13 or photos for iOS and Android 13+
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
                        // Show dialog if permanently denied
                        permissionUtils.showPermissionDialog(
                          title: 'Storage Permission Required',
                          message:
                              'Storage permission is required to select photos. Please enable it in app settings.',
                          cancelButtonText: 'Cancel',
                          settingsButtonText: 'Open Settings',
                        );
                      } else {
                        permissionUtils.showToast('Storage permission denied');
                      }
                    },
                    child: Column(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: ColorTheme.info.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(50),
                          ),
                          child: Icon(
                            Icons.photo_library,
                            color: ColorTheme.info,
                            size: 30,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Gallery',
                          style: TextStyle(
                            color: ColorTheme.textPrimary,
                            fontFamily: 'JosefinSans',
                          ),
                        ),
                      ],
                    ),
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
      permissionUtils.showToast('Error: ${e.toString()}');
    }
  }

  // Helper method to check if device is running Android 13 or above
  Future<bool> _isAndroid13OrAbove() async {
    if (Platform.isAndroid) {
      final deviceInfo = DeviceInfoPlugin();
      final androidInfo = await deviceInfo.androidInfo;
      return androidInfo.version.sdkInt >= 33; // Android 13 is API level 33
    }
    return false;
  }

  // Helper method to take picture from camera
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
        permissionUtils.showToast('Image captured successfully');
      }
    } catch (e) {
      permissionUtils.showToast('Failed to capture image: $e');
    }
  }

  // Helper method to pick image from gallery
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
        permissionUtils.showToast('Image selected successfully');
      }
    } catch (e) {
      permissionUtils.showToast('Failed to select image: $e');
    }
  }
}
