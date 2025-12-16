import 'package:emababyspa/features/notification/controllers/notification_controller.dart';
import 'package:emababyspa/utils/app_routes.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:emababyspa/common/layouts/main_layout.dart';
import 'package:emababyspa/features/dashboard/controllers/dashboard_controller.dart';
import 'package:emababyspa/data/models/reservation.dart';
import 'package:emababyspa/utils/timezone_utils.dart';

// ✅ add
import 'package:emababyspa/common/theme/app_theme.dart';

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
      debugPrint('Error time parsing: $e');
      return reservation.sessionTime ?? 'Error';
    }
    return 'N/A';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final sp = theme.extension<AppSpacing>() ?? const AppSpacing();

    return MainLayout(
      showBottomNavigation: true,
      enablePullToRefresh: true,
      onRefresh: controller.refreshCurrentPage,
      child: Obx(() {
        if (controller.isLoading && controller.owner.value == null) {
          return Center(child: CircularProgressIndicator(color: cs.primary));
        }

        return SingleChildScrollView(
          padding: EdgeInsets.all(sp.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildWelcomeHeader(context),
              SizedBox(height: sp.xl),
              _buildSectionTitle(context, 'Ringkasan Hari Ini'),
              SizedBox(height: sp.md),
              _buildDailyStats(context),
              SizedBox(height: sp.xl),
              _buildSectionTitle(context, 'Jadwal Berikutnya'),
              SizedBox(height: sp.md),
              _buildUpcomingSession(context),
              SizedBox(height: sp.xl),
              _buildSectionTitle(context, 'Aksi Cepat'),
              SizedBox(height: sp.md),
              _buildQuickActionsGrid(context),
              SizedBox(height: sp.xl),
              _buildSectionTitle(context, 'Performa Bulan Ini'),
              SizedBox(height: sp.md),
              _buildMonthlyAnalytics(context),
              SizedBox(height: sp.lg),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    final theme = Theme.of(context);
    return Text(
      title,
      style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
    );
  }

  Widget _buildWelcomeHeader(BuildContext context) {
    final notificationController = Get.find<NotificationController>();
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final sp = theme.extension<AppSpacing>() ?? const AppSpacing();

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(sp.lg),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [cs.primary, cs.primary.withValues(alpha: 0.82)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(AppRadii.xl),
        boxShadow: [
          BoxShadow(
            color: cs.primary.withValues(alpha: 0.22),
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
                        color: cs.onPrimary,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.2,
                      ),
                    ),
                    SizedBox(height: sp.xxs),
                    Obx(
                      () => Text(
                        controller.owner.value?.name ?? 'Owner',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.headlineMedium?.copyWith(
                          fontFamily: 'DeliusSwashCaps',
                          color: cs.onPrimary,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.4,
                          height: 1.15,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // notif button + badge
              Obx(() {
                return Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        color: cs.onPrimary.withValues(alpha: 0.18),
                        borderRadius: BorderRadius.circular(AppRadii.md),
                        border: Border.all(
                          color: cs.onPrimary.withValues(alpha: 0.28),
                          width: 1,
                        ),
                      ),
                      child: IconButton(
                        icon: Icon(
                          Icons.notifications_outlined,
                          color: cs.onPrimary,
                          size: 24,
                        ),
                        onPressed: () => Get.toNamed(AppRoutes.notification),
                      ),
                    ),
                    if (notificationController.unreadCount.value > 0)
                      Positioned(
                        right: -2,
                        top: -2,
                        child: Container(
                          padding: EdgeInsets.all(sp.xxs),
                          constraints: const BoxConstraints(
                            minWidth: 20,
                            minHeight: 20,
                          ),
                          decoration: BoxDecoration(
                            color: cs.error,
                            shape: BoxShape.circle,
                            border: Border.all(color: cs.primary, width: 2.2),
                            boxShadow: [
                              BoxShadow(
                                color: cs.error.withValues(alpha: 0.35),
                                blurRadius: 10,
                                offset: const Offset(0, 3),
                              ),
                            ],
                          ),
                          child: Center(
                            child: Text(
                              '${notificationController.unreadCount.value}',
                              style: theme.textTheme.labelSmall?.copyWith(
                                color: cs.onError,
                                fontWeight: FontWeight.w800,
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

          SizedBox(height: sp.md),

          Container(
            padding: EdgeInsets.symmetric(horizontal: sp.md, vertical: sp.xs),
            decoration: BoxDecoration(
              color: cs.onPrimary.withValues(alpha: 0.18),
              borderRadius: BorderRadius.circular(999),
              border: Border.all(
                color: cs.onPrimary.withValues(alpha: 0.28),
                width: 1,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: EdgeInsets.all(sp.xxs),
                  decoration: BoxDecoration(
                    color: cs.onPrimary.withValues(alpha: 0.18),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.spa_outlined,
                    size: 16,
                    color: cs.onPrimary,
                  ),
                ),
                SizedBox(width: sp.sm),
                Flexible(
                  child: Text(
                    'Siap melayani pelanggan kecil hari ini',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: cs.onPrimary,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.15,
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
    final cs = theme.colorScheme;
    final sp = theme.extension<AppSpacing>() ?? const AppSpacing();

    return Column(
      children: [
        Obx(
          () => _SpaStatCard(
            title: 'Total Pendapatan',
            value: controller.totalRevenueTodayFormatted,
            icon: Icons.monetization_on_outlined,
            // ✅ use scheme: primary
            accent: cs.primary,
            isPrimary: true,
          ),
        ),
        SizedBox(height: sp.md),
        Row(
          children: [
            Expanded(
              child: Obx(
                () => _SpaStatCard(
                  title: 'Total Reservasi',
                  value: controller.totalAppointmentsToday,
                  icon: Icons.calendar_today_outlined,
                  // ✅ use scheme: secondary
                  accent: cs.secondary,
                ),
              ),
            ),
            SizedBox(width: sp.md),
            Expanded(
              child: Obx(
                () => _SpaStatCard(
                  title: 'Akan Datang',
                  value: controller.upcomingReservationsTodayCount.value,
                  icon: Icons.schedule_outlined,
                  // ✅ use scheme: tertiary (pink accent kamu sudah ada)
                  accent: cs.tertiary,
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
    final cs = theme.colorScheme;
    final sp = theme.extension<AppSpacing>() ?? const AppSpacing();

    return Obx(() {
      if (controller.isLoadingUpcomingCarousel.value &&
          controller.upcomingReservationsTodayList.isEmpty) {
        return Center(child: CircularProgressIndicator(color: cs.primary));
      }

      if (controller.upcomingReservationsTodayList.isEmpty) {
        return Container(
          width: double.infinity,
          padding: EdgeInsets.all(sp.xl),
          decoration: BoxDecoration(
            color: cs.surfaceContainerHighest.withValues(alpha: 0.35),
            borderRadius: BorderRadius.circular(AppRadii.lg),
            border: Border.all(
              color: cs.outlineVariant.withValues(alpha: 0.55),
            ),
          ),
          child: Column(
            children: [
              Icon(
                Icons.event_available_outlined,
                size: 56,
                color: cs.outline.withValues(alpha: 0.45),
              ),
              SizedBox(height: sp.md),
              Text(
                'Tidak ada jadwal lagi hari ini',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              SizedBox(height: sp.xxs),
              Text(
                'Istirahat yang cukup!',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: cs.onSurfaceVariant.withValues(alpha: 0.75),
                  fontWeight: FontWeight.w600,
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
          color: cs.surface,
          borderRadius: BorderRadius.circular(AppRadii.lg),
          boxShadow: AppShadows.soft(cs.shadow),
          border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.55)),
        ),
        child: Column(
          children: [
            Container(
              padding: EdgeInsets.all(sp.md),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    cs.primaryContainer.withValues(alpha: 0.55),
                    cs.primaryContainer.withValues(alpha: 0.20),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.vertical(
                  top: Radius.circular(AppRadii.lg),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: sp.sm,
                      vertical: sp.xxs,
                    ),
                    decoration: BoxDecoration(
                      color: cs.surface,
                      borderRadius: BorderRadius.circular(AppRadii.sm),
                      boxShadow: [
                        BoxShadow(
                          color: cs.shadow.withValues(alpha: 0.04),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                      border: Border.all(
                        color: cs.outlineVariant.withValues(alpha: 0.45),
                      ),
                    ),
                    child: Text(
                      'NEXT SESSION',
                      style: theme.textTheme.labelSmall?.copyWith(
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1.1,
                        color: cs.primary,
                      ),
                    ),
                  ),
                  Text(
                    startTimeDisplay,
                    style: theme.textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.w900,
                      letterSpacing: -0.4,
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.all(sp.md),
              child: Column(
                children: [
                  _TicketRow(
                    context,
                    label: 'Pelanggan',
                    value: currentRes.customerName ?? '-',
                    icon: Icons.person_outline,
                  ),
                  Divider(
                    height: sp.xl,
                    color: cs.outlineVariant.withValues(alpha: 0.55),
                  ),
                  _TicketRow(
                    context,
                    label: 'Layanan',
                    value: currentRes.serviceName ?? '-',
                    icon: Icons.spa_outlined,
                  ),
                  Divider(
                    height: sp.xl,
                    color: cs.outlineVariant.withValues(alpha: 0.55),
                  ),
                  _TicketRow(
                    context,
                    label: 'Terapis',
                    value: currentRes.staffName ?? '-',
                    icon: Icons.support_agent_outlined,
                  ),
                  SizedBox(height: sp.md),
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
                            foregroundColor: cs.primary,
                          ),
                        ),
                        Text(
                          "${controller.currentUpcomingReservationIndex.value + 1} / ${controller.upcomingReservationsTodayList.length}",
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: cs.onSurfaceVariant,
                            fontWeight: FontWeight.w700,
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
                            foregroundColor: cs.primary,
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
    final cs = theme.colorScheme;
    final sp = theme.extension<AppSpacing>() ?? const AppSpacing();

    return Row(
      children: [
        Container(
          padding: EdgeInsets.all(sp.sm),
          decoration: BoxDecoration(
            color: cs.surfaceContainerHighest.withValues(alpha: 0.55),
            borderRadius: BorderRadius.circular(AppRadii.md),
            border: Border.all(
              color: cs.outlineVariant.withValues(alpha: 0.50),
            ),
          ),
          child: Icon(icon, color: cs.primary, size: 22),
        ),
        SizedBox(width: sp.md),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: theme.textTheme.labelMedium?.copyWith(
                  color: cs.onSurfaceVariant,
                  fontWeight: FontWeight.w700,
                ),
              ),
              SizedBox(height: sp.xxs),
              Text(
                value,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w800,
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
    final cs = theme.colorScheme;
    final sp = theme.extension<AppSpacing>() ?? const AppSpacing();

    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: sp.md,
      mainAxisSpacing: sp.md,
      childAspectRatio: 1.3,
      children: [
        _SpaActionCard(
          title: 'Layanan',
          icon: Icons.spa_outlined,
          accent: cs.primary,
          onTap: () => Get.toNamed('/services/manage'),
        ),
        _SpaActionCard(
          title: 'Statistik',
          icon: Icons.analytics_outlined,
          accent: cs.secondary,
          onTap: () => Get.toNamed('/analytics'),
        ),
        _SpaActionCard(
          title: 'Jadwal',
          icon: Icons.event_note_outlined,
          accent: cs.tertiary,
          onTap: () => Get.toNamed('/schedule'),
        ),
        _SpaActionCard(
          title: 'Pengaturan',
          icon: Icons.settings_outlined,
          accent: cs.primary, // keep brand-blue
          onTap: () => Get.toNamed('/account'),
        ),
      ],
    );
  }

  Widget _buildMonthlyAnalytics(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final sp = theme.extension<AppSpacing>() ?? const AppSpacing();

    return Obx(() {
      if (controller.isLoadingAnalytics.value &&
          controller.detailsDataThisMonth.value == null) {
        return Center(child: CircularProgressIndicator(color: cs.primary));
      }

      return Container(
        padding: EdgeInsets.all(sp.lg),
        decoration: BoxDecoration(
          color: cs.surface,
          borderRadius: BorderRadius.circular(AppRadii.lg),
          boxShadow: AppShadows.soft(cs.shadow),
          border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.55)),
        ),
        child: Column(
          children: [
            _AnalyticsRow(
              context,
              'Penghasilan Bulan Ini',
              controller.totalRevenueThisMonthFormatted,
              cs.primary,
            ),
            Divider(
              height: sp.xl,
              color: cs.outlineVariant.withValues(alpha: 0.55),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _MiniStat(
                  context,
                  'Total',
                  controller.totalReservationsThisMonth,
                  cs.secondary,
                ),
                _MiniStat(
                  context,
                  'Selesai',
                  controller.completedReservationsThisMonth,
                  cs.primary,
                ),
                _MiniStat(
                  context,
                  'Batal',
                  controller.cancelledReservationsThisMonth,
                  cs.error,
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
    final cs = theme.colorScheme;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: cs.onSurfaceVariant,
            fontWeight: FontWeight.w700,
          ),
        ),
        Text(
          value,
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w900,
            color: accentColor,
            letterSpacing: -0.2,
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
    final sp = theme.extension<AppSpacing>() ?? const AppSpacing();

    return Column(
      children: [
        Text(
          value,
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w900,
          ),
        ),
        SizedBox(height: sp.xxs),
        Container(
          padding: EdgeInsets.symmetric(horizontal: sp.xs, vertical: sp.xxs),
          decoration: BoxDecoration(
            color: accentColor.withValues(alpha: 0.14),
            borderRadius: BorderRadius.circular(AppRadii.sm),
            border: Border.all(color: accentColor.withValues(alpha: 0.20)),
          ),
          child: Text(
            label,
            style: theme.textTheme.labelSmall?.copyWith(
              fontWeight: FontWeight.w900,
              color: accentColor,
              letterSpacing: 0.2,
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

  /// ✅ single source of truth for accent
  final Color accent;

  final bool isPrimary;

  const _SpaStatCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.accent,
    this.isPrimary = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final sp = theme.extension<AppSpacing>() ?? const AppSpacing();

    final pad = isPrimary ? sp.lg : sp.md;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(pad),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            accent.withValues(alpha: 0.16),
            accent.withValues(alpha: 0.08),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(AppRadii.lg),
        border: Border.all(color: accent.withValues(alpha: 0.22), width: 1),
        boxShadow: AppShadows.soft(cs.shadow),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.all(sp.sm),
            decoration: BoxDecoration(
              // ✅ remove Colors.white
              color: cs.surface.withValues(alpha: 0.92),
              borderRadius: BorderRadius.circular(AppRadii.md),
              border: Border.all(
                color: cs.outlineVariant.withValues(alpha: 0.45),
              ),
              boxShadow: [
                BoxShadow(
                  color: accent.withValues(alpha: 0.14),
                  blurRadius: 10,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Icon(icon, color: accent, size: isPrimary ? 28 : 24),
          ),
          SizedBox(height: isPrimary ? sp.md : sp.sm),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.headlineMedium?.copyWith(
              fontSize: isPrimary ? 28 : 22,
              fontWeight: FontWeight.w900,
              color: cs.onSurface,
              letterSpacing: -0.6,
            ),
          ),
          SizedBox(height: sp.xxs),
          Text(
            title,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: cs.onSurfaceVariant,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _SpaActionCard extends StatelessWidget {
  final String title;
  final IconData icon;

  /// ✅ single accent
  final Color accent;

  final VoidCallback onTap;

  const _SpaActionCard({
    required this.title,
    required this.icon,
    required this.accent,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final sp = theme.extension<AppSpacing>() ?? const AppSpacing();

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadii.lg),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                accent.withValues(alpha: 0.16),
                accent.withValues(alpha: 0.08),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(AppRadii.lg),
            border: Border.all(
              color: accent.withValues(alpha: 0.26),
              width: 1.25,
            ),
            boxShadow: AppShadows.soft(cs.shadow),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: EdgeInsets.all(sp.md),
                decoration: BoxDecoration(
                  // ✅ remove Colors.white
                  color: cs.surface.withValues(alpha: 0.92),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: cs.outlineVariant.withValues(alpha: 0.45),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: accent.withValues(alpha: 0.18),
                      blurRadius: 10,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Icon(icon, color: accent, size: 28),
              ),
              SizedBox(height: sp.sm),
              Text(
                title,
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: cs.onSurface,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
