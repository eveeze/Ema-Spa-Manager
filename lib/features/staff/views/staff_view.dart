// lib/features/staff/views/staff_view.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:emababyspa/common/layouts/main_layout.dart';
import 'package:emababyspa/common/theme/app_theme.dart';
import 'package:emababyspa/common/theme/semantic_colors.dart';
import 'package:emababyspa/common/widgets/custom_appbar.dart';
import 'package:emababyspa/common/widgets/empty_state_widget.dart';
import 'package:emababyspa/data/models/staff.dart';
import 'package:emababyspa/features/staff/controllers/staff_controller.dart';
import 'package:emababyspa/features/theme/controllers/theme_controller.dart';
import 'package:emababyspa/utils/app_routes.dart';

class StaffView extends GetView<StaffController> {
  const StaffView({super.key});

  Color _tone({required ThemeData theme, required bool isSuccess}) {
    final cs = theme.colorScheme;
    final semantic = theme.extension<AppSemanticColors>();
    if (isSuccess) return semantic?.success ?? cs.primary;
    return cs.error;
  }

  void _showTopSnack({
    required ThemeData theme,
    required String title,
    required String message,
    required bool isSuccess,
  }) {
    final cs = theme.colorScheme;
    final spacing = theme.extension<AppSpacing>()!;
    final tone = _tone(theme: theme, isSuccess: isSuccess);

    if (Get.isSnackbarOpen) Get.closeAllSnackbars();

    Get.snackbar(
      title,
      message,
      snackPosition: SnackPosition.TOP,
      duration: const Duration(seconds: 3),
      margin: EdgeInsets.all(spacing.md),
      borderRadius: AppRadii.lg,
      backgroundColor: tone.withOpacity(0.14),
      colorText: tone,
      icon: Icon(
        isSuccess ? Icons.check_circle_rounded : Icons.error_rounded,
        color: tone,
      ),
      shouldIconPulse: false,
    );
  }

  Future<void> _openAddStaff(BuildContext context) async {
    final theme = Theme.of(context);

    final result = await Get.toNamed(AppRoutes.staffForm);
    if (result is Map && result['success'] == true) {
      _showTopSnack(
        theme: theme,
        title: 'Berhasil',
        message: (result['message'] ?? 'Staff berhasil ditambahkan').toString(),
        isSuccess: true,
      );
      controller.refreshData();
    }
  }

  Future<void> _openEditStaff(BuildContext context, String id) async {
    final theme = Theme.of(context);

    final result = await Get.toNamed('/staffs/edit/$id');
    if (result is Map && result['success'] == true) {
      _showTopSnack(
        theme: theme,
        title: 'Berhasil',
        message:
            (result['message'] ?? 'Perubahan staff berhasil disimpan')
                .toString(),
        isSuccess: true,
      );
      controller.refreshData();
    }
  }

  void _showDeleteConfirmation(BuildContext context, Staff staff) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final spacing = theme.extension<AppSpacing>()!;
    final semantic = theme.extension<AppSemanticColors>();

    final danger = semantic?.danger ?? cs.error;

    Get.dialog(
      AlertDialog(
        backgroundColor: cs.surface,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadii.xl),
        ),
        title: Text(
          'Hapus Staf',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w900,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: EdgeInsets.all(spacing.md),
              decoration: BoxDecoration(
                color: danger.withOpacity(0.10),
                borderRadius: BorderRadius.circular(AppRadii.lg),
                border: Border.all(color: danger.withOpacity(0.18)),
              ),
              child: Icon(
                Icons.warning_amber_rounded,
                size: spacing.xxl,
                color: danger,
              ),
            ),
            SizedBox(height: spacing.md),
            Text(
              'Yakin ingin menghapus ${staff.name}?',
              textAlign: TextAlign.center,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w800,
              ),
            ),
            SizedBox(height: spacing.xxs),
            Text(
              'Tindakan ini tidak dapat dibatalkan.',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: cs.onSurfaceVariant,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        actionsPadding: EdgeInsets.fromLTRB(
          spacing.md,
          0,
          spacing.md,
          spacing.md,
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            style: TextButton.styleFrom(
              padding: EdgeInsets.symmetric(
                horizontal: spacing.md,
                vertical: spacing.sm,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppRadii.lg),
              ),
            ),
            child: Text(
              'Batal',
              style: theme.textTheme.labelLarge?.copyWith(
                fontWeight: FontWeight.w800,
                color: cs.onSurfaceVariant,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Get.back();
              controller.deleteStaff(staff.id);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: danger,
              foregroundColor: cs.onError,
              padding: EdgeInsets.symmetric(
                horizontal: spacing.md,
                vertical: spacing.sm,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppRadii.lg),
              ),
              elevation: 0,
            ),
            child: Text(
              'Hapus',
              style: theme.textTheme.labelLarge?.copyWith(
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final ThemeController themeController = Get.find<ThemeController>();
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final spacing = theme.extension<AppSpacing>()!;
    final semantic = theme.extension<AppSemanticColors>();

    return MainLayout(
      child: Obx(() {
        // ThemeController dipakai kalau kamu butuh state dark-mode untuk logic lain.
        // Di view ini, semua warna sudah dari Theme(colorScheme), jadi aman.
        final _ = themeController.isDarkMode;

        final isLoading = controller.isLoading.value;
        final error = controller.errorMessage.value;
        final items = controller.staffList;

        return Scaffold(
          backgroundColor: cs.background,
          appBar: const CustomAppBar(
            title: 'Manajemen Staf',
            showBackButton: true,
          ),
          floatingActionButton: _FabAddStaff(
            onTap: () => _openAddStaff(context),
          ),
          floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
          body: SafeArea(
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
                      spacing.md,
                      spacing.lg,
                      spacing.sm,
                    ),
                    sliver: SliverToBoxAdapter(
                      child: _HeaderHero(count: items.length),
                    ),
                  ),

                  if (isLoading)
                    SliverFillRemaining(
                      hasScrollBody: false,
                      child: _LoadingState(tone: semantic?.info ?? cs.primary),
                    ),

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
                          buttonLabel: 'Muat Ulang',
                          onButtonPressed: controller.refreshData,
                          fullScreen: false,
                        ),
                      ),
                    ),

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
                          title: 'Belum Ada Staf',
                          message:
                              'Tambahkan staf untuk membantu mengelola layanan dan reservasi.',
                          icon: Icons.people_outline_rounded,
                          buttonLabel: 'Tambah Staf',
                          onButtonPressed: () => _openAddStaff(context),
                          fullScreen: false,
                        ),
                      ),
                    ),

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
                        separatorBuilder:
                            (_, __) => SizedBox(height: spacing.md),
                        itemBuilder: (context, index) {
                          final staff = items[index];
                          return _AppearIn(
                            delayMs: (index * 35).clamp(0, 240),
                            child: _StaffCard(
                              staff: staff,
                              onTap: () => _openEditStaff(context, staff.id),
                              onEdit: () => _openEditStaff(context, staff.id),
                              onToggle:
                                  () => controller.toggleStaffStatus(staff),
                              onDelete:
                                  () => _showDeleteConfirmation(context, staff),
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
}

// =========================================================
// FAB (tokenized)
// =========================================================
class _FabAddStaff extends StatelessWidget {
  final VoidCallback onTap;

  const _FabAddStaff({required this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final spacing = theme.extension<AppSpacing>()!;

    return Container(
      margin: EdgeInsets.only(bottom: spacing.sm),
      child: FloatingActionButton.extended(
        onPressed: onTap,
        backgroundColor: cs.primary,
        foregroundColor: cs.onPrimary,
        elevation: 10,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadii.xl),
        ),
        icon: Icon(
          Icons.person_add_alt_1_rounded,
          color: cs.onPrimary,
          size: spacing.lg,
        ),
        label: Text(
          'Tambah Staf',
          style: theme.textTheme.labelLarge?.copyWith(
            color: cs.onPrimary,
            fontWeight: FontWeight.w900,
            letterSpacing: 0.1,
          ),
        ),
      ),
    );
  }
}

// =========================================================
// Header (pakai theme tokens)
// =========================================================
class _HeaderHero extends StatelessWidget {
  final int count;

  const _HeaderHero({required this.count});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final spacing = theme.extension<AppSpacing>()!;

    return Row(
      children: [
        Container(
          width: spacing.xxl * 1.2,
          height: spacing.xxl * 1.2,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppRadii.xl),
            gradient: LinearGradient(
              colors: [
                cs.primary.withOpacity(0.22),
                cs.primary.withOpacity(0.08),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            border: Border.all(color: cs.primary.withOpacity(0.22), width: 1.2),
          ),
          child: Icon(
            Icons.groups_rounded,
            color: cs.primary,
            size: spacing.xl,
          ),
        ),
        SizedBox(width: spacing.md),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Daftar Staf',
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w900,
                  letterSpacing: 0.2,
                  height: 1.1,
                ),
              ),
              SizedBox(height: spacing.xxs),
              Text(
                count == 0
                    ? 'Belum ada staf terdaftar'
                    : 'Mengelola $count staf untuk operasional harian',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: cs.onSurfaceVariant,
                  fontWeight: FontWeight.w700,
                  height: 1.25,
                ),
              ),
            ],
          ),
        ),
        SizedBox(width: spacing.sm),
        Container(
          padding: EdgeInsets.symmetric(
            horizontal: spacing.md,
            vertical: spacing.sm,
          ),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppRadii.xl),
            color: cs.primary.withOpacity(0.10),
            border: Border.all(color: cs.primary.withOpacity(0.22)),
          ),
          child: Text(
            '$count',
            style: theme.textTheme.labelLarge?.copyWith(
              fontWeight: FontWeight.w900,
              color: cs.primary,
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
  final Color tone;

  const _LoadingState({required this.tone});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final spacing = theme.extension<AppSpacing>()!;

    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: spacing.xxl,
            height: spacing.xxl,
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(tone),
              strokeWidth: 3,
              strokeCap: StrokeCap.round,
            ),
          ),
          SizedBox(height: spacing.md),
          Text(
            'Memuat data staf...',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: cs.onSurfaceVariant,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

// =========================================================
// Card staf (tetap, tapi token + theme)
// =========================================================
class _StaffCard extends StatelessWidget {
  final Staff staff;

  final Future<void> Function() onTap;
  final Future<void> Function() onEdit;
  final VoidCallback onToggle;
  final VoidCallback onDelete;

  const _StaffCard({
    required this.staff,
    required this.onTap,
    required this.onEdit,
    required this.onToggle,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final spacing = theme.extension<AppSpacing>()!;
    final semantic = theme.extension<AppSemanticColors>();

    final borderColor = cs.outlineVariant.withOpacity(0.70);

    return Container(
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.circular(AppRadii.xl),
        border: Border.all(color: borderColor),
        boxShadow: AppShadows.soft(cs.shadow),
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(AppRadii.xl),
        child: InkWell(
          onTap: () async => onTap(),
          borderRadius: BorderRadius.circular(AppRadii.xl),
          splashColor: cs.primary.withOpacity(0.10),
          highlightColor: cs.primary.withOpacity(0.05),
          child: Padding(
            padding: EdgeInsets.all(spacing.lg),
            child: Column(
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _AvatarWithStatus(
                      staff: staff,
                      activeTone: semantic?.success ?? cs.primary,
                      inactiveTone: semantic?.danger ?? cs.error,
                    ),
                    SizedBox(width: spacing.md),
                    Expanded(child: _StaffInfo(staff: staff)),
                  ],
                ),
                SizedBox(height: spacing.md),
                _ActionRow(
                  staff: staff,
                  onEdit: () async => onEdit(),
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
  final Color activeTone;
  final Color inactiveTone;

  const _AvatarWithStatus({
    required this.staff,
    required this.activeTone,
    required this.inactiveTone,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final spacing = theme.extension<AppSpacing>()!;

    final ringColor = staff.isActive ? activeTone : cs.outlineVariant;
    final dotColor = staff.isActive ? activeTone : inactiveTone;

    final double size = spacing.xxl * 1.55;

    return Stack(
      children: [
        Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(999),
            color: cs.primary.withOpacity(0.10),
            border: Border.all(color: ringColor, width: 3),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child:
                (staff.profilePicture != null &&
                        (staff.profilePicture ?? '').isNotEmpty)
                    ? Image.network(
                      staff.profilePicture!,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) {
                        return Icon(
                          Icons.person_rounded,
                          size: spacing.xl,
                          color: cs.primary,
                        );
                      },
                    )
                    : Icon(
                      Icons.person_rounded,
                      size: spacing.xl,
                      color: cs.primary,
                    ),
          ),
        ),
        Positioned(
          right: 2,
          bottom: 2,
          child: Container(
            width: spacing.lg,
            height: spacing.lg,
            decoration: BoxDecoration(
              color: dotColor,
              borderRadius: BorderRadius.circular(999),
              border: Border.all(color: cs.surface, width: 2),
            ),
            child: Icon(
              staff.isActive ? Icons.check : Icons.close,
              size: spacing.sm,
              color: cs.onPrimary,
            ),
          ),
        ),
      ],
    );
  }
}

class _StaffInfo extends StatelessWidget {
  final Staff staff;

  const _StaffInfo({required this.staff});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final spacing = theme.extension<AppSpacing>()!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                staff.name,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w900,
                  letterSpacing: -0.2,
                  height: 1.15,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            SizedBox(width: spacing.sm),
            _StatusPill(isActive: staff.isActive),
          ],
        ),
        SizedBox(height: spacing.md),
        _ContactRow(icon: Icons.email_rounded, text: staff.email),
        SizedBox(height: spacing.sm),
        _ContactRow(icon: Icons.phone_rounded, text: staff.phoneNumber),
      ],
    );
  }
}

class _StatusPill extends StatelessWidget {
  final bool isActive;

  const _StatusPill({required this.isActive});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final semantic = theme.extension<AppSemanticColors>();

    final fg =
        isActive
            ? (semantic?.success ?? cs.primary)
            : (semantic?.danger ?? cs.error);

    final bg = fg.withOpacity(0.14);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: fg.withOpacity(0.85), width: 1),
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
            style: theme.textTheme.labelSmall?.copyWith(
              fontWeight: FontWeight.w900,
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

  const _ContactRow({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final spacing = theme.extension<AppSpacing>()!;

    return Row(
      children: [
        Container(
          padding: EdgeInsets.all(spacing.xs),
          decoration: BoxDecoration(
            color: cs.primary.withOpacity(0.10),
            borderRadius: BorderRadius.circular(AppRadii.lg),
          ),
          child: Icon(icon, size: spacing.md, color: cs.primary),
        ),
        SizedBox(width: spacing.sm),
        Expanded(
          child: Text(
            text,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w700,
              color: cs.onSurface.withOpacity(0.82),
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
  final Future<void> Function() onEdit;
  final VoidCallback onToggle;
  final VoidCallback onDelete;

  const _ActionRow({
    required this.staff,
    required this.onEdit,
    required this.onToggle,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final spacing = theme.extension<AppSpacing>()!;
    final semantic = theme.extension<AppSemanticColors>();

    final bg = cs.surfaceVariant.withOpacity(0.35);
    final border = cs.outlineVariant.withOpacity(0.70);

    final info = semantic?.info ?? cs.secondary;
    final warn = semantic?.warning ?? Colors.orange;
    final ok = semantic?.success ?? cs.primary;
    final danger = semantic?.danger ?? cs.error;

    return Container(
      padding: EdgeInsets.all(spacing.sm),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(AppRadii.xl),
        border: Border.all(color: border),
      ),
      child: Row(
        children: [
          _ActionButton(
            label: 'Edit',
            icon: Icons.edit_rounded,
            tone: info,
            onTap: () async => onEdit(),
          ),
          _ActionButton(
            label: staff.isActive ? 'Nonaktifkan' : 'Aktifkan',
            icon:
                staff.isActive
                    ? Icons.person_off_rounded
                    : Icons.person_add_rounded,
            tone: staff.isActive ? warn : ok,
            onTap: onToggle,
          ),
          _ActionButton(
            label: 'Hapus',
            icon: Icons.delete_rounded,
            tone: danger,
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
  final Color tone;
  final VoidCallback onTap;

  const _ActionButton({
    required this.label,
    required this.icon,
    required this.tone,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final spacing = theme.extension<AppSpacing>()!;

    return Expanded(
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: spacing.xxs),
        child: Material(
          color: tone.withOpacity(0.12),
          borderRadius: BorderRadius.circular(AppRadii.lg),
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(AppRadii.lg),
            splashColor: tone.withOpacity(0.20),
            highlightColor: tone.withOpacity(0.10),
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: spacing.md,
                vertical: spacing.sm,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(icon, size: spacing.lg, color: tone),
                  SizedBox(height: spacing.xxs),
                  Text(
                    label,
                    style: theme.textTheme.labelSmall?.copyWith(
                      fontWeight: FontWeight.w900,
                      color: tone,
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
