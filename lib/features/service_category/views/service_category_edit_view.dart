// lib/features/service_category/views/service_category_edit_view.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:emababyspa/common/layouts/main_layout.dart';
import 'package:emababyspa/common/theme/app_theme.dart';
import 'package:emababyspa/common/widgets/custom_appbar.dart';
import 'package:emababyspa/common/widgets/app_button.dart';
import 'package:emababyspa/common/widgets/app_text_field.dart';
import 'package:emababyspa/features/service_category/controllers/service_category_controller.dart';
import 'package:emababyspa/utils/app_routes.dart';

class ServiceCategoryEditView extends StatefulWidget {
  const ServiceCategoryEditView({super.key});

  @override
  State<ServiceCategoryEditView> createState() =>
      _ServiceCategoryEditViewState();
}

class _ServiceCategoryEditViewState extends State<ServiceCategoryEditView> {
  final ServiceCategoryController controller =
      Get.find<ServiceCategoryController>();

  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _descriptionController;

  String _categoryId = '';
  bool _prefilled = false; // biar tidak overwrite input user saat rebuild

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _descriptionController = TextEditingController();

    _categoryId = Get.parameters['id'] ?? '';

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadCategory();
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _loadCategory() async {
    if (_categoryId.isEmpty) {
      controller.errorMessage.value = 'Category ID tidak ditemukan.';
      return;
    }

    controller.isLoading.value = true;
    controller.errorMessage.value = '';

    try {
      final category = await controller.getCategoryById(_categoryId);
      if (!mounted) return;

      if (category == null) {
        controller.errorMessage.value = 'Kategori tidak ditemukan.';
        return;
      }

      if (!_prefilled) {
        _nameController.text = category.name;
        _descriptionController.text = category.description ?? '';
        _prefilled = true;
      }
    } catch (e) {
      controller.errorMessage.value = 'Gagal memuat kategori: $e';
    } finally {
      controller.isLoading.value = false;
    }
  }

  void _handleSubmit() {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    final name = _nameController.text.trim();
    final desc = _descriptionController.text.trim();

    controller.updateServiceCategory(
      id: _categoryId,
      name: name,
      description: desc.isEmpty ? null : desc,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final sp = theme.extension<AppSpacing>() ?? const AppSpacing();

    return MainLayout(
      parentRoute: AppRoutes.services,
      customAppBar: CustomAppBar(
        title: 'Edit Kategori Layanan',
        showBackButton: true,
        onBackPressed: () => controller.popPage(),
      ),
      child: PopScope(
        onPopInvokedWithResult: (didPop, result) {
          if (!didPop) controller.popPage();
        },
        child: Container(
          color: cs.background,
          child: SafeArea(
            child: Padding(
              padding: EdgeInsets.fromLTRB(sp.lg, sp.md, sp.lg, sp.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const _HeaderShell(
                    title: 'Edit Kategori',
                    subtitle: 'Perbarui nama dan deskripsi kategori layanan.',
                    icon: Icons.edit_outlined,
                  ),
                  SizedBox(height: sp.lg),
                  Expanded(
                    child: Obx(() {
                      final loading = controller.isLoading.value;
                      final err = controller.errorMessage.value;

                      if (loading) {
                        return _LoadingState(onRetry: _loadCategory);
                      }

                      if (err.isNotEmpty) {
                        return _ErrorState(
                          title: 'Terjadi Kesalahan',
                          message: err,
                          onRetry: _loadCategory,
                        );
                      }

                      return _FormCard(
                        formKey: _formKey,
                        nameController: _nameController,
                        descriptionController: _descriptionController,
                        onSubmit: _handleSubmit,
                        onCancel: () => controller.popPage(),
                      );
                    }),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ======================== UI PARTS (theme-driven) ========================

class _HeaderShell extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;

  const _HeaderShell({
    required this.title,
    required this.subtitle,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final sp = theme.extension<AppSpacing>() ?? const AppSpacing();

    return Container(
      padding: EdgeInsets.all(sp.md),
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.circular(AppRadii.lg),
        border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.55)),
        boxShadow: [
          BoxShadow(
            color: cs.shadow.withValues(alpha: 0.06),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: cs.primary.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(AppRadii.md),
              border: Border.all(color: cs.primary.withValues(alpha: 0.18)),
            ),
            child: Icon(icon, color: cs.primary, size: 22),
          ),
          SizedBox(width: sp.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w900,
                    letterSpacing: -0.2,
                  ),
                ),
                SizedBox(height: sp.xs),
                Text(
                  subtitle,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: cs.onSurface.withValues(alpha: 0.78),
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

class _FormCard extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final TextEditingController nameController;
  final TextEditingController descriptionController;

  final VoidCallback onSubmit;
  final VoidCallback onCancel;

  const _FormCard({
    required this.formKey,
    required this.nameController,
    required this.descriptionController,
    required this.onSubmit,
    required this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final sp = theme.extension<AppSpacing>() ?? const AppSpacing();

    return Container(
      padding: EdgeInsets.all(sp.lg),
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.circular(AppRadii.lg),
        border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.55)),
        boxShadow: [
          BoxShadow(
            color: cs.shadow.withValues(alpha: 0.06),
            blurRadius: 18,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Form(
        key: formKey,
        child: ListView(
          physics: const BouncingScrollPhysics(),
          children: [
            const _FieldLabel(label: 'Nama Kategori', requiredMark: true),
            SizedBox(height: sp.sm),
            AppTextField(
              controller: nameController,
              placeholder: 'Contoh: Baby Spa Premium',
              prefix: Icon(Icons.category_outlined, color: cs.primary),
              isRequired: true,
              validator: (v) {
                final value = (v ?? '').trim();
                if (value.isEmpty) return 'Nama kategori wajib diisi';
                if (value.length < 3) return 'Minimal 3 karakter';
                return null;
              },
            ),
            SizedBox(height: sp.lg),
            const _FieldLabel(label: 'Deskripsi', requiredMark: false),
            SizedBox(height: sp.sm),
            AppTextField(
              controller: descriptionController,
              placeholder: 'Tulis deskripsi singkat (opsional)',
              prefix: Icon(Icons.description_outlined, color: cs.primary),
              maxLines: 3,
            ),
            SizedBox(height: sp.xl),

            Obx(() {
              final c = Get.find<ServiceCategoryController>();
              final submitting = c.isFormSubmitting.value;

              return Column(
                children: [
                  AppButton(
                    text: 'Update Kategori',
                    icon: Icons.check_circle_outline,
                    isLoading: submitting,
                    onPressed: submitting ? null : onSubmit,
                    type: AppButtonType.primary,
                    size: AppButtonSize.large,
                    isFullWidth: true,
                  ),
                  SizedBox(height: sp.md),
                  AppButton(
                    text: 'Batal',
                    icon: Icons.close_outlined,
                    onPressed: submitting ? null : onCancel,
                    type: AppButtonType.outline,
                    size: AppButtonSize.large,
                    isFullWidth: true,
                  ),
                ],
              );
            }),
          ],
        ),
      ),
    );
  }
}

class _FieldLabel extends StatelessWidget {
  final String label;
  final bool requiredMark;

  const _FieldLabel({required this.label, required this.requiredMark});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return Row(
      children: [
        Text(
          label,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w800,
            letterSpacing: -0.1,
          ),
        ),
        if (requiredMark) ...[
          const SizedBox(width: 4),
          Text(
            '*',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w900,
              color: cs.error,
            ),
          ),
        ],
      ],
    );
  }
}

class _LoadingState extends StatelessWidget {
  final VoidCallback onRetry;
  const _LoadingState({required this.onRetry});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final sp = theme.extension<AppSpacing>() ?? const AppSpacing();

    return Center(
      child: Container(
        padding: EdgeInsets.all(sp.lg),
        decoration: BoxDecoration(
          color: cs.surface,
          borderRadius: BorderRadius.circular(AppRadii.lg),
          border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.55)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: 44,
              height: 44,
              child: CircularProgressIndicator(
                strokeWidth: 3,
                valueColor: AlwaysStoppedAnimation(cs.primary),
              ),
            ),
            SizedBox(height: sp.md),
            Text(
              'Memuat data kategori...',
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w700,
                color: cs.onSurface.withValues(alpha: 0.82),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  final String title;
  final String message;
  final VoidCallback onRetry;

  const _ErrorState({
    required this.title,
    required this.message,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final sp = theme.extension<AppSpacing>() ?? const AppSpacing();

    return Center(
      child: Container(
        padding: EdgeInsets.all(sp.lg),
        margin: EdgeInsets.symmetric(horizontal: sp.md),
        decoration: BoxDecoration(
          color: cs.surface,
          borderRadius: BorderRadius.circular(AppRadii.lg),
          border: Border.all(color: cs.error.withValues(alpha: 0.20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.error_outline_rounded, color: cs.error, size: 40),
            SizedBox(height: sp.md),
            Text(
              title,
              textAlign: TextAlign.center,
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w900,
              ),
            ),
            SizedBox(height: sp.xs),
            Text(
              message,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: cs.onSurface.withValues(alpha: 0.78),
                fontWeight: FontWeight.w600,
                height: 1.35,
              ),
            ),
            SizedBox(height: sp.lg),
            AppButton(
              text: 'Coba Lagi',
              icon: Icons.refresh_rounded,
              onPressed: onRetry,
              type: AppButtonType.primary,
              size: AppButtonSize.medium,
            ),
          ],
        ),
      ),
    );
  }
}
