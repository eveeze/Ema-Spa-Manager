// lib/features/time_slot/widgets/time_slot_dialog.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:emababyspa/common/theme/app_theme.dart';
import 'package:emababyspa/common/theme/semantic_colors.dart';
import 'package:emababyspa/common/widgets/app_button.dart';
import 'package:emababyspa/features/time_slot/controllers/time_slot_controller.dart';
import 'package:emababyspa/features/operating_schedule/controllers/operating_schedule_controller.dart';
import 'package:emababyspa/data/models/time_slot.dart';
import 'package:emababyspa/data/models/operating_schedule.dart';
import 'package:emababyspa/common/utils/date_utils.dart' as app_date_utils;
import 'package:emababyspa/features/theme/controllers/theme_controller.dart';

class TimeSlotDialog extends StatefulWidget {
  final String operatingScheduleId;
  final TimeSlot? timeSlot; // edit mode

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
  final ThemeController _themeController = Get.find<ThemeController>();

  late TimeOfDay _startTime;
  late TimeOfDay _endTime;

  bool get isEditMode => widget.timeSlot != null;

  @override
  void initState() {
    super.initState();
    _timeSlotController.clearErrors();

    if (isEditMode && widget.timeSlot != null) {
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
      _startTime = const TimeOfDay(hour: 8, minute: 0);
      _endTime = const TimeOfDay(hour: 9, minute: 0);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final spacing = theme.extension<AppSpacing>() ?? const AppSpacing();

    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadii.xl),
      ),
      elevation: theme.dialogTheme.elevation ?? 8,
      backgroundColor: theme.colorScheme.surface.withValues(alpha: 0),
      insetPadding: EdgeInsets.all(spacing.lg),
      child: _buildDialogContent(context),
    );
  }

  Widget _buildDialogContent(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;
    final spacing = theme.extension<AppSpacing>() ?? const AppSpacing();

    final outlineSoft = colorScheme.outlineVariant.withValues(alpha: 0.70);

    return Container(
      padding: EdgeInsets.all(spacing.lg),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(AppRadii.xl),
        border: Border.all(color: outlineSoft),
        boxShadow: [
          BoxShadow(
            color: colorScheme.shadow.withValues(alpha: 0.12),
            blurRadius: spacing.xl,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildHeader(context),
            SizedBox(height: spacing.lg),
            _buildTimeSelectors(context),
            SizedBox(height: spacing.md),
            _buildActionButtons(),
            Obx(() {
              final msg = _timeSlotController.errorMessage.value;
              if (msg.isEmpty) return const SizedBox.shrink();

              return Padding(
                padding: EdgeInsets.only(top: spacing.md),
                child: Container(
                  width: double.infinity,
                  padding: EdgeInsets.symmetric(
                    vertical: spacing.sm,
                    horizontal: spacing.md,
                  ),
                  decoration: BoxDecoration(
                    color: colorScheme.errorContainer.withValues(alpha: 0.70),
                    borderRadius: BorderRadius.circular(AppRadii.lg),
                    border: Border.all(
                      color: colorScheme.error.withValues(alpha: 0.18),
                    ),
                  ),
                  child: Text(
                    msg,
                    textAlign: TextAlign.center,
                    style: textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onErrorContainer,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;
    final spacing = theme.extension<AppSpacing>() ?? const AppSpacing();

    return Column(
      children: [
        Container(
          height: 72,
          width: 72,
          decoration: BoxDecoration(
            color: colorScheme.primaryContainer.withValues(alpha: 0.70),
            borderRadius: BorderRadius.circular(AppRadii.xl),
            border: Border.all(
              color: colorScheme.primary.withValues(alpha: 0.14),
            ),
          ),
          child: Icon(
            Icons.access_time_filled_rounded,
            size: 36,
            color: colorScheme.onPrimaryContainer,
          ),
        ),
        SizedBox(height: spacing.md),
        Text(
          isEditMode ? 'Ubah Slot Waktu' : 'Tambah Slot Waktu',
          textAlign: TextAlign.center,
          style: textTheme.headlineSmall?.copyWith(
            color: colorScheme.onSurface,
            fontWeight: FontWeight.w900,
          ),
        ),
        SizedBox(height: spacing.xs),
        Text(
          isEditMode
              ? 'Perbarui jam mulai dan jam selesai untuk slot ini.'
              : 'Atur jam mulai dan jam selesai untuk slot baru.',
          textAlign: TextAlign.center,
          style: textTheme.bodyMedium?.copyWith(
            color: colorScheme.onSurfaceVariant,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildTimeSelectors(BuildContext context) {
    final theme = Theme.of(context);
    final spacing = theme.extension<AppSpacing>() ?? const AppSpacing();

    return Column(
      children: [
        _buildTimeSelectorField(
          context: context,
          label: 'Jam Mulai',
          icon: Icons.schedule_rounded,
          time: _startTime,
          onTap: () => _selectTime(context, true),
        ),
        SizedBox(height: spacing.md),
        _buildTimeSelectorField(
          context: context,
          label: 'Jam Selesai',
          icon: Icons.update_rounded,
          time: _endTime,
          onTap: () => _selectTime(context, false),
        ),
        SizedBox(height: spacing.sm),
        _buildDurationDisplay(context),
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
    final textTheme = theme.textTheme;
    final spacing = theme.extension<AppSpacing>() ?? const AppSpacing();

    final DateTime tempDateTime = DateTime(2000, 1, 1, time.hour, time.minute);
    final String timeString = app_date_utils.DateUtils.formatTime(tempDateTime);

    final outlineSoft = colorScheme.outlineVariant.withValues(alpha: 0.70);
    final fieldBg =
        _themeController.isDarkMode
            ? colorScheme.surfaceContainerHighest.withValues(alpha: 0.35)
            : colorScheme.surfaceContainerHighest.withValues(alpha: 0.55);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadii.lg),
        child: Ink(
          padding: EdgeInsets.symmetric(
            horizontal: spacing.md,
            vertical: spacing.sm,
          ),
          decoration: BoxDecoration(
            color: fieldBg,
            borderRadius: BorderRadius.circular(AppRadii.lg),
            border: Border.all(color: outlineSoft),
          ),
          child: Row(
            children: [
              Container(
                height: 40,
                width: 40,
                decoration: BoxDecoration(
                  color: colorScheme.primaryContainer.withValues(alpha: 0.65),
                  borderRadius: BorderRadius.circular(AppRadii.md),
                  border: Border.all(
                    color: colorScheme.primary.withValues(alpha: 0.14),
                  ),
                ),
                child: Icon(
                  icon,
                  color: colorScheme.onPrimaryContainer,
                  size: 20,
                ),
              ),
              SizedBox(width: spacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    SizedBox(height: spacing.xxs),
                    Text(
                      timeString,
                      style: textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w900,
                        color: colorScheme.onSurface,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_drop_down_rounded,
                color: colorScheme.onSurfaceVariant,
                size: spacing.xl,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDurationDisplay(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;
    final spacing = theme.extension<AppSpacing>() ?? const AppSpacing();
    final semantic = theme.extension<AppSemanticColors>();

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

    final successColor = semantic?.success ?? colorScheme.tertiary;

    final Color backgroundColor =
        isValid
            ? successColor.withValues(alpha: 0.10)
            : colorScheme.errorContainer.withValues(alpha: 0.70);
    final Color borderColor =
        isValid
            ? successColor.withValues(alpha: 0.30)
            : colorScheme.error.withValues(alpha: 0.22);
    final Color contentColor =
        isValid ? successColor : colorScheme.onErrorContainer;

    final IconData icon =
        isValid ? Icons.timer_outlined : Icons.error_outline_rounded;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        vertical: spacing.sm,
        horizontal: spacing.md,
      ),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(AppRadii.lg),
        border: Border.all(color: borderColor),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: contentColor, size: 18),
          SizedBox(width: spacing.sm),
          Flexible(
            child: Text(
              isValid
                  ? 'Durasi: $durationText'
                  : 'Jam selesai harus setelah jam mulai.',
              textAlign: TextAlign.center,
              style: textTheme.bodySmall?.copyWith(
                color: contentColor,
                fontWeight: FontWeight.w800,
              ),
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
              text: 'Batal',
              onPressed: isLoading ? null : () => Get.back(),
              type: AppButtonType.outline,
              icon: Icons.close_rounded,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: AppButton(
              text: isEditMode ? 'Perbarui' : 'Simpan',
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
        return Theme(data: Theme.of(context), child: child!);
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

  // ====== LOGIC (DO NOT CHANGE) ======

  DateTime _getScheduleDate() {
    final OperatingSchedule? schedule = _scheduleController.schedulesList
        .firstWhereOrNull((s) => s.id == widget.operatingScheduleId);
    if (schedule == null) {
      _timeSlotController.errorMessage.value =
          'Jadwal operasional tidak ditemukan. Menggunakan tanggal hari ini.';
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
      final theme = Theme.of(Get.context!);
      final colorScheme = theme.colorScheme;
      final semantic = theme.extension<AppSemanticColors>();
      final successColor = semantic?.success ?? colorScheme.tertiary;

      Get.back();
      Get.snackbar(
        'Berhasil',
        isEditMode
            ? 'Slot waktu berhasil diperbarui.'
            : 'Slot waktu berhasil dibuat.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: successColor.withValues(alpha: 0.14),
        colorText: colorScheme.onSurface,
        margin: const EdgeInsets.all(12),
        borderRadius: 8,
        icon: Icon(Icons.check_circle, color: successColor),
      );
    }
  }
}
