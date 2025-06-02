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

class ScheduleView extends GetView<ScheduleController> {
  const ScheduleView({super.key});

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.refreshScheduleData(controller.selectedDate.value);
    });

    return MainLayout(
      child: Scaffold(
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

          return _buildContent(
            context,
            Get.find<OperatingScheduleController>(),
            Get.find<TimeSlotController>(),
            Get.find<SessionController>(),
          );
        }),
        floatingActionButton: _buildFloatingActionButton(),
      ),
    );
  }

  // Helper function to compare dates without time component
  bool _isSameDate(String? apiDate, String targetDate) {
    if (apiDate == null) return false;

    // Handle ISO date format (2025-05-17T00:00:00.000Z)
    if (apiDate.contains('T')) {
      final datePart = apiDate.split('T')[0];
      return datePart == targetDate;
    }

    return apiDate == targetDate;
  }

  Widget _buildFloatingActionButton() {
    return FloatingActionButton(
      onPressed: () => Get.toNamed(AppRoutes.operatingScheduleForm),
      backgroundColor: ColorTheme.primary,
      tooltip: 'Add Operating Schedule',
      child: const Icon(Icons.add, color: Colors.white),
    );
  }

  Widget _buildContent(
    BuildContext context,
    OperatingScheduleController operatingScheduleController,
    TimeSlotController timeSlotController,
    SessionController sessionController,
  ) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Colors.white, ColorTheme.primary.withValues(alpha: 0.05)],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(),
          const SizedBox(height: 12),
          _buildTableCalendar(operatingScheduleController, timeSlotController),
          const SizedBox(height: 12),
          Expanded(
            child: Obx(() {
              if (!controller.isDataLoaded.value) {
                return Center(
                  child: LoadingWidget(
                    color: ColorTheme.primary,
                    size: LoadingSize.small,
                    message: "Loading schedule data...",
                  ),
                );
              }

              return _buildDailySchedule(
                context,
                controller.selectedDate.value,
                operatingScheduleController,
                timeSlotController,
                sessionController,
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(15),
          bottomRight: Radius.circular(15),
        ),
      ),
      child: Row(
        children: [
          Icon(Icons.event_note_rounded, size: 32, color: ColorTheme.primary),
          const SizedBox(width: 12),
          Text(
            'Schedule',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: ColorTheme.textPrimary,
              fontFamily: 'JosefinSans',
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTableCalendar(
    OperatingScheduleController operatingScheduleController,
    TimeSlotController timeSlotController,
  ) {
    return Obx(() {
      return Container(
        margin: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withValues(alpha: 0.1),
              spreadRadius: 1,
              blurRadius: 5,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: TableCalendar(
            firstDay: DateTime.now().subtract(const Duration(days: 365)),
            lastDay: DateTime.now().add(const Duration(days: 365)),
            focusedDay: controller.focusedDate.value,
            calendarFormat: controller.calendarFormat.value,
            selectedDayPredicate: (day) {
              return isSameDay(controller.selectedDate.value, day);
            },
            onDaySelected: (selectedDay, focusedDay) {
              controller.selectedDate.value = selectedDay;
              controller.focusedDate.value = focusedDay;
              controller.refreshScheduleData(selectedDay);
            },
            onFormatChanged: (format) {
              controller.calendarFormat.value = format;
            },
            onPageChanged: (focusedDay) {
              controller.focusedDate.value = focusedDay;
            },
            calendarStyle: CalendarStyle(
              todayDecoration: BoxDecoration(
                color: ColorTheme.primary.withValues(alpha: 0.5),
                shape: BoxShape.circle,
              ),
              selectedDecoration: BoxDecoration(
                color: ColorTheme.primary,
                shape: BoxShape.circle,
              ),
              markerDecoration: const BoxDecoration(
                color: Colors.amber,
                shape: BoxShape.circle,
              ),
              markersMaxCount: 3,
              markerSize: 5.0,
              weekendTextStyle: TextStyle(color: Colors.red.shade800),
              outsideTextStyle: TextStyle(color: Colors.grey.shade400),
            ),
            calendarBuilders: CalendarBuilders(
              defaultBuilder: (context, day, focusedDay) {
                final formattedDay = DateFormat('yyyy-MM-dd').format(day);

                final hasSchedule = operatingScheduleController.schedulesList
                    .any(
                      (schedule) => _isSameDate(
                        schedule.date.toIso8601String(),
                        formattedDay,
                      ),
                    );

                final isHoliday = operatingScheduleController.schedulesList.any(
                  (schedule) =>
                      _isSameDate(
                        schedule.date.toIso8601String(),
                        formattedDay,
                      ) &&
                      schedule.isHoliday == true,
                );

                if (isHoliday) {
                  return Container(
                    margin: const EdgeInsets.all(4.0),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: Colors.red.withValues(alpha: 0.3),
                      shape: BoxShape.circle,
                    ),
                    child: Text(
                      '${day.day}',
                      style: const TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  );
                } else if (hasSchedule) {
                  return Container(
                    margin: const EdgeInsets.all(4.0),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: Colors.green.withValues(alpha: 0.3),
                      shape: BoxShape.circle,
                    ),
                    child: Text(
                      '${day.day}',
                      style: const TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  );
                }
                return null;
              },
              markerBuilder: (context, date, events) {
                final formattedDate = DateFormat('yyyy-MM-dd').format(date);

                final schedule = operatingScheduleController.schedulesList
                    .firstWhereOrNull(
                      (s) =>
                          _isSameDate(s.date.toIso8601String(), formattedDate),
                    );

                if (schedule == null) return const SizedBox.shrink();

                final slots =
                    timeSlotController.timeSlots
                        .where(
                          (slot) => slot.operatingScheduleId == schedule.id,
                        )
                        .toList();

                if (slots.isEmpty) return const SizedBox.shrink();

                return Positioned(
                  bottom: 1,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: List.generate(
                      slots.length > 3 ? 3 : slots.length,
                      (index) => Container(
                        width: 5.0,
                        height: 5.0,
                        margin: const EdgeInsets.symmetric(horizontal: 0.5),
                        decoration: BoxDecoration(
                          color: ColorTheme.primary,
                          borderRadius: BorderRadius.circular(5.0),
                        ),
                      ),
                    ),
                  ),
                );
              },
              headerTitleBuilder: (context, day) {
                final month = DateFormat('MMMM yyyy').format(day);
                return Center(
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          ColorTheme.primary.withValues(alpha: 0.7),
                          ColorTheme.primary,
                        ],
                      ),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      month,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                );
              },
            ),
            headerStyle: HeaderStyle(
              formatButtonVisible: true,
              titleCentered: true,
              formatButtonDecoration: BoxDecoration(
                color: ColorTheme.primary,
                borderRadius: BorderRadius.circular(16.0),
              ),
              formatButtonTextStyle: const TextStyle(color: Colors.white),
              titleTextStyle: TextStyle(
                color: Colors.transparent,
                fontSize: 18.0,
                fontWeight: FontWeight.bold,
              ),
              headerMargin: const EdgeInsets.only(bottom: 8),
              headerPadding: const EdgeInsets.symmetric(vertical: 10),
              leftChevronIcon: Icon(
                Icons.chevron_left_rounded,
                color: ColorTheme.primary,
                size: 28,
              ),
              rightChevronIcon: Icon(
                Icons.chevron_right_rounded,
                color: ColorTheme.primary,
                size: 28,
              ),
            ),
            daysOfWeekStyle: DaysOfWeekStyle(
              weekdayStyle: TextStyle(
                color: ColorTheme.textPrimary,
                fontWeight: FontWeight.bold,
              ),
              weekendStyle: TextStyle(
                color: Colors.red.shade800,
                fontWeight: FontWeight.bold,
              ),
              decoration: BoxDecoration(color: Colors.grey.shade100),
            ),
          ),
        ),
      );
    });
  }

  Widget _buildDailySchedule(
    BuildContext context,
    DateTime selectedDate,
    OperatingScheduleController operatingScheduleController,
    TimeSlotController timeSlotController,
    SessionController sessionController,
  ) {
    final formattedDate = DateFormat('yyyy-MM-dd').format(selectedDate);

    final schedule = operatingScheduleController.schedulesList.firstWhereOrNull(
      (s) => _isSameDate(s.date.toIso8601String(), formattedDate),
    );

    if (schedule == null) {
      return _buildNoScheduleView(formattedDate, selectedDate);
    }

    if (schedule.isHoliday == true) {
      return _buildHolidayView(schedule);
    }

    final timeSlots =
        timeSlotController.timeSlots
            .where((slot) => slot.operatingScheduleId == schedule.id)
            .toList();

    if (timeSlots.isEmpty) {
      return _buildNoTimeSlotsView(schedule);
    }

    timeSlots.sort((a, b) => a.startTime.compareTo(b.startTime));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildDailyHeader(selectedDate, schedule),
        Expanded(
          child: ListView.builder(
            itemCount: timeSlots.length + 1,
            padding: const EdgeInsets.symmetric(
              horizontal: 16.0,
              vertical: 8.0,
            ),
            physics: const BouncingScrollPhysics(),
            itemBuilder: (context, index) {
              if (index == timeSlots.length) {
                return _buildAddTimeSlotButton(schedule.id);
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
                  timeSlot,
                  displayStartTime,
                  sessionsForSlot,
                  sessionController,
                );
              });
            },
          ),
        ),
      ],
    );
  }

  Widget _buildAddTimeSlotButton(dynamic scheduleId) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.1),
            spreadRadius: 1,
            blurRadius: 3,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () async {
              final timeSlotController = Get.find<TimeSlotController>();
              await timeSlotController.fetchTimeSlotsByScheduleId(scheduleId);

              showDialog(
                context: Get.context!,
                builder:
                    (context) =>
                        TimeSlotDialog(operatingScheduleId: scheduleId),
              );
            },
            child: Container(
              padding: const EdgeInsets.all(2),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    ColorTheme.primary.withValues(alpha: 0.2),
                    ColorTheme.primary.withValues(alpha: 0.1),
                  ],
                ),
              ),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.add_circle_outline,
                      color: ColorTheme.primary,
                      size: 24,
                    ),
                    const SizedBox(width: 10),
                    Text(
                      'Add New Time Slot',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: ColorTheme.primary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDailyHeader(DateTime selectedDate, dynamic schedule) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 8, 16, 4),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.1),
            spreadRadius: 1,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: ColorTheme.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      Icons.calendar_today_rounded,
                      color: ColorTheme.primary,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        TimeZoneUtil.formatDate(selectedDate),
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: ColorTheme.textPrimary,
                        ),
                      ),
                      Text(
                        DateFormat(
                          'EEEE',
                        ).format(TimeZoneUtil.toIndonesiaTime(selectedDate)),
                        style: TextStyle(
                          fontSize: 14,
                          color: ColorTheme.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              IconButton(
                onPressed: () => _showDeleteConfirmationDialog(schedule),
                icon: Icon(
                  Icons.delete_outline,
                  color: Colors.red.shade400,
                  size: 24,
                ),
                tooltip: 'Delete Schedule',
              ),
            ],
          ),
          if (schedule.notes != null && schedule.notes!.isNotEmpty)
            Container(
              margin: const EdgeInsets.only(top: 8),
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.amber.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.amber.withValues(alpha: 0.3)),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.sticky_note_2_outlined,
                    color: Colors.amber,
                    size: 18,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      schedule.notes!,
                      style: TextStyle(
                        fontSize: 14,
                        fontStyle: FontStyle.italic,
                        color: ColorTheme.textSecondary,
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

  String _formatTimeSlot(String isoTimeString) {
    return TimeZoneUtil.formatISOToIndonesiaTime(isoTimeString);
  }

  Widget _buildTimeSlotItem(
    dynamic timeSlot,
    String displayStartTime,
    List<dynamic> sessions,
    SessionController sessionController,
  ) {
    final int totalSessions = sessions.length;
    final int bookedSessions =
        sessions.where((session) => session.isBooked == true).length;
    final bool allBooked = totalSessions > 0 && bookedSessions == totalSessions;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.1),
            spreadRadius: 1,
            blurRadius: 3,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () async {
              // Simpan tanggal yang sedang dilihat
              final dateBeforeNavigation = controller.selectedDate.value;
              final focusedDateBeforeNavigation = controller.focusedDate.value;
              await Get.toNamed(
                AppRoutes.timeSlotDetail,
                arguments: {
                  'timeSlot': timeSlot,
                }, // timeSlot is the item being tapped
              );
              // Reset state saat kembali
              controller.selectedDate.value = dateBeforeNavigation;
              controller.focusedDate.value = focusedDateBeforeNavigation;
              Get.find<TimeSlotController>().resetTimeSlotState();
              Get.find<SessionController>().resetSessionState();

              // Refresh data untuk tanggal yang sama
              await controller.refreshScheduleData(dateBeforeNavigation);
            },
            child: Container(
              padding: const EdgeInsets.all(2),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors:
                      allBooked
                          ? [Colors.red.shade100, Colors.red.shade50]
                          : [Colors.green.shade100, Colors.green.shade50],
                ),
              ),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 70,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      decoration: BoxDecoration(
                        color:
                            allBooked
                                ? Colors.red.shade50
                                : Colors.green.shade50,
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(10),
                          bottomLeft: Radius.circular(10),
                        ),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            displayStartTime,
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color:
                                  allBooked
                                      ? Colors.red.shade700
                                      : Colors.green.shade700,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  width: 32,
                                  height: 32,
                                  decoration: BoxDecoration(
                                    color:
                                        allBooked ? Colors.red : Colors.green,
                                    shape: BoxShape.circle,
                                    boxShadow: [
                                      BoxShadow(
                                        color: (allBooked
                                                ? Colors.red
                                                : Colors.green)
                                            .withValues(alpha: 0.3),
                                        spreadRadius: 1,
                                        blurRadius: 2,
                                        offset: const Offset(0, 1),
                                      ),
                                    ],
                                  ),
                                  child: Icon(
                                    Icons.group,
                                    color: Colors.white,
                                    size: 20,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      totalSessions > 0
                                          ? '$bookedSessions/$totalSessions Terbooking'
                                          : 'Tidak ada sesi',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w500,
                                        color: ColorTheme.textPrimary,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    if (totalSessions > 0)
                                      SizedBox(
                                        width: 120,
                                        child: ClipRRect(
                                          borderRadius: BorderRadius.circular(
                                            10,
                                          ),
                                          child: LinearProgressIndicator(
                                            value:
                                                1 -
                                                (bookedSessions /
                                                    totalSessions),
                                            backgroundColor:
                                                Colors.grey.shade200,
                                            valueColor:
                                                AlwaysStoppedAnimation<Color>(
                                                  allBooked
                                                      ? Colors.red
                                                      : Colors.green,
                                                ),
                                            minHeight: 6,
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                              ],
                            ),
                            Padding(
                              padding: const EdgeInsets.only(
                                top: 8.0,
                                left: 4.0,
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    allBooked
                                        ? Icons.event_busy
                                        : Icons.event_available,
                                    size: 16,
                                    color:
                                        allBooked ? Colors.red : Colors.green,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    allBooked
                                        ? "Fully Booked"
                                        : "Sessions Available",
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                      color:
                                          allBooked ? Colors.red : Colors.green,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNoScheduleView(String formattedDate, DateTime selectedDate) {
    return Center(
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withValues(alpha: 0.1),
              spreadRadius: 1,
              blurRadius: 5,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.amber.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.event_busy,
                size: 64,
                color: Colors.amber.shade700,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Tidak ada jadwal operasional',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: ColorTheme.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'untuk tanggal $formattedDate',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16, color: ColorTheme.textSecondary),
            ),
            const SizedBox(height: 24),
            AppButton(
              text: 'Buat Jadwal',
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
          ],
        ),
      ),
    );
  }

  Widget _buildHolidayView(dynamic schedule) {
    return Center(
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withValues(alpha: 0.1),
              spreadRadius: 1,
              blurRadius: 5,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.red.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.beach_access,
                size: 64,
                color: Colors.red.shade700,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Hari Libur',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.red.shade700,
              ),
            ),
            const SizedBox(height: 16),
            if (schedule.notes != null && schedule.notes!.isNotEmpty)
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.red.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.red.withValues(alpha: 0.2)),
                ),
                child: Text(
                  schedule.notes!,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    color: ColorTheme.textSecondary,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                AppButton(
                  text: 'Ubah Status Libur',
                  icon: Icons.edit_calendar,
                  onPressed: () {
                    controller.toggleHolidayStatus(schedule.id, false);
                  },
                ),
                const SizedBox(width: 12),
                AppButton(
                  text: 'Hapus Jadwal',
                  icon: Icons.delete_outline,
                  type: AppButtonType.values[1],
                  onPressed: () => _showDeleteConfirmationDialog(schedule),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNoTimeSlotsView(dynamic schedule) {
    return Center(
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withValues(alpha: 0.1),
              spreadRadius: 1,
              blurRadius: 5,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blue.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.schedule,
                size: 64,
                color: Colors.blue.shade700,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Tidak ada slot waktu',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: ColorTheme.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Jadwal telah dibuat namun belum memiliki slot waktu',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16, color: ColorTheme.textSecondary),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                AppButton(
                  text: 'Generate Slot Waktu',
                  icon: Icons.add_alarm,
                  onPressed: () async {
                    final scheduleDate = schedule.date;
                    final timeSlotController = Get.find<TimeSlotController>();

                    await timeSlotController.generateFixedIntervalTimeSlots(
                      operatingScheduleId: schedule.id,
                      startDate: scheduleDate,
                      firstSlotStart: const TimeOfDay(hour: 7, minute: 0),
                      lastSlotEnd: const TimeOfDay(hour: 15, minute: 0),
                      slotDuration: const Duration(minutes: 60),
                    );

                    await timeSlotController.fetchTimeSlotsByScheduleId(
                      schedule.id,
                    );
                  },
                ),
                const SizedBox(width: 12),
                AppButton(
                  text: 'Hapus Jadwal',
                  icon: Icons.delete_outline,
                  type: AppButtonType.values[1],
                  onPressed: () => _showDeleteConfirmationDialog(schedule),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showDeleteConfirmationDialog(dynamic schedule) {
    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.red.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.warning_amber_rounded,
                  size: 48,
                  color: Colors.red.shade700,
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'Hapus Jadwal Operasional',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: ColorTheme.textPrimary,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Yakin ingin menghapus jadwal operasional ini? Semua slot waktu dan sesi yang terkait juga akan dihapus.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14, color: ColorTheme.textSecondary),
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                    onPressed: () => Get.back(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey.shade200,
                      foregroundColor: ColorTheme.textPrimary,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text('Batal'),
                  ),
                  ElevatedButton(
                    onPressed: () => _deleteSchedule(schedule),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text('Hapus'),
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
    final timeSlotController = Get.find<TimeSlotController>();

    Get.back();

    try {
      final success = await operatingScheduleController.deleteOperatingSchedule(
        schedule.id,
      );

      if (Get.isDialogOpen ?? false) {
        Get.back();
      }

      if (success) {
        final formattedDate = DateFormat('yyyy-MM-dd').format(DateTime.now());
        await operatingScheduleController.fetchAllSchedules(
          date: formattedDate,
        );

        final sessionController = Get.find<SessionController>();
        await sessionController.fetchSessionsByDate(DateTime.now());

        timeSlotController.timeSlots.clear();

        Get.snackbar(
          'Success',
          'Jadwal operasional berhasil dihapus',
          backgroundColor: ColorTheme.success.withValues(alpha: 0.1),
          colorText: ColorTheme.success,
        );
      } else {
        Get.snackbar(
          'Error',
          'Gagal menghapus jadwal operasional',
          backgroundColor: ColorTheme.error.withValues(alpha: 0.1),
          colorText: ColorTheme.error,
        );
      }
    } catch (e) {
      if (Get.isDialogOpen ?? false) {
        Get.back();
      }

      Get.snackbar(
        'Error',
        'Gagal menghapus jadwal operasional: ${e.toString()}',
        backgroundColor: ColorTheme.error.withValues(alpha: 0.1),
        colorText: ColorTheme.error,
      );
    }
  }
}
