// lib/features/service_category/views/service_category_view.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:emababyspa/common/theme/color_theme.dart';
import 'package:emababyspa/common/widgets/custom_appbar.dart';
import 'package:emababyspa/common/widgets/empty_state_widget.dart';
import 'package:emababyspa/common/layouts/main_layout.dart';
import 'package:emababyspa/features/service_category/controllers/service_category_controller.dart';
import 'package:emababyspa/features/theme/controllers/theme_controller.dart';
import 'package:emababyspa/data/models/service_category.dart';
import 'package:emababyspa/utils/app_routes.dart';

class ServiceCategoryView extends GetView<ServiceCategoryController> {
  const ServiceCategoryView({super.key});

  @override
  Widget build(BuildContext context) {
    final ThemeController themeController = Get.find<ThemeController>();

    return MainLayout(
      parentRoute: AppRoutes.services,
      customAppBar: const CustomAppBar(
        title: 'Kategori Layanan',
        showBackButton: true,
      ),

      // ✅ FAB
      floatingActionButton: Obx(() {
        final isDarkMode = themeController.isDarkMode;
        final primary =
            isDarkMode ? ColorTheme.primaryLightDark : ColorTheme.primary;

        return FloatingActionButton.extended(
          onPressed: controller.navigateToAddServiceCategory,
          backgroundColor: primary,
          elevation: 10,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
          icon: Icon(
            Icons.add_rounded,
            color: isDarkMode ? Colors.black : Colors.white,
            size: 20,
          ),
          label: Text(
            'Tambah Kategori',
            style: TextStyle(
              color: isDarkMode ? Colors.black : Colors.white,
              fontWeight: FontWeight.w800,
              fontFamily: 'JosefinSans',
              fontSize: 15,
              letterSpacing: 0.1,
            ),
          ),
        );
      }),

      child: Obx(() {
        final isDarkMode = themeController.isDarkMode;

        final bg =
            isDarkMode ? ColorTheme.backgroundDark : ColorTheme.background;
        final surface = isDarkMode ? ColorTheme.surfaceDark : Colors.white;

        final textPrimary =
            isDarkMode ? ColorTheme.textPrimaryDark : ColorTheme.textPrimary;
        final textSecondary =
            isDarkMode
                ? ColorTheme.textSecondaryDark
                : ColorTheme.textSecondary;

        final primary =
            isDarkMode ? ColorTheme.primaryLightDark : ColorTheme.primary;

        final isLoading = controller.isLoading.value;
        final error = controller.errorMessage.value;
        final items = controller.serviceCategories;

        return Container(
          color: bg,
          child: RefreshIndicator(
            onRefresh: () async => controller.refreshData(),
            color: primary,
            backgroundColor: surface,
            strokeWidth: 2.5,
            child: CustomScrollView(
              physics: const AlwaysScrollableScrollPhysics(
                parent: BouncingScrollPhysics(),
              ),
              slivers: [
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(24, 18, 24, 14),
                  sliver: SliverToBoxAdapter(
                    child: _HeaderHero(
                      isDarkMode: isDarkMode,
                      primaryColor: primary,
                      textPrimaryColor: textPrimary,
                      textSecondaryColor: textSecondary,
                    ),
                  ),
                ),

                // Count pill
                if (!isLoading && error.isEmpty && items.isNotEmpty)
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(24, 0, 24, 14),
                    sliver: SliverToBoxAdapter(
                      child: _CountPill(
                        count: items.length,
                        primaryColor: primary,
                        isDarkMode: isDarkMode,
                      ),
                    ),
                  ),

                // Loading
                if (isLoading)
                  SliverFillRemaining(
                    hasScrollBody: false,
                    child: _LoadingState(
                      surfaceColor: surface,
                      primaryColor: primary,
                      textSecondaryColor: textSecondary,
                    ),
                  ),

                // Error
                if (!isLoading && error.isNotEmpty)
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(24, 0, 24, 120),
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
                    padding: const EdgeInsets.fromLTRB(24, 0, 24, 120),
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
                    padding: const EdgeInsets.fromLTRB(24, 0, 24, 120),
                    sliver: SliverList.separated(
                      itemCount: items.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 16),
                      itemBuilder: (context, index) {
                        final category = items[index];

                        return _AppearIn(
                          delayMs: (index * 35).clamp(0, 240),
                          child: _CategoryCard(
                            category: category,
                            index: index,
                            isDarkMode: isDarkMode,
                            surfaceColor: surface,
                            textPrimaryColor: textPrimary,
                            textSecondaryColor: textSecondary,
                            primaryColor: primary,
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
// Header
// =========================================================

class _HeaderHero extends StatelessWidget {
  final bool isDarkMode;
  final Color primaryColor;
  final Color textPrimaryColor;
  final Color textSecondaryColor;

  const _HeaderHero({
    required this.isDarkMode,
    required this.primaryColor,
    required this.textPrimaryColor,
    required this.textSecondaryColor,
  });

  @override
  Widget build(BuildContext context) {
    return _AppearIn(
      delayMs: 0,
      child: Row(
        children: [
          Container(
            width: 54,
            height: 54,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              gradient: LinearGradient(
                colors: [
                  primaryColor.withValues(alpha: 0.22),
                  primaryColor.withValues(alpha: 0.08),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              border: Border.all(
                color: primaryColor.withValues(alpha: 0.22),
                width: 1.2,
              ),
            ),
            child: Icon(Icons.spa_rounded, color: primaryColor, size: 28),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Kategori Layanan',
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.w900,
                    fontFamily: 'JosefinSans',
                    color: textPrimaryColor,
                    letterSpacing: 0.2,
                    height: 1.1,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  'Kelola kategori agar layanan lebih tertata dan mudah dicari',
                  style: TextStyle(
                    fontSize: 15.5,
                    fontWeight: FontWeight.w600,
                    fontFamily: 'JosefinSans',
                    color: textSecondaryColor,
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
  final Color primaryColor;
  final bool isDarkMode;

  const _CountPill({
    required this.count,
    required this.primaryColor,
    required this.isDarkMode,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: primaryColor.withValues(alpha: isDarkMode ? 0.16 : 0.10),
        border: Border.all(
          color: primaryColor.withValues(alpha: 0.22),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color: primaryColor.withValues(alpha: 0.16),
            ),
            child: Icon(Icons.category_rounded, size: 16, color: primaryColor),
          ),
          const SizedBox(width: 10),
          Text(
            '$count kategori tersedia',
            style: TextStyle(
              fontFamily: 'JosefinSans',
              fontSize: 14.8,
              fontWeight: FontWeight.w900,
              color: primaryColor,
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
  final Color surfaceColor;
  final Color primaryColor;
  final Color textSecondaryColor;

  const _LoadingState({
    required this.surfaceColor,
    required this.primaryColor,
    required this.textSecondaryColor,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: _AppearIn(
        delayMs: 0,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 78,
              height: 78,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: surfaceColor,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: primaryColor.withValues(alpha: 0.12),
                    blurRadius: 18,
                    offset: const Offset(0, 10),
                  ),
                ],
                border: Border.all(
                  color: primaryColor.withValues(alpha: 0.18),
                  width: 1,
                ),
              ),
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(primaryColor),
                strokeWidth: 3,
              ),
            ),
            const SizedBox(height: 18),
            Text(
              'Sedang memuat kategori...',
              style: TextStyle(
                color: textSecondaryColor,
                fontFamily: 'JosefinSans',
                fontSize: 15.5,
                fontWeight: FontWeight.w700,
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
  final int index;
  final bool isDarkMode;
  final Color surfaceColor;
  final Color textPrimaryColor;
  final Color textSecondaryColor;
  final Color primaryColor;
  final VoidCallback onTap;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _CategoryCard({
    required this.category,
    required this.index,
    required this.isDarkMode,
    required this.surfaceColor,
    required this.textPrimaryColor,
    required this.textSecondaryColor,
    required this.primaryColor,
    required this.onTap,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final accents = <Color>[
      primaryColor,
      ColorTheme.info,
      ColorTheme.success,
      ColorTheme.warning,
    ];
    final accent = accents[index % accents.length];

    final borderColor =
        isDarkMode
            ? Colors.white.withValues(alpha: 0.08)
            : Colors.black.withValues(alpha: 0.06);

    return Container(
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: borderColor, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDarkMode ? 0.35 : 0.08),
            blurRadius: 18,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(20),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(20),
          splashColor: primaryColor.withValues(alpha: 0.08),
          highlightColor: primaryColor.withValues(alpha: 0.04),
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Row(
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    gradient: LinearGradient(
                      colors: [
                        accent.withValues(alpha: isDarkMode ? 0.22 : 0.16),
                        accent.withValues(alpha: isDarkMode ? 0.10 : 0.06),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    border: Border.all(
                      color: accent.withValues(alpha: 0.22),
                      width: 1,
                    ),
                  ),
                  child: Icon(Icons.spa_rounded, color: accent, size: 26),
                ),
                const SizedBox(width: 14),

                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        category.name,
                        style: TextStyle(
                          fontSize: 18.5,
                          fontWeight: FontWeight.w900,
                          color: textPrimaryColor,
                          fontFamily: 'JosefinSans',
                          letterSpacing: 0.1,
                          height: 1.15,
                        ),
                      ),
                      const SizedBox(height: 6),
                      if ((category.description ?? '').trim().isNotEmpty)
                        Text(
                          category.description!.trim(),
                          style: TextStyle(
                            fontSize: 14.5,
                            color: textSecondaryColor,
                            fontFamily: 'JosefinSans',
                            height: 1.35,
                            fontWeight: FontWeight.w600,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        )
                      else
                        Text(
                          'Belum ada deskripsi',
                          style: TextStyle(
                            fontSize: 14,
                            color: textSecondaryColor.withValues(alpha: 0.85),
                            fontFamily: 'JosefinSans',
                            height: 1.25,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                    ],
                  ),
                ),
                const SizedBox(width: 10),

                _ActionRail(
                  isDarkMode: isDarkMode,
                  onEdit: onEdit,
                  onDelete: onDelete,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ActionRail extends StatelessWidget {
  final bool isDarkMode;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _ActionRail({
    required this.isDarkMode,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final bg =
        isDarkMode
            ? Colors.white.withValues(alpha: 0.06)
            : Colors.black.withValues(alpha: 0.03);

    final border =
        isDarkMode
            ? Colors.white.withValues(alpha: 0.12)
            : Colors.black.withValues(alpha: 0.07);

    return Container(
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: border, width: 1),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          InkWell(
            onTap: onEdit,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(14),
              topRight: Radius.circular(14),
            ),
            child: const Padding(
              padding: EdgeInsets.all(12),
              child: Icon(Icons.edit_outlined, size: 20),
            ),
          ),
          Container(height: 1, width: 26, color: border),
          InkWell(
            onTap: onDelete,
            borderRadius: const BorderRadius.only(
              bottomLeft: Radius.circular(14),
              bottomRight: Radius.circular(14),
            ),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Icon(
                Icons.delete_outline_rounded,
                size: 20,
                color: isDarkMode ? ColorTheme.errorDark : ColorTheme.error,
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
