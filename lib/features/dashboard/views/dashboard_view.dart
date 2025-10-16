// lib/features/dashboard/views/dashboard_view.dart
import 'package:emababyspa/features/notification/controllers/notification_controller.dart';
import 'package:emababyspa/utils/app_routes.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:emababyspa/common/layouts/main_layout.dart';
import 'package:emababyspa/features/dashboard/controllers/dashboard_controller.dart';
import 'package:emababyspa/common/theme/color_theme.dart';
import 'package:emababyspa/features/theme/controllers/theme_controller.dart';
import 'package:emababyspa/data/models/reservation.dart';
import 'package:emababyspa/utils/timezone_utils.dart';

class DashboardView extends GetView<DashboardController> {
  const DashboardView({super.key});

  String _getFormattedDisplayTime(Reservation? reservation) {
    if (reservation == null) return 'N/A';
    try {
      if (reservation.sessionDate != null) {
        DateTime baseUtcTime = reservation.sessionDate!;
        if (reservation.sessionTime != null &&
            reservation.sessionTime!.isNotEmpty) {
          String timeStr = reservation.sessionTime!;
          if (timeStr.contains(' - ')) {
            timeStr = timeStr.split(' - ')[0].trim();
          }
          final timeParts = timeStr.split(':');
          if (timeParts.length >= 2) {
            final hour = int.tryParse(timeParts[0]);
            final minute = int.tryParse(timeParts[1]);
            if (hour != null && minute != null) {
              baseUtcTime = DateTime.utc(
                baseUtcTime.year,
                baseUtcTime.month,
                baseUtcTime.day,
                hour,
                minute,
              );
            }
          }
        }
        return TimeZoneUtil.formatIndonesiaTime(baseUtcTime, format: 'HH:mm');
      }
      if (reservation.sessionTime != null &&
          reservation.sessionTime!.isNotEmpty) {
        String rawTime = reservation.sessionTime!;
        if (rawTime.contains(' - ')) {
          rawTime = rawTime.split(' - ')[0].trim();
        }
        return TimeZoneUtil.formatISOToIndonesiaTime(rawTime, format: 'HH:mm');
      }
    } catch (e) {
      debugPrint(
        'Error parsing time for reservation ${reservation.id}: $e. Fallback to raw value.',
      );
      return reservation.sessionTime ?? 'Waktu Error';
    }
    return 'N/A';
  }

  @override
  Widget build(BuildContext context) {
    final themeController = Get.find<ThemeController>();
    return MainLayout(
      showBottomNavigation: true,
      enablePullToRefresh: true,
      onRefresh: controller.refreshCurrentPage,
      child: Obx(() {
        if (controller.isLoading && controller.owner.value == null) {
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
              _buildUpcomingTodaySection(themeController),
              const SizedBox(height: 24),
              _buildQuickActions(themeController),
              const SizedBox(height: 24),
              _buildMonthlyAnalyticsSection(themeController),
              const SizedBox(height: 24),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildWelcomeSection(ThemeController themeController) {
    final notificationController = Get.find<NotificationController>();
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
                ? ColorTheme.primaryLightDark.withAlpha((255 * 0.8).round())
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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
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
                  ],
                ),
              ),
              Obx(() {
                return Stack(
                  children: [
                    IconButton(
                      icon: const Icon(
                        Icons.notifications_outlined,
                        color: Colors.white,
                        size: 28,
                      ),
                      onPressed: () {
                        Get.toNamed(AppRoutes.notification);
                      },
                    ),
                    if (notificationController.unreadCount.value > 0)
                      Positioned(
                        right: 8,
                        top: 8,
                        child: Container(
                          padding: const EdgeInsets.all(2),
                          decoration: BoxDecoration(
                            color: Colors.red,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: Colors.white, width: 1.5),
                          ),
                          constraints: const BoxConstraints(
                            minWidth: 18,
                            minHeight: 18,
                          ),
                          child: Center(
                            child: Text(
                              '${notificationController.unreadCount.value}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                      ),
                  ],
                );
              }),
            ],
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
          'Ringkasan Hari Ini',
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
        Obx(
          () => _buildLargeStatCard(
            title: 'Total Penghasilan Hari Ini',
            value: controller.totalRevenueTodayFormatted,
            icon: Icons.monetization_on,
            color: Colors.teal,
            themeController: themeController,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: Obx(
                () => _buildStatCard(
                  title: 'Total Reservasi',
                  value: controller.totalAppointmentsToday,
                  icon: Icons.calendar_today_outlined,
                  color: Colors.blue,
                  themeController: themeController,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Obx(
                () => _buildStatCard(
                  title: 'Reservasi Mendatang',
                  value: controller.upcomingReservationsTodayCount.value,
                  icon: Icons.pending_actions_outlined,
                  color: Colors.purple,
                  themeController: themeController,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

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

          final Reservation? currentRes =
              controller.currentReservationForCarousel.value;
          if (currentRes == null) {
            return const Center(child: Text("Error memuat jadwal."));
          }

          final String startTimeDisplay = _getFormattedDisplayTime(currentRes);
          final String customerName = currentRes.customerName ?? 'N/A';
          final String serviceName = currentRes.serviceName ?? 'N/A';
          final String staffName = currentRes.staffName ?? 'N/A';

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
                      splashRadius: 24.0,
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
                      splashRadius: 24.0,
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
          childAspectRatio: 1.3,
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
              title: 'Kelola Jadwal',
              icon: Icons.event_note_outlined,
              color: Colors.lightBlue,
              onTap: () => Get.toNamed('/schedule'),
              themeController: themeController,
            ),
            _buildQuickActionCard(
              title: 'Profil & Pengaturan',
              icon: Icons.settings_outlined,
              color: Colors.grey,
              onTap: () => Get.toNamed('/account'),
              themeController: themeController,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildMonthlyAnalyticsSection(ThemeController themeController) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Analitik Bulan Ini',
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
          if (controller.isLoadingAnalytics.value &&
              controller.detailsDataThisMonth.value == null) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(32.0),
                child: CircularProgressIndicator(),
              ),
            );
          }
          return GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 1.0,
            children: [
              _buildStatCard(
                title: 'Total Penghasilan',
                value: controller.totalRevenueThisMonthFormatted,
                icon: Icons.monetization_on_outlined,
                color: Colors.green,
                themeController: themeController,
              ),
              _buildStatCard(
                title: 'Total Reservasi',
                value: controller.totalReservationsThisMonth,
                icon: Icons.event_available_outlined,
                color: Colors.purple,
                themeController: themeController,
              ),
              _buildStatCard(
                title: 'Sesi Selesai',
                value: controller.completedReservationsThisMonth,
                icon: Icons.check_circle_outline,
                color: Colors.cyan,
                themeController: themeController,
              ),
              _buildStatCard(
                title: 'Sesi Dibatalkan',
                value: controller.cancelledReservationsThisMonth,
                icon: Icons.cancel_outlined,
                color: Colors.redAccent,
                themeController: themeController,
              ),
            ],
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
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
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
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withAlpha((255 * 0.1).round()),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 32),
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
                    fontSize: 14,
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
                    fontSize: 28,
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
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withAlpha((255 * 0.1).round()),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(height: 12),
          Text(
            value,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontFamily: 'JosefinSans',
              fontSize: 18,
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
                  fontSize: 12,
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
}
