// lib/features/analytics/views/analytics_view.dart

import 'package:emababyspa/common/layouts/main_layout.dart';
import 'package:emababyspa/common/theme/text_theme.dart';
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
    return MainLayout.subPage(
      title: 'Statistik',
      parentRoute: AppRoutes.analyticsView,
      showAppBar: true,
      showBottomNavigation: true,
      child: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }
        if (controller.errorMessage.value != null) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.error_outline,
                  size: 64,
                  color: Theme.of(context).colorScheme.error,
                ),
                SizedBox(height: M3Spacing.md),
                Text(
                  controller.errorMessage.value!,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                SizedBox(height: M3Spacing.md),
                ElevatedButton.icon(
                  onPressed: controller.refreshData,
                  icon: const Icon(Icons.refresh),
                  label: const Text('Coba Lagi'),
                ),
              ],
            ),
          );
        }
        if (controller.detailsData.value == null) {
          return Center(
            child: Text(
              'Tidak ada data analitik tersedia.',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
          );
        }
        return RefreshIndicator(
          onRefresh: controller.refreshData,
          child: _buildAnalyticsContent(context),
        );
      }),
    );
  }

  /// Widget utama yang membangun seluruh konten halaman.
  Widget _buildAnalyticsContent(BuildContext context) {
    final details = controller.detailsData.value!;
    return SingleChildScrollView(
      padding: EdgeInsets.all(M3Spacing.md),
      physics: const AlwaysScrollableScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildDateFilter(context),
          SizedBox(height: M3Spacing.lg),
          _buildStatsGrid(context),
          SizedBox(height: M3Spacing.lg),
          _buildRevenueChart(context),
          SizedBox(height: M3Spacing.lg),
          _buildReservationStatusChart(context, details.reservationStats),
          SizedBox(height: M3Spacing.lg),
          _buildTopPerformingBarChart(
            context,
            'Layanan Terlaris',
            details.topPerformingServices,
            Icons.spa_outlined,
            (item) => '${item.count} Sesi',
          ),
          SizedBox(height: M3Spacing.lg),
          _buildTopPerformingBarChart(
            context,
            'Terapis Terbaik',
            details.topPerformingStaff,
            Icons.support_agent_outlined,
            (item) => '${item.count} Sesi',
          ),
          SizedBox(height: M3Spacing.lg),
          _buildRatingSection(context, details.ratingStats),
          SizedBox(height: M3Spacing.md),
        ],
      ),
    );
  }

  /// Membangun widget filter tanggal menggunakan [SegmentedButton].
  Widget _buildDateFilter(BuildContext context) {
    final theme = Theme.of(context);
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
          backgroundColor: theme.colorScheme.surface,
          foregroundColor: theme.colorScheme.primary,
          selectedBackgroundColor: theme.colorScheme.primary,
          selectedForegroundColor: theme.colorScheme.onPrimary,
          textStyle: theme.textTheme.labelLarge,
        ),
      ),
    );
  }

  /// Membangun grid statistik utama (Pendapatan, Reservasi, dll).
  Widget _buildStatsGrid(BuildContext context) {
    final stats = controller.detailsData.value!.reservationStats;
    final totalRevenue = controller.detailsData.value!.revenueChartData.fold(
      0.0,
      (sum, item) => sum + item.revenue,
    );
    final overallRating =
        controller.detailsData.value!.ratingStats.overallAverageRating;

    // Responsive grid: 2 columns on small screens, 4 on larger screens
    final width = MediaQuery.of(context).size.width;
    final crossAxisCount = width > 600 ? 4 : 2;
    final childAspectRatio = width > 600 ? 1.4 : 1.3;

    return GridView.count(
      crossAxisCount: crossAxisCount,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: M3Spacing.sm,
      mainAxisSpacing: M3Spacing.sm,
      childAspectRatio: childAspectRatio,
      children: [
        _buildStatCard(
          context: context,
          title: 'Total Pendapatan',
          value: NumberFormat.currency(
            locale: 'id_ID',
            symbol: 'Rp ',
            decimalDigits: 0,
          ).format(totalRevenue),
          icon: Icons.monetization_on_outlined,
          color: Colors.green,
        ),
        _buildStatCard(
          context: context,
          title: 'Total Reservasi',
          value: stats.total.toString(),
          icon: Icons.event_available_outlined,
          color: Colors.purple,
        ),
        _buildStatCard(
          context: context,
          title: 'Sesi Selesai',
          value: stats.completed.toString(),
          icon: Icons.check_circle_outline,
          color: Colors.cyan,
        ),
        _buildStatCard(
          context: context,
          title: 'Rata-Rata Rating',
          value: overallRating.toStringAsFixed(2),
          icon: Icons.star_outline,
          color: Colors.amber,
        ),
      ],
    );
  }

  /// Membangun grafik pendapatan menggunakan [LineChart].
  Widget _buildRevenueChart(BuildContext context) {
    final theme = Theme.of(context);
    final chartData = controller.detailsData.value!.revenueChartData;

    if (chartData.isEmpty) {
      return _buildEmptyChartContainer(
        context,
        'Grafik Pendapatan',
        'Tidak ada data pendapatan untuk ditampilkan.',
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Grafik Pendapatan',
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: M3Spacing.md),
        Container(
          height: 250,
          padding: EdgeInsets.fromLTRB(
            M3Spacing.md,
            M3Spacing.lg,
            M3Spacing.md,
            M3Spacing.sm,
          ),
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: theme.colorScheme.outlineVariant),
          ),
          child: LineChart(
            LineChartData(
              gridData: const FlGridData(show: false),
              titlesData: FlTitlesData(
                leftTitles: const AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
                topTitles: const AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
                rightTitles: const AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 30,
                    getTitlesWidget: (value, meta) {
                      if (value.toInt() < chartData.length) {
                        final date = DateTime.parse(
                          chartData[value.toInt()].date,
                        );
                        return Padding(
                          padding: EdgeInsets.only(top: M3Spacing.sm),
                          child: Text(
                            DateFormat('d/M').format(date),
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                        );
                      }
                      return const SizedBox.shrink();
                    },
                  ),
                ),
              ),
              borderData: FlBorderData(show: false),
              lineBarsData: [
                LineChartBarData(
                  spots:
                      chartData.asMap().entries.map((entry) {
                        return FlSpot(
                          entry.key.toDouble(),
                          entry.value.revenue,
                        );
                      }).toList(),
                  isCurved: true,
                  color: theme.colorScheme.primary,
                  barWidth: 3,
                  isStrokeCapRound: true,
                  dotData: const FlDotData(show: false),
                  belowBarData: BarAreaData(
                    show: true,
                    gradient: LinearGradient(
                      colors: [
                        theme.colorScheme.primary.withOpacity(0.4),
                        theme.colorScheme.primary.withOpacity(0.0),
                      ],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                  ),
                ),
              ],
              lineTouchData: LineTouchData(
                touchTooltipData: LineTouchTooltipData(
                  getTooltipColor:
                      (touchedSpot) =>
                          theme.colorScheme.primary.withOpacity(0.8),
                  getTooltipItems: (List<LineBarSpot> touchedSpots) {
                    return touchedSpots.map((spot) {
                      return LineTooltipItem(
                        NumberFormat.currency(
                          locale: 'id_ID',
                          symbol: 'Rp ',
                          decimalDigits: 0,
                        ).format(spot.y),
                        TextStyle(
                          color: theme.colorScheme.onPrimary,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      );
                    }).toList();
                  },
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  /// Membangun Pie Chart untuk status reservasi.
  Widget _buildReservationStatusChart(
    BuildContext context,
    ReservationStats stats,
  ) {
    final theme = Theme.of(context);
    final sections = <PieChartSectionData>[];
    final legendItems = <Widget>[];

    void addSection(String title, int value, Color color) {
      if (value > 0) {
        sections.add(
          PieChartSectionData(
            color: color,
            value: value.toDouble(),
            title: '$value',
            radius: 50,
            titleStyle: theme.textTheme.labelLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.onPrimary,
            ),
          ),
        );
        legendItems.add(_buildLegendItem(context, color, title));
      }
    }

    addSection('Selesai', stats.completed, Colors.green);
    addSection('Dibatalkan', stats.cancelled, theme.colorScheme.error);
    addSection('Pending', stats.pending, Colors.orange);
    addSection(
      'Terkonfirmasi',
      stats.total - stats.completed - stats.cancelled - stats.pending,
      theme.colorScheme.primary,
    );

    if (sections.isEmpty) {
      return _buildEmptyChartContainer(
        context,
        'Status Reservasi',
        'Tidak ada data status reservasi untuk ditampilkan.',
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Status Reservasi',
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: M3Spacing.md),
        Container(
          padding: EdgeInsets.all(M3Spacing.md),
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: theme.colorScheme.outlineVariant),
          ),
          child: LayoutBuilder(
            builder: (context, constraints) {
              // Responsive layout for pie chart
              if (constraints.maxWidth > 400) {
                return Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: AspectRatio(
                        aspectRatio: 1,
                        child: PieChart(
                          PieChartData(
                            sections: sections,
                            sectionsSpace: 2,
                            centerSpaceRadius: 40,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: M3Spacing.lg),
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
              } else {
                return Column(
                  children: [
                    AspectRatio(
                      aspectRatio: 1,
                      child: PieChart(
                        PieChartData(
                          sections: sections,
                          sectionsSpace: 2,
                          centerSpaceRadius: 40,
                        ),
                      ),
                    ),
                    SizedBox(height: M3Spacing.md),
                    ...legendItems,
                  ],
                );
              }
            },
          ),
        ),
      ],
    );
  }

  /// Helper untuk membuat item legenda Pie Chart.
  Widget _buildLegendItem(BuildContext context, Color color, String text) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: M3Spacing.xs),
      child: Row(
        children: [
          Container(
            width: 16,
            height: 16,
            decoration: BoxDecoration(shape: BoxShape.circle, color: color),
          ),
          SizedBox(width: M3Spacing.sm),
          Text(text, style: Theme.of(context).textTheme.bodyMedium),
        ],
      ),
    );
  }

  /// Membangun Bar Chart horizontal untuk item terlaris.
  Widget _buildTopPerformingBarChart(
    BuildContext context,
    String title,
    List<TopPerformingItem> items,
    IconData sectionIcon,
    String Function(TopPerformingItem) valueFormatter,
  ) {
    final theme = Theme.of(context);

    if (items.isEmpty) {
      return _buildEmptyChartContainer(
        context,
        title,
        'Tidak ada data untuk ditampilkan.',
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: M3Spacing.md),
        Container(
          padding: EdgeInsets.all(M3Spacing.md),
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: theme.colorScheme.outlineVariant),
          ),
          child: Column(
            children:
                items.map((item) {
                  final maxValue = items.first.count.toDouble();
                  final currentValue = item.count.toDouble();
                  return Padding(
                    padding: EdgeInsets.symmetric(vertical: M3Spacing.sm),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                item.name,
                                style: theme.textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            SizedBox(width: M3Spacing.sm),
                            Text(
                              valueFormatter(item),
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: theme.colorScheme.primary,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: M3Spacing.sm),
                        LinearProgressIndicator(
                          value: maxValue > 0 ? currentValue / maxValue : 0,
                          backgroundColor: theme.colorScheme.surfaceVariant,
                          color: theme.colorScheme.primary,
                          minHeight: 8,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ],
                    ),
                  );
                }).toList(),
          ),
        ),
      ],
    );
  }

  /// Menggunakan bar indicator untuk rating.
  Widget _buildRatingSection(BuildContext context, RatingStats ratingStats) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildRatedServiceList(
          context,
          'Layanan Rating Tertinggi',
          ratingStats.topRatedServices,
          Icons.thumb_up_alt_outlined,
          Colors.green,
        ),
        SizedBox(height: M3Spacing.lg),
        _buildRatedServiceList(
          context,
          'Layanan Rating Terendah',
          ratingStats.lowestRatedServices,
          Icons.thumb_down_alt_outlined,
          Colors.orange,
        ),
      ],
    );
  }

  /// Membangun daftar layanan dengan LinearProgressIndicator.
  Widget _buildRatedServiceList(
    BuildContext context,
    String title,
    List<RatedServiceItem> items,
    IconData sectionIcon,
    Color iconColor,
  ) {
    final theme = Theme.of(context);
    if (items.isEmpty) {
      return _buildEmptyChartContainer(
        context,
        title,
        'Belum ada layanan yang dirating.',
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: M3Spacing.md),
        Container(
          padding: EdgeInsets.all(M3Spacing.md),
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: theme.colorScheme.outlineVariant),
          ),
          child: Column(
            children:
                items.map((item) {
                  return Padding(
                    padding: EdgeInsets.symmetric(vertical: M3Spacing.sm),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                item.name,
                                style: theme.textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            SizedBox(width: M3Spacing.sm),
                            Row(
                              children: [
                                Icon(
                                  Icons.star,
                                  color: Colors.amber[600],
                                  size: 18,
                                ),
                                SizedBox(width: M3Spacing.xs),
                                Text(
                                  item.averageRating.toStringAsFixed(2),
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: theme.colorScheme.onSurface,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        SizedBox(height: M3Spacing.sm),
                        LinearProgressIndicator(
                          value: item.averageRating / 5.0,
                          backgroundColor: theme.colorScheme.surfaceVariant,
                          color: iconColor,
                          minHeight: 8,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ],
                    ),
                  );
                }).toList(),
          ),
        ),
      ],
    );
  }

  /// Widget kartu individual untuk menampilkan satu metrik statistik.
  Widget _buildStatCard({
    required BuildContext context,
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    final theme = Theme.of(context);
    return Container(
      padding: EdgeInsets.all(M3Spacing.sm),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: theme.colorScheme.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  title,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              SizedBox(width: M3Spacing.xs),
              Icon(icon, color: color, size: 20),
            ],
          ),
          const Spacer(),
          Text(
            value,
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
          ),
        ],
      ),
    );
  }

  /// Helper widget untuk kontainer chart yang kosong.
  Widget _buildEmptyChartContainer(
    BuildContext context,
    String title,
    String message,
  ) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: M3Spacing.md),
        Container(
          height: 200,
          width: double.infinity,
          padding: EdgeInsets.all(M3Spacing.md),
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: theme.colorScheme.outlineVariant),
          ),
          child: Center(
            child: Text(
              message,
              style: theme.textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ],
    );
  }
}
