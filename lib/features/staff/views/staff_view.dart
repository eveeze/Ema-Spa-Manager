// lib/features/staff/views/staff_view.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:emababyspa/common/theme/color_theme.dart';
import 'package:emababyspa/common/widgets/custom_appbar.dart';
import 'package:emababyspa/common/widgets/empty_state_widget.dart';
import 'package:emababyspa/common/layouts/main_layout.dart';
import 'package:emababyspa/features/staff/controllers/staff_controller.dart';
import 'package:emababyspa/data/models/staff.dart';

class StaffView extends GetView<StaffController> {
  const StaffView({super.key});

  @override
  Widget build(BuildContext context) {
    return MainLayout(
      child: Scaffold(
        appBar: const CustomAppBar(
          title: 'Staff Management',
          showBackButton: true,
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: controller.navigateToAddStaff,
          backgroundColor: ColorTheme.primary,
          icon: const Icon(Icons.person_add_rounded, color: Colors.white),
          label: const Text(
            'Add Staff',
            style: TextStyle(
              color: Colors.white,
              fontFamily: 'JosefinSans',
              fontWeight: FontWeight.w600,
            ),
          ),
          elevation: 2,
        ),
        body: SafeArea(
          child: RefreshIndicator(
            onRefresh: () async {
              controller.refreshData();
            },
            color: ColorTheme.primary,
            backgroundColor: Colors.white,
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 24.0,
                vertical: 16.0,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header with counter badge
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Staff Members',
                              style: Theme.of(
                                context,
                              ).textTheme.headlineMedium?.copyWith(
                                color: ColorTheme.textPrimary,
                                fontFamily: 'JosefinSans',
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Obx(
                              () => Text(
                                'Managing ${controller.staffList.length} team members',
                                style: TextStyle(
                                  fontSize: 15,
                                  color: ColorTheme.textSecondary,
                                  fontFamily: 'JosefinSans',
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      // Counter badge
                      Obx(
                        () => Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: ColorTheme.primaryLight,
                            borderRadius: BorderRadius.circular(24),
                          ),
                          child: Text(
                            '${controller.staffList.length}',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: ColorTheme.primaryDark,
                              fontFamily: 'JosefinSans',
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  Expanded(
                    child: Obx(() {
                      if (controller.isLoading.value) {
                        return Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              CircularProgressIndicator(
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  ColorTheme.primary,
                                ),
                                strokeWidth: 3,
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'Loading staff...',
                                style: TextStyle(
                                  color: ColorTheme.textSecondary,
                                  fontFamily: 'JosefinSans',
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        );
                      }

                      if (controller.errorMessage.isNotEmpty) {
                        return EmptyStateWidget(
                          title: 'Oops!',
                          message: controller.errorMessage.value,
                          icon: Icons.error_outline_rounded,
                          buttonLabel: 'Refresh',
                          onButtonPressed: controller.refreshData,
                          fullScreen: false,
                        );
                      }

                      if (controller.staffList.isEmpty) {
                        return EmptyStateWidget(
                          title: 'No Staff Found',
                          message: 'You haven\'t added any staff members yet.',
                          icon: Icons.people_outline_rounded,
                          buttonLabel: 'Add Staff',
                          onButtonPressed: controller.navigateToAddStaff,
                          fullScreen: false,
                        );
                      }

                      return _buildStaffList();
                    }),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStaffList() {
    return ListView.separated(
      physics: const BouncingScrollPhysics(),
      itemCount: controller.staffList.length,
      separatorBuilder: (context, index) => const SizedBox(height: 16),
      itemBuilder: (context, index) {
        final staff = controller.staffList[index];
        return _buildStaffCard(staff);
      },
    );
  }

  Widget _buildStaffCard(Staff staff) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 12,
            spreadRadius: 0,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => controller.navigateToEditStaff(staff.id),
          borderRadius: BorderRadius.circular(16),
          splashColor: ColorTheme.primaryLight.withValues(alpha: 0.2),
          highlightColor: ColorTheme.primaryLight.withValues(alpha: 0.1),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                Row(
                  children: [
                    // Profile image with elegant container
                    Container(
                      width: 64,
                      height: 64,
                      decoration: BoxDecoration(
                        color: ColorTheme.accent.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(32),
                        border: Border.all(
                          color:
                              staff.isActive
                                  ? ColorTheme.primary
                                  : ColorTheme.divider,
                          width: 2,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: ColorTheme.primary.withValues(alpha: 0.1),
                            blurRadius: 8,
                            spreadRadius: 0,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child:
                          staff.profilePicture != null &&
                                  staff.profilePicture!.isNotEmpty
                              ? ClipRRect(
                                borderRadius: BorderRadius.circular(30),
                                child: Image.network(
                                  staff.profilePicture!,
                                  width: 60,
                                  height: 60,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) {
                                    return Icon(
                                      Icons.person,
                                      size: 30,
                                      color: ColorTheme.primary,
                                    );
                                  },
                                ),
                              )
                              : Icon(
                                Icons.person,
                                size: 30,
                                color: ColorTheme.primary,
                              ),
                    ),
                    const SizedBox(width: 20),

                    // Staff info with better typography
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Name and status in row
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  staff.name,
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    fontFamily: 'JosefinSans',
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              AnimatedContainer(
                                duration: const Duration(milliseconds: 300),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color:
                                      staff.isActive
                                          ? ColorTheme.activeTagBackground
                                          : ColorTheme.inactiveTagBackground,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  staff.isActive ? 'Active' : 'Inactive',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color:
                                        staff.isActive
                                            ? ColorTheme.activeTagText
                                            : ColorTheme.inactiveTagText,
                                    fontFamily: 'JosefinSans',
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),

                          // Email with icon
                          Row(
                            children: [
                              Icon(
                                Icons.email_outlined,
                                size: 16,
                                color: ColorTheme.secondary.withValues(
                                  alpha: 0.7,
                                ),
                              ),
                              const SizedBox(width: 6),
                              Expanded(
                                child: Text(
                                  staff.email,
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: ColorTheme.textSecondary,
                                    fontFamily: 'JosefinSans',
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),

                          // Phone with icon
                          Row(
                            children: [
                              Icon(
                                Icons.phone_outlined,
                                size: 16,
                                color: ColorTheme.secondary.withValues(
                                  alpha: 0.7,
                                ),
                              ),
                              const SizedBox(width: 6),
                              Text(
                                staff.phoneNumber,
                                style: TextStyle(
                                  fontSize: 14,
                                  color: ColorTheme.textSecondary,
                                  fontFamily: 'JosefinSans',
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                // Divider and action buttons
                Padding(
                  padding: const EdgeInsets.only(top: 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      // Edit button
                      _buildActionButton(
                        label: 'Edit',
                        icon: Icons.edit_outlined,
                        color: ColorTheme.info,
                        onTap: () => controller.navigateToEditStaff(staff.id),
                      ),
                      const SizedBox(width: 8),

                      // Toggle status button
                      _buildActionButton(
                        label: staff.isActive ? 'Deactivate' : 'Activate',
                        icon:
                            staff.isActive
                                ? Icons.person_off_outlined
                                : Icons.person_outline,
                        color:
                            staff.isActive
                                ? ColorTheme.warning
                                : ColorTheme.success,
                        onTap: () => controller.toggleStaffStatus(staff),
                      ),
                      const SizedBox(width: 8),

                      // Delete button
                      _buildActionButton(
                        label: 'Delete',
                        icon: Icons.delete_outline_rounded,
                        color: ColorTheme.error,
                        onTap: () => _showDeleteConfirmation(staff),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required String label,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Material(
      color: color.withValues(alpha: 0.1),
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 16, color: color),
              const SizedBox(width: 4),
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: color,
                  fontWeight: FontWeight.w600,
                  fontFamily: 'JosefinSans',
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Show delete confirmation dialog
  void _showDeleteConfirmation(Staff staff) {
    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          'Delete Staff Member',
          style: TextStyle(
            fontFamily: 'JosefinSans',
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: ColorTheme.error.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                Icons.warning_amber_rounded,
                color: ColorTheme.error,
                size: 48,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Are you sure you want to delete ${staff.name}?',
              textAlign: TextAlign.center,
              style: const TextStyle(fontFamily: 'JosefinSans', fontSize: 16),
            ),
            const SizedBox(height: 8),
            Text(
              'This action cannot be undone.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'JosefinSans',
                fontSize: 14,
                color: ColorTheme.textSecondary,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            style: TextButton.styleFrom(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            ),
            child: Text(
              'Cancel',
              style: TextStyle(
                color: ColorTheme.textSecondary,
                fontFamily: 'JosefinSans',
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Get.back();
              controller.deleteStaff(staff.id);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: ColorTheme.error,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            ),
            child: const Text(
              'Delete',
              style: TextStyle(
                fontFamily: 'JosefinSans',
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
