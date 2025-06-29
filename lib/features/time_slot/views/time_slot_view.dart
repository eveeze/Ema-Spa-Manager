import 'package:emababyspa/features/schedule/controllers/schedule_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:emababyspa/common/theme/color_theme.dart';
import 'package:emababyspa/common/layouts/main_layout.dart';
import 'package:emababyspa/common/widgets/app_button.dart';
import 'package:emababyspa/features/time_slot/controllers/time_slot_controller.dart';
import 'package:emababyspa/features/session/controllers/session_controller.dart';
import 'package:emababyspa/utils/app_routes.dart';
import 'package:emababyspa/utils/timezone_utils.dart';
import 'package:emababyspa/common/theme/text_theme.dart';
import 'package:emababyspa/common/widgets/custom_appbar.dart';

class TimeSlotView extends StatefulWidget {
  const TimeSlotView({super.key});

  @override
  State<TimeSlotView> createState() => _TimeSlotViewState();
}

class _TimeSlotViewState extends State<TimeSlotView> {
  final controller = Get.find<TimeSlotController>();
  final sessionController = Get.find<SessionController>();

  @override
  void initState() {
    super.initState();
    final args = Get.arguments as Map<String, dynamic>;
    final timeSlot = args['timeSlot'];
    if (controller.selectedTimeSlot.value == null) {
      controller.selectedTimeSlot.value = timeSlot;
    }

    // --- PERBAIKAN #1: Mencegah error "setState called during build" ---
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        sessionController.fetchSessions(timeSlotId: timeSlot.id);
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

      return Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        appBar: CustomAppBar(
          title: 'Time Slot Details',
          backgroundColor: Theme.of(context).colorScheme.surface,
          actions: [
            PopupMenuButton<String>(
              icon: Icon(
                Icons.more_vert,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
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
                        leading: Icon(
                          Icons.edit_outlined,
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                        title: Text(
                          'Edit',
                          style: Theme.of(context).textTheme.bodyLarge,
                        ),
                      ),
                    ),
                    const PopupMenuDivider(),
                    PopupMenuItem<String>(
                      value: 'delete',
                      child: ListTile(
                        leading: Icon(
                          Icons.delete_outline,
                          color: Theme.of(context).colorScheme.error,
                        ),
                        title: Text(
                          'Delete',
                          style: Theme.of(
                            context,
                          ).textTheme.bodyLarge?.copyWith(
                            color: Theme.of(context).colorScheme.error,
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
              padding: const EdgeInsets.symmetric(horizontal: M3Spacing.lg),
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
            const SizedBox(height: M3Spacing.md),
            Obx(
              () => _buildTimeSlotHeader(
                context,
                timeSlot,
                sessionController.sessions,
              ),
            ),
            const SizedBox(height: M3Spacing.xl),
            _buildSessionsSection(context, timeSlot),
            const SizedBox(height: M3Spacing.xxl),
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

    return Card(
      elevation: 0,
      color: Theme.of(context).colorScheme.surfaceContainerLowest,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Theme.of(context).colorScheme.outlineVariant),
      ),
      child: Padding(
        padding: const EdgeInsets.all(M3Spacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.calendar_today,
                  size: 16,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
                const SizedBox(width: M3Spacing.sm),
                Text(
                  dateFormatted,
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
            const SizedBox(height: M3Spacing.md),
            Divider(color: Theme.of(context).colorScheme.outlineVariant),
            const SizedBox(height: M3Spacing.md),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Time Slot',
                        style: Theme.of(context).textTheme.labelLarge?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: M3Spacing.xs),
                      Text(
                        '$startTime - $endTime',
                        style: Theme.of(
                          context,
                        ).textTheme.headlineSmall?.copyWith(
                          color: Theme.of(context).colorScheme.onSurface,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                _buildStatusBadge(context, allBooked),
              ],
            ),
            const SizedBox(height: M3Spacing.md),
            Divider(color: Theme.of(context).colorScheme.outlineVariant),
            const SizedBox(height: M3Spacing.md),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatItem(
                  context: context,
                  title: 'Total',
                  value: '$totalSessions',
                  color: Theme.of(context).colorScheme.primary,
                ),
                _buildStatItem(
                  context: context,
                  title: 'Booked',
                  value: '$bookedSessions',
                  color: Theme.of(context).colorScheme.error,
                ),
                _buildStatItem(
                  context: context,
                  title: 'Available',
                  value: '$availableSessions',
                  color: ColorTheme.success,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem({
    required BuildContext context,
    required String title,
    required String value,
    required Color color,
  }) {
    return Column(
      children: [
        Text(
          value,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        const SizedBox(height: M3Spacing.xs),
        Text(
          title,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }

  Widget _buildStatusBadge(BuildContext context, bool allBooked) {
    final textColor =
        allBooked
            ? Theme.of(context).colorScheme.onErrorContainer
            : ColorTheme.activeTagText;
    final bgColor =
        allBooked
            ? Theme.of(context).colorScheme.errorContainer
            : ColorTheme.activeTagBackground;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: M3Spacing.md,
        vertical: M3Spacing.xs,
      ),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(100),
      ),
      child: Text(
        allBooked ? 'Fully Booked' : 'Available',
        style: Theme.of(context).textTheme.labelMedium?.copyWith(
          color: textColor,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildSessionsSection(BuildContext context, dynamic timeSlot) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader(context, 'Sessions', timeSlot),
        const SizedBox(height: M3Spacing.md),
        Obx(() {
          if (sessionController.isLoading.value) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(M3Spacing.xl),
                child: CircularProgressIndicator(),
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
                    (context, index) => const SizedBox(height: M3Spacing.md),
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
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: Theme.of(
            context,
          ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
        ),
        AppButton(
          text: 'Add Session',
          type: AppButtonType.text,
          size: AppButtonSize.small,
          icon: Icons.add_circle_outline,
          onPressed: () => _showAddSessionDialog(context, timeSlot),
        ),
      ],
    );
  }

  Widget _buildEmptySessions(BuildContext context, dynamic timeSlot) {
    return Card(
      elevation: 0,
      color: Theme.of(context).colorScheme.surfaceContainer,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(M3Spacing.xl),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.event_note_outlined,
                size: 48,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
              const SizedBox(height: M3Spacing.md),
              Text(
                'No Sessions Yet',
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: M3Spacing.sm),
              Text(
                'Add sessions to this time slot to manage bookings.',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: M3Spacing.lg),
              AppButton(
                icon: Icons.add,
                text: 'Add First Session',
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
    final bool isBooked = session.isBooked ?? false;
    final Color statusColor =
        isBooked ? Theme.of(context).colorScheme.error : ColorTheme.success;

    String customerName = "Available Slot";
    if (isBooked &&
        session.reservation?.babyName != null &&
        session.reservation!.babyName.isNotEmpty) {
      customerName = session.reservation!.babyName;
    }

    String staffName = "Staff: Not Assigned";
    if (session.staff != null && session.staff?.name != null) {
      staffName = "Staff: ${session.staff!.name}";
    }

    return Dismissible(
      key: Key(session.id.toString()),
      direction: DismissDirection.endToStart,
      confirmDismiss: (direction) async {
        return await _showDeleteSessionConfirmation(context, session);
      },
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: M3Spacing.lg),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.errorContainer,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.delete_outline,
              color: Theme.of(context).colorScheme.onErrorContainer,
            ),
            const SizedBox(height: M3Spacing.xs),
            Text(
              'Delete',
              style: TextStyle(
                color: Theme.of(context).colorScheme.onErrorContainer,
              ),
            ),
          ],
        ),
      ),
      child: Card(
        elevation: 0,
        margin: EdgeInsets.zero,
        color: Theme.of(context).colorScheme.surfaceContainerHigh,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: ListTile(
          contentPadding: const EdgeInsets.symmetric(
            horizontal: M3Spacing.lg,
            vertical: M3Spacing.sm,
          ),
          onTap: () {
            Get.toNamed(
              AppRoutes.sessionDetail,
              arguments: {'session': session},
            );
          },
          leading: CircleAvatar(
            backgroundColor: statusColor.withOpacity(0.15),
            child: Icon(
              isBooked ? Icons.person_rounded : Icons.person_add_alt_1_rounded,
              color: statusColor,
            ),
          ),
          title: Text(
            customerName,
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          subtitle: Text(
            staffName,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
          trailing: Switch(
            value: isBooked,
            activeColor: Theme.of(context).colorScheme.primary,
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
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Mark as Booked?'),
          content: const Text(
            'This will manually mark the session as booked. This action should be used if a booking was made outside the app. Continue?',
          ),
          actions: [
            AppButton(
              text: 'Cancel',
              type: AppButtonType.text,
              onPressed: () => Navigator.of(context).pop(),
            ),
            AppButton(
              text: 'Mark as Booked',
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

  // --- PERBAIKAN #2: Logika hapus yang benar ---
  Future<bool> _showDeleteSessionConfirmation(
    BuildContext context,
    dynamic session,
  ) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          icon: Icon(
            Icons.warning_amber_rounded,
            color: Theme.of(context).colorScheme.error,
          ),
          title: const Text('Delete Session?'),
          content: const Text(
            'This action is permanent and cannot be undone. Are you sure?',
          ),
          actions: [
            AppButton(
              text: 'Cancel',
              type: AppButtonType.text,
              onPressed: () => Navigator.of(context).pop(false),
            ),
            AppButton(
              text: 'Delete',
              onPressed: () => Navigator.of(context).pop(true),
            ),
          ],
        );
      },
    );

    // Hanya jika pengguna menekan "Delete"
    if (result == true) {
      // Panggil controller untuk menghapus, dan tunggu hasilnya
      final success = await sessionController.deleteSession(session.id);
      // Kembalikan status suksesnya ke widget Dismissible.
      // Jika true, item akan hilang. Jika false, item akan kembali.
      // Tidak perlu panggil fetch ulang di sini.
      return success;
    }

    // Jika pengguna menekan "Cancel"
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
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          icon: Icon(
            Icons.delete_forever_rounded,
            color: Theme.of(context).colorScheme.error,
          ),
          title: const Text('Delete Time Slot?'),
          content: const Text(
            'This will delete the entire time slot and all its associated sessions. This action cannot be undone.',
          ),
          actions: [
            AppButton(
              text: 'Cancel',
              type: AppButtonType.text,
              onPressed: () => Navigator.of(context).pop(),
            ),
            AppButton(
              text: 'Delete Permanently',
              onPressed: () async {
                Navigator.of(context).pop();
                final timeSlotId = timeSlot.id;
                final success = await controller.deleteTimeSlot(timeSlotId);
                if (!mounted) return;

                if (success) {
                  controller.clearSelectedTimeSlot();
                  final scheduleController = Get.find<ScheduleController>();
                  await scheduleController.fetchScheduleData();
                  Get.back();
                  Get.snackbar(
                    'Success',
                    'Time slot deleted successfully',
                    backgroundColor: ColorTheme.success,
                    colorText: Colors.white,
                  );
                } else {
                  Get.snackbar(
                    'Error',
                    controller.errorMessage.value.isNotEmpty
                        ? controller.errorMessage.value
                        : 'Failed to delete time slot',
                    backgroundColor: Theme.of(context).colorScheme.error,
                    colorText: Theme.of(context).colorScheme.onError,
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
