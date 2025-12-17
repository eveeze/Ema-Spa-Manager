// lib/features/time_slot/views/time_slot_edit_view.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import 'package:emababyspa/common/layouts/main_layout.dart';
import 'package:emababyspa/common/theme/app_theme.dart';
import 'package:emababyspa/common/theme/semantic_colors.dart';
import 'package:emababyspa/common/theme/text_theme.dart';
import 'package:emababyspa/common/widgets/app_button.dart';

import 'package:emababyspa/features/time_slot/controllers/time_slot_controller.dart';
import 'package:emababyspa/data/models/time_slot.dart';
import 'package:emababyspa/utils/timezone_utils.dart';
import 'package:emababyspa/features/theme/controllers/theme_controller.dart';

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
      title: Text('Ubah Slot Waktu', style: theme.appBarTheme.titleTextStyle),
      backgroundColor: theme.appBarTheme.backgroundColor,
      elevation: theme.appBarTheme.elevation,
      iconTheme: theme.appBarTheme.iconTheme,

      // ✅ Disable M3 "scroll under" color shift
      scrolledUnderElevation: 0,
      surfaceTintColor: Colors.transparent,
      shadowColor: Colors.transparent,
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
    final spacing = theme.extension<AppSpacing>() ?? const AppSpacing();

    return Container(
      color: theme.scaffoldBackgroundColor,
      child: Form(
        key: formKey,
        child: ListView(
          padding: EdgeInsets.all(spacing.md),
          children: [
            _buildInfoCard(context, timeSlot),
            SizedBox(height: spacing.lg),
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
            SizedBox(height: spacing.xl),
            _buildActionButtons(
              context,
              formKey,
              timeSlot,
              selectedStartDate,
              selectedEndDate,
              selectedStartTime,
              selectedEndTime,
            ),
            SizedBox(height: spacing.xxl),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard(BuildContext context, TimeSlot timeSlot) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;
    final spacing = theme.extension<AppSpacing>() ?? const AppSpacing();

    final String currentDate = TimeZoneUtil.formatDate(
      timeSlot.startTime,
      format: 'EEEE, d MMMM yyyy',
    );
    final String currentTimeRange =
        '${TimeZoneUtil.formatIndonesiaTime(timeSlot.startTime)} - ${TimeZoneUtil.formatIndonesiaTime(timeSlot.endTime)}';

    return Card(
      elevation: 0,
      color: colorScheme.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadii.xl),
        side: BorderSide(
          color: colorScheme.outlineVariant.withValues(alpha: 0.70),
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: Padding(
        padding: EdgeInsets.all(spacing.lg),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 48,
              width: 48,
              decoration: BoxDecoration(
                color: colorScheme.primaryContainer.withValues(alpha: 0.70),
                borderRadius: BorderRadius.circular(AppRadii.md),
                border: Border.all(
                  color: colorScheme.primary.withValues(alpha: 0.12),
                ),
              ),
              child: Icon(
                Icons.info_outline_rounded,
                color: colorScheme.onPrimaryContainer,
              ),
            ),
            SizedBox(width: spacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Slot Saat Ini',
                    style: textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w900,
                      color: colorScheme.onSurface,
                    ),
                  ),
                  SizedBox(height: spacing.xxs),
                  Text(
                    currentDate,
                    style: textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: spacing.xxs),
                  Text(
                    currentTimeRange,
                    style: textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w900,
                      color: colorScheme.primary,
                    ),
                  ),
                  SizedBox(height: spacing.xs),
                  Text(
                    'Waktu Indonesia (GMT+7)',
                    style: textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                      fontWeight: FontWeight.w600,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
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
    final textTheme = theme.textTheme;
    final spacing = theme.extension<AppSpacing>() ?? const AppSpacing();

    Get.find<ThemeController>();

    return Card(
      elevation: 0,
      color: colorScheme.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadii.xl),
        side: BorderSide(
          color: colorScheme.outlineVariant.withValues(alpha: 0.70),
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: Padding(
        padding: EdgeInsets.all(spacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Ubah Detail Slot Waktu',
              style: textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w900,
                color: colorScheme.onSurface,
              ),
            ),
            SizedBox(height: spacing.xs),
            Text(
              'Semua waktu menggunakan Waktu Indonesia (GMT+7).',
              style: textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurfaceVariant,
                fontWeight: FontWeight.w600,
                fontStyle: FontStyle.italic,
              ),
            ),
            SizedBox(height: spacing.lg),

            _buildSectionLabel(context, 'Waktu Mulai'),
            SizedBox(height: spacing.sm),
            Row(
              children: [
                Expanded(
                  flex: 2,
                  child: _buildDateField(
                    context,
                    'Tanggal Mulai',
                    startDateController,
                    selectedStartDate,
                    Icons.calendar_today_rounded,
                  ),
                ),
                SizedBox(width: spacing.sm),
                Expanded(
                  child: _buildTimeField(
                    context,
                    'Jam Mulai',
                    startTimeController,
                    selectedStartTime,
                    selectedStartDate,
                    Icons.access_time_rounded,
                  ),
                ),
              ],
            ),

            SizedBox(height: spacing.lg),

            _buildSectionLabel(context, 'Waktu Selesai'),
            SizedBox(height: spacing.sm),
            Row(
              children: [
                Expanded(
                  flex: 2,
                  child: _buildDateField(
                    context,
                    'Tanggal Selesai',
                    endDateController,
                    selectedEndDate,
                    Icons.calendar_today_rounded,
                  ),
                ),
                SizedBox(width: spacing.sm),
                Expanded(
                  child: _buildTimeField(
                    context,
                    'Jam Selesai',
                    endTimeController,
                    selectedEndTime,
                    selectedEndDate,
                    Icons.access_time_rounded,
                  ),
                ),
              ],
            ),

            SizedBox(height: spacing.md),

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
                  return _buildInlineAlert(
                    context,
                    icon: Icons.error_outline_rounded,
                    toneColor: colorScheme.error,
                    background: colorScheme.errorContainer.withValues(
                      alpha: 0.35,
                    ),
                    text: 'Waktu selesai harus setelah waktu mulai.',
                  );
                }
              }
              return const SizedBox.shrink();
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionLabel(BuildContext context, String text) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Text(
      text,
      style: theme.textTheme.titleMedium?.copyWith(
        fontWeight: FontWeight.w800,
        color: colorScheme.onSurface,
      ),
    );
  }

  Widget _buildInlineAlert(
    BuildContext context, {
    required IconData icon,
    required Color toneColor,
    required Color background,
    required String text,
  }) {
    final theme = Theme.of(context);
    final spacing = theme.extension<AppSpacing>() ?? const AppSpacing();

    return Container(
      margin: EdgeInsets.only(top: spacing.sm),
      padding: EdgeInsets.all(spacing.sm),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(AppRadii.md),
        border: Border.all(color: toneColor.withValues(alpha: 0.55)),
      ),
      child: Row(
        children: [
          Icon(icon, color: toneColor, size: 20),
          SizedBox(width: spacing.sm),
          Expanded(
            child: Text(
              text,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: toneColor,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
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
          return 'Silakan pilih $label';
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
          return 'Silakan pilih $label';
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
    final colorScheme = theme.colorScheme;
    final spacing = theme.extension<AppSpacing>() ?? const AppSpacing();

    return Column(
      children: [
        Obx(() {
          return AppButton(
            text: 'Simpan Perubahan',
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
            icon: Icons.save_rounded,
          );
        }),
        SizedBox(height: spacing.sm),
        OutlinedButton(
          onPressed: () => Get.back(),
          style: theme.outlinedButtonTheme.style,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.close_rounded, color: colorScheme.primary),
              SizedBox(width: spacing.sm),
              Text(
                'Batal',
                style: SpecialTextStyles.buttonSecondary.copyWith(
                  color: colorScheme.primary,
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
      final theme = Theme.of(context);
      final colorScheme = theme.colorScheme;
      Get.snackbar(
        'Gagal',
        'Silakan lengkapi semua kolom tanggal dan waktu.',
        backgroundColor: colorScheme.error.withValues(alpha: 0.14),
        colorText: theme.colorScheme.onSurface,
        snackPosition: SnackPosition.BOTTOM,
        icon: Icon(Icons.error_outline_rounded, color: colorScheme.error),
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
      final theme = Theme.of(context);
      final colorScheme = theme.colorScheme;
      Get.snackbar(
        'Gagal',
        'Waktu selesai harus setelah waktu mulai.',
        backgroundColor: colorScheme.error.withValues(alpha: 0.14),
        colorText: theme.colorScheme.onSurface,
        snackPosition: SnackPosition.BOTTOM,
        icon: Icon(Icons.error_outline_rounded, color: colorScheme.error),
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
      final theme = Theme.of(context);
      final colorScheme = theme.colorScheme;
      Get.snackbar(
        'Tidak Ada Perubahan',
        'Tidak ada perubahan pada slot waktu.',
        backgroundColor: colorScheme.secondary.withValues(alpha: 0.14),
        colorText: theme.colorScheme.onSurface,
        snackPosition: SnackPosition.BOTTOM,
        icon: Icon(Icons.info_outline_rounded, color: colorScheme.secondary),
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

        final theme = Theme.of(context);
        final colorScheme = theme.colorScheme;
        final semantic = theme.extension<AppSemanticColors>();
        final successColor = semantic?.success ?? colorScheme.tertiary;

        Get.snackbar(
          'Berhasil',
          'Slot waktu berhasil diperbarui.',
          backgroundColor: successColor.withValues(alpha: 0.14),
          colorText: theme.colorScheme.onSurface,
          snackPosition: SnackPosition.BOTTOM,
          icon: Icon(Icons.check_circle_rounded, color: successColor),
        );
      } else {
        final errorMessage = controller.errorMessage.value;
        if (errorMessage.isNotEmpty) {
          final theme = Theme.of(context);
          final colorScheme = theme.colorScheme;
          Get.snackbar(
            'Gagal',
            errorMessage,
            backgroundColor: colorScheme.error.withValues(alpha: 0.14),
            colorText: theme.colorScheme.onSurface,
            snackPosition: SnackPosition.BOTTOM,
            icon: Icon(Icons.error_outline_rounded, color: colorScheme.error),
          );
        }
      }
    } catch (e) {
      final theme = Theme.of(context);
      final colorScheme = theme.colorScheme;
      Get.snackbar(
        'Gagal',
        'Gagal memperbarui slot waktu: $e',
        backgroundColor: colorScheme.error.withValues(alpha: 0.14),
        colorText: theme.colorScheme.onSurface,
        snackPosition: SnackPosition.BOTTOM,
        icon: Icon(Icons.error_outline_rounded, color: colorScheme.error),
      );
    }
  }
}
