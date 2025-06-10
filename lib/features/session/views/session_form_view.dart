import 'package:emababyspa/common/layouts/main_layout.dart';
import 'package:emababyspa/common/theme/text_theme.dart';
import 'package:emababyspa/common/widgets/app_button.dart';
import 'package:emababyspa/data/models/staff.dart';
import 'package:emababyspa/features/session/controllers/session_controller.dart';
import 'package:emababyspa/features/staff/controllers/staff_controller.dart';
import 'package:emababyspa/features/theme/controllers/theme_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SessionFormView extends StatefulWidget {
  const SessionFormView({super.key});

  @override
  State<SessionFormView> createState() => _SessionFormViewState();
}

class _SessionFormViewState extends State<SessionFormView> {
  final SessionController _sessionController = Get.find<SessionController>();
  final StaffController _staffController = Get.find<StaffController>();
  // ThemeController tidak perlu di-find di sini jika hanya digunakan di dalam GetBuilder
  // final ThemeController _themeController = Get.find<ThemeController>();

  late String _timeSlotId;
  late List<dynamic> _existingSessions;
  List<Staff> _availableStaff = [];
  final Map<String, bool> _selectedStaffMap = {};
  bool _isCreating = false;
  bool _showMultiSelect = false;

  @override
  void initState() {
    super.initState();
    final args = Get.arguments as Map<String, dynamic>;
    _timeSlotId = args['timeSlotId'];
    _existingSessions = args['existingSessions'] ?? [];

    _loadAvailableStaff();
  }

  /// --- UPDATED ---
  /// Menggabungkan logika filter dari kode lama ke dalam metode ini.
  Future<void> _loadAvailableStaff() async {
    // 1. Fetch semua staff
    await _staffController.fetchAllStaffs();

    // 2. Filter hanya staff yang aktif
    final List<Staff> allActiveStaff =
        _staffController.staffList.where((staff) => staff.isActive).toList();

    // 3. Dapatkan ID dari staff yang sudah punya sesi di slot ini (Logika dari kode lama)
    final List<String> assignedStaffIds =
        _existingSessions.map((session) => session.staffId.toString()).toList();

    // 4. Filter staff aktif untuk mendapatkan hanya yang tersedia (Logika dari kode lama)
    _availableStaff =
        allActiveStaff
            .where((staff) => !assignedStaffIds.contains(staff.id))
            .toList();

    // 5. Inisialisasi map seleksi
    _selectedStaffMap.clear();
    for (var staff in _availableStaff) {
      _selectedStaffMap[staff.id] = false;
    }

    // 6. Atur ulang seleksi awal dengan benar
    if (mounted) {
      setState(() {
        _resetSelections();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // GetBuilder akan otomatis rebuild saat tema berubah
    return GetBuilder<ThemeController>(
      builder: (controller) {
        return MainLayout(
          child: Scaffold(
            appBar: AppBar(
              title: Text('Add Session${_showMultiSelect ? 's' : ''}'),
              actions: [
                if (_availableStaff.isNotEmpty)
                  IconButton(
                    icon: Icon(
                      _showMultiSelect
                          ? Icons.person_outline
                          : Icons.people_outline,
                    ),
                    tooltip:
                        _showMultiSelect
                            ? 'Single Selection'
                            : 'Multi Selection',
                    onPressed: () {
                      setState(() {
                        _showMultiSelect = !_showMultiSelect;
                        _resetSelections();
                      });
                    },
                  ),
              ],
            ),
            body: _buildBody(),
            bottomNavigationBar: _buildBottomBar(),
          ),
        );
      },
    );
  }

  Widget _buildBody() {
    if (_staffController.isLoading.value) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_availableStaff.isEmpty) {
      final textTheme = Theme.of(context).textTheme;
      final colorScheme = Theme.of(context).colorScheme;

      return Center(
        child: Padding(
          padding: const EdgeInsets.all(M3Spacing.xl),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.person_search_rounded,
                size: 80,
                color: colorScheme.secondary,
              ),
              const SizedBox(height: M3Spacing.lg),
              Text(
                'No Available Staff',
                style: textTheme.headlineSmall,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: M3Spacing.sm),
              Text(
                'All staff members are already assigned to this time slot.',
                textAlign: TextAlign.center,
                style: textTheme.bodyMedium,
              ),
              const SizedBox(height: M3Spacing.lg),
              AppButton(
                text: 'Go Back',
                onPressed: () => Get.back(),
                isFullWidth: false,
                type: AppButtonType.secondary,
              ),
            ],
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _showMultiSelect ? 'Select Multiple Staff' : 'Select Staff',
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: M3Spacing.xs),
              Text(
                _showMultiSelect
                    ? 'Choose staff to create multiple sessions at once.'
                    : 'Select a staff member for the session.',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: M3Spacing.md),
              _buildSelectionHint(),
            ],
          ),
        ),
        Expanded(
          child:
              _showMultiSelect
                  ? _buildMultiSelectList()
                  : _buildSingleSelectList(),
        ),
      ],
    );
  }

  Widget _buildSelectionHint() {
    final int selectedCount =
        _selectedStaffMap.values.where((selected) => selected).length;
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    if (!_showMultiSelect) {
      return const SizedBox.shrink();
    }

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      padding: const EdgeInsets.symmetric(
        horizontal: M3Spacing.md,
        vertical: M3Spacing.sm,
      ),
      decoration: BoxDecoration(
        color:
            selectedCount > 0
                ? colorScheme.primaryContainer
                : colorScheme.errorContainer.withOpacity(0.5),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(
            selectedCount > 0
                ? Icons.check_circle_outline_rounded
                : Icons.info_outline_rounded,
            size: 20,
            color:
                selectedCount > 0
                    ? colorScheme.onPrimaryContainer
                    : colorScheme.onErrorContainer,
          ),
          const SizedBox(width: M3Spacing.sm),
          Expanded(
            child: Text(
              selectedCount > 0
                  ? 'Selected $selectedCount staff member${selectedCount > 1 ? 's' : ''}'
                  : 'Select at least one staff member',
              style: textTheme.labelLarge?.copyWith(
                color:
                    selectedCount > 0
                        ? colorScheme.onPrimaryContainer
                        : colorScheme.onErrorContainer,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSingleSelectList() {
    return ListView.builder(
      padding: const EdgeInsets.all(M3Spacing.md),
      itemCount: _availableStaff.length,
      itemBuilder: (context, index) {
        final staff = _availableStaff[index];
        final isSelected = _selectedStaffMap[staff.id] ?? false;
        return _buildStaffListItem(staff, isSelected, () {
          setState(() {
            _selectedStaffMap.updateAll((key, value) => false);
            _selectedStaffMap[staff.id] = true;
          });
        });
      },
    );
  }

  Widget _buildMultiSelectList() {
    return ListView.builder(
      padding: const EdgeInsets.all(M3Spacing.md),
      itemCount: _availableStaff.length,
      itemBuilder: (context, index) {
        final staff = _availableStaff[index];
        final isSelected = _selectedStaffMap[staff.id] ?? false;
        return _buildStaffListItem(staff, isSelected, () {
          setState(() {
            _selectedStaffMap[staff.id] = !isSelected;
          });
        });
      },
    );
  }

  Widget _buildStaffListItem(Staff staff, bool isSelected, VoidCallback onTap) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Card(
      elevation: isSelected ? 2 : 0,
      margin: const EdgeInsets.symmetric(vertical: M3Spacing.xs),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: isSelected ? colorScheme.primary : colorScheme.outline,
          width: isSelected ? 1.5 : 1.0,
        ),
      ),
      child: ListTile(
        onTap: onTap,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: M3Spacing.md,
          vertical: M3Spacing.xs,
        ),
        leading: CircleAvatar(
          backgroundColor:
              isSelected ? colorScheme.primary : colorScheme.primaryContainer,
          foregroundColor:
              isSelected
                  ? colorScheme.onPrimary
                  : colorScheme.onPrimaryContainer,
          child: Text(
            staff.name.isNotEmpty ? staff.name[0].toUpperCase() : '?',
            style: textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color:
                  isSelected
                      ? colorScheme.onPrimary
                      : colorScheme.onPrimaryContainer,
            ),
          ),
        ),
        title: Text(
          staff.name,
          style: textTheme.bodyLarge?.copyWith(
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            color: colorScheme.onSurface,
          ),
        ),
        subtitle: Text(
          staff.phoneNumber,
          style: textTheme.bodySmall?.copyWith(
            color: colorScheme.onSurfaceVariant,
          ),
        ),
        trailing:
            _showMultiSelect
                ? Checkbox(value: isSelected, onChanged: (_) => onTap())
                : Radio<bool>(
                  value: true,
                  groupValue: isSelected,
                  onChanged: (_) => onTap(),
                ),
      ),
    );
  }

  void _resetSelections() {
    _selectedStaffMap.updateAll((key, value) => false);

    if (!_showMultiSelect && _availableStaff.isNotEmpty) {
      _selectedStaffMap[_availableStaff.first.id] = true;
    }
  }

  Widget _buildBottomBar() {
    final bool hasSelection = _selectedStaffMap.values.contains(true);
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(
        M3Spacing.md,
      ).copyWith(bottom: M3Spacing.md + MediaQuery.of(context).padding.bottom),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: colorScheme.shadow.withOpacity(0.1),
            offset: const Offset(0, -2),
            blurRadius: 8,
          ),
        ],
        border: Border(
          top: BorderSide(color: colorScheme.outlineVariant, width: 1),
        ),
      ),
      child:
          _isCreating
              ? Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const CircularProgressIndicator(),
                  const SizedBox(height: M3Spacing.md),
                  Text(
                    'Creating session${_showMultiSelect ? 's' : ''}...',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              )
              : Row(
                children: [
                  Expanded(
                    child: AppButton(
                      text: 'Cancel',
                      onPressed: () => Get.back(),
                      type: AppButtonType.secondary,
                    ),
                  ),
                  const SizedBox(width: M3Spacing.md),
                  Expanded(
                    child: AppButton(
                      text:
                          _showMultiSelect
                              ? 'Create Sessions'
                              : 'Create Session',
                      onPressed: hasSelection ? _createSessions : null,
                      icon: Icons.check_circle_outline,
                    ),
                  ),
                ],
              ),
    );
  }

  void _showSnackbar(String title, String message, {bool isError = false}) {
    final colorScheme = Theme.of(context).colorScheme;
    Get.snackbar(
      title,
      message,
      backgroundColor:
          isError ? colorScheme.errorContainer : colorScheme.primaryContainer,
      colorText:
          isError
              ? colorScheme.onErrorContainer
              : colorScheme.onPrimaryContainer,
      snackPosition: SnackPosition.BOTTOM,
      margin: const EdgeInsets.all(M3Spacing.md),
      borderRadius: 12,
      icon: Icon(
        isError ? Icons.error_outline : Icons.check_circle_outline,
        color:
            isError
                ? colorScheme.onErrorContainer
                : colorScheme.onPrimaryContainer,
      ),
    );
  }

  Future<void> _createSessions() async {
    if (!_selectedStaffMap.values.contains(true)) {
      _showSnackbar(
        'No Selection',
        'Please select at least one staff member.',
        isError: true,
      );
      return;
    }

    setState(() {
      _isCreating = true;
    });

    try {
      bool success = false;
      if (_showMultiSelect) {
        final List<String> selectedStaffIds =
            _selectedStaffMap.entries
                .where((entry) => entry.value)
                .map((entry) => entry.key)
                .toList();
        final List<Map<String, dynamic>> sessionsList =
            selectedStaffIds.map((staffId) {
              return {
                "timeSlotId": _timeSlotId,
                "staffId": staffId,
                "isBooked": false,
              };
            }).toList();

        success = await _sessionController.createManySessions(
          sessionsList: sessionsList,
        );
      } else {
        String? selectedStaffId;
        for (var entry in _selectedStaffMap.entries) {
          if (entry.value) {
            selectedStaffId = entry.key;
            break;
          }
        }
        if (selectedStaffId != null) {
          success = await _sessionController.createSession(
            timeSlotId: _timeSlotId,
            staffId: selectedStaffId,
            isBooked: false,
          );
        }
      }

      if (success) {
        await _sessionController.fetchSessions(timeSlotId: _timeSlotId);
        _showSnackbar(
          'Success',
          'Session${_showMultiSelect ? 's' : ''} created successfully.',
        );
        Get.back(result: true);
      } else {
        _showSnackbar(
          'Error',
          'Failed to create session${_showMultiSelect ? 's' : ''}.',
          isError: true,
        );
      }
    } catch (e) {
      _showSnackbar(
        'Error',
        'An unexpected error occurred: ${e.toString()}',
        isError: true,
      );
    } finally {
      if (mounted) {
        setState(() {
          _isCreating = false;
        });
      }
    }
  }
}
