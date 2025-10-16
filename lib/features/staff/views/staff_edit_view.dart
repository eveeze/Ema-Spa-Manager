// lib/features/staff/views/staff_edit_view.dart
import 'package:emababyspa/utils/app_routes.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:emababyspa/common/theme/color_theme.dart';
import 'package:emababyspa/common/widgets/app_button.dart';
import 'package:emababyspa/common/widgets/app_text_field.dart';
import 'package:emababyspa/common/layouts/main_layout.dart';
import 'package:emababyspa/features/staff/controllers/staff_controller.dart';
import 'package:emababyspa/data/models/staff.dart';
import 'package:emababyspa/utils/permission_utils.dart';
import 'package:emababyspa/utils/file_utils.dart';
import 'package:emababyspa/features/theme/controllers/theme_controller.dart';

class StaffEditView extends GetView<StaffController> {
  const StaffEditView({super.key});

  @override
  Widget build(BuildContext context) {
    // ✨ --- PERBAIKAN --- ✨
    // Gunakan MainLayout.subPage untuk struktur halaman yang benar.
    // Ini akan secara otomatis menampilkan AppBar dengan tombol kembali dan
    // mengatur bottom navigation bar dengan benar.
    return MainLayout.subPage(
      title: 'Edit Staff',
      parentRoute:
          AppRoutes
              .services, // Memberitahu MainLayout ini bagian dari tab 'Layanan'
      child: _buildFormContent(context),
    );
  }

  // ✨ --- PERBAIKAN --- ✨
  // Konten form dipindahkan ke method terpisah.
  // Method ini tidak lagi mengembalikan Scaffold atau AppBar.
  Widget _buildFormContent(BuildContext context) {
    final permissionUtils = PermissionUtils();
    final ThemeController themeController = Get.find();
    final String staffId = Get.parameters['id'] ?? '';

    final currentStaff = Rx<Staff?>(null);
    final nameController = TextEditingController();
    final emailController = TextEditingController();
    final phoneController = TextEditingController();
    final addressController = TextEditingController();

    final isActiveRx = true.obs;
    final Rx<File?> profilePicture = Rx<File?>(null);

    final formKey = GlobalKey<FormState>();
    final nameError = RxString('');
    final emailError = RxString('');
    final phoneError = RxString('');

    final isDataLoaded = false.obs;

    void loadStaffData() async {
      // (Implementasi loadStaffData tetap sama)
      try {
        controller.isLoading.value = true;

        if (staffId.isEmpty) {
          Get.snackbar(
            'Error',
            'Invalid staff ID',
            backgroundColor: (themeController.isDarkMode
                    ? ColorTheme.errorDark
                    : ColorTheme.error)
                .withValues(
                  alpha: 0.8,
                ), // Using withValues alpha:for cleaner look
            colorText:
                themeController.isDarkMode
                    ? ColorTheme.textPrimaryDark
                    : ColorTheme.textInverse,
            snackPosition: SnackPosition.BOTTOM,
            margin: const EdgeInsets.all(16),
            borderRadius: 12,
          );
          Get.back();
          return;
        }

        Staff? staff;
        if (controller.staffList.isNotEmpty) {
          staff = controller.staffList.firstWhereOrNull((s) => s.id == staffId);
        }

        staff ??= await controller.fetchStaffById(staffId);

        if (staff != null) {
          currentStaff.value = staff;
          nameController.text = staff.name;
          emailController.text = staff.email;
          phoneController.text = staff.phoneNumber;
          addressController.text = staff.address ?? '';
          isActiveRx.value = staff.isActive;
          isDataLoaded.value = true;
        } else {
          Get.snackbar(
            'Error',
            'Staff member not found',
            backgroundColor: (themeController.isDarkMode
                    ? ColorTheme.errorDark
                    : ColorTheme.error)
                .withValues(alpha: 0.8),
            colorText:
                themeController.isDarkMode
                    ? ColorTheme.textPrimaryDark
                    : ColorTheme.textInverse,
            snackPosition: SnackPosition.BOTTOM,
            margin: const EdgeInsets.all(16),
            borderRadius: 12,
          );
          Get.back();
        }
      } catch (e) {
        Get.snackbar(
          'Error',
          'Failed to load staff data: ${e.toString()}',
          backgroundColor: (themeController.isDarkMode
                  ? ColorTheme.errorDark
                  : ColorTheme.error)
              .withValues(alpha: 0.8),
          colorText:
              themeController.isDarkMode
                  ? ColorTheme.textPrimaryDark
                  : ColorTheme.textInverse,
          snackPosition: SnackPosition.BOTTOM,
          margin: const EdgeInsets.all(16),
          borderRadius: 12,
        );
        Get.back();
      } finally {
        controller.isLoading.value = false;
      }
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (staffId.isNotEmpty) {
        loadStaffData();
      }
    });

    bool validateForm() {
      // (Implementasi validateForm tetap sama)
      bool isValid = true;

      if (nameController.text.trim().isEmpty) {
        nameError.value = 'Name is required';
        isValid = false;
      } else {
        nameError.value = '';
      }

      if (emailController.text.trim().isEmpty) {
        emailError.value = 'Email is required';
        isValid = false;
      } else if (!GetUtils.isEmail(emailController.text.trim())) {
        emailError.value = 'Enter a valid email address';
        isValid = false;
      } else {
        emailError.value = '';
      }

      if (phoneController.text.trim().isEmpty) {
        phoneError.value = 'Phone number is required';
        isValid = false;
      } else {
        phoneError.value = '';
      }

      if (profilePicture.value != null) {
        if (!FileUtils.isAllowedImageType(profilePicture.value!)) {
          Get.snackbar(
            'Invalid File Type',
            'Please select a JPG, JPEG, or PNG image',
            backgroundColor: (themeController.isDarkMode
                    ? ColorTheme.errorDark
                    : ColorTheme.error)
                .withValues(alpha: 0.8),
            colorText:
                themeController.isDarkMode
                    ? ColorTheme.textPrimaryDark
                    : ColorTheme.textInverse,
            snackPosition: SnackPosition.BOTTOM,
            margin: const EdgeInsets.all(16),
            borderRadius: 12,
          );
          return false;
        }

        if (!FileUtils.isFileSizeWithinLimit(profilePicture.value!, 5.0)) {
          Get.snackbar(
            'File Too Large',
            'Profile picture should be less than 5MB',
            backgroundColor: (themeController.isDarkMode
                    ? ColorTheme.errorDark
                    : ColorTheme.error)
                .withValues(alpha: 0.8),
            colorText:
                themeController.isDarkMode
                    ? ColorTheme.textPrimaryDark
                    : ColorTheme.textInverse,
            snackPosition: SnackPosition.BOTTOM,
            margin: const EdgeInsets.all(16),
            borderRadius: 12,
          );
          return false;
        }
      }
      return isValid;
    }

    return Obx(() {
      if (controller.isLoading.value && !isDataLoaded.value) {
        return Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(
              themeController.isDarkMode
                  ? ColorTheme.primaryLightDark
                  : ColorTheme.primary,
            ),
          ),
        );
      }

      return SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Edit Staff Information',
                  style: TextStyle(
                    fontSize: 22, // Slightly larger for modern feel
                    fontWeight: FontWeight.bold,
                    color:
                        themeController.isDarkMode
                            ? ColorTheme.textPrimaryDark
                            : ColorTheme.textPrimary,
                    fontFamily: 'JosefinSans',
                  ),
                ),
                const SizedBox(height: 8),
                Obx(
                  () => Text(
                    'Update the details for ${currentStaff.value?.name ?? "this staff member"}',
                    style: TextStyle(
                      fontSize: 15, // Slightly larger
                      color:
                          themeController.isDarkMode
                              ? ColorTheme.textSecondaryDark
                              : ColorTheme.textSecondary,
                      fontFamily: 'JosefinSans',
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Center(
                  child: Column(
                    children: [
                      Obx(
                        () => GestureDetector(
                          onTap:
                              () => _selectImage(
                                profilePicture,
                                permissionUtils,
                                themeController,
                              ),
                          child: Container(
                            width: 120, // Increased size
                            height: 120, // Increased size
                            decoration: BoxDecoration(
                              color:
                                  themeController.isDarkMode
                                      ? ColorTheme.surfaceDark
                                      : ColorTheme.surface,
                              borderRadius: BorderRadius.circular(
                                60,
                              ), // Perfectly circular
                              border: Border.all(
                                color: (themeController.isDarkMode
                                        ? ColorTheme.primaryLightDark
                                        : ColorTheme.primary)
                                    .withValues(alpha: 0.5),
                                width: 2.5, // Slightly thicker border
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color:
                                      themeController.isDarkMode
                                          ? Colors.black.withValues(alpha: 0.3)
                                          : Colors.grey.withValues(alpha: 0.3),
                                  spreadRadius: 1,
                                  blurRadius: 5,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(60),
                              child:
                                  profilePicture.value != null
                                      ? Image.file(
                                        profilePicture.value!,
                                        width: 120,
                                        height: 120,
                                        fit: BoxFit.cover,
                                      )
                                      : (currentStaff.value?.profilePicture !=
                                                  null &&
                                              currentStaff
                                                  .value!
                                                  .profilePicture!
                                                  .isNotEmpty
                                          ? Image.network(
                                            currentStaff.value!.profilePicture!,
                                            width: 120,
                                            height: 120,
                                            fit: BoxFit.cover,
                                            loadingBuilder: (
                                              context,
                                              child,
                                              loadingProgress,
                                            ) {
                                              if (loadingProgress == null) {
                                                return child;
                                              }
                                              return Center(
                                                child: CircularProgressIndicator(
                                                  valueColor:
                                                      AlwaysStoppedAnimation<
                                                        Color
                                                      >(
                                                        themeController
                                                                .isDarkMode
                                                            ? ColorTheme
                                                                .primaryLightDark
                                                            : ColorTheme
                                                                .primary,
                                                      ),
                                                  value:
                                                      loadingProgress
                                                                  .expectedTotalBytes !=
                                                              null
                                                          ? loadingProgress
                                                                  .cumulativeBytesLoaded /
                                                              loadingProgress
                                                                  .expectedTotalBytes!
                                                          : null,
                                                ),
                                              );
                                            },
                                            errorBuilder:
                                                (
                                                  context,
                                                  error,
                                                  stackTrace,
                                                ) => Icon(
                                                  Icons
                                                      .person_outline, // Changed icon
                                                  size: 60, // Adjusted size
                                                  color:
                                                      themeController.isDarkMode
                                                          ? ColorTheme
                                                              .textTertiaryDark
                                                          : ColorTheme
                                                              .textTertiary,
                                                ),
                                          )
                                          : Icon(
                                            Icons
                                                .person_add_alt_1_outlined, // Changed icon for adding
                                            size: 50, // Adjusted size
                                            color:
                                                themeController.isDarkMode
                                                    ? ColorTheme
                                                        .textTertiaryDark
                                                    : ColorTheme.textTertiary,
                                          )),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextButton.icon(
                        onPressed:
                            () => _selectImage(
                              profilePicture,
                              permissionUtils,
                              themeController,
                            ),
                        icon: Icon(
                          Icons.edit_outlined, // Changed icon
                          color:
                              themeController.isDarkMode
                                  ? ColorTheme.primaryLightDark
                                  : ColorTheme.primary,
                          size: 20,
                        ),
                        label: Text(
                          profilePicture.value != null ||
                                  (currentStaff.value?.profilePicture != null &&
                                      currentStaff
                                          .value!
                                          .profilePicture!
                                          .isNotEmpty)
                              ? 'Change Picture'
                              : 'Add Profile Picture',
                          style: TextStyle(
                            color:
                                themeController.isDarkMode
                                    ? ColorTheme.primaryLightDark
                                    : ColorTheme.primary,
                            fontSize: 15,
                            fontWeight: FontWeight.w600, // Bolder
                            fontFamily: 'JosefinSans',
                          ),
                        ),
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                            side: BorderSide(
                              color: (themeController.isDarkMode
                                      ? ColorTheme.primaryLightDark
                                      : ColorTheme.primary)
                                  .withValues(alpha: 0.5),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
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
                              bottom: 8.0,
                            ),
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
                          : const SizedBox(
                            height: 16,
                          ), // Keep consistent spacing
                ),
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
                              bottom: 8.0,
                            ),
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
                          : const SizedBox(height: 16),
                ),
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
                              bottom: 8.0,
                            ),
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
                          : const SizedBox(height: 16),
                ),
                AppTextField(
                  controller: addressController,
                  label: 'Address (Optional)',
                  placeholder: 'Enter staff address',
                  prefix: const Icon(Icons.location_on_outlined),
                  maxLines: 3,
                ),
                const SizedBox(height: 24), // Increased spacing before switch
                Obx(
                  () => Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color:
                          themeController.isDarkMode
                              ? ColorTheme.surfaceDark.withValues(alpha: 0.5)
                              : ColorTheme.surface,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color:
                            themeController.isDarkMode
                                ? ColorTheme.borderDark
                                : ColorTheme.border,
                        width: 1,
                      ),
                    ),
                    child: SwitchListTile(
                      title: Text(
                        'Active Status',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600, // Bolder
                          color:
                              themeController.isDarkMode
                                  ? ColorTheme.textPrimaryDark
                                  : ColorTheme.textPrimary,
                          fontFamily: 'JosefinSans',
                        ),
                      ),
                      subtitle: Text(
                        isActiveRx.value
                            ? 'Staff member is active'
                            : 'Staff member is inactive',
                        style: TextStyle(
                          fontSize: 14,
                          color:
                              themeController.isDarkMode
                                  ? ColorTheme.textSecondaryDark
                                  : ColorTheme.textSecondary,
                          fontFamily: 'JosefinSans',
                        ),
                      ),
                      value: isActiveRx.value,
                      onChanged: (value) {
                        isActiveRx.value = value;
                      },
                      activeColor:
                          themeController.isDarkMode
                              ? ColorTheme.primaryLightDark
                              : ColorTheme.primary,
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                ),
                const SizedBox(height: 32),
                Obx(
                  () => AppButton(
                    text: 'Update Staff',
                    isLoading: controller.isFormSubmitting.value,
                    type: AppButtonType.primary,
                    size: AppButtonSize.large, // Larger button
                    isFullWidth: true,
                    icon: Icons.save_alt_outlined, // Changed icon
                    onPressed: () async {
                      if (validateForm()) {
                        await controller.updateStaff(
                          id: staffId,
                          name: nameController.text.trim(),
                          email: emailController.text.trim(),
                          phoneNumber: phoneController.text.trim(),
                          address:
                              addressController.text.trim().isNotEmpty
                                  ? addressController.text.trim()
                                  : null,
                          isActive: isActiveRx.value,
                          profilePicture: profilePicture.value,
                        );
                      } else {
                        Get.snackbar(
                          'Validation Error',
                          'Please check the form fields',
                          backgroundColor: (themeController.isDarkMode
                                  ? ColorTheme.errorDark
                                  : ColorTheme.error)
                              .withValues(alpha: 0.8),
                          colorText:
                              themeController.isDarkMode
                                  ? ColorTheme.textPrimaryDark
                                  : ColorTheme.textInverse,
                          snackPosition: SnackPosition.BOTTOM,
                          margin: const EdgeInsets.all(16),
                          borderRadius: 12,
                        );
                      }
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    });
  }

  // Sisa method (_isAndroid13OrAbove, _selectImage, dll) tetap sama
  Future<bool> _isAndroid13OrAbove() async {
    if (Platform.isAndroid) {
      final deviceInfo = DeviceInfoPlugin();
      final androidInfo = await deviceInfo.androidInfo;
      return androidInfo.version.sdkInt >= 33;
    }
    return false;
  }

  Future<void> _selectImage(
    Rx<File?> profilePicture,
    PermissionUtils permissionUtils,
    ThemeController themeController, // Pass ThemeController
  ) async {
    try {
      await Get.bottomSheet(
        Container(
          padding: const EdgeInsets.all(20), // Increased padding
          decoration: BoxDecoration(
            color:
                themeController.isDarkMode
                    ? ColorTheme.surfaceDark
                    : Colors.white, // Theme-aware background
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(24), // Larger radius
              topRight: Radius.circular(24), // Larger radius
            ),
            boxShadow: [
              // Add a subtle shadow
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.1),
                blurRadius: 10,
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                // Handle for bottom sheet
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 15),
                decoration: BoxDecoration(
                  color: Colors.grey[400],
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              Text(
                'Select Profile Picture', // Updated title
                style: TextStyle(
                  fontSize: 20, // Slightly larger
                  fontWeight: FontWeight.bold,
                  color:
                      themeController.isDarkMode
                          ? ColorTheme.textPrimaryDark
                          : ColorTheme.textPrimary,
                  fontFamily: 'JosefinSans',
                ),
              ),
              const SizedBox(height: 24), // Increased spacing
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
                            : ColorTheme.info, // Different color for gallery
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
        backgroundColor:
            Colors.transparent, // Ensure container's shadow is visible
        elevation: 0,
      );
    } catch (e) {
      permissionUtils.showToast('Error: ${e.toString()}');
    }
  }

  // Helper widget for image source options in BottomSheet
  Widget _buildImageSourceOption({
    required IconData icon,
    required String label,
    required ThemeController themeController,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16), // Add splash effect
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(16), // Increased padding
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1), // Use passed color
                borderRadius: BorderRadius.circular(100), // Fully circular
                border: Border.all(color: color.withValues(alpha: 0.3)),
              ),
              child: Icon(icon, color: color, size: 32), // Use passed color
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
                fontSize: 14, // Slightly smaller
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _takePicture(
    Rx<File?> profilePicture,
    PermissionUtils permissionUtils,
  ) async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? photo = await picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 80, // Consider higher quality for modern apps
        maxWidth: 1024, // Consider larger dimensions
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
