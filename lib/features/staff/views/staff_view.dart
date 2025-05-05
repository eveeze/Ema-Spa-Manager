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
        floatingActionButton: FloatingActionButton(
          onPressed: controller.navigateToAddStaff,
          backgroundColor: ColorTheme.primary,
          child: const Icon(Icons.add, color: Colors.white),
        ),
        body: SafeArea(
          child: RefreshIndicator(
            onRefresh: () async {
              controller.refreshData();
            },
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header title
                  Text(
                    'Staff Members',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: ColorTheme.textPrimary,
                      fontFamily: 'JosefinSans',
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Manage your spa staff members',
                    style: TextStyle(
                      fontSize: 14,
                      color: ColorTheme.textSecondary,
                      fontFamily: 'JosefinSans',
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Staff list
                  Expanded(
                    child: Obx(() {
                      if (controller.isLoading.value) {
                        return const Center(child: CircularProgressIndicator());
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
      physics: const AlwaysScrollableScrollPhysics(),
      itemCount: controller.staffList.length,
      separatorBuilder: (context, index) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final staff = controller.staffList[index];
        return _buildStaffCard(staff);
      },
    );
  }

  Widget _buildStaffCard(Staff staff) {
    return Container(
      decoration: BoxDecoration(
        color: ColorTheme.surface,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: InkWell(
        onTap: () => controller.navigateToEditStaff(staff.id),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              // Profile image or placeholder
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: ColorTheme.info.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(30),
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
                                color: ColorTheme.info,
                              );
                            },
                          ),
                        )
                        : Icon(Icons.person, size: 30, color: ColorTheme.info),
              ),
              const SizedBox(width: 16),

              // Staff info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          staff.name,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: ColorTheme.textPrimary,
                            fontFamily: 'JosefinSans',
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color:
                                staff.isActive
                                    ? ColorTheme.success.withValues(alpha: 0.1)
                                    : ColorTheme.error.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            staff.isActive ? 'Active' : 'Inactive',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color:
                                  staff.isActive
                                      ? ColorTheme.success
                                      : ColorTheme.error,
                              fontFamily: 'JosefinSans',
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      staff.email,
                      style: TextStyle(
                        fontSize: 14,
                        color: ColorTheme.textSecondary,
                        fontFamily: 'JosefinSans',
                      ),
                    ),
                    const SizedBox(height: 2),
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
              ),

              // Action buttons
              Column(
                children: [
                  // Toggle active status button
                  IconButton(
                    icon: Icon(
                      staff.isActive
                          ? Icons.toggle_on_rounded
                          : Icons.toggle_off_rounded,
                      color:
                          staff.isActive
                              ? ColorTheme.success
                              : ColorTheme.textSecondary,
                      size: 28,
                    ),
                    onPressed: () => controller.toggleStaffStatus(staff),
                  ),
                  // Delete button
                  IconButton(
                    icon: Icon(
                      Icons.delete_outline_rounded,
                      color: ColorTheme.error,
                      size: 24,
                    ),
                    onPressed: () => _showDeleteConfirmation(staff),
                  ),
                ],
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
        title: const Text('Delete Staff'),
        content: Text('Are you sure you want to delete ${staff.name}?'),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text(
              'Cancel',
              style: TextStyle(color: ColorTheme.textSecondary),
            ),
          ),
          TextButton(
            onPressed: () {
              Get.back();
              controller.deleteStaff(staff.id);
            },
            child: Text('Delete', style: TextStyle(color: ColorTheme.error)),
          ),
        ],
      ),
    );
  }
}
