import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:emababyspa/common/theme/color_theme.dart';
import 'package:emababyspa/common/widgets/custom_appbar.dart';
import 'package:emababyspa/common/layouts/main_layout.dart';
import 'package:emababyspa/common/widgets/app_button.dart';
import 'package:emababyspa/common/widgets/loading_widget.dart';
import 'package:emababyspa/features/schedule/controllers/schedule_controller.dart';
import 'package:emababyspa/features/operating_schedule/controllers/operating_schedule_controller.dart';
import 'package:emababyspa/features/time_slot/controllers/time_slot_controller.dart';
import 'package:emababyspa/features/session/controllers/session_controller.dart';
import 'package:emababyspa/utils/app_routes.dart';
import 'package:emababyspa/data/models/scheduler.dart';
import 'package:emababyspa/common/utils/date_utils.dart' as app_date_utils;

class ScheduleView extends GetView<ScheduleController> {
  const ScheduleView({super.key});

  @override
  Widget build(BuildContext context) {
    // Initialize controllers
    final operatingScheduleController = Get.find<OperatingScheduleController>();
    final timeSlotController = Get.find<TimeSlotController>();
    final sessionController = Get.find<SessionController>();

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
      sessionController,
      isDataLoaded,
    );

    return MainLayout(
      child: Scaffold(
        appBar: const CustomAppBar(title: 'Jadwal', showBackButton: false),
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
                    sessionController,
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
    SessionController sessionController,
    RxBool isDataLoaded,
  ) async {
    isDataLoaded.value = false;

    // Format date for API
    final formattedDate = DateFormat('yyyy-MM-dd').format(date);

    // Load operating schedule for the selected date - FIXED: passing String instead of DateTime
    await operatingScheduleController.fetchAllSchedules(date: formattedDate);

    // Get schedule ID for the selected date if exists
    final schedule = operatingScheduleController.schedulesList.firstWhereOrNull(
      (schedule) => _isSameDate(
        DateFormat('yyyy-MM-dd').format(schedule.date),
        formattedDate,
      ),
    );

    if (schedule != null) {
      // Load time slots for this schedule
      await timeSlotController.fetchTimeSlotsByScheduleId(schedule.id);

      // Load sessions for this date
      await sessionController.fetchSessions(date: formattedDate);
    }

    isDataLoaded.value = true;
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
    SessionController sessionController,
    RxBool isDataLoaded,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Text(
            'Schedule',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: ColorTheme.textPrimary,
              fontFamily: 'JosefinSans',
            ),
          ),
        ),
        const SizedBox(height: 12),
        _buildTableCalendar(
          selectedDate,
          focusedDate,
          calendarFormat,
          operatingScheduleController,
          timeSlotController,
          sessionController,
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
                    : const Center(
                      child: LoadingWidget(
                        color: ColorTheme.primary,
                        size: LoadingSize.small,
                        message: "Loading schedule data...",
                      ),
                    ),
          ),
        ),
        _buildAddSection(),
      ],
    );
  }

  Widget _buildTableCalendar(
    Rx<DateTime> selectedDate,
    Rx<DateTime> focusedDate,
    Rx<CalendarFormat> calendarFormat,
    OperatingScheduleController operatingScheduleController,
    TimeSlotController timeSlotController,
    SessionController sessionController,
    RxBool isDataLoaded,
  ) {
    return Obx(() {
      return TableCalendar(
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
            sessionController,
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
          markerDecoration: BoxDecoration(
            color: Colors.amber,
            shape: BoxShape.circle,
          ),
          markersMaxCount: 3,
          markerSize: 5.0,
        ),
        calendarBuilders: CalendarBuilders(
          defaultBuilder: (context, day, focusedDay) {
            // Format day to check against schedule
            final formattedDay = DateFormat('yyyy-MM-dd').format(day);

            // Use our helper function to check for schedules
            final hasSchedule = operatingScheduleController.schedulesList.any(
              (schedule) =>
                  _isSameDate(schedule.date.toIso8601String(), formattedDay),
            );

            // Same for holiday check
            final isHoliday = operatingScheduleController.schedulesList.any(
              (schedule) =>
                  _isSameDate(schedule.date.toIso8601String(), formattedDay) &&
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
                  style: const TextStyle(color: Colors.black),
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
                  style: const TextStyle(color: Colors.black),
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
                  (s) => _isSameDate(s.date.toIso8601String(), formattedDate),
                );

            if (schedule == null) return const SizedBox.shrink();

            final slots =
                timeSlotController.timeSlots
                    .where((slot) => slot.operatingScheduleId == schedule.id)
                    .toList();

            if (slots.isEmpty) return const SizedBox.shrink();

            // Show markers based on number of time slots
            return Positioned(
              bottom: 1,
              child: Container(
                width: 5.0 * (slots.length > 3 ? 3 : slots.length),
                height: 5.0,
                decoration: BoxDecoration(
                  color: Colors.amber,
                  borderRadius: BorderRadius.circular(5.0),
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
            color: ColorTheme.textPrimary,
            fontSize: 18.0,
            fontWeight: FontWeight.bold,
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

    // Use our helper function to find the schedule
    final schedule = operatingScheduleController.schedulesList.firstWhereOrNull(
      (schedule) => _isSameDate(schedule.date.toIso8601String(), formattedDate),
    );

    if (schedule == null) {
      return _buildNoScheduleView(formattedDate);
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
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Text(
            // Use app_date_utils.DateUtils.formatDate with the DateTime object
            app_date_utils.DateUtils.formatDate(selectedDate),
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: ColorTheme.textPrimary,
            ),
          ),
        ),
        const SizedBox(height: 8),
        if (schedule.notes != null && schedule.notes!.isNotEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Text(
              'Notes: ${schedule.notes}',
              style: TextStyle(
                fontSize: 14,
                fontStyle: FontStyle.italic,
                color: ColorTheme.textSecondary,
              ),
            ),
          ),
        const SizedBox(height: 16),
        Expanded(
          child: ListView.builder(
            itemCount: timeSlots.length,
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            itemBuilder: (context, index) {
              final timeSlot = timeSlots[index];

              // Format time slots for display
              String displayStartTime = _formatTimeSlot(
                timeSlot.startTime.toIso8601String(),
              );

              // Find sessions for this time slot
              final sessions =
                  sessionController.sessions
                      .where((session) => session.timeSlotId == timeSlot.id)
                      .toList();

              // For demo purposes, assign staff names (Allison or Alex) based on pattern
              final staffName = index % 2 == 0 ? 'Allison' : 'Alex';

              // Check if this time slot is booked
              final isBooked = sessions.isNotEmpty;

              return _buildTimeSlotItem(
                timeSlot,
                displayStartTime,
                staffName,
                isBooked,
                sessions,
              );
            },
          ),
        ),
      ],
    );
  }

  // Helper function to format time slots for display
  String _formatTimeSlot(String isoTimeString) {
    try {
      // Parse the ISO time string
      DateTime dateTime = DateTime.parse(isoTimeString);

      // Format it to display just the hour:minute
      return DateFormat('HH:mm').format(dateTime);
    } catch (e) {
      // If parsing fails, return the original string
      return isoTimeString;
    }
  }

  Widget _buildTimeSlotItem(
    dynamic timeSlot,
    String displayStartTime,
    String staffName,
    bool isBooked,
    List<dynamic> sessions,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              displayStartTime,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: ColorTheme.textPrimary,
              ),
            ),
          ),
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(8),
                color:
                    isBooked
                        ? Colors.red.withValues(alpha: 0.05)
                        : Colors.green.withValues(alpha: 0.05),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 30,
                        height: 30,
                        decoration: BoxDecoration(
                          color: isBooked ? Colors.red : Colors.green,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          isBooked ? Icons.event_busy : Icons.event_available,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        isBooked ? 'Booked' : 'Available',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w500,
                          color: isBooked ? Colors.red : Colors.green,
                        ),
                      ),
                    ],
                  ),
                  if (isBooked && sessions.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children:
                            sessions.map((session) {
                              return Padding(
                                padding: const EdgeInsets.only(top: 4.0),
                                child: Text(
                                  "Session with $staffName - ${session.clientName ?? 'Client'}",
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: ColorTheme.textSecondary,
                                  ),
                                ),
                              );
                            }).toList(),
                      ),
                    ),
                  if (!isBooked)
                    Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Text(
                        "Therapist: $staffName",
                        style: TextStyle(
                          fontSize: 14,
                          color: ColorTheme.textSecondary,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNoScheduleView(String formattedDate) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.event_busy,
            size: 64,
            color: ColorTheme.textSecondary.withAlpha(80),
          ),
          const SizedBox(height: 16),
          Text(
            'Tidak ada jadwal operasional untuk tanggal $formattedDate',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 16, color: ColorTheme.textSecondary),
          ),
          const SizedBox(height: 16),
          AppButton(
            text: 'Buat Jadwal',
            icon: Icons.add_circle_outline,
            onPressed: () => Get.toNamed(AppRoutes.operatingScheduleForm),
          ),
        ],
      ),
    );
  }

  Widget _buildHolidayView(dynamic schedule) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.beach_access, size: 64, color: Colors.red.withAlpha(150)),
          const SizedBox(height: 16),
          Text(
            'Hari Libur',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.red,
            ),
          ),
          const SizedBox(height: 8),
          if (schedule.notes != null && schedule.notes!.isNotEmpty)
            Text(
              schedule.notes!,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16, color: ColorTheme.textSecondary),
            ),
          const SizedBox(height: 16),
          AppButton(
            text: 'Ubah Status Libur',
            icon: Icons.edit_calendar,
            onPressed: () {
              controller.toggleHolidayStatus(schedule.id, false);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildNoTimeSlotsView(dynamic schedule) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.schedule,
            size: 64,
            color: ColorTheme.textSecondary.withAlpha(80),
          ),
          const SizedBox(height: 16),
          Text(
            'Tidak ada slot waktu yang tersedia',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 16, color: ColorTheme.textSecondary),
          ),
          const SizedBox(height: 16),
          AppButton(
            text: 'Generate Slot Waktu',
            icon: Icons.add_alarm,
            onPressed: () {
              // Generate time slots for this schedule
              controller.generateTimeSlots(
                scheduleIds: [schedule.id],
                timeConfig: TimeConfig(
                  startHour: 7,
                  endHour: 15,
                  slotDurationMinutes: 60,
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildAddSection() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.1),
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, -3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Add',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: ColorTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          _buildAddOption(
            icon: Icons.schedule,
            title: 'New Time Slot',
            onTap: () => Get.toNamed(AppRoutes.timeSlotForm),
          ),
          const SizedBox(height: 10),
          _buildAddOption(
            icon: Icons.calendar_today,
            title: 'Mark as Holiday',
            onTap: () {
              // Handle marking as holiday
              final formattedDate = DateFormat(
                'yyyy-MM-dd',
              ).format(DateTime.now());
              final scheduleController = Get.find<ScheduleController>();

              // Find if there's already a schedule for today
              scheduleController.getOperatingScheduleByDate(formattedDate).then(
                (schedule) {
                  if (schedule != null) {
                    // Update existing schedule to mark as holiday
                    scheduleController.toggleHolidayStatus(schedule.id, true);
                  } else {
                    // Create new schedule and mark as holiday
                    scheduleController.createOperatingSchedule(
                      date: formattedDate,
                      isHoliday: true,
                      notes: 'Holiday',
                    );
                  }
                },
              );
            },
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildAddOption({
    required IconData icon,
    required String title,
    required Function() onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Icon(icon, color: ColorTheme.textSecondary),
            const SizedBox(width: 12),
            Text(
              title,
              style: TextStyle(fontSize: 18, color: ColorTheme.textPrimary),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFloatingActionButton() {
    return FloatingActionButton(
      backgroundColor: ColorTheme.primary,
      child: const Icon(Icons.add),
      onPressed: () {
        // Show add options menu
        Get.bottomSheet(
          Container(
            padding: const EdgeInsets.all(20),
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  leading: Icon(Icons.schedule, color: ColorTheme.primary),
                  title: const Text('Generate Next Day Schedule'),
                  onTap: () {
                    Get.back();
                    controller.generateNextDaySchedule();
                  },
                ),
                ListTile(
                  leading: Icon(Icons.date_range, color: ColorTheme.primary),
                  title: const Text('Generate Week Schedule'),
                  onTap: () {
                    Get.back();
                    controller.generateNextWeekSchedule();
                  },
                ),
                ListTile(
                  leading: Icon(Icons.add_alarm, color: ColorTheme.primary),
                  title: const Text('Add New Time Slot'),
                  onTap: () {
                    Get.back();
                    Get.toNamed(AppRoutes.timeSlotForm);
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
