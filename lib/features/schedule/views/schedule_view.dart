// lib/features/schedule/views/schedule_view.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';

import 'package:emababyspa/common/layouts/main_layout.dart';
import 'package:emababyspa/common/theme/app_theme.dart';
import 'package:emababyspa/common/theme/color_theme.dart';
import 'package:emababyspa/common/theme/semantic_colors.dart';
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
        final theme = Theme.of(context);
        final cs = theme.colorScheme;

        // ✅ Background FLAT (no blue, no blob), consistent with other pages.
        // UI only: we don't touch any logic / controller flow.
        final bg =
            themeController.isDarkMode ? cs.surfaceContainerLowest : cs.surface;

        final isBusy =
            controller.isLoading.value || controller.isGenerating.value;
        final isDetailsLoading = !controller.isDataLoaded.value;

        return Scaffold(
          backgroundColor: bg,
          body: SafeArea(
            child:
                isBusy
                    ? const Center(
                      child: LoadingWidget(
                        color: ColorTheme.primary,
                        fullScreen: true,
                        message: "Memuat jadwal…",
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
                                      message: "Menyiapkan detail hari…",
                                    ),
                                  )
                                  : _buildDailySchedule(
                                    context,
                                    controller.selectedDate.value,
                                  ),
                        ),
                      ],
                    ),
          ),
        );
      }),
    );
  }

  Widget _buildCalendarCard(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;
    final spacing = theme.extension<AppSpacing>() ?? const AppSpacing();
    final operatingScheduleController = Get.find<OperatingScheduleController>();

    final surface = colorScheme.surface;
    final outlineSoft = colorScheme.outlineVariant.withValues(alpha: 0.70);

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: spacing.md),
      child: Card(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadii.lg),
          side: BorderSide(color: outlineSoft, width: 1),
        ),
        clipBehavior: Clip.antiAlias,
        child: Obx(() {
          return Column(
            children: [
              // Subtle header strip (premium/airy)
              Container(
                width: double.infinity,
                padding: EdgeInsets.fromLTRB(
                  spacing.md,
                  spacing.md,
                  spacing.md,
                  spacing.sm,
                ),
                decoration: BoxDecoration(
                  color: colorScheme.surfaceContainerHighest.withValues(
                    alpha: 0.55,
                  ),
                  border: Border(bottom: BorderSide(color: outlineSoft)),
                ),
                child: Row(
                  children: [
                    Container(
                      height: 44,
                      width: 44,
                      decoration: BoxDecoration(
                        color: colorScheme.primaryContainer.withValues(
                          alpha: 0.70,
                        ),
                        borderRadius: BorderRadius.circular(AppRadii.md),
                        border: Border.all(
                          color: colorScheme.primary.withValues(alpha: 0.12),
                        ),
                      ),
                      child: Icon(
                        Icons.calendar_month_rounded,
                        color: colorScheme.onPrimaryContainer,
                      ),
                    ),
                    SizedBox(width: spacing.sm),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Kalender',
                            style: textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w800,
                              color: colorScheme.onSurface,
                            ),
                          ),
                          SizedBox(height: spacing.xxs),
                          Text(
                            'Ketuk tanggal untuk mengelola hari operasional & slot waktu',
                            style: textTheme.bodySmall?.copyWith(
                              color: colorScheme.onSurfaceVariant,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // Calendar itself
              Padding(
                padding: EdgeInsets.fromLTRB(
                  spacing.sm,
                  spacing.sm,
                  spacing.sm,
                  spacing.sm,
                ),
                child: TableCalendar(
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
                    CalendarFormat.month: 'Bulan',
                    CalendarFormat.week: 'Minggu',
                  },

                  calendarStyle: CalendarStyle(
                    outsideDaysVisible: true,
                    cellMargin: EdgeInsets.all(spacing.xxs),
                    cellPadding: EdgeInsets.zero,

                    todayDecoration: BoxDecoration(
                      color: colorScheme.primary.withValues(alpha: 0.10),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: colorScheme.primary.withValues(alpha: 0.85),
                        width: 1.4,
                      ),
                    ),
                    todayTextStyle: textTheme.bodyMedium!.copyWith(
                      color: colorScheme.primary,
                      fontWeight: FontWeight.w800,
                    ),

                    selectedDecoration: BoxDecoration(
                      color: colorScheme.primary,
                      shape: BoxShape.circle,
                      boxShadow: AppShadows.soft(colorScheme.primary),
                    ),
                    selectedTextStyle: textTheme.bodyMedium!.copyWith(
                      color: colorScheme.onPrimary,
                      fontWeight: FontWeight.w900,
                    ),

                    weekendTextStyle: textTheme.bodyMedium!.copyWith(
                      color: colorScheme.error,
                      fontWeight: FontWeight.w700,
                    ),
                    outsideTextStyle: textTheme.bodyMedium!.copyWith(
                      color: colorScheme.onSurfaceVariant.withValues(
                        alpha: 0.55,
                      ),
                      fontWeight: FontWeight.w600,
                    ),
                    defaultTextStyle: textTheme.bodyMedium!.copyWith(
                      color: colorScheme.onSurface,
                      fontWeight: FontWeight.w700,
                    ),
                  ),

                  calendarBuilders: CalendarBuilders(
                    defaultBuilder: (context, day, _) {
                      final formatted = DateFormat('yyyy-MM-dd').format(day);
                      final isHoliday = operatingScheduleController
                          .schedulesList
                          .any((s) {
                            return controller.isSameDate(
                                  s.date.toIso8601String(),
                                  formatted,
                                ) &&
                                s.isHoliday == true;
                          });

                      if (!isHoliday) return null;

                      return Center(
                        child: Container(
                          margin: EdgeInsets.all(spacing.xxs),
                          decoration: BoxDecoration(
                            color: colorScheme.errorContainer.withValues(
                              alpha: 0.60,
                            ),
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: colorScheme.error.withValues(alpha: 0.18),
                            ),
                          ),
                          child: Center(
                            child: Text(
                              '${day.day}',
                              style: textTheme.bodySmall?.copyWith(
                                color: colorScheme.onErrorContainer,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                    markerBuilder: (context, date, _) {
                      final formatted = DateFormat('yyyy-MM-dd').format(date);
                      final hasSchedule = operatingScheduleController
                          .schedulesList
                          .any(
                            (s) => controller.isSameDate(
                              s.date.toIso8601String(),
                              formatted,
                            ),
                          );

                      if (!hasSchedule) return null;

                      return Positioned(
                        bottom: spacing.xxs,
                        child: Container(
                          height: spacing.xxs + 2,
                          width: spacing.xxs + 2,
                          decoration: BoxDecoration(
                            color: colorScheme.secondary,
                            shape: BoxShape.circle,
                            boxShadow: AppShadows.soft(colorScheme.secondary),
                          ),
                        ),
                      );
                    },
                  ),

                  headerStyle: HeaderStyle(
                    titleCentered: true,
                    formatButtonVisible: true,
                    headerMargin: EdgeInsets.only(bottom: spacing.xs),
                    leftChevronMargin: EdgeInsets.zero,
                    rightChevronMargin: EdgeInsets.zero,
                    decoration: BoxDecoration(
                      color: surface,
                      borderRadius: BorderRadius.circular(AppRadii.lg),
                    ),
                    formatButtonDecoration: BoxDecoration(
                      color: colorScheme.surfaceContainerHighest.withValues(
                        alpha: 0.45,
                      ),
                      border: Border.all(color: outlineSoft),
                      borderRadius: BorderRadius.circular(999),
                    ),
                    formatButtonPadding: EdgeInsets.symmetric(
                      vertical: spacing.xxs,
                      horizontal: spacing.sm,
                    ),
                    formatButtonTextStyle: textTheme.labelMedium!.copyWith(
                      color: colorScheme.onSurface,
                      fontWeight: FontWeight.w800,
                    ),
                    titleTextStyle: textTheme.titleMedium!.copyWith(
                      color: colorScheme.onSurface,
                      fontWeight: FontWeight.w900,
                    ),
                    leftChevronIcon: Icon(
                      Icons.chevron_left_rounded,
                      color: colorScheme.primary,
                      size: spacing.xl,
                    ),
                    rightChevronIcon: Icon(
                      Icons.chevron_right_rounded,
                      color: colorScheme.primary,
                      size: spacing.xl,
                    ),
                  ),

                  daysOfWeekStyle: DaysOfWeekStyle(
                    weekdayStyle: textTheme.bodySmall!.copyWith(
                      color: colorScheme.onSurfaceVariant,
                      fontWeight: FontWeight.w900,
                    ),
                    weekendStyle: textTheme.bodySmall!.copyWith(
                      color: colorScheme.error,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
              ),
            ],
          );
        }),
      ),
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
        title: 'Belum ada hari operasional',
        subtitle: 'Buat jadwal operasional untuk\n$formattedDate.',
        actions: AppButton(
          text: 'Buat Hari Operasional',
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
        title: 'Mode libur',
        subtitle:
            (schedule.notes != null && schedule.notes!.isNotEmpty)
                ? schedule.notes!
                : 'Hari ini ditandai sebagai libur.',
        actions: SizedBox(
          width: double.infinity,
          child: AppButton(
            text: 'Jadikan Hari Aktif',
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
        title: 'Belum ada slot waktu',
        subtitle:
            'Tambahkan slot secara manual atau buat otomatis sekali ketuk.',
        actions: Column(
          children: [
            SizedBox(
              width: double.infinity,
              child: AppButton(
                text: 'Buat Otomatis',
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
                text: 'Tambah Manual',
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
      text: 'Tambah Slot Waktu',
      icon: Icons.add_rounded,
      color: colorScheme.primary,
    );
  }

  Widget _buildDailyHeader(
    BuildContext context,
    DateTime date,
    dynamic schedule,
  ) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;
    final spacing = theme.extension<AppSpacing>() ?? const AppSpacing();

    final dayLabel = DateFormat('EEEE').format(date);

    return Padding(
      padding: EdgeInsets.fromLTRB(
        spacing.md,
        spacing.xs,
        spacing.md,
        spacing.sm,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Row(
              children: [
                Container(
                  height: 44,
                  width: 44,
                  decoration: BoxDecoration(
                    color: colorScheme.secondaryContainer.withValues(
                      alpha: 0.60,
                    ),
                    borderRadius: BorderRadius.circular(AppRadii.md),
                    border: Border.all(
                      color: colorScheme.secondary.withValues(alpha: 0.12),
                    ),
                  ),
                  child: Icon(
                    Icons.access_time_rounded,
                    color: colorScheme.onSecondaryContainer,
                  ),
                ),
                SizedBox(width: spacing.sm),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        TimeZoneUtil.formatDate(date),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: textTheme.titleLarge?.copyWith(
                          color: colorScheme.onSurface,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      SizedBox(height: spacing.xxs),
                      Text(
                        dayLabel,
                        style: textTheme.bodySmall?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          PopupMenuButton(
            icon: Icon(
              Icons.more_vert_rounded,
              color: colorScheme.onSurfaceVariant,
            ),
            tooltip: "Opsi lainnya",
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
                        'Hapus Hari Operasional',
                        style: textTheme.bodyMedium?.copyWith(
                          color: colorScheme.error,
                          fontWeight: FontWeight.w800,
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
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;
    final spacing = theme.extension<AppSpacing>() ?? const AppSpacing();
    final semantic = theme.extension<AppSemanticColors>();

    final total = sessions.length;
    final booked = sessions.where((s) => s.isBooked == true).length;
    final isFull = total > 0 && booked == total;
    final progress = total > 0 ? booked / total : 0.0;

    final statusColor =
        isFull
            ? colorScheme.error
            : (semantic?.success ?? colorScheme.tertiary);

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadii.lg),
        side: BorderSide(
          color: colorScheme.outlineVariant.withValues(alpha: 0.70),
          width: 1,
        ),
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
          padding: EdgeInsets.all(spacing.md),
          child: Row(
            children: [
              // Time pill
              Container(
                constraints: const BoxConstraints(minWidth: 92),
                padding: EdgeInsets.symmetric(
                  vertical: spacing.xs,
                  horizontal: spacing.sm,
                ),
                decoration: BoxDecoration(
                  color: colorScheme.primaryContainer.withValues(alpha: 0.65),
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(
                    color: colorScheme.primary.withValues(alpha: 0.12),
                  ),
                ),
                child: Text(
                  displayStartTime,
                  textAlign: TextAlign.center,
                  style: textTheme.titleMedium?.copyWith(
                    color: colorScheme.onPrimaryContainer,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              SizedBox(width: spacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Status row
                    Row(
                      children: [
                        Container(
                          width: spacing.sm,
                          height: spacing.sm,
                          decoration: BoxDecoration(
                            color: statusColor,
                            shape: BoxShape.circle,
                            boxShadow: AppShadows.soft(statusColor),
                          ),
                        ),
                        SizedBox(width: spacing.sm),
                        Expanded(
                          child: Text(
                            isFull ? "Penuh" : "Tersedia",
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: textTheme.bodyMedium?.copyWith(
                              color: statusColor,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ),
                        Text(
                          total > 0
                              ? '$booked/$total terisi'
                              : 'Belum ada sesi',
                          style: textTheme.bodySmall?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                    if (total > 0) ...[
                      SizedBox(height: spacing.sm),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(999),
                        child: LinearProgressIndicator(
                          value: progress,
                          backgroundColor: colorScheme.surfaceContainerHighest,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            statusColor,
                          ),
                          minHeight: 7,
                        ),
                      ),
                    ] else ...[
                      SizedBox(height: spacing.xxs),
                      Text(
                        'Ketuk untuk lihat detail & kelola sesi',
                        style: textTheme.bodySmall?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              SizedBox(width: spacing.sm),
              Icon(
                Icons.chevron_right_rounded,
                color: colorScheme.onSurfaceVariant.withValues(alpha: 0.60),
                size: spacing.xl,
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
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;
    final spacing = theme.extension<AppSpacing>() ?? const AppSpacing();

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: EdgeInsets.all(spacing.xl),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 520),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                height: 84,
                width: 84,
                decoration: BoxDecoration(
                  color: iconColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(AppRadii.xl),
                  border: Border.all(color: iconColor.withValues(alpha: 0.18)),
                ),
                child: Icon(icon, size: 44, color: iconColor),
              ),
              SizedBox(height: spacing.lg),
              Text(
                title,
                textAlign: TextAlign.center,
                style: textTheme.headlineSmall?.copyWith(
                  color: colorScheme.onSurface,
                  fontWeight: FontWeight.w900,
                ),
              ),
              SizedBox(height: spacing.sm),
              Text(
                subtitle,
                textAlign: TextAlign.center,
                style: textTheme.bodyLarge?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                  fontWeight: FontWeight.w600,
                ),
              ),
              if (actions != null) ...[SizedBox(height: spacing.xl), actions],
            ],
          ),
        ),
      ),
    );
  }

  void _showDeleteConfirmationDialog(BuildContext context, dynamic schedule) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;
    final spacing = theme.extension<AppSpacing>() ?? const AppSpacing();

    Get.dialog(
      Dialog(
        child: Padding(
          padding: EdgeInsets.all(spacing.lg),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                height: 72,
                width: 72,
                decoration: BoxDecoration(
                  color: colorScheme.errorContainer.withValues(alpha: 0.75),
                  borderRadius: BorderRadius.circular(AppRadii.xl),
                  border: Border.all(
                    color: colorScheme.error.withValues(alpha: 0.18),
                  ),
                ),
                child: Icon(
                  Icons.warning_amber_rounded,
                  size: 40,
                  color: colorScheme.onErrorContainer,
                ),
              ),
              SizedBox(height: spacing.md),
              Text(
                'Hapus hari operasional?',
                textAlign: TextAlign.center,
                style: textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w900,
                  color: colorScheme.onSurface,
                ),
              ),
              SizedBox(height: spacing.xs),
              Text(
                'Ini akan menghapus hari dan seluruh slot waktunya.',
                textAlign: TextAlign.center,
                style: textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(height: spacing.lg),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: Get.back,
                      child: const Text('Batal'),
                    ),
                  ),
                  SizedBox(width: spacing.sm),
                  Expanded(
                    child: FilledButton(
                      onPressed: () => _deleteSchedule(schedule),
                      style: FilledButton.styleFrom(
                        backgroundColor: colorScheme.error,
                        foregroundColor: colorScheme.onError,
                        minimumSize: const Size(0, 52),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(AppRadii.md),
                        ),
                      ),
                      child: const Text('Hapus'),
                    ),
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
        'Dihapus',
        'Hari operasional berhasil dihapus.',
        backgroundColor: ColorTheme.success.withValues(alpha: 0.10),
        colorText: ColorTheme.success,
      );
    } catch (e) {
      Get.snackbar(
        'Gagal',
        'Tidak dapat menghapus: ${e.toString()}',
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
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final spacing = theme.extension<AppSpacing>() ?? const AppSpacing();

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadii.lg),
        child: Ink(
          padding: EdgeInsets.symmetric(vertical: spacing.lg),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.06),
            borderRadius: BorderRadius.circular(AppRadii.lg),
            border: Border.all(
              color: color.withValues(alpha: 0.28),
              width: 1.5,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: color),
              SizedBox(width: spacing.sm),
              Text(
                text,
                style: textTheme.labelLarge?.copyWith(
                  color: color,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
