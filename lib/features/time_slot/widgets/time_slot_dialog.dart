// lib/features/time_slot/widgets/time_slot_dialog.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:emababyspa/common/theme/color_theme.dart';
import 'package:emababyspa/common/widgets/app_button.dart';
import 'package:emababyspa/features/time_slot/controllers/time_slot_controller.dart';
import 'package:emababyspa/features/operating_schedule/controllers/operating_schedule_controller.dart';
import 'package:emababyspa/data/models/time_slot.dart';
import 'package:emababyspa/data/models/operating_schedule.dart'; // For OperatingSchedule type hint
import 'package:emababyspa/common/utils/date_utils.dart' as app_date_utils;
import 'package:emababyspa/features/theme/controllers/theme_controller.dart'; // Import ThemeController

class TimeSlotDialog extends StatefulWidget {
  final String operatingScheduleId;
  final TimeSlot? timeSlot; // For editing

  const TimeSlotDialog({
    super.key,
    required this.operatingScheduleId,
    this.timeSlot,
  });

  @override
  State<TimeSlotDialog> createState() => _TimeSlotDialogState();
}

class _TimeSlotDialogState extends State<TimeSlotDialog> {
  final TimeSlotController _timeSlotController = Get.find<TimeSlotController>();
  final OperatingScheduleController _scheduleController =
      Get.find<OperatingScheduleController>();
  // Access the ThemeController to check the current theme state
  final ThemeController _themeController = Get.find<ThemeController>();

  late TimeOfDay _startTime;
  late TimeOfDay _endTime;

  bool get isEditMode => widget.timeSlot != null;

  @override
  void initState() {
    super.initState();
    _timeSlotController.clearErrors();

    if (isEditMode && widget.timeSlot != null) {
      // TimeSlot times are UTC, convert to local TimeOfDay for pickers
      final DateTime localStartTime = widget.timeSlot!.startTime.toLocal();
      final DateTime localEndTime = widget.timeSlot!.endTime.toLocal();
      _startTime = TimeOfDay(
        hour: localStartTime.hour,
        minute: localStartTime.minute,
      );
      _endTime = TimeOfDay(
        hour: localEndTime.hour,
        minute: localEndTime.minute,
      );
    } else {
      _startTime = const TimeOfDay(hour: 8, minute: 0); // Default for new
      _endTime = const TimeOfDay(hour: 9, minute: 0); // Default for new
    }
  }

  @override
  Widget build(BuildContext context) {
    // No changes here, the dialog background is transparent by default
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 0,
      backgroundColor: Colors.transparent,
      child: _buildDialogContent(context),
    );
  }

  Widget _buildDialogContent(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        // Use surface color which adapts to light/dark themes
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            // A subtle shadow that works on both themes
            color: Colors.black.withValues(alpha: 0.1),
            spreadRadius: 2,
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildHeader(context),
            const SizedBox(height: 24),
            _buildTimeSelectors(context),
            const SizedBox(height: 20),
            _buildActionButtons(),
            Obx(() {
              return _timeSlotController.errorMessage.isNotEmpty
                  ? Padding(
                    padding: const EdgeInsets.only(top: 16),
                    child: Text(
                      _timeSlotController.errorMessage.value,
                      style: TextStyle(
                        // Use the theme's error color
                        color: colorScheme.error,
                        fontSize: 14,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  )
                  : const SizedBox.shrink();
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            // Use primary container for a subtle, theme-aware background
            color: colorScheme.primaryContainer,
            shape: BoxShape.circle,
          ),
          child: Icon(
            Icons.access_time_filled_rounded,
            size: 36,
            // Use the primary color, which is defined for both light and dark themes
            color: colorScheme.primary,
          ),
        ),
        const SizedBox(height: 16),
        Text(
          isEditMode ? 'Edit Time Slot' : 'Add New Time Slot',
          style: theme.textTheme.headlineSmall?.copyWith(
            // Use onSurface color for high-emphasis text
            color: colorScheme.onSurface,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          isEditMode
              ? 'Update the start and end time for this slot.'
              : 'Set the start and end time for the new slot.',
          textAlign: TextAlign.center,
          style: theme.textTheme.bodyMedium?.copyWith(
            // Use onSurfaceVariant for medium-emphasis text
            color: colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }

  Widget _buildTimeSelectors(BuildContext context) {
    // This widget now implicitly uses theme colors passed down from its children.
    return Column(
      children: [
        _buildTimeSelectorField(
          context: context,
          label: 'Start Time',
          icon: Icons.schedule_rounded,
          time: _startTime,
          onTap: () => _selectTime(context, true),
        ),
        const SizedBox(height: 16),
        _buildTimeSelectorField(
          context: context,
          label: 'End Time',
          icon: Icons.update_rounded,
          time: _endTime,
          onTap: () => _selectTime(context, false),
        ),
        const SizedBox(height: 12),
        _buildDurationDisplay(context), // Pass context to access the theme
      ],
    );
  }

  Widget _buildTimeSelectorField({
    required BuildContext context,
    required String label,
    required IconData icon,
    required TimeOfDay time,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final DateTime tempDateTime = DateTime(2000, 1, 1, time.hour, time.minute);
    final String timeString = app_date_utils.DateUtils.formatTime(tempDateTime);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          // Use a subtle color that works on both themes
          color:
              _themeController.isDarkMode
                  ? colorScheme.surfaceVariant.withValues(alpha: 0.3)
                  : ColorTheme.surfaceAlt,
          borderRadius: BorderRadius.circular(12),
          // Use the theme's outline color for borders
          border: Border.all(color: colorScheme.outline.withValues(alpha: 0.5)),
        ),
        child: Row(
          children: [
            Icon(icon, color: colorScheme.primary, size: 22),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: theme.textTheme.bodySmall?.copyWith(
                    // Use onSurfaceVariant for labels
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  timeString,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    // Use onSurface for the main time text
                    color: colorScheme.onSurface,
                  ),
                ),
              ],
            ),
            const Spacer(),
            Icon(
              Icons.arrow_drop_down_rounded,
              color: colorScheme.onSurfaceVariant,
              size: 28,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDurationDisplay(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    // Your existing duration logic remains unchanged
    final DateTime nowDate = DateTime.now();
    DateTime startDt = DateTime(
      nowDate.year,
      nowDate.month,
      nowDate.day,
      _startTime.hour,
      _startTime.minute,
    );
    DateTime endDt = DateTime(
      nowDate.year,
      nowDate.month,
      nowDate.day,
      _endTime.hour,
      _endTime.minute,
    );

    if (_endTime.hour < _startTime.hour ||
        (_endTime.hour == _startTime.hour &&
            _endTime.minute <= _startTime.minute)) {
      endDt = endDt.add(const Duration(days: 1));
    }

    final Duration duration = endDt.difference(startDt);
    final bool isValid = duration.inMinutes > 0;
    final String durationText =
        isValid ? app_date_utils.DateUtils.formatDuration(duration) : "N/A";

    // Determine theme-aware colors for valid/invalid states
    final Color backgroundColor =
        isValid
            ? (_themeController.isDarkMode
                ? Colors.teal.withValues(alpha: 0.15)
                : ColorTheme.success.withValues(alpha: 0.1))
            : colorScheme.errorContainer;
    final Color borderColor =
        isValid
            ? (_themeController.isDarkMode
                ? Colors.teal.withValues(alpha: 0.4)
                : ColorTheme.success.withValues(alpha: 0.4))
            : colorScheme.error;
    final Color contentColor =
        isValid
            ? (_themeController.isDarkMode
                ? Colors.teal.shade200
                : ColorTheme.success)
            : colorScheme.onErrorContainer;
    final IconData icon =
        isValid ? Icons.timer_outlined : Icons.error_outline_rounded;

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: borderColor),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: contentColor, size: 18),
          const SizedBox(width: 8),
          Text(
            isValid
                ? 'Duration: $durationText'
                : 'End time must be after start',
            style: theme.textTheme.bodySmall?.copyWith(
              color: contentColor,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    // This widget uses AppButton, which should already be theme-aware.
    // No changes are needed here assuming AppButton uses theme colors.
    return Obx(() {
      final bool isLoading =
          isEditMode
              ? _timeSlotController.isUpdating.value
              : _timeSlotController.isCreating.value;
      return Row(
        children: [
          Expanded(
            child: AppButton(
              text: 'Cancel',
              onPressed: isLoading ? null : () => Get.back(),
              type: AppButtonType.outline,
              icon: Icons.close_rounded,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: AppButton(
              text: isEditMode ? 'Update' : 'Save',
              onPressed: isLoading ? null : _saveTimeSlot,
              isLoading: isLoading,
              icon:
                  isEditMode
                      ? Icons.check_circle_outline_rounded
                      : Icons.save_alt_rounded,
            ),
          ),
        ],
      );
    });
  }

  Future<void> _selectTime(BuildContext context, bool isStartSelection) async {
    // This function now uses the main app theme directly for the time picker.
    final TimeOfDay initialTime = isStartSelection ? _startTime : _endTime;
    final TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: initialTime,
      // The builder now correctly inherits the app's theme for the picker.
      builder: (context, child) {
        return Theme(
          data: Theme.of(context), // This passes the entire theme context
          child: child!,
        );
      },
    );
    if (pickedTime != null) {
      setState(() {
        if (isStartSelection) {
          _startTime = pickedTime;
        } else {
          _endTime = pickedTime;
        }
      });
    }
  }

  // No changes needed for the methods below as they are logic-based.
  // ... existing _getScheduleDate, _createDateTimeValues, _validateTimeRange, and _saveTimeSlot methods ...
  DateTime _getScheduleDate() {
    final OperatingSchedule? schedule = _scheduleController.schedulesList
        .firstWhereOrNull((s) => s.id == widget.operatingScheduleId);
    if (schedule == null) {
      _timeSlotController.errorMessage.value =
          'Jadwal operasi tidak ditemukan. Menggunakan tanggal hari ini.';
      final now = DateTime.now();
      return DateTime(now.year, now.month, now.day);
    }
    return schedule.date;
  }

  List<DateTime> _createDateTimeValues() {
    final DateTime scheduleDate = _getScheduleDate();
    DateTime startDateTime = DateTime(
      scheduleDate.year,
      scheduleDate.month,
      scheduleDate.day,
      _startTime.hour,
      _startTime.minute,
    );
    DateTime endDateTime = DateTime(
      scheduleDate.year,
      scheduleDate.month,
      scheduleDate.day,
      _endTime.hour,
      _endTime.minute,
    );
    if (_endTime.hour < _startTime.hour ||
        (_endTime.hour == _startTime.hour &&
            _endTime.minute <= _startTime.minute)) {
      endDateTime = endDateTime.add(const Duration(days: 1));
    }
    return [startDateTime, endDateTime];
  }

  bool _validateTimeRange() {
    _timeSlotController.clearErrors();
    final List<DateTime> dateTimeValues = _createDateTimeValues();
    final DateTime localStartDateTime = dateTimeValues[0];
    final DateTime localEndDateTime = dateTimeValues[1];

    if (!localEndDateTime.isAfter(localStartDateTime)) {
      _timeSlotController.errorMessage.value =
          'Waktu selesai harus setelah waktu mulai.';
      return false;
    }

    final TimeSlot proposedSlotForCheck = TimeSlot(
      id:
          isEditMode
              ? widget.timeSlot!.id
              : 'temp-${DateTime.now().millisecondsSinceEpoch}',
      operatingScheduleId: widget.operatingScheduleId,
      startTime: localStartDateTime.toUtc(),
      endTime: localEndDateTime.toUtc(),
      createdAt:
          (isEditMode ? widget.timeSlot!.createdAt : DateTime.now().toUtc()),
      updatedAt: DateTime.now().toUtc(),
      sessions: const [],
    );

    List<TimeSlot> existingSlotsForSchedule =
        _timeSlotController.timeSlots
            .where((s) => s.operatingScheduleId == widget.operatingScheduleId)
            .toList();

    if (isEditMode) {
      existingSlotsForSchedule.removeWhere((s) => s.id == widget.timeSlot!.id);
    }

    final List<TimeSlot> slotsToEvaluate = [
      ...existingSlotsForSchedule,
      proposedSlotForCheck,
    ];

    if (_timeSlotController.hasOverlap(slotsToEvaluate)) {
      _timeSlotController.errorMessage.value =
          'Slot waktu ini tumpang tindih dengan slot yang sudah ada.';
      return false;
    }
    return true;
  }

  Future<void> _saveTimeSlot() async {
    if (!_validateTimeRange()) {
      return;
    }

    final List<DateTime> localDateTimeValues = _createDateTimeValues();
    final DateTime localStart = localDateTimeValues[0];
    final DateTime localEnd = localDateTimeValues[1];

    TimeSlot? result;
    if (isEditMode && widget.timeSlot != null) {
      result = await _timeSlotController.updateTimeSlot(
        id: widget.timeSlot!.id,
        startTime: localStart,
        endTime: localEnd,
        operatingScheduleId: widget.operatingScheduleId,
      );
    } else {
      result = await _timeSlotController.createTimeSlot(
        operatingScheduleId: widget.operatingScheduleId,
        startTime: localStart,
        endTime: localEnd,
      );
    }

    if (result != null && _timeSlotController.errorMessage.isEmpty) {
      Get.back();
      Get.snackbar(
        'Berhasil',
        isEditMode
            ? 'Slot waktu berhasil diperbarui.'
            : 'Slot waktu berhasil dibuat.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green.withValues(alpha: 0.9),
        colorText: Colors.white,
        margin: const EdgeInsets.all(12),
        borderRadius: 8,
        icon: const Icon(Icons.check_circle, color: Colors.white),
      );
    }
  }
}

// Keep this extension as it is
extension _FirstWhereOrNull<E> on Iterable<E> {}
