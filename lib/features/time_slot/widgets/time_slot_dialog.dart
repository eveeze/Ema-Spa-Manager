// lib/features/time_slot/widgets/time_slot_dialog.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:emababyspa/common/theme/color_theme.dart';
import 'package:emababyspa/common/widgets/app_button.dart';
import 'package:emababyspa/features/time_slot/controllers/time_slot_controller.dart';
import 'package:emababyspa/features/operating_schedule/controllers/operating_schedule_controller.dart';
import 'package:emababyspa/common/utils/date_utils.dart' as app_date_utils;
import 'package:emababyspa/data/models/time_slot.dart';

class TimeSlotDialog extends StatefulWidget {
  final String operatingScheduleId;
  final TimeSlot? timeSlot; // Add optional time slot for editing

  const TimeSlotDialog({
    super.key,
    required this.operatingScheduleId,
    this.timeSlot, // Optional parameter for editing existing time slots
  });

  @override
  State<TimeSlotDialog> createState() => _TimeSlotDialogState();
}

class _TimeSlotDialogState extends State<TimeSlotDialog> {
  final TimeSlotController _timeSlotController = Get.find<TimeSlotController>();
  final OperatingScheduleController _scheduleController =
      Get.find<OperatingScheduleController>();

  // Time values
  late TimeOfDay _startTime;
  late TimeOfDay _endTime;

  // Dialog mode - create or edit
  bool get isEditMode => widget.timeSlot != null;

  @override
  void initState() {
    super.initState();

    if (isEditMode) {
      // Initialize with existing time slot values
      _startTime = TimeOfDay(
        hour: widget.timeSlot!.startTime.hour,
        minute: widget.timeSlot!.startTime.minute,
      );
      _endTime = TimeOfDay(
        hour: widget.timeSlot!.endTime.hour,
        minute: widget.timeSlot!.endTime.minute,
      );
    } else {
      // Default values for new time slot
      _startTime = TimeOfDay(hour: 8, minute: 0);
      _endTime = TimeOfDay(hour: 9, minute: 0);
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
            color: Colors.black.withValues(
              alpha: 26,
            ), // Fixed .withOpacity(0.1)
            spreadRadius: 5,
            blurRadius: 10,
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildHeader(),
          const SizedBox(height: 24),
          _buildTimeSelectors(context),
          const SizedBox(height: 20),
          _buildActionButtons(),
          // Show error message if any
          Obx(() {
            return _timeSlotController.errorMessage.isNotEmpty
                ? Padding(
                  padding: const EdgeInsets.only(top: 16),
                  child: Text(
                    _timeSlotController.errorMessage.value,
                    style: TextStyle(color: Colors.red.shade700),
                    textAlign: TextAlign.center,
                  ),
                )
                : const SizedBox.shrink();
          }),
        ],
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
              alpha: 26,
            ), // Fixed .withOpacity(0.1)
            shape: BoxShape.circle,
          ),
          child: Icon(
            Icons.access_time_rounded,
            size: 36,
            color: ColorTheme.primary,
          ),
        ),
        const SizedBox(height: 16),
        Text(
          isEditMode ? 'Edit Time Slot' : 'Add New Time Slot',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: ColorTheme.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          isEditMode
              ? 'Update the start and end time for this slot'
              : 'Set the start and end time for the new slot',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 16, color: ColorTheme.textSecondary),
        ),
      ],
    );
  }

  Widget _buildTimeSelectors(BuildContext context) {
    return Column(
      children: [
        // Start Time Selector
        _buildTimeSelectorField(
          context: context,
          label: 'Start Time',
          icon: Icons.play_circle_outline_rounded,
          time: _startTime,
          onTap: () => _selectTime(context, true),
        ),
        const SizedBox(height: 16),
        // End Time Selector
        _buildTimeSelectorField(
          context: context,
          label: 'End Time',
          icon: Icons.stop_circle_outlined,
          time: _endTime,
          onTap: () => _selectTime(context, false),
        ),
        const SizedBox(height: 8),
        // Duration Display
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
    // Convert TimeOfDay to DateTime for formatting
    final DateTime tempDate = DateTime(2000, 1, 1, time.hour, time.minute);
    final timeString = app_date_utils.DateUtils.formatTime(tempDate);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: Row(
          children: [
            Icon(icon, color: ColorTheme.primary),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 14,
                    color: ColorTheme.textSecondary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  timeString,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: ColorTheme.textPrimary,
                  ),
                ),
              ],
            ),
            const Spacer(),
            Icon(Icons.arrow_drop_down, color: ColorTheme.textSecondary),
          ],
        ),
      ),
    );
  }

  Widget _buildDurationDisplay() {
    // Calculate duration in minutes
    final int startMinutes = _startTime.hour * 60 + _startTime.minute;
    final int endMinutes = _endTime.hour * 60 + _endTime.minute;
    int durationMinutes = endMinutes - startMinutes;

    // Handle cases where end time is on the next day
    if (durationMinutes < 0) {
      durationMinutes += 24 * 60; // Add a full day worth of minutes
    }

    // Create duration object for formatting
    final duration = Duration(minutes: durationMinutes);
    final durationText = app_date_utils.DateUtils.formatDuration(duration);

    // Display warning for invalid duration
    final bool isValid = durationMinutes > 0;

    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: isValid ? Colors.green.shade50 : Colors.red.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isValid ? Colors.green.shade300 : Colors.red.shade300,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            isValid ? Icons.check_circle_outline : Icons.warning_amber_rounded,
            color: isValid ? Colors.green : Colors.red,
            size: 20,
          ),
          const SizedBox(width: 8),
          Text(
            isValid ? 'Duration: $durationText' : 'Invalid time range',
            style: TextStyle(
              color: isValid ? Colors.green.shade700 : Colors.red.shade700,
              fontWeight: FontWeight.w500,
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
              onPressed: () => Get.back(),
              type: AppButtonType.outline,
              icon: Icons.close,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: AppButton(
              text: isEditMode ? 'Update' : 'Save',
              onPressed: isLoading ? null : _saveTimeSlot,
              isLoading: isLoading,
              icon: isEditMode ? Icons.update : Icons.save,
            ),
          ),
        ],
      );
    });
  }

  Future<void> _selectTime(BuildContext context, bool isStartTime) async {
    final TimeOfDay initialTime = isStartTime ? _startTime : _endTime;

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
        if (isStartTime) {
          _startTime = pickedTime;
        } else {
          _endTime = pickedTime;
        }
      });
    }
  }

  // Get the schedule date from the operating schedule
  DateTime _getScheduleDate() {
    final schedule = _scheduleController.schedulesList.firstWhere(
      (schedule) => schedule.id == widget.operatingScheduleId,
      orElse: () => throw Exception('Operating schedule not found'),
    );
    return schedule.date;
  }

  // Create DateTime objects from TimeOfDay values
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

    // Handle next day end time
    if (endDateTime.isBefore(startDateTime)) {
      // Add a day to the end time
      endDateTime = endDateTime.add(const Duration(days: 1));
    }

    return [startDateTime, endDateTime];
  }

  bool _validateTimeRange() {
    // Calculate duration in minutes
    final int startMinutes = _startTime.hour * 60 + _startTime.minute;
    final int endMinutes = _endTime.hour * 60 + _endTime.minute;
    int durationMinutes = endMinutes - startMinutes;

    // Handle cases where end time is on the next day
    if (durationMinutes < 0) {
      durationMinutes += 24 * 60; // Add a full day worth of minutes
    }

    if (durationMinutes <= 0) {
      Get.snackbar(
        'Invalid Time Range',
        'End time must be after start time',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.shade100,
        colorText: Colors.red.shade900,
        margin: const EdgeInsets.all(16),
      );
      return false;
    }

    // Check for overlapping time slots if creating a new slot
    if (!isEditMode) {
      // Create a temporary time slot for overlap check
      final dateTimeValues = _createDateTimeValues();
      final tempTimeSlot = TimeSlot(
        id: 'temp',
        operatingScheduleId: widget.operatingScheduleId,
        startTime: dateTimeValues[0],
        endTime: dateTimeValues[1],
        // Add the required parameters
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        sessions: const [], // Empty sessions list
      );

      // Get current time slots for this schedule
      final currentSlots =
          _timeSlotController.timeSlots
              .where(
                (slot) =>
                    slot.operatingScheduleId == widget.operatingScheduleId,
              )
              .toList();

      // Skip overlap check for back-to-back slots
      bool isBackToBack = false;
      for (var slot in currentSlots) {
        // Check if this slot ends exactly when our new slot starts
        if (slot.endTime.isAtSameMomentAs(tempTimeSlot.startTime)) {
          isBackToBack = true;
          break;
        }
        // Check if our new slot ends exactly when another slot starts
        if (tempTimeSlot.endTime.isAtSameMomentAs(slot.startTime)) {
          isBackToBack = true;
          break;
        }
      }

      // Only check for overlaps if it's not a back-to-back slot situation
      if (!isBackToBack) {
        // Add our temporary slot and check for overlaps
        final allSlots = [...currentSlots, tempTimeSlot];
        if (_timeSlotController.hasOverlap(allSlots)) {
          Get.snackbar(
            'Time Slot Overlap',
            'This time slot overlaps with an existing one',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.red.shade100,
            colorText: Colors.red.shade900,
            margin: const EdgeInsets.all(16),
          );
          return false;
        }
      }
    }

    return true;
  }

  // Validate the time selection

  Future<void> _saveTimeSlot() async {
    // Clear any previous error messages
    _timeSlotController.clearErrors();

    // Validate time range
    if (!_validateTimeRange()) {
      return;
    }

    // Get the date-time values
    final dateTimeValues = _createDateTimeValues();
    final startDateTime = dateTimeValues[0];
    final endDateTime = dateTimeValues[1];

    // Create or update the time slot
    if (isEditMode) {
      final result = await _timeSlotController.updateTimeSlot(
        id: widget.timeSlot!.id,
        startTime: startDateTime,
        endTime: endDateTime,
      );

      if (result != null) {
        Get.back(); // Close the dialog
        Get.snackbar(
          'Success',
          'Time slot updated successfully',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green.shade100,
          colorText: Colors.green.shade900,
          margin: const EdgeInsets.all(16),
        );
      }
    } else {
      // Create new time slot
      final result = await _timeSlotController.createTimeSlot(
        operatingScheduleId: widget.operatingScheduleId,
        startTime: startDateTime,
        endTime: endDateTime,
      );

      if (result != null) {
        Get.back(); // Close the dialog
        Get.snackbar(
          'Success',
          'Time slot created successfully',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green.shade100,
          colorText: Colors.green.shade900,
          margin: const EdgeInsets.all(16),
        );
      }
    }

    // If there's an error message from the controller, it will be shown in the dialog
  }
}
