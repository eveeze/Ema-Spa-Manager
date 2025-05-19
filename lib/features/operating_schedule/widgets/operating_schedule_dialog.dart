// lib/features/operating_schedule/widgets/operating_schedule_dialog.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:emababyspa/common/theme/color_theme.dart';
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
    // Manual formatting to avoid locale initialization issues
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
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      elevation: 8,
      child: Container(
        constraints: const BoxConstraints(maxWidth: 400),
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Colors.white, ColorTheme.primary.withValues(alpha: 0.02)],
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            const SizedBox(height: 24),
            _buildForm(),
            const SizedBox(height: 24),
            _buildActionButtons(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
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
                Icons.event_note_rounded,
                color: ColorTheme.primary,
                size: 28,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Buat Jadwal Operasional',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: ColorTheme.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _formatDateIndonesian(widget.selectedDate),
                    style: TextStyle(
                      fontSize: 14,
                      color: ColorTheme.textSecondary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            IconButton(
              onPressed: () => Navigator.of(context).pop(),
              icon: Icon(Icons.close_rounded, color: ColorTheme.textSecondary),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Container(
          width: double.infinity,
          height: 2,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                ColorTheme.primary.withValues(alpha: 0.3),
                ColorTheme.primary.withValues(alpha: 0.1),
                Colors.transparent,
              ],
            ),
            borderRadius: BorderRadius.circular(1),
          ),
        ),
      ],
    );
  }

  Widget _buildForm() {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Schedule Type Selection
          Text(
            'Tipe Jadwal',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: ColorTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: ColorTheme.primary.withValues(alpha: 0.2),
                width: 1.5,
              ),
            ),
            child: Column(
              children: [
                _buildScheduleTypeOption(
                  title: 'Hari Buka',
                  subtitle: 'Spa buka dan beroperasi normal',
                  icon: Icons.event_available_rounded,
                  isSelected: !_isHoliday,
                  onTap: () => setState(() => _isHoliday = false),
                  color: Colors.green,
                ),
                Divider(
                  height: 1,
                  color: ColorTheme.primary.withValues(alpha: 0.1),
                ),
                _buildScheduleTypeOption(
                  title: 'Hari Libur',
                  subtitle: 'Spa tutup atau tidak beroperasi',
                  icon: Icons.event_busy_rounded,
                  isSelected: _isHoliday,
                  onTap: () => setState(() => _isHoliday = true),
                  color: Colors.red,
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Notes Section
          Text(
            'Catatan (Opsional)',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: ColorTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: Colors.grey.withValues(alpha: 0.3),
                width: 1,
              ),
            ),
            child: TextFormField(
              controller: _notesController,
              maxLines: 3,
              decoration: InputDecoration(
                hintText:
                    _isHoliday
                        ? 'Contoh: Libur Nasional - Hari Raya Nyepi'
                        : 'Contoh: Operasional normal, staff lengkap',
                hintStyle: TextStyle(color: Colors.grey.shade500, fontSize: 14),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.all(16),
                prefixIcon: Padding(
                  padding: const EdgeInsets.only(left: 16, right: 12, top: 16),
                  child: Icon(
                    Icons.sticky_note_2_outlined,
                    color: Colors.grey.shade500,
                    size: 20,
                  ),
                ),
              ),
              style: const TextStyle(fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScheduleTypeOption({
    required String title,
    required String subtitle,
    required IconData icon,
    required bool isSelected,
    required VoidCallback onTap,
    required Color color,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(11),
        child: Container(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Radio button
              Container(
                width: 20,
                height: 20,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isSelected ? color : Colors.grey.shade400,
                    width: 2,
                  ),
                ),
                child:
                    isSelected
                        ? Container(
                          margin: const EdgeInsets.all(3),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: color,
                          ),
                        )
                        : null,
              ),
              const SizedBox(width: 16),

              // Icon
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color:
                      isSelected
                          ? color.withValues(alpha: 0.1)
                          : Colors.grey.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  icon,
                  color: isSelected ? color : Colors.grey.shade600,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),

              // Text content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: isSelected ? color : ColorTheme.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 12,
                        color: ColorTheme.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActionButtons() {
    return Obx(() {
      return Row(
        children: [
          Expanded(
            child: OutlinedButton(
              onPressed:
                  _controller.isFormSubmitting.value
                      ? null
                      : () => Navigator.of(context).pop(),
              style: OutlinedButton.styleFrom(
                side: BorderSide(color: ColorTheme.primary),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: Text(
                'Batal',
                style: TextStyle(
                  color: ColorTheme.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: AppButton(
              text: 'Buat Jadwal',
              icon:
                  _controller.isFormSubmitting.value ? null : Icons.add_rounded,
              onPressed:
                  _controller.isFormSubmitting.value ? null : _submitForm,
              isLoading: _controller.isFormSubmitting.value,
            ),
          ),
        ],
      );
    });
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState?.validate() ?? false) {
      // Format date for API
      final formattedDate = DateFormat(
        'yyyy-MM-dd',
      ).format(widget.selectedDate);

      // Get notes (trim and handle empty string)
      final notes = _notesController.text.trim();
      final notesToSend = notes.isEmpty ? null : notes;

      // Submit the form
      final success = await _controller.addOperatingSchedule(
        date: formattedDate,
        isHoliday: _isHoliday,
        notes: notesToSend,
      );

      // Close dialog if successful
      if (success && mounted) {
        Navigator.of(context).pop();
      }
    }
  }
}
