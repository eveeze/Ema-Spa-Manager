// lib/data/models/rating.dart
import 'package:equatable/equatable.dart';

class Rating extends Equatable {
  final String id;
  final double rating;
  final String? comment;
  final DateTime createdAt;
  final String reservationId; // Belongs to a reservation

  const Rating({
    required this.id,
    required this.rating,
    this.comment,
    required this.createdAt,
    required this.reservationId,
  });

  factory Rating.fromJson(Map<String, dynamic> json) {
    return Rating(
      id: json['id'] ?? '',
      rating: (json['rating'] as num?)?.toDouble() ?? 0.0,
      comment: json['comment'],
      createdAt: DateTime.parse(json['createdAt']),
      reservationId: json['reservationId'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'rating': rating,
      'comment': comment,
      'createdAt': createdAt.toIso8601String(),
      'reservationId': reservationId,
    };
  }

  @override
  List<Object?> get props => [id, rating, comment, createdAt, reservationId];
}
