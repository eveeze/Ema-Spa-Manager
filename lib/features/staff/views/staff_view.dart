// lib/features/staff/views/staff_view.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:emababyspa/common/theme/color_theme.dart';
import 'package:emababyspa/common/widgets/custom_appbar.dart';
import 'package:emababyspa/common/widgets/empty_state_widget.dart';
import 'package:emababyspa/common/layouts/main_layout.dart';
import 'package:emababyspa/features/staff/controllers/staff_controller.dart';
import 'package:emababyspa/features/theme/controllers/theme_controller.dart';
import 'package:emababyspa/data/models/staff.dart';

class StaffView extends GetView<StaffController> {
  const StaffView({super.key});

  @override
  Widget build(BuildContext context) {
    final ThemeController themeController = Get.find<ThemeController>();

    return MainLayout(
      child: Obx(() {
        final isDark = themeController.isDarkMode;

        final bg = isDark ? ColorTheme.backgroundDark : ColorTheme.background;
        final surface = isDark ? ColorTheme.surfaceDark : Colors.white;

        final primary =
            isDark ? ColorTheme.primaryLightDark : ColorTheme.primary;
        final textPrimary =
            isDark ? ColorTheme.textPrimaryDark : ColorTheme.textPrimary;
        final textSecondary =
            isDark ? ColorTheme.textSecondaryDark : ColorTheme.textSecondary;

        final isLoading = controller.isLoading.value;
        final error = controller.errorMessage.value;
        final items = controller.staffList;

        return Scaffold(
          backgroundColor: bg,
          appBar: const CustomAppBar(
            title: 'Manajemen Staf',
            showBackButton: true,
          ),

          floatingActionButton: _FabAddStaff(
            isDark: isDark,
            primary: primary,
            onTap: controller.navigateToAddStaff,
          ),

          floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,

          body: SafeArea(
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
                        isDark: isDark,
                        primary: primary,
                        textPrimary: textPrimary,
                        textSecondary: textSecondary,
                        count: items.length,
                      ),
                    ),
                  ),

                  if (isLoading)
                    SliverFillRemaining(
                      hasScrollBody: false,
                      child: _LoadingState(
                        primary: primary,
                        textSecondary: textSecondary,
                      ),
                    ),

                  if (!isLoading && error.isNotEmpty)
                    SliverPadding(
                      padding: const EdgeInsets.fromLTRB(24, 0, 24, 120),
                      sliver: SliverToBoxAdapter(
                        child: EmptyStateWidget(
                          title: 'Terjadi Kendala',
                          message: error,
                          icon: Icons.error_outline_rounded,
                          buttonLabel: 'Muat Ulang',
                          onButtonPressed: controller.refreshData,
                          fullScreen: false,
                        ),
                      ),
                    ),

                  if (!isLoading && error.isEmpty && items.isEmpty)
                    SliverPadding(
                      padding: const EdgeInsets.fromLTRB(24, 0, 24, 120),
                      sliver: SliverToBoxAdapter(
                        child: EmptyStateWidget(
                          title: 'Belum Ada Staf',
                          message:
                              'Tambahkan staf untuk membantu mengelola layanan dan reservasi.',
                          icon: Icons.people_outline_rounded,
                          buttonLabel: 'Tambah Staf',
                          onButtonPressed: controller.navigateToAddStaff,
                          fullScreen: false,
                        ),
                      ),
                    ),

                  if (!isLoading && error.isEmpty && items.isNotEmpty)
                    SliverPadding(
                      padding: const EdgeInsets.fromLTRB(24, 0, 24, 120),
                      sliver: SliverList.separated(
                        itemCount: items.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 16),
                        itemBuilder: (context, index) {
                          final staff = items[index];
                          return _AppearIn(
                            delayMs: (index * 35).clamp(0, 240),
                            child: _StaffCard(
                              staff: staff,
                              isDark: isDark,
                              primary: primary,
                              surface: surface,
                              textPrimary: textPrimary,
                              textSecondary: textSecondary,
                              onTap:
                                  () =>
                                      controller.navigateToEditStaff(staff.id),
                              onEdit:
                                  () =>
                                      controller.navigateToEditStaff(staff.id),
                              onToggle:
                                  () => controller.toggleStaffStatus(staff),
                              onDelete:
                                  () => _showDeleteConfirmation(
                                    context,
                                    staff,
                                    isDark,
                                  ),
                            ),
                          );
                        },
                      ),
                    ),
                ],
              ),
            ),
          ),
        );
      }),
    );
  }

  void _showDeleteConfirmation(BuildContext context, Staff staff, bool isDark) {
    Get.dialog(
      AlertDialog(
        backgroundColor: isDark ? ColorTheme.surfaceDark : Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          'Hapus Staf',
          style: TextStyle(
            fontFamily: 'JosefinSans',
            fontWeight: FontWeight.w800,
            color: isDark ? ColorTheme.textPrimaryDark : ColorTheme.textPrimary,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: (isDark ? ColorTheme.errorDark : ColorTheme.error)
                    .withValues(alpha: 0.10),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(
                Icons.warning_amber_rounded,
                size: 46,
                color: isDark ? ColorTheme.errorDark : ColorTheme.error,
              ),
            ),
            const SizedBox(height: 14),
            Text(
              'Yakin ingin menghapus ${staff.name}?',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'JosefinSans',
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color:
                    isDark
                        ? ColorTheme.textPrimaryDark
                        : ColorTheme.textPrimary,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Tindakan ini tidak dapat dibatalkan.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'JosefinSans',
                fontSize: 13.5,
                fontWeight: FontWeight.w600,
                color:
                    isDark
                        ? ColorTheme.textSecondaryDark
                        : ColorTheme.textSecondary,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: Text(
              'Batal',
              style: TextStyle(
                fontFamily: 'JosefinSans',
                fontWeight: FontWeight.w700,
                color:
                    isDark
                        ? ColorTheme.textSecondaryDark
                        : ColorTheme.textSecondary,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Get.back();
              controller.deleteStaff(staff.id);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: isDark ? ColorTheme.errorDark : ColorTheme.error,
              foregroundColor: isDark ? Colors.black : Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              elevation: 0,
            ),
            child: Text(
              'Hapus',
              style: TextStyle(
                fontFamily: 'JosefinSans',
                fontWeight: FontWeight.w800,
                color: isDark ? Colors.black : Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// =========================================================
// FAB
// =========================================================
class _FabAddStaff extends StatelessWidget {
  final bool isDark;
  final Color primary;
  final VoidCallback onTap;

  const _FabAddStaff({
    required this.isDark,
    required this.primary,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      child: FloatingActionButton.extended(
        onPressed: onTap,
        backgroundColor: primary,
        elevation: 10,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        icon: Icon(
          Icons.person_add_alt_1_rounded,
          color: isDark ? Colors.black : Colors.white,
          size: 20,
        ),
        label: Text(
          'Tambah Staf',
          style: TextStyle(
            color: isDark ? Colors.black : Colors.white,
            fontFamily: 'JosefinSans',
            fontWeight: FontWeight.w900,
            fontSize: 15,
            letterSpacing: 0.1,
          ),
        ),
      ),
    );
  }
}

// =========================================================
// Header (brand biru, ada count)
// =========================================================
class _HeaderHero extends StatelessWidget {
  final bool isDark;
  final Color primary;
  final Color textPrimary;
  final Color textSecondary;
  final int count;

  const _HeaderHero({
    required this.isDark,
    required this.primary,
    required this.textPrimary,
    required this.textSecondary,
    required this.count,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 54,
          height: 54,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: LinearGradient(
              colors: [
                primary.withValues(alpha: 0.22),
                primary.withValues(alpha: 0.08),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            border: Border.all(
              color: primary.withValues(alpha: 0.22),
              width: 1.2,
            ),
          ),
          child: Icon(Icons.groups_rounded, color: primary, size: 28),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Daftar Staf',
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.w900,
                  fontFamily: 'JosefinSans',
                  color: textPrimary,
                  letterSpacing: 0.2,
                  height: 1.1,
                ),
              ),
              const SizedBox(height: 5),
              Text(
                count == 0
                    ? 'Belum ada staf terdaftar'
                    : 'Mengelola $count staf untuk operasional harian',
                style: TextStyle(
                  fontSize: 15.5,
                  fontWeight: FontWeight.w700,
                  fontFamily: 'JosefinSans',
                  color: textSecondary,
                  height: 1.25,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 10),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            color: primary.withValues(alpha: isDark ? 0.16 : 0.10),
            border: Border.all(
              color: primary.withValues(alpha: 0.22),
              width: 1,
            ),
          ),
          child: Text(
            '$count',
            style: TextStyle(
              fontFamily: 'JosefinSans',
              fontSize: 15,
              fontWeight: FontWeight.w900,
              color: primary,
            ),
          ),
        ),
      ],
    );
  }
}

// =========================================================
// Loading
// =========================================================
class _LoadingState extends StatelessWidget {
  final Color primary;
  final Color textSecondary;

  const _LoadingState({required this.primary, required this.textSecondary});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: 46,
            height: 46,
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(primary),
              strokeWidth: 3,
              strokeCap: StrokeCap.round,
            ),
          ),
          const SizedBox(height: 14),
          Text(
            'Memuat data staf...',
            style: TextStyle(
              color: textSecondary,
              fontFamily: 'JosefinSans',
              fontSize: 14.5,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

// =========================================================
// Card staf (lebih clean + konsisten)
// =========================================================
class _StaffCard extends StatelessWidget {
  final Staff staff;
  final bool isDark;
  final Color primary;
  final Color surface;
  final Color textPrimary;
  final Color textSecondary;

  final VoidCallback onTap;
  final VoidCallback onEdit;
  final VoidCallback onToggle;
  final VoidCallback onDelete;

  const _StaffCard({
    required this.staff,
    required this.isDark,
    required this.primary,
    required this.surface,
    required this.textPrimary,
    required this.textSecondary,
    required this.onTap,
    required this.onEdit,
    required this.onToggle,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final borderColor =
        isDark
            ? ColorTheme.borderDark.withValues(alpha: 0.30)
            : Colors.black.withValues(alpha: 0.06);

    return Container(
      decoration: BoxDecoration(
        color: surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: borderColor, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.22 : 0.08),
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
          splashColor: primary.withValues(alpha: 0.10),
          highlightColor: primary.withValues(alpha: 0.05),
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _AvatarWithStatus(
                      staff: staff,
                      isDark: isDark,
                      primary: primary,
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _StaffInfo(
                        staff: staff,
                        isDark: isDark,
                        textPrimary: textPrimary,
                        textSecondary: textSecondary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                _ActionRow(
                  staff: staff,
                  isDark: isDark,
                  onEdit: onEdit,
                  onToggle: onToggle,
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

class _AvatarWithStatus extends StatelessWidget {
  final Staff staff;
  final bool isDark;
  final Color primary;

  const _AvatarWithStatus({
    required this.staff,
    required this.isDark,
    required this.primary,
  });

  @override
  Widget build(BuildContext context) {
    final ringColor =
        staff.isActive
            ? primary
            : (isDark ? ColorTheme.borderDark : ColorTheme.divider);

    return Stack(
      children: [
        Container(
          width: 68,
          height: 68,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(34),
            color: (isDark ? ColorTheme.accentDark : ColorTheme.accent)
                .withValues(alpha: 0.14),
            border: Border.all(color: ringColor, width: 3),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(31),
            child:
                (staff.profilePicture != null &&
                        (staff.profilePicture ?? '').isNotEmpty)
                    ? Image.network(
                      staff.profilePicture!,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) {
                        return Icon(
                          Icons.person_rounded,
                          size: 34,
                          color: primary,
                        );
                      },
                    )
                    : Icon(Icons.person_rounded, size: 34, color: primary),
          ),
        ),
        Positioned(
          right: 2,
          bottom: 2,
          child: Container(
            width: 18,
            height: 18,
            decoration: BoxDecoration(
              color:
                  staff.isActive
                      ? (isDark ? ColorTheme.successDark : ColorTheme.success)
                      : (isDark ? ColorTheme.errorDark : ColorTheme.error),
              borderRadius: BorderRadius.circular(9),
              border: Border.all(
                color: isDark ? ColorTheme.surfaceDark : Colors.white,
                width: 2,
              ),
            ),
            child: Icon(
              staff.isActive ? Icons.check : Icons.close,
              size: 11,
              color: Colors.white,
            ),
          ),
        ),
      ],
    );
  }
}

class _StaffInfo extends StatelessWidget {
  final Staff staff;
  final bool isDark;
  final Color textPrimary;
  final Color textSecondary;

  const _StaffInfo({
    required this.staff,
    required this.isDark,
    required this.textPrimary,
    required this.textSecondary,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                staff.name,
                style: TextStyle(
                  fontSize: 19,
                  fontWeight: FontWeight.w900,
                  fontFamily: 'JosefinSans',
                  color: textPrimary,
                  letterSpacing: -0.2,
                  height: 1.15,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(width: 10),
            _StatusPill(isDark: isDark, isActive: staff.isActive),
          ],
        ),
        const SizedBox(height: 10),
        _ContactRow(
          icon: Icons.email_rounded,
          text: staff.email,
          isDark: isDark,
        ),
        const SizedBox(height: 8),
        _ContactRow(
          icon: Icons.phone_rounded,
          text: staff.phoneNumber,
          isDark: isDark,
        ),
      ],
    );
  }
}

class _StatusPill extends StatelessWidget {
  final bool isDark;
  final bool isActive;

  const _StatusPill({required this.isDark, required this.isActive});

  @override
  Widget build(BuildContext context) {
    final fg =
        isActive
            ? (isDark ? ColorTheme.successDark : ColorTheme.success)
            : (isDark ? ColorTheme.errorDark : ColorTheme.error);

    final bg = fg.withValues(alpha: 0.14);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: fg.withValues(alpha: 0.85), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isActive ? Icons.check_circle : Icons.cancel,
            size: 14,
            color: fg,
          ),
          const SizedBox(width: 6),
          Text(
            isActive ? 'Aktif' : 'Nonaktif',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w900,
              fontFamily: 'JosefinSans',
              color: fg,
            ),
          ),
        ],
      ),
    );
  }
}

class _ContactRow extends StatelessWidget {
  final IconData icon;
  final String text;
  final bool isDark;

  const _ContactRow({
    required this.icon,
    required this.text,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final primary = isDark ? ColorTheme.primaryLightDark : ColorTheme.primary;

    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: primary.withValues(alpha: 0.10),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, size: 16, color: primary),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              fontSize: 14.5,
              fontWeight: FontWeight.w700,
              color: (isDark
                      ? ColorTheme.textPrimaryDark
                      : ColorTheme.textPrimary)
                  .withValues(alpha: 0.82),
              fontFamily: 'JosefinSans',
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}

class _ActionRow extends StatelessWidget {
  final Staff staff;
  final bool isDark;
  final VoidCallback onEdit;
  final VoidCallback onToggle;
  final VoidCallback onDelete;

  const _ActionRow({
    required this.staff,
    required this.isDark,
    required this.onEdit,
    required this.onToggle,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final bg =
        isDark
            ? ColorTheme.backgroundDark.withValues(alpha: 0.30)
            : ColorTheme.background;

    final border =
        isDark
            ? Colors.white.withValues(alpha: 0.10)
            : Colors.black.withValues(alpha: 0.06);

    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: border),
      ),
      child: Row(
        children: [
          _ActionButton(
            label: 'Edit',
            icon: Icons.edit_rounded,
            color: isDark ? ColorTheme.infoDark : ColorTheme.info,
            onTap: onEdit,
          ),
          _ActionButton(
            label: staff.isActive ? 'Nonaktifkan' : 'Aktifkan',
            icon:
                staff.isActive
                    ? Icons.person_off_rounded
                    : Icons.person_add_rounded,
            color:
                staff.isActive
                    ? (isDark ? ColorTheme.warningDark : ColorTheme.warning)
                    : (isDark ? ColorTheme.successDark : ColorTheme.success),
            onTap: onToggle,
          ),
          _ActionButton(
            label: 'Hapus',
            icon: Icons.delete_rounded,
            color: isDark ? ColorTheme.errorDark : ColorTheme.error,
            onTap: onDelete,
          ),
        ],
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _ActionButton({
    required this.label,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 4),
        child: Material(
          color: color.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(12),
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(12),
            splashColor: color.withValues(alpha: 0.20),
            highlightColor: color.withValues(alpha: 0.10),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(icon, size: 18, color: color),
                  const SizedBox(height: 4),
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: 11,
                      color: color,
                      fontWeight: FontWeight.w800,
                      fontFamily: 'JosefinSans',
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
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

// =========================================================
// Appear animation (ringan)
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
