// lib/features/service/views/service_form_view.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:emababyspa/common/theme/color_theme.dart';
import 'package:emababyspa/common/widgets/custom_appbar.dart';
import 'package:emababyspa/common/layouts/main_layout.dart';
import 'package:emababyspa/features/service/controllers/service_controller.dart';
import 'package:emababyspa/common/widgets/app_button.dart';
import 'package:emababyspa/common/widgets/app_text_field.dart';

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

  // Map of controllers for price tiers
  final RxMap<int, Map<String, TextEditingController>> priceTierControllers =
      <int, Map<String, TextEditingController>>{}.obs;

  @override
  Widget build(BuildContext context) {
    // Add an initial empty price tier if none exists
    if (priceTiers.isEmpty) {
      priceTiers.add({'minAge': 0, 'maxAge': 12, 'price': 0.0});
      _initializePriceTierControllers(0);
    }

    return MainLayout(
      child: Scaffold(
        backgroundColor: Colors.grey[50],
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
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
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
                        color: Colors.grey[600],
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
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
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
                          color: Colors.red[50],
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          Icons.error_outline,
                          color: Colors.red[400],
                          size: 48,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Oops! Something went wrong',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey[800],
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Error: ${controller.categoryError.value}',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.grey[600]),
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
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
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
                          color: ColorTheme.primary.withOpacity(0.1),
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
                          color: Colors.grey[800],
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Please add service categories first before creating a new service.',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.grey),
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

  // Initialize controllers for a price tier at specified index
  void _initializePriceTierControllers(int index) {
    final tierData = priceTiers[index];

    priceTierControllers[index] = {
      'minAge': TextEditingController(text: tierData['minAge'].toString()),
      'maxAge': TextEditingController(text: tierData['maxAge'].toString()),
      'price': TextEditingController(text: tierData['price'].toString()),
    };
  }

  Widget _buildForm(BuildContext context) {
    return Form(
      key: formKey,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Section
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    ColorTheme.primary.withOpacity(0.1),
                    ColorTheme.primary.withOpacity(0.05),
                  ],
                ),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: ColorTheme.primary.withOpacity(0.2)),
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
                    style: TextStyle(color: Colors.grey[600], fontSize: 14),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // Image Section
            _buildImageSection(),
            const SizedBox(height: 32),

            // Basic Information Section
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

            // Pricing Section
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

            // Submit Button
            Obx(
              () => Container(
                width: double.infinity,
                height: 56,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      ColorTheme.primary,
                      ColorTheme.primary.withOpacity(0.8),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: ColorTheme.primary.withOpacity(0.3),
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
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
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
                  color: ColorTheme.primary.withOpacity(0.1),
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
                  color: ColorTheme.textPrimary,
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
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
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
                  color: ColorTheme.primary.withOpacity(0.1),
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
                  color: ColorTheme.textPrimary,
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
    return Center(
      child: GestureDetector(
        onTap: _pickImage,
        child: Container(
          width: 180,
          height: 180,
          decoration: BoxDecoration(
            color: Colors.grey[50],
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: ColorTheme.primary.withOpacity(0.3),
              width: 2,
              style: BorderStyle.solid,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
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
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(8),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.1),
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
                            color: ColorTheme.primary.withOpacity(0.1),
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
                            color: Colors.grey[500],
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
                color: ColorTheme.textPrimary,
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
            border: Border.all(color: ColorTheme.border),
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.02),
                blurRadius: 4,
                offset: const Offset(0, 1),
              ),
            ],
          ),
          child: DropdownButtonFormField<String>(
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
                color: ColorTheme.primary.withOpacity(0.7),
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
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: ColorTheme.primary.withOpacity(0.1),
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
                    color: ColorTheme.textPrimary,
                  ),
                ),
                Text(
                  'Enable different prices for age ranges',
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
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
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSimplePricing() {
    return Column(
      key: const ValueKey('simple'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.blue[50],
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.blue[200]!),
          ),
          child: Row(
            children: [
              Icon(Icons.info_outline, color: Colors.blue[600], size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Single price for all age ranges',
                  style: TextStyle(
                    color: Colors.blue[700],
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
            color: ColorTheme.textPrimary,
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
    return Column(
      key: const ValueKey('tiers'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.orange[50],
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.orange[200]!),
          ),
          child: Row(
            children: [
              Icon(Icons.info_outline, color: Colors.orange[600], size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Create multiple pricing tiers for different age ranges',
                  style: TextStyle(
                    color: Colors.orange[700],
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),

        // List of price tiers
        Obx(
          () => Column(
            children: [
              ...List.generate(priceTiers.length, (index) {
                // Ensure controllers exist for this index
                if (!priceTierControllers.containsKey(index)) {
                  _initializePriceTierControllers(index);
                }

                final controllers = priceTierControllers[index]!;

                return Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: ColorTheme.primary.withOpacity(0.2),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.03),
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
                                color: ColorTheme.primary.withOpacity(0.1),
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
                                  color: Colors.red[50],
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: IconButton(
                                  icon: Icon(
                                    Icons.delete_outline,
                                    color: Colors.red[400],
                                    size: 20,
                                  ),
                                  onPressed: () {
                                    priceTiers.removeAt(index);
                                    priceTierControllers.remove(index);
                                    // Reindex the controllers
                                    final newControllers =
                                        <
                                          int,
                                          Map<String, TextEditingController>
                                        >{};
                                    for (
                                      int i = 0;
                                      i < priceTiers.length;
                                      i++
                                    ) {
                                      if (i < index) {
                                        newControllers[i] =
                                            priceTierControllers[i]!;
                                      } else {
                                        newControllers[i] =
                                            priceTierControllers[i + 1]!;
                                      }
                                    }
                                    priceTierControllers.value = newControllers;
                                  },
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 16),

                        // Min and Max Age
                        Row(
                          children: [
                            Expanded(
                              child: AppTextField(
                                placeholder: 'Min Age (months)',
                                keyboardType: TextInputType.number,
                                controller: controllers['minAge'],
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Required';
                                  }
                                  if (int.tryParse(value) == null ||
                                      int.parse(value) < 0) {
                                    return 'Invalid age';
                                  }
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
                                controller: controllers['maxAge'],
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Required';
                                  }

                                  final minAgeText =
                                      controllers['minAge']!.text;
                                  if (minAgeText.isEmpty ||
                                      int.tryParse(minAgeText) == null) {
                                    return 'Enter min age first';
                                  }

                                  if (int.tryParse(value) == null ||
                                      int.parse(value) <=
                                          int.parse(minAgeText)) {
                                    return 'Must be > min age';
                                  }
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

                        // Price
                        AppTextField(
                          placeholder: 'Price (Rp)',
                          keyboardType: TextInputType.number,
                          controller: controllers['price'],
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Price is required';
                            }
                            if (double.tryParse(value) == null ||
                                double.parse(value) < 0) {
                              return 'Invalid price';
                            }
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

        // Add new tier button
        const SizedBox(height: 16),
        Center(
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: ColorTheme.primary.withOpacity(0.1),
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
                // Find the max age from the last tier to start the new one
                final lastMaxAge = priceTiers.last['maxAge'];
                final newIndex = priceTiers.length;

                priceTiers.add({
                  'minAge': lastMaxAge + 1,
                  'maxAge': lastMaxAge + 12,
                  'price': 0.0,
                });

                // Initialize controllers for the new tier
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
    if (formKey.currentState!.validate()) {
      // Prepare service data
      final name = nameController.text;
      final description = descriptionController.text;
      final duration = int.parse(durationController.text);
      final categoryId = selectedCategoryId.value;

      if (hasPriceTiers.value) {
        // Validate price tiers
        bool isValid = true;
        for (var tier in priceTiers) {
          if (tier['minAge'] == null ||
              tier['maxAge'] == null ||
              tier['price'] == null) {
            isValid = false;
            break;
          }
        }

        if (!isValid) {
          Get.snackbar(
            'Validation Error',
            'Please complete all price tier fields',
            backgroundColor: Colors.red,
            colorText: Colors.white,
          );
          return;
        }

        // Convert to the correct format expected by the API
        List<Map<String, dynamic>> formattedPriceTiers =
            priceTiers.map((tier) {
              return {
                'minBabyAge': tier['minAge'],
                'maxBabyAge': tier['maxAge'],
                'price': tier['price'],
                'tierName': 'Tier ${priceTiers.indexOf(tier) + 1}',
              };
            }).toList();

        // Submit with price tiers
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
        // Simple pricing
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
    }
  }
}
