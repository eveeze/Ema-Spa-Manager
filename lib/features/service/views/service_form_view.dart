// lib/features/service/views/service_form_view.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:emababyspa/common/theme/color_theme.dart'; // Asumsi path ini benar
import 'package:emababyspa/common/widgets/custom_appbar.dart'; // Asumsi path ini benar
import 'package:emababyspa/common/layouts/main_layout.dart'; // Asumsi path ini benar
import 'package:emababyspa/features/service/controllers/service_controller.dart'; // Asumsi path ini benar
import 'package:emababyspa/common/widgets/app_button.dart'; // Asumsi path ini benar
import 'package:emababyspa/common/widgets/app_text_field.dart'; // Asumsi path ini benar
import 'package:emababyspa/features/theme/controllers/theme_controller.dart'; // Import ThemeController

class ServiceFormView extends GetView<ServiceController> {
  ServiceFormView({super.key});

  final formKey = GlobalKey<FormState>();
  final nameController = TextEditingController();
  final descriptionController = TextEditingController();
  final durationController = TextEditingController();
  final priceController = TextEditingController();
  final minAgeController = TextEditingController();
  final maxAgeController = TextEditingController();

  final RxString selectedCategoryId = ''.obs;
  final RxBool hasPriceTiers = false.obs;
  final RxBool isImageSelected = false.obs;
  final Rx<File?> imageFile = Rx<File?>(null);
  final RxList<Map<String, dynamic>> priceTiers = <Map<String, dynamic>>[].obs;

  final RxMap<int, Map<String, TextEditingController>> priceTierControllers =
      <int, Map<String, TextEditingController>>{}.obs;

  // Akses ThemeController
  final ThemeController themeController = Get.find<ThemeController>();

  @override
  Widget build(BuildContext context) {
    if (priceTiers.isEmpty) {
      priceTiers.add({'minAge': 0, 'maxAge': 12, 'price': 0.0});
      _initializePriceTierControllers(0);
    }

    // Warna dinamis berdasarkan tema
    final bool isDark = themeController.isDarkMode;
    final Color scaffoldBackgroundColor =
        isDark ? const Color(0xFF121212) : Colors.grey[50]!;
    final Color cardBackgroundColor =
        isDark ? const Color(0xFF1E1E1E) : Colors.white;
    final Color defaultTextColor =
        isDark
            ? Colors.white.withValues(alpha: 0.87) // Menggunakan withValues
            : Colors.black.withValues(alpha: 0.87); // Menggunakan withValues
    final Color secondaryTextColor =
        isDark
            ? Colors.white.withValues(alpha: 0.60)
            : Colors.grey[600]!; // Menggunakan withValues
    final Color shadowColor =
        isDark
            ? Colors.black.withValues(alpha: 0.5)
            : Colors.black.withValues(alpha: 0.05); // Menggunakan withValues
    final Color primaryColorWithOpacityLow = ColorTheme.primary.withValues(
      // Menggunakan withValues
      alpha: isDark ? 0.2 : 0.1,
    );

    return MainLayout(
      child: Scaffold(
        backgroundColor: scaffoldBackgroundColor,
        appBar: const CustomAppBar(
          title: 'Add New Service',
          showBackButton: true,
        ),
        body: SafeArea(
          child: Obx(() {
            if (controller.isLoadingCategories.value ||
                controller.isLoadingStaff.value) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: cardBackgroundColor,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: shadowColor,
                            blurRadius: 10,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: const CircularProgressIndicator(),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Loading service data...',
                      style: TextStyle(
                        color: secondaryTextColor,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              );
            }

            if (controller.categoryError.isNotEmpty) {
              return Center(
                child: Container(
                  margin: const EdgeInsets.all(24),
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: cardBackgroundColor,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: shadowColor,
                        blurRadius: 10,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color:
                              isDark
                                  ? Colors.red.withValues(
                                    alpha: 0.2,
                                  ) // Menggunakan withValues
                                  : Colors.red[50],
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          Icons.error_outline,
                          color:
                              isDark ? Colors.redAccent[100] : Colors.red[400],
                          size: 48,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Oops! Something went wrong',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: defaultTextColor,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Error: ${controller.categoryError.value}',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: secondaryTextColor),
                      ),
                      const SizedBox(height: 24),
                      AppButton(
                        text: 'Try Again',
                        onPressed: controller.fetchCategories,
                        type: AppButtonType.primary,
                        icon: Icons.refresh,
                      ),
                    ],
                  ),
                ),
              );
            }

            if (controller.serviceCategories.isEmpty) {
              return Center(
                child: Container(
                  margin: const EdgeInsets.all(24),
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: cardBackgroundColor,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: shadowColor,
                        blurRadius: 10,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: primaryColorWithOpacityLow,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          Icons.category_outlined,
                          color: ColorTheme.primary,
                          size: 48,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'No Categories Found',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: defaultTextColor,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Please add service categories first before creating a new service.',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: secondaryTextColor),
                      ),
                      const SizedBox(height: 24),
                      AppButton(
                        text: 'Go to Categories',
                        onPressed: () => Get.toNamed('/service-categories'),
                        type: AppButtonType.primary,
                        icon: Icons.arrow_forward,
                      ),
                    ],
                  ),
                ),
              );
            }
            return _buildForm(context);
          }),
        ),
      ),
    );
  }

  void _initializePriceTierControllers(int index) {
    final tierData = priceTiers[index];
    priceTierControllers[index] = {
      'minAge': TextEditingController(text: tierData['minAge'].toString()),
      'maxAge': TextEditingController(text: tierData['maxAge'].toString()),
      'price': TextEditingController(text: tierData['price'].toString()),
    };
  }

  Widget _buildForm(BuildContext context) {
    final bool isDark = themeController.isDarkMode;
    // final Color defaultTextColor = isDark ? Colors.white.withValues(alpha: 0.87) : Colors.black.withValues(alpha: 0.87); // Dihapus karena tidak digunakan secara langsung di sini
    final Color secondaryTextColor =
        isDark
            ? Colors.white.withValues(alpha: 0.60)
            : Colors.grey[600]!; // Menggunakan withValues
    final Color primaryColorWithOpacityLow = ColorTheme.primary.withValues(
      // Menggunakan withValues
      alpha: isDark ? 0.2 : 0.1,
    );
    final Color primaryColorWithOpacityMedium = ColorTheme.primary.withValues(
      // Menggunakan withValues
      alpha: isDark ? 0.3 : 0.2,
    );

    return Form(
      key: formKey,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    primaryColorWithOpacityLow,
                    ColorTheme.primary.withValues(
                      alpha: isDark ? 0.1 : 0.05,
                    ), // Menggunakan withValues
                  ],
                ),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: primaryColorWithOpacityMedium),
              ),
              child: Column(
                children: [
                  Icon(Icons.spa_outlined, size: 32, color: ColorTheme.primary),
                  const SizedBox(height: 8),
                  Text(
                    'Create New Service',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: ColorTheme.primary,
                      fontFamily: 'JosefinSans',
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Fill in the details below to add a new service',
                    style: TextStyle(color: secondaryTextColor, fontSize: 14),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            _buildImageSection(),
            const SizedBox(height: 32),
            _buildSectionCard(
              title: 'Basic Information',
              icon: Icons.info_outline,
              child: Column(
                children: [
                  AppTextField(
                    controller: nameController,
                    label: 'Service Name',
                    placeholder: 'Enter service name',
                    isRequired: true,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Service name is required';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),
                  AppTextField(
                    controller: descriptionController,
                    label: 'Description',
                    placeholder: 'Enter service description',
                    maxLines: 3,
                  ),
                  const SizedBox(height: 20),
                  _buildCategoryDropdown(),
                  const SizedBox(height: 20),
                  AppTextField(
                    controller: durationController,
                    label: 'Duration (minutes)',
                    placeholder: 'Enter service duration',
                    keyboardType: TextInputType.number,
                    isRequired: true,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Duration is required';
                      }
                      if (int.tryParse(value) == null ||
                          int.parse(value) <= 0) {
                        return 'Please enter a valid duration';
                      }
                      return null;
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            _buildSectionCard(
              title: 'Pricing Configuration',
              icon: Icons.attach_money,
              child: Column(
                children: [
                  _buildPriceTierSwitch(),
                  const SizedBox(height: 20),
                  Obx(
                    () => AnimatedSwitcher(
                      duration: const Duration(milliseconds: 300),
                      child:
                          !hasPriceTiers.value
                              ? _buildSimplePricing()
                              : _buildPriceTiers(),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 40),
            Obx(
              () => Container(
                width: double.infinity,
                height: 56,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      ColorTheme.primary,
                      ColorTheme.primary.withValues(
                        alpha: 0.8,
                      ), // Menggunakan withValues
                    ],
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: ColorTheme.primary.withValues(
                        alpha: 0.3,
                      ), // Menggunakan withValues
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: AppButton(
                  text: 'Create Service',
                  isLoading: controller.isCreatingService.value,
                  onPressed: _submitForm,
                  type: AppButtonType.primary,
                  size: AppButtonSize.large,
                  isFullWidth: true,
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionCard({
    required String title,
    required IconData icon,
    required Widget child,
  }) {
    final bool isDark = themeController.isDarkMode;
    final Color cardBackgroundColor =
        isDark ? const Color(0xFF1E1E1E) : Colors.white;
    final Color defaultTextColor =
        isDark
            ? Colors.white.withValues(alpha: 0.87) // Menggunakan withValues
            : ColorTheme.textPrimary;
    final Color shadowColor =
        isDark
            ? Colors.black.withValues(alpha: 0.5)
            : Colors.black.withValues(alpha: 0.05); // Menggunakan withValues
    final Color primaryColorWithOpacityLow = ColorTheme.primary.withValues(
      // Menggunakan withValues
      alpha: isDark ? 0.25 : 0.1,
    );

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: cardBackgroundColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: shadowColor,
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: primaryColorWithOpacityLow,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: ColorTheme.primary, size: 20),
              ),
              const SizedBox(width: 12),
              Text(
                title,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: defaultTextColor,
                  fontFamily: 'JosefinSans',
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          child,
        ],
      ),
    );
  }

  Widget _buildImageSection() {
    final bool isDark = themeController.isDarkMode;
    final Color cardBackgroundColor =
        isDark ? const Color(0xFF1E1E1E) : Colors.white;
    final Color defaultTextColor =
        isDark
            ? Colors.white.withValues(alpha: 0.87)
            : ColorTheme.textPrimary; // Menggunakan withValues
    final Color shadowColor =
        isDark
            ? Colors.black.withValues(alpha: 0.5)
            : Colors.black.withValues(alpha: 0.05); // Menggunakan withValues
    final Color primaryColorWithOpacityLow = ColorTheme.primary.withValues(
      alpha: isDark ? 0.25 : 0.1,
    ); // Menggunakan withValues

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: cardBackgroundColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: shadowColor,
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: primaryColorWithOpacityLow,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(Icons.image, color: ColorTheme.primary, size: 20),
              ),
              const SizedBox(width: 12),
              Text(
                'Service Image',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: defaultTextColor,
                  fontFamily: 'JosefinSans',
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          _buildImagePicker(),
        ],
      ),
    );
  }

  Widget _buildImagePicker() {
    final bool isDark = themeController.isDarkMode;
    final Color imagePickerBackgroundColor =
        isDark ? Colors.grey[800]! : Colors.grey[50]!;
    final Color imagePickerBorderColor = ColorTheme.primary.withValues(
      alpha: isDark ? 0.6 : 0.3,
    ); // Menggunakan withValues
    final Color shadowColor =
        isDark
            ? Colors.black.withValues(alpha: 0.4)
            : Colors.black.withValues(alpha: 0.05); // Menggunakan withValues
    final Color iconContainerBackgroundColor =
        isDark
            ? ColorTheme.primary.withValues(
              alpha: 0.25,
            ) // Menggunakan withValues
            : ColorTheme.primary.withValues(
              alpha: 0.1,
            ); // Menggunakan withValues
    final Color secondaryTextColor =
        isDark
            ? Colors.white.withValues(alpha: 0.60)
            : Colors.grey[500]!; // Menggunakan withValues
    final Color editIconBackgroundColor =
        isDark ? Colors.grey[700]! : Colors.white;

    return Center(
      child: GestureDetector(
        onTap: _pickImage,
        child: Container(
          width: 180,
          height: 180,
          decoration: BoxDecoration(
            color: imagePickerBackgroundColor,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: imagePickerBorderColor,
              width: 2,
              style: BorderStyle.solid,
            ),
            boxShadow: [
              BoxShadow(
                color: shadowColor,
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Obx(
            () =>
                imageFile.value != null
                    ? Stack(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(14),
                          child: Image.file(
                            imageFile.value!,
                            fit: BoxFit.cover,
                            width: double.infinity,
                            height: double.infinity,
                          ),
                        ),
                        Positioned(
                          top: 8,
                          right: 8,
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: editIconBackgroundColor,
                              borderRadius: BorderRadius.circular(8),
                              boxShadow: [
                                BoxShadow(
                                  color:
                                      isDark
                                          ? Colors.black.withValues(alpha: 0.3)
                                          : Colors.black.withValues(
                                            alpha: 0.1,
                                          ), // Menggunakan withValues
                                  blurRadius: 4,
                                ),
                              ],
                            ),
                            child: Icon(
                              Icons.edit,
                              color: ColorTheme.primary,
                              size: 16,
                            ),
                          ),
                        ),
                      ],
                    )
                    : Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: iconContainerBackgroundColor,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            Icons.add_photo_alternate_outlined,
                            size: 40,
                            color: ColorTheme.primary,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'Add Service Image',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: ColorTheme.primary,
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Tap to select from gallery',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: secondaryTextColor,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryDropdown() {
    final bool isDark = themeController.isDarkMode;
    final Color labelTextColor =
        isDark
            ? Colors.white.withValues(alpha: 0.87)
            : ColorTheme.textPrimary; // Menggunakan withValues
    final Color dropdownBackgroundColor =
        isDark ? Colors.grey[800]! : Colors.white;
    final Color dropdownBorderColor =
        isDark ? Colors.grey[700]! : ColorTheme.border;
    final Color prefixIconColor = ColorTheme.primary.withValues(
      alpha: isDark ? 0.9 : 0.7,
    ); // Menggunakan withValues

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'Category',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: labelTextColor,
                fontFamily: 'JosefinSans',
              ),
            ),
            Text(
              " *",
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: ColorTheme.error,
                fontFamily: 'JosefinSans',
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: dropdownBorderColor),
            color: dropdownBackgroundColor,
            boxShadow: [
              BoxShadow(
                color:
                    isDark
                        ? Colors.black.withValues(alpha: 0.2)
                        : Colors.black.withValues(
                          alpha: 0.02,
                        ), // Menggunakan withValues
                blurRadius: 4,
                offset: const Offset(0, 1),
              ),
            ],
          ),
          child: DropdownButtonFormField<String>(
            style: TextStyle(
              color:
                  isDark
                      ? Colors.white.withValues(alpha: 0.87)
                      : Colors.black87,
            ), // Menggunakan withValues
            dropdownColor: dropdownBackgroundColor,
            decoration: InputDecoration(
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
              border: InputBorder.none,
              enabledBorder: InputBorder.none,
              focusedBorder: InputBorder.none,
              prefixIcon: Icon(
                Icons.category_outlined,
                color: prefixIconColor,
                size: 20,
              ),
            ),
            value:
                selectedCategoryId.value.isEmpty
                    ? null
                    : selectedCategoryId.value,
            onChanged: (String? value) {
              if (value != null) {
                selectedCategoryId.value = value;
              }
            },
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please select a category';
              }
              return null;
            },
            items:
                controller.serviceCategories.map((category) {
                  return DropdownMenuItem<String>(
                    value: category.id,
                    child: Text(category.name),
                  );
                }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildPriceTierSwitch() {
    final bool isDark = themeController.isDarkMode;
    final Color switchBackgroundColor =
        isDark ? Colors.grey[700]! : Colors.grey[50]!;
    final Color switchBorderColor =
        isDark ? Colors.grey[600]! : Colors.grey[200]!;
    final Color labelTextColor =
        isDark
            ? Colors.white.withValues(alpha: 0.87)
            : ColorTheme.textPrimary; // Menggunakan withValues
    final Color secondaryTextColor =
        isDark
            ? Colors.white.withValues(alpha: 0.60)
            : Colors.grey[600]!; // Menggunakan withValues
    final Color iconContainerBackgroundColor = ColorTheme.primary.withValues(
      alpha: isDark ? 0.25 : 0.1,
    ); // Menggunakan withValues

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: switchBackgroundColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: switchBorderColor),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: iconContainerBackgroundColor,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              Icons.layers_outlined,
              color: ColorTheme.primary,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Multiple Price Tiers',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: labelTextColor,
                  ),
                ),
                Text(
                  'Enable different prices for age ranges',
                  style: TextStyle(fontSize: 12, color: secondaryTextColor),
                ),
              ],
            ),
          ),
          Obx(
            () => Switch(
              value: hasPriceTiers.value,
              onChanged: (value) {
                hasPriceTiers.value = value;
              },
              activeColor: ColorTheme.primary,
              inactiveTrackColor: isDark ? Colors.grey[600] : Colors.grey[300],
              inactiveThumbColor: isDark ? Colors.grey[400] : Colors.grey[100],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSimplePricing() {
    final bool isDark = themeController.isDarkMode;
    final Color infoBoxColor =
        isDark
            ? Colors.blue[900]!.withValues(alpha: 0.5)
            : Colors.blue[50]!; // Menggunakan withValues
    final Color infoBoxBorderColor =
        isDark ? Colors.blue[700]! : Colors.blue[200]!;
    final Color infoBoxTextColor =
        isDark ? Colors.blue[200]! : Colors.blue[700]!;
    final Color labelTextColor =
        isDark
            ? Colors.white.withValues(alpha: 0.87)
            : ColorTheme.textPrimary; // Menggunakan withValues

    return Column(
      key: const ValueKey('simple'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: infoBoxColor,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: infoBoxBorderColor),
          ),
          child: Row(
            children: [
              Icon(Icons.info_outline, color: infoBoxTextColor, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Single price for all age ranges',
                  style: TextStyle(
                    color: infoBoxTextColor,
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        AppTextField(
          controller: priceController,
          label: 'Price (Rp)',
          placeholder: 'Enter service price',
          keyboardType: TextInputType.number,
          isRequired: true,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Price is required';
            }
            if (double.tryParse(value) == null || double.parse(value) < 0) {
              return 'Please enter a valid price';
            }
            return null;
          },
        ),
        const SizedBox(height: 20),
        Text(
          'Baby Age Range',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: labelTextColor,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: AppTextField(
                controller: minAgeController,
                label: 'Min Age (months)',
                placeholder: 'Min',
                keyboardType: TextInputType.number,
                isRequired: true,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Required';
                  }
                  if (int.tryParse(value) == null || int.parse(value) < 0) {
                    return 'Invalid';
                  }
                  return null;
                },
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: AppTextField(
                controller: maxAgeController,
                label: 'Max Age (months)',
                placeholder: 'Max',
                keyboardType: TextInputType.number,
                isRequired: true,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Required';
                  }
                  final minAgeText = minAgeController.text;
                  if (minAgeText.isEmpty || int.tryParse(minAgeText) == null) {
                    return 'Enter min age first';
                  }
                  if (int.tryParse(value) == null ||
                      int.parse(value) <= int.parse(minAgeText)) {
                    return 'Invalid';
                  }
                  return null;
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildPriceTiers() {
    final bool isDark = themeController.isDarkMode;
    final Color infoBoxColor =
        isDark
            ? Colors.orange[900]!.withValues(alpha: 0.5)
            : Colors.orange[50]!; // Menggunakan withValues
    final Color infoBoxBorderColor =
        isDark ? Colors.orange[700]! : Colors.orange[200]!;
    final Color infoBoxTextColor =
        isDark ? Colors.orange[200]! : Colors.orange[700]!;
    final Color tierCardBackgroundColor =
        isDark ? const Color(0xFF2A2A2A) : Colors.white;
    final Color tierCardBorderColor = ColorTheme.primary.withValues(
      alpha: isDark ? 0.4 : 0.2,
    ); // Menggunakan withValues
    final Color tierShadowColor =
        isDark
            ? Colors.black.withValues(alpha: 0.3)
            : Colors.black.withValues(alpha: 0.03); // Menggunakan withValues
    final Color deleteButtonBackgroundColor =
        isDark
            ? Colors.red.withValues(alpha: 0.2)
            : Colors.red[50]!; // Menggunakan withValues
    final Color deleteIconColor =
        isDark ? Colors.redAccent[100]! : Colors.red[400]!;

    return Column(
      key: const ValueKey('tiers'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: infoBoxColor,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: infoBoxBorderColor),
          ),
          child: Row(
            children: [
              Icon(Icons.info_outline, color: infoBoxTextColor, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Create multiple pricing tiers for different age ranges',
                  style: TextStyle(
                    color: infoBoxTextColor,
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        Obx(
          () => Column(
            children: [
              ...List.generate(priceTiers.length, (index) {
                if (!priceTierControllers.containsKey(index)) {
                  _initializePriceTierControllers(index);
                }
                final currentTierControllers =
                    priceTierControllers[index]!; // Menggunakan variabel yang berbeda untuk kejelasan
                return Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: tierCardBackgroundColor,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: tierCardBorderColor),
                    boxShadow: [
                      BoxShadow(
                        color: tierShadowColor,
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: ColorTheme.primary.withValues(
                                  alpha: isDark ? 0.3 : 0.1,
                                ), // Menggunakan withValues
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                'Tier ${index + 1}',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: ColorTheme.primary,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                            const Spacer(),
                            if (priceTiers.length > 1)
                              Container(
                                decoration: BoxDecoration(
                                  color: deleteButtonBackgroundColor,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: IconButton(
                                  icon: Icon(
                                    Icons.delete_outline,
                                    color: deleteIconColor,
                                    size: 20,
                                  ),
                                  onPressed: () {
                                    priceTiers.removeAt(index);
                                    // Rebuild the controllers map to ensure keys are contiguous
                                    final tempControllers = Map<
                                      int,
                                      Map<String, TextEditingController>
                                    >.from(priceTierControllers);
                                    priceTierControllers.clear();
                                    tempControllers.remove(
                                      index,
                                    ); // Remove the specific controller

                                    int newKey = 0;
                                    for (var oldKey
                                        in tempControllers.keys.toList()
                                          ..sort()) {
                                      // Iterate over sorted old keys
                                      if (oldKey != index) {
                                        // Skip the removed one if it was somehow still there
                                        final controllerSet =
                                            tempControllers[oldKey];
                                        if (controllerSet != null) {
                                          priceTierControllers[newKey] =
                                              controllerSet;
                                          newKey++;
                                        }
                                      }
                                    }
                                    // Ensure priceTiers list and priceTierControllers map are in sync
                                    // If a tier was removed, its controller should also be gone.
                                    // If priceTiers is shorter than controllers, adjust controllers.
                                    // If priceTiers is longer (e.g. added but controller not made), this is an issue.
                                    // The current logic re-indexes existing controllers.
                                  },
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              child: AppTextField(
                                placeholder: 'Min Age (months)',
                                keyboardType: TextInputType.number,
                                controller: currentTierControllers['minAge'],
                                validator: (value) {
                                  if (value == null || value.isEmpty)
                                    return 'Required';
                                  if (int.tryParse(value) == null ||
                                      int.parse(value) < 0)
                                    return 'Invalid age';
                                  return null;
                                },
                                onChanged: (value) {
                                  if (value.isNotEmpty &&
                                      int.tryParse(value) != null) {
                                    priceTiers[index]['minAge'] = int.parse(
                                      value,
                                    );
                                  }
                                },
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: AppTextField(
                                placeholder: 'Max Age (months)',
                                keyboardType: TextInputType.number,
                                controller: currentTierControllers['maxAge'],
                                validator: (value) {
                                  if (value == null || value.isEmpty)
                                    return 'Required';
                                  final minAgeText =
                                      currentTierControllers['minAge']!.text;
                                  if (minAgeText.isEmpty ||
                                      int.tryParse(minAgeText) == null)
                                    return 'Min age first';
                                  if (int.tryParse(value) == null ||
                                      int.parse(value) <= int.parse(minAgeText))
                                    return '> min age';
                                  return null;
                                },
                                onChanged: (value) {
                                  if (value.isNotEmpty &&
                                      int.tryParse(value) != null) {
                                    priceTiers[index]['maxAge'] = int.parse(
                                      value,
                                    );
                                  }
                                },
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        AppTextField(
                          placeholder: 'Price (Rp)',
                          keyboardType: TextInputType.number,
                          controller: currentTierControllers['price'],
                          validator: (value) {
                            if (value == null || value.isEmpty)
                              return 'Required';
                            if (double.tryParse(value) == null ||
                                double.parse(value) < 0)
                              return 'Invalid price';
                            return null;
                          },
                          onChanged: (value) {
                            if (value.isNotEmpty &&
                                double.tryParse(value) != null) {
                              priceTiers[index]['price'] = double.parse(value);
                            }
                          },
                        ),
                      ],
                    ),
                  ),
                );
              }),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Center(
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: ColorTheme.primary.withValues(
                    alpha: isDark ? 0.2 : 0.1,
                  ), // Menggunakan withValues
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: AppButton(
              text: 'Add Price Tier',
              type: AppButtonType.outline,
              icon: Icons.add,
              onPressed: () {
                final lastMaxAge =
                    priceTiers.isNotEmpty ? priceTiers.last['maxAge'] ?? 0 : 0;
                final newIndex = priceTiers.length;
                priceTiers.add({
                  'minAge': lastMaxAge + 1,
                  'maxAge': lastMaxAge + 12,
                  'price': 0.0,
                });
                _initializePriceTierControllers(newIndex);
              },
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      imageFile.value = File(pickedFile.path);
      isImageSelected.value = true;
    }
  }

  void _submitForm() {
    // final bool isDark = themeController.isDarkMode; // Dihapus, tidak digunakan
    if (formKey.currentState!.validate()) {
      final name = nameController.text;
      final description = descriptionController.text;
      final duration = int.parse(durationController.text);
      final categoryId = selectedCategoryId.value;

      if (hasPriceTiers.value) {
        bool isValid = true;
        // Validasi harusnya dari priceTiers list yang sudah diupdate oleh onChanged
        for (var i = 0; i < priceTiers.length; i++) {
          final tier = priceTiers[i];
          final tierControllerSet =
              priceTierControllers[i]; // Ambil controller yang sesuai

          if (tier['minAge'] == null ||
              tier['maxAge'] == null ||
              tier['price'] == null ||
              tierControllerSet == null || // Pastikan controller ada
              tierControllerSet['minAge']!.text.isEmpty ||
              tierControllerSet['maxAge']!.text.isEmpty ||
              tierControllerSet['price']!.text.isEmpty) {
            isValid = false;
            break;
          }
          // Pastikan juga nilai numerik valid jika diperlukan
          if (int.tryParse(tierControllerSet['minAge']!.text) == null ||
              int.tryParse(tierControllerSet['maxAge']!.text) == null ||
              double.tryParse(tierControllerSet['price']!.text) == null) {
            isValid = false;
            break;
          }
        }

        if (!isValid) {
          Get.snackbar(
            'Validation Error',
            'Please complete all price tier fields correctly.',
            backgroundColor: Colors.red,
            colorText: Colors.white,
            snackPosition: SnackPosition.BOTTOM,
          );
          return;
        }

        List<Map<String, dynamic>> formattedPriceTiers =
            priceTiers.map((tier) {
              return {
                'minBabyAge': tier['minAge'], // Sudah diupdate oleh onChanged
                'maxBabyAge': tier['maxAge'], // Sudah diupdate oleh onChanged
                'price': tier['price'], // Sudah diupdate oleh onChanged
                'tierName': 'Tier ${priceTiers.indexOf(tier) + 1}',
              };
            }).toList();
        controller.createService(
          name: name,
          description: description,
          duration: duration,
          categoryId: categoryId,
          hasPriceTiers: true,
          imageFile: imageFile.value,
          priceTiers: formattedPriceTiers,
        );
      } else {
        final price = double.parse(priceController.text);
        final minBabyAge = int.parse(minAgeController.text);
        final maxBabyAge = int.parse(maxAgeController.text);
        controller.createService(
          name: name,
          description: description,
          duration: duration,
          categoryId: categoryId,
          hasPriceTiers: false,
          imageFile: imageFile.value,
          price: price,
          minBabyAge: minBabyAge,
          maxBabyAge: maxBabyAge,
        );
      }
    } else {
      Get.snackbar(
        'Validation Error',
        'Please fill all required fields correctly.',
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }
}
