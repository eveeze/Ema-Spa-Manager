// lib/features/schedule/views/schedule_view.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';

import 'package:emababyspa/common/layouts/main_layout.dart';
import 'package:emababyspa/common/theme/color_theme.dart';
import 'package:emababyspa/common/theme/text_theme.dart';
import 'package:emababyspa/common/widgets/app_button.dart';
import 'package:emababyspa/common/widgets/loading_widget.dart';

import 'package:emababyspa/features/schedule/controllers/schedule_controller.dart';
import 'package:emababyspa/features/theme/controllers/theme_controller.dart';
import 'package:emababyspa/features/operating_schedule/controllers/operating_schedule_controller.dart';
import 'package:emababyspa/features/session/controllers/session_controller.dart';
import 'package:emababyspa/features/time_slot/controllers/time_slot_controller.dart';

import 'package:emababyspa/features/operating_schedule/widgets/operating_schedule_dialog.dart';
import 'package:emababyspa/features/time_slot/widgets/time_slot_dialog.dart';
import 'package:emababyspa/utils/app_routes.dart';
import 'package:emababyspa/utils/timezone_utils.dart';

class ScheduleView extends StatefulWidget {
  const ScheduleView({super.key});

  @override
  State<ScheduleView> createState() => _ScheduleViewState();
}

class _ScheduleViewState extends State<ScheduleView> {
  final ScheduleController controller = Get.find<ScheduleController>();
  final ThemeController themeController = Get.find<ThemeController>();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted) return;
      await controller.bootstrap();
    });
  }

  @override
  Widget build(BuildContext context) {
    return MainLayout(
      child: Obx(() {
        final isDark = themeController.isDarkMode;
        final bg = isDark ? ColorTheme.backgroundDark : ColorTheme.background;

        final isBusy =
            controller.isLoading.value || controller.isGenerating.value;
        final isDetailsLoading = !controller.isDataLoaded.value;

        return Scaffold(
          backgroundColor: bg,
          floatingActionButton: _buildFab(context),
          body:
              isBusy
                  ? const Center(
                    child: LoadingWidget(
                      color: ColorTheme.primary,
                      fullScreen: true,
                      message: "Loading schedule…",
                      size: LoadingSize.medium,
                    ),
                  )
                  : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildCalendarCard(context),
                      const SizedBox(height: M3Spacing.md),
                      Expanded(
                        child:
                            isDetailsLoading
                                ? const Center(
                                  child: LoadingWidget(
                                    color: ColorTheme.primary,
                                    size: LoadingSize.small,
                                    message: "Preparing day details…",
                                  ),
                                )
                                : _buildDailySchedule(
                                  context,
                                  controller.selectedDate.value,
                                ),
                      ),
                    ],
                  ),
        );
      }),
    );
  }

  Widget _buildFab(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return FloatingActionButton(
      heroTag: 'add_schedule_fab',
      onPressed: () => Get.toNamed(AppRoutes.operatingScheduleForm),
      tooltip: 'Create Operating Day',
      backgroundColor: colorScheme.primary,
      child: Icon(Icons.add_rounded, color: colorScheme.onPrimary),
    );
  }

  Widget _buildCalendarCard(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final operatingScheduleController = Get.find<OperatingScheduleController>();

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: M3Spacing.md),
      elevation: 0,
      shape: RoundedRectangleBorder(
        side: BorderSide(color: colorScheme.primary.withValues(alpha: 0.10)),
        borderRadius: BorderRadius.circular(M3Spacing.md),
      ),
      clipBehavior: Clip.antiAlias,
      child: Obx(() {
        return TableCalendar(
          firstDay: DateTime.now().subtract(const Duration(days: 365)),
          lastDay: DateTime.now().add(const Duration(days: 365)),
          focusedDay: controller.focusedDate.value,
          calendarFormat: controller.calendarFormat.value,
          selectedDayPredicate:
              (day) => isSameDay(controller.selectedDate.value, day),

          onDaySelected: controller.onDateSelected,
          onFormatChanged: controller.onFormatChanged,
          onPageChanged: controller.onPageChanged,

          availableCalendarFormats: const {
            CalendarFormat.month: 'Month',
            CalendarFormat.week: 'Week',
          },

          calendarStyle: CalendarStyle(
            todayDecoration: BoxDecoration(
              color: colorScheme.primary.withValues(alpha: 0.10),
              shape: BoxShape.circle,
              border: Border.all(color: colorScheme.primary, width: 1.5),
            ),
            todayTextStyle: textTheme.bodyMedium!.copyWith(
              color: colorScheme.primary,
              fontWeight: FontWeight.bold,
            ),
            selectedDecoration: BoxDecoration(
              color: colorScheme.primary,
              shape: BoxShape.circle,
            ),
            selectedTextStyle: textTheme.bodyMedium!.copyWith(
              color: colorScheme.onPrimary,
              fontWeight: FontWeight.bold,
            ),
            weekendTextStyle: textTheme.bodyMedium!.copyWith(
              color: colorScheme.error,
            ),
            outsideTextStyle: textTheme.bodyMedium!.copyWith(
              color: colorScheme.onSurfaceVariant.withValues(alpha: 0.55),
            ),
            defaultTextStyle: textTheme.bodyMedium!.copyWith(
              color: colorScheme.onSurface,
            ),
          ),

          calendarBuilders: CalendarBuilders(
            defaultBuilder: (context, day, _) {
              final formatted = DateFormat('yyyy-MM-dd').format(day);
              final isHoliday = operatingScheduleController.schedulesList.any((
                s,
              ) {
                return controller.isSameDate(
                      s.date.toIso8601String(),
                      formatted,
                    ) &&
                    s.isHoliday == true;
              });

              if (!isHoliday) return null;

              return Center(
                child: Container(
                  margin: const EdgeInsets.all(M3Spacing.xs),
                  decoration: BoxDecoration(
                    color: colorScheme.errorContainer.withValues(alpha: 0.55),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      '${day.day}',
                      style: textTheme.bodySmall?.copyWith(
                        color: colorScheme.onErrorContainer,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              );
            },

            markerBuilder: (context, date, _) {
              final formatted = DateFormat('yyyy-MM-dd').format(date);
              final hasSchedule = operatingScheduleController.schedulesList.any(
                (s) =>
                    controller.isSameDate(s.date.toIso8601String(), formatted),
              );

              if (!hasSchedule) return null;

              return Positioned(
                bottom: M3Spacing.xs,
                child: Container(
                  height: M3Spacing.xs,
                  width: M3Spacing.xs,
                  decoration: BoxDecoration(
                    color: colorScheme.secondary,
                    shape: BoxShape.circle,
                  ),
                ),
              );
            },
          ),

          headerStyle: HeaderStyle(
            titleCentered: true,
            formatButtonVisible: true,
            formatButtonDecoration: BoxDecoration(
              border: Border.all(color: colorScheme.outline),
              borderRadius: BorderRadius.circular(999),
            ),
            formatButtonTextStyle: textTheme.labelMedium!.copyWith(
              color: colorScheme.onSurface,
              fontWeight: FontWeight.w700,
            ),
            titleTextStyle: textTheme.titleMedium!.copyWith(
              color: colorScheme.onSurface,
              fontWeight: FontWeight.w800,
            ),
            leftChevronIcon: Icon(
              Icons.chevron_left_rounded,
              color: colorScheme.primary,
              size: M3Spacing.xl,
            ),
            rightChevronIcon: Icon(
              Icons.chevron_right_rounded,
              color: colorScheme.primary,
              size: M3Spacing.xl,
            ),
          ),

          daysOfWeekStyle: DaysOfWeekStyle(
            weekdayStyle: textTheme.bodySmall!.copyWith(
              color: colorScheme.onSurface,
              fontWeight: FontWeight.w800,
            ),
            weekendStyle: textTheme.bodySmall!.copyWith(
              color: colorScheme.error,
              fontWeight: FontWeight.w800,
            ),
          ),
        );
      }),
    );
  }

  Widget _buildDailySchedule(BuildContext context, DateTime selectedDate) {
    final operatingScheduleController = Get.find<OperatingScheduleController>();
    final timeSlotController = Get.find<TimeSlotController>();
    final sessionController = Get.find<SessionController>();

    final formattedDate = DateFormat('yyyy-MM-dd').format(selectedDate);
    final schedule = operatingScheduleController.schedulesList.firstWhereOrNull(
      (s) => controller.isSameDate(s.date.toIso8601String(), formattedDate),
    );

    if (schedule == null) {
      return _buildStatusView(
        context: context,
        icon: Icons.calendar_month_outlined,
        iconColor: Theme.of(context).colorScheme.secondary,
        title: 'No operating day yet',
        subtitle: 'Create an operating schedule for\n$formattedDate.',
        actions: AppButton(
          text: 'Create Operating Day',
          icon: Icons.add_circle_outline_rounded,
          onPressed: () {
            showDialog(
              context: Get.context!,
              barrierDismissible: false,
              builder:
                  (_) => OperatingScheduleDialog(selectedDate: selectedDate),
            );
          },
        ),
      );
    }

    if (schedule.isHoliday == true) {
      return _buildStatusView(
        context: context,
        icon: Icons.celebration_outlined,
        iconColor: Theme.of(context).colorScheme.error,
        title: 'Holiday mode',
        subtitle:
            (schedule.notes != null && schedule.notes!.isNotEmpty)
                ? schedule.notes!
                : 'This day is marked as a day off.',
        actions: SizedBox(
          width: double.infinity,
          child: AppButton(
            text: 'Set as Active Day',
            icon: Icons.edit_calendar_outlined,
            type: AppButtonType.secondary,
            onPressed: () => controller.toggleHolidayStatus(schedule.id, false),
          ),
        ),
      );
    }

    final slots =
        timeSlotController.timeSlots
            .where((slot) => slot.operatingScheduleId == schedule.id)
            .toList()
          ..sort((a, b) => a.startTime.compareTo(b.startTime));

    if (slots.isEmpty) {
      return _buildStatusView(
        context: context,
        icon: Icons.hourglass_empty_rounded,
        iconColor: Theme.of(context).colorScheme.primary,
        title: 'No time slots',
        subtitle: 'Add slots manually or generate a set in one tap.',
        actions: Column(
          children: [
            SizedBox(
              width: double.infinity,
              child: AppButton(
                text: 'Generate Slots',
                icon: Icons.auto_awesome_outlined,
                onPressed: () async {
                  await timeSlotController.generateFixedIntervalTimeSlots(
                    operatingScheduleId: schedule.id,
                    startDate: schedule.date,
                    firstSlotStart: const TimeOfDay(hour: 7, minute: 0),
                    lastSlotEnd: const TimeOfDay(hour: 15, minute: 0),
                    slotDuration: const Duration(minutes: 60),
                  );
                  await timeSlotController.fetchTimeSlotsByScheduleId(
                    schedule.id,
                  );
                },
              ),
            ),
            const SizedBox(height: M3Spacing.sm),
            SizedBox(
              width: double.infinity,
              child: DottedBorderButton(
                onTap:
                    () => showDialog(
                      context: Get.context!,
                      builder:
                          (_) =>
                              TimeSlotDialog(operatingScheduleId: schedule.id),
                    ),
                text: 'Add Manually',
                icon: Icons.add_rounded,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildDailyHeader(context, selectedDate, schedule),
        Expanded(
          child: ListView.separated(
            padding: const EdgeInsets.fromLTRB(
              M3Spacing.md,
              M3Spacing.sm,
              M3Spacing.md,
              M3Spacing.xxl,
            ),
            physics: const BouncingScrollPhysics(),
            itemCount: slots.length + 1,
            separatorBuilder: (_, __) => const SizedBox(height: M3Spacing.sm),
            itemBuilder: (context, index) {
              if (index == slots.length) {
                return _buildAddTimeSlotButton(context, schedule.id);
              }

              final timeSlot = slots[index];
              final displayStart = TimeZoneUtil.formatISOToIndonesiaTime(
                timeSlot.startTime.toIso8601String(),
              );

              return Obx(() {
                final sessionsForSlot =
                    sessionController.sessions
                        .where((s) => s.timeSlotId == timeSlot.id)
                        .toList();

                return _buildTimeSlotItem(
                  context,
                  timeSlot,
                  displayStart,
                  sessionsForSlot,
                );
              });
            },
          ),
        ),
      ],
    );
  }

  Widget _buildAddTimeSlotButton(BuildContext context, dynamic scheduleId) {
    final colorScheme = Theme.of(context).colorScheme;

    return DottedBorderButton(
      onTap:
          () => showDialog(
            context: Get.context!,
            builder: (_) => TimeSlotDialog(operatingScheduleId: scheduleId),
          ),
      text: 'Add New Time Slot',
      icon: Icons.add_rounded,
      color: colorScheme.primary,
    );
  }

  Widget _buildDailyHeader(
    BuildContext context,
    DateTime date,
    dynamic schedule,
  ) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        M3Spacing.md,
        M3Spacing.xs,
        M3Spacing.md,
        M3Spacing.sm,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                TimeZoneUtil.formatDate(date),
                style: textTheme.titleLarge?.copyWith(
                  color: colorScheme.onSurface,
                  fontWeight: FontWeight.w900,
                ),
              ),
              Text(
                DateFormat('EEEE').format(date),
                style: textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
          PopupMenuButton(
            icon: Icon(
              Icons.more_vert_rounded,
              color: colorScheme.onSurfaceVariant,
            ),
            tooltip: "More options",
            itemBuilder:
                (_) => [
                  PopupMenuItem(
                    onTap:
                        () => _showDeleteConfirmationDialog(context, schedule),
                    child: ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: Icon(
                        Icons.delete_outline_rounded,
                        color: colorScheme.error,
                      ),
                      title: Text(
                        'Delete Operating Day',
                        style: textTheme.bodyMedium?.copyWith(
                          color: colorScheme.error,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                ],
          ),
        ],
      ),
    );
  }

  Widget _buildTimeSlotItem(
    BuildContext context,
    dynamic timeSlot,
    String displayStartTime,
    List<dynamic> sessions,
  ) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    final total = sessions.length;
    final booked = sessions.where((s) => s.isBooked == true).length;
    final isFull = total > 0 && booked == total;
    final progress = total > 0 ? booked / total : 0.0;

    final statusColor = isFull ? colorScheme.error : ColorTheme.success;

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(M3Spacing.md),
        side: BorderSide(color: colorScheme.primary.withValues(alpha: 0.10)),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () async {
          final dateBefore = controller.selectedDate.value;
          await Get.toNamed(
            AppRoutes.timeSlotDetail,
            arguments: {'timeSlot': timeSlot},
          );
          if (!mounted) return;
          await controller.refreshScheduleData(dateBefore);
        },
        child: Padding(
          padding: const EdgeInsets.all(M3Spacing.md),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      displayStartTime,
                      style: textTheme.headlineSmall?.copyWith(
                        color: colorScheme.onSurface,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: M3Spacing.sm),
                    Row(
                      children: [
                        Container(
                          width: M3Spacing.sm,
                          height: M3Spacing.sm,
                          decoration: BoxDecoration(
                            color: statusColor,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: M3Spacing.sm),
                        Text(
                          isFull ? "Fully booked" : "Available",
                          style: textTheme.bodyMedium?.copyWith(
                            color: statusColor,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const Spacer(),
                        Text(
                          total > 0 ? '$booked/$total booked' : 'No sessions',
                          style: textTheme.bodySmall?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    if (total > 0) ...[
                      const SizedBox(height: M3Spacing.sm),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(M3Spacing.sm),
                        child: LinearProgressIndicator(
                          value: progress,
                          backgroundColor: colorScheme.surfaceContainerHighest,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            statusColor,
                          ),
                          minHeight: 6,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: M3Spacing.md),
              Icon(
                Icons.chevron_right_rounded,
                color: colorScheme.onSurfaceVariant.withValues(alpha: 0.60),
                size: M3Spacing.xl,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusView({
    required BuildContext context,
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    Widget? actions,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.all(M3Spacing.xl),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 64, color: iconColor),
          const SizedBox(height: M3Spacing.lg),
          Text(
            title,
            textAlign: TextAlign.center,
            style: textTheme.headlineSmall?.copyWith(
              color: colorScheme.onSurface,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: M3Spacing.sm),
          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: textTheme.bodyLarge?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
          if (actions != null) ...[
            const SizedBox(height: M3Spacing.xl),
            actions,
          ],
        ],
      ),
    );
  }

  void _showDeleteConfirmationDialog(BuildContext context, dynamic schedule) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(M3Spacing.xl),
        ),
        child: Padding(
          padding: const EdgeInsets.all(M3Spacing.lg),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.warning_amber_rounded,
                size: 56,
                color: colorScheme.error,
              ),
              const SizedBox(height: M3Spacing.md),
              Text(
                'Delete this operating day?',
                style: textTheme.headlineSmall,
              ),
              const SizedBox(height: M3Spacing.sm),
              Text(
                'This will remove the day and its related time slots.',
                textAlign: TextAlign.center,
                style: textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: M3Spacing.lg),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(onPressed: Get.back, child: const Text('Cancel')),
                  const SizedBox(width: M3Spacing.sm),
                  TextButton(
                    onPressed: () => _deleteSchedule(schedule),
                    style: TextButton.styleFrom(
                      foregroundColor: colorScheme.error,
                    ),
                    child: const Text('Delete'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _deleteSchedule(dynamic schedule) async {
    final operatingScheduleController = Get.find<OperatingScheduleController>();
    Get.back();

    try {
      final success = await operatingScheduleController.deleteOperatingSchedule(
        schedule.id,
      );
      if (!success) throw Exception('Failed to delete');

      await controller.refreshScheduleData(controller.selectedDate.value);

      Get.snackbar(
        'Deleted',
        'Operating day removed successfully.',
        backgroundColor: ColorTheme.success.withValues(alpha: 0.10),
        colorText: ColorTheme.success,
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Could not delete: ${e.toString()}',
        backgroundColor: ColorTheme.error.withValues(alpha: 0.10),
        colorText: ColorTheme.error,
      );
    }
  }
}

class DottedBorderButton extends StatelessWidget {
  final VoidCallback onTap;
  final String text;
  final IconData icon;
  final Color color;

  const DottedBorderButton({
    super.key,
    required this.onTap,
    required this.text,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(M3Spacing.md),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: M3Spacing.lg),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.06),
          borderRadius: BorderRadius.circular(M3Spacing.md),
          border: Border.all(color: color.withValues(alpha: 0.28), width: 1.5),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color),
            const SizedBox(width: M3Spacing.sm),
            Text(
              text,
              style: textTheme.labelLarge?.copyWith(
                color: color,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
