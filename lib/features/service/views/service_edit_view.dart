import 'dart:io';
import 'package:emababyspa/utils/app_routes.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:emababyspa/common/theme/color_theme.dart';
import 'package:emababyspa/common/layouts/main_layout.dart';
import 'package:emababyspa/features/service/controllers/service_controller.dart';
import 'package:emababyspa/common/widgets/app_button.dart';
import 'package:emababyspa/common/widgets/app_text_field.dart';
import 'package:emababyspa/features/theme/controllers/theme_controller.dart';

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

  final RxMap<int, Map<String, TextEditingController>> priceTierControllers =
      <int, Map<String, TextEditingController>>{}.obs;

  final String serviceId = Get.parameters['id'] ?? '';
  final ThemeController themeController = Get.find<ThemeController>();

  @override
  Widget build(BuildContext context) {
    _fetchServiceIfNeeded();

    return MainLayout.subPage(
      title: 'Edit Service',
      parentRoute: AppRoutes.services,
      child: Obx(() {
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
                onPressed: () => Get.toNamed(AppRoutes.serviceCategoryList),
                type: AppButtonType.primary,
                isFullWidth: true,
                size: AppButtonSize.medium,
              ),
            ],
          );
        }

        return _buildForm(context);
      }),
    );
  }

  Widget _buildLoadingState() {
    return Container(
      color:
          themeController.isDarkMode
              ? ColorTheme.backgroundDark
              : ColorTheme.background,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                color:
                    themeController.isDarkMode
                        ? ColorTheme.surfaceDark
                        : ColorTheme.surface,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: (themeController.isDarkMode
                            ? ColorTheme.primaryDark
                            : ColorTheme.primary)
                        .withOpacity(0.08),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                    spreadRadius: 0,
                  ),
                  BoxShadow(
                    color: (themeController.isDarkMode
                            ? ColorTheme.textPrimaryDark
                            : ColorTheme.textPrimary)
                        .withOpacity(0.02),
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
                          (themeController.isDarkMode
                                  ? ColorTheme.primaryDark
                                  : ColorTheme.primary)
                              .withOpacity(0.1),
                          (themeController.isDarkMode
                                  ? ColorTheme.primaryDark
                                  : ColorTheme.primary)
                              .withOpacity(0.05),
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
                            themeController.isDarkMode
                                ? ColorTheme.primaryDark
                                : ColorTheme.primary,
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
                      color:
                          themeController.isDarkMode
                              ? ColorTheme.textSecondaryDark
                              : ColorTheme.textPrimary,
                      fontFamily: 'JosefinSans',
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Please wait while we fetch the service details',
                    style: TextStyle(
                      fontSize: 14,
                      color:
                          themeController.isDarkMode
                              ? ColorTheme.textTertiaryDark
                              : ColorTheme.textSecondary,
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
      color:
          themeController.isDarkMode
              ? ColorTheme.backgroundDark
              : ColorTheme.background,
      child: Center(
        child: Container(
          margin: const EdgeInsets.all(24),
          padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(
            color:
                themeController.isDarkMode
                    ? ColorTheme.surfaceDark
                    : ColorTheme.surface,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: (themeController.isDarkMode
                        ? ColorTheme.primaryDark
                        : ColorTheme.primary)
                    .withOpacity(0.08),
                blurRadius: 24,
                offset: const Offset(0, 12),
                spreadRadius: 0,
              ),
              BoxShadow(
                color: (themeController.isDarkMode
                        ? ColorTheme.textPrimaryDark
                        : ColorTheme.textPrimary)
                    .withOpacity(0.04),
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
                      (themeController.isDarkMode
                              ? ColorTheme.primaryDark
                              : ColorTheme.primary)
                          .withOpacity(0.1),
                      (themeController.isDarkMode
                              ? ColorTheme.primaryDark
                              : ColorTheme.primary)
                          .withOpacity(0.05),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  size: 48,
                  color:
                      themeController.isDarkMode
                          ? ColorTheme.primaryDark
                          : ColorTheme.primary,
                ),
              ),
              const SizedBox(height: 24),
              Text(
                title,
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color:
                      themeController.isDarkMode
                          ? ColorTheme.textPrimaryDark
                          : ColorTheme.textPrimary,
                  fontFamily: 'JosefinSans',
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              Text(
                message,
                style: TextStyle(
                  fontSize: 15,
                  color:
                      themeController.isDarkMode
                          ? ColorTheme.textTertiaryDark
                          : ColorTheme.textSecondary,
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

  Future<void> _fetchServiceIfNeeded() async {
    if (serviceId.isEmpty) {
      Get.snackbar(
        'Error',
        'No service ID provided',
        backgroundColor:
            themeController.isDarkMode
                ? ColorTheme.errorDark
                : ColorTheme.error,
        colorText: ColorTheme.textInverse,
      );
      return;
    }

    if (controller.selectedService.value == null ||
        controller.selectedService.value!.id != serviceId) {
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        await controller.getServiceById(serviceId);
        if (controller.serviceCategories.isEmpty &&
            controller.categoryError.isEmpty) {
          await controller.fetchCategories();
        }
        _initializeFormWithServiceData();
      });
    }
  }

  void _initializeFormWithServiceData() {
    if (controller.selectedService.value != null) {
      final service = controller.selectedService.value!;
      nameController.text = service.name;
      descriptionController.text = service.description;
      durationController.text = service.duration.toString();
      selectedCategoryId.value = service.categoryId;
      currentImageUrl.value = service.imageUrl ?? '';
      hasPriceTiers.value = service.hasPriceTiers;

      if (!service.hasPriceTiers) {
        priceController.text = service.price.toString();
        minAgeController.text = service.minBabyAge.toString();
        maxAgeController.text = service.maxBabyAge.toString();
      } else {
        if (service.priceTiers != null && service.priceTiers!.isNotEmpty) {
          priceTiers.clear();
          priceTierControllers.clear();
          for (var tier in service.priceTiers!) {
            priceTiers.add({
              'minAge': tier.minBabyAge,
              'maxAge': tier.maxBabyAge,
              'price': tier.price,
              'tierName': tier.tierName,
            });
          }
          for (int i = 0; i < priceTiers.length; i++) {
            _initializePriceTierControllers(i);
          }
        } else {
          _addInitialPriceTier();
        }
      }
    }
  }

  void _addInitialPriceTier() {
    priceTiers.add({
      'minAge': 0,
      'maxAge': 12,
      'price': 0.0,
      'tierName': 'Tier ${priceTiers.length + 1}',
    });
    _initializePriceTierControllers(priceTiers.length - 1);
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
    return Container(
      color:
          themeController.isDarkMode
              ? ColorTheme.backgroundDark
              : ColorTheme.background,
      child: Form(
        key: formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSectionHeader('Service Details', Icons.edit_outlined),
              const SizedBox(height: 24),
              _buildProgressIndicator(),
              const SizedBox(height: 32),
              _buildImagePickerCard(),
              const SizedBox(height: 24),
              _buildCard(
                child: Column(
                  children: [
                    _buildSectionTitle('Basic Information'),
                    const SizedBox(height: 24),
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
              _buildCard(
                child: Column(
                  children: [
                    _buildSectionTitle('Pricing Configuration'),
                    const SizedBox(height: 24),
                    _buildPriceTierSwitch(),
                    const SizedBox(height: 24),
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
          colors:
              themeController.isDarkMode
                  ? [
                    (ColorTheme.primaryDark).withOpacity(0.1),
                    (ColorTheme.primaryDark).withOpacity(0.05),
                  ]
                  : [
                    ColorTheme.primary.withOpacity(0.05),
                    ColorTheme.primary.withOpacity(0.02),
                  ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: (themeController.isDarkMode
                  ? ColorTheme.primaryDark
                  : ColorTheme.primary)
              .withOpacity(0.1),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: (themeController.isDarkMode
                      ? ColorTheme.primaryDark
                      : ColorTheme.primary)
                  .withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              Icons.settings_outlined,
              color:
                  themeController.isDarkMode
                      ? ColorTheme.primaryDark
                      : ColorTheme.primary,
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
                    color:
                        themeController.isDarkMode
                            ? ColorTheme.textSecondaryDark
                            : ColorTheme.textPrimary,
                    fontFamily: 'JosefinSans',
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Update your service details and pricing information',
                  style: TextStyle(
                    fontSize: 13,
                    color:
                        themeController.isDarkMode
                            ? ColorTheme.textTertiaryDark
                            : ColorTheme.textSecondary,
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
    final primaryCurrent =
        themeController.isDarkMode
            ? ColorTheme.primaryDark
            : ColorTheme.primary;
    final primaryDarkCurrent =
        themeController.isDarkMode
            ? ColorTheme.primary
            : ColorTheme.primaryDark;

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  primaryCurrent.withOpacity(0.15),
                  primaryCurrent.withOpacity(0.08),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, size: 24, color: primaryCurrent),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color:
                        themeController.isDarkMode
                            ? ColorTheme.textPrimaryDark
                            : ColorTheme.textPrimary,
                    fontFamily: 'JosefinSans',
                  ),
                ),
                const SizedBox(height: 4),
                Container(
                  height: 3,
                  width: 40,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [primaryCurrent, primaryDarkCurrent],
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
        color:
            themeController.isDarkMode
                ? ColorTheme.surfaceDark
                : ColorTheme.surface,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: (themeController.isDarkMode
                    ? ColorTheme.primaryDark
                    : ColorTheme.primary)
                .withOpacity(0.06),
            blurRadius: 20,
            offset: const Offset(0, 8),
            spreadRadius: 0,
          ),
          BoxShadow(
            color: (themeController.isDarkMode
                    ? ColorTheme.textPrimaryDark
                    : ColorTheme.textPrimary)
                .withOpacity(0.03),
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
    final primaryCurrent =
        themeController.isDarkMode
            ? ColorTheme.primaryDark
            : ColorTheme.primary;
    final primaryDarkCurrent =
        themeController.isDarkMode
            ? ColorTheme.primary
            : ColorTheme.primaryDark;
    return Row(
      children: [
        Container(
          width: 4,
          height: 24,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [primaryCurrent, primaryDarkCurrent],
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
            color:
                themeController.isDarkMode
                    ? ColorTheme.textSecondaryDark
                    : ColorTheme.textPrimary,
            fontFamily: 'JosefinSans',
          ),
        ),
      ],
    );
  }

  Widget _buildImagePickerCard() {
    final primaryCurrent =
        themeController.isDarkMode
            ? ColorTheme.primaryDark
            : ColorTheme.primary;
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
                    colors:
                        themeController.isDarkMode
                            ? [ColorTheme.borderDark, ColorTheme.surfaceDark]
                            : [ColorTheme.surface, ColorTheme.background],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: primaryCurrent.withOpacity(0.2),
                    width: 2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: primaryCurrent.withOpacity(0.08),
                      blurRadius: 16,
                      offset: const Offset(0, 8),
                    ),
                    BoxShadow(
                      color: (themeController.isDarkMode
                              ? ColorTheme.textPrimaryDark
                              : ColorTheme.textPrimary)
                          .withOpacity(0.04),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
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
                                  Colors.black.withOpacity(0.7),
                                  Colors.black.withOpacity(0.5),
                                ],
                              ),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.edit,
                              color: ColorTheme.textInverse,
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
                                  Colors.black.withOpacity(0.7),
                                  Colors.black.withOpacity(0.5),
                                ],
                              ),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.edit,
                              color: ColorTheme.textInverse,
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
              color:
                  themeController.isDarkMode
                      ? ColorTheme.textTertiaryDark
                      : ColorTheme.textSecondary,
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
    final primaryCurrent =
        themeController.isDarkMode
            ? ColorTheme.primaryDark
            : ColorTheme.primary;
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                primaryCurrent.withOpacity(0.1),
                primaryCurrent.withOpacity(0.05),
              ],
            ),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, size: 48, color: primaryCurrent.withOpacity(0.8)),
        ),
        const SizedBox(height: 16),
        Text(
          text,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: primaryCurrent,
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
                color:
                    themeController.isDarkMode
                        ? ColorTheme.textSecondaryDark
                        : ColorTheme.textPrimary,
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
            border: Border.all(
              color:
                  themeController.isDarkMode
                      ? ColorTheme.borderDark
                      : ColorTheme.border.withOpacity(0.3),
            ),
            gradient: LinearGradient(
              colors:
                  themeController.isDarkMode
                      ? [
                        ColorTheme.borderDark,
                        ColorTheme.surfaceDark.withOpacity(0.8),
                      ]
                      : [
                        ColorTheme.surface,
                        ColorTheme.background.withOpacity(0.3),
                      ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            boxShadow: [
              BoxShadow(
                color: (themeController.isDarkMode
                        ? ColorTheme.textPrimaryDark
                        : ColorTheme.textPrimary)
                    .withOpacity(0.02),
                blurRadius: 8,
                offset: const Offset(0, 2),
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
              hintStyle: TextStyle(
                color:
                    themeController.isDarkMode
                        ? ColorTheme.textTertiaryDark
                        : Colors.grey.shade500,
              ),
            ),
            dropdownColor:
                themeController.isDarkMode
                    ? ColorTheme.borderDark
                    : ColorTheme.surface,
            style: TextStyle(
              color:
                  themeController.isDarkMode
                      ? ColorTheme.textPrimaryDark
                      : ColorTheme.textPrimary,
              fontFamily: 'JosefinSans',
              fontSize: 16,
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
    final primaryCurrent =
        themeController.isDarkMode
            ? ColorTheme.primaryDark
            : ColorTheme.primary;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            primaryCurrent.withOpacity(0.06),
            primaryCurrent.withOpacity(0.03),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: primaryCurrent.withOpacity(0.1)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  primaryCurrent.withOpacity(0.15),
                  primaryCurrent.withOpacity(0.08),
                ],
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(Icons.tune_outlined, color: primaryCurrent, size: 24),
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
                    color:
                        themeController.isDarkMode
                            ? ColorTheme.textSecondaryDark
                            : ColorTheme.textPrimary,
                    fontFamily: 'JosefinSans',
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Enable different pricing for different age groups',
                  style: TextStyle(
                    fontSize: 13,
                    color:
                        themeController.isDarkMode
                            ? ColorTheme.textTertiaryDark
                            : ColorTheme.textSecondary,
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
                  color: primaryCurrent.withOpacity(0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Switch(
              value: hasPriceTiers.value,
              onChanged: (value) {
                hasPriceTiers.value = value;
                if (value && priceTiers.isEmpty) {
                  _addInitialPriceTier();
                }
              },
              activeColor: primaryCurrent,
              activeTrackColor: primaryCurrent.withOpacity(0.3),
              inactiveThumbColor:
                  themeController.isDarkMode
                      ? ColorTheme.textTertiaryDark.withOpacity(0.6)
                      : Colors.grey.shade400,
              inactiveTrackColor:
                  themeController.isDarkMode
                      ? ColorTheme.borderDark
                      : Colors.grey.shade300,
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSimplePricing() {
    final simplePricingAccent =
        themeController.isDarkMode
            ? ColorTheme.successDark
            : ColorTheme.success;
    return Container(
      key: const ValueKey('simple_pricing'),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            simplePricingAccent.withOpacity(0.03),
            simplePricingAccent.withOpacity(0.01),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: simplePricingAccent.withOpacity(0.1)),
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
                      simplePricingAccent.withOpacity(0.15),
                      simplePricingAccent.withOpacity(0.08),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  Icons.attach_money_outlined,
                  color: simplePricingAccent,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'Simple Pricing',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color:
                      themeController.isDarkMode
                          ? ColorTheme.textSecondaryDark
                          : ColorTheme.textPrimary,
                  fontFamily: 'JosefinSans',
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          AppTextField(
            controller: priceController,
            label: 'Price (Rp)',
            placeholder: 'Enter service price',
            keyboardType: TextInputType.number,
            isRequired: true,
            validator: (value) {
              if (value == null || value.isEmpty) return 'Price is required';
              if (double.tryParse(value) == null || double.parse(value) < 0) {
                return 'Please enter a valid price';
              }
              return null;
            },
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      (themeController.isDarkMode
                              ? ColorTheme.primaryDark
                              : ColorTheme.primary)
                          .withOpacity(0.15),
                      (themeController.isDarkMode
                              ? ColorTheme.primaryDark
                              : ColorTheme.primary)
                          .withOpacity(0.08),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  Icons.child_care_outlined,
                  color:
                      themeController.isDarkMode
                          ? ColorTheme.primaryDark
                          : ColorTheme.primary,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'Age Range',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color:
                      themeController.isDarkMode
                          ? ColorTheme.textSecondaryDark
                          : ColorTheme.textPrimary,
                  fontFamily: 'JosefinSans',
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          // ✨ --- PERBAIKAN DI SINI --- ✨
          // Mengubah Row menjadi Column untuk mencegah overflow horizontal.
          Column(
            children: [
              AppTextField(
                controller: minAgeController,
                label: 'Min Age (months)',
                placeholder: 'Min',
                keyboardType: TextInputType.number,
                isRequired: true,
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Required';
                  if (int.tryParse(value) == null || int.parse(value) < 0) {
                    return 'Invalid';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20), // Memberi jarak vertikal antar field
              AppTextField(
                controller: maxAgeController,
                label: 'Max Age (months)',
                placeholder: 'Max',
                keyboardType: TextInputType.number,
                isRequired: true,
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Required';
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
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPriceTiers() {
    final priceTierAccent =
        themeController.isDarkMode ? ColorTheme.infoDark : ColorTheme.info;
    final primaryCurrent =
        themeController.isDarkMode
            ? ColorTheme.primaryDark
            : ColorTheme.primary;

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
                  priceTierAccent.withOpacity(0.03),
                  priceTierAccent.withOpacity(0.01),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: priceTierAccent.withOpacity(0.1)),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        priceTierAccent.withOpacity(0.15),
                        priceTierAccent.withOpacity(0.08),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    Icons.layers_outlined,
                    color: priceTierAccent,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  'Price Tiers',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color:
                        themeController.isDarkMode
                            ? ColorTheme.textSecondaryDark
                            : ColorTheme.textPrimary,
                    fontFamily: 'JosefinSans',
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
                  final controllers = priceTierControllers[index]!;
                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 400),
                    curve: Curves.easeInOutCubic,
                    margin: const EdgeInsets.only(bottom: 20),
                    child: Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color:
                            themeController.isDarkMode
                                ? ColorTheme.borderDark
                                : ColorTheme.surface,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: primaryCurrent.withOpacity(0.15),
                          width: 1.5,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: primaryCurrent.withOpacity(0.08),
                            blurRadius: 16,
                            offset: const Offset(0, 6),
                          ),
                          BoxShadow(
                            color: (themeController.isDarkMode
                                    ? ColorTheme.textPrimaryDark
                                    : ColorTheme.textPrimary)
                                .withOpacity(0.02),
                            blurRadius: 4,
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
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 8,
                                ),
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      primaryCurrent.withOpacity(0.15),
                                      primaryCurrent.withOpacity(0.08),
                                    ],
                                  ),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  'Tier ${index + 1}',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w700,
                                    color: primaryCurrent,
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
                                        ColorTheme.error.withOpacity(0.1),
                                        ColorTheme.error.withOpacity(0.05),
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
                                      final newControllers =
                                          <
                                            int,
                                            Map<String, TextEditingController>
                                          >{};
                                      for (
                                        int i = 0;
                                        i < priceTierControllers.length;
                                        i++
                                      ) {
                                        if (priceTierControllers.containsKey(
                                          i < index ? i : i + 1,
                                        )) {
                                          newControllers[i] =
                                              priceTierControllers[i < index
                                                  ? i
                                                  : i + 1]!;
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
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color:
                                  themeController.isDarkMode
                                      ? ColorTheme.surfaceDark.withOpacity(0.5)
                                      : ColorTheme.background.withOpacity(0.6),
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
                                    color:
                                        themeController.isDarkMode
                                            ? ColorTheme.textSecondaryDark
                                            : ColorTheme.textPrimary,
                                    fontFamily: 'JosefinSans',
                                  ),
                                ),
                                const SizedBox(height: 16),
                                // ✨ --- PERBAIKAN DI SINI JUGA --- ✨
                                // Mengubah Row menjadi Column di dalam price tier.
                                Column(
                                  children: [
                                    AppTextField(
                                      placeholder: 'Min Age',
                                      keyboardType: TextInputType.number,
                                      controller: controllers['minAge'],
                                      validator:
                                          (v) =>
                                              (v == null || v.isEmpty)
                                                  ? 'Required'
                                                  : (int.tryParse(v) == null ||
                                                      int.parse(v) < 0)
                                                  ? 'Invalid'
                                                  : null,
                                      onChanged:
                                          (v) =>
                                              priceTiers[index]['minAge'] =
                                                  int.tryParse(v) ?? 0,
                                    ),
                                    const SizedBox(height: 20),
                                    AppTextField(
                                      placeholder: 'Max Age',
                                      keyboardType: TextInputType.number,
                                      controller: controllers['maxAge'],
                                      validator: (v) {
                                        if (v == null || v.isEmpty) {
                                          return 'Required';
                                        }
                                        final minAge = int.tryParse(
                                          controllers['minAge']!.text,
                                        );
                                        if (minAge == null) {
                                          return 'Min Invalid';
                                        }
                                        return (int.tryParse(v) == null ||
                                                int.parse(v) <= minAge)
                                            ? 'Invalid'
                                            : null;
                                      },
                                      onChanged:
                                          (v) =>
                                              priceTiers[index]['maxAge'] =
                                                  int.tryParse(v) ?? 0,
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 20),
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  (themeController.isDarkMode
                                          ? ColorTheme.successDark
                                          : ColorTheme.success)
                                      .withOpacity(0.05),
                                  (themeController.isDarkMode
                                          ? ColorTheme.successDark
                                          : ColorTheme.success)
                                      .withOpacity(0.02),
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
                                    color:
                                        themeController.isDarkMode
                                            ? ColorTheme.textSecondaryDark
                                            : ColorTheme.textPrimary,
                                    fontFamily: 'JosefinSans',
                                  ),
                                ),
                                const SizedBox(height: 16),
                                AppTextField(
                                  placeholder: 'Enter price for this tier',
                                  keyboardType: TextInputType.number,
                                  controller: controllers['price'],
                                  validator:
                                      (v) =>
                                          (v == null || v.isEmpty)
                                              ? 'Required'
                                              : (double.tryParse(v) == null ||
                                                  double.parse(v) < 0)
                                              ? 'Invalid'
                                              : null,
                                  onChanged:
                                      (v) =>
                                          priceTiers[index]['price'] =
                                              double.tryParse(v) ?? 0.0,
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
          const SizedBox(height: 20),
          Center(
            child: AppButton(
              text: 'Add Price Tier',
              icon: Icons.add,
              onPressed: () {
                final lastMaxAge =
                    priceTiers.isNotEmpty ? priceTiers.last['maxAge'] : -1;
                final newIndex = priceTiers.length;
                priceTiers.add({
                  'minAge': lastMaxAge + 1,
                  'maxAge': lastMaxAge + 13,
                  'price': 0.0,
                  'tierName': 'Tier ${newIndex + 1}',
                });
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
    final primaryCurrent =
        themeController.isDarkMode
            ? ColorTheme.primaryDark
            : ColorTheme.primary;
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            primaryCurrent.withOpacity(0.1),
            primaryCurrent.withOpacity(0.05),
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
        bool isValid = true;
        for (int i = 0; i < priceTiers.length; i++) {
          final tier = priceTiers[i];
          final minAgeCtrl = priceTierControllers[i]?['minAge'];
          final maxAgeCtrl = priceTierControllers[i]?['maxAge'];
          final priceCtrl = priceTierControllers[i]?['price'];

          if (minAgeCtrl == null ||
              maxAgeCtrl == null ||
              priceCtrl == null ||
              minAgeCtrl.text.isEmpty ||
              maxAgeCtrl.text.isEmpty ||
              priceCtrl.text.isEmpty) {
            isValid = false;
            break;
          }
          tier['minAge'] = int.tryParse(minAgeCtrl.text) ?? 0;
          tier['maxAge'] = int.tryParse(maxAgeCtrl.text) ?? 0;
          tier['price'] = double.tryParse(priceCtrl.text) ?? 0.0;
        }

        if (!isValid) {
          Get.snackbar(
            'Validation Error',
            'Please complete all price tier fields with valid numbers.',
            backgroundColor:
                themeController.isDarkMode
                    ? ColorTheme.errorDark
                    : ColorTheme.error,
            colorText: ColorTheme.textInverse,
          );
          return;
        }

        List<Map<String, dynamic>> formattedPriceTiers =
            priceTiers.map((tier) {
              return {
                'minBabyAge': tier['minAge'],
                'maxBabyAge': tier['maxAge'],
                'price': tier['price'],
                'tierName':
                    tier['tierName'] ?? 'Tier ${priceTiers.indexOf(tier) + 1}',
              };
            }).toList();

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
              if (service != null) Get.back();
            });
      } else {
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
              if (service != null) Get.back();
            });
      }
    }
  }
}
