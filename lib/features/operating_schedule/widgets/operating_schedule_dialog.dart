// lib/features/operating_scheudle/widgets/operating_schedule_dialog.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:emababyspa/common/theme/app_theme.dart';
import 'package:emababyspa/common/widgets/app_button.dart';
import 'package:emababyspa/features/operating_schedule/controllers/operating_schedule_controller.dart';

class OperatingScheduleDialog extends StatefulWidget {
  final DateTime selectedDate;

  const OperatingScheduleDialog({super.key, required this.selectedDate});

  @override
  State<OperatingScheduleDialog> createState() =>
      _OperatingScheduleDialogState();
}

class _OperatingScheduleDialogState extends State<OperatingScheduleDialog> {
  final _formKey = GlobalKey<FormState>();
  final _notesController = TextEditingController();
  bool _isHoliday = false;

  late final OperatingScheduleController _controller;

  @override
  void initState() {
    super.initState();
    _controller = Get.find<OperatingScheduleController>();
  }

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  String _formatDateIndonesian(DateTime date) {
    final List<String> dayNames = [
      'Senin',
      'Selasa',
      'Rabu',
      'Kamis',
      'Jumat',
      'Sabtu',
      'Minggu',
    ];
    final List<String> monthNames = [
      'Januari',
      'Februari',
      'Maret',
      'April',
      'Mei',
      'Juni',
      'Juli',
      'Agustus',
      'September',
      'Oktober',
      'November',
      'Desember',
    ];
    final dayName = dayNames[date.weekday - 1];
    final monthName = monthNames[date.month - 1];
    return '$dayName, ${date.day} $monthName ${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final spacing = theme.extension<AppSpacing>() ?? const AppSpacing();

    return Dialog(
      shape: theme.dialogTheme.shape,
      elevation: theme.dialogTheme.elevation ?? 8,
      backgroundColor: theme.dialogTheme.backgroundColor,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 440),
        child: Padding(
          padding: EdgeInsets.all(spacing.lg),
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(context),
                SizedBox(height: spacing.lg),
                _buildForm(context),
                SizedBox(height: spacing.lg),
                _buildActionButtons(context),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;
    final spacing = theme.extension<AppSpacing>() ?? const AppSpacing();

    final outlineSoft = colorScheme.outlineVariant.withValues(alpha: 0.70);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 44,
              width: 44,
              decoration: BoxDecoration(
                color: colorScheme.primaryContainer.withValues(alpha: 0.70),
                borderRadius: BorderRadius.circular(AppRadii.md),
                border: Border.all(
                  color: colorScheme.primary.withValues(alpha: 0.12),
                ),
              ),
              child: Icon(
                Icons.event_note_rounded,
                color: colorScheme.onPrimaryContainer,
                size: 22,
              ),
            ),
            SizedBox(width: spacing.sm),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Buat Hari Operasional',
                    style: textTheme.titleLarge?.copyWith(
                      color: colorScheme.onSurface,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  SizedBox(height: spacing.xxs),
                  Text(
                    _formatDateIndonesian(widget.selectedDate),
                    style: textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            IconButton(
              onPressed: () => Navigator.of(context).pop(),
              tooltip: 'Tutup',
              icon: Icon(
                Icons.close_rounded,
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
        SizedBox(height: spacing.md),
        Divider(height: 1, color: outlineSoft),
      ],
    );
  }

  Widget _buildForm(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final colorScheme = theme.colorScheme;
    final spacing = theme.extension<AppSpacing>() ?? const AppSpacing();

    final outlineSoft = colorScheme.outlineVariant.withValues(alpha: 0.70);

    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Tipe Hari',
            style: textTheme.titleMedium?.copyWith(
              color: colorScheme.onSurface,
              fontWeight: FontWeight.w900,
            ),
          ),
          SizedBox(height: spacing.sm),
          Container(
            decoration: BoxDecoration(
              color: colorScheme.surface,
              borderRadius: BorderRadius.circular(AppRadii.lg),
              border: Border.all(color: outlineSoft),
            ),
            clipBehavior: Clip.antiAlias,
            child: Column(
              children: [
                _buildScheduleTypeOption(
                  context: context,
                  title: 'Hari Buka',
                  subtitle: 'Spa beroperasi seperti biasa.',
                  icon: Icons.event_available_rounded,
                  isSelected: !_isHoliday,
                  onTap: () => setState(() => _isHoliday = false),
                  color: colorScheme.primary,
                ),
                Divider(height: 1, color: outlineSoft),
                _buildScheduleTypeOption(
                  context: context,
                  title: 'Hari Libur',
                  subtitle: 'Spa tutup atau tidak menerima sesi.',
                  icon: Icons.event_busy_rounded,
                  isSelected: _isHoliday,
                  onTap: () => setState(() => _isHoliday = true),
                  color: colorScheme.error,
                ),
              ],
            ),
          ),
          SizedBox(height: spacing.lg),
          Text(
            'Catatan',
            style: textTheme.titleMedium?.copyWith(
              color: colorScheme.onSurface,
              fontWeight: FontWeight.w900,
            ),
          ),
          SizedBox(height: spacing.xs),
          Text(
            'Opsional — isi alasan atau info penting untuk hari ini.',
            style: textTheme.bodySmall?.copyWith(
              color: colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: spacing.sm),
          TextFormField(
            controller: _notesController,
            maxLines: 3,
            decoration: InputDecoration(
              hintText:
                  _isHoliday
                      ? 'Contoh: Libur nasional / acara keluarga'
                      : 'Contoh: Operasional normal, tim lengkap',
              prefixIcon: const Icon(Icons.sticky_note_2_outlined),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScheduleTypeOption({
    required BuildContext context,
    required String title,
    required String subtitle,
    required IconData icon,
    required bool isSelected,
    required VoidCallback onTap,
    required Color color,
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;
    final spacing = theme.extension<AppSpacing>() ?? const AppSpacing();

    final outlineSoft = colorScheme.outlineVariant.withValues(alpha: 0.70);
    final iconBg = colorScheme.surfaceContainerHighest;
    final unselectedIcon = colorScheme.onSurfaceVariant;

    return Material(
      color: isSelected ? color.withValues(alpha: 0.06) : Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: EdgeInsets.all(spacing.md),
          child: Row(
            children: [
              // Radio-like indicator
              Container(
                width: 20,
                height: 20,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isSelected ? color : outlineSoft,
                    width: 2,
                  ),
                ),
                child:
                    isSelected
                        ? Center(
                          child: Container(
                            width: 10,
                            height: 10,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: color,
                            ),
                          ),
                        )
                        : null,
              ),
              SizedBox(width: spacing.md),
              // Icon chip
              Container(
                height: 36,
                width: 36,
                decoration: BoxDecoration(
                  color:
                      isSelected
                          ? color.withValues(alpha: 0.10)
                          : iconBg.withValues(alpha: 0.70),
                  borderRadius: BorderRadius.circular(AppRadii.md),
                  border: Border.all(
                    color:
                        isSelected
                            ? color.withValues(alpha: 0.18)
                            : outlineSoft,
                  ),
                ),
                child: Icon(
                  icon,
                  size: 20,
                  color: isSelected ? color : unselectedIcon,
                ),
              ),
              SizedBox(width: spacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w900,
                        color: isSelected ? color : colorScheme.onSurface,
                      ),
                    ),
                    SizedBox(height: spacing.xxs),
                    Text(
                      subtitle,
                      style: textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(width: spacing.sm),
              // Subtle check
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 180),
                child:
                    isSelected
                        ? Icon(
                          Icons.check_circle_rounded,
                          key: const ValueKey('selected'),
                          color: color,
                        )
                        : Icon(
                          Icons.radio_button_unchecked_rounded,
                          key: const ValueKey('unselected'),
                          color: colorScheme.onSurfaceVariant.withValues(
                            alpha: 0.55,
                          ),
                        ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    final theme = Theme.of(context);
    final spacing = theme.extension<AppSpacing>() ?? const AppSpacing();

    return Obx(() {
      final isLoading = _controller.isFormSubmitting.value;

      return Row(
        children: [
          Expanded(
            child: OutlinedButton(
              onPressed: isLoading ? null : () => Navigator.of(context).pop(),
              child: const Text('Batal'),
            ),
          ),
          SizedBox(width: spacing.sm),
          Expanded(
            child: AppButton(
              text: 'Simpan',
              icon: isLoading ? null : Icons.check_rounded,
              onPressed: isLoading ? null : _submitForm,
              isLoading: isLoading,
            ),
          ),
        ],
      );
    });
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState?.validate() ?? false) {
      final formattedDate = DateFormat(
        'yyyy-MM-dd',
      ).format(widget.selectedDate);
      final notes = _notesController.text.trim();
      final notesToSend = notes.isEmpty ? null : notes;

      final success = await _controller.addOperatingSchedule(
        date: formattedDate,
        isHoliday: _isHoliday,
        notes: notesToSend,
      );

      if (success && mounted) {
        Navigator.of(context).pop();
      }
    }
  }
}
