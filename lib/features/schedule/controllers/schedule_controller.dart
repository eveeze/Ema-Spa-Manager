// lib/features/schedule/controllers/schedule_controller.dart
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';

import 'package:emababyspa/common/theme/color_theme.dart';
import 'package:emababyspa/data/models/operating_schedule.dart';
import 'package:emababyspa/data/models/scheduler.dart';
import 'package:emababyspa/data/repository/operating_schedule_repository.dart';
import 'package:emababyspa/data/repository/scheduler_repository.dart';
import 'package:emababyspa/features/operating_schedule/controllers/operating_schedule_controller.dart';
import 'package:emababyspa/features/session/controllers/session_controller.dart';
import 'package:emababyspa/features/time_slot/controllers/time_slot_controller.dart';
import 'package:emababyspa/utils/logger_utils.dart';

class ScheduleController extends GetxController {
  final SchedulerRepository _schedulerRepository;
  final OperatingScheduleRepository _operatingScheduleRepository;
  final LoggerUtils _logger = LoggerUtils();

  // Integrated controllers
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

  /// Flag khusus untuk section detail harian (list time slot/sessions)
  final RxBool isDataLoaded = false.obs;

  /// Optional: list operating schedule via repository langsung (kalau masih dipakai di tempat lain)
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
    // Jangan langsung refresh detail di sini biar tidak double-call dari view.
    // View panggil bootstrap() sekali di initState.
  }

  // =========================
  // Public API (dipanggil view)
  // =========================

  /// Panggil SEKALI saat page baru dibuka (initState)
  Future<void> bootstrap() async {
    await refreshScheduleData(selectedDate.value);
  }

  /// Handler TableCalendar
  void onDateSelected(DateTime selectedDay, DateTime focusedDay) {
    if (isSameDay(selectedDate.value, selectedDay)) return;

    selectedDate.value = selectedDay;
    focusedDate.value = focusedDay;

    refreshScheduleData(selectedDay);
  }

  void onFormatChanged(CalendarFormat format) {
    if (calendarFormat.value == format) return;
    calendarFormat.value = format;
  }

  /// Saat user swipe page (bulan/minggu) di kalender
  void onPageChanged(DateTime newFocusedDay) {
    focusedDate.value = newFocusedDay;
    // Refresh marker bulan itu, dan detail tetap untuk selectedDate saat ini
    refreshScheduleData(selectedDate.value);
  }

  /// Refresh marker kalender (range focused month) + refresh detail untuk 1 hari yang dipilih
  Future<void> refreshScheduleData(DateTime dateToRefreshDetailsFor) async {
    isDataLoaded.value = false;

    // Sinkronkan selectedDate
    selectedDate.value = dateToRefreshDetailsFor;

    // Kalau selectedDate pindah bulan, selaraskan focusedDate juga (biar marker match)
    if (focusedDate.value.year != dateToRefreshDetailsFor.year ||
        focusedDate.value.month != dateToRefreshDetailsFor.month) {
      focusedDate.value = dateToRefreshDetailsFor;
    }

    // 1) Fetch operating schedules untuk marker (range 1 bulan dari focusedDate)
    final firstDayOfMonth = DateTime(
      focusedDate.value.year,
      focusedDate.value.month,
      1,
    );
    final lastDayOfMonth = DateTime(
      focusedDate.value.year,
      focusedDate.value.month + 1,
      0,
    );

    await operatingScheduleController.fetchAllSchedules(
      startDate: _fmt(firstDayOfMonth),
      endDate: _fmt(lastDayOfMonth),
    );

    // 2) Fetch detail harian (schedule -> time slots -> sessions)
    final formattedDate = _fmt(dateToRefreshDetailsFor);

    final scheduleForSelectedDate = operatingScheduleController.schedulesList
        .firstWhereOrNull(
          (s) => isSameDate(s.date.toIso8601String(), formattedDate),
        );

    // Clear detail sebelumnya biar UI tidak campur data
    timeSlotController.timeSlots.clear();
    sessionController.sessions.clear();

    if (scheduleForSelectedDate != null) {
      await timeSlotController.fetchTimeSlotsByScheduleId(
        scheduleForSelectedDate.id,
      );
      await sessionController.fetchSessionsByDate(dateToRefreshDetailsFor);
    } else {
      _logger.info("No operating schedule found for date: $formattedDate");
    }

    isDataLoaded.value = true;
  }

  /// Util date compare aman untuk: "yyyy-MM-dd" dan ISO "yyyy-MM-ddT..."
  bool isSameDate(String? apiDate, String targetDate) {
    if (apiDate == null) return false;
    return apiDate.startsWith(targetDate);
  }

  /// Reset state saat butuh “hard reset”
  Future<void> resetScheduleState() async {
    isDataLoaded.value = false;
    selectedDate.value = DateTime.now();
    focusedDate.value = DateTime.now();
    calendarFormat.value = CalendarFormat.week;

    await refreshScheduleData(selectedDate.value);
  }

  /// Toggle holiday (dipakai dari view)
  Future<void> toggleHolidayStatus(dynamic scheduleId, bool isHoliday) async {
    await operatingScheduleController.updateOperatingSchedule(
      id: scheduleId,
      isHoliday: isHoliday,
    );
    await refreshScheduleData(selectedDate.value);
  }

  // =========================
  // Optional: Repository direct CRUD (kalau masih kamu pakai)
  // =========================

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

      Get.snackbar(
        'Error',
        'Failed to load operating schedules',
        backgroundColor: ColorTheme.error.withValues(alpha: 0.10),
        colorText: ColorTheme.error,
      );
    } finally {
      isLoadingOperatingSchedules.value = false;
    }
  }

  Future<OperatingSchedule?> getOperatingScheduleById(String id) async {
    try {
      return await _operatingScheduleRepository.getOperatingScheduleById(id);
    } catch (e) {
      _logger.error('Error getting operating schedule by ID: $e');
      return null;
    }
  }

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

      await fetchOperatingSchedules();
      await operatingScheduleController.fetchAllSchedules();

      Get.snackbar(
        'Success',
        'Operating day created.',
        backgroundColor: ColorTheme.success.withValues(alpha: 0.10),
        colorText: ColorTheme.success,
      );

      return schedule;
    } catch (e) {
      errorMessage.value = 'Failed to create operating schedule.';
      _logger.error('Error creating operating schedule: $e');

      Get.snackbar(
        'Error',
        'Failed to create operating schedule',
        backgroundColor: ColorTheme.error.withValues(alpha: 0.10),
        colorText: ColorTheme.error,
      );

      return null;
    } finally {
      isLoading.value = false;
    }
  }

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

      await fetchOperatingSchedules();
      await operatingScheduleController.fetchAllSchedules();

      Get.snackbar(
        'Success',
        'Operating day updated.',
        backgroundColor: ColorTheme.success.withValues(alpha: 0.10),
        colorText: ColorTheme.success,
      );

      return schedule;
    } catch (e) {
      errorMessage.value = 'Failed to update operating schedule.';
      _logger.error('Error updating operating schedule: $e');

      Get.snackbar(
        'Error',
        'Failed to update operating schedule',
        backgroundColor: ColorTheme.error.withValues(alpha: 0.10),
        colorText: ColorTheme.error,
      );

      return null;
    } finally {
      isLoading.value = false;
    }
  }

  Future<OperatingSchedule?> toggleHolidayStatusDirect(
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

      await fetchOperatingSchedules();
      await operatingScheduleController.fetchAllSchedules();

      Get.snackbar(
        'Success',
        'Holiday status updated.',
        backgroundColor: ColorTheme.success.withValues(alpha: 0.10),
        colorText: ColorTheme.success,
      );

      return schedule;
    } catch (e) {
      errorMessage.value = 'Failed to update holiday status.';
      _logger.error('Error toggling holiday status: $e');

      Get.snackbar(
        'Error',
        'Failed to update holiday status',
        backgroundColor: ColorTheme.error.withValues(alpha: 0.10),
        colorText: ColorTheme.error,
      );

      return null;
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> deleteOperatingSchedule(String id) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      final result = await _operatingScheduleRepository.deleteOperatingSchedule(
        id,
      );

      await fetchOperatingSchedules();
      await operatingScheduleController.fetchAllSchedules();

      Get.snackbar(
        'Success',
        'Operating day deleted.',
        backgroundColor: ColorTheme.success.withValues(alpha: 0.10),
        colorText: ColorTheme.success,
      );

      return result;
    } catch (e) {
      errorMessage.value = 'Failed to delete operating schedule.';
      _logger.error('Error deleting operating schedule: $e');

      Get.snackbar(
        'Error',
        'Failed to delete operating schedule',
        backgroundColor: ColorTheme.error.withValues(alpha: 0.10),
        colorText: ColorTheme.error,
      );

      return false;
    } finally {
      isLoading.value = false;
    }
  }

  // =========================
  // Scheduler generation (tetap kamu pakai)
  // =========================

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

      if (result.success) {
        await _refreshAllControllers(startDate, days);
        await fetchOperatingSchedules(
          startDate: startDate,
          endDate: days != null ? _calculateEndDate(startDate, days) : null,
        );

        Get.snackbar(
          'Success',
          'Schedule generated successfully',
          backgroundColor: ColorTheme.success.withValues(alpha: 0.10),
          colorText: ColorTheme.success,
        );

        // refresh UI detail hari yang sedang dipilih
        await refreshScheduleData(selectedDate.value);
      } else {
        Get.snackbar(
          'Warning',
          result.message,
          backgroundColor: ColorTheme.warning.withValues(alpha: 0.10),
          colorText: ColorTheme.warning,
        );
      }
    } catch (e) {
      errorMessage.value = 'Failed to generate schedule.';
      _logger.error('Error generating schedule: $e');

      Get.snackbar(
        'Error',
        'Failed to generate schedule',
        backgroundColor: ColorTheme.error.withValues(alpha: 0.10),
        colorText: ColorTheme.error,
      );
    } finally {
      isGenerating.value = false;
    }
  }

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

      if (result.success) {
        await operatingScheduleController.fetchAllSchedules(
          startDate: startDate,
          endDate: _calculateEndDate(startDate, days),
        );

        await fetchOperatingSchedules(
          startDate: startDate,
          endDate: days != null ? _calculateEndDate(startDate, days) : null,
        );

        Get.snackbar(
          'Success',
          'Operating schedules generated successfully',
          backgroundColor: ColorTheme.success.withValues(alpha: 0.10),
          colorText: ColorTheme.success,
        );

        await refreshScheduleData(selectedDate.value);
      } else {
        Get.snackbar(
          'Warning',
          result.message,
          backgroundColor: ColorTheme.warning.withValues(alpha: 0.10),
          colorText: ColorTheme.warning,
        );
      }

      return result;
    } catch (e) {
      errorMessage.value = 'Failed to generate operating schedules.';
      _logger.error('Error generating operating schedules: $e');

      Get.snackbar(
        'Error',
        'Failed to generate operating schedules',
        backgroundColor: ColorTheme.error.withValues(alpha: 0.10),
        colorText: ColorTheme.error,
      );

      return null;
    } finally {
      isGenerating.value = false;
    }
  }

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

      if (result.success) {
        for (final scheduleId in scheduleIds) {
          await timeSlotController.fetchTimeSlotsByScheduleId(scheduleId);
        }

        Get.snackbar(
          'Success',
          'Time slots generated successfully',
          backgroundColor: ColorTheme.success.withValues(alpha: 0.10),
          colorText: ColorTheme.success,
        );

        await refreshScheduleData(selectedDate.value);
      } else {
        Get.snackbar(
          'Warning',
          result.message,
          backgroundColor: ColorTheme.warning.withValues(alpha: 0.10),
          colorText: ColorTheme.warning,
        );
      }

      return result;
    } catch (e) {
      errorMessage.value = 'Failed to generate time slots.';
      _logger.error('Error generating time slots: $e');

      Get.snackbar(
        'Error',
        'Failed to generate time slots',
        backgroundColor: ColorTheme.error.withValues(alpha: 0.10),
        colorText: ColorTheme.error,
      );

      return null;
    } finally {
      isGenerating.value = false;
    }
  }

  Future<ComponentGenerationResult?> generateSessions({
    required Map<String, List<String>> timeSlotsBySchedule,
  }) async {
    try {
      isGenerating.value = true;
      errorMessage.value = '';

      final result = await _schedulerRepository.generateSessions(
        timeSlotsBySchedule: timeSlotsBySchedule,
      );

      if (result.success) {
        final scheduleIds = timeSlotsBySchedule.keys.toList();
        if (scheduleIds.isNotEmpty) {
          await operatingScheduleController.fetchAllSchedules();

          final dates = _getDateRangeFromSchedules(scheduleIds);
          if (dates.isNotEmpty) {
            await sessionController.fetchSessions(date: dates.join(','));
          }
        }

        Get.snackbar(
          'Success',
          'Sessions generated successfully',
          backgroundColor: ColorTheme.success.withValues(alpha: 0.10),
          colorText: ColorTheme.success,
        );

        await refreshScheduleData(selectedDate.value);
      } else {
        Get.snackbar(
          'Warning',
          result.message,
          backgroundColor: ColorTheme.warning.withValues(alpha: 0.10),
          colorText: ColorTheme.warning,
        );
      }

      return result;
    } catch (e) {
      errorMessage.value = 'Failed to generate sessions.';
      _logger.error('Error generating sessions: $e');

      Get.snackbar(
        'Error',
        'Failed to generate sessions',
        backgroundColor: ColorTheme.error.withValues(alpha: 0.10),
        colorText: ColorTheme.error,
      );

      return null;
    } finally {
      isGenerating.value = false;
    }
  }

  Future<void> runScheduledGeneration() async {
    try {
      isGenerating.value = true;
      errorMessage.value = '';

      final result = await _schedulerRepository.runScheduledGeneration();
      lastGenerationResult.value = result;

      if (result.success) {
        await _refreshAllControllers();
        await fetchOperatingSchedules();

        Get.snackbar(
          'Success',
          'Scheduled generation completed successfully',
          backgroundColor: ColorTheme.success.withValues(alpha: 0.10),
          colorText: ColorTheme.success,
        );

        await refreshScheduleData(selectedDate.value);
      } else {
        Get.snackbar(
          'Warning',
          result.message,
          backgroundColor: ColorTheme.warning.withValues(alpha: 0.10),
          colorText: ColorTheme.warning,
        );
      }
    } catch (e) {
      errorMessage.value = 'Failed to run scheduled generation.';
      _logger.error('Error running scheduled generation: $e');

      Get.snackbar(
        'Error',
        'Failed to run scheduled generation',
        backgroundColor: ColorTheme.error.withValues(alpha: 0.10),
        colorText: ColorTheme.error,
      );
    } finally {
      isGenerating.value = false;
    }
  }

  Future<void> generateNextDaySchedule() async {
    try {
      isGenerating.value = true;
      errorMessage.value = '';

      final result = await _schedulerRepository.generateNextDaySchedule();
      lastGenerationResult.value = result;

      if (result.success) {
        final tomorrow = DateTime.now().add(const Duration(days: 1));
        final formattedDate = _fmt(tomorrow);

        await _refreshControllersForDate(formattedDate);
        await fetchOperatingSchedules(date: formattedDate);

        Get.snackbar(
          'Success',
          'Next day schedule generated successfully',
          backgroundColor: ColorTheme.success.withValues(alpha: 0.10),
          colorText: ColorTheme.success,
        );

        await refreshScheduleData(selectedDate.value);
      } else {
        Get.snackbar(
          'Warning',
          result.message,
          backgroundColor: ColorTheme.warning.withValues(alpha: 0.10),
          colorText: ColorTheme.warning,
        );
      }
    } catch (e) {
      errorMessage.value = 'Failed to generate next day schedule.';
      _logger.error('Error generating next day schedule: $e');

      Get.snackbar(
        'Error',
        'Failed to generate next day schedule',
        backgroundColor: ColorTheme.error.withValues(alpha: 0.10),
        colorText: ColorTheme.error,
      );
    } finally {
      isGenerating.value = false;
    }
  }

  Future<void> generateNextWeekSchedule() async {
    try {
      isGenerating.value = true;
      errorMessage.value = '';

      final result = await _schedulerRepository.generateNextWeekSchedule();
      lastGenerationResult.value = result;

      if (result.success) {
        final tomorrow = DateTime.now().add(const Duration(days: 1));
        final startDate = _fmt(tomorrow);

        await _refreshAllControllers(startDate, 7);
        await fetchOperatingSchedules(
          startDate: startDate,
          endDate: _calculateEndDate(startDate, 7),
        );

        Get.snackbar(
          'Success',
          'Next week schedule generated successfully',
          backgroundColor: ColorTheme.success.withValues(alpha: 0.10),
          colorText: ColorTheme.success,
        );

        await refreshScheduleData(selectedDate.value);
      } else {
        Get.snackbar(
          'Warning',
          result.message,
          backgroundColor: ColorTheme.warning.withValues(alpha: 0.10),
          colorText: ColorTheme.warning,
        );
      }
    } catch (e) {
      errorMessage.value = 'Failed to generate next week schedule.';
      _logger.error('Error generating next week schedule: $e');

      Get.snackbar(
        'Error',
        'Failed to generate next week schedule',
        backgroundColor: ColorTheme.error.withValues(alpha: 0.10),
        colorText: ColorTheme.error,
      );
    } finally {
      isGenerating.value = false;
    }
  }

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

      if (result.success) {
        await _refreshAllControllers(startDate, days);
        await fetchOperatingSchedules(
          startDate: startDate,
          endDate: _calculateEndDate(startDate, days),
        );

        Get.snackbar(
          'Success',
          'Custom schedule generated successfully',
          backgroundColor: ColorTheme.success.withValues(alpha: 0.10),
          colorText: ColorTheme.success,
        );

        await refreshScheduleData(selectedDate.value);
      } else {
        Get.snackbar(
          'Warning',
          result.message,
          backgroundColor: ColorTheme.warning.withValues(alpha: 0.10),
          colorText: ColorTheme.warning,
        );
      }
    } catch (e) {
      errorMessage.value = 'Failed to generate custom schedule.';
      _logger.error('Error generating custom schedule: $e');

      Get.snackbar(
        'Error',
        'Failed to generate custom schedule',
        backgroundColor: ColorTheme.error.withValues(alpha: 0.10),
        colorText: ColorTheme.error,
      );
    } finally {
      isGenerating.value = false;
    }
  }

  // =========================
  // Helpers
  // =========================

  String _fmt(DateTime d) => DateFormat('yyyy-MM-dd').format(d);

  Future<void> _refreshAllControllers([String? startDate, int? days]) async {
    try {
      final startDateToUse = startDate ?? _getTodayFormatted();
      final endDate =
          days != null ? _calculateEndDate(startDateToUse, days) : null;

      await operatingScheduleController.fetchAllSchedules(
        startDate: startDateToUse,
        endDate: endDate,
      );

      final scheduleIds =
          operatingScheduleController.schedulesList
              .map((schedule) => schedule.id)
              .toList();

      for (final scheduleId in scheduleIds) {
        await timeSlotController.fetchTimeSlotsByScheduleId(scheduleId);
      }

      await sessionController.fetchSessions(
        date: endDate != null ? '$startDateToUse,$endDate' : startDateToUse,
      );
    } catch (e) {
      _logger.error('Error refreshing controller data: $e');
    }
  }

  Future<void> _refreshControllersForDate(String date) async {
    try {
      await operatingScheduleController.fetchAllSchedules(date: date);

      final schedule = operatingScheduleController.schedulesList
          .firstWhereOrNull((s) {
            // date param di sini string, sedangkan s.date DateTime.
            final scheduleDate = _fmt(s.date);
            return scheduleDate == date;
          });

      final scheduleId = schedule?.id;

      if (scheduleId != null) {
        await timeSlotController.fetchTimeSlotsByScheduleId(scheduleId);
        await sessionController.fetchSessions(date: date);
      }
    } catch (e) {
      _logger.error('Error refreshing controller data for date: $e');
    }
  }

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
      return _fmt(endDate);
    } catch (e) {
      _logger.error('Error calculating end date: $e');
      return _getTodayFormatted();
    }
  }

  String _getTodayFormatted() => _fmt(DateTime.now());

  List<String> _getDateRangeFromSchedules(List<String> scheduleIds) {
    final dates = <String>[];

    for (final scheduleId in scheduleIds) {
      final schedule = operatingScheduleController.schedulesList
          .firstWhereOrNull((s) => s.id == scheduleId);

      if (schedule != null) {
        final formattedDate = _fmt(schedule.date);
        if (!dates.contains(formattedDate)) dates.add(formattedDate);
      }
    }

    return dates;
  }

  void resetError() => errorMessage.value = '';

  void resetGenerationResult() => lastGenerationResult.value = null;
}
