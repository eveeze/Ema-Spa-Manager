// lib/features/schedule/controllers/schedule_controller.dart
import 'package:get/get.dart';
import 'package:emababyspa/data/models/scheduler.dart';
import 'package:emababyspa/data/models/operating_schedule.dart';
import 'package:emababyspa/data/repository/scheduler_repository.dart';
import 'package:emababyspa/data/repository/operating_schedule_repository.dart';
import 'package:emababyspa/common/theme/color_theme.dart';
import 'package:emababyspa/utils/logger_utils.dart';
import 'package:emababyspa/features/operating_schedule/controllers/operating_schedule_controller.dart';
import 'package:emababyspa/features/time_slot/controllers/time_slot_controller.dart';
import 'package:emababyspa/features/session/controllers/session_controller.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';

class ScheduleController extends GetxController {
  final SchedulerRepository _schedulerRepository;
  final OperatingScheduleRepository _operatingScheduleRepository;
  final LoggerUtils _logger = LoggerUtils();

  // Controllers for integrated functionality
  final OperatingScheduleController operatingScheduleController;
  final TimeSlotController timeSlotController;
  final SessionController sessionController;

  // Observable state
  final RxBool isLoading = false.obs;
  final RxBool isGenerating = false.obs;
  final RxString errorMessage = ''.obs;
  final Rx<ScheduleGenerationResult?> lastGenerationResult =
      Rx<ScheduleGenerationResult?>(null);
  final Rx<DateTime> selectedDate = DateTime.now().obs;
  final Rx<DateTime> focusedDate = DateTime.now().obs;
  final Rx<CalendarFormat> calendarFormat = CalendarFormat.week.obs;
  final RxBool isDataLoaded = false.obs;
  // Add observable state for operating schedules
  final RxList<OperatingSchedule> operatingSchedules =
      <OperatingSchedule>[].obs;
  final RxBool isLoadingOperatingSchedules = false.obs;

  ScheduleController({
    required SchedulerRepository schedulerRepository,
    required OperatingScheduleRepository operatingScheduleRepository,
    required this.operatingScheduleController,
    required this.timeSlotController,
    required this.sessionController,
  }) : _schedulerRepository = schedulerRepository,
       _operatingScheduleRepository = operatingScheduleRepository;

  @override
  void onInit() {
    super.onInit();
    fetchOperatingSchedules();
  }

  void resetScheduleState() {
    isDataLoaded.value = false;
    selectedDate.value = DateTime.now();
    focusedDate.value = DateTime.now();
    refreshScheduleData(selectedDate.value);
  }

  /// Fetch operating schedules directly using the repository
  Future<void> fetchOperatingSchedules({
    String? date,
    bool? isHoliday,
    String? startDate,
    String? endDate,
  }) async {
    try {
      isLoadingOperatingSchedules.value = true;
      errorMessage.value = '';

      final schedules = await _operatingScheduleRepository
          .getAllOperatingSchedules(
            date: date,
            isHoliday: isHoliday,
            startDate: startDate,
            endDate: endDate,
          );

      operatingSchedules.value = schedules;
    } catch (e) {
      errorMessage.value =
          'Failed to load operating schedules. Please try again.';
      _logger.error('Error fetching operating schedules: $e');

      // Show error message
      Get.snackbar(
        'Error',
        'Failed to load operating schedules',
        backgroundColor: ColorTheme.error.withValues(alpha: 0.1),
        colorText: ColorTheme.error,
      );
    } finally {
      isLoadingOperatingSchedules.value = false;
    }
  }

  /// Get operating schedule by ID directly
  Future<OperatingSchedule?> getOperatingScheduleById(String id) async {
    try {
      return await _operatingScheduleRepository.getOperatingScheduleById(id);
    } catch (e) {
      _logger.error('Error getting operating schedule by ID: $e');
      return null;
    }
  }

  /// Get operating schedule by date directly
  Future<OperatingSchedule?> getOperatingScheduleByDate(String date) async {
    try {
      return await _operatingScheduleRepository.getOperatingScheduleByDate(
        date,
      );
    } catch (e) {
      _logger.error('Error getting operating schedule by date: $e');
      return null;
    }
  }

  Future<void> refreshScheduleData(DateTime dateToRefreshDetailsFor) async {
    isDataLoaded.value = false; // Indicate loading for details section

    // 1. Update selectedDate (important for TableCalendar's selectedDayPredicate)
    selectedDate.value = dateToRefreshDetailsFor;
    // focusedDate is typically handled by calendar interactions or explicit setting.
    // If not, ensure it's aligned with dateToRefreshDetailsFor or the relevant view.
    if (focusedDate.value.month != dateToRefreshDetailsFor.month ||
        focusedDate.value.year != dateToRefreshDetailsFor.year) {
      focusedDate.value = dateToRefreshDetailsFor;
    }

    // 2. Fetch OperatingSchedules for the current calendar view (e.g., month of focusedDate)
    //    This data is for the TableCalendar markers.
    DateTime firstDayOfMonth = DateTime(
      focusedDate.value.year,
      focusedDate.value.month,
      1,
    );
    DateTime lastDayOfMonth = DateTime(
      focusedDate.value.year,
      focusedDate.value.month + 1,
      0,
    );

    // Let OperatingScheduleController manage the list used by its view components
    // Ensure OperatingScheduleController.fetchAllSchedules can handle a date range.
    await operatingScheduleController.fetchAllSchedules(
      startDate: DateFormat('yyyy-MM-dd').format(firstDayOfMonth),
      endDate: DateFormat('yyyy-MM-dd').format(lastDayOfMonth),
    );
    // Now operatingScheduleController.schedulesList contains schedules for the current month.

    // 3. Fetch specific details for the 'dateToRefreshDetailsFor'.
    final formattedDate = DateFormat(
      'yyyy-MM-dd',
    ).format(dateToRefreshDetailsFor);
    // Find the schedule from the list populated in OperatingScheduleController
    final scheduleForSelectedDate = operatingScheduleController.schedulesList
        .firstWhereOrNull(
          (s) => _isSameDate(s.date.toIso8601String(), formattedDate),
        );

    // Clear previous details from respective controllers
    timeSlotController.timeSlots.clear();
    sessionController.sessions.clear();

    if (scheduleForSelectedDate != null) {
      // Load time slots for the selected date's schedule
      await timeSlotController.fetchTimeSlotsByScheduleId(
        scheduleForSelectedDate.id,
      );
      // Load sessions for the selected date
      await sessionController.fetchSessionsByDate(dateToRefreshDetailsFor);
    } else {
      _logger.info(
        "No operating schedule found for date: $formattedDate. Time slots and sessions will be empty for this date.",
      );
    }

    isDataLoaded.value =
        true; // Indicate details are loaded for the selected date
  }

  void resetInternalStatesForNewDateSelection() {
    isDataLoaded.value = false;
    // Do not reset selectedDate or focusedDate here if they are meant to be preserved
    // from a previous state or set explicitly before calling refresh.
    operatingScheduleController.schedulesList.clear();
    timeSlotController.timeSlots.clear();
    sessionController.sessions.clear();
  }

  /// Create a new operating schedule directly
  Future<OperatingSchedule?> createOperatingSchedule({
    required String date,
    bool? isHoliday,
    String? notes,
  }) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      final schedule = await _operatingScheduleRepository
          .createOperatingSchedule(
            date: date,
            isHoliday: isHoliday,
            notes: notes,
          );

      // Refresh the list
      await fetchOperatingSchedules();

      // Also refresh the operating schedule controller
      await operatingScheduleController.fetchAllSchedules();

      Get.snackbar(
        'Success',
        'Operating schedule created successfully',
        backgroundColor: ColorTheme.success.withValues(alpha: 0.1),
        colorText: ColorTheme.success,
      );

      return schedule;
    } catch (e) {
      errorMessage.value =
          'Failed to create operating schedule. Please try again.';
      _logger.error('Error creating operating schedule: $e');

      // Show error message
      Get.snackbar(
        'Error',
        'Failed to create operating schedule',
        backgroundColor: ColorTheme.error.withValues(alpha: 0.1),
        colorText: ColorTheme.error,
      );

      return null;
    } finally {
      isLoading.value = false;
    }
  }

  /// Update an operating schedule directly
  Future<OperatingSchedule?> updateOperatingSchedule({
    required String id,
    String? date,
    bool? isHoliday,
    String? notes,
  }) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      final schedule = await _operatingScheduleRepository
          .updateOperatingSchedule(
            id: id,
            date: date,
            isHoliday: isHoliday,
            notes: notes,
          );

      // Refresh the list
      await fetchOperatingSchedules();

      // Also refresh the operating schedule controller
      await operatingScheduleController.fetchAllSchedules();

      Get.snackbar(
        'Success',
        'Operating schedule updated successfully',
        backgroundColor: ColorTheme.success.withValues(alpha: 0.1),
        colorText: ColorTheme.success,
      );

      return schedule;
    } catch (e) {
      errorMessage.value =
          'Failed to update operating schedule. Please try again.';
      _logger.error('Error updating operating schedule: $e');

      // Show error message
      Get.snackbar(
        'Error',
        'Failed to update operating schedule',
        backgroundColor: ColorTheme.error.withValues(alpha: 0.1),
        colorText: ColorTheme.error,
      );

      return null;
    } finally {
      isLoading.value = false;
    }
  }

  /// Toggle the holiday status of an operating schedule directly
  Future<OperatingSchedule?> toggleHolidayStatus(
    String id,
    bool isHoliday,
  ) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      final schedule = await _operatingScheduleRepository.toggleHolidayStatus(
        id,
        isHoliday,
      );

      // Refresh the list
      await fetchOperatingSchedules();

      // Also refresh the operating schedule controller
      await operatingScheduleController.fetchAllSchedules();

      Get.snackbar(
        'Success',
        'Holiday status updated successfully',
        backgroundColor: ColorTheme.success.withValues(alpha: 0.1),
        colorText: ColorTheme.success,
      );

      return schedule;
    } catch (e) {
      errorMessage.value = 'Failed to update holiday status. Please try again.';
      _logger.error('Error toggling holiday status: $e');

      // Show error message
      Get.snackbar(
        'Error',
        'Failed to update holiday status',
        backgroundColor: ColorTheme.error.withValues(alpha: 0.1),
        colorText: ColorTheme.error,
      );

      return null;
    } finally {
      isLoading.value = false;
    }
  }

  /// Delete an operating schedule directly
  Future<bool> deleteOperatingSchedule(String id) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      final result = await _operatingScheduleRepository.deleteOperatingSchedule(
        id,
      );

      // Refresh the list
      await fetchOperatingSchedules();

      // Also refresh the operating schedule controller
      await operatingScheduleController.fetchAllSchedules();

      Get.snackbar(
        'Success',
        'Operating schedule deleted successfully',
        backgroundColor: ColorTheme.success.withValues(alpha: 0.1),
        colorText: ColorTheme.success,
      );

      return result;
    } catch (e) {
      errorMessage.value =
          'Failed to delete operating schedule. Please try again.';
      _logger.error('Error deleting operating schedule: $e');

      // Show error message
      Get.snackbar(
        'Error',
        'Failed to delete operating schedule',
        backgroundColor: ColorTheme.error.withValues(alpha: 0.1),
        colorText: ColorTheme.error,
      );

      return false;
    } finally {
      isLoading.value = false;
    }
  }

  // Original scheduler methods

  // Generate full schedule
  Future<void> generateFullSchedule({
    String? startDate,
    int? days,
    List<String>? holidayDates,
    TimeConfig? timeConfig,
    int? timeZoneOffset,
  }) async {
    try {
      isGenerating.value = true;
      errorMessage.value = '';

      final result = await _schedulerRepository.generateSchedule(
        startDate: startDate,
        days: days,
        holidayDates: holidayDates,
        timeConfig: timeConfig,
        timeZoneOffset: timeZoneOffset,
      );

      lastGenerationResult.value = result;

      // If successful, refresh data in all controllers
      if (result.success) {
        await _refreshAllControllers(startDate, days);

        // Also refresh our direct operating schedules
        await fetchOperatingSchedules(
          startDate: startDate,
          endDate: days != null ? _calculateEndDate(startDate, days) : null,
        );

        Get.snackbar(
          'Success',
          'Schedule generated successfully',
          backgroundColor: ColorTheme.success.withValues(alpha: 0.1),
          colorText: ColorTheme.success,
        );
      } else {
        Get.snackbar(
          'Warning',
          result.message,
          backgroundColor: ColorTheme.warning.withValues(alpha: 0.1),
          colorText: ColorTheme.warning,
        );
      }
    } catch (e) {
      errorMessage.value = 'Failed to generate schedule. Please try again.';
      _logger.error('Error generating schedule: $e');

      // Show error message
      Get.snackbar(
        'Error',
        'Failed to generate schedule',
        backgroundColor: ColorTheme.error.withValues(alpha: 0.1),
        colorText: ColorTheme.error,
      );
    } finally {
      isGenerating.value = false;
    }
  }

  // Generate operating schedules only
  Future<ComponentGenerationResult?> generateOperatingSchedules({
    String? startDate,
    int? days,
    List<String>? holidayDates,
  }) async {
    try {
      isGenerating.value = true;
      errorMessage.value = '';

      final result = await _schedulerRepository.generateOperatingSchedules(
        startDate: startDate,
        days: days,
        holidayDates: holidayDates,
      );

      // If successful, refresh operating schedules data
      if (result.success) {
        await operatingScheduleController.fetchAllSchedules(
          startDate: startDate,
          endDate: _calculateEndDate(startDate, days),
        );

        // Also refresh our direct operating schedules
        await fetchOperatingSchedules(
          startDate: startDate,
          endDate: days != null ? _calculateEndDate(startDate, days) : null,
        );

        Get.snackbar(
          'Success',
          'Operating schedules generated successfully',
          backgroundColor: ColorTheme.success.withValues(alpha: 0.1),
          colorText: ColorTheme.success,
        );
      } else {
        Get.snackbar(
          'Warning',
          result.message,
          backgroundColor: ColorTheme.warning.withValues(alpha: 0.1),
          colorText: ColorTheme.warning,
        );
      }

      return result;
    } catch (e) {
      errorMessage.value =
          'Failed to generate operating schedules. Please try again.';
      _logger.error('Error generating operating schedules: $e');

      // Show error message
      Get.snackbar(
        'Error',
        'Failed to generate operating schedules',
        backgroundColor: ColorTheme.error.withValues(alpha: 0.1),
        colorText: ColorTheme.error,
      );

      return null;
    } finally {
      isGenerating.value = false;
    }
  }

  // Generate time slots for specific operating schedules
  Future<ComponentGenerationResult?> generateTimeSlots({
    required List<String> scheduleIds,
    TimeConfig? timeConfig,
    int? timeZoneOffset,
  }) async {
    try {
      isGenerating.value = true;
      errorMessage.value = '';

      final result = await _schedulerRepository.generateTimeSlots(
        scheduleIds: scheduleIds,
        timeConfig: timeConfig,
        timeZoneOffset: timeZoneOffset,
      );

      // If successful, refresh time slots data for each schedule
      if (result.success) {
        // Refresh time slots for each schedule ID
        for (final scheduleId in scheduleIds) {
          await timeSlotController.fetchTimeSlotsByScheduleId(scheduleId);
        }

        Get.snackbar(
          'Success',
          'Time slots generated successfully',
          backgroundColor: ColorTheme.success.withValues(alpha: 0.1),
          colorText: ColorTheme.success,
        );
      } else {
        Get.snackbar(
          'Warning',
          result.message,
          backgroundColor: ColorTheme.warning.withValues(alpha: 0.1),
          colorText: ColorTheme.warning,
        );
      }

      return result;
    } catch (e) {
      errorMessage.value = 'Failed to generate time slots. Please try again.';
      _logger.error('Error generating time slots: $e');

      // Show error message
      Get.snackbar(
        'Error',
        'Failed to generate time slots',
        backgroundColor: ColorTheme.error.withValues(alpha: 0.1),
        colorText: ColorTheme.error,
      );

      return null;
    } finally {
      isGenerating.value = false;
    }
  }

  // Generate sessions for specified time slots
  Future<ComponentGenerationResult?> generateSessions({
    required Map<String, List<String>> timeSlotsBySchedule,
  }) async {
    try {
      isGenerating.value = true;
      errorMessage.value = '';

      final result = await _schedulerRepository.generateSessions(
        timeSlotsBySchedule: timeSlotsBySchedule,
      );

      // If successful, refresh session data
      if (result.success) {
        // Get all schedules with generated sessions
        final scheduleIds = timeSlotsBySchedule.keys.toList();
        if (scheduleIds.isNotEmpty) {
          // Fetch operating schedules to get their dates
          await operatingScheduleController.fetchAllSchedules();

          // Get the date range for these schedules
          final dates = _getDateRangeFromSchedules(scheduleIds);
          if (dates.isNotEmpty) {
            // Refresh sessions data
            await sessionController.fetchSessions(date: dates.join(','));
          }
        }

        Get.snackbar(
          'Success',
          'Sessions generated successfully',
          backgroundColor: ColorTheme.success.withValues(alpha: 0.1),
          colorText: ColorTheme.success,
        );
      } else {
        Get.snackbar(
          'Warning',
          result.message,
          backgroundColor: ColorTheme.warning.withValues(alpha: 0.1),
          colorText: ColorTheme.warning,
        );
      }

      return result;
    } catch (e) {
      errorMessage.value = 'Failed to generate sessions. Please try again.';
      _logger.error('Error generating sessions: $e');

      // Show error message
      Get.snackbar(
        'Error',
        'Failed to generate sessions',
        backgroundColor: ColorTheme.error.withValues(alpha: 0.1),
        colorText: ColorTheme.error,
      );

      return null;
    } finally {
      isGenerating.value = false;
    }
  }

  // Run scheduled generation manually
  Future<void> runScheduledGeneration() async {
    try {
      isGenerating.value = true;
      errorMessage.value = '';

      final result = await _schedulerRepository.runScheduledGeneration();
      lastGenerationResult.value = result;

      // If successful, refresh data in all controllers
      if (result.success) {
        await _refreshAllControllers();

        // Also refresh our direct operating schedules
        await fetchOperatingSchedules();

        Get.snackbar(
          'Success',
          'Scheduled generation completed successfully',
          backgroundColor: ColorTheme.success.withValues(alpha: 0.1),
          colorText: ColorTheme.success,
        );
      } else {
        Get.snackbar(
          'Warning',
          result.message,
          backgroundColor: ColorTheme.warning.withValues(alpha: 0.1),
          colorText: ColorTheme.warning,
        );
      }
    } catch (e) {
      errorMessage.value =
          'Failed to run scheduled generation. Please try again.';
      _logger.error('Error running scheduled generation: $e');

      // Show error message
      Get.snackbar(
        'Error',
        'Failed to run scheduled generation',
        backgroundColor: ColorTheme.error.withValues(alpha: 0.1),
        colorText: ColorTheme.error,
      );
    } finally {
      isGenerating.value = false;
    }
  }

  // Generate schedule for next day
  Future<void> generateNextDaySchedule() async {
    try {
      isGenerating.value = true;
      errorMessage.value = '';

      final result = await _schedulerRepository.generateNextDaySchedule();
      lastGenerationResult.value = result;

      // If successful, refresh data in all controllers
      if (result.success) {
        // Get tomorrow's date
        final tomorrow = DateTime.now().add(Duration(days: 1));
        final formattedDate =
            "${tomorrow.year}-${tomorrow.month.toString().padLeft(2, '0')}-${tomorrow.day.toString().padLeft(2, '0')}";

        await _refreshControllersForDate(formattedDate);

        // Also refresh our direct operating schedules
        await fetchOperatingSchedules(date: formattedDate);

        Get.snackbar(
          'Success',
          'Next day schedule generated successfully',
          backgroundColor: ColorTheme.success.withValues(alpha: 0.1),
          colorText: ColorTheme.success,
        );
      } else {
        Get.snackbar(
          'Warning',
          result.message,
          backgroundColor: ColorTheme.warning.withValues(alpha: 0.1),
          colorText: ColorTheme.warning,
        );
      }
    } catch (e) {
      errorMessage.value =
          'Failed to generate next day schedule. Please try again.';
      _logger.error('Error generating next day schedule: $e');

      // Show error message
      Get.snackbar(
        'Error',
        'Failed to generate next day schedule',
        backgroundColor: ColorTheme.error.withValues(alpha: 0.1),
        colorText: ColorTheme.error,
      );
    } finally {
      isGenerating.value = false;
    }
  }

  // Generate schedule for next week
  Future<void> generateNextWeekSchedule() async {
    try {
      isGenerating.value = true;
      errorMessage.value = '';

      final result = await _schedulerRepository.generateNextWeekSchedule();
      lastGenerationResult.value = result;

      // If successful, refresh data in all controllers
      if (result.success) {
        // Get tomorrow's date as the start date
        final tomorrow = DateTime.now().add(Duration(days: 1));
        final startDate =
            "${tomorrow.year}-${tomorrow.month.toString().padLeft(2, '0')}-${tomorrow.day.toString().padLeft(2, '0')}";

        // Refresh for a week period
        await _refreshAllControllers(startDate, 7);

        // Also refresh our direct operating schedules
        await fetchOperatingSchedules(
          startDate: startDate,
          endDate: _calculateEndDate(startDate, 7),
        );

        Get.snackbar(
          'Success',
          'Next week schedule generated successfully',
          backgroundColor: ColorTheme.success.withValues(alpha: 0.1),
          colorText: ColorTheme.success,
        );
      } else {
        Get.snackbar(
          'Warning',
          result.message,
          backgroundColor: ColorTheme.warning.withValues(alpha: 0.1),
          colorText: ColorTheme.warning,
        );
      }
    } catch (e) {
      errorMessage.value =
          'Failed to generate next week schedule. Please try again.';
      _logger.error('Error generating next week schedule: $e');

      // Show error message
      Get.snackbar(
        'Error',
        'Failed to generate next week schedule',
        backgroundColor: ColorTheme.error.withValues(alpha: 0.1),
        colorText: ColorTheme.error,
      );
    } finally {
      isGenerating.value = false;
    }
  }

  // Generate custom schedule
  Future<void> generateCustomSchedule({
    required String startDate,
    required int days,
    required List<String> holidayDates,
    required TimeConfig timeConfig,
    int? timeZoneOffset,
  }) async {
    try {
      isGenerating.value = true;
      errorMessage.value = '';

      final result = await _schedulerRepository.generateCustomSchedule(
        startDate: startDate,
        days: days,
        holidayDates: holidayDates,
        timeConfig: timeConfig,
        timeZoneOffset: timeZoneOffset,
      );

      lastGenerationResult.value = result;

      // If successful, refresh data in all controllers
      if (result.success) {
        await _refreshAllControllers(startDate, days);

        // Also refresh our direct operating schedules
        await fetchOperatingSchedules(
          startDate: startDate,
          endDate: _calculateEndDate(startDate, days),
        );

        Get.snackbar(
          'Success',
          'Custom schedule generated successfully',
          backgroundColor: ColorTheme.success.withValues(alpha: 0.1),
          colorText: ColorTheme.success,
        );
      } else {
        Get.snackbar(
          'Warning',
          result.message,
          backgroundColor: ColorTheme.warning.withValues(alpha: 0.1),
          colorText: ColorTheme.warning,
        );
      }
    } catch (e) {
      errorMessage.value =
          'Failed to generate custom schedule. Please try again.';
      _logger.error('Error generating custom schedule: $e');

      // Show error message
      Get.snackbar(
        'Error',
        'Failed to generate custom schedule',
        backgroundColor: ColorTheme.error.withValues(alpha: 0.1),
        colorText: ColorTheme.error,
      );
    } finally {
      isGenerating.value = false;
    }
  }

  // Helper methods to refresh controller data

  // Refresh all controllers with latest data
  Future<void> _refreshAllControllers([String? startDate, int? days]) async {
    try {
      final startDateToUse = startDate ?? _getTodayFormatted();
      final endDate =
          days != null ? _calculateEndDate(startDateToUse, days) : null;

      // Refresh operating schedules
      await operatingScheduleController.fetchAllSchedules(
        startDate: startDateToUse,
        endDate: endDate,
      );

      // Get schedule IDs for the date range
      final scheduleIds =
          operatingScheduleController.schedulesList
              .map((schedule) => schedule.id)
              .toList();

      // Refresh time slots for these schedules
      for (final scheduleId in scheduleIds) {
        await timeSlotController.fetchTimeSlotsByScheduleId(scheduleId);
      }

      // Refresh sessions
      await sessionController.fetchSessions(
        date: endDate != null ? '$startDateToUse,$endDate' : startDateToUse,
      );
    } catch (e) {
      _logger.error('Error refreshing controller data: $e');
    }
  }

  Future<void> fetchScheduleData() async {
    try {
      isLoading.value = true;

      // 1. Refresh operating schedules
      await fetchOperatingSchedules();

      // 2. Refresh time slots untuk semua operating schedules
      final allTimeSlotIds = <String>[];

      for (final schedule in operatingSchedules) {
        await timeSlotController.fetchTimeSlotsByScheduleId(schedule.id);

        // Get the time slots from the controller's observable list
        // Filter time slots that belong to this specific schedule
        final scheduleTimeSlots =
            timeSlotController.timeSlots
                .where((ts) => ts.operatingScheduleId == schedule.id)
                .toList();

        allTimeSlotIds.addAll(scheduleTimeSlots.map((ts) => ts.id));
      }

      // 3. Refresh sessions untuk semua time slots yang ada
      if (allTimeSlotIds.isNotEmpty) {
        for (final timeSlotId in allTimeSlotIds) {
          await sessionController.fetchSessions(timeSlotId: timeSlotId);
        }
      }
    } catch (e) {
      _logger.error('Error fetching schedule data: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> refreshData({String? specificTimeSlotId}) async {
    try {
      // Refresh operating schedules
      await operatingScheduleController.fetchAllSchedules();

      // Refresh time slots
      if (specificTimeSlotId != null) {
        await timeSlotController.fetchTimeSlotsByScheduleId(specificTimeSlotId);
      }

      // Refresh sessions
      await sessionController.fetchSessionsByDate(DateTime.now());

      update();
    } catch (e) {
      _logger.error('Error refreshing data: $e');
    }
  }

  // Refresh controllers for a specific date
  Future<void> _refreshControllersForDate(String date) async {
    try {
      // Refresh operating schedules for this date
      await operatingScheduleController.fetchAllSchedules(date: date);

      // Get schedule ID for this date
      final schedule = operatingScheduleController.schedulesList
      // ignore: unrelated_type_equality_checks
      .firstWhereOrNull((schedule) => schedule.date == date);

      final scheduleId = schedule?.id;

      if (scheduleId != null) {
        // Refresh time slots for this schedule
        await timeSlotController.fetchTimeSlotsByScheduleId(scheduleId);

        // Refresh sessions for this date
        await sessionController.fetchSessions(date: date);
      }
    } catch (e) {
      _logger.error('Error refreshing controller data for date: $e');
    }
  }

  // Helper to calculate end date string based on start date and number of days
  String _calculateEndDate(String? startDateStr, int? days) {
    if (startDateStr == null || days == null || days <= 0) {
      return _getTodayFormatted();
    }

    try {
      final dateParts = startDateStr.split('-');
      if (dateParts.length != 3) return _getTodayFormatted();

      final startDate = DateTime(
        int.parse(dateParts[0]),
        int.parse(dateParts[1]),
        int.parse(dateParts[2]),
      );

      final endDate = startDate.add(Duration(days: days - 1));
      return "${endDate.year}-${endDate.month.toString().padLeft(2, '0')}-${endDate.day.toString().padLeft(2, '0')}";
    } catch (e) {
      _logger.error('Error calculating end date: $e');
      return _getTodayFormatted();
    }
  }

  // Get today's date formatted as yyyy-MM-dd
  String _getTodayFormatted() {
    final now = DateTime.now();
    return "${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}";
  }

  bool _isSameDate(String? apiDate, String targetDate) {
    if (apiDate == null) return false;
    return apiDate.contains(targetDate);
  }

  // Get dates from a list of schedule IDs by looking them up in the controller
  List<String> _getDateRangeFromSchedules(List<String> scheduleIds) {
    final dates = <String>[];

    for (final scheduleId in scheduleIds) {
      final schedule = operatingScheduleController.schedulesList
          .firstWhereOrNull((s) => s.id == scheduleId);

      if (schedule != null) {
        final date = schedule.date;
        final formattedDate =
            "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";
        if (!dates.contains(formattedDate)) {
          dates.add(formattedDate);
        }
      }
    }

    return dates;
  }

  // Reset error message
  void resetError() {
    errorMessage.value = '';
  }

  // Reset generation result
  void resetGenerationResult() {
    lastGenerationResult.value = null;
  }
}
