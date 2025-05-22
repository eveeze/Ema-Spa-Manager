// lib/features/service/views/service_edit_view.dart
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

class ServiceEditView extends GetView<ServiceController> {
  ServiceEditView({super.key});

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
  final RxString currentImageUrl = ''.obs;
  final RxList<Map<String, dynamic>> priceTiers = <Map<String, dynamic>>[].obs;

  // Map of controllers for price tiers
  final RxMap<int, Map<String, TextEditingController>> priceTierControllers =
      <int, Map<String, TextEditingController>>{}.obs;

  // Service ID for editing
  final String serviceId = Get.parameters['id'] ?? '';

  @override
  Widget build(BuildContext context) {
    // Fetch service data on init if not already loaded
    _fetchServiceIfNeeded();

    return MainLayout(
      child: Scaffold(
        backgroundColor: const Color(0xFFF8FAFC),
        appBar: CustomAppBar(
          title: 'Edit Service',
          showBackButton: true,
          backgroundColor: Colors.white,
          elevation: 0,
        ),
        body: Obx(() {
          if (controller.isFetchingServiceDetail.value) {
            return _buildLoadingState();
          }

          if (controller.isLoadingCategories.value) {
            return _buildLoadingState();
          }

          if (controller.selectedService.value == null) {
            return _buildErrorState(
              icon: Icons.error_outline,
              title: 'Service Not Found',
              message: 'No service selected or service not found.',
              actions: [
                AppButton(
                  text: 'Refresh',
                  icon: Icons.refresh,
                  onPressed: () => _fetchServiceIfNeeded(),
                  type: AppButtonType.primary,
                  isFullWidth: true,
                  size: AppButtonSize.medium,
                ),
                const SizedBox(height: 12),
                AppButton(
                  text: 'Go Back',
                  icon: Icons.arrow_back,
                  onPressed: () => Get.back(),
                  type: AppButtonType.outline,
                  isFullWidth: true,
                  size: AppButtonSize.medium,
                ),
              ],
            );
          }

          if (controller.categoryError.isNotEmpty) {
            return _buildErrorState(
              icon: Icons.warning_amber_outlined,
              title: 'Error Loading Categories',
              message: controller.categoryError.value,
              actions: [
                AppButton(
                  text: 'Refresh',
                  icon: Icons.refresh,
                  onPressed: controller.fetchCategories,
                  type: AppButtonType.primary,
                  isFullWidth: true,
                  size: AppButtonSize.medium,
                ),
              ],
            );
          }

          if (controller.serviceCategories.isEmpty) {
            return _buildErrorState(
              icon: Icons.category_outlined,
              title: 'No Categories Found',
              message: 'Please add categories first before editing services.',
              actions: [
                AppButton(
                  text: 'Go to Categories',
                  icon: Icons.add_box,
                  onPressed: () => Get.toNamed('/service-categories'),
                  type: AppButtonType.primary,
                  isFullWidth: true,
                  size: AppButtonSize.medium,
                ),
              ],
            );
          }

          return _buildForm(context);
        }),
      ),
    );
  }

  Widget _buildLoadingState() {
    return Container(
      color: const Color(0xFFF8FAFC),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: ColorTheme.primary.withValues(alpha: 0.08),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                    spreadRadius: 0,
                  ),
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.02),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                    spreadRadius: 0,
                  ),
                ],
              ),
              child: Column(
                children: [
                  Container(
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          ColorTheme.primary.withValues(alpha: 0.1),
                          ColorTheme.primary.withValues(alpha: 0.05),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: SizedBox(
                        width: 32,
                        height: 32,
                        child: CircularProgressIndicator(
                          strokeWidth: 3,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            ColorTheme.primary,
                          ),
                          strokeCap: StrokeCap.round,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Loading service data...',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: ColorTheme.textPrimary,
                      fontFamily: 'JosefinSans',
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Please wait while we fetch the service details',
                    style: TextStyle(
                      fontSize: 14,
                      color: ColorTheme.textSecondary,
                      fontFamily: 'JosefinSans',
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState({
    required IconData icon,
    required String title,
    required String message,
    required List<Widget> actions,
  }) {
    return Container(
      color: const Color(0xFFF8FAFC),
      child: Center(
        child: Container(
          margin: const EdgeInsets.all(24),
          padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: ColorTheme.primary.withValues(alpha: 0.08),
                blurRadius: 24,
                offset: const Offset(0, 12),
                spreadRadius: 0,
              ),
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 8,
                offset: const Offset(0, 4),
                spreadRadius: 0,
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      ColorTheme.primary.withValues(alpha: 0.1),
                      ColorTheme.primary.withValues(alpha: 0.05),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, size: 48, color: ColorTheme.primary),
              ),
              const SizedBox(height: 24),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1E293B),
                  fontFamily: 'JosefinSans',
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              Text(
                message,
                style: TextStyle(
                  fontSize: 15,
                  color: ColorTheme.textSecondary,
                  fontFamily: 'JosefinSans',
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              ...actions,
            ],
          ),
        ),
      ),
    );
  }

  // Fetch the service if needed
  Future<void> _fetchServiceIfNeeded() async {
    if (serviceId.isEmpty) {
      Get.snackbar(
        'Error',
        'No service ID provided',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    if (controller.selectedService.value == null ||
        controller.selectedService.value!.id != serviceId) {
      await controller.getServiceById(serviceId);

      // Also ensure categories are loaded
      if (controller.serviceCategories.isEmpty) {
        await controller.fetchCategories();
      }

      // Initialize form after fetching data
      _initializeFormWithServiceData();
    }
  }

  void _initializeFormWithServiceData() {
    // Only initialize when service data is available
    if (controller.selectedService.value != null) {
      final service = controller.selectedService.value!;

      // Set basic form fields
      nameController.text = service.name;
      descriptionController.text = service.description;
      durationController.text = service.duration.toString();
      selectedCategoryId.value = service.categoryId;
      currentImageUrl.value = service.imageUrl ?? '';

      // Set pricing data
      hasPriceTiers.value = service.hasPriceTiers;

      if (!service.hasPriceTiers) {
        // Simple pricing
        priceController.text = service.price.toString();
        minAgeController.text = service.minBabyAge.toString();
        maxAgeController.text = service.maxBabyAge.toString();
      } else {
        // Price tiers
        if (service.priceTiers != null && service.priceTiers!.isNotEmpty) {
          priceTiers.clear();

          // Convert API price tiers to local format
          for (var tier in service.priceTiers!) {
            // Access PriceTier properties directly instead of using array notation
            priceTiers.add({
              'minAge': tier.minBabyAge, // Changed from tier['minBabyAge']
              'maxAge': tier.maxBabyAge, // Changed from tier['maxBabyAge']
              'price': tier.price, // Changed from tier['price']
              'tierName': tier.tierName, // Changed from tier['tierName']
            });
          }

          // Initialize controllers for each tier
          for (int i = 0; i < priceTiers.length; i++) {
            _initializePriceTierControllers(i);
          }
        } else {
          // If no price tiers found, add an initial empty one
          _addInitialPriceTier();
        }
      }
    }
  }

  void _addInitialPriceTier() {
    priceTiers.add({'minAge': 0, 'maxAge': 12, 'price': 0.0});
    _initializePriceTierControllers(0);
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
    return Container(
      color: const Color(0xFFF8FAFC),
      child: Form(
        key: formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Enhanced Header Section
              _buildSectionHeader('Service Details', Icons.edit_outlined),
              const SizedBox(height: 24),

              // Progress Indicator
              _buildProgressIndicator(),
              const SizedBox(height: 32),

              // Image Picker Card
              _buildImagePickerCard(),
              const SizedBox(height: 24),

              // Basic Information Card
              _buildCard(
                child: Column(
                  children: [
                    _buildSectionTitle('Basic Information'),
                    const SizedBox(height: 24),

                    // Service Name
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

                    // Service Description
                    AppTextField(
                      controller: descriptionController,
                      label: 'Description',
                      placeholder: 'Enter service description',
                      maxLines: 3,
                    ),
                    const SizedBox(height: 20),

                    // Service Category Dropdown
                    _buildCategoryDropdown(),
                    const SizedBox(height: 20),

                    // Service Duration
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

              // Pricing Configuration Card
              _buildCard(
                child: Column(
                  children: [
                    _buildSectionTitle('Pricing Configuration'),
                    const SizedBox(height: 24),

                    // Price Tier Switch
                    _buildPriceTierSwitch(),
                    const SizedBox(height: 24),

                    // Baby Age Range (for simple pricing) or Price Tiers
                    Obx(
                      () => AnimatedSwitcher(
                        duration: const Duration(milliseconds: 400),
                        transitionBuilder: (child, animation) {
                          return FadeTransition(
                            opacity: animation,
                            child: SlideTransition(
                              position: Tween<Offset>(
                                begin: const Offset(0, 0.1),
                                end: Offset.zero,
                              ).animate(
                                CurvedAnimation(
                                  parent: animation,
                                  curve: Curves.easeOutCubic,
                                ),
                              ),
                              child: child,
                            ),
                          );
                        },
                        child:
                            !hasPriceTiers.value
                                ? _buildSimplePricing()
                                : _buildPriceTiers(),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 32),

              // Submit Button
              _buildSubmitButton(),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProgressIndicator() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            ColorTheme.primary.withValues(alpha: 0.05),
            ColorTheme.primary.withValues(alpha: 0.02),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: ColorTheme.primary.withValues(alpha: 0.1)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: ColorTheme.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              Icons.settings_outlined,
              color: ColorTheme.primary,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Editing Service',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: ColorTheme.textPrimary,
                    fontFamily: 'JosefinSans',
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Update your service details and pricing information',
                  style: TextStyle(
                    fontSize: 13,
                    color: ColorTheme.textSecondary,
                    fontFamily: 'JosefinSans',
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  ColorTheme.primary.withValues(alpha: 0.15),
                  ColorTheme.primary.withValues(alpha: 0.08),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, size: 24, color: ColorTheme.primary),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1E293B),
                    fontFamily: 'JosefinSans',
                  ),
                ),
                const SizedBox(height: 4),
                Container(
                  height: 3,
                  width: 40,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [ColorTheme.primary, ColorTheme.primaryDark],
                    ),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCard({required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: ColorTheme.primary.withValues(alpha: 0.06),
            blurRadius: 20,
            offset: const Offset(0, 8),
            spreadRadius: 0,
          ),
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 6,
            offset: const Offset(0, 2),
            spreadRadius: 0,
          ),
        ],
      ),
      child: child,
    );
  }

  Widget _buildSectionTitle(String title) {
    return Row(
      children: [
        Container(
          width: 4,
          height: 24,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [ColorTheme.primary, ColorTheme.primaryDark],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 16),
        Text(
          title,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: ColorTheme.textPrimary,
            fontFamily: 'JosefinSans',
          ),
        ),
      ],
    );
  }

  Widget _buildImagePickerCard() {
    return _buildCard(
      child: Column(
        children: [
          _buildSectionTitle('Service Image'),
          const SizedBox(height: 24),
          Center(
            child: GestureDetector(
              onTap: _pickImage,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOutCubic,
                width: 200,
                height: 200,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [ColorTheme.background, Colors.white],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: ColorTheme.primary.withValues(alpha: 0.2),
                    width: 2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: ColorTheme.primary.withValues(alpha: 0.08),
                      blurRadius: 16,
                      offset: const Offset(0, 8),
                      spreadRadius: 0,
                    ),
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.04),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                      spreadRadius: 0,
                    ),
                  ],
                ),
                child: Obx(() {
                  if (imageFile.value != null) {
                    return Stack(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(22),
                          child: Image.file(
                            imageFile.value!,
                            fit: BoxFit.cover,
                            width: double.infinity,
                            height: double.infinity,
                          ),
                        ),
                        Positioned(
                          top: 12,
                          right: 12,
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  Colors.black.withValues(alpha: 0.7),
                                  Colors.black.withValues(alpha: 0.5),
                                ],
                              ),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.edit,
                              color: Colors.white,
                              size: 18,
                            ),
                          ),
                        ),
                      ],
                    );
                  } else if (currentImageUrl.value.isNotEmpty) {
                    return Stack(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(22),
                          child: Image.network(
                            currentImageUrl.value,
                            fit: BoxFit.cover,
                            width: double.infinity,
                            height: double.infinity,
                            errorBuilder: (context, error, stackTrace) {
                              return _buildImagePlaceholder(
                                icon: Icons.image_not_supported_outlined,
                                text: 'Image not available',
                              );
                            },
                          ),
                        ),
                        Positioned(
                          top: 12,
                          right: 12,
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  Colors.black.withValues(alpha: 0.7),
                                  Colors.black.withValues(alpha: 0.5),
                                ],
                              ),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.edit,
                              color: Colors.white,
                              size: 18,
                            ),
                          ),
                        ),
                      ],
                    );
                  } else {
                    return _buildImagePlaceholder(
                      icon: Icons.add_photo_alternate_outlined,
                      text: 'Add Service Image',
                    );
                  }
                }),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Tap to select or change image',
            style: TextStyle(
              fontSize: 13,
              color: ColorTheme.textSecondary,
              fontFamily: 'JosefinSans',
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImagePlaceholder({
    required IconData icon,
    required String text,
  }) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                ColorTheme.primary.withValues(alpha: 0.1),
                ColorTheme.primary.withValues(alpha: 0.05),
              ],
            ),
            shape: BoxShape.circle,
          ),
          child: Icon(
            icon,
            size: 48,
            color: ColorTheme.primary.withValues(alpha: 0.8),
          ),
        ),
        const SizedBox(height: 16),
        Text(
          text,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: ColorTheme.primary,
            fontWeight: FontWeight.w600,
            fontSize: 15,
            fontFamily: 'JosefinSans',
          ),
        ),
      ],
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
            border: Border.all(color: ColorTheme.border.withValues(alpha: 0.3)),
            gradient: LinearGradient(
              colors: [
                Colors.white,
                ColorTheme.background.withValues(alpha: 0.3),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.02),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: DropdownButtonFormField<String>(
            decoration: const InputDecoration(
              contentPadding: EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
              border: InputBorder.none,
              enabledBorder: InputBorder.none,
              focusedBorder: InputBorder.none,
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
                    child: Text(
                      category.name,
                      style: TextStyle(
                        fontSize: 16,
                        color: ColorTheme.textPrimary,
                        fontFamily: 'JosefinSans',
                      ),
                    ),
                  );
                }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildPriceTierSwitch() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            ColorTheme.primary.withValues(alpha: 0.06),
            ColorTheme.primary.withValues(alpha: 0.03),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: ColorTheme.primary.withValues(alpha: 0.1)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  ColorTheme.primary.withValues(alpha: 0.15),
                  ColorTheme.primary.withValues(alpha: 0.08),
                ],
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              Icons.tune_outlined,
              color: ColorTheme.primary,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Multiple Price Tiers',
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w600,
                    color: ColorTheme.textPrimary,
                    fontFamily: 'JosefinSans',
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Enable different pricing for different age groups',
                  style: TextStyle(
                    fontSize: 13,
                    color: ColorTheme.textSecondary,
                    fontFamily: 'JosefinSans',
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: ColorTheme.primary.withValues(alpha: 0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Switch(
              value: hasPriceTiers.value,
              onChanged: (value) {
                hasPriceTiers.value = value;

                // Initialize price tiers if switching to multiple tiers
                if (value && priceTiers.isEmpty) {
                  _addInitialPriceTier();
                }
              },
              activeColor: ColorTheme.primary,
              activeTrackColor: ColorTheme.primary.withValues(alpha: 0.3),
              inactiveThumbColor: Colors.grey[400],
              inactiveTrackColor: Colors.grey[300],
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSimplePricing() {
    return Container(
      key: const ValueKey('simple_pricing'),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.green.withValues(alpha: 0.03),
            Colors.green.withValues(alpha: 0.01),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.green.withValues(alpha: 0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.green.withValues(alpha: 0.15),
                      Colors.green.withValues(alpha: 0.08),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  Icons.attach_money_outlined,
                  color: Colors.green[600],
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'Simple Pricing',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: ColorTheme.textPrimary,
                  fontFamily: 'JosefinSans',
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Price
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
          const SizedBox(height: 24),

          // Baby Age Range Header
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      ColorTheme.primary.withValues(alpha: 0.15),
                      ColorTheme.primary.withValues(alpha: 0.08),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  Icons.child_care_outlined,
                  color: ColorTheme.primary,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'Age Range',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: ColorTheme.textPrimary,
                  fontFamily: 'JosefinSans',
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Baby Age Range Fields
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
                    if (minAgeText.isEmpty ||
                        int.tryParse(minAgeText) == null) {
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
      ),
    );
  }

  Widget _buildPriceTiers() {
    return Container(
      key: const ValueKey('price_tiers'),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.blue.withValues(alpha: 0.03),
                  Colors.blue.withValues(alpha: 0.01),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.blue.withValues(alpha: 0.1)),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.blue.withValues(alpha: 0.15),
                        Colors.blue.withValues(alpha: 0.08),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    Icons.layers_outlined,
                    color: Colors.blue[600],
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  'Price Tiers',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: ColorTheme.textPrimary,
                    fontFamily: 'JosefinSans',
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

                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 400),
                    curve: Curves.easeInOutCubic,
                    margin: const EdgeInsets.only(bottom: 20),
                    child: Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: ColorTheme.primary.withValues(alpha: 0.15),
                          width: 1.5,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: ColorTheme.primary.withValues(alpha: 0.08),
                            blurRadius: 16,
                            offset: const Offset(0, 6),
                            spreadRadius: 0,
                          ),
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.02),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                            spreadRadius: 0,
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 8,
                                ),
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      ColorTheme.primary.withValues(
                                        alpha: 0.15,
                                      ),
                                      ColorTheme.primary.withValues(
                                        alpha: 0.08,
                                      ),
                                    ],
                                  ),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  'Tier ${index + 1}',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w700,
                                    color: ColorTheme.primary,
                                    fontSize: 14,
                                    fontFamily: 'JosefinSans',
                                  ),
                                ),
                              ),
                              const Spacer(),
                              if (priceTiers.length > 1)
                                Container(
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [
                                        ColorTheme.error.withValues(alpha: 0.1),
                                        ColorTheme.error.withValues(
                                          alpha: 0.05,
                                        ),
                                      ],
                                    ),
                                    shape: BoxShape.circle,
                                  ),
                                  child: IconButton(
                                    icon: Icon(
                                      Icons.delete_outline,
                                      color: ColorTheme.error,
                                      size: 22,
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
                                      priceTierControllers.value =
                                          newControllers;
                                    },
                                  ),
                                ),
                            ],
                          ),
                          const SizedBox(height: 20),

                          // Age Range Section
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: ColorTheme.background.withValues(
                                alpha: 0.3,
                              ),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Age Range (months)',
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w600,
                                    color: ColorTheme.textPrimary,
                                    fontFamily: 'JosefinSans',
                                  ),
                                ),
                                const SizedBox(height: 16),

                                // Min and Max Age
                                Row(
                                  children: [
                                    Expanded(
                                      child: AppTextField(
                                        placeholder: 'Min Age',
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
                                            priceTiers[index]['minAge'] =
                                                int.parse(value);
                                          }
                                        },
                                      ),
                                    ),
                                    Container(
                                      margin: const EdgeInsets.symmetric(
                                        horizontal: 16,
                                      ),
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 12,
                                        vertical: 8,
                                      ),
                                      decoration: BoxDecoration(
                                        gradient: LinearGradient(
                                          colors: [
                                            ColorTheme.primary.withValues(
                                              alpha: 0.1,
                                            ),
                                            ColorTheme.primary.withValues(
                                              alpha: 0.05,
                                            ),
                                          ],
                                        ),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Text(
                                        'to',
                                        style: TextStyle(
                                          color: ColorTheme.primary,
                                          fontWeight: FontWeight.w600,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ),
                                    Expanded(
                                      child: AppTextField(
                                        placeholder: 'Max Age',
                                        keyboardType: TextInputType.number,
                                        controller: controllers['maxAge'],
                                        validator: (value) {
                                          if (value == null || value.isEmpty) {
                                            return 'Required';
                                          }

                                          final minAgeText =
                                              controllers['minAge']!.text;
                                          if (minAgeText.isEmpty ||
                                              int.tryParse(minAgeText) ==
                                                  null) {
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
                                            priceTiers[index]['maxAge'] =
                                                int.parse(value);
                                          }
                                        },
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 20),

                          // Price Section
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  Colors.green.withValues(alpha: 0.05),
                                  Colors.green.withValues(alpha: 0.02),
                                ],
                              ),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Price (Rp)',
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w600,
                                    color: ColorTheme.textPrimary,
                                    fontFamily: 'JosefinSans',
                                  ),
                                ),
                                const SizedBox(height: 16),
                                AppTextField(
                                  placeholder: 'Enter price for this tier',
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
                                      priceTiers[index]['price'] = double.parse(
                                        value,
                                      );
                                    }
                                  },
                                ),
                              ],
                            ),
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
          const SizedBox(height: 20),
          Center(
            child: AppButton(
              text: 'Add Price Tier',
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
              type: AppButtonType.outline,
              isFullWidth: true,
              size: AppButtonSize.medium,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSubmitButton() {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            ColorTheme.primary.withValues(alpha: 0.1),
            ColorTheme.primary.withValues(alpha: 0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Obx(
        () => AppButton(
          text:
              controller.isUpdatingService.value
                  ? 'Updating Service...'
                  : 'Update Service',
          icon: controller.isUpdatingService.value ? null : Icons.save_outlined,
          onPressed: controller.isUpdatingService.value ? null : _submitForm,
          type: AppButtonType.primary,
          isFullWidth: true,
          size: AppButtonSize.large,
          isLoading: controller.isUpdatingService.value,
        ),
      ),
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
      final serviceId = controller.selectedService.value!.id;
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
        controller
            .updateService(
              id: serviceId,
              name: name,
              description: description,
              duration: duration,
              categoryId: categoryId,
              hasPriceTiers: true,
              imageFile: imageFile.value,
              imageUrl: isImageSelected.value ? null : currentImageUrl.value,
              priceTiers: formattedPriceTiers,
            )
            .then((service) {
              if (service != null) {
                Get.back(); // Return to previous screen on success
              }
            });
      } else {
        // Simple pricing
        final price = double.parse(priceController.text);
        final minBabyAge = int.parse(minAgeController.text);
        final maxBabyAge = int.parse(maxAgeController.text);

        controller
            .updateService(
              id: serviceId,
              name: name,
              description: description,
              duration: duration,
              categoryId: categoryId,
              hasPriceTiers: false,
              imageFile: imageFile.value,
              imageUrl: isImageSelected.value ? null : currentImageUrl.value,
              price: price,
              minBabyAge: minBabyAge,
              maxBabyAge: maxBabyAge,
            )
            .then((service) {
              if (service != null) {
                Get.back(); // Return to previous screen on success
              }
            });
      }
    }
  }
}
