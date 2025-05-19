import 'package:emababyspa/features/time_slot/widgets/time_slot_dialog.dart';
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
import 'package:emababyspa/utils/timezone_utils.dart';

class ScheduleView extends GetView<ScheduleController> {
  const ScheduleView({super.key});

  @override
  Widget build(BuildContext context) {
    // Initialize controllers
    final operatingScheduleController = Get.find<OperatingScheduleController>();
    final timeSlotController = Get.find<TimeSlotController>();
    Get.find<SessionController>();
    // For tracking selected date
    final selectedDate = DateTime.now().obs;
    final focusedDate = DateTime.now().obs;

    // For tracking calendar format
    final calendarFormat = CalendarFormat.week.obs;

    // For tracking if data is loaded
    final isDataLoaded = false.obs;

    // Load initial data for today
    _loadScheduleData(
      selectedDate.value,
      operatingScheduleController,
      timeSlotController,
      isDataLoaded,
    );

    return MainLayout(
      child: Scaffold(
        body: Obx(
          () =>
              controller.isLoading.value || controller.isGenerating.value
                  ? const Center(
                    child: LoadingWidget(
                      color: ColorTheme.primary,
                      fullScreen: true,
                      message: "Loading...",
                      size: LoadingSize.medium,
                    ),
                  )
                  : _buildContent(
                    context,
                    selectedDate,
                    focusedDate,
                    calendarFormat,
                    operatingScheduleController,
                    timeSlotController,
                    isDataLoaded,
                  ),
        ),
        floatingActionButton: _buildFloatingActionButton(),
      ),
    );
  }

  Future<void> _loadScheduleData(
    DateTime date,
    OperatingScheduleController operatingScheduleController,
    TimeSlotController timeSlotController,
    RxBool isDataLoaded,
  ) async {
    isDataLoaded.value = false;

    // Format date for API
    final formattedDate = DateFormat('yyyy-MM-dd').format(date);

    // Load operating schedule for the selected date
    await operatingScheduleController.fetchAllSchedules(date: formattedDate);

    // Load sessions for the selected date
    final sessionController = Get.find<SessionController>();
    await sessionController.fetchSessionsByDate(date);

    // Get schedule ID for the selected date if exists
    final schedule = operatingScheduleController.schedulesList.firstWhereOrNull(
      (schedule) => _isSameDate(
        DateFormat('yyyy-MM-dd').format(schedule.date),
        formattedDate,
      ),
    );

    if (schedule != null) {
      // Use the new method to load time slots for this schedule
      await timeSlotController.fetchTimeSlotsByScheduleId(schedule.id);
    } else {
      // Clear time slots if no schedule exists
      timeSlotController.timeSlots.clear();
    }

    isDataLoaded.value = true;
  }

  void _deleteSchedule(dynamic schedule) async {
    final operatingScheduleController = Get.find<OperatingScheduleController>();
    final timeSlotController = Get.find<TimeSlotController>();

    // Close the confirmation dialog
    Get.back();

    try {
      // Delete the schedule
      final success = await operatingScheduleController.deleteOperatingSchedule(
        schedule.id,
      );

      // Important: Always close the loading dialog before showing any other dialog
      if (Get.isDialogOpen ?? false) {
        Get.back();
      }

      if (success) {
        // Fetch updated data without showing loading indicator
        final formattedDate = DateFormat('yyyy-MM-dd').format(DateTime.now());
        await operatingScheduleController.fetchAllSchedules(
          date: formattedDate,
        );

        // Get session controller and fetch sessions without loading indicator
        final sessionController = Get.find<SessionController>();
        await sessionController.fetchSessionsByDate(DateTime.now());

        // Clear time slots since we deleted the schedule
        timeSlotController.timeSlots.clear();

        // Show success message
        Get.snackbar(
          'Success',
          'Jadwal operasional berhasil dihapus',
          backgroundColor: ColorTheme.success.withValues(alpha: 0.1),
          colorText: ColorTheme.success,
        );
      } else {
        // Show error message for unsuccessful deletion
        Get.snackbar(
          'Error',
          'Gagal menghapus jadwal operasional',
          backgroundColor: ColorTheme.error.withValues(alpha: 0.1),
          colorText: ColorTheme.error,
        );
      }
    } catch (e) {
      // Make sure to close loading dialog in case of exception
      if (Get.isDialogOpen ?? false) {
        Get.back();
      }

      // Show error message
      Get.snackbar(
        'Error',
        'Gagal menghapus jadwal operasional: ${e.toString()}',
        backgroundColor: ColorTheme.error.withValues(alpha: 0.1),
        colorText: ColorTheme.error,
      );
    }
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
                  // Cancel button
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
                  // Delete button
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

  // Helper function to compare dates without time component
  bool _isSameDate(String? apiDate, String targetDate) {
    if (apiDate == null) return false;

    // Handle ISO date format (2025-05-17T00:00:00.000Z)
    if (apiDate.contains('T')) {
      // Extract just the date part from the ISO string
      final datePart = apiDate.split('T')[0];
      return datePart == targetDate;
    }

    // Handle simple date format
    return apiDate == targetDate;
  }

  Widget _buildContent(
    BuildContext context,
    Rx<DateTime> selectedDate,
    Rx<DateTime> focusedDate,
    Rx<CalendarFormat> calendarFormat,
    OperatingScheduleController operatingScheduleController,
    TimeSlotController timeSlotController,
    RxBool isDataLoaded,
  ) {
    final sessionController = Get.find<SessionController>();
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
          _buildTableCalendar(
            selectedDate,
            focusedDate,
            calendarFormat,
            operatingScheduleController,
            timeSlotController,
            isDataLoaded,
          ),
          const SizedBox(height: 12),
          Expanded(
            child: Obx(
              () =>
                  isDataLoaded.value
                      ? _buildDailySchedule(
                        context,
                        selectedDate.value,
                        operatingScheduleController,
                        timeSlotController,
                        sessionController,
                      )
                      : Center(
                        child: LoadingWidget(
                          color: ColorTheme.primary,
                          size: LoadingSize.small,
                          message: "Loading schedule data...",
                        ),
                      ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFloatingActionButton() {
    return FloatingActionButton(
      onPressed: () => Get.toNamed(AppRoutes.operatingScheduleForm),
      backgroundColor: ColorTheme.primary,
      tooltip: 'Add Operating Schedule',
      child: const Icon(Icons.add, color: Colors.white),
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
    Rx<DateTime> selectedDate,
    Rx<DateTime> focusedDate,
    Rx<CalendarFormat> calendarFormat,
    OperatingScheduleController operatingScheduleController,
    TimeSlotController timeSlotController,
    RxBool isDataLoaded,
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
            focusedDay: focusedDate.value,
            calendarFormat: calendarFormat.value,
            selectedDayPredicate: (day) {
              return isSameDay(selectedDate.value, day);
            },
            onDaySelected: (selectedDay, focusedDay) {
              selectedDate.value = selectedDay;
              focusedDate.value = focusedDay;
              _loadScheduleData(
                selectedDay,
                operatingScheduleController,
                timeSlotController,
                isDataLoaded,
              );
            },
            onFormatChanged: (format) {
              calendarFormat.value = format;
            },
            onPageChanged: (focusedDay) {
              focusedDate.value = focusedDay;
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
                // Format day to check against schedule
                final formattedDay = DateFormat('yyyy-MM-dd').format(day);

                // Use our helper function to check for schedules
                final hasSchedule = operatingScheduleController.schedulesList
                    .any(
                      (schedule) => _isSameDate(
                        schedule.date.toIso8601String(),
                        formattedDay,
                      ),
                    );

                // Same for holiday check
                final isHoliday = operatingScheduleController.schedulesList.any(
                  (schedule) =>
                      _isSameDate(
                        schedule.date.toIso8601String(),
                        formattedDay,
                      ) &&
                      schedule.isHoliday == true,
                );

                if (isHoliday) {
                  // Holiday style
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
                  // Has schedule style
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
                // Format date to check against schedule
                final formattedDate = DateFormat('yyyy-MM-dd').format(date);

                // Use our helper function to find the schedule
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

                // Show markers based on number of time slots with a more attractive design
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
    SessionController sessionController, // Add this parameter
  ) {
    final formattedDate = DateFormat('yyyy-MM-dd').format(selectedDate);

    // Use our helper function to find the schedule
    final schedule = operatingScheduleController.schedulesList.firstWhereOrNull(
      (schedule) => _isSameDate(schedule.date.toIso8601String(), formattedDate),
    );

    if (schedule == null) {
      return _buildNoScheduleView(formattedDate, selectedDate);
    }

    // Check if this is a holiday
    if (schedule.isHoliday == true) {
      return _buildHolidayView(schedule);
    }

    // Find time slots for this schedule
    final timeSlots =
        timeSlotController.timeSlots
            .where((slot) => slot.operatingScheduleId == schedule.id)
            .toList();

    if (timeSlots.isEmpty) {
      return _buildNoTimeSlotsView(schedule);
    }

    // Sort time slots by start time
    timeSlots.sort((a, b) => a.startTime.compareTo(b.startTime));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildDailyHeader(selectedDate, schedule),
        Expanded(
          child: ListView.builder(
            itemCount: timeSlots.length + 1, // +1 for the add button at the end
            padding: const EdgeInsets.symmetric(
              horizontal: 16.0,
              vertical: 8.0,
            ),
            physics: const BouncingScrollPhysics(),
            itemBuilder: (context, index) {
              // Check if this is the last item (add button)
              if (index == timeSlots.length) {
                return _buildAddTimeSlotButton(schedule.id);
              }

              final timeSlot = timeSlots[index];

              // Format time slots for display
              String displayStartTime = _formatTimeSlot(
                timeSlot.startTime.toIso8601String(),
              );

              // Find sessions for this time slot
              final sessionsForSlot =
                  sessionController.sessions
                      .where((session) => session.timeSlotId == timeSlot.id)
                      .toList();

              return _buildTimeSlotItem(
                timeSlot,
                displayStartTime,
                sessionsForSlot, // Pass the sessions
                sessionController, // Pass the controller
              );
            },
          ),
        ),
      ],
    );
  }

  // Modify the _buildAddTimeSlotButton method in ScheduleView
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
              // First, make sure time slots are up-to-date
              final timeSlotController = Get.find<TimeSlotController>();
              await timeSlotController.fetchTimeSlotsByScheduleId(scheduleId);

              // Then show the TimeSlotDialog with the schedule ID
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
              // Delete button
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

  // Helper function to format time slots for display
  String _formatTimeSlot(String isoTimeString) {
    return TimeZoneUtil.formatISOToIndonesiaTime(isoTimeString);
  }

  Widget _buildTimeSlotItem(
    dynamic timeSlot,
    String displayStartTime,
    List<dynamic> sessions,
    SessionController sessionController,
  ) {
    // Get total sessions and booked sessions count from actual session data
    final int totalSessions = sessions.length;
    final int bookedSessions =
        sessions.where((session) => session.isBooked == true).length;

    // Determine if all sessions are booked
    final bool allBooked = totalSessions > 0 && bookedSessions == totalSessions;

    // Use the TimeSlotController to format the time if needed
    Get.find<TimeSlotController>();

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
            onTap: () {
              // Navigate to time slot details page directly
              Get.toNamed(
                AppRoutes.timeSlotDetail,
                arguments: {'timeSlot': timeSlot, 'sessions': sessions},
              );
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
                    // Time column
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
                    // Main content column
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
                                // Session count icon
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
                                // Session statistics
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
                                    // Progress bar for availability
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
                            // Bottom section with status
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
                // Delete button
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
                    // Get the current date from the schedule
                    final scheduleDate = schedule.date;

                    // Use the new TimeSlotController method to generate time slots
                    final timeSlotController = Get.find<TimeSlotController>();

                    // Generate fixed interval time slots (7:00 AM to 3:00 PM with 1-hour slots)
                    await timeSlotController.generateFixedIntervalTimeSlots(
                      operatingScheduleId: schedule.id,
                      startDate: scheduleDate,
                      firstSlotStart: TimeOfDay(hour: 7, minute: 0),
                      lastSlotEnd: TimeOfDay(hour: 15, minute: 0),
                      slotDuration: Duration(minutes: 60),
                    );

                    // Refresh the UI with the new slots
                    await timeSlotController.fetchTimeSlotsByScheduleId(
                      schedule.id,
                    );
                  },
                ),
                const SizedBox(width: 12),
                // Delete button
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
}
