// lib/features/time_slot/views/time_slot_edit_view.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:emababyspa/common/theme/color_theme.dart';
import 'package:emababyspa/common/layouts/main_layout.dart';
import 'package:emababyspa/common/widgets/app_button.dart';
import 'package:emababyspa/features/time_slot/controllers/time_slot_controller.dart';
import 'package:emababyspa/data/models/time_slot.dart';
import 'package:emababyspa/utils/timezone_utils.dart';

class TimeSlotEditView extends GetView<TimeSlotController> {
  const TimeSlotEditView({super.key});

  @override
  Widget build(BuildContext context) {
    // Get the time slot from arguments
    final args = Get.arguments as Map<String, dynamic>;
    final TimeSlot timeSlot = args['timeSlot'];

    // Form key for validation
    final formKey = GlobalKey<FormState>();

    // Controllers for form fields
    final startDateController = TextEditingController();
    final endDateController = TextEditingController();
    final startTimeController = TextEditingController();
    final endTimeController = TextEditingController();

    // Observable variables for date/time selection
    final selectedStartDate = Rx<DateTime?>(null);
    final selectedEndDate = Rx<DateTime?>(null);
    final selectedStartTime = Rx<TimeOfDay?>(null);
    final selectedEndTime = Rx<TimeOfDay?>(null);

    // Initialize form with existing data
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeForm(
        timeSlot,
        startDateController,
        endDateController,
        startTimeController,
        endTimeController,
        selectedStartDate,
        selectedEndDate,
        selectedStartTime,
        selectedEndTime,
      );
    });

    return MainLayout(
      child: Scaffold(
        appBar: _buildAppBar(context),
        body: _buildBody(
          context,
          formKey,
          timeSlot,
          startDateController,
          endDateController,
          startTimeController,
          endTimeController,
          selectedStartDate,
          selectedEndDate,
          selectedStartTime,
          selectedEndTime,
        ),
      ),
    );
  }

  // Initialize form with existing time slot data, using Indonesia time
  void _initializeForm(
    TimeSlot timeSlot,
    TextEditingController startDateController,
    TextEditingController endDateController,
    TextEditingController startTimeController,
    TextEditingController endTimeController,
    Rx<DateTime?> selectedStartDate,
    Rx<DateTime?> selectedEndDate,
    Rx<TimeOfDay?> selectedStartTime,
    Rx<TimeOfDay?> selectedEndTime,
  ) {
    // Convert UTC times to Indonesia time
    final startTimeIndonesia = TimeZoneUtil.toIndonesiaTime(timeSlot.startTime);
    final endTimeIndonesia = TimeZoneUtil.toIndonesiaTime(timeSlot.endTime);

    // Set start date and time
    selectedStartDate.value = startTimeIndonesia;
    selectedStartTime.value = TimeOfDay(
      hour: startTimeIndonesia.hour,
      minute: startTimeIndonesia.minute,
    );
    startDateController.text = DateFormat(
      'dd/MM/yyyy',
    ).format(startTimeIndonesia);
    startTimeController.text = DateFormat('HH:mm').format(startTimeIndonesia);

    // Set end date and time
    selectedEndDate.value = endTimeIndonesia;
    selectedEndTime.value = TimeOfDay(
      hour: endTimeIndonesia.hour,
      minute: endTimeIndonesia.minute,
    );
    endDateController.text = DateFormat('dd/MM/yyyy').format(endTimeIndonesia);
    endTimeController.text = DateFormat('HH:mm').format(endTimeIndonesia);
  }

  // Build app bar
  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      title: Text(
        'Edit Time Slot',
        style: TextStyle(
          color: ColorTheme.textPrimary,
          fontWeight: FontWeight.bold,
        ),
      ),
      backgroundColor: Colors.white,
      elevation: 0,
      iconTheme: IconThemeData(color: ColorTheme.primary),
    );
  }

  // Build main body
  Widget _buildBody(
    BuildContext context,
    GlobalKey<FormState> formKey,
    TimeSlot timeSlot,
    TextEditingController startDateController,
    TextEditingController endDateController,
    TextEditingController startTimeController,
    TextEditingController endTimeController,
    Rx<DateTime?> selectedStartDate,
    Rx<DateTime?> selectedEndDate,
    Rx<TimeOfDay?> selectedStartTime,
    Rx<TimeOfDay?> selectedEndTime,
  ) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Colors.white, ColorTheme.primary.withValues(alpha: 0.05)],
        ),
      ),
      child: Form(
        key: formKey,
        child: ListView(
          padding: const EdgeInsets.all(16.0),
          children: [
            _buildInfoCard(timeSlot),
            const SizedBox(height: 24),
            _buildFormSection(
              context,
              startDateController,
              endDateController,
              startTimeController,
              endTimeController,
              selectedStartDate,
              selectedEndDate,
              selectedStartTime,
              selectedEndTime,
            ),
            const SizedBox(height: 32),
            _buildActionButtons(
              context,
              formKey,
              timeSlot,
              selectedStartDate,
              selectedEndDate,
              selectedStartTime,
              selectedEndTime,
            ),
          ],
        ),
      ),
    );
  }

  // Build info card showing current time slot details with Indonesia time
  Widget _buildInfoCard(TimeSlot timeSlot) {
    // Use TimeZoneUtil to format dates in Indonesia time
    final String currentDate = TimeZoneUtil.formatDate(
      timeSlot.startTime,
      format: 'EEEE, d MMMM yyyy',
    );

    final String currentTimeRange =
        '${TimeZoneUtil.formatIndonesiaTime(timeSlot.startTime)} - '
        '${TimeZoneUtil.formatIndonesiaTime(timeSlot.endTime)}';

    return Container(
      padding: const EdgeInsets.all(16),
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: ColorTheme.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.info_outline,
                  color: ColorTheme.primary,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Current Time Slot',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: ColorTheme.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      currentDate,
                      style: TextStyle(
                        fontSize: 14,
                        color: ColorTheme.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      currentTimeRange,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: ColorTheme.primary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Indonesia Time (GMT+7)',
                      style: TextStyle(
                        fontSize: 12,
                        fontStyle: FontStyle.italic,
                        color: ColorTheme.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Build form section
  Widget _buildFormSection(
    BuildContext context,
    TextEditingController startDateController,
    TextEditingController endDateController,
    TextEditingController startTimeController,
    TextEditingController endTimeController,
    Rx<DateTime?> selectedStartDate,
    Rx<DateTime?> selectedEndDate,
    Rx<TimeOfDay?> selectedStartTime,
    Rx<TimeOfDay?> selectedEndTime,
  ) {
    return Container(
      padding: const EdgeInsets.all(20),
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Edit Time Slot Details',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: ColorTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'All times are in Indonesia Time (GMT+7)',
            style: TextStyle(
              fontSize: 14,
              fontStyle: FontStyle.italic,
              color: ColorTheme.textSecondary,
            ),
          ),
          const SizedBox(height: 24),

          // Start Date and Time Section
          Text(
            'Start Date & Time',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: ColorTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                flex: 2,
                child: _buildDateField(
                  context,
                  'Start Date',
                  startDateController,
                  selectedStartDate,
                  Icons.calendar_today,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildTimeField(
                  context,
                  'Start Time',
                  startTimeController,
                  selectedStartTime,
                  selectedStartDate,
                  Icons.access_time,
                ),
              ),
            ],
          ),

          const SizedBox(height: 24),

          // End Date and Time Section
          Text(
            'End Date & Time',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: ColorTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                flex: 2,
                child: _buildDateField(
                  context,
                  'End Date',
                  endDateController,
                  selectedEndDate,
                  Icons.calendar_today,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildTimeField(
                  context,
                  'End Time',
                  endTimeController,
                  selectedEndTime,
                  selectedEndDate,
                  Icons.access_time,
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          // Validation message
          Obx(() {
            if (selectedStartDate.value != null &&
                selectedEndDate.value != null &&
                selectedStartTime.value != null &&
                selectedEndTime.value != null) {
              final startDateTime = DateTime(
                selectedStartDate.value!.year,
                selectedStartDate.value!.month,
                selectedStartDate.value!.day,
                selectedStartTime.value!.hour,
                selectedStartTime.value!.minute,
              );
              final endDateTime = DateTime(
                selectedEndDate.value!.year,
                selectedEndDate.value!.month,
                selectedEndDate.value!.day,
                selectedEndTime.value!.hour,
                selectedEndTime.value!.minute,
              );

              if (endDateTime.isBefore(startDateTime) ||
                  endDateTime.isAtSameMomentAs(startDateTime)) {
                return Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.red.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.red.shade200),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.error_outline,
                        color: Colors.red.shade700,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'End time must be after start time',
                          style: TextStyle(
                            color: Colors.red.shade700,
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }
            }
            return const SizedBox.shrink();
          }),
        ],
      ),
    );
  }

  // Build date field - Updated to use Indonesia time
  Widget _buildDateField(
    BuildContext context,
    String label,
    TextEditingController controller,
    Rx<DateTime?> selectedDate,
    IconData icon,
  ) {
    return TextFormField(
      controller: controller,
      readOnly: true,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: ColorTheme.primary),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: ColorTheme.primary, width: 2),
        ),
        filled: true,
        fillColor: Colors.grey.shade50,
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please select $label';
        }
        return null;
      },
      onTap: () async {
        // Use Indonesia time for initial date
        final indonesiaTimeNow = TimeZoneUtil.getNow();
        final initialDate = selectedDate.value ?? indonesiaTimeNow;

        final DateTime? pickedDate = await showDatePicker(
          context: context,
          initialDate: initialDate,
          firstDate: indonesiaTimeNow.subtract(const Duration(days: 365)),
          lastDate: indonesiaTimeNow.add(const Duration(days: 365)),
          builder: (context, child) {
            return Theme(
              data: Theme.of(context).copyWith(
                colorScheme: ColorScheme.light(
                  primary: ColorTheme.primary,
                  onPrimary: Colors.white,
                  surface: Colors.white,
                  onSurface: ColorTheme.textPrimary,
                ),
              ),
              child: child!,
            );
          },
        );

        if (pickedDate != null) {
          selectedDate.value = pickedDate;
          controller.text = DateFormat('dd/MM/yyyy').format(pickedDate);
        }
      },
    );
  }

  // Build time field - Updated to use Indonesia time
  Widget _buildTimeField(
    BuildContext context,
    String label,
    TextEditingController controller,
    Rx<TimeOfDay?> selectedTime,
    Rx<DateTime?> selectedDate,
    IconData icon,
  ) {
    return TextFormField(
      controller: controller,
      readOnly: true,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: ColorTheme.primary),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: ColorTheme.primary, width: 2),
        ),
        filled: true,
        fillColor: Colors.grey.shade50,
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please select $label';
        }
        return null;
      },
      onTap: () async {
        // Use Indonesia time for initial time
        final indonesiaTimeNow = TimeZoneUtil.getNow();
        final initialTime =
            selectedTime.value ??
            TimeOfDay(
              hour: indonesiaTimeNow.hour,
              minute: indonesiaTimeNow.minute,
            );

        final TimeOfDay? pickedTime = await showTimePicker(
          context: context,
          initialTime: initialTime,
          builder: (context, child) {
            return Theme(
              data: Theme.of(context).copyWith(
                colorScheme: ColorScheme.light(
                  primary: ColorTheme.primary,
                  onPrimary: Colors.white,
                  surface: Colors.white,
                  onSurface: ColorTheme.textPrimary,
                ),
              ),
              child: child!,
            );
          },
        );

        if (pickedTime != null) {
          selectedTime.value = pickedTime;
          controller.text =
              '${pickedTime.hour.toString().padLeft(2, '0')}:${pickedTime.minute.toString().padLeft(2, '0')}';
        }
      },
    );
  }

  // Build action buttons
  Widget _buildActionButtons(
    BuildContext context,
    GlobalKey<FormState> formKey,
    TimeSlot timeSlot,
    Rx<DateTime?> selectedStartDate,
    Rx<DateTime?> selectedEndDate,
    Rx<TimeOfDay?> selectedStartTime,
    Rx<TimeOfDay?> selectedEndTime,
  ) {
    return Column(
      children: [
        // Update button
        Obx(() {
          return AppButton(
            text: 'Update Time Slot',
            onPressed:
                controller.isUpdating.value
                    ? null
                    : () => _handleUpdate(
                      context,
                      formKey,
                      timeSlot,
                      selectedStartDate,
                      selectedEndDate,
                      selectedStartTime,
                      selectedEndTime,
                    ),
            isLoading: controller.isUpdating.value,
            icon: Icons.save,
          );
        }),

        const SizedBox(height: 12),

        // Cancel button
        OutlinedButton(
          onPressed: () => Get.back(),
          style: OutlinedButton.styleFrom(
            side: BorderSide(color: ColorTheme.primary),
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.cancel_outlined, color: ColorTheme.primary),
              const SizedBox(width: 8),
              Text(
                'Cancel',
                style: TextStyle(
                  color: ColorTheme.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // Handle update time slot - Modified to convert from Indonesia to UTC time
  Future<void> _handleUpdate(
    BuildContext context,
    GlobalKey<FormState> formKey,
    TimeSlot timeSlot,
    Rx<DateTime?> selectedStartDate,
    Rx<DateTime?> selectedEndDate,
    Rx<TimeOfDay?> selectedStartTime,
    Rx<TimeOfDay?> selectedEndTime,
  ) async {
    if (!formKey.currentState!.validate()) {
      return;
    }

    if (selectedStartDate.value == null ||
        selectedEndDate.value == null ||
        selectedStartTime.value == null ||
        selectedEndTime.value == null) {
      Get.snackbar(
        'Error',
        'Please select all date and time fields',
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    // Create DateTime objects in Indonesia time
    final startDateTimeIndonesia = DateTime(
      selectedStartDate.value!.year,
      selectedStartDate.value!.month,
      selectedStartDate.value!.day,
      selectedStartTime.value!.hour,
      selectedStartTime.value!.minute,
    );

    final endDateTimeIndonesia = DateTime(
      selectedEndDate.value!.year,
      selectedEndDate.value!.month,
      selectedEndDate.value!.day,
      selectedEndTime.value!.hour,
      selectedEndTime.value!.minute,
    );

    // Validate time range
    if (endDateTimeIndonesia.isBefore(startDateTimeIndonesia) ||
        endDateTimeIndonesia.isAtSameMomentAs(startDateTimeIndonesia)) {
      Get.snackbar(
        'Error',
        'End time must be after start time',
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    // Convert from Indonesia time to UTC
    final startDateTimeUTC = startDateTimeIndonesia.subtract(
      const Duration(hours: 7),
    );
    final endDateTimeUTC = endDateTimeIndonesia.subtract(
      const Duration(hours: 7),
    );

    // Convert the original time slot to Indonesia time for comparison
    final startTimeIndonesia = TimeZoneUtil.toIndonesiaTime(timeSlot.startTime);
    final endTimeIndonesia = TimeZoneUtil.toIndonesiaTime(timeSlot.endTime);

    // Check if there are any changes (comparing in Indonesia time)
    if (startDateTimeIndonesia.isAtSameMomentAs(startTimeIndonesia) &&
        endDateTimeIndonesia.isAtSameMomentAs(endTimeIndonesia)) {
      Get.snackbar(
        'No Changes',
        'No changes detected in the time slot',
        backgroundColor: Colors.orange,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    try {
      // Send UTC times to the controller
      final updatedTimeSlot = await controller.updateTimeSlot(
        id: timeSlot.id,
        startTime: startDateTimeUTC,
        endTime: endDateTimeUTC,
      );

      if (updatedTimeSlot != null) {
        Get.back(result: updatedTimeSlot);
        Get.snackbar(
          'Success',
          'Time slot updated successfully',
          backgroundColor: Colors.green,
          colorText: Colors.white,
          snackPosition: SnackPosition.BOTTOM,
        );
      } else {
        // Error message is handled by the controller
        final errorMessage = controller.errorMessage.value;
        if (errorMessage.isNotEmpty) {
          Get.snackbar(
            'Error',
            errorMessage,
            backgroundColor: Colors.red,
            colorText: Colors.white,
            snackPosition: SnackPosition.BOTTOM,
          );
        }
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to update time slot: $e',
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }
}
