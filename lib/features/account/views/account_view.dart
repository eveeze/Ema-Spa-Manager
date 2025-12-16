import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:emababyspa/common/layouts/main_layout.dart';
import 'package:emababyspa/common/theme/app_theme.dart'; // AppSpacing, AppRadii
import 'package:emababyspa/features/authentication/controllers/auth_controller.dart';
import 'package:emababyspa/features/theme/controllers/theme_controller.dart';

class AccountView extends StatelessWidget {
  const AccountView({super.key});

  @override
  Widget build(BuildContext context) {
    final authController = Get.find<AuthController>();
    final themeController = Get.find<ThemeController>();

    // ✅ ROOT Obx: biar SEMUA elemen di halaman (bukan cuma hero/tile) ikut update theme
    return Obx(() {
      // trigger rebuild saat theme/system brightness berubah
      themeController.forceRebuildRx.value;
      themeController.themeModeRx.value;
      themeController.systemBrightnessDarkRx.value;

      final theme = Theme.of(context);
      final cs = theme.colorScheme;
      final sp = theme.extension<AppSpacing>() ?? const AppSpacing();

      return MainLayout.subPage(
        title: 'Akun Saya',
        parentRoute: '/account',
        showAppBar: true,
        showBottomNavigation: true,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(
            parent: ClampingScrollPhysics(),
          ),
          padding: EdgeInsets.all(sp.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // =========================
              // HERO PROFILE
              // =========================
              _buildHero(context, authController, themeController),

              SizedBox(height: sp.lg),

              // =========================
              // PENGATURAN
              // =========================
              _SectionHeader(
                title: 'Pengaturan',
                subtitle: 'Sesuaikan tampilan aplikasi sesuai kebutuhan.',
                icon: Icons.tune_rounded,
              ),

              SizedBox(height: sp.sm),

              _SettingsCard(
                children: [
                  _SettingsTile(
                    icon: Icons.color_lens_outlined,
                    title: 'Mode Tampilan',
                    subtitle: themeController.themeModeDisplayName,
                    onTap: () => _showThemePicker(context, themeController),
                  ),
                ],
              ),

              SizedBox(height: sp.lg),

              // =========================
              // LOGOUT ONLY
              // =========================
              _DangerButton(
                label: 'Keluar',
                icon: Icons.logout_rounded,
                onTap: () => _confirmLogout(context, authController),
              ),

              SizedBox(height: sp.sm),

              // divider halus biar page berasa “selesai”
              Container(
                height: 1,
                decoration: BoxDecoration(
                  color: cs.outlineVariant.withValues(alpha: 0.35),
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
            ],
          ),
        ),
      );
    });
  }

  Widget _buildHero(
    BuildContext context,
    AuthController authController,
    ThemeController themeController,
  ) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final sp = theme.extension<AppSpacing>() ?? const AppSpacing();

    final isDark = themeController.isDarkMode;
    final owner = authController.owner.value;

    final name =
        owner?.name.trim().isNotEmpty == true ? owner!.name.trim() : 'Owner';
    final email = owner?.email ?? '—';
    final initial = (name.isNotEmpty ? name[0] : 'A').toUpperCase();

    return _GlassCard(
      borderRadius: AppRadii.xl,
      padding: EdgeInsets.all(sp.lg),
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          cs.primary.withValues(alpha: isDark ? 0.28 : 0.18),
          cs.secondary.withValues(alpha: isDark ? 0.22 : 0.14),
          cs.primaryContainer.withValues(alpha: isDark ? 0.18 : 0.10),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              _AvatarWellness(initial: initial, size: 64),
              SizedBox(width: sp.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.3,
                        color: cs.onSurface,
                      ),
                    ),
                    SizedBox(height: sp.xxs),
                    Text(
                      email,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: cs.onSurface.withValues(alpha: 0.72),
                        fontWeight: FontWeight.w600,
                        height: 1.2,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(width: sp.xs),
              _PillBadge(
                icon: themeController.themeModeIcon,
                text: themeController.themeModeDisplayName,
              ),
            ],
          ),
          SizedBox(height: sp.md),
          Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(horizontal: sp.sm, vertical: sp.sm),
            decoration: BoxDecoration(
              color: cs.surface.withValues(alpha: isDark ? 0.22 : 0.60),
              borderRadius: BorderRadius.circular(AppRadii.lg),
              border: Border.all(
                color: cs.outlineVariant.withValues(alpha: 0.45),
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: EdgeInsets.all(sp.xs),
                  decoration: BoxDecoration(
                    color: cs.primary.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(AppRadii.md),
                  ),
                  child: Icon(Icons.spa_outlined, size: 18, color: cs.primary),
                ),
                SizedBox(width: sp.sm),
                Expanded(
                  child: Text(
                    'Kelola preferensi akun dan tampilan aplikasi.',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: cs.onSurface.withValues(alpha: 0.78),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // =========================
  // LOGOUT CONFIRM
  // =========================
  void _confirmLogout(BuildContext context, AuthController authController) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final sp = theme.extension<AppSpacing>() ?? const AppSpacing();

    Get.bottomSheet(
      SafeArea(
        top: false,
        child: Container(
          padding: EdgeInsets.fromLTRB(sp.md, sp.sm, sp.md, sp.md),
          decoration: BoxDecoration(
            color: cs.surface,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(AppRadii.lg),
              topRight: Radius.circular(AppRadii.lg),
            ),
            border: Border(
              top: BorderSide(color: cs.outlineVariant.withValues(alpha: 0.45)),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 44,
                height: 5,
                decoration: BoxDecoration(
                  color: cs.outlineVariant.withValues(alpha: 0.6),
                  borderRadius: BorderRadius.circular(99),
                ),
              ),
              SizedBox(height: sp.sm),
              Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(sp.xs),
                    decoration: BoxDecoration(
                      color: cs.error.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(AppRadii.md),
                    ),
                    child: Icon(Icons.logout_rounded, color: cs.error),
                  ),
                  SizedBox(width: sp.sm),
                  Expanded(
                    child: Text(
                      'Keluar dari akun?',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.2,
                        color: cs.onSurface,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: sp.xs),
              Text(
                'Anda akan perlu login kembali untuk mengakses fitur manajer spa.',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: cs.onSurface.withValues(alpha: 0.72),
                  height: 1.35,
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(height: sp.md),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: Get.back,
                      style: OutlinedButton.styleFrom(
                        padding: EdgeInsets.symmetric(vertical: sp.sm),
                        side: BorderSide(
                          color: cs.outlineVariant.withValues(alpha: 0.8),
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(AppRadii.md),
                        ),
                      ),
                      child: const Text(
                        'Batal',
                        style: TextStyle(fontWeight: FontWeight.w800),
                      ),
                    ),
                  ),
                  SizedBox(width: sp.sm),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Get.back();
                        authController.logout();
                      },
                      style: ElevatedButton.styleFrom(
                        padding: EdgeInsets.symmetric(vertical: sp.sm),
                        backgroundColor: cs.error,
                        foregroundColor: cs.onError,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(AppRadii.md),
                        ),
                        elevation: 0,
                      ),
                      child: const Text(
                        'Keluar',
                        style: TextStyle(fontWeight: FontWeight.w900),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
    );
  }

  // =========================
  // THEME PICKER (TRUE REALTIME)
  // =========================
  void _showThemePicker(BuildContext context, ThemeController themeController) {
    Get.bottomSheet(
      Obx(() {
        // dependency
        themeController.forceRebuildRx.value;
        final mode = themeController.themeModeRx.value;

        final bool isDark = themeController.isDarkMode;
        final ThemeData effectiveTheme =
            isDark ? AppTheme.darkTheme : AppTheme.lightTheme;

        return Theme(
          data: effectiveTheme,
          child: Builder(
            builder: (sheetCtx) {
              final theme = Theme.of(sheetCtx);
              final cs = theme.colorScheme;
              final sp = theme.extension<AppSpacing>() ?? const AppSpacing();

              return Material(
                color: Colors.transparent,
                child: SafeArea(
                  top: false,
                  child: Container(
                    padding: EdgeInsets.fromLTRB(sp.md, sp.sm, sp.md, sp.md),
                    decoration: BoxDecoration(
                      color: cs.surface,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(AppRadii.lg),
                        topRight: Radius.circular(AppRadii.lg),
                      ),
                      border: Border(
                        top: BorderSide(
                          color: cs.outlineVariant.withValues(alpha: 0.45),
                        ),
                      ),
                    ),
                    child: Wrap(
                      runSpacing: sp.sm,
                      children: [
                        Center(
                          child: Container(
                            width: 44,
                            height: 5,
                            decoration: BoxDecoration(
                              color: cs.outlineVariant.withValues(alpha: 0.6),
                              borderRadius: BorderRadius.circular(99),
                            ),
                          ),
                        ),
                        SizedBox(height: sp.xs),
                        Row(
                          children: [
                            Container(
                              padding: EdgeInsets.all(sp.xs),
                              decoration: BoxDecoration(
                                color: cs.primary.withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(
                                  AppRadii.md,
                                ),
                              ),
                              child: Icon(
                                Icons.color_lens_outlined,
                                color: cs.primary,
                              ),
                            ),
                            SizedBox(width: sp.sm),
                            Expanded(
                              child: Text(
                                'Mode Tampilan',
                                style: theme.textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: -0.2,
                                  color: cs.onSurface,
                                ),
                              ),
                            ),
                            Text(
                              themeController.themeModeDisplayName,
                              style: theme.textTheme.labelLarge?.copyWith(
                                color: cs.onSurface.withValues(alpha: 0.72),
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ],
                        ),
                        _ModeOptionTile(
                          icon: Icons.light_mode_outlined,
                          title: 'Terang',
                          subtitle: 'Warna cerah dan bersih',
                          selected: mode == ThemeMode.light,
                          onTap: themeController.setLightMode,
                        ),
                        _ModeOptionTile(
                          icon: Icons.dark_mode_outlined,
                          title: 'Gelap',
                          subtitle: 'Lebih nyaman di malam hari',
                          selected: mode == ThemeMode.dark,
                          onTap: themeController.setDarkMode,
                        ),
                        _ModeOptionTile(
                          icon: Icons.brightness_auto_outlined,
                          title: 'Sesuai Sistem',
                          subtitle: 'Ikuti pengaturan perangkat',
                          selected: mode == ThemeMode.system,
                          onTap: themeController.setSystemMode,
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        );
      }),
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
    );
  }
}

// =========================
// UI BUILDING BLOCKS (MUST USE Theme.of(context))
// =========================

class _SectionHeader extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;

  const _SectionHeader({
    required this.title,
    required this.subtitle,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final sp = theme.extension<AppSpacing>() ?? const AppSpacing();

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 6,
          height: 26,
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
                  Icon(icon, size: 18, color: cs.primary),
                  SizedBox(width: sp.xs),
                  Expanded(
                    child: Text(
                      title,
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.2,
                        color: cs.onSurface,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: sp.xs),
              Text(
                subtitle,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: cs.onSurface.withValues(alpha: 0.78),
                  height: 1.35,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _SettingsCard extends StatelessWidget {
  final List<Widget> children;

  const _SettingsCard({required this.children});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final sp = theme.extension<AppSpacing>() ?? const AppSpacing();

    return DecoratedBox(
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(AppRadii.lg),
        border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.65)),
        boxShadow: [
          BoxShadow(
            color: theme.shadowColor.withValues(alpha: 0.06),
            blurRadius: 16,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.all(sp.sm),
        child: Column(children: children),
      ),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final VoidCallback onTap;

  const _SettingsTile({
    required this.icon,
    required this.title,
    this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final sp = theme.extension<AppSpacing>() ?? const AppSpacing();

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(AppRadii.md),
        onTap: onTap,
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: sp.sm, vertical: sp.sm),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppRadii.md),
            border: Border.all(
              color: cs.outlineVariant.withValues(alpha: 0.45),
            ),
          ),
          child: Row(
            children: [
              Container(
                padding: EdgeInsets.all(sp.xs),
                decoration: BoxDecoration(
                  color: cs.primary.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(AppRadii.md),
                ),
                child: Icon(icon, color: cs.primary, size: 20),
              ),
              SizedBox(width: sp.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.1,
                        color: cs.onSurface,
                      ),
                    ),
                    if (subtitle != null) ...[
                      SizedBox(height: sp.xxs),
                      Text(
                        subtitle!,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: cs.onSurface.withValues(alpha: 0.72),
                          fontWeight: FontWeight.w600,
                          height: 1.25,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios_rounded,
                size: 16,
                color: cs.onSurface.withValues(alpha: 0.45),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DangerButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onTap;

  const _DangerButton({
    required this.label,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final sp = theme.extension<AppSpacing>() ?? const AppSpacing();

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadii.lg),
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: sp.md, vertical: sp.md),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                cs.error.withValues(alpha: 0.95),
                cs.error.withValues(alpha: 0.78),
              ],
            ),
            borderRadius: BorderRadius.circular(AppRadii.lg),
            boxShadow: [
              BoxShadow(
                color: cs.error.withValues(alpha: 0.18),
                blurRadius: 18,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: cs.onError),
              SizedBox(width: sp.sm),
              Text(
                label,
                style: theme.textTheme.titleMedium?.copyWith(
                  color: cs.onError,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 0.2,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ModeOptionTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final bool selected;
  final VoidCallback onTap;

  const _ModeOptionTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.selected = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final sp = theme.extension<AppSpacing>() ?? const AppSpacing();

    final border =
        selected
            ? cs.primary.withValues(alpha: 0.85)
            : cs.outlineVariant.withValues(alpha: 0.45);

    final bg = selected ? cs.primary.withValues(alpha: 0.08) : null;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadii.md),
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: sp.sm, vertical: sp.sm),
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(AppRadii.md),
            border: Border.all(color: border),
          ),
          child: Row(
            children: [
              Container(
                padding: EdgeInsets.all(sp.xs),
                decoration: BoxDecoration(
                  color: cs.primary.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(AppRadii.md),
                ),
                child: Icon(icon, color: cs.primary, size: 20),
              ),
              SizedBox(width: sp.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                        color: cs.onSurface,
                      ),
                    ),
                    SizedBox(height: sp.xxs),
                    Text(
                      subtitle,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: cs.onSurface.withValues(alpha: 0.72),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              if (selected)
                Icon(Icons.check_rounded, color: cs.primary)
              else
                Icon(
                  Icons.chevron_right_rounded,
                  color: cs.onSurface.withValues(alpha: 0.45),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PillBadge extends StatelessWidget {
  final IconData icon;
  final String text;

  const _PillBadge({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final sp = theme.extension<AppSpacing>() ?? const AppSpacing();

    return Container(
      padding: EdgeInsets.symmetric(horizontal: sp.sm, vertical: sp.sm),
      decoration: BoxDecoration(
        color: cs.surface.withValues(alpha: 0.35),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.45)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 18, color: cs.primary),
          SizedBox(width: sp.xs),
          Text(
            text,
            style: theme.textTheme.labelLarge?.copyWith(
              fontWeight: FontWeight.w900,
              letterSpacing: 0.1,
              color: cs.onSurface,
            ),
          ),
        ],
      ),
    );
  }
}

class _AvatarWellness extends StatelessWidget {
  final String initial;
  final double size;

  const _AvatarWellness({required this.initial, required this.size});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            cs.primary.withValues(alpha: 0.95),
            cs.secondary.withValues(alpha: 0.85),
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: cs.primary.withValues(alpha: 0.22),
            blurRadius: 18,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Center(
        child: Text(
          initial,
          style: theme.textTheme.headlineMedium?.copyWith(
            color: cs.onPrimary,
            fontWeight: FontWeight.w900,
            letterSpacing: -0.6,
          ),
        ),
      ),
    );
  }
}

class _GlassCard extends StatelessWidget {
  final Widget child;
  final EdgeInsets padding;
  final double borderRadius;
  final Gradient? gradient;

  const _GlassCard({
    required this.child,
    this.padding = const EdgeInsets.all(20),
    this.borderRadius = 20,
    this.gradient,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
        child: Container(
          padding: padding,
          decoration: BoxDecoration(
            gradient: gradient,
            color: cs.surface.withValues(alpha: 0.55),
            borderRadius: BorderRadius.circular(borderRadius),
            border: Border.all(
              color: cs.outlineVariant.withValues(alpha: 0.45),
            ),
            boxShadow: [
              BoxShadow(
                color: theme.shadowColor.withValues(alpha: 0.08),
                blurRadius: 22,
                offset: const Offset(0, 12),
              ),
            ],
          ),
          child: child,
        ),
      ),
    );
  }
}
