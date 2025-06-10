// lib/features/schedule/views/schedule_view.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:emababyspa/common/theme/color_theme.dart';
import 'package:emababyspa/common/layouts/main_layout.dart';
import 'package:emababyspa/common/widgets/app_button.dart';
import 'package:emababyspa/common/widgets/loading_widget.dart';
import 'package:emababyspa/features/schedule/controllers/schedule_controller.dart';
import 'package:emababyspa/features/operating_schedule/controllers/operating_schedule_controller.dart';
import 'package:emababyspa/features/session/controllers/session_controller.dart';
import 'package:emababyspa/features/time_slot/controllers/time_slot_controller.dart';
import 'package:emababyspa/utils/app_routes.dart';
import 'package:emababyspa/features/operating_schedule/widgets/operating_schedule_dialog.dart';
import 'package:emababyspa/features/time_slot/widgets/time_slot_dialog.dart';
import 'package:emababyspa/utils/timezone_utils.dart';
import 'package:emababyspa/features/theme/controllers/theme_controller.dart';
import 'package:emababyspa/common/theme/text_theme.dart';

class ScheduleView extends GetView<ScheduleController> {
  const ScheduleView({super.key});

  @override
  Widget build(BuildContext context) {
    final themeController = Get.find<ThemeController>();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.refreshScheduleData(controller.selectedDate.value);
    });

    return MainLayout(
      child: Obx(() {
        final isDark = themeController.isDarkMode;
        final backgroundColor =
            isDark ? ColorTheme.backgroundDark : ColorTheme.background;

        return Scaffold(
          backgroundColor: backgroundColor,
          body: Obx(() {
            if (controller.isLoading.value || controller.isGenerating.value) {
              return const Center(
                child: LoadingWidget(
                  color: ColorTheme.primary,
                  fullScreen: true,
                  message: "Loading...",
                  size: LoadingSize.medium,
                ),
              );
            }
            return _buildContent(context);
          }),
          floatingActionButton: _buildFloatingActionButton(context),
        );
      }),
    );
  }

  bool _isSameDate(String? apiDate, String targetDate) {
    if (apiDate == null) return false;
    if (apiDate.contains('T')) {
      final datePart = apiDate.split('T')[0];
      return datePart == targetDate;
    }
    return apiDate == targetDate;
  }

  Widget _buildFloatingActionButton(BuildContext context) {
    return FloatingActionButton(
      onPressed: () => Get.toNamed(AppRoutes.operatingScheduleForm),
      tooltip: 'Add Operating Schedule',
      heroTag: 'add_schedule_fab',
      child: const Icon(Icons.add),
    );
  }

  Widget _buildContent(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildTableCalendar(context),
        const SizedBox(height: M3Spacing.md),
        Expanded(
          child: Obx(() {
            if (!controller.isDataLoaded.value) {
              return const Center(
                child: LoadingWidget(
                  color: ColorTheme.primary,
                  size: LoadingSize.small,
                  message: "Loading schedule data...",
                ),
              );
            }
            return _buildDailySchedule(context, controller.selectedDate.value);
          }),
        ),
      ],
    );
  }

  Widget _buildTableCalendar(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final operatingScheduleController = Get.find<OperatingScheduleController>();

    return Obx(() {
      return Card(
        margin: const EdgeInsets.symmetric(horizontal: M3Spacing.md),
        elevation: 0,
        // REMOVED: Explicit color. The Card now uses the color from your AppTheme's
        // cardTheme, which we updated to use a subtle light-blue color.
        shape: RoundedRectangleBorder(
          // UPDATED: Uses the theme's primary color and standard opacity for the border.
          side: BorderSide(color: colorScheme.primary.withOpacity(0.1)),
          borderRadius: BorderRadius.circular(M3Spacing.md),
        ),
        child: TableCalendar(
          firstDay: DateTime.now().subtract(const Duration(days: 365)),
          lastDay: DateTime.now().add(const Duration(days: 365)),
          focusedDay: controller.focusedDate.value,
          calendarFormat: controller.calendarFormat.value,
          selectedDayPredicate:
              (day) => isSameDay(controller.selectedDate.value, day),
          onDaySelected: (selectedDay, focusedDay) {
            controller.onDateSelected(selectedDay, focusedDay);
          },
          onFormatChanged: (format) {
            controller.calendarFormat.value = format;
          },
          onPageChanged: (focusedDay) {
            controller.focusedDate.value = focusedDay;
            controller.refreshScheduleData(focusedDay);
          },
          availableCalendarFormats: const {
            CalendarFormat.month: 'Month',
            CalendarFormat.week: 'Week',
          },
          calendarStyle: CalendarStyle(
            todayDecoration: BoxDecoration(
              color: colorScheme.primary.withOpacity(0.1),
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
              color: colorScheme.onSurfaceVariant.withOpacity(0.5),
            ),
            defaultTextStyle: textTheme.bodyMedium!.copyWith(
              color: colorScheme.onSurface,
            ),
          ),
          calendarBuilders: CalendarBuilders(
            defaultBuilder: (context, day, focusedDay) {
              final formattedDay = DateFormat('yyyy-MM-dd').format(day);
              final isHoliday = operatingScheduleController.schedulesList.any(
                (schedule) =>
                    _isSameDate(
                      schedule.date.toIso8601String(),
                      formattedDay,
                    ) &&
                    schedule.isHoliday == true,
              );

              if (isHoliday) {
                return Center(
                  child: Container(
                    decoration: BoxDecoration(
                      color: colorScheme.errorContainer.withOpacity(0.5),
                      shape: BoxShape.circle,
                    ),
                    margin: const EdgeInsets.all(6.0),
                    child: Center(
                      child: Text(
                        '${day.day}',
                        style: textTheme.bodySmall?.copyWith(
                          color: colorScheme.onErrorContainer,
                        ),
                      ),
                    ),
                  ),
                );
              }
              return null;
            },
            markerBuilder: (context, date, events) {
              final formattedDate = DateFormat('yyyy-MM-dd').format(date);
              final hasSchedule = operatingScheduleController.schedulesList.any(
                (s) => _isSameDate(s.date.toIso8601String(), formattedDate),
              );

              if (hasSchedule) {
                return Positioned(
                  bottom: 5,
                  child: Container(
                    height: 7,
                    width: 7,
                    decoration: BoxDecoration(
                      color: colorScheme.secondary,
                      shape: BoxShape.circle,
                    ),
                  ),
                );
              }
              return null;
            },
          ),
          headerStyle: HeaderStyle(
            formatButtonVisible: true,
            titleCentered: true,
            formatButtonDecoration: BoxDecoration(
              border: Border.all(color: colorScheme.outline),
              borderRadius: BorderRadius.circular(20.0),
            ),
            formatButtonTextStyle: textTheme.labelMedium!.copyWith(
              color: colorScheme.onSurface,
            ),
            titleTextStyle: textTheme.titleMedium!.copyWith(
              color: colorScheme.onSurface,
              fontWeight: FontWeight.bold,
            ),
            leftChevronIcon: Icon(
              Icons.chevron_left_rounded,
              color: colorScheme.primary,
              size: 28,
            ),
            rightChevronIcon: Icon(
              Icons.chevron_right_rounded,
              color: colorScheme.primary,
              size: 28,
            ),
          ),
          daysOfWeekStyle: DaysOfWeekStyle(
            weekdayStyle: textTheme.bodySmall!.copyWith(
              color: colorScheme.onSurface,
              fontWeight: FontWeight.bold,
            ),
            weekendStyle: textTheme.bodySmall!.copyWith(
              color: colorScheme.error,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      );
    });
  }

  Widget _buildDailySchedule(BuildContext context, DateTime selectedDate) {
    final operatingScheduleController = Get.find<OperatingScheduleController>();
    final timeSlotController = Get.find<TimeSlotController>();
    final sessionController = Get.find<SessionController>();
    final formattedDate = DateFormat('yyyy-MM-dd').format(selectedDate);
    final schedule = operatingScheduleController.schedulesList.firstWhereOrNull(
      (s) => _isSameDate(s.date.toIso8601String(), formattedDate),
    );

    if (schedule == null) {
      return _buildNoScheduleView(context, formattedDate, selectedDate);
    }
    if (schedule.isHoliday == true) {
      return _buildHolidayView(context, schedule);
    }

    final timeSlots =
        timeSlotController.timeSlots
            .where((slot) => slot.operatingScheduleId == schedule.id)
            .toList();
    timeSlots.sort((a, b) => a.startTime.compareTo(b.startTime));

    if (timeSlots.isEmpty) {
      return _buildNoTimeSlotsView(context, schedule);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildDailyHeader(context, selectedDate, schedule),
        Expanded(
          child: ListView.separated(
            itemCount: timeSlots.length + 1,
            padding: const EdgeInsets.fromLTRB(
              M3Spacing.md,
              M3Spacing.sm,
              M3Spacing.md,
              80,
            ), // Padding for FAB
            physics: const BouncingScrollPhysics(),
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              if (index == timeSlots.length) {
                return _buildAddTimeSlotButton(context, schedule.id);
              }
              final timeSlot = timeSlots[index];
              return Obx(() {
                final sessionsForSlot =
                    sessionController.sessions
                        .where((session) => session.timeSlotId == timeSlot.id)
                        .toList();
                String displayStartTime = _formatTimeSlot(
                  timeSlot.startTime.toIso8601String(),
                );
                return _buildTimeSlotItem(
                  context,
                  timeSlot,
                  displayStartTime,
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
      onTap: () {
        showDialog(
          context: Get.context!,
          builder: (context) => TimeSlotDialog(operatingScheduleId: scheduleId),
        );
      },
      text: 'Add New Time Slot',
      icon: Icons.add,
      color: colorScheme.primary,
    );
  }

  Widget _buildDailyHeader(
    BuildContext context,
    DateTime selectedDate,
    dynamic schedule,
  ) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, M3Spacing.sm, M3Spacing.sm),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                TimeZoneUtil.formatDate(selectedDate),
                style: textTheme.titleLarge?.copyWith(
                  color: colorScheme.onSurface,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                DateFormat('EEEE').format(selectedDate),
                style: textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
          PopupMenuButton(
            icon: Icon(Icons.more_vert, color: colorScheme.onSurfaceVariant),
            tooltip: "More options",
            itemBuilder:
                (context) => [
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
                        'Delete Schedule',
                        style: textTheme.bodyMedium?.copyWith(
                          color: colorScheme.error,
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

  String _formatTimeSlot(String isoTimeString) {
    return TimeZoneUtil.formatISOToIndonesiaTime(isoTimeString);
  }

  Widget _buildTimeSlotItem(
    BuildContext context,
    dynamic timeSlot,
    String displayStartTime,
    List<dynamic> sessions,
  ) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final totalSessions = sessions.length;
    final isFull =
        totalSessions > 0 &&
        sessions.every((session) => session.isBooked == true);
    final bookedCount =
        sessions.where((session) => session.isBooked == true).length;
    final progress = totalSessions > 0 ? bookedCount / totalSessions : 0.0;

    final Color statusColor = isFull ? colorScheme.error : ColorTheme.success;

    return Card(
      elevation: 0,
      // REMOVED: Explicit color to respect the central theme definition.
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(M3Spacing.md),
        // UPDATED: Use theme color for consistency.
        side: BorderSide(color: colorScheme.primary.withOpacity(0.1)),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () async {
          final dateBeforeNavigation = controller.selectedDate.value;
          await Get.toNamed(
            AppRoutes.timeSlotDetail,
            arguments: {'timeSlot': timeSlot},
          );
          controller.refreshScheduleData(dateBeforeNavigation);
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
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
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
                          isFull ? "Fully Booked" : "Available",
                          style: textTheme.bodyMedium?.copyWith(
                            color: statusColor,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const Spacer(),
                        Text(
                          totalSessions > 0
                              ? '$bookedCount/$totalSessions Booked'
                              : 'No Sessions',
                          style: textTheme.bodySmall?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                    if (totalSessions > 0) ...[
                      const SizedBox(height: M3Spacing.sm),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(10),
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
                color: colorScheme.onSurfaceVariant.withOpacity(0.6),
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

    return Container(
      padding: const EdgeInsets.all(M3Spacing.xl),
      width: double.infinity,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(icon, size: 64, color: iconColor),
          const SizedBox(height: M3Spacing.lg),
          Text(
            title,
            textAlign: TextAlign.center,
            style: textTheme.headlineSmall?.copyWith(
              color: colorScheme.onSurface,
              fontWeight: FontWeight.bold,
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

  Widget _buildNoScheduleView(
    BuildContext context,
    String formattedDate,
    DateTime selectedDate,
  ) {
    return _buildStatusView(
      context: context,
      icon: Icons.calendar_month_outlined,
      // UPDATED: Use theme color for a more integrated and professional look.
      iconColor: Theme.of(context).colorScheme.secondary,
      title: 'No Schedule Found',
      subtitle: 'There is no operating schedule for\n$formattedDate.',
      actions: AppButton(
        text: 'Create Schedule',
        icon: Icons.add_circle_outline,
        onPressed: () {
          showDialog(
            context: Get.context!,
            barrierDismissible: false,
            builder:
                (context) =>
                    OperatingScheduleDialog(selectedDate: selectedDate),
          );
        },
      ),
    );
  }

  Widget _buildHolidayView(BuildContext context, dynamic schedule) {
    return _buildStatusView(
      context: context,
      icon: Icons.celebration_outlined,
      // UPDATED: Use the standard error color from the theme.
      iconColor: Theme.of(context).colorScheme.error,
      title: 'It\'s a Holiday!',
      subtitle:
          schedule.notes != null && schedule.notes!.isNotEmpty
              ? schedule.notes!
              : 'This day is marked as a day off.',
      actions: SizedBox(
        width: double.infinity,
        child: AppButton(
          text: 'Set to Active Day',
          icon: Icons.edit_calendar_outlined,
          type: AppButtonType.secondary,
          onPressed: () {
            controller.toggleHolidayStatus(schedule.id, false);
          },
        ),
      ),
    );
  }

  Widget _buildNoTimeSlotsView(BuildContext context, dynamic schedule) {
    return _buildStatusView(
      context: context,
      icon: Icons.hourglass_empty_rounded,
      // UPDATED: Use the primary theme color to guide the user's attention.
      iconColor: Theme.of(context).colorScheme.primary,
      title: 'No Time Slots',
      subtitle:
          'This schedule has no time slots yet. Add them manually or generate a set.',
      actions: Column(
        children: [
          SizedBox(
            width: double.infinity,
            child: AppButton(
              text: 'Generate Slots',
              icon: Icons.auto_awesome_outlined,
              onPressed: () async {
                final timeSlotController = Get.find<TimeSlotController>();
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
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: DottedBorderButton(
              onTap: () {
                showDialog(
                  context: Get.context!,
                  builder:
                      (context) =>
                          TimeSlotDialog(operatingScheduleId: schedule.id),
                );
              },
              text: 'Add Manually',
              icon: Icons.add,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
        ],
      ),
    );
  }

  void _showDeleteConfirmationDialog(BuildContext context, dynamic schedule) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
        child: Padding(
          padding: const EdgeInsets.all(M3Spacing.lg),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.warning_amber_rounded,
                size: M3Spacing.lg,
                color: colorScheme.error,
              ),
              const SizedBox(height: M3Spacing.md),
              Text('Delete Schedule?', style: textTheme.headlineSmall),
              const SizedBox(height: M3Spacing.md),
              Text(
                'This will permanently delete the schedule and all its related time slots.',
                textAlign: TextAlign.center,
                style: textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: M3Spacing.lg),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Get.back(),
                    child: const Text('Cancel'),
                  ),
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
      if (success) {
        controller.refreshScheduleData(controller.selectedDate.value);
        Get.snackbar(
          'Success',
          'The schedule has been successfully deleted.',
          backgroundColor: ColorTheme.success.withOpacity(0.1),
          colorText: ColorTheme.success,
        );
      } else {
        throw Exception('Failed to delete.');
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Could not delete the schedule: ${e.toString()}',
        backgroundColor: ColorTheme.error.withOpacity(0.1),
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
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 20),
        decoration: BoxDecoration(
          color: color.withOpacity(0.05),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.3), width: 1.5),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color),
            const SizedBox(width: 10),
            Text(
              text,
              style: Theme.of(
                context,
              ).textTheme.labelLarge?.copyWith(color: color),
            ),
          ],
        ),
      ),
    );
  }
}

extension ScheduleControllerActions on ScheduleController {
  void onDateSelected(DateTime selectedDay, DateTime focusedDay) {
    if (!isSameDay(selectedDate.value, selectedDay)) {
      selectedDate.value = selectedDay;
      focusedDate.value = focusedDay;
      refreshScheduleData(selectedDay);
    }
  }

  Future<void> toggleHolidayStatus(dynamic scheduleId, bool isHoliday) async {
    final operatingScheduleController = Get.find<OperatingScheduleController>();
    await operatingScheduleController.updateOperatingSchedule(
      id: scheduleId,
      isHoliday: isHoliday,
    );
    await refreshScheduleData(selectedDate.value);
  }
}
