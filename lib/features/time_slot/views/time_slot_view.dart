// lib/features/time_slot/views/time_slot_view.dart
import 'package:emababyspa/features/schedule/controllers/schedule_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:emababyspa/common/layouts/main_layout.dart';
import 'package:emababyspa/common/theme/app_theme.dart';
import 'package:emababyspa/common/theme/semantic_colors.dart';
import 'package:emababyspa/common/widgets/app_button.dart';
import 'package:emababyspa/features/time_slot/controllers/time_slot_controller.dart';
import 'package:emababyspa/features/session/controllers/session_controller.dart';
import 'package:emababyspa/utils/app_routes.dart';
import 'package:emababyspa/utils/timezone_utils.dart';
import 'package:emababyspa/common/widgets/custom_appbar.dart';

class TimeSlotView extends StatefulWidget {
  const TimeSlotView({super.key});

  @override
  State<TimeSlotView> createState() => _TimeSlotViewState();
}

class _TimeSlotViewState extends State<TimeSlotView> {
  final controller = Get.find<TimeSlotController>();
  final sessionController = Get.find<SessionController>();

  dynamic _initialTimeSlot;

  @override
  void initState() {
    super.initState();

    final args = Get.arguments as Map<String, dynamic>;
    _initialTimeSlot = args['timeSlot'];

    // ✅ FIX: lakukan update Rx + fetch setelah frame pertama selesai
    // untuk menghindari "markNeedsBuild called during build" pada Obx.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;

      if (controller.selectedTimeSlot.value == null) {
        controller.selectedTimeSlot.value = _initialTimeSlot;
      }

      final slot = controller.selectedTimeSlot.value ?? _initialTimeSlot;
      if (slot != null) {
        sessionController.fetchSessions(timeSlotId: slot.id);
      }
    });
  }

  @override
  void dispose() {
    controller.clearSelectedTimeSlot();
    sessionController.resetSessionState();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final currentTimeSlot = controller.selectedTimeSlot.value;

      if (currentTimeSlot == null) {
        return Scaffold(
          body: Center(
            child: CircularProgressIndicator(
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
        );
      }

      final theme = Theme.of(context);
      final colorScheme = theme.colorScheme;

      return Scaffold(
        backgroundColor: theme.scaffoldBackgroundColor,
        appBar: CustomAppBar(
          title: 'Detail Slot Waktu',
          backgroundColor: colorScheme.surface,
          actions: [
            PopupMenuButton<String>(
              icon: Icon(Icons.more_vert, color: colorScheme.onSurfaceVariant),
              onSelected: (value) {
                if (value == 'edit') {
                  _onEditTimeSlot(currentTimeSlot);
                } else if (value == 'delete') {
                  _showDeleteConfirmation(context, currentTimeSlot);
                }
              },
              itemBuilder:
                  (BuildContext context) => <PopupMenuEntry<String>>[
                    PopupMenuItem<String>(
                      value: 'edit',
                      child: ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: Icon(
                          Icons.edit_outlined,
                          color: colorScheme.onSurfaceVariant,
                        ),
                        title: Text('Ubah', style: theme.textTheme.bodyLarge),
                      ),
                    ),
                    const PopupMenuDivider(),
                    PopupMenuItem<String>(
                      value: 'delete',
                      child: ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: Icon(
                          Icons.delete_outline,
                          color: colorScheme.error,
                        ),
                        title: Text(
                          'Hapus',
                          style: theme.textTheme.bodyLarge?.copyWith(
                            color: colorScheme.error,
                          ),
                        ),
                      ),
                    ),
                  ],
            ),
          ],
        ),
        body: MainLayout(
          child: SafeArea(
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal:
                    (theme.extension<AppSpacing>() ?? const AppSpacing()).lg,
              ),
              child: _buildBody(context, currentTimeSlot),
            ),
          ),
        ),
      );
    });
  }

  void _onEditTimeSlot(dynamic timeSlot) async {
    final result = await Get.toNamed(
      AppRoutes.timeSlotEdit.replaceAll(':id', timeSlot.id.toString()),
      arguments: {'timeSlot': timeSlot},
    );

    if (result != null && mounted) {
      await controller.refreshSelectedTimeSlot(timeSlot.id);
      await sessionController.fetchSessions(timeSlotId: timeSlot.id);
    }
  }

  Widget _buildBody(BuildContext context, dynamic timeSlot) {
    final theme = Theme.of(context);
    final spacing = theme.extension<AppSpacing>() ?? const AppSpacing();

    return RefreshIndicator(
      onRefresh: () async {
        await controller.refreshSelectedTimeSlot(timeSlot.id);
        await sessionController.fetchSessions(timeSlotId: timeSlot.id);
      },
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: spacing.md),
            // Obx di sini aman, karena update Rx utama sudah dipindah ke postFrame.
            Obx(
              () => _buildTimeSlotHeader(
                context,
                timeSlot,
                sessionController.sessions,
              ),
            ),
            SizedBox(height: spacing.xl),
            _buildSessionsSection(context, timeSlot),
            SizedBox(height: spacing.xxl),
          ],
        ),
      ),
    );
  }

  Widget _buildTimeSlotHeader(
    BuildContext context,
    dynamic timeSlot,
    List<dynamic> sessions,
  ) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;
    final spacing = theme.extension<AppSpacing>() ?? const AppSpacing();
    final semantic = theme.extension<AppSemanticColors>();

    final String dateFormatted = TimeZoneUtil.formatISOToIndonesiaTime(
      timeSlot.startTime.toIso8601String(),
      format: 'EEEE, d MMMM yyyy',
    );
    final String startTime = TimeZoneUtil.formatISOToIndonesiaTime(
      timeSlot.startTime.toIso8601String(),
    );
    final String endTime = TimeZoneUtil.formatISOToIndonesiaTime(
      timeSlot.endTime.toIso8601String(),
    );

    final int totalSessions = sessions.length;
    final int bookedSessions = sessions.where((s) => s.isBooked == true).length;
    final int availableSessions = totalSessions - bookedSessions;
    final bool allBooked = totalSessions > 0 && bookedSessions == totalSessions;

    final successColor = semantic?.success ?? colorScheme.tertiary;

    return Card(
      elevation: 0,
      color: colorScheme.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadii.xl),
        side: BorderSide(
          color: colorScheme.outlineVariant.withValues(alpha: 0.70),
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: Padding(
        padding: EdgeInsets.all(spacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  height: 36,
                  padding: EdgeInsets.symmetric(horizontal: spacing.sm),
                  decoration: BoxDecoration(
                    color: colorScheme.surfaceContainerHighest.withValues(
                      alpha: 0.55,
                    ),
                    borderRadius: BorderRadius.circular(999),
                    border: Border.all(
                      color: colorScheme.outlineVariant.withValues(alpha: 0.70),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.calendar_today,
                        size: 16,
                        color: colorScheme.onSurfaceVariant,
                      ),
                      SizedBox(width: spacing.xs),
                      Text(
                        dateFormatted,
                        style: textTheme.labelLarge?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: spacing.md),
            Divider(color: colorScheme.outlineVariant.withValues(alpha: 0.70)),
            SizedBox(height: spacing.md),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Rentang Waktu',
                        style: textTheme.labelLarge?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      SizedBox(height: spacing.xs),
                      Text(
                        '$startTime - $endTime',
                        style: textTheme.headlineSmall?.copyWith(
                          color: colorScheme.onSurface,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ],
                  ),
                ),
                _buildStatusBadge(context, allBooked),
              ],
            ),
            SizedBox(height: spacing.md),
            Divider(color: colorScheme.outlineVariant.withValues(alpha: 0.70)),
            SizedBox(height: spacing.md),
            Container(
              padding: EdgeInsets.symmetric(vertical: spacing.sm),
              decoration: BoxDecoration(
                color: colorScheme.surfaceContainerHighest.withValues(
                  alpha: 0.35,
                ),
                borderRadius: BorderRadius.circular(AppRadii.lg),
                border: Border.all(
                  color: colorScheme.outlineVariant.withValues(alpha: 0.70),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildStatItem(
                    context: context,
                    title: 'Total',
                    value: '$totalSessions',
                    color: colorScheme.primary,
                  ),
                  _buildStatDivider(context),
                  _buildStatItem(
                    context: context,
                    title: 'Terpesan',
                    value: '$bookedSessions',
                    color: colorScheme.error,
                  ),
                  _buildStatDivider(context),
                  _buildStatItem(
                    context: context,
                    title: 'Tersedia',
                    value: '$availableSessions',
                    color: successColor,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatDivider(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final spacing = theme.extension<AppSpacing>() ?? const AppSpacing();

    return Container(
      height: spacing.xl,
      width: 1,
      color: colorScheme.outlineVariant.withValues(alpha: 0.70),
    );
  }

  Widget _buildStatItem({
    required BuildContext context,
    required String title,
    required String value,
    required Color color,
  }) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final colorScheme = theme.colorScheme;
    final spacing = theme.extension<AppSpacing>() ?? const AppSpacing();

    return Column(
      children: [
        Text(
          value,
          style: textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w900,
            color: color,
          ),
        ),
        SizedBox(height: spacing.xxs),
        Text(
          title,
          style: textTheme.bodySmall?.copyWith(
            color: colorScheme.onSurfaceVariant,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildStatusBadge(BuildContext context, bool allBooked) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;
    final spacing = theme.extension<AppSpacing>() ?? const AppSpacing();
    final semantic = theme.extension<AppSemanticColors>();
    final successColor = semantic?.success ?? colorScheme.tertiary;

    final bgColor =
        allBooked
            ? colorScheme.errorContainer.withValues(alpha: 0.85)
            : successColor.withValues(alpha: 0.12);
    final fgColor = allBooked ? colorScheme.onErrorContainer : successColor;

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: spacing.md,
        vertical: spacing.xs,
      ),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: fgColor.withValues(alpha: 0.22)),
      ),
      child: Text(
        allBooked ? 'Penuh' : 'Tersedia',
        style: textTheme.labelMedium?.copyWith(
          color: fgColor,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }

  Widget _buildSessionsSection(BuildContext context, dynamic timeSlot) {
    final theme = Theme.of(context);
    final spacing = theme.extension<AppSpacing>() ?? const AppSpacing();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader(context, 'Sesi', timeSlot),
        SizedBox(height: spacing.md),
        Obx(() {
          if (sessionController.isLoading.value) {
            return Center(
              child: Padding(
                padding: EdgeInsets.all(spacing.xl),
                child: CircularProgressIndicator(
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
            );
          }

          final sessions = sessionController.sessions;

          return sessions.isEmpty
              ? _buildEmptySessions(context, timeSlot)
              : ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: sessions.length,
                separatorBuilder:
                    (context, index) => SizedBox(height: spacing.md),
                itemBuilder: (context, index) {
                  final session = sessions[index];
                  return _buildSessionItem(context, session);
                },
              );
        }),
      ],
    );
  }

  Widget _buildSectionHeader(
    BuildContext context,
    String title,
    dynamic timeSlot,
  ) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w900,
            color: colorScheme.onSurface,
          ),
        ),
        AppButton(
          text: 'Tambah Sesi',
          type: AppButtonType.text,
          size: AppButtonSize.small,
          icon: Icons.add_circle_outline,
          onPressed: () => _showAddSessionDialog(context, timeSlot),
        ),
      ],
    );
  }

  Widget _buildEmptySessions(BuildContext context, dynamic timeSlot) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;
    final spacing = theme.extension<AppSpacing>() ?? const AppSpacing();

    return Card(
      elevation: 0,
      color: colorScheme.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadii.xl),
        side: BorderSide(
          color: colorScheme.outlineVariant.withValues(alpha: 0.70),
        ),
      ),
      child: Padding(
        padding: EdgeInsets.all(spacing.xl),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                height: 84,
                width: 84,
                decoration: BoxDecoration(
                  color: colorScheme.surfaceContainerHighest.withValues(
                    alpha: 0.55,
                  ),
                  borderRadius: BorderRadius.circular(AppRadii.xl),
                  border: Border.all(
                    color: colorScheme.outlineVariant.withValues(alpha: 0.70),
                  ),
                ),
                child: Icon(
                  Icons.event_note_outlined,
                  size: 44,
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
              SizedBox(height: spacing.md),
              Text(
                'Belum Ada Sesi',
                style: textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w900,
                  color: colorScheme.onSurface,
                ),
              ),
              SizedBox(height: spacing.sm),
              Text(
                'Tambahkan sesi pada slot waktu ini untuk mengatur ketersediaan dan pemesanan.',
                style: textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: spacing.lg),
              AppButton(
                icon: Icons.add,
                text: 'Tambah Sesi Pertama',
                onPressed: () => _showAddSessionDialog(context, timeSlot),
                type: AppButtonType.primary,
                size: AppButtonSize.medium,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSessionItem(BuildContext context, dynamic session) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;
    final spacing = theme.extension<AppSpacing>() ?? const AppSpacing();
    final semantic = theme.extension<AppSemanticColors>();
    final successColor = semantic?.success ?? colorScheme.tertiary;

    final bool isBooked = session.isBooked ?? false;
    final Color statusColor = isBooked ? colorScheme.error : successColor;

    String customerName = "Slot Tersedia";
    if (isBooked &&
        session.reservation?.babyName != null &&
        session.reservation!.babyName.isNotEmpty) {
      customerName = session.reservation!.babyName;
    }

    String staffName = "Terapis: Belum ditentukan";
    if (session.staff != null && session.staff?.name != null) {
      staffName = "Terapis: ${session.staff!.name}";
    }

    return Dismissible(
      key: Key(session.id.toString()),
      direction: DismissDirection.endToStart,
      confirmDismiss: (direction) async {
        return await _showDeleteSessionConfirmation(context, session);
      },
      background: Container(
        alignment: Alignment.centerRight,
        padding: EdgeInsets.only(right: spacing.lg),
        decoration: BoxDecoration(
          color: colorScheme.errorContainer.withValues(alpha: 0.85),
          borderRadius: BorderRadius.circular(AppRadii.lg),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.delete_outline, color: colorScheme.onErrorContainer),
            SizedBox(height: spacing.xxs),
            Text(
              'Hapus',
              style: textTheme.bodySmall?.copyWith(
                color: colorScheme.onErrorContainer,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
      ),
      child: Card(
        elevation: 0,
        margin: EdgeInsets.zero,
        color: colorScheme.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadii.lg),
          side: BorderSide(
            color: colorScheme.outlineVariant.withValues(alpha: 0.70),
          ),
        ),
        clipBehavior: Clip.antiAlias,
        child: ListTile(
          contentPadding: EdgeInsets.symmetric(
            horizontal: spacing.lg,
            vertical: spacing.sm,
          ),
          onTap: () {
            Get.toNamed(
              AppRoutes.sessionDetail,
              arguments: {'session': session},
            );
          },
          leading: Container(
            height: 44,
            width: 44,
            decoration: BoxDecoration(
              color: statusColor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(AppRadii.md),
              border: Border.all(color: statusColor.withValues(alpha: 0.18)),
            ),
            child: Icon(
              isBooked ? Icons.person_rounded : Icons.person_add_alt_1_rounded,
              color: statusColor,
            ),
          ),
          title: Text(
            customerName,
            style: textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w900,
              color: colorScheme.onSurface,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          subtitle: Padding(
            padding: EdgeInsets.only(top: spacing.xxs),
            child: Text(
              staffName,
              style: textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          trailing: Switch(
            value: isBooked,
            activeColor: colorScheme.primary,
            onChanged:
                isBooked
                    ? null
                    : (value) {
                      _showToggleBookingConfirmation(context, session, value);
                    },
          ),
        ),
      ),
    );
  }

  Future<void> _showToggleBookingConfirmation(
    BuildContext context,
    dynamic session,
    bool newBookingStatus,
  ) async {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          icon: Icon(Icons.info_outline_rounded, color: colorScheme.primary),
          title: Text(
            'Tandai sebagai Terpesan?',
            style: textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900),
          ),
          content: Text(
            'Sesi ini akan ditandai sebagai terpesan secara manual. Gunakan opsi ini jika pemesanan dilakukan di luar aplikasi. Lanjutkan?',
            style: textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.w600,
            ),
          ),
          actions: [
            AppButton(
              text: 'Batal',
              type: AppButtonType.text,
              onPressed: () => Navigator.of(context).pop(),
            ),
            AppButton(
              text: 'Tandai Terpesan',
              onPressed: () {
                Navigator.of(context).pop();
                sessionController.updateSessionBookingStatus(
                  session.id,
                  newBookingStatus,
                );
              },
            ),
          ],
        );
      },
    );
  }

  Future<bool> _showDeleteSessionConfirmation(
    BuildContext context,
    dynamic session,
  ) async {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    final result = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          icon: Icon(Icons.warning_amber_rounded, color: colorScheme.error),
          title: Text(
            'Hapus Sesi?',
            style: textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900),
          ),
          content: Text(
            'Tindakan ini bersifat permanen dan tidak bisa dibatalkan. Yakin ingin menghapus sesi ini?',
            style: textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.w600,
            ),
          ),
          actions: [
            AppButton(
              text: 'Batal',
              type: AppButtonType.text,
              onPressed: () => Navigator.of(context).pop(false),
            ),
            AppButton(
              text: 'Hapus',
              onPressed: () => Navigator.of(context).pop(true),
            ),
          ],
        );
      },
    );

    if (result == true) {
      final success = await sessionController.deleteSession(session.id);
      return success;
    }
    return false;
  }

  void _showAddSessionDialog(BuildContext context, dynamic timeSlot) {
    Get.toNamed(
      AppRoutes.sessionForm,
      arguments: {
        'timeSlotId': timeSlot.id.toString(),
        'existingSessions': sessionController.sessions,
      },
    );
  }

  void _showDeleteConfirmation(BuildContext context, dynamic timeSlot) async {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          icon: Icon(Icons.delete_forever_rounded, color: colorScheme.error),
          title: Text(
            'Hapus Slot Waktu?',
            style: textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900),
          ),
          content: Text(
            'Ini akan menghapus seluruh slot waktu beserta semua sesi di dalamnya. Tindakan ini tidak bisa dibatalkan.',
            style: textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.w600,
            ),
          ),
          actions: [
            AppButton(
              text: 'Batal',
              type: AppButtonType.text,
              onPressed: () => Navigator.of(context).pop(),
            ),
            AppButton(
              text: 'Hapus Permanen',
              onPressed: () async {
                Navigator.of(context).pop();

                final timeSlotId = timeSlot.id;
                final success = await controller.deleteTimeSlot(timeSlotId);
                if (!mounted) return;

                if (success) {
                  controller.clearSelectedTimeSlot();

                  final scheduleController = Get.find<ScheduleController>();
                  await scheduleController.refreshScheduleData(
                    scheduleController.selectedDate.value,
                  );

                  Get.back();

                  final semantic =
                      Theme.of(Get.context!).extension<AppSemanticColors>();
                  final successColor =
                      semantic?.success ?? colorScheme.tertiary;

                  Get.snackbar(
                    'Berhasil',
                    'Slot waktu berhasil dihapus.',
                    backgroundColor: successColor.withValues(alpha: 0.14),
                    colorText: colorScheme.onSurface,
                    icon: Icon(Icons.check_circle, color: successColor),
                  );
                } else {
                  Get.snackbar(
                    'Gagal',
                    controller.errorMessage.value.isNotEmpty
                        ? controller.errorMessage.value
                        : 'Slot waktu gagal dihapus.',
                    backgroundColor: colorScheme.error.withValues(alpha: 0.14),
                    colorText: colorScheme.onSurface,
                    icon: Icon(Icons.error_outline, color: colorScheme.error),
                  );
                }
              },
            ),
          ],
        );
      },
    );
  }
}
