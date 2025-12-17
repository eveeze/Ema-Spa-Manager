// lib/features/session/views/session_form_view.dart
import 'package:emababyspa/common/layouts/main_layout.dart';
import 'package:emababyspa/common/theme/app_theme.dart';
import 'package:emababyspa/common/theme/semantic_colors.dart';
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

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadAvailableStaff();
    });
  }

  Future<void> _loadAvailableStaff() async {
    // 1. Fetch semua staff
    await _staffController.fetchAllStaffs();

    if (!mounted) return;

    // 2. Filter hanya staff yang aktif
    final List<Staff> allActiveStaff =
        _staffController.staffList.where((staff) => staff.isActive).toList();

    // 3. Dapatkan ID dari staff yang sudah punya sesi di slot ini
    final List<String> assignedStaffIds =
        _existingSessions.map((session) => session.staffId.toString()).toList();

    // 4. Filter staff aktif untuk mendapatkan hanya yang tersedia
    _availableStaff =
        allActiveStaff
            .where((staff) => !assignedStaffIds.contains(staff.id))
            .toList();

    // 5. Inisialisasi map seleksi
    _selectedStaffMap.clear();
    for (final staff in _availableStaff) {
      _selectedStaffMap[staff.id] = false;
    }

    // 6. Atur ulang seleksi awal
    setState(() {
      _resetSelections();
    });
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ThemeController>(
      builder: (_) {
        final theme = Theme.of(context);
        final colorScheme = theme.colorScheme;
        final spacing = theme.extension<AppSpacing>() ?? const AppSpacing();

        return MainLayout(
          child: Scaffold(
            appBar: AppBar(
              title: Text(
                _showMultiSelect ? 'Tambah Beberapa Sesi' : 'Tambah Sesi',
                style: theme.appBarTheme.titleTextStyle,
              ),
              actions: [
                if (_availableStaff.isNotEmpty)
                  IconButton(
                    icon: Icon(
                      _showMultiSelect
                          ? Icons.person_outline
                          : Icons.people_outline,
                      color: colorScheme.onSurfaceVariant,
                    ),
                    tooltip:
                        _showMultiSelect
                            ? 'Mode satu terapis'
                            : 'Mode beberapa terapis',
                    onPressed: () {
                      setState(() {
                        _showMultiSelect = !_showMultiSelect;
                        _resetSelections();
                      });
                    },
                  ),
                SizedBox(width: spacing.xs),
              ],
            ),
            body: _buildBody(context),
            bottomNavigationBar: _buildBottomBar(context),
          ),
        );
      },
    );
  }

  Widget _buildBody(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;
    final spacing = theme.extension<AppSpacing>() ?? const AppSpacing();

    if (_staffController.isLoading.value) {
      return Center(
        child: CircularProgressIndicator(color: colorScheme.primary),
      );
    }

    if (_availableStaff.isEmpty) {
      return Center(
        child: Padding(
          padding: EdgeInsets.all(spacing.xl),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                height: 88,
                width: 88,
                decoration: BoxDecoration(
                  color: colorScheme.surfaceContainerHighest.withValues(
                    alpha: 0.55,
                  ),
                  borderRadius: BorderRadius.circular(AppRadii.xl),
                  border: Border.all(
                    color: colorScheme.outlineVariant.withValues(alpha: 0.70),
                  ),
                ),
                child: Icon(
                  Icons.person_search_rounded,
                  size: 44,
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
              SizedBox(height: spacing.lg),
              Text(
                'Terapis Tidak Tersedia',
                style: textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w900,
                  color: colorScheme.onSurface,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: spacing.sm),
              Text(
                'Semua terapis aktif sudah terjadwal di slot waktu ini. Silakan kembali atau pilih slot waktu lain.',
                textAlign: TextAlign.center,
                style: textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(height: spacing.lg),
              AppButton(
                text: 'Kembali',
                onPressed: () => Get.back(),
                isFullWidth: false,
                type: AppButtonType.secondary,
                icon: Icons.arrow_back_rounded,
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
          padding: EdgeInsets.fromLTRB(spacing.lg, spacing.lg, spacing.lg, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _showMultiSelect ? 'Pilih Beberapa Terapis' : 'Pilih Terapis',
                style: textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w900,
                  color: colorScheme.onSurface,
                ),
              ),
              SizedBox(height: spacing.xs),
              Text(
                _showMultiSelect
                    ? 'Pilih beberapa terapis untuk membuat beberapa sesi sekaligus.'
                    : 'Pilih satu terapis untuk sesi ini.',
                style: textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(height: spacing.md),
              _buildSelectionHint(context),
            ],
          ),
        ),
        Expanded(
          child:
              _showMultiSelect
                  ? _buildMultiSelectList(context)
                  : _buildSingleSelectList(context),
        ),
      ],
    );
  }

  Widget _buildSelectionHint(BuildContext context) {
    final int selectedCount =
        _selectedStaffMap.values.where((selected) => selected).length;

    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;
    final spacing = theme.extension<AppSpacing>() ?? const AppSpacing();

    if (!_showMultiSelect) return const SizedBox.shrink();

    final bool hasSelection = selectedCount > 0;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 260),
      padding: EdgeInsets.symmetric(
        horizontal: spacing.md,
        vertical: spacing.sm,
      ),
      decoration: BoxDecoration(
        color:
            hasSelection
                ? colorScheme.primaryContainer.withValues(alpha: 0.60)
                : colorScheme.errorContainer.withValues(alpha: 0.45),
        borderRadius: BorderRadius.circular(AppRadii.md),
        border: Border.all(
          color:
              hasSelection
                  ? colorScheme.primary.withValues(alpha: 0.22)
                  : colorScheme.error.withValues(alpha: 0.22),
        ),
      ),
      child: Row(
        children: [
          Icon(
            hasSelection
                ? Icons.check_circle_outline_rounded
                : Icons.info_outline_rounded,
            size: 20,
            color:
                hasSelection
                    ? colorScheme.primary
                    : colorScheme.onErrorContainer,
          ),
          SizedBox(width: spacing.sm),
          Expanded(
            child: Text(
              hasSelection
                  ? 'Terpilih $selectedCount terapis'
                  : 'Pilih minimal 1 terapis untuk melanjutkan',
              style: textTheme.labelLarge?.copyWith(
                color:
                    hasSelection
                        ? colorScheme.onPrimaryContainer
                        : colorScheme.onErrorContainer,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSingleSelectList(BuildContext context) {
    final theme = Theme.of(context);
    final spacing = theme.extension<AppSpacing>() ?? const AppSpacing();

    return ListView.builder(
      padding: EdgeInsets.all(spacing.md),
      itemCount: _availableStaff.length,
      itemBuilder: (context, index) {
        final staff = _availableStaff[index];
        final isSelected = _selectedStaffMap[staff.id] ?? false;

        return _buildStaffListItem(context, staff, isSelected, () {
          setState(() {
            _selectedStaffMap.updateAll((key, value) => false);
            _selectedStaffMap[staff.id] = true;
          });
        });
      },
    );
  }

  Widget _buildMultiSelectList(BuildContext context) {
    final theme = Theme.of(context);
    final spacing = theme.extension<AppSpacing>() ?? const AppSpacing();

    return ListView.builder(
      padding: EdgeInsets.all(spacing.md),
      itemCount: _availableStaff.length,
      itemBuilder: (context, index) {
        final staff = _availableStaff[index];
        final isSelected = _selectedStaffMap[staff.id] ?? false;

        return _buildStaffListItem(context, staff, isSelected, () {
          setState(() {
            _selectedStaffMap[staff.id] = !isSelected;
          });
        });
      },
    );
  }

  Widget _buildStaffListItem(
    BuildContext context,
    Staff staff,
    bool isSelected,
    VoidCallback onTap,
  ) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;
    final spacing = theme.extension<AppSpacing>() ?? const AppSpacing();

    final String initial =
        staff.name.isNotEmpty ? staff.name[0].toUpperCase() : '?';

    return Card(
      elevation: 0,
      margin: EdgeInsets.symmetric(vertical: spacing.xs),
      color:
          isSelected
              ? colorScheme.primaryContainer.withValues(alpha: 0.35)
              : colorScheme.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadii.lg),
        side: BorderSide(
          color:
              isSelected
                  ? colorScheme.primary.withValues(alpha: 0.45)
                  : colorScheme.outlineVariant.withValues(alpha: 0.70),
          width: isSelected ? 1.25 : 1.0,
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: spacing.md,
            vertical: spacing.sm,
          ),
          child: Row(
            children: [
              Container(
                height: 44,
                width: 44,
                decoration: BoxDecoration(
                  color:
                      isSelected
                          ? colorScheme.primary
                          : colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(AppRadii.md),
                  border: Border.all(
                    color:
                        isSelected
                            ? colorScheme.primary.withValues(alpha: 0.30)
                            : colorScheme.outlineVariant.withValues(
                              alpha: 0.70,
                            ),
                  ),
                ),
                alignment: Alignment.center,
                child: Text(
                  initial,
                  style: textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w900,
                    color:
                        isSelected
                            ? colorScheme.onPrimary
                            : colorScheme.onPrimaryContainer,
                  ),
                ),
              ),
              SizedBox(width: spacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      staff.name,
                      style: textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w900,
                        color: colorScheme.onSurface,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: spacing.xxs),
                    Text(
                      staff.phoneNumber,
                      style: textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              SizedBox(width: spacing.sm),
              _showMultiSelect
                  ? Checkbox(value: isSelected, onChanged: (_) => onTap())
                  : Radio<bool>(
                    value: true,
                    groupValue: isSelected,
                    onChanged: (_) => onTap(),
                  ),
            ],
          ),
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

  Widget _buildBottomBar(BuildContext context) {
    final bool hasSelection = _selectedStaffMap.values.contains(true);

    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;
    final spacing = theme.extension<AppSpacing>() ?? const AppSpacing();

    return Container(
      padding: EdgeInsets.all(
        spacing.md,
      ).copyWith(bottom: spacing.md + MediaQuery.of(context).padding.bottom),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        border: Border(
          top: BorderSide(
            color: colorScheme.outlineVariant.withValues(alpha: 0.70),
            width: 1,
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: colorScheme.shadow.withValues(alpha: 0.10),
            offset: const Offset(0, -2),
            blurRadius: 10,
          ),
        ],
      ),
      child:
          _isCreating
              ? Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(
                    height: 22,
                    width: 22,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      color: colorScheme.primary,
                    ),
                  ),
                  SizedBox(height: spacing.md),
                  Text(
                    _showMultiSelect
                        ? 'Sedang membuat beberapa sesi...'
                        : 'Sedang membuat sesi...',
                    style: textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              )
              : Row(
                children: [
                  Expanded(
                    child: AppButton(
                      text: 'Batal',
                      onPressed: () => Get.back(),
                      type: AppButtonType.secondary,
                      icon: Icons.close_rounded,
                    ),
                  ),
                  SizedBox(width: spacing.md),
                  Expanded(
                    child: AppButton(
                      text: _showMultiSelect ? 'Buat Sesi' : 'Buat Sesi',
                      onPressed: hasSelection ? _createSessions : null,
                      icon: Icons.check_circle_outline,
                    ),
                  ),
                ],
              ),
    );
  }

  void _showSnackbar(String title, String message, {bool isError = false}) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final semantic = theme.extension<AppSemanticColors>();
    final successColor = semantic?.success ?? colorScheme.tertiary;

    Get.snackbar(
      title,
      message,
      backgroundColor:
          isError
              ? colorScheme.errorContainer
              : successColor.withValues(alpha: 0.16),
      colorText: colorScheme.onSurface,
      snackPosition: SnackPosition.BOTTOM,
      margin: const EdgeInsets.all(M3Spacing.md),
      borderRadius: 12,
      icon: Icon(
        isError ? Icons.error_outline : Icons.check_circle_outline,
        color: isError ? colorScheme.error : successColor,
      ),
    );
  }

  Future<void> _createSessions() async {
    if (!_selectedStaffMap.values.contains(true)) {
      _showSnackbar(
        'Belum Ada Pilihan',
        'Pilih minimal satu terapis terlebih dahulu.',
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
        for (final entry in _selectedStaffMap.entries) {
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
          'Berhasil',
          _showMultiSelect
              ? 'Beberapa sesi berhasil dibuat.'
              : 'Sesi berhasil dibuat.',
        );
        Get.back(result: true);
      } else {
        _showSnackbar(
          'Gagal',
          _showMultiSelect
              ? 'Gagal membuat beberapa sesi.'
              : 'Gagal membuat sesi.',
          isError: true,
        );
      }
    } catch (e) {
      _showSnackbar(
        'Terjadi Kesalahan',
        'Ada masalah tak terduga: ${e.toString()}',
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
