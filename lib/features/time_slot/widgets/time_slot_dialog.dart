// lib/features/time_slot/widgets/time_slot_dialog.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:emababyspa/common/theme/color_theme.dart';
import 'package:emababyspa/common/widgets/app_button.dart';
import 'package:emababyspa/features/time_slot/controllers/time_slot_controller.dart';
import 'package:emababyspa/features/operating_schedule/controllers/operating_schedule_controller.dart';
import 'package:emababyspa/common/utils/date_utils.dart' as app_date_utils;

class TimeSlotDialog extends StatefulWidget {
  final String operatingScheduleId;

  const TimeSlotDialog({super.key, required this.operatingScheduleId});

  @override
  State<TimeSlotDialog> createState() => _TimeSlotDialogState();
}

class _TimeSlotDialogState extends State<TimeSlotDialog> {
  final TimeSlotController _timeSlotController = Get.find<TimeSlotController>();

  // Default time values
  TimeOfDay _startTime = TimeOfDay(hour: 8, minute: 0);
  TimeOfDay _endTime = TimeOfDay(hour: 9, minute: 0);

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
            color: Colors.black.withValues(alpha: 0.1),
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
            color: ColorTheme.primary.withValues(alpha: 0.1),
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
          'Add New Time Slot',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: ColorTheme.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Set the start and end time for the new slot',
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
    return Obx(
      () => Row(
        children: [
          Expanded(
            child: AppButton(
              text: 'Cancel',
              onPressed: () => Get.back(),
              type: AppButtonType.primary,
              icon: Icons.close,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: AppButton(
              text: 'Save',
              onPressed:
                  _timeSlotController.isCreating.value ? null : _saveTimeSlot,
              isLoading: _timeSlotController.isCreating.value,
              icon: Icons.save,
            ),
          ),
        ],
      ),
    );
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

  Future<void> _saveTimeSlot() async {
    // Validate time range using the same calculation as in _buildDurationDisplay
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
      return;
    }

    // Get the operating schedule to extract its date
    final operatingScheduleController = Get.find<OperatingScheduleController>();
    final schedule = operatingScheduleController.schedulesList.firstWhere(
      (schedule) => schedule.id == widget.operatingScheduleId,
    );

    // Use the schedule's date for our time slot
    final DateTime scheduleDate = schedule.date;
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
      endDateTime = app_date_utils.DateUtils.addDays(endDateTime, 1);
    }

    // Create the time slot
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
    } else {
      Get.snackbar(
        'Error',
        _timeSlotController.errorMessage.value.isNotEmpty
            ? _timeSlotController.errorMessage.value
            : 'Failed to create time slot',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.shade100,
        colorText: Colors.red.shade900,
        margin: const EdgeInsets.all(16),
      );
    }
  }
}
