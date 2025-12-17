// lib/features/service/views/service_form_view.dart
import 'dart:io';

import 'package:emababyspa/common/theme/app_theme.dart';
import 'package:emababyspa/common/theme/semantic_colors.dart';
import 'package:emababyspa/common/widgets/app_button.dart';
import 'package:emababyspa/common/widgets/app_text_field.dart';
import 'package:emababyspa/common/widgets/custom_appbar.dart';
import 'package:emababyspa/common/layouts/main_layout.dart';
import 'package:emababyspa/features/service/controllers/service_controller.dart';
import 'package:emababyspa/features/theme/controllers/theme_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

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

  final ThemeController themeController = Get.find<ThemeController>();

  @override
  Widget build(BuildContext context) {
    if (priceTiers.isEmpty) {
      priceTiers.add({'minAge': 0, 'maxAge': 12, 'price': 0.0});
      _initializePriceTierControllers(0);
    }

    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final tt = theme.textTheme;
    final spacing = theme.extension<AppSpacing>() ?? const AppSpacing();
    final semantic = theme.extension<AppSemanticColors>();

    final infoTone = semantic?.info ?? cs.secondary;
    final warningTone = semantic?.warning ?? cs.tertiary;
    final dangerTone = semantic?.danger ?? cs.error;

    return MainLayout(
      child: Scaffold(
        backgroundColor: cs.surface,
        appBar: const CustomAppBar(
          title: 'Tambah Layanan',
          showBackButton: true,
        ),
        body: SafeArea(
          child: Obx(() {
            if (controller.isLoadingCategories.value ||
                controller.isLoadingStaff.value) {
              return _LoadingState(
                title: 'Menyiapkan data layanan…',
                subtitle: 'Tunggu sebentar ya.',
              );
            }

            if (controller.categoryError.isNotEmpty) {
              return _MessageState(
                icon: Icons.error_outline_rounded,
                title: 'Terjadi kendala',
                message: controller.categoryError.value,
                buttonLabel: 'Coba Lagi',
                onPressed: controller.fetchCategories,
                tone: dangerTone,
              );
            }

            if (controller.serviceCategories.isEmpty) {
              return _MessageState(
                icon: Icons.category_outlined,
                title: 'Kategori belum tersedia',
                message:
                    'Tambahkan kategori layanan terlebih dahulu agar kamu bisa membuat layanan baru.',
                buttonLabel: 'Kelola Kategori',
                onPressed: () => Get.toNamed('/service-categories'),
                tone: infoTone,
              );
            }

            return _buildForm(
              context,
              infoTone: infoTone,
              warningTone: warningTone,
              dangerTone: dangerTone,
              spacing: spacing,
              tt: tt,
              cs: cs,
            );
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

  Widget _buildForm(
    BuildContext context, {
    required Color infoTone,
    required Color warningTone,
    required Color dangerTone,
    required AppSpacing spacing,
    required TextTheme tt,
    required ColorScheme cs,
  }) {
    return Form(
      key: formKey,
      child: SingleChildScrollView(
        padding: EdgeInsets.all(spacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _HeaderCard(
              title: 'Buat Layanan Baru',
              subtitle: 'Lengkapi detail di bawah untuk menambahkan layanan.',
              icon: Icons.spa_outlined,
            ),
            SizedBox(height: spacing.xl),

            _SectionCard(
              title: 'Foto Layanan',
              subtitle: 'Opsional, tapi sangat membantu agar terlihat menarik.',
              leadingIcon: Icons.image_outlined,
              child: _buildImagePicker(context),
            ),
            SizedBox(height: spacing.lg),

            _SectionCard(
              title: 'Informasi Dasar',
              subtitle: 'Nama, deskripsi, kategori, dan durasi.',
              leadingIcon: Icons.info_outline_rounded,
              child: Column(
                children: [
                  AppTextField(
                    controller: nameController,
                    label: 'Nama layanan',
                    placeholder: 'Contoh: Baby Spa Premium',
                    isRequired: true,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Nama layanan wajib diisi';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: spacing.lg),
                  AppTextField(
                    controller: descriptionController,
                    label: 'Deskripsi',
                    placeholder: 'Tulis ringkas manfaat & detail layanan',
                    maxLines: 3,
                  ),
                  SizedBox(height: spacing.lg),
                  _buildCategoryDropdown(context),
                  SizedBox(height: spacing.lg),
                  AppTextField(
                    controller: durationController,
                    label: 'Durasi (menit)',
                    placeholder: 'Contoh: 60',
                    keyboardType: TextInputType.number,
                    isRequired: true,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Durasi wajib diisi';
                      }
                      final parsed = int.tryParse(value);
                      if (parsed == null || parsed <= 0) {
                        return 'Masukkan durasi yang valid';
                      }
                      return null;
                    },
                  ),
                ],
              ),
            ),

            SizedBox(height: spacing.lg),

            _SectionCard(
              title: 'Harga',
              subtitle: 'Atur harga tunggal atau bertingkat berdasarkan usia.',
              leadingIcon: Icons.payments_outlined,
              child: Column(
                children: [
                  _buildPriceTierSwitch(context, infoTone: infoTone),
                  SizedBox(height: spacing.lg),
                  Obx(
                    () => AnimatedSwitcher(
                      duration: const Duration(milliseconds: 220),
                      switchInCurve: Curves.easeOut,
                      switchOutCurve: Curves.easeIn,
                      child:
                          !hasPriceTiers.value
                              ? _buildSimplePricing(context, infoTone: infoTone)
                              : _buildPriceTiers(
                                context,
                                warningTone: warningTone,
                                dangerTone: dangerTone,
                              ),
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(height: spacing.xl),

            Obx(
              () => AppButton(
                text: 'Simpan Layanan',
                isLoading: controller.isCreatingService.value,
                onPressed: _submitForm,
                type: AppButtonType.primary,
                size: AppButtonSize.large,
                isFullWidth: true,
              ),
            ),

            SizedBox(height: spacing.md),
          ],
        ),
      ),
    );
  }

  // =========================
  // IMAGE PICKER (balanced + theme-only)
  // =========================
  Widget _buildImagePicker(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final tt = theme.textTheme;
    final spacing = theme.extension<AppSpacing>() ?? const AppSpacing();

    final border = cs.outlineVariant.withValues(alpha: 0.65);
    final bg = cs.surfaceContainerHighest.withValues(alpha: 0.35);

    return Center(
      child: InkWell(
        onTap: _pickImage,
        borderRadius: BorderRadius.circular(AppRadii.xl),
        child: Ink(
          width: 220,
          height: 220,
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(AppRadii.xl),
            border: Border.all(color: border, width: 1),
          ),
          child: Obx(() {
            final file = imageFile.value;
            if (file != null) {
              return Stack(
                fit: StackFit.expand,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(AppRadii.xl),
                    child: Image.file(
                      file,
                      fit: BoxFit.cover,
                      width: double.infinity,
                      height: double.infinity,
                    ),
                  ),
                  Positioned(
                    top: spacing.sm,
                    right: spacing.sm,
                    child: Container(
                      padding: EdgeInsets.all(spacing.xs),
                      decoration: BoxDecoration(
                        color: cs.surface.withValues(alpha: 0.92),
                        borderRadius: BorderRadius.circular(AppRadii.md),
                        border: Border.all(
                          color: cs.outlineVariant.withValues(alpha: 0.55),
                        ),
                      ),
                      child: Icon(
                        Icons.edit_rounded,
                        size: 18,
                        color: cs.primary,
                      ),
                    ),
                  ),
                ],
              );
            }

            return Padding(
              padding: EdgeInsets.all(spacing.lg),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: EdgeInsets.all(spacing.md),
                    decoration: BoxDecoration(
                      color: cs.primary.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(AppRadii.lg),
                      border: Border.all(
                        color: cs.primary.withValues(alpha: 0.22),
                      ),
                    ),
                    child: Icon(
                      Icons.add_photo_alternate_outlined,
                      size: 40,
                      color: cs.primary,
                    ),
                  ),
                  SizedBox(height: spacing.md),
                  Text(
                    'Tambah foto',
                    textAlign: TextAlign.center,
                    style: tt.titleMedium?.copyWith(
                      fontWeight: FontWeight.w900,
                      color: cs.onSurface,
                    ),
                  ),
                  SizedBox(height: spacing.xs),
                  Text(
                    'Ketuk untuk memilih dari galeri',
                    textAlign: TextAlign.center,
                    style: tt.bodySmall?.copyWith(
                      color: cs.onSurfaceVariant,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            );
          }),
        ),
      ),
    );
  }

  // =========================
  // CATEGORY DROPDOWN (theme-only)
  // =========================
  Widget _buildCategoryDropdown(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final tt = theme.textTheme;
    final spacing = theme.extension<AppSpacing>() ?? const AppSpacing();

    final border = cs.outlineVariant.withValues(alpha: 0.65);
    final bg = cs.surfaceContainerHighest.withValues(alpha: 0.30);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'Kategori',
              style: tt.bodyMedium?.copyWith(
                fontWeight: FontWeight.w700,
                color: cs.onSurface,
              ),
            ),
            Text(
              ' *',
              style: tt.bodyMedium?.copyWith(
                fontWeight: FontWeight.w800,
                color: cs.error,
              ),
            ),
          ],
        ),
        SizedBox(height: spacing.sm),
        Container(
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(AppRadii.lg),
            border: Border.all(color: border, width: 1),
          ),
          child: DropdownButtonFormField<String>(
            dropdownColor: cs.surface,
            style: tt.bodyMedium?.copyWith(
              color: cs.onSurface,
              fontWeight: FontWeight.w700,
            ),
            decoration: InputDecoration(
              labelText: 'Pilih kategori',
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(
                horizontal: spacing.lg,
                vertical: spacing.md,
              ),
              prefixIcon: Icon(
                Icons.category_outlined,
                color: cs.primary,
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
                return 'Kategori wajib dipilih';
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

  // =========================
  // PRICE TIER SWITCH (balanced)
  // =========================
  Widget _buildPriceTierSwitch(
    BuildContext context, {
    required Color infoTone,
  }) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final tt = theme.textTheme;
    final spacing = theme.extension<AppSpacing>() ?? const AppSpacing();

    final border = cs.outlineVariant.withValues(alpha: 0.65);
    final bg = cs.surfaceContainerHighest.withValues(alpha: 0.28);

    return Container(
      padding: EdgeInsets.all(spacing.lg),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(AppRadii.xl),
        border: Border.all(color: border, width: 1),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(spacing.sm),
            decoration: BoxDecoration(
              color: cs.primary.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(AppRadii.md),
              border: Border.all(color: cs.primary.withValues(alpha: 0.22)),
            ),
            child: Icon(Icons.layers_outlined, color: cs.primary, size: 20),
          ),
          SizedBox(width: spacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Harga bertingkat',
                  style: tt.titleSmall?.copyWith(
                    fontWeight: FontWeight.w900,
                    color: cs.onSurface,
                  ),
                ),
                SizedBox(height: spacing.xs),
                Text(
                  'Aktifkan jika harga berbeda untuk rentang usia tertentu.',
                  style: tt.bodySmall?.copyWith(
                    color: cs.onSurfaceVariant,
                    fontWeight: FontWeight.w600,
                  ),
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
              activeColor: cs.primary,
              activeTrackColor: cs.primary.withValues(alpha: 0.30),
              inactiveThumbColor: cs.onSurfaceVariant.withValues(alpha: 0.70),
              inactiveTrackColor: cs.outlineVariant.withValues(alpha: 0.55),
            ),
          ),
        ],
      ),
    );
  }

  // =========================
  // SIMPLE PRICING
  // =========================
  Widget _buildSimplePricing(BuildContext context, {required Color infoTone}) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final tt = theme.textTheme;
    final spacing = theme.extension<AppSpacing>() ?? const AppSpacing();

    return Column(
      key: const ValueKey('simple'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _InfoBanner(
          icon: Icons.info_outline_rounded,
          tone: infoTone,
          text: 'Harga tunggal berlaku untuk semua rentang usia.',
        ),
        SizedBox(height: spacing.lg),
        AppTextField(
          controller: priceController,
          label: 'Harga (Rp)',
          placeholder: 'Contoh: 150000',
          keyboardType: TextInputType.number,
          isRequired: true,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Harga wajib diisi';
            }
            final parsed = double.tryParse(value);
            if (parsed == null || parsed < 0) {
              return 'Masukkan harga yang valid';
            }
            return null;
          },
        ),
        SizedBox(height: spacing.lg),
        Text(
          'Rentang usia bayi',
          style: tt.titleSmall?.copyWith(
            fontWeight: FontWeight.w900,
            color: cs.onSurface,
          ),
        ),
        SizedBox(height: spacing.sm),
        Column(
          children: [
            AppTextField(
              controller: minAgeController,
              label: 'Usia minimum (bulan)',
              placeholder: 'Contoh: 0',
              keyboardType: TextInputType.number,
              isRequired: true,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Wajib diisi';
                }
                final parsed = int.tryParse(value);
                if (parsed == null || parsed < 0) {
                  return 'Tidak valid';
                }
                return null;
              },
            ),
            SizedBox(height: spacing.lg),
            AppTextField(
              controller: maxAgeController,
              label: 'Usia maksimum (bulan)',
              placeholder: 'Contoh: 12',
              keyboardType: TextInputType.number,
              isRequired: true,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Wajib diisi';
                }
                final minAgeText = minAgeController.text;
                final minParsed = int.tryParse(minAgeText);
                if (minParsed == null) {
                  return 'Isi usia minimum dulu';
                }
                final maxParsed = int.tryParse(value);
                if (maxParsed == null || maxParsed <= minParsed) {
                  return 'Harus lebih besar dari minimum';
                }
                return null;
              },
            ),
          ],
        ),
      ],
    );
  }

  // =========================
  // TIERS PRICING
  // =========================
  Widget _buildPriceTiers(
    BuildContext context, {
    required Color warningTone,
    required Color dangerTone,
  }) {
    final theme = Theme.of(context);
    final spacing = theme.extension<AppSpacing>() ?? const AppSpacing();

    return Column(
      key: const ValueKey('tiers'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _InfoBanner(
          icon: Icons.info_outline_rounded,
          tone: warningTone,
          text: 'Buat beberapa tier untuk rentang usia yang berbeda.',
        ),
        SizedBox(height: spacing.lg),
        Obx(
          () => Column(
            children: [
              ...List.generate(priceTiers.length, (index) {
                if (!priceTierControllers.containsKey(index)) {
                  _initializePriceTierControllers(index);
                }
                final currentTierControllers = priceTierControllers[index]!;
                return _TierCard(
                  index: index,
                  canDelete: priceTiers.length > 1,
                  dangerTone: dangerTone,
                  onDelete: () {
                    priceTiers.removeAt(index);

                    final tempControllers =
                        Map<int, Map<String, TextEditingController>>.from(
                          priceTierControllers,
                        );
                    priceTierControllers.clear();
                    tempControllers.remove(index);

                    int newKey = 0;
                    for (var oldKey in tempControllers.keys.toList()..sort()) {
                      final controllerSet = tempControllers[oldKey];
                      if (controllerSet != null) {
                        priceTierControllers[newKey] = controllerSet;
                        newKey++;
                      }
                    }
                  },
                  child: Column(
                    children: [
                      AppTextField(
                        label: 'Usia minimum (bulan)',
                        placeholder: 'Contoh: 0',
                        keyboardType: TextInputType.number,
                        controller: currentTierControllers['minAge'],
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Wajib diisi';
                          }
                          final parsed = int.tryParse(value);
                          if (parsed == null || parsed < 0) {
                            return 'Tidak valid';
                          }
                          return null;
                        },
                        onChanged: (value) {
                          final parsed = int.tryParse(value);
                          if (parsed != null) {
                            priceTiers[index]['minAge'] = parsed;
                          }
                        },
                      ),
                      SizedBox(height: spacing.md),
                      AppTextField(
                        label: 'Usia maksimum (bulan)',
                        placeholder: 'Contoh: 12',
                        keyboardType: TextInputType.number,
                        controller: currentTierControllers['maxAge'],
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Wajib diisi';
                          }
                          final minAgeText =
                              currentTierControllers['minAge']!.text;
                          final minParsed = int.tryParse(minAgeText);
                          if (minParsed == null) {
                            return 'Isi minimum dulu';
                          }
                          final maxParsed = int.tryParse(value);
                          if (maxParsed == null || maxParsed <= minParsed) {
                            return 'Harus > minimum';
                          }
                          return null;
                        },
                        onChanged: (value) {
                          final parsed = int.tryParse(value);
                          if (parsed != null) {
                            priceTiers[index]['maxAge'] = parsed;
                          }
                        },
                      ),
                      SizedBox(height: spacing.md),
                      AppTextField(
                        label: 'Harga (Rp)',
                        placeholder: 'Contoh: 150000',
                        keyboardType: TextInputType.number,
                        controller: currentTierControllers['price'],
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Wajib diisi';
                          }
                          final parsed = double.tryParse(value);
                          if (parsed == null || parsed < 0) {
                            return 'Tidak valid';
                          }
                          return null;
                        },
                        onChanged: (value) {
                          final parsed = double.tryParse(value);
                          if (parsed != null) {
                            priceTiers[index]['price'] = parsed;
                          }
                        },
                      ),
                    ],
                  ),
                );
              }),
            ],
          ),
        ),
        SizedBox(height: spacing.md),
        Align(
          alignment: Alignment.center,
          child: AppButton(
            text: 'Tambah Tier',
            type: AppButtonType.outline,
            icon: Icons.add_rounded,
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
      final name = nameController.text;
      final description = descriptionController.text;
      final duration = int.parse(durationController.text);
      final categoryId = selectedCategoryId.value;

      if (hasPriceTiers.value) {
        bool isValid = true;
        for (var i = 0; i < priceTiers.length; i++) {
          final tier = priceTiers[i];
          final tierControllerSet = priceTierControllers[i];

          if (tier['minAge'] == null ||
              tier['maxAge'] == null ||
              tier['price'] == null ||
              tierControllerSet == null ||
              tierControllerSet['minAge']!.text.isEmpty ||
              tierControllerSet['maxAge']!.text.isEmpty ||
              tierControllerSet['price']!.text.isEmpty) {
            isValid = false;
            break;
          }
          if (int.tryParse(tierControllerSet['minAge']!.text) == null ||
              int.tryParse(tierControllerSet['maxAge']!.text) == null ||
              double.tryParse(tierControllerSet['price']!.text) == null) {
            isValid = false;
            break;
          }
        }

        if (!isValid) {
          final theme = Theme.of(Get.context!);
          final cs = theme.colorScheme;

          Get.snackbar(
            'Validasi gagal',
            'Lengkapi semua field tier dengan benar.',
            backgroundColor: cs.error,
            colorText: cs.onError,
            snackPosition: SnackPosition.BOTTOM,
          );
          return;
        }

        List<Map<String, dynamic>> formattedPriceTiers =
            priceTiers.map((tier) {
              return {
                'minBabyAge': tier['minAge'],
                'maxBabyAge': tier['maxAge'],
                'price': tier['price'],
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
      final theme = Theme.of(Get.context!);
      final cs = theme.colorScheme;

      Get.snackbar(
        'Validasi gagal',
        'Periksa kembali field yang wajib diisi.',
        backgroundColor: cs.error,
        colorText: cs.onError,
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }
}

// =========================
// UI PARTS (theme-only)
// =========================

class _HeaderCard extends StatelessWidget {
  const _HeaderCard({
    required this.title,
    required this.subtitle,
    required this.icon,
  });

  final String title;
  final String subtitle;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final tt = theme.textTheme;
    final spacing = theme.extension<AppSpacing>() ?? const AppSpacing();

    final border = cs.primary.withValues(alpha: 0.22);

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(spacing.lg),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppRadii.xl),
        border: Border.all(color: border, width: 1),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            cs.primary.withValues(alpha: 0.14),
            cs.primary.withValues(alpha: 0.05),
          ],
        ),
      ),
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.all(spacing.sm),
            decoration: BoxDecoration(
              color: cs.primary.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(AppRadii.lg),
              border: Border.all(color: cs.primary.withValues(alpha: 0.20)),
            ),
            child: Icon(icon, size: 26, color: cs.primary),
          ),
          SizedBox(height: spacing.sm),
          Text(
            title,
            textAlign: TextAlign.center,
            style: tt.titleLarge?.copyWith(
              fontWeight: FontWeight.w900,
              color: cs.onSurface,
            ),
          ),
          SizedBox(height: spacing.xs),
          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: tt.bodyMedium?.copyWith(
              color: cs.onSurfaceVariant,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({
    required this.title,
    required this.subtitle,
    required this.leadingIcon,
    required this.child,
  });

  final String title;
  final String subtitle;
  final IconData leadingIcon;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final tt = theme.textTheme;
    final spacing = theme.extension<AppSpacing>() ?? const AppSpacing();

    final border = cs.outlineVariant.withValues(alpha: 0.65);

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(spacing.lg),
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.circular(AppRadii.xl),
        border: Border.all(color: border, width: 1),
        boxShadow: [
          BoxShadow(
            color: cs.shadow.withValues(alpha: 0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(spacing.sm),
                decoration: BoxDecoration(
                  color: cs.primary.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(AppRadii.md),
                  border: Border.all(color: cs.primary.withValues(alpha: 0.20)),
                ),
                child: Icon(leadingIcon, color: cs.primary, size: 20),
              ),
              SizedBox(width: spacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: tt.titleMedium?.copyWith(
                        fontWeight: FontWeight.w900,
                        color: cs.onSurface,
                      ),
                    ),
                    SizedBox(height: spacing.xs),
                    Text(
                      subtitle,
                      style: tt.bodySmall?.copyWith(
                        color: cs.onSurfaceVariant,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: spacing.lg),
          child,
        ],
      ),
    );
  }
}

class _InfoBanner extends StatelessWidget {
  const _InfoBanner({
    required this.icon,
    required this.tone,
    required this.text,
  });

  final IconData icon;
  final Color tone;
  final String text;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final tt = theme.textTheme;
    final spacing = theme.extension<AppSpacing>() ?? const AppSpacing();

    return Container(
      padding: EdgeInsets.all(spacing.md),
      decoration: BoxDecoration(
        color: tone.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(AppRadii.lg),
        border: Border.all(color: tone.withValues(alpha: 0.25), width: 1),
      ),
      child: Row(
        children: [
          Icon(icon, color: tone, size: 20),
          SizedBox(width: spacing.sm),
          Expanded(
            child: Text(
              text,
              style: tt.bodySmall?.copyWith(
                color: cs.onSurfaceVariant,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TierCard extends StatelessWidget {
  const _TierCard({
    required this.index,
    required this.canDelete,
    required this.dangerTone,
    required this.onDelete,
    required this.child,
  });

  final int index;
  final bool canDelete;
  final Color dangerTone;
  final VoidCallback onDelete;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final tt = theme.textTheme;
    final spacing = theme.extension<AppSpacing>() ?? const AppSpacing();

    final border = cs.outlineVariant.withValues(alpha: 0.65);

    return Container(
      margin: EdgeInsets.only(bottom: spacing.md),
      padding: EdgeInsets.all(spacing.lg),
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.circular(AppRadii.xl),
        border: Border.all(color: border, width: 1),
        boxShadow: [
          BoxShadow(
            color: cs.shadow.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: spacing.md,
                  vertical: spacing.xs,
                ),
                decoration: BoxDecoration(
                  color: cs.primary.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(AppRadii.xl),
                  border: Border.all(color: cs.primary.withValues(alpha: 0.20)),
                ),
                child: Text(
                  'Tier ${index + 1}',
                  style: tt.labelLarge?.copyWith(
                    fontWeight: FontWeight.w900,
                    color: cs.primary,
                  ),
                ),
              ),
              const Spacer(),
              if (canDelete)
                IconButton(
                  onPressed: onDelete,
                  tooltip: 'Hapus tier',
                  icon: Icon(Icons.delete_outline_rounded, color: dangerTone),
                ),
            ],
          ),
          SizedBox(height: spacing.md),
          child,
        ],
      ),
    );
  }
}

class _LoadingState extends StatelessWidget {
  const _LoadingState({required this.title, required this.subtitle});

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final tt = theme.textTheme;
    final spacing = theme.extension<AppSpacing>() ?? const AppSpacing();

    return Center(
      child: Container(
        padding: EdgeInsets.all(spacing.lg),
        decoration: BoxDecoration(
          color: cs.surface,
          borderRadius: BorderRadius.circular(AppRadii.xl),
          border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.65)),
          boxShadow: [
            BoxShadow(
              color: cs.shadow.withValues(alpha: 0.06),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(cs.primary),
            ),
            SizedBox(height: spacing.md),
            Text(
              title,
              style: tt.titleSmall?.copyWith(
                fontWeight: FontWeight.w900,
                color: cs.onSurface,
              ),
            ),
            SizedBox(height: spacing.xs),
            Text(
              subtitle,
              style: tt.bodySmall?.copyWith(
                color: cs.onSurfaceVariant,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MessageState extends StatelessWidget {
  const _MessageState({
    required this.icon,
    required this.title,
    required this.message,
    required this.buttonLabel,
    required this.onPressed,
    required this.tone,
  });

  final IconData icon;
  final String title;
  final String message;
  final String buttonLabel;
  final VoidCallback onPressed;
  final Color tone;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final tt = theme.textTheme;
    final spacing = theme.extension<AppSpacing>() ?? const AppSpacing();

    return Center(
      child: Container(
        margin: EdgeInsets.all(spacing.lg),
        padding: EdgeInsets.all(spacing.lg),
        decoration: BoxDecoration(
          color: cs.surface,
          borderRadius: BorderRadius.circular(AppRadii.xl),
          border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.65)),
          boxShadow: [
            BoxShadow(
              color: cs.shadow.withValues(alpha: 0.06),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: EdgeInsets.all(spacing.md),
              decoration: BoxDecoration(
                color: tone.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(AppRadii.lg),
                border: Border.all(color: tone.withValues(alpha: 0.22)),
              ),
              child: Icon(icon, color: tone, size: 40),
            ),
            SizedBox(height: spacing.md),
            Text(
              title,
              textAlign: TextAlign.center,
              style: tt.titleMedium?.copyWith(
                fontWeight: FontWeight.w900,
                color: cs.onSurface,
              ),
            ),
            SizedBox(height: spacing.xs),
            Text(
              message,
              textAlign: TextAlign.center,
              style: tt.bodySmall?.copyWith(
                color: cs.onSurfaceVariant,
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: spacing.lg),
            AppButton(
              text: buttonLabel,
              onPressed: onPressed,
              type: AppButtonType.primary,
              icon: Icons.arrow_forward_rounded,
            ),
          ],
        ),
      ),
    );
  }
}
