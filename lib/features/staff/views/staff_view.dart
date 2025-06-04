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
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return MainLayout(
      child: Scaffold(
        backgroundColor:
            isDarkMode ? ColorTheme.backgroundDark : ColorTheme.background,
        appBar: const CustomAppBar(
          title: 'Staff Management',
          showBackButton: true,
        ),
        floatingActionButton: Container(
          margin: const EdgeInsets.only(
            bottom: 16,
          ), // Add margin to prevent overlap
          child: FloatingActionButton.extended(
            onPressed: controller.navigateToAddStaff,
            backgroundColor:
                isDarkMode ? ColorTheme.primaryLightDark : ColorTheme.primary,
            foregroundColor: isDarkMode ? Colors.black : Colors.white,
            elevation: 8, // Increased elevation for better visibility
            highlightElevation: 12,
            splashColor: (isDarkMode ? Colors.black : Colors.white).withValues(
              alpha: 0.2,
            ),
            icon: Container(
              padding: const EdgeInsets.all(2),
              decoration: BoxDecoration(borderRadius: BorderRadius.circular(8)),
              child: Icon(
                Icons.person_add_alt_1_rounded, // More specific icon
                color: isDarkMode ? Colors.black : Colors.white,
                size: 20,
              ),
            ),
            label: Text(
              'Add Team Member', // More descriptive label
              style: TextStyle(
                color: isDarkMode ? Colors.black : Colors.white,
                fontFamily: 'JosefinSans',
                fontWeight: FontWeight.w700, // Bolder text
                fontSize: 15, // Slightly larger
                letterSpacing: 0.5,
              ),
            ),
            extendedPadding: const EdgeInsets.symmetric(
              horizontal: 20,
              vertical: 0,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(28), // More rounded
            ),
          ),
        ),
        floatingActionButtonLocation:
            FloatingActionButtonLocation.endFloat, // Bett
        body: SafeArea(
          child: RefreshIndicator(
            onRefresh: () async {
              controller.refreshData();
            },
            color:
                isDarkMode ? ColorTheme.primaryLightDark : ColorTheme.primary,
            backgroundColor: isDarkMode ? ColorTheme.surfaceDark : Colors.white,
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
                                color:
                                    isDarkMode
                                        ? ColorTheme.textPrimaryDark
                                        : ColorTheme.textPrimary,
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
                                  color:
                                      isDarkMode
                                          ? ColorTheme.textSecondaryDark
                                          : ColorTheme.textSecondary,
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
                            color:
                                isDarkMode
                                    ? ColorTheme.primaryLightDark.withValues(
                                      alpha: 0.2,
                                    )
                                    : ColorTheme.primaryLight,
                            borderRadius: BorderRadius.circular(24),
                          ),
                          child: Text(
                            '${controller.staffList.length}',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color:
                                  isDarkMode
                                      ? ColorTheme.primaryLightDark
                                      : ColorTheme.primaryDark,
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
                                  isDarkMode
                                      ? ColorTheme.primaryLightDark
                                      : ColorTheme.primary,
                                ),
                                strokeWidth: 3,
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'Loading staff...',
                                style: TextStyle(
                                  color:
                                      isDarkMode
                                          ? ColorTheme.textSecondaryDark
                                          : ColorTheme.textSecondary,
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

                      return _buildStaffList(context);
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

  Widget _buildStaffList(BuildContext context) {
    return ListView.separated(
      physics: const BouncingScrollPhysics(),
      itemCount: controller.staffList.length,
      separatorBuilder: (context, index) => const SizedBox(height: 16),
      itemBuilder: (context, index) {
        final staff = controller.staffList[index];
        return _buildStaffCard(context, staff);
      },
    );
  }

  Widget _buildStaffCard(BuildContext context, Staff staff) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.only(
        bottom: 4,
      ), // Add subtle spacing between cards
      decoration: BoxDecoration(
        color: isDarkMode ? ColorTheme.surfaceDark : Colors.white,
        borderRadius: BorderRadius.circular(
          20,
        ), // Increased from 16 for softer look
        border:
            isDarkMode
                ? Border.all(
                  color: ColorTheme.borderDark.withValues(alpha: 0.3),
                  width: 1,
                )
                : null,
        boxShadow: [
          BoxShadow(
            color:
                isDarkMode
                    ? Colors.black.withValues(alpha: 0.2)
                    : Colors.black.withValues(alpha: 0.08), // Enhanced shadow
            blurRadius: 16, // Increased blur
            spreadRadius: 0,
            offset: const Offset(0, 6), // Slightly more offset
          ),
          // Add secondary shadow for depth
          BoxShadow(
            color:
                isDarkMode
                    ? Colors.black.withValues(alpha: 0.1)
                    : Colors.black.withValues(alpha: 0.02),
            blurRadius: 4,
            spreadRadius: 0,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => controller.navigateToEditStaff(staff.id),
          borderRadius: BorderRadius.circular(20),
          splashColor: (isDarkMode
                  ? ColorTheme.primaryLightDark
                  : ColorTheme.primaryLight)
              .withValues(alpha: 0.15),
          highlightColor: (isDarkMode
                  ? ColorTheme.primaryLightDark
                  : ColorTheme.primaryLight)
              .withValues(alpha: 0.08),
          child: Padding(
            padding: const EdgeInsets.all(20.0), // Increased padding
            child: Column(
              children: [
                Row(
                  crossAxisAlignment:
                      CrossAxisAlignment.start, // Better alignment
                  children: [
                    // Enhanced profile image container
                    Stack(
                      children: [
                        Container(
                          width: 72, // Slightly larger
                          height: 72,
                          decoration: BoxDecoration(
                            color: (isDarkMode
                                    ? ColorTheme.accentDark
                                    : ColorTheme.accent)
                                .withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(36),
                            border: Border.all(
                              color:
                                  staff.isActive
                                      ? (isDarkMode
                                          ? ColorTheme.primaryLightDark
                                          : ColorTheme.primary)
                                      : (isDarkMode
                                          ? ColorTheme.borderDark
                                          : ColorTheme.divider),
                              width: 3, // Thicker border
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: (isDarkMode
                                        ? ColorTheme.primaryLightDark
                                        : ColorTheme.primary)
                                    .withValues(alpha: 0.2),
                                blurRadius: 12,
                                spreadRadius: 0,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child:
                              staff.profilePicture != null &&
                                      staff.profilePicture!.isNotEmpty
                                  ? ClipRRect(
                                    borderRadius: BorderRadius.circular(33),
                                    child: Image.network(
                                      staff.profilePicture!,
                                      width: 66,
                                      height: 66,
                                      fit: BoxFit.cover,
                                      errorBuilder: (
                                        context,
                                        error,
                                        stackTrace,
                                      ) {
                                        return Icon(
                                          Icons.person_rounded,
                                          size: 36,
                                          color:
                                              isDarkMode
                                                  ? ColorTheme.primaryLightDark
                                                  : ColorTheme.primary,
                                        );
                                      },
                                    ),
                                  )
                                  : Icon(
                                    Icons.person_rounded,
                                    size: 36,
                                    color:
                                        isDarkMode
                                            ? ColorTheme.primaryLightDark
                                            : ColorTheme.primary,
                                  ),
                        ),
                        // Status indicator dot
                        Positioned(
                          bottom: 2,
                          right: 2,
                          child: Container(
                            width: 20,
                            height: 20,
                            decoration: BoxDecoration(
                              color:
                                  staff.isActive
                                      ? (isDarkMode
                                          ? ColorTheme.successDark
                                          : ColorTheme.success)
                                      : (isDarkMode
                                          ? ColorTheme.errorDark
                                          : ColorTheme.error),
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color:
                                    isDarkMode
                                        ? ColorTheme.surfaceDark
                                        : Colors.white,
                                width: 2,
                              ),
                            ),
                            child: Icon(
                              staff.isActive ? Icons.check : Icons.close,
                              size: 12,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(width: 24), // Increased spacing
                    // Enhanced staff info section
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Name with enhanced typography
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  staff.name,
                                  style: TextStyle(
                                    fontSize: 20, // Larger font
                                    fontWeight: FontWeight.w700, // Bolder
                                    fontFamily: 'JosefinSans',
                                    color:
                                        isDarkMode
                                            ? ColorTheme.textPrimaryDark
                                            : ColorTheme.textPrimary,
                                    letterSpacing:
                                        -0.3, // Tighter letter spacing
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              // Enhanced status pill badge
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color:
                                      staff.isActive
                                          ? (isDarkMode
                                              ? ColorTheme.successDark
                                                  .withValues(alpha: 0.2)
                                              : const Color(0xFFE8F5E8))
                                          : (isDarkMode
                                              ? ColorTheme.errorDark.withValues(
                                                alpha: 0.2,
                                              )
                                              : const Color(0xFFFFF0F0)),
                                  borderRadius: BorderRadius.circular(
                                    20,
                                  ), // Full rounded
                                  border: Border.all(
                                    color:
                                        staff.isActive
                                            ? (isDarkMode
                                                ? ColorTheme.successDark
                                                : ColorTheme.success)
                                            : (isDarkMode
                                                ? ColorTheme.errorDark
                                                : ColorTheme.error),
                                    width: 1,
                                  ),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      staff.isActive
                                          ? Icons.check_circle
                                          : Icons.cancel,
                                      size: 14,
                                      color:
                                          staff.isActive
                                              ? (isDarkMode
                                                  ? ColorTheme.successDark
                                                  : ColorTheme.success)
                                              : (isDarkMode
                                                  ? ColorTheme.errorDark
                                                  : ColorTheme.error),
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      staff.isActive ? 'Active' : 'Inactive',
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w700,
                                        color:
                                            staff.isActive
                                                ? (isDarkMode
                                                    ? ColorTheme.successDark
                                                    : ColorTheme.success)
                                                : (isDarkMode
                                                    ? ColorTheme.errorDark
                                                    : ColorTheme.error),
                                        fontFamily: 'JosefinSans',
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12), // Increased spacing
                          // Enhanced contact info with better contrast
                          _buildContactRow(
                            context,
                            Icons.email_rounded,
                            staff.email,
                            isDarkMode,
                          ),
                          const SizedBox(height: 8),
                          _buildContactRow(
                            context,
                            Icons.phone_rounded,
                            staff.phoneNumber,
                            isDarkMode,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                // Enhanced action buttons section
                Padding(
                  padding: const EdgeInsets.only(top: 20),
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color:
                          isDarkMode
                              ? ColorTheme.backgroundDark.withValues(alpha: 0.3)
                              : ColorTheme.background,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        // Enhanced Edit button
                        _buildEnhancedActionButton(
                          context: context,
                          label: 'Edit',
                          icon: Icons.edit_rounded,
                          color:
                              isDarkMode
                                  ? ColorTheme.infoDark
                                  : ColorTheme.info,
                          onTap: () => controller.navigateToEditStaff(staff.id),
                        ),

                        // Enhanced Toggle status button
                        _buildEnhancedActionButton(
                          context: context,
                          label: staff.isActive ? 'Deactivate' : 'Activate',
                          icon:
                              staff.isActive
                                  ? Icons.person_off_rounded
                                  : Icons.person_add_rounded,
                          color:
                              staff.isActive
                                  ? (isDarkMode
                                      ? ColorTheme.warningDark
                                      : ColorTheme.warning)
                                  : (isDarkMode
                                      ? ColorTheme.successDark
                                      : ColorTheme.success),
                          onTap: () => controller.toggleStaffStatus(staff),
                        ),

                        // Enhanced Delete button
                        _buildEnhancedActionButton(
                          context: context,
                          label: 'Delete',
                          icon: Icons.delete_rounded,
                          color:
                              isDarkMode
                                  ? ColorTheme.errorDark
                                  : ColorTheme.error,
                          onTap: () => _showDeleteConfirmation(context, staff),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Helper method for contact information rows
  Widget _buildContactRow(
    BuildContext context,
    IconData icon,
    String text,
    bool isDarkMode,
  ) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: (isDarkMode
                    ? ColorTheme.primaryLightDark
                    : ColorTheme.primary)
                .withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            size: 16,
            color:
                isDarkMode ? ColorTheme.primaryLightDark : ColorTheme.primary,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              fontSize: 15, // Slightly larger for better readability
              fontWeight: FontWeight.w500, // Medium weight for better contrast
              color:
                  isDarkMode
                      ? ColorTheme.textPrimaryDark.withValues(alpha: 0.9)
                      : ColorTheme.textPrimary.withValues(
                        alpha: 0.8,
                      ), // Better contrast
              fontFamily: 'JosefinSans',
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _buildEnhancedActionButton({
    required BuildContext context,
    required String label,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 4),
        child: Material(
          color: color.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(12),
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(12),
            splashColor: color.withValues(alpha: 0.2),
            highlightColor: color.withValues(alpha: 0.1),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(icon, size: 18, color: color),
                  const SizedBox(height: 4),
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: 11,
                      color: color,
                      fontWeight: FontWeight.w600,
                      fontFamily: 'JosefinSans',
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // Show delete confirmation dialog
  void _showDeleteConfirmation(BuildContext context, Staff staff) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    Get.dialog(
      AlertDialog(
        backgroundColor: isDarkMode ? ColorTheme.surfaceDark : Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          'Delete Staff Member',
          style: TextStyle(
            fontFamily: 'JosefinSans',
            fontWeight: FontWeight.bold,
            color:
                isDarkMode
                    ? ColorTheme.textPrimaryDark
                    : ColorTheme.textPrimary,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: (isDarkMode ? ColorTheme.errorDark : ColorTheme.error)
                    .withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                Icons.warning_amber_rounded,
                color: isDarkMode ? ColorTheme.errorDark : ColorTheme.error,
                size: 48,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Are you sure you want to delete ${staff.name}?',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'JosefinSans',
                fontSize: 16,
                color:
                    isDarkMode
                        ? ColorTheme.textPrimaryDark
                        : ColorTheme.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'This action cannot be undone.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'JosefinSans',
                fontSize: 14,
                color:
                    isDarkMode
                        ? ColorTheme.textSecondaryDark
                        : ColorTheme.textSecondary,
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
                color:
                    isDarkMode
                        ? ColorTheme.textSecondaryDark
                        : ColorTheme.textSecondary,
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
              backgroundColor:
                  isDarkMode ? ColorTheme.errorDark : ColorTheme.error,
              foregroundColor: isDarkMode ? Colors.black : Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            ),
            child: Text(
              'Delete',
              style: TextStyle(
                fontFamily: 'JosefinSans',
                fontWeight: FontWeight.w600,
                color: isDarkMode ? Colors.black : Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
