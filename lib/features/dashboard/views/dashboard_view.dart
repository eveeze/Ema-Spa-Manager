// lib/features/dashboard/views/dashboard_view.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:emababyspa/common/layouts/main_layout.dart';
import 'package:emababyspa/features/dashboard/controllers/dashboard_controller.dart';
import 'package:emababyspa/common/theme/color_theme.dart';
import 'package:emababyspa/features/theme/controllers/theme_controller.dart';
import 'package:emababyspa/data/models/reservation.dart'; // Import Reservation model
import 'package:intl/intl.dart'; // For date formatting
import 'package:emababyspa/utils/timezone_utils.dart'; // IMPORT TimeZoneUtil

class DashboardView extends GetView<DashboardController> {
  const DashboardView({super.key});

  @override
  Widget build(BuildContext context) {
    final themeController = Get.find<ThemeController>();

    return MainLayout(
      showBottomNavigation: true,
      enablePullToRefresh: true,
      onRefresh: controller.refreshCurrentPage,
      child: Obx(() {
        // Use the combined isLoading getter from the controller
        if (controller.isLoading && controller.owner.value == null) {
          // Show main loader only if everything is loading initially
          return const Center(child: CircularProgressIndicator());
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildWelcomeSection(themeController),
              const SizedBox(height: 24),
              _buildDashboardSummarySection(themeController),
              const SizedBox(height: 24),
              _buildUpcomingTodaySection(themeController), // NEW SECTION
              const SizedBox(height: 24),
              _buildQuickActions(themeController),
              const SizedBox(height: 24),
              _buildRecentActivities(themeController),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildWelcomeSection(ThemeController themeController) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            themeController.isDarkMode
                ? ColorTheme.primaryLightDark.withAlpha((255 * 0.8).round())
                : ColorTheme.primary.withAlpha((255 * 0.8).round()),
            themeController.isDarkMode
                ? ColorTheme.primaryLightDark.withAlpha(
                  (255 * 0.8).round(),
                ) // Assuming same opacity for end color
                : ColorTheme.primary.withAlpha((255 * 0.8).round()),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: (themeController.isDarkMode
                    ? ColorTheme.primaryLightDark
                    : ColorTheme.primary)
                .withAlpha((255 * 0.3).round()),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Selamat Datang',
            style: TextStyle(
              fontFamily: 'JosefinSans',
              fontSize: 16,
              color: Colors.white.withAlpha((255 * 0.9).round()),
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          Obx(
            () => Text(
              controller.owner.value?.name ?? 'Owner',
              style: const TextStyle(
                fontFamily: 'JosefinSans',
                fontSize: 24,
                color: Colors.white,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Kelola spa bayi Anda dengan mudah',
            style: TextStyle(
              fontFamily: 'JosefinSans',
              fontSize: 14,
              color: Colors.white.withAlpha((255 * 0.8).round()),
              fontWeight: FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDashboardSummarySection(ThemeController themeController) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Ringkasan Hari Ini', // New Title
          style: TextStyle(
            fontFamily: 'JosefinSans',
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color:
                themeController.isDarkMode
                    ? ColorTheme.textPrimaryDark
                    : ColorTheme.textPrimary,
          ),
        ),
        const SizedBox(height: 16),
        _buildLargeStatCard(
          title: 'Total Penghasilan Hari Ini',
          value: controller.totalRevenueToday.value, // Ensure this is updated
          icon: Icons.monetization_on,
          color: Colors.teal,
          themeController: themeController,
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                title: 'Total Reservasi',
                value: controller.todayAppointments.value,
                icon: Icons.calendar_today_outlined,
                color: Colors.blue,
                themeController: themeController,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildStatCard(
                title: 'Upcoming Reservasi',
                value:
                    controller
                        .upcomingReservationsTodayCount
                        .value, // This shows the total count for the day
                icon: Icons.pending_actions_outlined,
                color: Colors.purple,
                themeController: themeController,
              ),
            ),
          ],
        ),
      ],
    );
  }

  // New Section for Upcoming Reservation Carousel
  // New Section for Upcoming Reservation Carousel
  Widget _buildUpcomingTodaySection(ThemeController themeController) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Jadwal Mendatang Hari Ini',
          style: TextStyle(
            fontFamily: 'JosefinSans',
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color:
                themeController.isDarkMode
                    ? ColorTheme.textPrimaryDark
                    : ColorTheme.textPrimary,
          ),
        ),
        const SizedBox(height: 16),
        Obx(() {
          if (controller.isLoadingUpcomingCarousel.value &&
              controller.upcomingReservationsTodayList.isEmpty) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: CircularProgressIndicator(),
              ),
            );
          }

          if (controller.upcomingReservationsTodayList.isEmpty) {
            return Container(
              width: double.infinity,
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                color:
                    themeController.isDarkMode
                        ? ColorTheme.surfaceDark
                        : ColorTheme.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color:
                      themeController.isDarkMode
                          ? ColorTheme.borderDark
                          : ColorTheme.border,
                  width: 1,
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.event_busy_outlined,
                    size: 48,
                    color: (themeController.isDarkMode
                            ? ColorTheme.textSecondaryDark
                            : ColorTheme.textSecondary)
                        .withAlpha((255 * 0.7).round()),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Tidak ada jadwal mendatang hari ini.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: 'JosefinSans',
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color:
                          themeController.isDarkMode
                              ? ColorTheme.textSecondaryDark
                              : ColorTheme.textSecondary,
                    ),
                  ),
                ],
              ),
            );
          }

          // Display the current reservation
          final Reservation? currentRes =
              controller.currentReservationForCarousel.value;
          if (currentRes == null) {
            return const Center(child: Text("Error memuat jadwal."));
          }

          String startTimeDisplay = 'N/A';

          // FIXED: Use only available properties from Reservation model
          try {
            // Primary: Use sessionTime if available
            if (currentRes.sessionTime != null &&
                currentRes.sessionTime!.isNotEmpty) {
              String rawTime = currentRes.sessionTime!;

              if (rawTime.contains(' - ')) {
                startTimeDisplay = rawTime.split(' - ')[0];
              }
              // If sessionTime is in ISO DateTime format, parse to HH:mm
              else if (rawTime.contains('T')) {
                startTimeDisplay = TimeZoneUtil.formatISOToIndonesiaTime(
                  rawTime,
                  format: 'HH:mm',
                );
              } else if (RegExp(r'^\d{1,2}:\d{2}$').hasMatch(rawTime)) {
                // Case: Already in "HH:mm" format
                startTimeDisplay = rawTime;
              } else {
                // Try to parse as ISO format
                startTimeDisplay = TimeZoneUtil.formatISOToIndonesiaTime(
                  rawTime,
                  format: 'HH:mm',
                );
              }
            }
            // Fallback: Use sessionDate if sessionTime is not available
            else if (currentRes.sessionDate != null) {
              startTimeDisplay = TimeZoneUtil.formatIndonesiaTime(
                currentRes.sessionDate!,
                format: 'HH:mm',
              );
            }
          } catch (e) {
            // Use debugPrint instead of print for better logging
            debugPrint('Error parsing time: $e');
            startTimeDisplay = 'N/A';
          }

          String customerName = currentRes.customerName ?? 'N/A';
          String serviceName = currentRes.serviceName ?? 'N/A';
          String staffName = currentRes.staffName ?? 'N/A';

          return Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color:
                  themeController.isDarkMode
                      ? ColorTheme.surfaceDark.withAlpha((255 * 0.8).round())
                      : ColorTheme.surface.withAlpha((255 * 0.9).round()),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color:
                    themeController.isDarkMode
                        ? ColorTheme.borderDark.withAlpha((255 * 0.5).round())
                        : ColorTheme.border.withAlpha((255 * 0.5).round()),
              ),
              boxShadow: [
                BoxShadow(
                  color:
                      themeController.isDarkMode
                          ? Colors.black.withAlpha((255 * 0.25).round())
                          : Colors.grey.withAlpha((255 * 0.15).round()),
                  blurRadius: 10,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      icon: Icon(
                        Icons.arrow_back_ios_new,
                        color:
                            themeController.isDarkMode
                                ? Colors.white70
                                : Colors.black54,
                      ),
                      onPressed:
                          controller.upcomingReservationsTodayList.length > 1
                              ? controller.previousUpcomingReservation
                              : null,
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(
                            startTimeDisplay,
                            style: TextStyle(
                              fontFamily: 'JosefinSans',
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color:
                                  themeController.isDarkMode
                                      ? ColorTheme.primaryLightDark
                                      : ColorTheme.primary,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            "${controller.currentUpcomingReservationIndex.value + 1} dari ${controller.upcomingReservationsTodayList.length}",
                            style: TextStyle(
                              fontFamily: 'JosefinSans',
                              fontSize: 12,
                              color:
                                  themeController.isDarkMode
                                      ? ColorTheme.textSecondaryDark
                                      : ColorTheme.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: Icon(
                        Icons.arrow_forward_ios,
                        color:
                            themeController.isDarkMode
                                ? Colors.white70
                                : Colors.black54,
                      ),
                      onPressed:
                          controller.upcomingReservationsTodayList.length > 1
                              ? controller.nextUpcomingReservation
                              : null,
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                _buildInfoRow(
                  themeController,
                  icon: Icons.person_outline,
                  label: 'Customer:',
                  value: customerName,
                ),
                const SizedBox(height: 8),
                _buildInfoRow(
                  themeController,
                  icon: Icons.spa_outlined,
                  label: 'Layanan:',
                  value: serviceName,
                ),
                const SizedBox(height: 8),
                _buildInfoRow(
                  themeController,
                  icon: Icons.support_agent_outlined,
                  label: 'Terapis:',
                  value: staffName,
                ),
              ],
            ),
          );
        }),
      ],
    );
  }

  Widget _buildInfoRow(
    ThemeController themeController, {
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      children: [
        Icon(
          icon,
          size: 18,
          color:
              themeController.isDarkMode
                  ? ColorTheme.textSecondaryDark
                  : ColorTheme.textSecondary,
        ),
        const SizedBox(width: 8),
        Text(
          '$label ',
          style: TextStyle(
            fontFamily: 'JosefinSans',
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color:
                themeController.isDarkMode
                    ? ColorTheme.textSecondaryDark
                    : ColorTheme.textSecondary,
          ),
        ),
        Expanded(
          child: Text(
            value,
            textAlign: TextAlign.end,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontFamily: 'JosefinSans',
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color:
                  themeController.isDarkMode
                      ? ColorTheme.textPrimaryDark
                      : ColorTheme.textPrimary,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLargeStatCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
    required ThemeController themeController,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: 20,
        vertical: 24,
      ), // Larger padding
      decoration: BoxDecoration(
        color:
            themeController.isDarkMode
                ? ColorTheme.surfaceDark
                : ColorTheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color:
              themeController.isDarkMode
                  ? ColorTheme.borderDark
                  : ColorTheme.border,
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color:
                themeController.isDarkMode
                    ? Colors.black.withAlpha((255 * 0.2).round())
                    : Colors.grey.withAlpha((255 * 0.1).round()),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12), // Larger icon container
            decoration: BoxDecoration(
              color: color.withAlpha((255 * 0.1).round()),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 32), // Larger icon
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontFamily: 'JosefinSans',
                    fontSize:
                        14, // Slightly smaller title for emphasis on value
                    fontWeight: FontWeight.w500,
                    color:
                        themeController.isDarkMode
                            ? ColorTheme.textSecondaryDark
                            : ColorTheme.textSecondary,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  value,
                  style: TextStyle(
                    fontFamily: 'JosefinSans',
                    fontSize: 28, // Larger value
                    fontWeight: FontWeight.w700,
                    color:
                        themeController.isDarkMode
                            ? ColorTheme.textPrimaryDark
                            : ColorTheme.textPrimary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
    required ThemeController themeController,
    bool isFullWidth = false,
  }) {
    return Container(
      width: isFullWidth ? double.infinity : null,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color:
            themeController.isDarkMode
                ? ColorTheme.surfaceDark
                : ColorTheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color:
              themeController.isDarkMode
                  ? ColorTheme.borderDark
                  : ColorTheme.border,
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color:
                themeController.isDarkMode
                    ? Colors.black.withAlpha((255 * 0.2).round())
                    : Colors.grey.withAlpha((255 * 0.1).round()),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withAlpha((255 * 0.1).round()),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: color, size: 20),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: TextStyle(
              fontFamily: 'JosefinSans',
              fontSize: 22, // Adjusted size
              fontWeight: FontWeight.w700,
              color:
                  themeController.isDarkMode
                      ? ColorTheme.textPrimaryDark
                      : ColorTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontFamily: 'JosefinSans',
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color:
                  themeController.isDarkMode
                      ? ColorTheme.textSecondaryDark
                      : ColorTheme.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions(ThemeController themeController) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Aksi Cepat',
          style: TextStyle(
            fontFamily: 'JosefinSans',
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color:
                themeController.isDarkMode
                    ? ColorTheme.textPrimaryDark
                    : ColorTheme.textPrimary,
          ),
        ),
        const SizedBox(height: 16),
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 1.5,
          children: [
            _buildQuickActionCard(
              title: 'Kelola Layanan',
              icon: Icons.spa_outlined,
              color: Colors.purple,
              onTap: () => Get.toNamed('/services/manage'),
              themeController: themeController,
            ),
            _buildQuickActionCard(
              title: 'Lihat Statistik',
              icon: Icons.bar_chart_outlined,
              color: Colors.orange,
              onTap: () => Get.toNamed('/analytics'),
              themeController: themeController,
            ),
            _buildQuickActionCard(
              title: 'Kelola Reservasi',
              icon: Icons.event_note_outlined,
              color: Colors.lightBlue,
              onTap: () => Get.toNamed('/reservations/manage'),
              themeController: themeController,
            ),
            _buildQuickActionCard(
              title: 'Profil & Pengaturan',
              icon: Icons.settings_outlined,
              color: Colors.grey,
              onTap: () => Get.toNamed('/profile/settings'),
              themeController: themeController,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildQuickActionCard({
    required String title,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
    required ThemeController themeController,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color:
                themeController.isDarkMode
                    ? ColorTheme.surfaceDark
                    : ColorTheme.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color:
                  themeController.isDarkMode
                      ? ColorTheme.borderDark
                      : ColorTheme.border,
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color:
                    themeController.isDarkMode
                        ? Colors.black.withAlpha((255 * 0.2).round())
                        : Colors.grey.withAlpha((255 * 0.1).round()),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: color.withAlpha((255 * 0.1).round()),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: color, size: 22),
              ),
              const SizedBox(height: 8),
              Text(
                title,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'JosefinSans',
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color:
                      themeController.isDarkMode
                          ? ColorTheme.textPrimaryDark
                          : ColorTheme.textPrimary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRecentActivities(ThemeController themeController) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Aktivitas Terbaru',
              style: TextStyle(
                fontFamily: 'JosefinSans',
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color:
                    themeController.isDarkMode
                        ? ColorTheme.textPrimaryDark
                        : ColorTheme.textPrimary,
              ),
            ),
            TextButton(
              onPressed: () {
                // TODO: Navigate to full activity list
                // Get.toNamed('/activities');
              },
              child: Text(
                'Lihat Semua',
                style: TextStyle(
                  fontFamily: 'JosefinSans',
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color:
                      themeController.isDarkMode
                          ? ColorTheme.primaryLightDark
                          : ColorTheme.primary,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Obx(() {
          if (controller.isLoadingActivities.value &&
              controller.recentActivities.isEmpty) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: Text("Memuat aktivitas..."),
              ),
            );
          }
          if (controller.recentActivities.isEmpty) {
            return Container(
              width: double.infinity,
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                color:
                    themeController.isDarkMode
                        ? ColorTheme.surfaceDark
                        : ColorTheme.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color:
                      themeController.isDarkMode
                          ? ColorTheme.borderDark
                          : ColorTheme.border,
                  width: 1,
                ),
              ),
              child: Column(
                children: [
                  Icon(
                    Icons.history_toggle_off_outlined,
                    size: 48,
                    color: (themeController.isDarkMode
                            ? ColorTheme.textSecondaryDark
                            : ColorTheme.textSecondary)
                        .withAlpha((255 * 0.7).round()),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Belum ada aktivitas terbaru',
                    style: TextStyle(
                      fontFamily: 'JosefinSans',
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color:
                          themeController.isDarkMode
                              ? ColorTheme.textSecondaryDark
                              : ColorTheme.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Aktivitas akan muncul di sini.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: 'JosefinSans',
                      fontSize: 14,
                      color: (themeController.isDarkMode
                              ? ColorTheme.textSecondaryDark
                              : ColorTheme.textSecondary)
                          .withAlpha((255 * 0.8).round()),
                    ),
                  ),
                ],
              ),
            );
          }

          return ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount:
                controller.recentActivities.length > 5
                    ? 5
                    : controller.recentActivities.length,
            separatorBuilder: (context, index) => const SizedBox(height: 8),
            itemBuilder: (context, index) {
              final activity = controller.recentActivities[index];
              return _buildActivityItem(activity, themeController);
            },
          );
        }),
      ],
    );
  }

  Widget _buildActivityItem(
    Map<String, dynamic> activity,
    ThemeController themeController,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color:
            themeController.isDarkMode
                ? ColorTheme.surfaceDark
                : ColorTheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color:
              themeController.isDarkMode
                  ? ColorTheme.borderDark
                  : ColorTheme.border,
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: (activity['color'] as Color? ?? Colors.grey).withAlpha(
                (255 * 0.1).round(),
              ), // Corrected
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              activity['icon'] as IconData? ?? Icons.info_outline,
              color: activity['color'] as Color? ?? Colors.grey,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  activity['title'] as String? ?? 'N/A',
                  style: TextStyle(
                    fontFamily: 'JosefinSans',
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color:
                        themeController.isDarkMode
                            ? ColorTheme.textPrimaryDark
                            : ColorTheme.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  activity['description'] as String? ?? 'No description',
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontFamily: 'JosefinSans',
                    fontSize: 12,
                    color:
                        themeController.isDarkMode
                            ? ColorTheme.textSecondaryDark
                            : ColorTheme.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Text(
            activity['time'] as String? ?? '',
            style: TextStyle(
              fontFamily: 'JosefinSans',
              fontSize: 12,
              color:
                  themeController.isDarkMode
                      ? ColorTheme.textSecondaryDark
                      : ColorTheme.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
