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
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 0,
      backgroundColor: Colors.transparent,
      child: _buildDialogContent(context),
    );
  }

  Widget _buildDialogContent(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1), // Standard opacity
            spreadRadius: 2, // Reduced spread
            blurRadius: 8, // Reduced blur
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildHeader(),
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
                        color: Colors.red.shade700,
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

  Widget _buildHeader() {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: ColorTheme.primary.withValues(
              alpha: 0.1,
            ), // Standard opacity
            shape: BoxShape.circle,
          ),
          child: Icon(
            Icons.access_time_filled_rounded, // Changed Icon
            size: 36,
            color: ColorTheme.primary,
          ),
        ),
        const SizedBox(height: 16),
        Text(
          isEditMode ? 'Edit Time Slot' : 'Add New Time Slot',
          style: TextStyle(
            fontSize: 20, // Adjusted size
            fontWeight: FontWeight.bold,
            color: ColorTheme.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          isEditMode
              ? 'Update the start and end time for this slot.'
              : 'Set the start and end time for the new slot.',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 15,
            color: ColorTheme.textSecondary,
          ), // Adjusted size
        ),
      ],
    );
  }

  Widget _buildTimeSelectors(BuildContext context) {
    return Column(
      children: [
        _buildTimeSelectorField(
          context: context,
          label: 'Start Time',
          icon: Icons.schedule_rounded, // Changed icon
          time: _startTime,
          onTap: () => _selectTime(context, true),
        ),
        const SizedBox(height: 16),
        _buildTimeSelectorField(
          context: context,
          label: 'End Time',
          icon: Icons.update_rounded, // Changed icon
          time: _endTime,
          onTap: () => _selectTime(context, false),
        ),
        const SizedBox(height: 12), // Adjusted spacing
        _buildDurationDisplay(),
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
    // Create a DateTime just for formatting TimeOfDay with app_date_utils
    final DateTime tempDateTime = DateTime(2000, 1, 1, time.hour, time.minute);
    final String timeString = app_date_utils.DateUtils.formatTime(tempDateTime);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ), // Adjusted padding
        decoration: BoxDecoration(
          color: Colors.grey.shade50, // Softer background
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: Row(
          children: [
            Icon(icon, color: ColorTheme.primary, size: 22), // Adjusted size
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 13,
                    color: ColorTheme.textSecondary.withValues(alpha: 0.8),
                  ),
                ), // Adjusted style
                const SizedBox(height: 3),
                Text(
                  timeString,
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w600,
                    color: ColorTheme.textPrimary,
                  ), // Adjusted style
                ),
              ],
            ),
            const Spacer(),
            Icon(
              Icons.arrow_drop_down_rounded,
              color: ColorTheme.textSecondary,
              size: 28,
            ), // Adjusted size
          ],
        ),
      ),
    );
  }

  Widget _buildDurationDisplay() {
    final DateTime nowDate = DateTime.now(); // Base for today's date context
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

    // If TimeOfDay for end is earlier than or same as start, assume it's next day for duration calc
    if (_endTime.hour < _startTime.hour ||
        (_endTime.hour == _startTime.hour &&
            _endTime.minute <= _startTime.minute)) {
      endDt = endDt.add(const Duration(days: 1));
    }

    final Duration duration = endDt.difference(startDt);
    final bool isValid = duration.inMinutes > 0;
    final String durationText =
        isValid ? app_date_utils.DateUtils.formatDuration(duration) : "N/A";

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
      decoration: BoxDecoration(
        color:
            isValid
                ? Colors.teal.withValues(alpha: 0.05)
                : Colors.red.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color:
              isValid
                  ? Colors.teal.withValues(alpha: 0.3)
                  : Colors.red.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            isValid ? Icons.timer_outlined : Icons.error_outline_rounded,
            color: isValid ? Colors.teal.shade600 : Colors.red.shade600,
            size: 18,
          ),
          const SizedBox(width: 8),
          Text(
            isValid
                ? 'Duration: $durationText'
                : 'End time must be after start',
            style: TextStyle(
              color: isValid ? Colors.teal.shade700 : Colors.red.shade700,
              fontWeight: FontWeight.w500,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
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
    final TimeOfDay initialTime = isStartSelection ? _startTime : _endTime;
    final TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: initialTime,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: ColorTheme.primary,
              onPrimary: Colors.white,
              onSurface: ColorTheme.textPrimary,
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(foregroundColor: ColorTheme.primary),
            ),
          ),
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

  DateTime _getScheduleDate() {
    final OperatingSchedule? schedule = _scheduleController.schedulesList
        .firstWhereOrNull((s) => s.id == widget.operatingScheduleId);
    if (schedule == null) {
      _timeSlotController.errorMessage.value =
          'Jadwal operasi tidak ditemukan. Menggunakan tanggal hari ini.';
      // Return current date, ensuring its time components are zeroed out for consistency if needed.
      final now = DateTime.now();
      return DateTime(now.year, now.month, now.day);
    }
    // schedule.date is already a local DateTime (date part only usually from API)
    return schedule.date;
  }

  List<DateTime> _createDateTimeValues() {
    final DateTime scheduleDate = _getScheduleDate(); // This is a local date

    DateTime startDateTime = DateTime(
      scheduleDate.year,
      scheduleDate.month,
      scheduleDate.day,
      _startTime.hour,
      _startTime.minute,
    ); // Local DateTime

    DateTime endDateTime = DateTime(
      scheduleDate.year,
      scheduleDate.month,
      scheduleDate.day,
      _endTime.hour,
      _endTime.minute,
    ); // Local DateTime

    // If end TimeOfDay is earlier than or same as start TimeOfDay, assume end is on the next day.
    if (_endTime.hour < _startTime.hour ||
        (_endTime.hour == _startTime.hour &&
            _endTime.minute <= _startTime.minute)) {
      endDateTime = endDateTime.add(const Duration(days: 1));
    }
    return [startDateTime, endDateTime];
  }

  bool _validateTimeRange() {
    _timeSlotController.clearErrors(); // Clear previous before new validation
    final List<DateTime> dateTimeValues = _createDateTimeValues();
    final DateTime localStartDateTime = dateTimeValues[0];
    final DateTime localEndDateTime = dateTimeValues[1];

    if (!localEndDateTime.isAfter(localStartDateTime)) {
      _timeSlotController.errorMessage.value =
          'Waktu selesai harus setelah waktu mulai.';
      return false;
    }

    // Overlap Check:
    // TimeSlot model stores UTC. Proposed slot needs to be UTC for hasOverlap.
    final TimeSlot proposedSlotForCheck = TimeSlot(
      id:
          isEditMode
              ? widget.timeSlot!.id
              : 'temp-${DateTime.now().millisecondsSinceEpoch}',
      operatingScheduleId: widget.operatingScheduleId,
      startTime: localStartDateTime.toUtc(), // Convert to UTC for hasOverlap
      endTime: localEndDateTime.toUtc(), // Convert to UTC for hasOverlap
      createdAt:
          (isEditMode ? widget.timeSlot!.createdAt : DateTime.now().toUtc()),
      updatedAt: DateTime.now().toUtc(),
      sessions: const [],
    );

    List<TimeSlot> existingSlotsForSchedule =
        _timeSlotController.timeSlots
            .where((s) => s.operatingScheduleId == widget.operatingScheduleId)
            .toList();

    // If editing, exclude the current slot being edited from the overlap check list
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
      return; // Error message is set by _validateTimeRange
    }

    final List<DateTime> localDateTimeValues = _createDateTimeValues();
    final DateTime localStart = localDateTimeValues[0]; // Local DateTime
    final DateTime localEnd = localDateTimeValues[1]; // Local DateTime

    TimeSlot? result;
    if (isEditMode && widget.timeSlot != null) {
      result = await _timeSlotController.updateTimeSlot(
        id: widget.timeSlot!.id,
        startTime: localStart, // Pass local DateTime
        endTime: localEnd, // Pass local DateTime
        operatingScheduleId:
            widget.operatingScheduleId, // Pass in case it can be changed
      );
    } else {
      result = await _timeSlotController.createTimeSlot(
        operatingScheduleId: widget.operatingScheduleId,
        startTime: localStart, // Pass local DateTime
        endTime: localEnd, // Pass local DateTime
      );
    }

    if (result != null && _timeSlotController.errorMessage.isEmpty) {
      Get.back(); // Close dialog
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
      // No need to call fetchTimeSlotsByScheduleId here, as it's done within the controller methods.
    }
    // If error, it will be displayed in the dialog via Obx
  }
}

extension _FirstWhereOrNull<E> on Iterable<E> {}
