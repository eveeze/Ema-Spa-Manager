// lib/features/time_slot/views/time_slot_edit_view.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:emababyspa/common/layouts/main_layout.dart';
import 'package:emababyspa/common/widgets/app_button.dart';
import 'package:emababyspa/features/time_slot/controllers/time_slot_controller.dart';
import 'package:emababyspa/data/models/time_slot.dart';
import 'package:emababyspa/utils/timezone_utils.dart';
import 'package:emababyspa/features/theme/controllers/theme_controller.dart';
import 'package:emababyspa/common/theme/text_theme.dart';

class TimeSlotEditView extends GetView<TimeSlotController> {
  const TimeSlotEditView({super.key});

  @override
  Widget build(BuildContext context) {
    final args = Get.arguments as Map<String, dynamic>;
    final TimeSlot timeSlot = args['timeSlot'];
    final formKey = GlobalKey<FormState>();
    final startDateController = TextEditingController();
    final endDateController = TextEditingController();
    final startTimeController = TextEditingController();
    final endTimeController = TextEditingController();
    final selectedStartDate = Rx<DateTime?>(null);
    final selectedEndDate = Rx<DateTime?>(null);
    final selectedStartTime = Rx<TimeOfDay?>(null);
    final selectedEndTime = Rx<TimeOfDay?>(null);

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
    final startTimeIndonesia = TimeZoneUtil.toIndonesiaTime(timeSlot.startTime);
    final endTimeIndonesia = TimeZoneUtil.toIndonesiaTime(timeSlot.endTime);

    selectedStartDate.value = startTimeIndonesia;
    selectedStartTime.value = TimeOfDay(
      hour: startTimeIndonesia.hour,
      minute: startTimeIndonesia.minute,
    );
    startDateController.text = DateFormat(
      'dd/MM/yyyy',
    ).format(startTimeIndonesia);
    startTimeController.text = DateFormat('HH:mm').format(startTimeIndonesia);

    selectedEndDate.value = endTimeIndonesia;
    selectedEndTime.value = TimeOfDay(
      hour: endTimeIndonesia.hour,
      minute: endTimeIndonesia.minute,
    );
    endDateController.text = DateFormat('dd/MM/yyyy').format(endTimeIndonesia);
    endTimeController.text = DateFormat('HH:mm').format(endTimeIndonesia);
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    final theme = Theme.of(context);
    Get.find<ThemeController>();
    return AppBar(
      title: Text('Edit Time Slot', style: theme.appBarTheme.titleTextStyle),
      backgroundColor: theme.appBarTheme.backgroundColor,
      elevation: theme.appBarTheme.elevation,
      iconTheme: theme.appBarTheme.iconTheme,
    );
  }

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
    final theme = Theme.of(context);
    return Container(
      color: theme.scaffoldBackgroundColor,
      child: Form(
        key: formKey,
        child: ListView(
          padding: const EdgeInsets.all(16.0),
          children: [
            _buildInfoCard(context, timeSlot),
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

  Widget _buildInfoCard(BuildContext context, TimeSlot timeSlot) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final String currentDate = TimeZoneUtil.formatDate(
      timeSlot.startTime,
      format: 'EEEE, d MMMM yyyy',
    );
    final String currentTimeRange =
        '${TimeZoneUtil.formatIndonesiaTime(timeSlot.startTime)} - ${TimeZoneUtil.formatIndonesiaTime(timeSlot.endTime)}';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: theme.shadowColor.withValues(alpha: 0.1),
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
                  color: colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.info_outline,
                  color: colorScheme.primary,
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
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      currentDate,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      currentTimeRange,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w500,
                        color: colorScheme.primary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Indonesia Time (GMT+7)',
                      style: theme.textTheme.bodySmall?.copyWith(
                        fontStyle: FontStyle.italic,
                        color: colorScheme.onSurfaceVariant,
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
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    Get.find<ThemeController>();

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: theme.shadowColor.withValues(alpha: 0.1),
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Edit Time Slot Details', style: theme.textTheme.titleLarge),
          const SizedBox(height: 8),
          Text(
            'All times are in Indonesia Time (GMT+7)',
            style: theme.textTheme.bodySmall?.copyWith(
              fontStyle: FontStyle.italic,
              color: colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Start Date & Time',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
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
          Text(
            'End Date & Time',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
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
                    color: colorScheme.errorContainer.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: colorScheme.error),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.error_outline,
                        color: colorScheme.error,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'End time must be after start time',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: colorScheme.error,
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

  Widget _buildDateField(
    BuildContext context,
    String label,
    TextEditingController controller,
    Rx<DateTime?> selectedDate,
    IconData icon,
  ) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    return TextFormField(
      controller: controller,
      readOnly: true,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: colorScheme.primary),
        fillColor:
            theme.inputDecorationTheme.fillColor ??
            colorScheme.surfaceContainerHighest,
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please select $label';
        }
        return null;
      },
      onTap: () async {
        final indonesiaTimeNow = TimeZoneUtil.getNow();
        final initialDate = selectedDate.value ?? indonesiaTimeNow;

        final DateTime? pickedDate = await showDatePicker(
          context: context,
          initialDate: initialDate,
          firstDate: indonesiaTimeNow.subtract(const Duration(days: 365)),
          lastDate: indonesiaTimeNow.add(const Duration(days: 365)),
          builder: (context, child) {
            return Theme(data: theme, child: child!);
          },
        );

        if (pickedDate != null) {
          selectedDate.value = pickedDate;
          controller.text = DateFormat('dd/MM/yyyy').format(pickedDate);
        }
      },
    );
  }

  Widget _buildTimeField(
    BuildContext context,
    String label,
    TextEditingController controller,
    Rx<TimeOfDay?> selectedTime,
    Rx<DateTime?> selectedDate,
    IconData icon,
  ) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    return TextFormField(
      controller: controller,
      readOnly: true,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: colorScheme.primary),
        fillColor:
            theme.inputDecorationTheme.fillColor ??
            colorScheme.surfaceContainerHighest,
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please select $label';
        }
        return null;
      },
      onTap: () async {
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
            return Theme(data: theme, child: child!);
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

  Widget _buildActionButtons(
    BuildContext context,
    GlobalKey<FormState> formKey,
    TimeSlot timeSlot,
    Rx<DateTime?> selectedStartDate,
    Rx<DateTime?> selectedEndDate,
    Rx<TimeOfDay?> selectedStartTime,
    Rx<TimeOfDay?> selectedEndTime,
  ) {
    final theme = Theme.of(context);
    return Column(
      children: [
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
        OutlinedButton(
          onPressed: () => Get.back(),
          style: theme.outlinedButtonTheme.style,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.cancel_outlined, color: theme.colorScheme.primary),
              const SizedBox(width: 8),
              Text(
                'Cancel',
                style: SpecialTextStyles.buttonSecondary.copyWith(
                  color: theme.colorScheme.primary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

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

    final correctStartUTC = startDateTimeIndonesia.toUtc();
    final correctEndUTC = endDateTimeIndonesia.toUtc();

    final startTimeToSend = correctStartUTC.add(const Duration(hours: 7));
    final endTimeToSend = correctEndUTC.add(const Duration(hours: 7));

    final initialStartTimeIndonesia = TimeZoneUtil.toIndonesiaTime(
      timeSlot.startTime,
    );
    final initialEndTimeIndonesia = TimeZoneUtil.toIndonesiaTime(
      timeSlot.endTime,
    );

    if (startDateTimeIndonesia.isAtSameMomentAs(initialStartTimeIndonesia) &&
        endDateTimeIndonesia.isAtSameMomentAs(initialEndTimeIndonesia)) {
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
      final updatedTimeSlot = await controller.updateTimeSlot(
        id: timeSlot.id,
        startTime: startTimeToSend,
        endTime: endTimeToSend,
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
