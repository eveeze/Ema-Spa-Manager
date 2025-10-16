import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
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
    return Dialog(
      shape: Theme.of(context).dialogTheme.shape,
      elevation: Theme.of(context).dialogTheme.elevation ?? 8,
      backgroundColor: Theme.of(context).dialogTheme.backgroundColor,
      child: Container(
        constraints: const BoxConstraints(maxWidth: 400),
        padding: const EdgeInsets.all(24),
        child: SingleChildScrollView(
          // <--- Wrap with SingleChildScrollView
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(context),
              const SizedBox(height: 24),
              _buildForm(context),
              const SizedBox(height: 24),
              _buildActionButtons(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                Icons.event_note_rounded,
                color: colorScheme.primary,
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
                    style: textTheme.titleLarge?.copyWith(
                      color: colorScheme.onSurface,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _formatDateIndonesian(widget.selectedDate),
                    style: textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            IconButton(
              onPressed: () => Navigator.of(context).pop(),
              icon: Icon(
                Icons.close_rounded,
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        const Divider(),
      ],
    );
  }

  Widget _buildForm(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Tipe Jadwal',
            style: textTheme.titleMedium?.copyWith(
              color: colorScheme.onSurface,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          Card(
            margin: EdgeInsets.zero,
            clipBehavior: Clip.antiAlias,
            child: Column(
              children: [
                _buildScheduleTypeOption(
                  context: context,
                  title: 'Hari Buka',
                  subtitle: 'Spa buka dan beroperasi normal',
                  icon: Icons.event_available_rounded,
                  isSelected: !_isHoliday,
                  onTap: () => setState(() => _isHoliday = false),
                  color: colorScheme.primary,
                ),
                const Divider(height: 1),
                _buildScheduleTypeOption(
                  context: context,
                  title: 'Hari Libur',
                  subtitle: 'Spa tutup atau tidak beroperasi',
                  icon: Icons.event_busy_rounded,
                  isSelected: _isHoliday,
                  onTap: () => setState(() => _isHoliday = true),
                  color: colorScheme.error,
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'Catatan (Opsional)',
            style: textTheme.titleMedium?.copyWith(
              color: colorScheme.onSurface,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          TextFormField(
            controller: _notesController,
            maxLines: 3,
            decoration: InputDecoration(
              hintText:
                  _isHoliday
                      ? 'Contoh: Libur Nasional - Hari Raya Nyepi'
                      : 'Contoh: Operasional normal, staff lengkap',
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
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final unselectedColor = colorScheme.onSurfaceVariant;
    final unselectedBorderColor = colorScheme.outline;
    final unselectedIconBg = colorScheme.surfaceContainerHighest;

    return Material(
      color: isSelected ? color.withValues(alpha: 0.05) : Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 20,
                height: 20,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isSelected ? color : unselectedBorderColor,
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
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color:
                      isSelected
                          ? color.withValues(
                            alpha: 0.1,
                          ) // Changed .withValues to .withOpacity
                          : unselectedIconBg,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  icon,
                  color: isSelected ? color : unselectedColor,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: isSelected ? color : colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
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

  Widget _buildActionButtons(BuildContext context) {
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
          const SizedBox(width: 16),
          Expanded(
            child: AppButton(
              text: 'Buat Jadwal',
              icon: isLoading ? null : Icons.add_rounded,
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
