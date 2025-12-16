// lib/features/service_category/views/service_category_view.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:emababyspa/common/layouts/main_layout.dart';
import 'package:emababyspa/common/theme/app_theme.dart';
import 'package:emababyspa/common/theme/semantic_colors.dart';
import 'package:emababyspa/common/widgets/custom_appbar.dart';
import 'package:emababyspa/common/widgets/empty_state_widget.dart';
import 'package:emababyspa/data/models/service_category.dart';
import 'package:emababyspa/features/service_category/controllers/service_category_controller.dart';
import 'package:emababyspa/utils/app_routes.dart';

class ServiceCategoryView extends GetView<ServiceCategoryController> {
  const ServiceCategoryView({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return MainLayout(
      parentRoute: AppRoutes.services,
      customAppBar: const CustomAppBar(
        title: 'Kategori Layanan',
        showBackButton: true,
      ),

      // ✅ FAB: theme sudah reactive, TIDAK perlu Obx
      floatingActionButton: FloatingActionButton.extended(
        onPressed: controller.navigateToAddServiceCategory,
        backgroundColor: cs.primary,
        elevation: 10,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadii.xl),
        ),
        icon: Icon(Icons.add_rounded, color: cs.onPrimary, size: 20),
        label: Text(
          'Tambah Kategori',
          style: theme.textTheme.labelLarge?.copyWith(
            color: cs.onPrimary,
            fontWeight: FontWeight.w900,
            letterSpacing: 0.1,
          ),
        ),
      ),

      // ✅ Obx cuma untuk Rx controller
      child: Obx(() {
        final theme = Theme.of(context);
        final cs = theme.colorScheme;
        final spacing = theme.extension<AppSpacing>()!;
        final semantic = theme.extension<AppSemanticColors>();

        final isLoading = controller.isLoading.value;
        final error = controller.errorMessage.value;
        final items = controller.serviceCategories;

        return Container(
          color: cs.background,
          child: RefreshIndicator(
            onRefresh: () async => controller.refreshData(),
            color: cs.primary,
            backgroundColor: cs.surface,
            strokeWidth: 2.5,
            child: CustomScrollView(
              physics: const AlwaysScrollableScrollPhysics(
                parent: BouncingScrollPhysics(),
              ),
              slivers: [
                SliverPadding(
                  padding: EdgeInsets.fromLTRB(
                    spacing.lg,
                    spacing.lg,
                    spacing.lg,
                    spacing.md,
                  ),
                  sliver: SliverToBoxAdapter(
                    child: _HeaderHero(
                      title: 'Kategori Layanan',
                      subtitle:
                          'Kelola kategori agar layanan lebih tertata dan mudah dicari',
                      icon: Icons.spa_rounded,
                    ),
                  ),
                ),

                // Count pill
                if (!isLoading && error.isEmpty && items.isNotEmpty)
                  SliverPadding(
                    padding: EdgeInsets.fromLTRB(
                      spacing.lg,
                      0,
                      spacing.lg,
                      spacing.md,
                    ),
                    sliver: SliverToBoxAdapter(
                      child: _CountPill(count: items.length),
                    ),
                  ),

                // Loading
                if (isLoading)
                  const SliverFillRemaining(
                    hasScrollBody: false,
                    child: _LoadingState(),
                  ),

                // Error
                if (!isLoading && error.isNotEmpty)
                  SliverPadding(
                    padding: EdgeInsets.fromLTRB(
                      spacing.lg,
                      0,
                      spacing.lg,
                      spacing.xxl * 2,
                    ),
                    sliver: SliverToBoxAdapter(
                      child: EmptyStateWidget(
                        title: 'Terjadi Kendala',
                        message: error,
                        icon: Icons.error_outline_rounded,
                        buttonLabel: 'Coba Lagi',
                        onButtonPressed: controller.refreshData,
                        fullScreen: false,
                      ),
                    ),
                  ),

                // Empty
                if (!isLoading && error.isEmpty && items.isEmpty)
                  SliverPadding(
                    padding: EdgeInsets.fromLTRB(
                      spacing.lg,
                      0,
                      spacing.lg,
                      spacing.xxl * 2,
                    ),
                    sliver: SliverToBoxAdapter(
                      child: EmptyStateWidget(
                        title: 'Belum Ada Kategori',
                        message:
                            'Buat kategori dulu supaya layanan kamu lebih rapi dan mudah dikelola.',
                        icon: Icons.category_outlined,
                        buttonLabel: 'Buat Kategori',
                        onButtonPressed:
                            controller.navigateToAddServiceCategory,
                        fullScreen: false,
                      ),
                    ),
                  ),

                // List
                if (!isLoading && error.isEmpty && items.isNotEmpty)
                  SliverPadding(
                    padding: EdgeInsets.fromLTRB(
                      spacing.lg,
                      0,
                      spacing.lg,
                      spacing.xxl * 2,
                    ),
                    sliver: SliverList.separated(
                      itemCount: items.length,
                      separatorBuilder: (_, __) => SizedBox(height: spacing.md),
                      itemBuilder: (context, index) {
                        final category = items[index];

                        // accents dari semantic + colorScheme (konsisten light/dark)
                        final accents = <Color>[
                          cs.primary,
                          semantic?.info ?? cs.secondary,
                          semantic?.success ?? cs.tertiary,
                          semantic?.warning ?? cs.secondaryContainer,
                        ];
                        final accent = accents[index % accents.length];

                        return _AppearIn(
                          delayMs: (index * 35).clamp(0, 240),
                          child: _CategoryCard(
                            category: category,
                            accent: accent,
                            onTap:
                                () => controller.navigateToEditServiceCategory(
                                  category.id.toString(),
                                ),
                            onEdit:
                                () => controller.navigateToEditServiceCategory(
                                  category.id.toString(),
                                ),
                            onDelete:
                                () => controller.showDeleteConfirmation(
                                  category.id.toString(),
                                  category.name,
                                ),
                          ),
                        );
                      },
                    ),
                  ),
              ],
            ),
          ),
        );
      }),
    );
  }
}

// =========================================================
// Header (pakai tokens)
// =========================================================

class _HeaderHero extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;

  const _HeaderHero({
    required this.title,
    required this.subtitle,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final spacing = theme.extension<AppSpacing>()!;

    return _AppearIn(
      delayMs: 0,
      child: Row(
        children: [
          Container(
            width: spacing.xxl * 1.8, // ~54
            height: spacing.xxl * 1.8,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(AppRadii.lg),
              gradient: LinearGradient(
                colors: [
                  cs.primary.withValues(alpha: 0.22),
                  cs.primary.withValues(alpha: 0.08),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              border: Border.all(
                color: cs.primary.withValues(alpha: 0.22),
                width: 1.2,
              ),
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
                    letterSpacing: 0.2,
                    height: 1.1,
                  ),
                ),
                SizedBox(height: spacing.xxs),
                Text(
                  subtitle,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: cs.onBackground.withValues(alpha: 0.72),
                    fontWeight: FontWeight.w700,
                    height: 1.25,
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

// =========================================================
// Count pill
// =========================================================

class _CountPill extends StatelessWidget {
  final int count;

  const _CountPill({required this.count});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final spacing = theme.extension<AppSpacing>()!;

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: spacing.lg,
        vertical: spacing.md,
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppRadii.lg),
        color: cs.primary.withValues(alpha: 0.10),
        border: Border.all(color: cs.primary.withValues(alpha: 0.22), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: spacing.xl * 1.1,
            height: spacing.xl * 1.1,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(AppRadii.md),
              color: cs.primary.withValues(alpha: 0.16),
            ),
            child: Icon(
              Icons.category_rounded,
              size: spacing.md,
              color: cs.primary,
            ),
          ),
          SizedBox(width: spacing.md),
          Text(
            '$count kategori tersedia',
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w900,
              color: cs.primary,
              letterSpacing: 0.1,
            ),
          ),
        ],
      ),
    );
  }
}

// =========================================================
// Loading state
// =========================================================

class _LoadingState extends StatelessWidget {
  const _LoadingState();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final spacing = theme.extension<AppSpacing>()!;

    return Center(
      child: _AppearIn(
        delayMs: 0,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: spacing.xxl * 2.6,
              height: spacing.xxl * 2.6,
              padding: EdgeInsets.all(spacing.lg),
              decoration: BoxDecoration(
                color: cs.surface,
                borderRadius: BorderRadius.circular(AppRadii.xl),
                boxShadow: AppShadows.soft(cs.shadow),
                border: Border.all(
                  color: cs.primary.withValues(alpha: 0.18),
                  width: 1,
                ),
              ),
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(cs.primary),
                strokeWidth: 3,
                strokeCap: StrokeCap.round,
              ),
            ),
            SizedBox(height: spacing.lg),
            Text(
              'Sedang memuat kategori...',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: cs.onBackground.withValues(alpha: 0.72),
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// =========================================================
// Card
// =========================================================

class _CategoryCard extends StatelessWidget {
  final ServiceCategory category;
  final Color accent;
  final VoidCallback onTap;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _CategoryCard({
    required this.category,
    required this.accent,
    required this.onTap,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final spacing = theme.extension<AppSpacing>()!;

    final borderColor = cs.outlineVariant.withValues(alpha: 0.65);

    return Container(
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.circular(AppRadii.xl),
        border: Border.all(color: borderColor, width: 1),
        boxShadow: AppShadows.soft(cs.shadow),
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(AppRadii.xl),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppRadii.xl),
          splashColor: cs.primary.withValues(alpha: 0.08),
          highlightColor: cs.primary.withValues(alpha: 0.04),
          child: Padding(
            padding: EdgeInsets.all(spacing.lg),
            child: Row(
              children: [
                Container(
                  width: spacing.xxl * 1.9,
                  height: spacing.xxl * 1.9,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(AppRadii.lg),
                    gradient: LinearGradient(
                      colors: [
                        accent.withValues(alpha: 0.18),
                        accent.withValues(alpha: 0.06),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    border: Border.all(
                      color: accent.withValues(alpha: 0.22),
                      width: 1,
                    ),
                  ),
                  child: Icon(
                    Icons.spa_rounded,
                    color: accent,
                    size: spacing.xl,
                  ),
                ),
                SizedBox(width: spacing.md),

                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        category.name,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w900,
                          letterSpacing: 0.1,
                          height: 1.15,
                        ),
                      ),
                      SizedBox(height: spacing.xxs),
                      if ((category.description ?? '').trim().isNotEmpty)
                        Text(
                          category.description!.trim(),
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: cs.onSurfaceVariant,
                            height: 1.35,
                            fontWeight: FontWeight.w600,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        )
                      else
                        Text(
                          'Belum ada deskripsi',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: cs.onSurfaceVariant.withValues(alpha: 0.85),
                            height: 1.25,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                    ],
                  ),
                ),

                SizedBox(width: spacing.sm),

                _ActionRail(onEdit: onEdit, onDelete: onDelete),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ActionRail extends StatelessWidget {
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _ActionRail({required this.onEdit, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final semantic = theme.extension<AppSemanticColors>();
    final spacing = theme.extension<AppSpacing>()!;

    final bg = cs.surfaceVariant.withValues(alpha: 0.35);
    final border = cs.outlineVariant.withValues(alpha: 0.65);
    final danger = semantic?.danger ?? cs.error;

    return Container(
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(AppRadii.lg),
        border: Border.all(color: border, width: 1),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          InkWell(
            onTap: onEdit,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(AppRadii.lg),
              topRight: Radius.circular(AppRadii.lg),
            ),
            child: Padding(
              padding: EdgeInsets.all(spacing.md),
              child: Icon(
                Icons.edit_outlined,
                size: spacing.lg,
                color: cs.onSurface,
              ),
            ),
          ),
          Container(height: 1, width: spacing.xl * 1.4, color: border),
          InkWell(
            onTap: onDelete,
            borderRadius: const BorderRadius.only(
              bottomLeft: Radius.circular(AppRadii.lg),
              bottomRight: Radius.circular(AppRadii.lg),
            ),
            child: Padding(
              padding: EdgeInsets.all(spacing.md),
              child: Icon(
                Icons.delete_outline_rounded,
                size: spacing.lg,
                color: danger,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// =========================================================
// Appear animation
// =========================================================

class _AppearIn extends StatefulWidget {
  final Widget child;
  final int delayMs;

  const _AppearIn({required this.child, required this.delayMs});

  @override
  State<_AppearIn> createState() => _AppearInState();
}

class _AppearInState extends State<_AppearIn>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c;
  late final Animation<double> _fade;
  late final Animation<Offset> _slide;

  @override
  void initState() {
    super.initState();
    _c = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 520),
    );
    _fade = CurvedAnimation(parent: _c, curve: Curves.easeOutCubic);
    _slide = Tween<Offset>(
      begin: const Offset(0, 0.06),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _c, curve: Curves.easeOutCubic));

    Future.delayed(Duration(milliseconds: widget.delayMs), () {
      if (mounted) _c.forward();
    });
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fade,
      child: SlideTransition(position: _slide, child: widget.child),
    );
  }
}
