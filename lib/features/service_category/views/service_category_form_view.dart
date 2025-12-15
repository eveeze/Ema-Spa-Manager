// lib/features/service_category/views/service_category_form_view.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:emababyspa/common/theme/color_theme.dart';
import 'package:emababyspa/common/widgets/custom_appbar.dart';
import 'package:emababyspa/common/widgets/app_button.dart';
import 'package:emababyspa/common/widgets/app_text_field.dart';
import 'package:emababyspa/common/layouts/main_layout.dart';
import 'package:emababyspa/features/service_category/controllers/service_category_controller.dart';
import 'package:emababyspa/features/theme/controllers/theme_controller.dart';

class ServiceCategoryFormView extends GetView<ServiceCategoryController> {
  const ServiceCategoryFormView({super.key});

  @override
  Widget build(BuildContext context) {
    final ThemeController themeController = Get.find<ThemeController>();
    return MainLayout(
      child: PopScope(
        onPopInvokedWithResult: (didPop, result) {
          if (!didPop) controller.navigateBackToServiceCategories();
        },
        child: _FormScaffold(themeController: themeController),
      ),
    );
  }
}

class _FormScaffold extends StatefulWidget {
  final ThemeController themeController;
  const _FormScaffold({required this.themeController});

  @override
  State<_FormScaffold> createState() => _FormScaffoldState();
}

class _FormScaffoldState extends State<_FormScaffold> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _descriptionController;

  ServiceCategoryController get c => Get.find<ServiceCategoryController>();

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _descriptionController = TextEditingController();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // ✅ Cuma Obx sekali untuk theme + loading button
    return Obx(() {
      final isDark = widget.themeController.isDarkMode;

      final bg = isDark ? ColorTheme.backgroundDark : ColorTheme.background;
      final surface = isDark ? ColorTheme.surfaceDark : Colors.white;

      final primary = isDark ? ColorTheme.primaryLightDark : ColorTheme.primary;
      final textPrimary =
          isDark ? ColorTheme.textPrimaryDark : ColorTheme.textPrimary;
      final textSecondary =
          isDark ? ColorTheme.textSecondaryDark : ColorTheme.textSecondary;

      return Scaffold(
        backgroundColor: bg,
        appBar: CustomAppBar(
          title: 'Tambah Kategori Layanan',
          showBackButton: true,
          onBackPressed: c.navigateBackToServiceCategories,
        ),
        body: SafeArea(
          child: CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                  child: _Header(
                    isDark: isDark,
                    primary: primary,
                    textPrimary: textPrimary,
                    textSecondary: textSecondary,
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 18, 20, 24),
                  child: _FormCard(
                    isDark: isDark,
                    surface: surface,
                    primary: primary,
                    textPrimary: textPrimary,
                    textSecondary: textSecondary,
                    formKey: _formKey,
                    nameController: _nameController,
                    descriptionController: _descriptionController,
                    isSubmitting: c.isFormSubmitting.value,
                    onSave: _onSave,
                    onCancel: c.navigateBackToServiceCategories,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    });
  }

  void _onSave() {
    final name = _nameController.text.trim();
    final desc = _descriptionController.text.trim();

    if (!(_formKey.currentState?.validate() ?? false)) return;

    c.addServiceCategory(name: name, description: desc);
  }
}

class _Header extends StatelessWidget {
  final bool isDark;
  final Color primary;
  final Color textPrimary;
  final Color textSecondary;

  const _Header({
    required this.isDark,
    required this.primary,
    required this.textPrimary,
    required this.textSecondary,
  });

  @override
  Widget build(BuildContext context) {
    final headerBg1 = primary.withValues(alpha: isDark ? 0.14 : 0.12);
    final headerBg2 = primary.withValues(alpha: isDark ? 0.06 : 0.06);

    return Stack(
      children: [
        Positioned(
          right: -18,
          top: -18,
          child: Container(
            width: 140,
            height: 140,
            decoration: BoxDecoration(color: headerBg1, shape: BoxShape.circle),
          ),
        ),
        Positioned(
          left: -30,
          bottom: -34,
          child: Container(
            width: 170,
            height: 170,
            decoration: BoxDecoration(color: headerBg2, shape: BoxShape.circle),
          ),
        ),
        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: (isDark ? Colors.white : Colors.black).withValues(
              alpha: 0.02,
            ),
            borderRadius: BorderRadius.circular(22),
            border: Border.all(
              color: (isDark ? Colors.white : Colors.black).withValues(
                alpha: isDark ? 0.10 : 0.06,
              ),
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      primary.withValues(alpha: 0.22),
                      primary.withValues(alpha: 0.08),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: primary.withValues(alpha: 0.28)),
                ),
                child: Icon(Icons.category_rounded, color: primary, size: 26),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Buat Kategori Baru',
                      style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.w800,
                        color: textPrimary,
                        fontFamily: 'JosefinSans',
                        letterSpacing: -0.4,
                        height: 1.12,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Tambahkan kategori agar layanan kamu lebih rapi dan mudah dikelola.',
                      style: TextStyle(
                        fontSize: 15.5,
                        fontWeight: FontWeight.w600,
                        color: textSecondary,
                        fontFamily: 'JosefinSans',
                        height: 1.35,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _FormCard extends StatelessWidget {
  final bool isDark;
  final Color surface;
  final Color primary;
  final Color textPrimary;
  final Color textSecondary;

  final GlobalKey<FormState> formKey;
  final TextEditingController nameController;
  final TextEditingController descriptionController;

  final bool isSubmitting;
  final VoidCallback onSave;
  final VoidCallback onCancel;

  const _FormCard({
    required this.isDark,
    required this.surface,
    required this.primary,
    required this.textPrimary,
    required this.textSecondary,
    required this.formKey,
    required this.nameController,
    required this.descriptionController,
    required this.isSubmitting,
    required this.onSave,
    required this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    final outline = (isDark ? Colors.white : Colors.black).withValues(
      alpha: isDark ? 0.10 : 0.06,
    );

    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: surface,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: outline),
        boxShadow: [
          BoxShadow(
            color: (isDark ? Colors.black : Colors.black).withValues(
              alpha: isDark ? 0.30 : 0.06,
            ),
            blurRadius: isDark ? 18 : 24,
            offset: const Offset(0, 10),
          ),
          if (!isDark)
            BoxShadow(
              color: primary.withValues(alpha: 0.06),
              blurRadius: 50,
              offset: const Offset(0, 18),
              spreadRadius: -10,
            ),
        ],
      ),
      child: Form(
        key: formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _SectionTitle(
              title: 'Detail Kategori',
              primary: primary,
              textPrimary: textPrimary,
            ),
            const SizedBox(height: 18),

            _FieldLabel(
              label: 'Nama Kategori',
              requiredField: true,
              textPrimary: textPrimary,
            ),
            const SizedBox(height: 8),
            AppTextField(
              controller: nameController,
              placeholder: 'Masukkan nama kategori',
              prefix: Icon(
                Icons.category_outlined,
                color: primary.withValues(alpha: 0.85),
              ),
              isRequired: true,
              validator: (v) {
                final value = (v ?? '').trim();
                if (value.isEmpty) return 'Nama kategori wajib diisi';
                if (value.length < 3) return 'Minimal 3 karakter';
                return null;
              },
            ),

            const SizedBox(height: 18),

            _FieldLabel(
              label: 'Deskripsi',
              requiredField: false,
              textPrimary: textPrimary,
            ),
            const SizedBox(height: 8),
            AppTextField(
              controller: descriptionController,
              placeholder: 'Tambahkan deskripsi (opsional)',
              prefix: Icon(
                Icons.description_outlined,
                color: primary.withValues(alpha: 0.85),
              ),
              maxLines: 3,
              validator: (v) {
                final value = (v ?? '').trim();
                if (value.isNotEmpty && value.length < 5) {
                  return 'Jika diisi, minimal 5 karakter';
                }
                return null;
              },
            ),

            const SizedBox(height: 22),

            AppButton(
              text: 'Simpan Kategori',
              icon: Icons.save_rounded,
              isLoading: isSubmitting,
              onPressed: isSubmitting ? null : onSave,
              type: AppButtonType.secondary,
              size: AppButtonSize.large,
              isFullWidth: true,
            ),
            const SizedBox(height: 12),
            AppButton(
              text: 'Batal',
              icon: Icons.close_rounded,
              type: AppButtonType.outline,
              size: AppButtonSize.large,
              isFullWidth: true,
              onPressed: isSubmitting ? null : onCancel,
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;
  final Color primary;
  final Color textPrimary;

  const _SectionTitle({
    required this.title,
    required this.primary,
    required this.textPrimary,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 4,
          height: 22,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [primary, primary.withValues(alpha: 0.65)],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
            borderRadius: BorderRadius.circular(99),
          ),
        ),
        const SizedBox(width: 10),
        Text(
          title,
          style: TextStyle(
            fontSize: 16.5,
            fontWeight: FontWeight.w800,
            color: textPrimary,
            fontFamily: 'JosefinSans',
            letterSpacing: 0.1,
          ),
        ),
      ],
    );
  }
}

class _FieldLabel extends StatelessWidget {
  final String label;
  final bool requiredField;
  final Color textPrimary;

  const _FieldLabel({
    required this.label,
    required this.requiredField,
    required this.textPrimary,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 13.5,
            fontWeight: FontWeight.w800,
            color: textPrimary,
            fontFamily: 'JosefinSans',
            letterSpacing: 0.2,
          ),
        ),
        if (requiredField) ...[
          const SizedBox(width: 4),
          Text(
            '*',
            style: TextStyle(
              fontSize: 13.5,
              fontWeight: FontWeight.w900,
              color: ColorTheme.error,
            ),
          ),
        ],
      ],
    );
  }
}
