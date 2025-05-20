// lib/features/session/views/session_form_view.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:emababyspa/common/theme/color_theme.dart';
import 'package:emababyspa/common/widgets/app_button.dart';
import 'package:emababyspa/features/session/controllers/session_controller.dart';
import 'package:emababyspa/features/staff/controllers/staff_controller.dart';
import 'package:emababyspa/data/models/staff.dart';
import 'package:emababyspa/common/layouts/main_layout.dart';

class SessionFormView extends StatefulWidget {
  const SessionFormView({super.key});

  @override
  State<SessionFormView> createState() => _SessionFormViewState();
}

class _SessionFormViewState extends State<SessionFormView> {
  final SessionController _sessionController = Get.find<SessionController>();
  final StaffController _staffController = Get.find<StaffController>();

  late String _timeSlotId;
  late List<dynamic> _existingSessions;
  List<Staff> _availableStaff = [];
  final Map<String, bool> _selectedStaffMap = {};
  bool _isCreating = false;
  bool _showMultiSelect = false;

  @override
  void initState() {
    super.initState();
    // Extract data from arguments
    final args = Get.arguments as Map<String, dynamic>;
    _timeSlotId = args['timeSlotId'];
    _existingSessions = args['existingSessions'] ?? [];

    _loadAvailableStaff();
  }

  // Load staff members who haven't been assigned to this time slot
  Future<void> _loadAvailableStaff() async {
    // Get all active staff members
    await _staffController.fetchAllStaffs();

    final List<Staff> allActiveStaff =
        _staffController.staffList.where((staff) => staff.isActive).toList();

    // Get IDs of staff already assigned to this time slot
    final List<String> assignedStaffIds =
        _existingSessions.map((session) => session.staffId.toString()).toList();

    // Filter out staff already assigned
    _availableStaff =
        allActiveStaff
            .where((staff) => !assignedStaffIds.contains(staff.id))
            .toList();

    // Initialize selection map with all false
    for (var staff in _availableStaff) {
      _selectedStaffMap[staff.id] = false;
    }

    setState(() {
      // Auto-select the first available staff if any (for single select mode)
      if (_availableStaff.isNotEmpty) {
        _selectedStaffMap[_availableStaff.first.id] = true;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return MainLayout(
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            'Add Session${_showMultiSelect ? 's' : ''}',
            style: TextStyle(
              color: ColorTheme.textPrimary,
              fontWeight: FontWeight.bold,
            ),
          ),
          backgroundColor: Colors.white,
          elevation: 0,
          iconTheme: IconThemeData(color: ColorTheme.primary),
          actions: [
            // Toggle between single and multi-select mode
            IconButton(
              icon: Icon(_showMultiSelect ? Icons.person : Icons.people),
              tooltip:
                  _showMultiSelect ? 'Single Selection' : 'Multi Selection',
              onPressed: () {
                setState(() {
                  _showMultiSelect = !_showMultiSelect;

                  // Reset selections when toggling modes
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
  }

  Widget _buildBody() {
    if (_staffController.isLoading.value) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_availableStaff.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 80, color: Colors.amber[700]),
            const SizedBox(height: 24),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Text(
                'All staff members already have sessions for this time slot.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 18, color: ColorTheme.textSecondary),
              ),
            ),
            const SizedBox(height: 24),
            AppButton(
              text: 'Go Back',
              onPressed: () => Get.back(),
              isFullWidth: false,
            ),
          ],
        ),
      );
    }

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Colors.white, ColorTheme.primary.withValues(alpha: 0.05)],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _showMultiSelect ? 'Select Multiple Staff' : 'Select Staff',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: ColorTheme.textPrimary,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  _showMultiSelect
                      ? 'Choose staff members to create multiple sessions at once'
                      : 'Select a staff member to create a session',
                  style: TextStyle(
                    color: ColorTheme.textSecondary,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 16),
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
      ),
    );
  }

  Widget _buildSelectionHint() {
    final int selectedCount =
        _selectedStaffMap.values.where((selected) => selected).length;

    if (!_showMultiSelect) {
      return Container(); // No hint needed in single select mode
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color:
            selectedCount > 0
                ? ColorTheme.primary.withValues(alpha: 0.1)
                : Colors.amber.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(
            selectedCount > 0 ? Icons.check_circle : Icons.info_outline,
            size: 20,
            color: selectedCount > 0 ? ColorTheme.primary : Colors.amber[700],
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              selectedCount > 0
                  ? 'Selected $selectedCount staff member${selectedCount > 1 ? 's' : ''}'
                  : 'Select at least one staff member',
              style: TextStyle(
                color:
                    selectedCount > 0 ? ColorTheme.primary : Colors.amber[700],
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSingleSelectList() {
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: _availableStaff.length,
      separatorBuilder: (context, index) => const Divider(height: 1),
      itemBuilder: (context, index) {
        final staff = _availableStaff[index];
        final isSelected = _selectedStaffMap[staff.id] ?? false;

        return _buildStaffListItem(staff, isSelected, () {
          setState(() {
            // Deselect all first
            _resetSelections();
            // Then select just this one
            _selectedStaffMap[staff.id] = true;
          });
        });
      },
    );
  }

  Widget _buildMultiSelectList() {
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: _availableStaff.length,
      separatorBuilder: (context, index) => const Divider(height: 1),
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
    return ListTile(
      onTap: onTap,
      leading: Stack(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color:
                  isSelected
                      ? ColorTheme.primary.withValues(alpha: 0.15)
                      : ColorTheme.primary.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                staff.name.isNotEmpty ? staff.name[0].toUpperCase() : '?',
                style: TextStyle(
                  color: ColorTheme.primary,
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                ),
              ),
            ),
          ),
          if (isSelected)
            Positioned(
              right: 0,
              bottom: 0,
              child: Container(
                padding: const EdgeInsets.all(2),
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
                child: Container(
                  width: 18,
                  height: 18,
                  decoration: BoxDecoration(
                    color: ColorTheme.primary,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.check, size: 14, color: Colors.white),
                ),
              ),
            ),
        ],
      ),
      title: Text(
        staff.name,
        style: TextStyle(
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          color: ColorTheme.textPrimary,
        ),
      ),
      subtitle: Text(
        staff.phoneNumber,
        style: TextStyle(color: ColorTheme.textSecondary),
      ),
      trailing:
          _showMultiSelect
              ? Checkbox(
                value: isSelected,
                activeColor: ColorTheme.primary,
                onChanged: (_) => onTap(),
              )
              : Radio<bool>(
                value: true,
                groupValue: isSelected,
                activeColor: ColorTheme.primary,
                onChanged: (_) => onTap(),
              ),
    );
  }

  void _resetSelections() {
    // If single select mode, deselect all
    if (!_showMultiSelect) {
      for (var staffId in _selectedStaffMap.keys) {
        _selectedStaffMap[staffId] = false;
      }
    }
  }

  Widget _buildBottomBar() {
    final bool hasSelection = _selectedStaffMap.values.contains(true);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            offset: const Offset(0, -4),
            blurRadius: 8,
          ),
        ],
      ),
      child: SafeArea(
        child:
            _isCreating
                ? Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const CircularProgressIndicator(),
                      const SizedBox(height: 16),
                      Text(
                        'Creating session${_showMultiSelect ? 's' : ''}...',
                        style: TextStyle(color: ColorTheme.textSecondary),
                      ),
                    ],
                  ),
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
                    const SizedBox(width: 16),
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
      ),
    );
  }

  Future<void> _createSessions() async {
    if (!_selectedStaffMap.values.contains(true)) {
      Get.snackbar(
        'Error',
        'Please select at least one staff member',
        backgroundColor: Colors.red.shade100,
        colorText: Colors.red.shade900,
      );
      return;
    }

    setState(() {
      _isCreating = true;
    });

    try {
      bool success = false;

      if (_showMultiSelect) {
        // Get all selected staff IDs
        final List<String> selectedStaffIds =
            _selectedStaffMap.entries
                .where((entry) => entry.value)
                .map((entry) => entry.key)
                .toList();

        // Create sessions for all selected staff
        final List<Map<String, dynamic>> sessionsList =
            selectedStaffIds.map((staffId) {
              return {
                "timeSlotId": _timeSlotId,
                "staffId": staffId,
                "isBooked": false,
              };
            }).toList();

        // Create multiple sessions at once
        success = await _sessionController.createManySessions(
          sessionsList: sessionsList,
        );
      } else {
        // Single session creation
        // Find the selected staff ID
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
        // Ensure sessions are refreshed in the controller before going back
        await _sessionController.fetchSessions(timeSlotId: _timeSlotId);

        // Show a success message
        Get.snackbar(
          'Success',
          'Session${_showMultiSelect ? 's' : ''} created successfully',
          backgroundColor: Colors.green.shade100,
          colorText: Colors.green.shade900,
          duration: const Duration(seconds: 2),
          snackPosition: SnackPosition.BOTTOM,
        );

        // Go back to the previous screen - no need to pass result since we're using reactive state
        Get.back();
      } else {
        // Show error if session creation failed but API returned
        Get.snackbar(
          'Error',
          'Failed to create session${_showMultiSelect ? 's' : ''}',
          backgroundColor: Colors.red.shade100,
          colorText: Colors.red.shade900,
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    } catch (e) {
      // Show error for exceptions during session creation
      Get.snackbar(
        'Error',
        'Failed to create session${_showMultiSelect ? 's' : ''}: ${e.toString()}',
        backgroundColor: Colors.red.shade100,
        colorText: Colors.red.shade900,
        snackPosition: SnackPosition.BOTTOM,
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
