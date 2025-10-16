// lib/data/models/analytics.dart
import 'package:equatable/equatable.dart';

// ===== Model untuk Respons Endpoint /overview =====

class AnalyticsOverview extends Equatable {
  final double revenueToday;
  final int newCustomersToday;
  final int upcomingReservationsTomorrow;

  const AnalyticsOverview({
    required this.revenueToday,
    required this.newCustomersToday,
    required this.upcomingReservationsTomorrow,
  });

  factory AnalyticsOverview.fromJson(Map<String, dynamic> json) {
    return AnalyticsOverview(
      revenueToday: (json['revenueToday'] as num?)?.toDouble() ?? 0.0,
      newCustomersToday: (json['newCustomersToday'] as num?)?.toInt() ?? 0,
      upcomingReservationsTomorrow:
          (json['upcomingReservationsTomorrow'] as num?)?.toInt() ?? 0,
    );
  }

  @override
  List<Object?> get props => [
    revenueToday,
    newCustomersToday,
    upcomingReservationsTomorrow,
  ];
}

// ===== Model untuk Respons Endpoint /details =====

class AnalyticsDetails extends Equatable {
  final Period period;
  final ReservationStats reservationStats;
  final List<RevenueChartData> revenueChartData;
  final List<TopPerformingItem> topPerformingServices;
  final List<TopPerformingItem> topPerformingStaff;
  final RatingStats ratingStats; // <-- BARU: Tambahkan rating stats

  const AnalyticsDetails({
    required this.period,
    required this.reservationStats,
    required this.revenueChartData,
    required this.topPerformingServices,
    required this.topPerformingStaff,
    required this.ratingStats, // <-- BARU: Tambahkan di constructor
  });

  factory AnalyticsDetails.fromJson(Map<String, dynamic> json) {
    return AnalyticsDetails(
      period: Period.fromJson(json['period'] ?? {}),
      reservationStats: ReservationStats.fromJson(
        json['reservationStats'] ?? {},
      ),
      revenueChartData:
          (json['revenueChartData'] as List<dynamic>?)
              ?.map((item) => RevenueChartData.fromJson(item))
              .toList() ??
          [],
      topPerformingServices:
          (json['topPerformingServices'] as List<dynamic>?)
              ?.map((item) => TopPerformingItem.fromJson(item))
              .toList() ??
          [],
      topPerformingStaff:
          (json['topPerformingStaff'] as List<dynamic>?)
              ?.map((item) => TopPerformingItem.fromJson(item))
              .toList() ??
          [],
      // <-- BARU: Parsing data rating stats dari JSON
      ratingStats: RatingStats.fromJson(json['ratingStats'] ?? {}),
    );
  }

  @override
  List<Object?> get props => [
    period,
    reservationStats,
    revenueChartData,
    topPerformingServices,
    topPerformingStaff,
    ratingStats, // <-- BARU: Tambahkan ke props
  ];
}

class Period extends Equatable {
  final DateTime startDate;
  final DateTime endDate;

  const Period({required this.startDate, required this.endDate});

  factory Period.fromJson(Map<String, dynamic> json) {
    return Period(
      startDate: DateTime.tryParse(json['startDate'] ?? '') ?? DateTime.now(),
      endDate: DateTime.tryParse(json['endDate'] ?? '') ?? DateTime.now(),
    );
  }

  @override
  List<Object?> get props => [startDate, endDate];
}

class ReservationStats extends Equatable {
  final int total;
  final int completed;
  final int cancelled;
  final int pending;

  const ReservationStats({
    required this.total,
    required this.completed,
    required this.cancelled,
    required this.pending,
  });

  factory ReservationStats.fromJson(Map<String, dynamic> json) {
    return ReservationStats(
      total: (json['total'] as num?)?.toInt() ?? 0,
      completed: (json['completed'] as num?)?.toInt() ?? 0,
      cancelled: (json['cancelled'] as num?)?.toInt() ?? 0,
      pending: (json['pending'] as num?)?.toInt() ?? 0,
    );
  }

  @override
  List<Object?> get props => [total, completed, cancelled, pending];
}

class RevenueChartData extends Equatable {
  final String date;
  final double revenue;

  const RevenueChartData({required this.date, required this.revenue});

  factory RevenueChartData.fromJson(Map<String, dynamic> json) {
    return RevenueChartData(
      date: json['date'] ?? '',
      revenue: (json['revenue'] as num?)?.toDouble() ?? 0.0,
    );
  }

  @override
  List<Object?> get props => [date, revenue];
}

class TopPerformingItem extends Equatable {
  final String id;
  final String name;
  final String? imageUrl;
  final int count;

  const TopPerformingItem({
    required this.id,
    required this.name,
    this.imageUrl,
    required this.count,
  });

  factory TopPerformingItem.fromJson(Map<String, dynamic> json) {
    // Backend mengirim 'bookingCount' untuk service dan 'completedServices' untuk staff
    final int itemCount =
        (json['bookingCount'] as num?)?.toInt() ??
        (json['completedServices'] as num?)?.toInt() ??
        0;

    return TopPerformingItem(
      id: json['id'] ?? '',
      name: json['name'] ?? 'Unknown',
      imageUrl: json['imageUrl'] ?? json['profilePicture'],
      count: itemCount,
    );
  }

  @override
  List<Object?> get props => [id, name, imageUrl, count];
}

// ===== MODEL BARU UNTUK RATING STATS =====

class RatingStats extends Equatable {
  final double overallAverageRating;
  final List<RatedServiceItem> topRatedServices;
  final List<RatedServiceItem> lowestRatedServices;

  const RatingStats({
    required this.overallAverageRating,
    required this.topRatedServices,
    required this.lowestRatedServices,
  });

  factory RatingStats.fromJson(Map<String, dynamic> json) {
    return RatingStats(
      overallAverageRating:
          (json['overallAverageRating'] as num?)?.toDouble() ?? 0.0,
      topRatedServices:
          (json['topRatedServices'] as List<dynamic>?)
              ?.map((item) => RatedServiceItem.fromJson(item))
              .toList() ??
          [],
      lowestRatedServices:
          (json['lowestRatedServices'] as List<dynamic>?)
              ?.map((item) => RatedServiceItem.fromJson(item))
              .toList() ??
          [],
    );
  }

  @override
  List<Object?> get props => [
    overallAverageRating,
    topRatedServices,
    lowestRatedServices,
  ];
}

class RatedServiceItem extends Equatable {
  final String id;
  final String name;
  final double averageRating;

  const RatedServiceItem({
    required this.id,
    required this.name,
    required this.averageRating,
  });

  factory RatedServiceItem.fromJson(Map<String, dynamic> json) {
    return RatedServiceItem(
      id: json['id'] ?? '',
      name: json['name'] ?? 'Unknown',
      averageRating: (json['averageRating'] as num?)?.toDouble() ?? 0.0,
    );
  }

  @override
  List<Object?> get props => [id, name, averageRating];
}
