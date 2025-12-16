// lib/features/service_category/views/service_category_form_view.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:emababyspa/common/layouts/main_layout.dart';
import 'package:emababyspa/common/theme/app_theme.dart';
import 'package:emababyspa/common/theme/semantic_colors.dart';
import 'package:emababyspa/common/widgets/app_button.dart';
import 'package:emababyspa/common/widgets/app_text_field.dart';
import 'package:emababyspa/common/widgets/custom_appbar.dart';
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
          if (!didPop) controller.popPage();
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

  void _onSave() {
    final name = _nameController.text.trim();
    final desc = _descriptionController.text.trim();

    if (!(_formKey.currentState?.validate() ?? false)) return;

    // controller akan handle loading + snackbar + popPage(result)
    c.addServiceCategory(name: name, description: desc.isEmpty ? null : desc);
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      // trigger rebuild kalau theme berubah
      final _ = widget.themeController.isDarkMode;

      final theme = Theme.of(context);
      final cs = theme.colorScheme;
      final spacing = theme.extension<AppSpacing>()!;
      final semantic = theme.extension<AppSemanticColors>();

      return Scaffold(
        backgroundColor: cs.background,
        appBar: CustomAppBar(
          title: 'Tambah Kategori Layanan',
          showBackButton: true,
          onBackPressed: () => c.popPage(),
        ),
        body: SafeArea(
          child: CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.fromLTRB(
                    spacing.lg,
                    spacing.lg,
                    spacing.lg,
                    0,
                  ),
                  child: _Header(
                    title: 'Buat Kategori Baru',
                    subtitle:
                        'Tambahkan kategori agar layanan kamu lebih rapi dan mudah dikelola.',
                    icon: Icons.category_rounded,
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.fromLTRB(
                    spacing.lg,
                    spacing.lg,
                    spacing.lg,
                    spacing.xxl,
                  ),
                  child: _FormCard(
                    formKey: _formKey,
                    nameController: _nameController,
                    descriptionController: _descriptionController,
                    isSubmitting: c.isFormSubmitting.value,
                    onSave: _onSave,
                    onCancel: () => c.popPage(),
                    danger: semantic?.danger ?? cs.error,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    });
  }
}

class _Header extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;

  const _Header({
    required this.title,
    required this.subtitle,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final spacing = theme.extension<AppSpacing>()!;

    return Stack(
      children: [
        Positioned(
          right: -18,
          top: -18,
          child: Container(
            width: spacing.xxl * 3.2,
            height: spacing.xxl * 3.2,
            decoration: BoxDecoration(
              color: cs.primary.withOpacity(0.12),
              shape: BoxShape.circle,
            ),
          ),
        ),
        Positioned(
          left: -30,
          bottom: -34,
          child: Container(
            width: spacing.xxl * 3.8,
            height: spacing.xxl * 3.8,
            decoration: BoxDecoration(
              color: cs.primary.withOpacity(0.06),
              shape: BoxShape.circle,
            ),
          ),
        ),
        Container(
          padding: EdgeInsets.all(spacing.lg),
          decoration: BoxDecoration(
            color: cs.surface,
            borderRadius: BorderRadius.circular(AppRadii.xl),
            border: Border.all(color: cs.outlineVariant.withOpacity(0.65)),
            boxShadow: AppShadows.soft(cs.shadow),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: spacing.xxl * 1.85, // ~52
                height: spacing.xxl * 1.85,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      cs.primary.withOpacity(0.22),
                      cs.primary.withOpacity(0.08),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(AppRadii.lg),
                  border: Border.all(color: cs.primary.withOpacity(0.28)),
                ),
                child: Icon(icon, color: cs.primary, size: spacing.xl),
              ),
              SizedBox(width: spacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w900,
                        height: 1.12,
                        letterSpacing: -0.2,
                      ),
                    ),
                    SizedBox(height: spacing.xxs),
                    Text(
                      subtitle,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: cs.onBackground.withOpacity(0.72),
                        fontWeight: FontWeight.w700,
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
  final GlobalKey<FormState> formKey;
  final TextEditingController nameController;
  final TextEditingController descriptionController;

  final bool isSubmitting;
  final VoidCallback onSave;
  final VoidCallback onCancel;

  final Color danger;

  const _FormCard({
    required this.formKey,
    required this.nameController,
    required this.descriptionController,
    required this.isSubmitting,
    required this.onSave,
    required this.onCancel,
    required this.danger,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final spacing = theme.extension<AppSpacing>()!;

    return Container(
      padding: EdgeInsets.all(spacing.lg),
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.circular(AppRadii.xl),
        border: Border.all(color: cs.outlineVariant.withOpacity(0.65)),
        boxShadow: AppShadows.soft(cs.shadow),
      ),
      child: Form(
        key: formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _SectionTitle(title: 'Detail Kategori'),
            SizedBox(height: spacing.lg),

            _FieldLabel(label: 'Nama Kategori', requiredField: true),
            SizedBox(height: spacing.xs),
            AppTextField(
              controller: nameController,
              placeholder: 'Masukkan nama kategori',
              prefix: Icon(Icons.category_outlined, color: cs.primary),
              isRequired: true,
              validator: (v) {
                final value = (v ?? '').trim();
                if (value.isEmpty) return 'Nama kategori wajib diisi';
                if (value.length < 3) return 'Minimal 3 karakter';
                return null;
              },
            ),

            SizedBox(height: spacing.lg),

            _FieldLabel(label: 'Deskripsi', requiredField: false),
            SizedBox(height: spacing.xs),
            AppTextField(
              controller: descriptionController,
              placeholder: 'Tambahkan deskripsi (opsional)',
              prefix: Icon(Icons.description_outlined, color: cs.primary),
              maxLines: 3,
              validator: (v) {
                final value = (v ?? '').trim();
                if (value.isNotEmpty && value.length < 5) {
                  return 'Jika diisi, minimal 5 karakter';
                }
                return null;
              },
            ),

            SizedBox(height: spacing.xl),

            AppButton(
              text: 'Simpan Kategori',
              icon: Icons.save_rounded,
              isLoading: isSubmitting,
              onPressed: isSubmitting ? null : onSave,
              type: AppButtonType.secondary,
              size: AppButtonSize.large,
              isFullWidth: true,
            ),
            SizedBox(height: spacing.sm),
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
  const _SectionTitle({required this.title});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final spacing = theme.extension<AppSpacing>()!;

    return Row(
      children: [
        Container(
          width: 4,
          height: spacing.xl,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [cs.primary, cs.primary.withOpacity(0.65)],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
            borderRadius: BorderRadius.circular(99),
          ),
        ),
        SizedBox(width: spacing.sm),
        Text(
          title,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w900,
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

  const _FieldLabel({required this.label, required this.requiredField});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final spacing = theme.extension<AppSpacing>()!;

    return Row(
      children: [
        Text(
          label,
          style: theme.textTheme.labelLarge?.copyWith(
            fontWeight: FontWeight.w900,
            letterSpacing: 0.2,
          ),
        ),
        if (requiredField) ...[
          SizedBox(width: spacing.xxs),
          Text(
            '*',
            style: theme.textTheme.labelLarge?.copyWith(
              fontWeight: FontWeight.w900,
              color: cs.error,
            ),
          ),
        ],
      ],
    );
  }
}
