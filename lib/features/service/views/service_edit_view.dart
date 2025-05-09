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
        appBar: const CustomAppBar(title: 'Edit Service', showBackButton: true),
        body: Obx(() {
          if (controller.isFetchingServiceDetail.value) {
            return const Center(child: CircularProgressIndicator());
          }

          if (controller.isLoadingCategories.value) {
            return const Center(child: CircularProgressIndicator());
          }

          if (controller.selectedService.value == null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('No service selected or service not found.'),
                  const SizedBox(height: 16),
                  AppButton(
                    text: 'Refresh',
                    onPressed: () => _fetchServiceIfNeeded(),
                    type: AppButtonType.primary,
                  ),
                  const SizedBox(height: 16),
                  AppButton(
                    text: 'Go Back',
                    onPressed: () => Get.back(),
                    type: AppButtonType.outline,
                  ),
                ],
              ),
            );
          }

          if (controller.categoryError.isNotEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Error: ${controller.categoryError.value}'),
                  const SizedBox(height: 16),
                  AppButton(
                    text: 'Refresh',
                    onPressed: controller.fetchCategories,
                    type: AppButtonType.primary,
                  ),
                ],
              ),
            );
          }

          if (controller.serviceCategories.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'No service categories found. Please add categories first.',
                  ),
                  const SizedBox(height: 16),
                  AppButton(
                    text: 'Go to Categories',
                    onPressed: () => Get.toNamed('/service-categories'),
                    type: AppButtonType.primary,
                  ),
                ],
              ),
            );
          }

          return _buildForm(context);
        }),
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
    return Form(
      key: formKey,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildImagePicker(),
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
            const SizedBox(height: 16),

            // Service Description
            AppTextField(
              controller: descriptionController,
              label: 'Description',
              placeholder: 'Enter service description',
              maxLines: 3,
            ),
            const SizedBox(height: 16),

            // Service Category Dropdown
            _buildCategoryDropdown(),
            const SizedBox(height: 16),

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
                if (int.tryParse(value) == null || int.parse(value) <= 0) {
                  return 'Please enter a valid duration';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Price Tier Switch
            _buildPriceTierSwitch(),
            const SizedBox(height: 16),

            // Baby Age Range (for simple pricing) or Price Tiers
            Obx(
              () =>
                  !hasPriceTiers.value
                      ? _buildSimplePricing()
                      : _buildPriceTiers(),
            ),

            const SizedBox(height: 32),

            // Submit Button
            Obx(
              () => AppButton(
                text: 'Update Service',
                isLoading: controller.isUpdatingService.value,
                onPressed: _submitForm,
                type: AppButtonType.primary,
                size: AppButtonSize.large,
                isFullWidth: true,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImagePicker() {
    return Center(
      child: GestureDetector(
        onTap: _pickImage,
        child: Container(
          width: 150,
          height: 150,
          decoration: BoxDecoration(
            color: ColorTheme.background,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: ColorTheme.primary.withValues(alpha: 0.5),
            ),
          ),
          child: Obx(() {
            if (imageFile.value != null) {
              return ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.file(imageFile.value!, fit: BoxFit.cover),
              );
            } else if (currentImageUrl.value.isNotEmpty) {
              return ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(
                  currentImageUrl.value,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.image_not_supported_outlined,
                          size: 50,
                          color: ColorTheme.primary,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Image not available',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: ColorTheme.primary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    );
                  },
                ),
              );
            } else {
              return Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.add_photo_alternate_outlined,
                    size: 50,
                    color: ColorTheme.primary,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Add Service Image',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: ColorTheme.primary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              );
            }
          }),
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
        const SizedBox(height: 6),
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: ColorTheme.border),
            color: Colors.white,
          ),
          child: DropdownButtonFormField<String>(
            decoration: InputDecoration(
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 8,
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
                    child: Text(category.name),
                  );
                }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildPriceTierSwitch() {
    return Row(
      children: [
        Expanded(
          child: Text(
            'Multiple Price Tiers',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: ColorTheme.textPrimary,
            ),
          ),
        ),
        Switch(
          value: hasPriceTiers.value,
          onChanged: (value) {
            hasPriceTiers.value = value;

            // Initialize price tiers if switching to multiple tiers
            if (value && priceTiers.isEmpty) {
              _addInitialPriceTier();
            }
          },
          activeColor: ColorTheme.primary,
        ),
      ],
    );
  }

  Widget _buildSimplePricing() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
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
        const SizedBox(height: 16),

        // Baby Age Range
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
            const SizedBox(width: 12),
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
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Price Tiers',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: ColorTheme.textPrimary,
          ),
        ),
        const SizedBox(height: 8),

        // List of price tiers
        Obx(
          () => ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: priceTiers.length,
            itemBuilder: (context, index) {
              // Ensure controllers exist for this index
              if (!priceTierControllers.containsKey(index)) {
                _initializePriceTierControllers(index);
              }

              final controllers = priceTierControllers[index]!;

              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              'Price Tier ${index + 1}',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: ColorTheme.primary,
                              ),
                            ),
                          ),
                          if (priceTiers.length > 1)
                            IconButton(
                              icon: Icon(Icons.delete, color: ColorTheme.error),
                              onPressed: () {
                                priceTiers.removeAt(index);
                                priceTierControllers.remove(index);
                                // Reindex the controllers
                                final newControllers =
                                    <int, Map<String, TextEditingController>>{};
                                for (int i = 0; i < priceTiers.length; i++) {
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
                        ],
                      ),
                      const SizedBox(height: 8),

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
                          const SizedBox(width: 12),
                          Expanded(
                            child: AppTextField(
                              placeholder: 'Max Age (months)',
                              keyboardType: TextInputType.number,
                              controller: controllers['maxAge'],
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Required';
                                }

                                final minAgeText = controllers['minAge']!.text;
                                if (minAgeText.isEmpty ||
                                    int.tryParse(minAgeText) == null) {
                                  return 'Enter min age first';
                                }

                                if (int.tryParse(value) == null ||
                                    int.parse(value) <= int.parse(minAgeText)) {
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
                      const SizedBox(height: 12),

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
            },
          ),
        ),

        // Add new tier button
        Center(
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
