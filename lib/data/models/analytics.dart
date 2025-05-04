// lib/data/models/analytics.dart
import 'package:equatable/equatable.dart';

class Analytics extends Equatable {
  final String id;
  final DateTime date;
  final double totalRevenue;
  final int totalBookings;
  final int completedBookings;
  final int cancelledBookings;
  final String? popularServiceId;
  final String? popularStaffId;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Analytics({
    required this.id,
    required this.date,
    required this.totalRevenue,
    required this.totalBookings,
    required this.completedBookings,
    required this.cancelledBookings,
    this.popularServiceId,
    this.popularStaffId,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Analytics.fromJson(Map<String, dynamic> json) {
    return Analytics(
      id: json['id'],
      date: DateTime.parse(json['date']),
      totalRevenue: json['totalRevenue'].toDouble(),
      totalBookings: json['totalBookings'],
      completedBookings: json['completedBookings'],
      cancelledBookings: json['cancelledBookings'],
      popularServiceId: json['popularServiceId'],
      popularStaffId: json['popularStaffId'],
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'date': date.toIso8601String(),
      'totalRevenue': totalRevenue,
      'totalBookings': totalBookings,
      'completedBookings': completedBookings,
      'cancelledBookings': cancelledBookings,
      'popularServiceId': popularServiceId,
      'popularStaffId': popularStaffId,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  Analytics copyWith({
    String? id,
    DateTime? date,
    double? totalRevenue,
    int? totalBookings,
    int? completedBookings,
    int? cancelledBookings,
    String? popularServiceId,
    String? popularStaffId,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Analytics(
      id: id ?? this.id,
      date: date ?? this.date,
      totalRevenue: totalRevenue ?? this.totalRevenue,
      totalBookings: totalBookings ?? this.totalBookings,
      completedBookings: completedBookings ?? this.completedBookings,
      cancelledBookings: cancelledBookings ?? this.cancelledBookings,
      popularServiceId: popularServiceId ?? this.popularServiceId,
      popularStaffId: popularStaffId ?? this.popularStaffId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        date,
        totalRevenue,
        totalBookings,
        completedBookings,
        cancelledBookings,
        popularServiceId,
        popularStaffId,
        createdAt,
        updatedAt,
      ];
}