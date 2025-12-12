import 'package:emababyspa/features/notification/controllers/notification_controller.dart';
import 'package:emababyspa/utils/app_routes.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:emababyspa/common/layouts/main_layout.dart';
import 'package:emababyspa/features/dashboard/controllers/dashboard_controller.dart';
import 'package:emababyspa/data/models/reservation.dart';
import 'package:emababyspa/utils/timezone_utils.dart';

/// REFACTORED: DashboardView - Soft Spa/Wellness Color Palette
///
/// PERUBAHAN UTAMA:
/// ✅ Warna pastel yang soft & calming (biru muda, mint, lavender, rose)
/// ✅ Glassmorphism effect dengan gradient subtle
/// ✅ Konsisten dengan Theme API (tidak ada hardcoded colors untuk text/bg)
/// ✅ Spacing menggunakan kelipatan 8 (8, 16, 24, 32)
/// ✅ Modern & cocok untuk Baby Spa

class DashboardView extends GetView<DashboardController> {
  const DashboardView({super.key});

  // Spa Color Palette - Soft & Calming (untuk accent saja)
  static const Color _spaLightBlue = Color(0xFF85C1E2);
  static const Color _spaMint = Color(0xFF8BC9C3);
  static const Color _spaLavender = Color(0xFFA8B5E8);
  static const Color _spaRose = Color(0xFFE8A5B8);

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
      debugPrint('Error time parsing: $e');
      return reservation.sessionTime ?? 'Error';
    }
    return 'N/A';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return MainLayout(
      showBottomNavigation: true,
      enablePullToRefresh: true,
      onRefresh: controller.refreshCurrentPage,
      child: Obx(() {
        if (controller.isLoading && controller.owner.value == null) {
          return Center(
            child: CircularProgressIndicator(color: theme.colorScheme.primary),
          );
        }
        return SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildWelcomeHeader(context),
              const SizedBox(height: 32),
              _buildSectionTitle(context, 'Ringkasan Hari Ini'),
              const SizedBox(height: 16),
              _buildDailyStats(context),
              const SizedBox(height: 32),
              _buildSectionTitle(context, 'Jadwal Berikutnya'),
              const SizedBox(height: 16),
              _buildUpcomingSession(context),
              const SizedBox(height: 32),
              _buildSectionTitle(context, 'Aksi Cepat'),
              const SizedBox(height: 16),
              _buildQuickActionsGrid(context),
              const SizedBox(height: 32),
              _buildSectionTitle(context, 'Performa Bulan Ini'),
              const SizedBox(height: 16),
              _buildMonthlyAnalytics(context),
              const SizedBox(height: 24),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    return Text(
      title,
      style: Theme.of(
        context,
      ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
    );
  }

  Widget _buildWelcomeHeader(BuildContext context) {
    final notificationController = Get.find<NotificationController>();
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [colorScheme.primary, colorScheme.primary.withOpacity(0.8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: colorScheme.primary.withOpacity(isDark ? 0.3 : 0.25),
            blurRadius: 20,
            offset: const Offset(0, 10),
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
                      'Selamat Datang,',
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: colorScheme.onPrimary,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.3,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Obx(
                      () => Text(
                        controller.owner.value?.name ?? 'Owner',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.headlineMedium?.copyWith(
                          fontFamily: 'DeliusSwashCaps',
                          color: colorScheme.onPrimary,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.5,
                          height: 1.2,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Obx(() {
                return Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        color: colorScheme.onPrimary.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: colorScheme.onPrimary.withOpacity(0.3),
                          width: 1,
                        ),
                      ),
                      child: IconButton(
                        icon: Icon(
                          Icons.notifications_outlined,
                          color: colorScheme.onPrimary,
                          size: 24,
                        ),
                        onPressed: () => Get.toNamed(AppRoutes.notification),
                      ),
                    ),
                    if (notificationController.unreadCount.value > 0)
                      Positioned(
                        right: 0,
                        top: 0,
                        child: Container(
                          padding: const EdgeInsets.all(6),
                          constraints: const BoxConstraints(
                            minWidth: 20,
                            minHeight: 20,
                          ),
                          decoration: BoxDecoration(
                            color: colorScheme.error,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: colorScheme.primary,
                              width: 2.5,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: colorScheme.error.withOpacity(0.4),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Center(
                            child: Text(
                              '${notificationController.unreadCount.value}',
                              style: theme.textTheme.labelSmall?.copyWith(
                                color: colorScheme.onError,
                                fontWeight: FontWeight.bold,
                                fontSize: 11,
                                height: 1,
                              ),
                            ),
                          ),
                        ),
                      ),
                  ],
                );
              }),
            ],
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: colorScheme.onPrimary.withOpacity(0.2),
              borderRadius: BorderRadius.circular(100),
              border: Border.all(
                color: colorScheme.onPrimary.withOpacity(0.3),
                width: 1,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: colorScheme.onPrimary.withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.spa_outlined,
                    size: 16,
                    color: colorScheme.onPrimary,
                  ),
                ),
                const SizedBox(width: 10),
                Flexible(
                  child: Text(
                    'Siap melayani pelanggan kecil hari ini',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onPrimary,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.2,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDailyStats(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Column(
      children: [
        Obx(
          () => _SpaStatCard(
            title: 'Total Pendapatan',
            value: controller.totalRevenueTodayFormatted,
            icon: Icons.monetization_on_outlined,
            gradientColors:
                isDark
                    ? [
                      _spaLightBlue.withOpacity(0.3),
                      _spaLightBlue.withOpacity(0.2),
                    ]
                    : [
                      _spaLightBlue.withOpacity(0.15),
                      _spaLightBlue.withOpacity(0.08),
                    ],
            iconColor: _spaLightBlue,
            isPrimary: true,
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: Obx(
                () => _SpaStatCard(
                  title: 'Total Reservasi',
                  value: controller.totalAppointmentsToday,
                  icon: Icons.calendar_today_outlined,
                  gradientColors:
                      isDark
                          ? [
                            _spaMint.withOpacity(0.25),
                            _spaMint.withOpacity(0.15),
                          ]
                          : [
                            _spaMint.withOpacity(0.12),
                            _spaMint.withOpacity(0.06),
                          ],
                  iconColor: _spaMint,
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Obx(
                () => _SpaStatCard(
                  title: 'Akan Datang',
                  value: '${controller.upcomingReservationsTodayCount.value}',
                  icon: Icons.schedule_outlined,
                  gradientColors:
                      isDark
                          ? [
                            _spaLavender.withOpacity(0.25),
                            _spaLavender.withOpacity(0.15),
                          ]
                          : [
                            _spaLavender.withOpacity(0.12),
                            _spaLavender.withOpacity(0.06),
                          ],
                  iconColor: _spaLavender,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildUpcomingSession(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Obx(() {
      if (controller.isLoadingUpcomingCarousel.value &&
          controller.upcomingReservationsTodayList.isEmpty) {
        return Center(
          child: CircularProgressIndicator(color: colorScheme.primary),
        );
      }

      if (controller.upcomingReservationsTodayList.isEmpty) {
        return Container(
          width: double.infinity,
          padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(
            color: colorScheme.surfaceContainerHighest.withOpacity(0.3),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: colorScheme.outlineVariant.withOpacity(0.5),
            ),
          ),
          child: Column(
            children: [
              Icon(
                Icons.event_available_outlined,
                size: 56,
                color: colorScheme.outline.withOpacity(0.4),
              ),
              const SizedBox(height: 16),
              Text(
                'Tidak ada jadwal lagi hari ini',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Istirahat yang cukup!',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurfaceVariant.withOpacity(0.7),
                ),
              ),
            ],
          ),
        );
      }

      final Reservation? currentRes =
          controller.currentReservationForCarousel.value;
      if (currentRes == null) return const SizedBox.shrink();

      final String startTimeDisplay = _getFormattedDisplayTime(currentRes);

      return Container(
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: colorScheme.shadow.withOpacity(0.06),
              blurRadius: 20,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    colorScheme.primaryContainer.withOpacity(0.3),
                    colorScheme.primaryContainer.withOpacity(0.15),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(20),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: colorScheme.surface,
                      borderRadius: BorderRadius.circular(8),
                      boxShadow: [
                        BoxShadow(
                          color: colorScheme.shadow.withOpacity(0.04),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Text(
                      'NEXT SESSION',
                      style: theme.textTheme.labelSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.2,
                        color: colorScheme.primary,
                      ),
                    ),
                  ),
                  Text(
                    startTimeDisplay,
                    style: theme.textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  _TicketRow(
                    context,
                    label: 'Pelanggan',
                    value: currentRes.customerName ?? '-',
                    icon: Icons.person_outline,
                  ),
                  Divider(
                    height: 32,
                    color: colorScheme.outlineVariant.withOpacity(0.5),
                  ),
                  _TicketRow(
                    context,
                    label: 'Layanan',
                    value: currentRes.serviceName ?? '-',
                    icon: Icons.spa_outlined,
                  ),
                  Divider(
                    height: 32,
                    color: colorScheme.outlineVariant.withOpacity(0.5),
                  ),
                  _TicketRow(
                    context,
                    label: 'Terapis',
                    value: currentRes.staffName ?? '-',
                    icon: Icons.support_agent_outlined,
                  ),
                  const SizedBox(height: 20),
                  if (controller.upcomingReservationsTodayList.length > 1)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        TextButton.icon(
                          onPressed: controller.previousUpcomingReservation,
                          icon: const Icon(Icons.arrow_back_ios_new, size: 14),
                          label: Text(
                            'Sebelumnya',
                            style: theme.textTheme.labelMedium,
                          ),
                          style: TextButton.styleFrom(
                            foregroundColor: colorScheme.primary,
                          ),
                        ),
                        Text(
                          "${controller.currentUpcomingReservationIndex.value + 1} / ${controller.upcomingReservationsTodayList.length}",
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                        TextButton.icon(
                          onPressed: controller.nextUpcomingReservation,
                          icon: const Icon(Icons.arrow_forward_ios, size: 14),
                          label: Text(
                            'Lanjut',
                            style: theme.textTheme.labelMedium,
                          ),
                          iconAlignment: IconAlignment.end,
                          style: TextButton.styleFrom(
                            foregroundColor: colorScheme.primary,
                          ),
                        ),
                      ],
                    ),
                ],
              ),
            ),
          ],
        ),
      );
    });
  }

  Widget _TicketRow(
    BuildContext context, {
    required String label,
    required String value,
    required IconData icon,
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: colorScheme.surfaceContainerHighest.withOpacity(0.5),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: colorScheme.primary, size: 22),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: theme.textTheme.labelMedium?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildQuickActionsGrid(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      childAspectRatio: 1.3,
      children: [
        _SpaActionCard(
          context,
          title: 'Layanan',
          icon: Icons.spa_outlined,
          gradientColors:
              isDark
                  ? [
                    _spaLavender.withOpacity(0.3),
                    _spaLavender.withOpacity(0.2),
                  ]
                  : [
                    _spaLavender.withOpacity(0.2),
                    _spaLavender.withOpacity(0.1),
                  ],
          iconColor: _spaLavender,
          onTap: () => Get.toNamed('/services/manage'),
        ),
        _SpaActionCard(
          context,
          title: 'Statistik',
          icon: Icons.analytics_outlined,
          gradientColors:
              isDark
                  ? [_spaRose.withOpacity(0.3), _spaRose.withOpacity(0.2)]
                  : [_spaRose.withOpacity(0.2), _spaRose.withOpacity(0.1)],
          iconColor: _spaRose,
          onTap: () => Get.toNamed('/analytics'),
        ),
        _SpaActionCard(
          context,
          title: 'Jadwal',
          icon: Icons.event_note_outlined,
          gradientColors:
              isDark
                  ? [
                    _spaLightBlue.withOpacity(0.3),
                    _spaLightBlue.withOpacity(0.2),
                  ]
                  : [
                    _spaLightBlue.withOpacity(0.2),
                    _spaLightBlue.withOpacity(0.1),
                  ],
          iconColor: _spaLightBlue,
          onTap: () => Get.toNamed('/schedule'),
        ),
        _SpaActionCard(
          context,
          title: 'Pengaturan',
          icon: Icons.settings_outlined,
          gradientColors:
              isDark
                  ? [_spaMint.withOpacity(0.3), _spaMint.withOpacity(0.2)]
                  : [_spaMint.withOpacity(0.2), _spaMint.withOpacity(0.1)],
          iconColor: _spaMint,
          onTap: () => Get.toNamed('/account'),
        ),
      ],
    );
  }

  Widget _buildMonthlyAnalytics(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Obx(() {
      if (controller.isLoadingAnalytics.value &&
          controller.detailsDataThisMonth.value == null) {
        return Center(
          child: CircularProgressIndicator(color: colorScheme.primary),
        );
      }

      return Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: colorScheme.shadow.withOpacity(0.06),
              blurRadius: 20,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            _AnalyticsRow(
              context,
              'Penghasilan Bulan Ini',
              controller.totalRevenueThisMonthFormatted,
              _spaMint,
            ),
            Divider(
              height: 32,
              color: colorScheme.outlineVariant.withOpacity(0.5),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _MiniStat(
                  context,
                  'Total',
                  controller.totalReservationsThisMonth,
                  _spaLightBlue,
                ),
                _MiniStat(
                  context,
                  'Selesai',
                  controller.completedReservationsThisMonth,
                  _spaMint,
                ),
                _MiniStat(
                  context,
                  'Batal',
                  controller.cancelledReservationsThisMonth,
                  _spaRose,
                ),
              ],
            ),
          ],
        ),
      );
    });
  }

  Widget _AnalyticsRow(
    BuildContext context,
    String label,
    String value,
    Color accentColor,
  ) {
    final theme = Theme.of(context);

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
            fontWeight: FontWeight.w600,
          ),
        ),
        Text(
          value,
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: accentColor,
          ),
        ),
      ],
    );
  }

  Widget _MiniStat(
    BuildContext context,
    String label,
    String value,
    Color accentColor,
  ) {
    final theme = Theme.of(context);

    return Column(
      children: [
        Text(
          value,
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: accentColor.withOpacity(0.15),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Text(
            label,
            style: theme.textTheme.labelSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: accentColor,
            ),
          ),
        ),
      ],
    );
  }
}

// ==================== REUSABLE WIDGETS ====================

class _SpaStatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final List<Color> gradientColors;
  final Color iconColor;
  final bool isPrimary;

  const _SpaStatCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.gradientColors,
    required this.iconColor,
    this.isPrimary = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(isPrimary ? 24 : 20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: gradientColors,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: iconColor.withOpacity(0.2), width: 1),
        boxShadow: [
          BoxShadow(
            color: iconColor.withOpacity(0.1),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.9),
              borderRadius: BorderRadius.circular(14),
              boxShadow: [
                BoxShadow(
                  color: iconColor.withOpacity(0.2),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Icon(icon, color: iconColor, size: isPrimary ? 28 : 24),
          ),
          SizedBox(height: isPrimary ? 16 : 12),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.headlineMedium?.copyWith(
              fontSize: isPrimary ? 28 : 22,
              fontWeight: FontWeight.w800,
              color: colorScheme.onSurface,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

class _SpaActionCard extends StatelessWidget {
  final BuildContext context;
  final String title;
  final IconData icon;
  final List<Color> gradientColors;
  final Color iconColor;
  final VoidCallback onTap;

  const _SpaActionCard(
    this.context, {
    required this.title,
    required this.icon,
    required this.gradientColors,
    required this.iconColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: gradientColors,
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: iconColor.withOpacity(0.3), width: 1.5),
            boxShadow: [
              BoxShadow(
                color: iconColor.withOpacity(0.15),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.9),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: iconColor.withOpacity(0.25),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Icon(icon, color: iconColor, size: 28),
              ),
              const SizedBox(height: 12),
              Text(
                title,
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: colorScheme.onSurface,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
