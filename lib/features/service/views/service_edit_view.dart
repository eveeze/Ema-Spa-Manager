// lib/features/service/views/service_edit_view.dart
import 'dart:io';
import 'dart:math' as math;
import 'dart:ui';

import 'package:emababyspa/common/layouts/main_layout.dart';
import 'package:emababyspa/common/theme/app_theme.dart';
import 'package:emababyspa/common/theme/semantic_colors.dart';
import 'package:emababyspa/common/widgets/app_button.dart';
import 'package:emababyspa/common/widgets/app_text_field.dart';
import 'package:emababyspa/features/service/controllers/service_controller.dart';
import 'package:emababyspa/features/theme/controllers/theme_controller.dart';
import 'package:emababyspa/utils/app_routes.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

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
      title: 'Edit Layanan',
      parentRoute: AppRoutes.services,
      child: Obx(() {
        if (controller.isFetchingServiceDetail.value ||
            controller.isLoadingCategories.value) {
          return const _LoadingState(
            title: 'Memuat layanan…',
            subtitle: 'Menyiapkan editor layanan untuk kamu.',
          );
        }

        if (controller.selectedService.value == null) {
          return _MessageState(
            icon: Icons.error_outline_rounded,
            title: 'Layanan tidak ditemukan',
            message:
                'Tidak ada layanan yang dipilih atau data layanan tidak ada.',
            actions: [
              AppButton(
                text: 'Muat Ulang',
                icon: Icons.refresh_rounded,
                onPressed: () => _fetchServiceIfNeeded(),
                type: AppButtonType.primary,
                isFullWidth: true,
                size: AppButtonSize.medium,
              ),
              const SizedBox(height: 12),
              AppButton(
                text: 'Kembali',
                icon: Icons.arrow_back_rounded,
                onPressed: () => Get.back(),
                type: AppButtonType.outline,
                isFullWidth: true,
                size: AppButtonSize.medium,
              ),
            ],
          );
        }

        if (controller.categoryError.isNotEmpty) {
          return _MessageState(
            icon: Icons.warning_amber_rounded,
            title: 'Gagal memuat kategori',
            message: controller.categoryError.value,
            actions: [
              AppButton(
                text: 'Coba Lagi',
                icon: Icons.refresh_rounded,
                onPressed: controller.fetchCategories,
                type: AppButtonType.primary,
                isFullWidth: true,
                size: AppButtonSize.medium,
              ),
            ],
          );
        }

        if (controller.serviceCategories.isEmpty) {
          return _MessageState(
            icon: Icons.category_outlined,
            title: 'Kategori belum tersedia',
            message:
                'Tambahkan kategori terlebih dahulu agar kamu bisa mengedit layanan.',
            actions: [
              AppButton(
                text: 'Kelola Kategori',
                icon: Icons.add_box_rounded,
                onPressed: () => Get.toNamed(AppRoutes.serviceCategoryList),
                type: AppButtonType.primary,
                isFullWidth: true,
                size: AppButtonSize.medium,
              ),
            ],
          );
        }

        final theme = Theme.of(context);
        final spacing = theme.extension<AppSpacing>() ?? const AppSpacing();

        // ✅ Bulatan background dihilangkan total (sesuai request)
        return Stack(
          children: [
            Padding(
              padding: EdgeInsets.only(bottom: spacing.xxl + spacing.lg),
              child: _buildEditor(context),
            ),
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: _GlassBottomBar(child: _buildSubmitButton(context)),
            ),
          ],
        );
      }),
    );
  }

  // =========================
  // Data init (DO NOT CHANGE LOGIC)
  // =========================
  Future<void> _fetchServiceIfNeeded() async {
    if (serviceId.isEmpty) {
      final cs = Theme.of(Get.context!).colorScheme;
      Get.snackbar(
        'Error',
        'No service ID provided',
        backgroundColor: cs.error,
        colorText: cs.onError,
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

  // =========================
  // UI: Editor layout (UI ONLY)
  // =========================
  Widget _buildEditor(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final spacing = theme.extension<AppSpacing>() ?? const AppSpacing();
    final semantic = theme.extension<AppSemanticColors>();

    final infoTone = semantic?.info ?? cs.secondary;
    final warningTone = semantic?.warning ?? cs.tertiary;
    final dangerTone = semantic?.danger ?? cs.error;

    return Form(
      key: formKey,
      child: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          SliverPadding(
            padding: EdgeInsets.fromLTRB(
              spacing.lg,
              spacing.lg,
              spacing.lg,
              spacing.md,
            ),
            sliver: const SliverToBoxAdapter(
              child: _EditorHero(
                title: 'Edit Layanan',
                subtitle:
                    'Perbarui detail, foto, dan harga—biar tampil rapi & profesional.',
                leading: Icons.tune_rounded,
              ),
            ),
          ),
          SliverPadding(
            padding: EdgeInsets.fromLTRB(spacing.lg, 0, spacing.lg, spacing.lg),
            sliver: SliverToBoxAdapter(
              child: _InfoPill(
                tone: infoTone,
                icon: Icons.tips_and_updates_outlined,
                text:
                    'Tips: aktifkan “Harga bertingkat” kalau tarif berbeda berdasarkan usia bayi.',
              ),
            ),
          ),
          SliverPadding(
            padding: EdgeInsets.fromLTRB(spacing.lg, 0, spacing.lg, spacing.lg),
            sliver: SliverToBoxAdapter(
              child: LayoutBuilder(
                builder: (context, c) {
                  final isWide = c.maxWidth >= 520;
                  final gap = SizedBox(height: spacing.md, width: spacing.md);

                  final imageCard = _SectionCard(
                    title: 'Foto Layanan',
                    subtitle: 'Tap untuk memilih / mengganti foto.',
                    icon: Icons.image_outlined,
                    child: _buildImagePicker(context),
                  );

                  final summaryCard = _SectionCard(
                    title: 'Ringkasan',
                    subtitle: 'Sekilas status konfigurasi layanan.',
                    icon: Icons.insights_outlined,
                    child: Obx(
                      () => _SummaryTiles(
                        tiles: [
                          _SummaryTile(
                            label: 'Nama',
                            value:
                                nameController.text.isEmpty
                                    ? '—'
                                    : nameController.text,
                            icon: Icons.badge_outlined,
                          ),
                          _SummaryTile(
                            label: 'Durasi',
                            value:
                                durationController.text.isEmpty
                                    ? '—'
                                    : '${durationController.text} menit',
                            icon: Icons.schedule_rounded,
                          ),
                          _SummaryTile(
                            label: 'Mode Harga',
                            value:
                                hasPriceTiers.value ? 'Bertingkat' : 'Tunggal',
                            icon: Icons.payments_outlined,
                          ),
                        ],
                      ),
                    ),
                  );

                  if (!isWide) {
                    return Column(children: [imageCard, gap, summaryCard]);
                  }

                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(child: imageCard),
                      gap,
                      Expanded(child: summaryCard),
                    ],
                  );
                },
              ),
            ),
          ),
          SliverPadding(
            padding: EdgeInsets.fromLTRB(spacing.lg, 0, spacing.lg, spacing.lg),
            sliver: SliverToBoxAdapter(
              child: _SectionCard(
                title: 'Informasi Dasar',
                subtitle: 'Nama, deskripsi, kategori, dan durasi.',
                icon: Icons.info_outline_rounded,
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
                      placeholder:
                          'Tulis singkat: manfaat, durasi, dan highlight layanan',
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
                        if (int.tryParse(value) == null ||
                            int.parse(value) <= 0) {
                          return 'Masukkan durasi yang valid';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: spacing.md),
                    _InlineHint(
                      icon: Icons.check_circle_outline_rounded,
                      tone: cs.primary,
                      text: 'Pastikan durasi sesuai paket agar jadwal akurat.',
                    ),
                  ],
                ),
              ),
            ),
          ),
          SliverPadding(
            padding: EdgeInsets.fromLTRB(spacing.lg, 0, spacing.lg, spacing.xl),
            sliver: SliverToBoxAdapter(
              child: _SectionCard(
                title: 'Harga',
                subtitle: 'Tunggal atau bertingkat per rentang usia.',
                icon: Icons.payments_outlined,
                child: Column(
                  children: [
                    _buildPriceTierSwitch(context),
                    SizedBox(height: spacing.lg),
                    Obx(
                      () => AnimatedSwitcher(
                        duration: const Duration(milliseconds: 260),
                        switchInCurve: Curves.easeOutCubic,
                        switchOutCurve: Curves.easeIn,
                        transitionBuilder: (child, animation) {
                          return FadeTransition(
                            opacity: animation,
                            child: SlideTransition(
                              position: Tween<Offset>(
                                begin: const Offset(0, 0.07),
                                end: Offset.zero,
                              ).animate(animation),
                              child: child,
                            ),
                          );
                        },
                        child:
                            !hasPriceTiers.value
                                ? _buildSimplePricing(
                                  context,
                                  infoTone: infoTone,
                                )
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
            ),
          ),
        ],
      ),
    );
  }

  // ✅ Fix overflow + request: bagian foto dibuat LEBIH TINGGI
  Widget _buildImagePicker(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final tt = theme.textTheme;
    final spacing = theme.extension<AppSpacing>() ?? const AppSpacing();

    return LayoutBuilder(
      builder: (context, c) {
        final maxW = c.maxWidth.isFinite ? c.maxWidth : double.infinity;

        // Ukuran dasar dari token spacing (tanpa angka literal)
        final base = spacing.xxl + spacing.xxl + spacing.xl;
        final ratio = (spacing.xl / (spacing.sm == 0 ? 1 : spacing.sm));
        final desired = base * ratio;

        // Minimum aman supaya placeholder nggak kepaksa jadi super kecil
        final minSide = spacing.xxl + spacing.xxl + spacing.xl + spacing.lg;

        final raw = maxW.isFinite ? math.min(desired, maxW) : desired;
        final size =
            maxW.isFinite
                ? math.max(math.min(minSide, maxW), raw)
                : math.max(minSide, raw);

        // ✅ Tinggi ekstra (request: "tambahkan tingginya")
        final extraHeight = spacing.xl + spacing.lg;

        return Column(
          children: [
            Center(
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: _pickImage,
                  borderRadius: BorderRadius.circular(AppRadii.xl),
                  child: Ink(
                    width: size,
                    height: size + extraHeight,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(AppRadii.xl),
                      border: Border.all(
                        color: cs.outlineVariant.withValues(alpha: 0.65),
                      ),
                      color: cs.surfaceContainerHighest.withValues(alpha: 0.26),
                      boxShadow: [
                        BoxShadow(
                          color: cs.shadow.withValues(alpha: 0.08),
                          blurRadius: spacing.lg,
                          offset: Offset(0, spacing.xs),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(AppRadii.xl),
                      child: Obx(() {
                        if (imageFile.value != null) {
                          return _ImageStage(
                            child: Image.file(
                              imageFile.value!,
                              fit: BoxFit.cover,
                            ),
                          );
                        }
                        if (currentImageUrl.value.isNotEmpty) {
                          return _ImageStage(
                            child: Image.network(
                              currentImageUrl.value,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return const _ImagePlaceholder(
                                  icon: Icons.image_not_supported_outlined,
                                  title: 'Gambar tidak tersedia',
                                  subtitle: 'Tap untuk pilih ulang',
                                );
                              },
                            ),
                          );
                        }
                        return const _ImagePlaceholder(
                          icon: Icons.add_photo_alternate_outlined,
                          title: 'Tambah foto',
                          subtitle: 'Tap untuk memilih dari galeri',
                        );
                      }),
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(height: spacing.md),
            Text(
              'Foto yang bagus bikin layanan terlihat premium.',
              textAlign: TextAlign.center,
              style: tt.bodySmall?.copyWith(
                color: cs.onSurfaceVariant,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildCategoryDropdown(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final tt = theme.textTheme;
    final spacing = theme.extension<AppSpacing>() ?? const AppSpacing();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'Kategori',
              style: tt.bodyMedium?.copyWith(
                fontWeight: FontWeight.w800,
                color: cs.onSurface,
              ),
            ),
            Text(
              ' *',
              style: tt.bodyMedium?.copyWith(
                fontWeight: FontWeight.w900,
                color: cs.error,
              ),
            ),
          ],
        ),
        SizedBox(height: spacing.sm),
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppRadii.lg),
            border: Border.all(
              color: cs.outlineVariant.withValues(alpha: 0.65),
            ),
            color: cs.surfaceContainerHighest.withValues(alpha: 0.26),
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

  Widget _buildPriceTierSwitch(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final tt = theme.textTheme;
    final spacing = theme.extension<AppSpacing>() ?? const AppSpacing();

    return Container(
      padding: EdgeInsets.all(spacing.lg),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppRadii.xl),
        border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.65)),
        color: cs.surfaceContainerHighest.withValues(alpha: 0.20),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(spacing.sm),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(AppRadii.md),
              color: cs.primary.withValues(alpha: 0.12),
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
                  'Buat beberapa tier untuk rentang usia berbeda.',
                  style: tt.bodySmall?.copyWith(
                    color: cs.onSurfaceVariant,
                    fontWeight: FontWeight.w600,
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: hasPriceTiers.value,
            onChanged: (value) {
              hasPriceTiers.value = value;
              if (value && priceTiers.isEmpty) {
                _addInitialPriceTier();
              }
            },
            activeColor: cs.primary,
            activeTrackColor: cs.primary.withValues(alpha: 0.30),
            inactiveThumbColor: cs.onSurfaceVariant.withValues(alpha: 0.70),
            inactiveTrackColor: cs.outlineVariant.withValues(alpha: 0.55),
            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
        ],
      ),
    );
  }

  Widget _buildSimplePricing(BuildContext context, {required Color infoTone}) {
    final theme = Theme.of(context);
    final spacing = theme.extension<AppSpacing>() ?? const AppSpacing();

    return Column(
      key: const ValueKey('simple_pricing'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _InlineHint(
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
            if (value == null || value.isEmpty) return 'Harga wajib diisi';
            if (double.tryParse(value) == null || double.parse(value) < 0) {
              return 'Masukkan harga yang valid';
            }
            return null;
          },
        ),
        SizedBox(height: spacing.lg),
        Column(
          children: [
            AppTextField(
              controller: minAgeController,
              label: 'Usia minimum (bulan)',
              placeholder: 'Contoh: 0',
              keyboardType: TextInputType.number,
              isRequired: true,
              validator: (value) {
                if (value == null || value.isEmpty) return 'Wajib diisi';
                if (int.tryParse(value) == null || int.parse(value) < 0) {
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
                if (value == null || value.isEmpty) return 'Wajib diisi';
                final minAgeText = minAgeController.text;
                if (minAgeText.isEmpty || int.tryParse(minAgeText) == null) {
                  return 'Isi usia minimum dulu';
                }
                if (int.tryParse(value) == null ||
                    int.parse(value) <= int.parse(minAgeText)) {
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

  Widget _buildPriceTiers(
    BuildContext context, {
    required Color warningTone,
    required Color dangerTone,
  }) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final tt = theme.textTheme;
    final spacing = theme.extension<AppSpacing>() ?? const AppSpacing();

    return Column(
      key: const ValueKey('price_tiers'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _InlineHint(
          icon: Icons.info_outline_rounded,
          tone: warningTone,
          text: 'Setiap tier punya rentang usia dan harga sendiri.',
        ),
        SizedBox(height: spacing.lg),
        Obx(
          () => Column(
            children: [
              ...List.generate(priceTiers.length, (index) {
                if (!priceTierControllers.containsKey(index)) {
                  _initializePriceTierControllers(index);
                }
                final ctrls = priceTierControllers[index]!;

                return Container(
                  margin: EdgeInsets.only(bottom: spacing.md),
                  padding: EdgeInsets.all(spacing.lg),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(AppRadii.xl),
                    border: Border.all(
                      color: cs.outlineVariant.withValues(alpha: 0.65),
                    ),
                    color: cs.surface,
                    boxShadow: [
                      BoxShadow(
                        color: cs.shadow.withValues(alpha: 0.06),
                        blurRadius: spacing.lg,
                        offset: Offset(0, spacing.xs),
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
                              borderRadius: BorderRadius.circular(AppRadii.xl),
                              color: cs.primary.withValues(alpha: 0.12),
                              border: Border.all(
                                color: cs.primary.withValues(alpha: 0.20),
                              ),
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
                          if (priceTiers.length > 1)
                            IconButton(
                              onPressed: () {
                                priceTiers.removeAt(index);
                                priceTierControllers.remove(index);

                                final newControllers =
                                    <int, Map<String, TextEditingController>>{};
                                for (
                                  int i = 0;
                                  i < priceTierControllers.length;
                                  i++
                                ) {
                                  final key = i < index ? i : i + 1;
                                  if (priceTierControllers.containsKey(key)) {
                                    newControllers[i] =
                                        priceTierControllers[key]!;
                                  }
                                }
                                priceTierControllers.value = newControllers;
                              },
                              tooltip: 'Hapus tier',
                              icon: Icon(
                                Icons.delete_outline_rounded,
                                color: dangerTone,
                              ),
                            ),
                        ],
                      ),
                      SizedBox(height: spacing.md),
                      Divider(color: cs.outlineVariant.withValues(alpha: 0.55)),
                      SizedBox(height: spacing.md),
                      Column(
                        children: [
                          AppTextField(
                            label: 'Usia minimum (bulan)',
                            placeholder: 'Contoh: 0',
                            keyboardType: TextInputType.number,
                            controller: ctrls['minAge'],
                            validator: (v) {
                              if (v == null || v.isEmpty) return 'Wajib diisi';
                              if (int.tryParse(v) == null || int.parse(v) < 0) {
                                return 'Tidak valid';
                              }
                              return null;
                            },
                            onChanged:
                                (v) =>
                                    priceTiers[index]['minAge'] =
                                        int.tryParse(v) ?? 0,
                          ),
                          SizedBox(height: spacing.md),
                          AppTextField(
                            label: 'Usia maksimum (bulan)',
                            placeholder: 'Contoh: 12',
                            keyboardType: TextInputType.number,
                            controller: ctrls['maxAge'],
                            validator: (v) {
                              if (v == null || v.isEmpty) return 'Wajib diisi';
                              final minAge = int.tryParse(
                                ctrls['minAge']!.text,
                              );
                              if (minAge == null) return 'Minimum tidak valid';
                              return (int.tryParse(v) == null ||
                                      int.parse(v) <= minAge)
                                  ? 'Harus > minimum'
                                  : null;
                            },
                            onChanged:
                                (v) =>
                                    priceTiers[index]['maxAge'] =
                                        int.tryParse(v) ?? 0,
                          ),
                          SizedBox(height: spacing.md),
                          AppTextField(
                            label: 'Harga (Rp)',
                            placeholder: 'Contoh: 150000',
                            keyboardType: TextInputType.number,
                            controller: ctrls['price'],
                            validator: (v) {
                              if (v == null || v.isEmpty) return 'Wajib diisi';
                              if (double.tryParse(v) == null ||
                                  double.parse(v) < 0) {
                                return 'Tidak valid';
                              }
                              return null;
                            },
                            onChanged:
                                (v) =>
                                    priceTiers[index]['price'] =
                                        double.tryParse(v) ?? 0.0,
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              }),
            ],
          ),
        ),
        SizedBox(height: spacing.md),
        AppButton(
          text: 'Tambah Tier',
          icon: Icons.add_rounded,
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
      ],
    );
  }

  Widget _buildSubmitButton(BuildContext context) {
    return Obx(
      () => AppButton(
        text:
            controller.isUpdatingService.value
                ? 'Menyimpan…'
                : 'Simpan Perubahan',
        icon: controller.isUpdatingService.value ? null : Icons.save_outlined,
        onPressed: controller.isUpdatingService.value ? null : _submitForm,
        type: AppButtonType.primary,
        isFullWidth: true,
        size: AppButtonSize.large,
        isLoading: controller.isUpdatingService.value,
      ),
    );
  }

  // =========================
  // Actions (DO NOT CHANGE LOGIC)
  // =========================
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
          final cs = Theme.of(Get.context!).colorScheme;
          Get.snackbar(
            'Validation Error',
            'Please complete all price tier fields with valid numbers.',
            backgroundColor: cs.error,
            colorText: cs.onError,
          );
          return;
        }

        final formattedPriceTiers =
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

// =========================
// UI Blocks (theme-only)
// =========================

class _GlassBottomBar extends StatelessWidget {
  const _GlassBottomBar({required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final spacing = theme.extension<AppSpacing>() ?? const AppSpacing();

    return ClipRRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: spacing.sm, sigmaY: spacing.sm),
        child: Container(
          padding: EdgeInsets.fromLTRB(
            spacing.lg,
            spacing.md,
            spacing.lg,
            spacing.md,
          ),
          decoration: BoxDecoration(
            color: cs.surface.withValues(alpha: 0.78),
            border: Border(
              top: BorderSide(color: cs.outlineVariant.withValues(alpha: 0.55)),
            ),
          ),
          child: child,
        ),
      ),
    );
  }
}

class _EditorHero extends StatelessWidget {
  const _EditorHero({
    required this.title,
    required this.subtitle,
    required this.leading,
  });

  final String title;
  final String subtitle;
  final IconData leading;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final tt = theme.textTheme;
    final spacing = theme.extension<AppSpacing>() ?? const AppSpacing();

    return Container(
      padding: EdgeInsets.all(spacing.lg),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppRadii.xl),
        border: Border.all(color: cs.primary.withValues(alpha: 0.22)),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            cs.primary.withValues(alpha: 0.16),
            cs.primary.withValues(alpha: 0.06),
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: cs.shadow.withValues(alpha: 0.06),
            blurRadius: spacing.lg,
            offset: Offset(0, spacing.xs),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(spacing.md),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(AppRadii.lg),
              color: cs.primary.withValues(alpha: 0.14),
              border: Border.all(color: cs.primary.withValues(alpha: 0.22)),
            ),
            child: Icon(leading, color: cs.primary, size: 24),
          ),
          SizedBox(width: spacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: tt.titleLarge?.copyWith(
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
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoPill extends StatelessWidget {
  const _InfoPill({required this.tone, required this.icon, required this.text});

  final Color tone;
  final IconData icon;
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
        borderRadius: BorderRadius.circular(AppRadii.xl),
        color: tone.withValues(alpha: 0.10),
        border: Border.all(color: tone.withValues(alpha: 0.25)),
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
                fontWeight: FontWeight.w700,
                height: 1.35,
              ),
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
    required this.icon,
    required this.child,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final tt = theme.textTheme;
    final spacing = theme.extension<AppSpacing>() ?? const AppSpacing();

    return Container(
      padding: EdgeInsets.all(spacing.lg),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppRadii.xl),
        border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.65)),
        color: cs.surface,
        boxShadow: [
          BoxShadow(
            color: cs.shadow.withValues(alpha: 0.06),
            blurRadius: spacing.lg,
            offset: Offset(0, spacing.xs),
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
                  borderRadius: BorderRadius.circular(AppRadii.md),
                  color: cs.primary.withValues(alpha: 0.12),
                  border: Border.all(color: cs.primary.withValues(alpha: 0.20)),
                ),
                child: Icon(icon, color: cs.primary, size: 20),
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

class _InlineHint extends StatelessWidget {
  const _InlineHint({
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
      width: double.infinity,
      padding: EdgeInsets.all(spacing.md),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppRadii.lg),
        color: tone.withValues(alpha: 0.10),
        border: Border.all(color: tone.withValues(alpha: 0.22)),
      ),
      child: Row(
        children: [
          Icon(icon, color: tone, size: 18),
          SizedBox(width: spacing.sm),
          Expanded(
            child: Text(
              text,
              style: tt.bodySmall?.copyWith(
                color: cs.onSurfaceVariant,
                fontWeight: FontWeight.w700,
                height: 1.35,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ImageStage extends StatelessWidget {
  const _ImageStage({required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final spacing = theme.extension<AppSpacing>() ?? const AppSpacing();

    return Stack(
      fit: StackFit.expand,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(AppRadii.xl),
          child: child,
        ),
        Positioned(
          left: spacing.sm,
          right: spacing.sm,
          bottom: spacing.sm,
          child: Container(
            padding: EdgeInsets.symmetric(
              horizontal: spacing.md,
              vertical: spacing.xs,
            ),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(AppRadii.xl),
              color: cs.surface.withValues(alpha: 0.80),
              border: Border.all(
                color: cs.outlineVariant.withValues(alpha: 0.55),
              ),
            ),
            child: Row(
              children: [
                Icon(Icons.edit_rounded, size: 16, color: cs.primary),
                SizedBox(width: spacing.xs),
                Expanded(
                  child: Text(
                    'Ganti foto',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: cs.onSurface,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

// ✅ Fix overflow: placeholder adaptif. Kalau ruang kecil, tampilkan versi “compact”.
class _ImagePlaceholder extends StatelessWidget {
  const _ImagePlaceholder({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  final IconData icon;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final tt = theme.textTheme;
    final spacing = theme.extension<AppSpacing>() ?? const AppSpacing();

    return LayoutBuilder(
      builder: (context, c) {
        final w = c.maxWidth;
        final h = c.maxHeight;

        // Compact jika area terlalu kecil untuk Column + padding.
        final compactThreshold = spacing.xxl + spacing.xxl + spacing.xl;
        final isCompact =
            (w.isFinite && w < compactThreshold) ||
            (h.isFinite && h < compactThreshold);

        if (isCompact) {
          return Center(
            child: Icon(
              icon,
              size: math.max(spacing.lg, spacing.xl),
              color: cs.primary,
            ),
          );
        }

        return Center(
          child: Padding(
            padding: EdgeInsets.all(spacing.lg),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: EdgeInsets.all(spacing.md),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(AppRadii.lg),
                    color: cs.primary.withValues(alpha: 0.12),
                    border: Border.all(
                      color: cs.primary.withValues(alpha: 0.22),
                    ),
                  ),
                  child: Icon(icon, size: spacing.xxl, color: cs.primary),
                ),
                SizedBox(height: spacing.md),
                Text(
                  title,
                  textAlign: TextAlign.center,
                  style: tt.titleSmall?.copyWith(
                    fontWeight: FontWeight.w900,
                    color: cs.onSurface,
                  ),
                ),
                SizedBox(height: spacing.xs),
                Text(
                  subtitle,
                  textAlign: TextAlign.center,
                  style: tt.bodySmall?.copyWith(
                    color: cs.onSurfaceVariant,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _SummaryTiles extends StatelessWidget {
  const _SummaryTiles({required this.tiles});
  final List<_SummaryTile> tiles;

  @override
  Widget build(BuildContext context) {
    final spacing =
        Theme.of(context).extension<AppSpacing>() ?? const AppSpacing();
    return Column(
      children: [
        for (int i = 0; i < tiles.length; i++) ...[
          tiles[i],
          if (i != tiles.length - 1) SizedBox(height: spacing.md),
        ],
      ],
    );
  }
}

class _SummaryTile extends StatelessWidget {
  const _SummaryTile({
    required this.label,
    required this.value,
    required this.icon,
  });

  final String label;
  final String value;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final tt = theme.textTheme;
    final spacing = theme.extension<AppSpacing>() ?? const AppSpacing();

    return Container(
      padding: EdgeInsets.all(spacing.md),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppRadii.lg),
        border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.55)),
        color: cs.surfaceContainerHighest.withValues(alpha: 0.18),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(spacing.sm),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(AppRadii.md),
              color: cs.primary.withValues(alpha: 0.12),
            ),
            child: Icon(icon, size: 18, color: cs.primary),
          ),
          SizedBox(width: spacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: tt.bodySmall?.copyWith(
                    color: cs.onSurfaceVariant,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                SizedBox(height: spacing.xs),
                Text(
                  value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: tt.titleSmall?.copyWith(
                    color: cs.onSurface,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
          ),
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
        margin: EdgeInsets.all(spacing.lg),
        padding: EdgeInsets.all(spacing.lg),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppRadii.xl),
          border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.65)),
          color: cs.surface,
          boxShadow: [
            BoxShadow(
              color: cs.shadow.withValues(alpha: 0.06),
              blurRadius: spacing.lg,
              offset: Offset(0, spacing.xs),
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
              textAlign: TextAlign.center,
              style: tt.titleSmall?.copyWith(
                fontWeight: FontWeight.w900,
                color: cs.onSurface,
              ),
            ),
            SizedBox(height: spacing.xs),
            Text(
              subtitle,
              textAlign: TextAlign.center,
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
    required this.actions,
  });

  final IconData icon;
  final String title;
  final String message;
  final List<Widget> actions;

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
          borderRadius: BorderRadius.circular(AppRadii.xl),
          border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.65)),
          color: cs.surface,
          boxShadow: [
            BoxShadow(
              color: cs.shadow.withValues(alpha: 0.06),
              blurRadius: spacing.lg,
              offset: Offset(0, spacing.xs),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: EdgeInsets.all(spacing.md),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(AppRadii.lg),
                color: cs.primary.withValues(alpha: 0.12),
                border: Border.all(color: cs.primary.withValues(alpha: 0.22)),
              ),
              child: Icon(icon, size: spacing.xxl, color: cs.primary),
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
                height: 1.35,
              ),
            ),
            SizedBox(height: spacing.lg),
            ..._withGaps(actions, gap: spacing.sm),
          ],
        ),
      ),
    );
  }

  List<Widget> _withGaps(List<Widget> items, {required double gap}) {
    final out = <Widget>[];
    for (int i = 0; i < items.length; i++) {
      out.add(items[i]);
      if (i != items.length - 1) out.add(SizedBox(height: gap));
    }
    return out;
  }
}
