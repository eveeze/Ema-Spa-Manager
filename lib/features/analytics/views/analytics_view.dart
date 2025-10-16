// lib/features/analytics/views/analytics_view.dart

import 'package:emababyspa/common/layouts/main_layout.dart';
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
                const SizedBox(height: 16),
                Text(
                  controller.errorMessage.value!,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                const SizedBox(height: 16),
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
          return const Center(child: Text('Tidak ada data analitik tersedia.'));
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
    final ratingStats = controller.detailsData.value!.ratingStats;
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      physics: const AlwaysScrollableScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildDateFilter(context),
          const SizedBox(height: 24),
          _buildStatsGrid(context),
          const SizedBox(height: 24),
          _buildRevenueChart(context),
          const SizedBox(height: 24),
          _buildTopPerformingList(
            context,
            'Layanan Terlaris',
            controller.detailsData.value!.topPerformingServices,
            Icons.spa_outlined,
          ),
          const SizedBox(height: 24),
          _buildTopPerformingList(
            context,
            'Terapis Terbaik',
            controller.detailsData.value!.topPerformingStaff,
            Icons.support_agent_outlined,
          ),
          const SizedBox(height: 24),
          // <-- WIDGET BARU UNTUK RATING -->
          _buildRatingSection(context, ratingStats),
          const SizedBox(height: 16),
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
    // Data rating baru
    final overallRating =
        controller.detailsData.value!.ratingStats.overallAverageRating;

    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      childAspectRatio: 1.6,
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
        // <-- KARTU BARU UNTUK RATA-RATA RATING -->
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

  /// Membangun grafik pendapatan menggunakan [LineChart] dari `fl_chart`.
  Widget _buildRevenueChart(BuildContext context) {
    final theme = Theme.of(context);
    final chartData = controller.detailsData.value!.revenueChartData;

    if (chartData.isEmpty) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Grafik Pendapatan',
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Container(
            height: 250,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: theme.colorScheme.outlineVariant),
            ),
            child: const Center(
              child: Text('Tidak ada data pendapatan untuk ditampilkan.'),
            ),
          ),
        ],
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
        const SizedBox(height: 16),
        Container(
          height: 250,
          padding: const EdgeInsets.fromLTRB(16, 24, 16, 12),
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
                          padding: const EdgeInsets.only(top: 8.0),
                          child: Text(
                            DateFormat('d/M').format(date),
                            style: TextStyle(
                              color: theme.colorScheme.onSurfaceVariant,
                              fontSize: 10,
                              fontWeight: FontWeight.w500,
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

  /// Membangun daftar performa terbaik (layanan atau terapis).
  Widget _buildTopPerformingList(
    BuildContext context,
    String title,
    List<TopPerformingItem> items,
    IconData sectionIcon,
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
        const SizedBox(height: 16),
        if (items.isEmpty)
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: theme.colorScheme.outlineVariant),
            ),
            child: const Center(
              child: Text('Tidak ada data untuk ditampilkan.'),
            ),
          )
        else
          ListView.separated(
            itemCount: items.length,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            separatorBuilder: (_, __) => const SizedBox(height: 10),
            itemBuilder: (context, index) {
              final item = items[index];
              return Container(
                decoration: BoxDecoration(
                  color: theme.colorScheme.surface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: theme.colorScheme.outlineVariant),
                ),
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  leading: CircleAvatar(
                    backgroundColor: theme.colorScheme.primaryContainer,
                    foregroundColor: theme.colorScheme.onPrimaryContainer,
                    backgroundImage:
                        item.imageUrl != null && item.imageUrl!.isNotEmpty
                            ? NetworkImage(item.imageUrl!)
                            : null,
                    child:
                        item.imageUrl == null || item.imageUrl!.isEmpty
                            ? Icon(sectionIcon, size: 20)
                            : null,
                  ),
                  title: Text(
                    item.name,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  trailing: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primaryContainer,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      '${item.count} Sesi',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onPrimaryContainer,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
      ],
    );
  }

  /// [BARU] Membangun section untuk menampilkan statistik rating.
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
        const SizedBox(height: 24),
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

  /// [BARU] Membangun daftar layanan berdasarkan rating (tertinggi/terendah).
  Widget _buildRatedServiceList(
    BuildContext context,
    String title,
    List<RatedServiceItem> items,
    IconData sectionIcon,
    Color iconColor,
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
        const SizedBox(height: 16),
        if (items.isEmpty)
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: theme.colorScheme.outlineVariant),
            ),
            child: const Center(
              child: Text('Belum ada layanan yang dirating.'),
            ),
          )
        else
          ListView.separated(
            itemCount: items.length,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            separatorBuilder: (_, __) => const SizedBox(height: 10),
            itemBuilder: (context, index) {
              final item = items[index];
              return Container(
                decoration: BoxDecoration(
                  color: theme.colorScheme.surface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: theme.colorScheme.outlineVariant),
                ),
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  leading: CircleAvatar(
                    backgroundColor: iconColor.withOpacity(0.1),
                    foregroundColor: iconColor,
                    child: Icon(sectionIcon, size: 20),
                  ),
                  title: Text(
                    item.name,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.star, color: Colors.amber[600], size: 18),
                      const SizedBox(width: 4),
                      Text(
                        item.averageRating.toStringAsFixed(2),
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.onSurface,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
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
      padding: const EdgeInsets.all(16),
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
            children: [
              Expanded(
                child: Text(
                  title,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
              Icon(icon, color: color, size: 24),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
          ),
        ],
      ),
    );
  }
}
