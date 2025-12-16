// lib/features/service/views/service_view.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:emababyspa/common/layouts/main_layout.dart';
import 'package:emababyspa/common/theme/app_theme.dart';
import 'package:emababyspa/common/widgets/empty_state_widget.dart';
import 'package:emababyspa/features/service/controllers/service_controller.dart';

class ServiceView extends GetView<ServiceController> {
  const ServiceView({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final sp = theme.extension<AppSpacing>() ?? const AppSpacing();

    return MainLayout(
      showBottomNavigation: true,
      enablePullToRefresh: true,
      onRefresh: controller.refreshData,
      child: Obx(() {
        final isInitialLoading =
            controller.isLoading.value &&
            controller.services.isEmpty &&
            controller.serviceCategories.isEmpty &&
            controller.staff.isEmpty;

        if (isInitialLoading) {
          return _buildLoadingState(context);
        }

        final allErrors =
            controller.serviceError.isNotEmpty &&
            controller.categoryError.isNotEmpty &&
            controller.staffError.isNotEmpty;

        if (allErrors) {
          return EmptyStateWidget(
            title: 'Koneksi Bermasalah',
            message:
                'Gagal memuat data. Periksa koneksi internet Anda dan coba lagi.',
            icon: Icons.error_outline_rounded,
            buttonLabel: 'Muat Ulang',
            onButtonPressed: controller.refreshData,
            fullScreen: true,
          );
        }

        return SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(
            parent: ClampingScrollPhysics(),
          ),
          padding: EdgeInsets.all(sp.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildAnimatedSection(
                duration: const Duration(milliseconds: 520),
                child: _buildStatsSection(context),
              ),
              SizedBox(height: sp.lg),
              _buildAnimatedSection(
                duration: const Duration(milliseconds: 620),
                child: _buildManagementSection(context),
              ),
              SizedBox(height: sp.lg),
            ],
          ),
        );
      }),
    );
  }

  // =========================
  // LOADING STATE
  // =========================
  Widget _buildLoadingState(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final tt = theme.textTheme;
    final sp = theme.extension<AppSpacing>() ?? const AppSpacing();

    return Center(
      child: Padding(
        padding: EdgeInsets.all(sp.lg),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 420),
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: cs.surface,
              borderRadius: BorderRadius.circular(AppRadii.xl),
              border: Border.all(
                color: cs.outlineVariant.withValues(alpha: 0.70),
              ),
              boxShadow: AppShadows.soft(cs.shadow),
            ),
            child: Padding(
              padding: EdgeInsets.all(sp.lg),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(
                    width: sp.xl + sp.sm, // ~46
                    height: sp.xl + sp.sm,
                    child: CircularProgressIndicator(
                      strokeWidth: 3,
                      valueColor: AlwaysStoppedAnimation<Color>(cs.primary),
                    ),
                  ),
                  SizedBox(height: sp.md),
                  Text(
                    'Memuat data layanan...',
                    style: tt.bodyMedium?.copyWith(
                      color: cs.onSurface.withValues(alpha: 0.78),
                      fontWeight: FontWeight.w600,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // =========================
  // ANIM WRAPPER
  // =========================
  Widget _buildAnimatedSection({
    required Duration duration,
    required Widget child,
  }) {
    return TweenAnimationBuilder<double>(
      duration: duration,
      curve: Curves.easeOutCubic,
      tween: Tween(begin: 0.0, end: 1.0),
      builder: (context, t, _) {
        return Opacity(
          opacity: t,
          child: Transform.translate(
            offset: Offset(0, 14 * (1 - t)),
            child: child,
          ),
        );
      },
      child: child,
    );
  }

  // =========================
  // SECTION HEADER
  // =========================
  Widget _buildSectionHeader(
    BuildContext context, {
    required String title,
    String? subtitle,
    IconData? icon,
  }) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final tt = theme.textTheme;
    final sp = theme.extension<AppSpacing>() ?? const AppSpacing();

    return Padding(
      padding: EdgeInsets.fromLTRB(sp.xxs, 0, sp.xxs, sp.sm),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 6,
            height: sp.xxl * 0.6, // ~26
            decoration: BoxDecoration(
              color: cs.primary,
              borderRadius: BorderRadius.circular(99),
            ),
          ),
          SizedBox(width: sp.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    if (icon != null) ...[
                      Icon(icon, size: 18, color: cs.primary),
                      SizedBox(width: sp.xs),
                    ],
                    Expanded(
                      child: Text(
                        title,
                        style: tt.titleLarge?.copyWith(
                          fontWeight: FontWeight.w800,
                          letterSpacing: -0.3,
                        ),
                      ),
                    ),
                  ],
                ),
                if (subtitle != null) ...[
                  SizedBox(height: sp.xxs),
                  Text(
                    subtitle,
                    style: tt.bodyMedium?.copyWith(
                      color: cs.onSurface.withValues(alpha: 0.78),
                      height: 1.35,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  // =========================
  // STATS SECTION
  // =========================
  Widget _buildStatsSection(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final sp = theme.extension<AppSpacing>() ?? const AppSpacing();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader(
          context,
          title: 'Ringkasan',
          subtitle: 'Lihat cepat jumlah layanan, staf, dan kategori.',
          icon: Icons.insights_rounded,
        ),
        SizedBox(
          height: 220,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                flex: 6,
                child: Column(
                  children: [
                    Expanded(
                      child: Padding(
                        padding: EdgeInsets.only(right: sp.sm, bottom: sp.xxs),
                        child: Obx(
                          () => _buildStatCard(
                            context,
                            title: 'Total Layanan',
                            count: controller.serviceCount.toString(),
                            isLoading: controller.isLoadingServices.value,
                            hasError: controller.serviceError.isNotEmpty,
                            onRetry: controller.refreshServices,
                            cardType: CardType.primary,
                            isCompact: true,
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: Padding(
                        padding: EdgeInsets.only(right: sp.sm, top: sp.xxs),
                        child: Obx(
                          () => _buildStatCard(
                            context,
                            title: 'Jumlah Staf',
                            count: controller.staffCount.toString(),
                            isLoading: controller.isLoadingStaff.value,
                            hasError: controller.staffError.isNotEmpty,
                            onRetry: controller.refreshStaff,
                            cardType: CardType.secondary,
                            isCompact: true,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                flex: 4,
                child: Padding(
                  padding: EdgeInsets.only(left: sp.sm),
                  child: Obx(
                    () => _buildStatCard(
                      context,
                      title: 'Kategori',
                      count: controller.categoryCount.toString(),
                      isLoading: controller.isLoadingCategories.value,
                      hasError: controller.categoryError.isNotEmpty,
                      onRetry: controller.refreshCategories,
                      cardType: CardType.accent,
                      isCompact: false,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: sp.xxs),
        Divider(
          height: sp.lg,
          color: cs.outlineVariant.withValues(alpha: 0.60),
        ),
      ],
    );
  }

  // =========================
  // STAT CARD
  // =========================
  Widget _buildStatCard(
    BuildContext context, {
    required String title,
    required String count,
    required bool isLoading,
    required bool hasError,
    required VoidCallback onRetry,
    required CardType cardType,
    bool isCompact = false,
  }) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final tt = theme.textTheme;
    final sp = theme.extension<AppSpacing>() ?? const AppSpacing();

    final w = MediaQuery.of(context).size.width;

    final padding = isCompact ? sp.sm : sp.md;
    final countSize =
        isCompact ? (w > 360 ? 20.0 : 18.0) : (w > 360 ? 32.0 : 28.0);

    Gradient? gradient;
    Color? solid;
    Color fg;
    Color fgSoft;
    BoxBorder? border;

    switch (cardType) {
      case CardType.primary:
        gradient = LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [cs.primary, cs.secondary],
        );
        fg = cs.onPrimary;
        fgSoft = cs.onPrimary.withValues(alpha: 0.90);
        break;

      case CardType.accent:
        gradient = LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [cs.secondary, cs.primary.withValues(alpha: 0.90)],
        );
        fg = cs.onSecondary;
        fgSoft = cs.onSecondary.withValues(alpha: 0.90);
        break;

      case CardType.secondary:
        solid = cs.surface;
        fg = cs.onSurface;
        fgSoft = cs.onSurface.withValues(alpha: 0.78);
        border = Border.all(color: cs.outlineVariant.withValues(alpha: 0.65));
        break;
    }

    return DecoratedBox(
      decoration: BoxDecoration(
        color: gradient == null ? solid : null,
        gradient: gradient,
        borderRadius: BorderRadius.circular(AppRadii.lg),
        border: border,
        boxShadow: AppShadows.soft(cs.shadow),
      ),
      child: Padding(
        padding: EdgeInsets.all(padding),
        child: Stack(
          children: [
            Align(
              alignment: Alignment.topLeft,
              child: Builder(
                builder: (_) {
                  if (isLoading) {
                    final s = isCompact ? sp.md : sp.lg;
                    return SizedBox(
                      width: s,
                      height: s,
                      child: CircularProgressIndicator(
                        strokeWidth: 3,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          gradient != null ? fg : cs.primary,
                        ),
                      ),
                    );
                  }

                  if (hasError) {
                    return InkWell(
                      onTap: onRetry,
                      borderRadius: BorderRadius.circular(AppRadii.sm),
                      child: Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: sp.sm,
                          vertical: sp.xs,
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.refresh_rounded, size: 16, color: fg),
                            SizedBox(width: sp.xs),
                            Text(
                              'Coba lagi',
                              style: tt.labelLarge?.copyWith(
                                color: fg,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }

                  return Text(
                    count,
                    style: tt.headlineMedium?.copyWith(
                      fontSize: countSize,
                      fontWeight: FontWeight.w900,
                      color: fg,
                      letterSpacing: -1.1,
                      height: 1.0,
                    ),
                  );
                },
              ),
            ),
            Align(
              alignment: Alignment.bottomLeft,
              child: Text(
                title,
                maxLines: isCompact ? 1 : 2,
                overflow: TextOverflow.ellipsis,
                style: (isCompact ? tt.labelLarge : tt.titleSmall)?.copyWith(
                  color: fgSoft,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.2,
                  height: 1.2,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // =========================
  // MANAGEMENT SECTION
  // =========================
  Widget _buildManagementSection(BuildContext context) {
    final sp = Theme.of(context).extension<AppSpacing>() ?? const AppSpacing();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader(
          context,
          title: 'Manajemen',
          subtitle: 'Kelola katalog layanan agar rapi dan selalu terbaru.',
          icon: Icons.tune_rounded,
        ),
        _buildManagementCard(
          context,
          title: 'Kelola Layanan',
          subtitle: 'Tambah, ubah, atau hapus layanan dan treatment spa',
          imagePath: 'assets/icons/service.png',
          onTap: controller.navigateToManageServices,
        ),
        SizedBox(height: sp.sm),
        _buildManagementCard(
          context,
          title: 'Kelola Staf',
          subtitle: 'Atur staf dan penugasan mereka',
          imagePath: 'assets/icons/staff.png',
          onTap: controller.navigateToManageStaff,
        ),
        SizedBox(height: sp.sm),
        _buildManagementCard(
          context,
          title: 'Kelola Kategori',
          subtitle: 'Susun dan kelompokkan penawaran layanan',
          imagePath: 'assets/icons/service_category.png',
          onTap: controller.navigateToManageCategories,
        ),
      ],
    );
  }

  Widget _buildManagementCard(
    BuildContext context, {
    required String title,
    required String subtitle,
    required String imagePath,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final tt = theme.textTheme;
    final sp = theme.extension<AppSpacing>() ?? const AppSpacing();

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadii.lg),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: cs.surface,
            borderRadius: BorderRadius.circular(AppRadii.lg),
            border: Border.all(
              color: cs.outlineVariant.withValues(alpha: 0.65),
            ),
            boxShadow: AppShadows.soft(cs.shadow),
          ),
          child: Padding(
            padding: EdgeInsets.all(sp.md),
            child: Row(
              children: [
                _buildLeadingIconImage(
                  context,
                  title: title,
                  imagePath: imagePath,
                ),
                SizedBox(width: sp.sm),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: tt.titleMedium?.copyWith(
                          fontWeight: FontWeight.w800,
                          letterSpacing: -0.2,
                        ),
                      ),
                      SizedBox(height: sp.xxs),
                      Text(
                        subtitle,
                        style: tt.bodyMedium?.copyWith(
                          color: cs.onSurface.withValues(alpha: 0.80),
                          height: 1.35,
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                SizedBox(width: sp.sm),
                Container(
                  padding: EdgeInsets.all(sp.xs),
                  decoration: BoxDecoration(
                    color: cs.primary.withValues(alpha: 0.10),
                    borderRadius: BorderRadius.circular(AppRadii.sm),
                  ),
                  child: Icon(
                    Icons.arrow_forward_ios_rounded,
                    size: 16,
                    color: cs.primary,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLeadingIconImage(
    BuildContext context, {
    required String title,
    required String imagePath,
  }) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final sp = theme.extension<AppSpacing>() ?? const AppSpacing();

    IconData fallback;
    final t = title.toLowerCase();
    if (t.contains('layanan')) {
      fallback = Icons.spa_rounded;
    } else if (t.contains('staf')) {
      fallback = Icons.people_rounded;
    } else {
      fallback = Icons.category_rounded;
    }

    final size = sp.xxl * 1.2; // ~52-53

    return Container(
      width: size,
      height: size,
      padding: EdgeInsets.all(sp.xs),
      decoration: BoxDecoration(
        color: cs.primary.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(AppRadii.md),
      ),
      child: Image.asset(
        imagePath,
        fit: BoxFit.contain,
        errorBuilder: (context, error, stackTrace) {
          return Icon(fallback, color: cs.primary, size: sp.lg);
        },
      ),
    );
  }
}

enum CardType { primary, secondary, accent }
