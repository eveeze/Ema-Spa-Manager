// lib/features/analytics/views/analytics_view.dart

import 'dart:math' as math;

import 'package:emababyspa/common/layouts/main_layout.dart';
import 'package:emababyspa/common/theme/app_theme.dart';
import 'package:emababyspa/data/models/analytics.dart';
import 'package:emababyspa/features/analytics/controllers/analytics_controller.dart';
import 'package:emababyspa/utils/app_routes.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class AnalyticsView extends GetView<AnalyticsController> {
  const AnalyticsView({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return MainLayout.subPage(
      title: 'Statistik',
      parentRoute: AppRoutes.analyticsView,
      showAppBar: true,
      showBottomNavigation: true,
      child: Obx(() {
        if (controller.isLoading.value) {
          return Center(child: CircularProgressIndicator(color: cs.primary));
        }

        if (controller.errorMessage.value != null) {
          return _CenteredMessage(
            icon: Icons.error_outline_rounded,
            iconColor: cs.error,
            title: 'Terjadi Kesalahan',
            message: controller.errorMessage.value!,
            action: ElevatedButton.icon(
              onPressed: controller.refreshData,
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Coba Lagi'),
            ),
          );
        }

        if (controller.detailsData.value == null) {
          return _CenteredMessage(
            icon: Icons.insights_rounded,
            iconColor: cs.primary,
            title: 'Belum Ada Data',
            message: 'Tidak ada data analitik tersedia.',
          );
        }

        return RefreshIndicator(
          color: cs.primary,
          onRefresh: controller.refreshData,
          child: _buildAnalyticsContent(context),
        );
      }),
    );
  }

  // =========================================================
  // CONTENT
  // =========================================================
  Widget _buildAnalyticsContent(BuildContext context) {
    final theme = Theme.of(context);
    final sp = theme.extension<AppSpacing>() ?? const AppSpacing();
    final details = controller.detailsData.value!;

    return SingleChildScrollView(
      padding: EdgeInsets.all(sp.lg),
      physics: const AlwaysScrollableScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildDateFilter(context),
          SizedBox(height: sp.lg),
          _buildStatsGrid(context),
          SizedBox(height: sp.lg),
          _buildRevenueChart(context),
          SizedBox(height: sp.lg),
          _buildReservationStatusChart(context, details.reservationStats),
          SizedBox(height: sp.lg),
          _buildTopPerformingBarChart(
            context,
            title: 'Layanan Terlaris',
            items: details.topPerformingServices,
            sectionIcon: Icons.spa_outlined,
            valueFormatter: (item) => '${item.count} Sesi',
          ),
          SizedBox(height: sp.lg),
          _buildTopPerformingBarChart(
            context,
            title: 'Terapis Terbaik',
            items: details.topPerformingStaff,
            sectionIcon: Icons.support_agent_outlined,
            valueFormatter: (item) => '${item.count} Sesi',
          ),
          SizedBox(height: sp.lg),
          _buildRatingSection(context, details.ratingStats),
          SizedBox(height: sp.md),
        ],
      ),
    );
  }

  // =========================================================
  // DATE FILTER
  // =========================================================
  Widget _buildDateFilter(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final sp = theme.extension<AppSpacing>() ?? const AppSpacing();

    return Obx(
      () => SegmentedButton<DateRangeFilter>(
        segments: const [
          ButtonSegment(
            value: DateRangeFilter.last7Days,
            label: Text('7 Hari'),
          ),
          ButtonSegment(
            value: DateRangeFilter.thisMonth,
            label: Text('Bulan Ini'),
          ),
          ButtonSegment(
            value: DateRangeFilter.last3Months,
            label: Text('3 Bulan'),
          ),
        ],
        selected: {controller.selectedFilter.value},
        onSelectionChanged: (Set<DateRangeFilter> newSelection) {
          controller.changeDateFilter(newSelection.first);
        },
        style: SegmentedButton.styleFrom(
          backgroundColor: cs.surface,
          foregroundColor: cs.primary,
          selectedBackgroundColor: cs.primary,
          selectedForegroundColor: cs.onPrimary,
          textStyle: theme.textTheme.labelLarge,
          side: BorderSide(color: cs.outlineVariant.withOpacity(0.80)),
          padding: EdgeInsets.symmetric(horizontal: sp.sm, vertical: sp.xs),
        ),
      ),
    );
  }

  // =========================================================
  // STATS GRID
  // =========================================================
  Widget _buildStatsGrid(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final sp = theme.extension<AppSpacing>() ?? const AppSpacing();

    final stats = controller.detailsData.value!.reservationStats;
    final totalRevenue = controller.detailsData.value!.revenueChartData.fold(
      0.0,
      (sum, item) => sum + item.revenue,
    );
    final overallRating =
        controller.detailsData.value!.ratingStats.overallAverageRating;

    final width = MediaQuery.of(context).size.width;
    final crossAxisCount = width > 600 ? 4 : 2;
    final childAspectRatio = width > 600 ? 1.45 : 1.30;

    // Accent colors (ambil dari scheme, no hardcode)
    final cRevenue = cs.primary;
    final cTotal = cs.secondary;
    final cDone = cs.tertiary;
    final cRating = cs.primaryContainer;

    return GridView.count(
      crossAxisCount: crossAxisCount,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: sp.sm,
      mainAxisSpacing: sp.sm,
      childAspectRatio: childAspectRatio,
      children: [
        _StatCard(
          title: 'Total Pendapatan',
          value: NumberFormat.currency(
            locale: 'id_ID',
            symbol: 'Rp ',
            decimalDigits: 0,
          ).format(totalRevenue),
          icon: Icons.monetization_on_outlined,
          accent: cRevenue,
        ),
        _StatCard(
          title: 'Total Reservasi',
          value: stats.total.toString(),
          icon: Icons.event_available_outlined,
          accent: cTotal,
        ),
        _StatCard(
          title: 'Sesi Selesai',
          value: stats.completed.toString(),
          icon: Icons.check_circle_outline_rounded,
          accent: cDone,
        ),
        _StatCard(
          title: 'Rata-Rata Rating',
          value: overallRating.toStringAsFixed(2),
          icon: Icons.star_outline_rounded,
          accent: cRating,
        ),
      ],
    );
  }

  // =========================================================
  // REVENUE CHART (IMPROVED VISUAL)
  // =========================================================
  Widget _buildRevenueChart(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final sp = theme.extension<AppSpacing>() ?? const AppSpacing();

    final chartData = controller.detailsData.value!.revenueChartData;

    if (chartData.isEmpty) {
      return const _EmptySection(
        title: 'Grafik Pendapatan',
        message: 'Tidak ada data pendapatan untuk ditampilkan.',
      );
    }

    final spots =
        chartData.asMap().entries.map((e) {
          return FlSpot(e.key.toDouble(), e.value.revenue);
        }).toList();

    final maxY = spots.map((s) => s.y).fold<double>(0, math.max);
    final safeMaxY = (maxY <= 0) ? 1.0 : maxY;
    final yInterval = _niceInterval(safeMaxY);

    // Label bawah: tampilkan ~5 label saja (auto skip)
    final intervalX = _bottomLabelInterval(chartData.length);

    return _SectionShell(
      title: 'Grafik Pendapatan',
      subtitle: 'Tren pendapatan berdasarkan rentang tanggal terpilih.',
      child: SizedBox(
        height: 280,
        child: Padding(
          padding: EdgeInsets.fromLTRB(sp.md, sp.lg, sp.md, sp.md),
          child: LineChart(
            LineChartData(
              minX: 0,
              maxX: (chartData.length - 1).toDouble(),
              minY: 0,
              maxY: safeMaxY * 1.15,

              // Grid halus (biar kebaca), vertical dimatikan biar clean
              gridData: FlGridData(
                show: true,
                drawVerticalLine: false,
                horizontalInterval: yInterval,
                getDrawingHorizontalLine:
                    (value) => FlLine(
                      color: cs.outlineVariant.withOpacity(0.35),
                      strokeWidth: 1,
                      dashArray: [6, 6],
                    ),
              ),

              borderData: FlBorderData(show: false),

              // Titles
              titlesData: FlTitlesData(
                topTitles: const AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
                rightTitles: const AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),

                // Y axis kiri: compact currency "rb/jt"
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 44,
                    interval: yInterval,
                    getTitlesWidget: (value, meta) {
                      // hide label 0 biar nggak ramai
                      if (value == 0) {
                        return Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: Text(
                            '0',
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: cs.onSurfaceVariant.withOpacity(0.80),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        );
                      }

                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: Text(
                          _compactRupiah(value),
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: cs.onSurfaceVariant.withOpacity(0.85),
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      );
                    },
                  ),
                ),

                // X axis bawah: auto-skip label
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 34,
                    interval: intervalX.toDouble(),
                    getTitlesWidget: (value, meta) {
                      final idx = value.round();
                      if (idx < 0 || idx >= chartData.length) {
                        return const SizedBox.shrink();
                      }

                      // Pastikan hanya label yg sesuai interval yg muncul
                      if (idx % intervalX != 0 && idx != chartData.length - 1) {
                        return const SizedBox.shrink();
                      }

                      final date = DateTime.parse(chartData[idx].date);
                      final label = DateFormat('d MMM', 'id_ID').format(date);

                      return Padding(
                        padding: EdgeInsets.only(top: sp.sm),
                        child: Text(
                          label,
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: cs.onSurfaceVariant.withOpacity(0.85),
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),

              // Line
              lineBarsData: [
                LineChartBarData(
                  spots: spots,
                  isCurved: true,
                  barWidth: 3.2,
                  isStrokeCapRound: true,

                  // Biar lebih premium: gradient tipis pada line
                  gradient: LinearGradient(
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                    colors: [cs.primary.withOpacity(0.75), cs.primary],
                  ),

                  dotData: FlDotData(
                    show: true,
                    checkToShowDot: (spot, barData) {
                      // Tampilkan dot hanya pada last point (lebih clean)
                      return spot.x == (chartData.length - 1).toDouble();
                    },
                    getDotPainter: (spot, percent, barData, index) {
                      return FlDotCirclePainter(
                        radius: 4.5,
                        color: cs.primary,
                        strokeWidth: 2,
                        strokeColor: cs.surface,
                      );
                    },
                  ),

                  // Area bawah: very subtle (tanpa “blob”)
                  belowBarData: BarAreaData(
                    show: true,
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        cs.primary.withOpacity(0.16),
                        cs.primary.withOpacity(0.00),
                      ],
                    ),
                  ),
                ),
              ],

              // Tooltip
              lineTouchData: LineTouchData(
                handleBuiltInTouches: true,
                touchTooltipData: LineTouchTooltipData(
                  tooltipPadding: EdgeInsets.symmetric(
                    horizontal: sp.md,
                    vertical: sp.sm,
                  ),
                  tooltipMargin: 14,
                  tooltipBorder: BorderSide(
                    color: cs.outlineVariant.withOpacity(0.55),
                    width: 1,
                  ),
                  getTooltipColor:
                      (touchedSpot) => cs.onSurface.withOpacity(0.92),
                  getTooltipItems: (List<LineBarSpot> touchedSpots) {
                    return touchedSpots
                        .map((spot) {
                          final idx = spot.x.round();
                          if (idx < 0 || idx >= chartData.length) {
                            return null;
                          }
                          final date = DateTime.parse(chartData[idx].date);
                          final money = NumberFormat.currency(
                            locale: 'id_ID',
                            symbol: 'Rp ',
                            decimalDigits: 0,
                          ).format(spot.y);

                          return LineTooltipItem(
                            '${DateFormat('EEE, d MMM', 'id_ID').format(date)}\n',
                            theme.textTheme.labelLarge!.copyWith(
                              color: cs.surface,
                              fontWeight: FontWeight.w900,
                              height: 1.15,
                            ),
                            children: [
                              TextSpan(
                                text: money,
                                style: theme.textTheme.titleMedium!.copyWith(
                                  color: cs.surface,
                                  fontWeight: FontWeight.w900,
                                  height: 1.2,
                                ),
                              ),
                            ],
                          );
                        })
                        .whereType<LineTooltipItem>()
                        .toList();
                  },
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // =========================================================
  // RESERVATION STATUS PIE CHART (slightly cleaned)
  // =========================================================
  Widget _buildReservationStatusChart(
    BuildContext context,
    ReservationStats stats,
  ) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final sp = theme.extension<AppSpacing>() ?? const AppSpacing();

    final sections = <PieChartSectionData>[];
    final legendItems = <Widget>[];

    void addSection(String title, int value, Color color) {
      if (value <= 0) return;

      sections.add(
        PieChartSectionData(
          color: color,
          value: value.toDouble(),
          title: '$value',
          radius: 56,
          titleStyle: theme.textTheme.labelLarge?.copyWith(
            fontWeight: FontWeight.w900,
            color: cs.onPrimary,
          ),
        ),
      );

      legendItems.add(_LegendItem(color: color, text: title));
    }

    final done = cs.tertiary;
    final cancel = cs.error;
    final pending = cs.secondary;
    final confirmed = cs.primary;

    final confirmedValue =
        stats.total - stats.completed - stats.cancelled - stats.pending;

    addSection('Selesai', stats.completed, done);
    addSection('Dibatalkan', stats.cancelled, cancel);
    addSection('Pending', stats.pending, pending);
    addSection('Terkonfirmasi', confirmedValue, confirmed);

    if (sections.isEmpty) {
      return const _EmptySection(
        title: 'Status Reservasi',
        message: 'Tidak ada data status reservasi untuk ditampilkan.',
      );
    }

    return _SectionShell(
      title: 'Status Reservasi',
      subtitle: 'Komposisi status dari seluruh reservasi pada periode ini.',
      child: LayoutBuilder(
        builder: (context, constraints) {
          final wide = constraints.maxWidth > 420;

          final chart = AspectRatio(
            aspectRatio: 1,
            child: PieChart(
              PieChartData(
                sections: sections,
                sectionsSpace: 3,
                centerSpaceRadius: 44,
              ),
            ),
          );

          if (wide) {
            return Row(
              children: [
                Expanded(flex: 2, child: chart),
                SizedBox(width: sp.lg),
                Expanded(
                  flex: 1,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: legendItems,
                  ),
                ),
              ],
            );
          }

          return Column(
            children: [chart, SizedBox(height: sp.md), ...legendItems],
          );
        },
      ),
    );
  }

  // =========================================================
  // TOP PERFORMING
  // =========================================================
  Widget _buildTopPerformingBarChart(
    BuildContext context, {
    required String title,
    required List<TopPerformingItem> items,
    required IconData sectionIcon,
    required String Function(TopPerformingItem) valueFormatter,
  }) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final sp = theme.extension<AppSpacing>() ?? const AppSpacing();

    if (items.isEmpty) {
      return _EmptySection(
        title: title,
        message: 'Tidak ada data untuk ditampilkan.',
      );
    }

    final maxValue = items.first.count.toDouble().clamp(1, double.infinity);

    return _SectionShell(
      title: title,
      leading: Icon(sectionIcon, color: cs.primary),
      child: Column(
        children:
            items.map((item) {
              final currentValue = item.count.toDouble();
              final progress = (currentValue / maxValue).clamp(0.0, 1.0);

              return Padding(
                padding: EdgeInsets.symmetric(vertical: sp.sm),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            item.name,
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w800,
                              letterSpacing: -0.1,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        SizedBox(width: sp.sm),
                        Text(
                          valueFormatter(item),
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: cs.primary,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: sp.sm),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(AppRadii.sm),
                      child: LinearProgressIndicator(
                        value: progress,
                        backgroundColor: cs.surfaceVariant.withOpacity(0.65),
                        color: cs.primary,
                        minHeight: 9,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
      ),
    );
  }

  // =========================================================
  // RATINGS
  // =========================================================
  Widget _buildRatingSection(BuildContext context, RatingStats ratingStats) {
    final theme = Theme.of(context);
    final sp = theme.extension<AppSpacing>() ?? const AppSpacing();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildRatedServiceList(
          context,
          title: 'Layanan Rating Tertinggi',
          items: ratingStats.topRatedServices,
          icon: Icons.thumb_up_alt_outlined,
          accent: Theme.of(context).colorScheme.tertiary,
        ),
        SizedBox(height: sp.lg),
        _buildRatedServiceList(
          context,
          title: 'Layanan Rating Terendah',
          items: ratingStats.lowestRatedServices,
          icon: Icons.thumb_down_alt_outlined,
          accent: Theme.of(context).colorScheme.secondary,
        ),
      ],
    );
  }

  Widget _buildRatedServiceList(
    BuildContext context, {
    required String title,
    required List<RatedServiceItem> items,
    required IconData icon,
    required Color accent,
  }) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final sp = theme.extension<AppSpacing>() ?? const AppSpacing();

    if (items.isEmpty) {
      return _EmptySection(
        title: title,
        message: 'Belum ada layanan yang dirating.',
      );
    }

    return _SectionShell(
      title: title,
      leading: Icon(icon, color: accent),
      child: Column(
        children:
            items.map((item) {
              return Padding(
                padding: EdgeInsets.symmetric(vertical: sp.sm),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            item.name,
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w800,
                              letterSpacing: -0.1,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        SizedBox(width: sp.sm),
                        Row(
                          children: [
                            Icon(
                              Icons.star_rounded,
                              color: cs.tertiary,
                              size: 18,
                            ),
                            SizedBox(width: sp.xs),
                            Text(
                              item.averageRating.toStringAsFixed(2),
                              style: theme.textTheme.bodyMedium?.copyWith(
                                fontWeight: FontWeight.w900,
                                color: cs.onSurface,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    SizedBox(height: sp.sm),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(AppRadii.sm),
                      child: LinearProgressIndicator(
                        value: (item.averageRating / 5.0).clamp(0.0, 1.0),
                        backgroundColor: cs.surfaceVariant.withOpacity(0.65),
                        color: accent,
                        minHeight: 9,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
      ),
    );
  }

  // =========================================================
  // HELPERS
  // =========================================================
  int _bottomLabelInterval(int length) {
    if (length <= 7) return 1; // 7 hari: tampil semua
    // target sekitar 5-6 label biar kebaca
    final target = 5;
    return math.max(1, (length / target).ceil());
  }

  double _niceInterval(double maxY) {
    // bikin interval “enak” dilihat (misal 20rb, 50rb, 100rb, dst)
    if (maxY <= 0) return 1;
    final raw = maxY / 4; // ~4 garis
    final pow10 = math.pow(10, (math.log(raw) / math.ln10).floor()).toDouble();
    final digit = raw / pow10;

    double nice;
    if (digit < 1.5) {
      nice = 1;
    } else if (digit < 3) {
      nice = 2;
    } else if (digit < 7) {
      nice = 5;
    } else {
      nice = 10;
    }
    return nice * pow10;
  }

  String _compactRupiah(double value) {
    // compact: 50 rb, 1.2 jt, dst (biar Y-axis bersih)
    if (value >= 1000000000) {
      final v = value / 1000000000;
      return '${v.toStringAsFixed(v < 10 ? 1 : 0)} m';
    }
    if (value >= 1000000) {
      final v = value / 1000000;
      return '${v.toStringAsFixed(v < 10 ? 1 : 0)} jt';
    }
    if (value >= 1000) {
      final v = value / 1000;
      return '${v.toStringAsFixed(v < 10 ? 1 : 0)} rb';
    }
    return value.toStringAsFixed(0);
  }
}

// =========================================================
// REUSABLE UI (cleaner - no double shadow blob)
// =========================================================

class _SectionShell extends StatelessWidget {
  final String title;
  final String? subtitle;
  final Widget child;
  final Widget? leading;

  const _SectionShell({
    required this.title,
    required this.child,
    this.subtitle,
    this.leading,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final sp = theme.extension<AppSpacing>() ?? const AppSpacing();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.only(left: sp.xs),
          child: Row(
            children: [
              Container(
                width: 6,
                height: 22,
                decoration: BoxDecoration(
                  color: cs.primary,
                  borderRadius: BorderRadius.circular(99),
                ),
              ),
              SizedBox(width: sp.sm),
              if (leading != null) ...[leading!, SizedBox(width: sp.sm)],
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.25,
                      ),
                    ),
                    if (subtitle != null) ...[
                      SizedBox(height: sp.xs),
                      Text(
                        subtitle!,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: cs.onSurface.withOpacity(0.78),
                          fontWeight: FontWeight.w600,
                          height: 1.35,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: sp.md),

        // ✅ Single surface container: no Card+inner shadow (hilang “bulatan”)
        Container(
          width: double.infinity,
          padding: EdgeInsets.all(sp.md),
          decoration: BoxDecoration(
            color: cs.surface,
            borderRadius: BorderRadius.circular(AppRadii.lg),
            border: Border.all(
              color: cs.outlineVariant.withOpacity(0.55),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: cs.shadow.withOpacity(0.06),
                blurRadius: 18,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: child,
        ),
      ],
    );
  }
}

class _EmptySection extends StatelessWidget {
  final String title;
  final String message;

  const _EmptySection({required this.title, required this.message});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return _SectionShell(
      title: title,
      child: SizedBox(
        height: 180,
        child: Center(
          child: Text(
            message,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: cs.onSurfaceVariant.withOpacity(0.90),
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}

class _LegendItem extends StatelessWidget {
  final Color color;
  final String text;

  const _LegendItem({required this.color, required this.text});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final sp = Theme.of(context).extension<AppSpacing>() ?? const AppSpacing();

    return Padding(
      padding: EdgeInsets.symmetric(vertical: sp.xs),
      child: Row(
        children: [
          Container(
            width: 14,
            height: 14,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          SizedBox(width: sp.sm),
          Text(text, style: theme.textTheme.bodyMedium),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color accent;

  const _StatCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.accent,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final sp = theme.extension<AppSpacing>() ?? const AppSpacing();

    return Container(
      padding: EdgeInsets.all(sp.sm),
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.circular(AppRadii.lg),
        border: Border.all(
          color: cs.outlineVariant.withOpacity(0.55),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: cs.shadow.withOpacity(0.05),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: accent.withOpacity(0.12),
              borderRadius: BorderRadius.circular(AppRadii.md),
              border: Border.all(color: accent.withOpacity(0.22)),
            ),
            child: Icon(icon, color: accent, size: 20),
          ),
          SizedBox(width: sp.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: cs.onSurfaceVariant.withOpacity(0.85),
                    fontWeight: FontWeight.w600,
                    height: 1.2,
                  ),
                ),
                const Spacer(),
                Text(
                  value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w900,
                    letterSpacing: -0.2,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _CenteredMessage extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String message;
  final Widget? action;

  const _CenteredMessage({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.message,
    this.action,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final sp = theme.extension<AppSpacing>() ?? const AppSpacing();

    return Center(
      child: Padding(
        padding: EdgeInsets.all(sp.lg),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 420),
          child: Container(
            padding: EdgeInsets.all(sp.lg),
            decoration: BoxDecoration(
              color: cs.surface,
              borderRadius: BorderRadius.circular(AppRadii.xl),
              border: Border.all(
                color: cs.outlineVariant.withOpacity(0.55),
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: cs.shadow.withOpacity(0.06),
                  blurRadius: 18,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, size: 56, color: iconColor),
                SizedBox(height: sp.md),
                Text(
                  title,
                  textAlign: TextAlign.center,
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w900,
                  ),
                ),
                SizedBox(height: sp.xs),
                Text(
                  message,
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: cs.onSurface.withOpacity(0.78),
                    fontWeight: FontWeight.w600,
                    height: 1.35,
                  ),
                ),
                if (action != null) ...[SizedBox(height: sp.lg), action!],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
