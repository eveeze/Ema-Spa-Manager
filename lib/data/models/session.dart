// lib/data/models/session.dart
import 'package:equatable/equatable.dart';

class Session extends Equatable {
  final String id;
  final String timeSlotId;
  final String staffId;
  final bool isBooked;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Session({
    required this.id,
    required this.timeSlotId,
    required this.staffId,
    required this.isBooked,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Session.fromJson(Map<String, dynamic> json) {
    return Session(
      id: json['id'],
      timeSlotId: json['timeSlotId'],
      staffId: json['staffId'],
      isBooked: json['isBooked'] ?? false,
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'timeSlotId': timeSlotId,
      'staffId': staffId,
      'isBooked': isBooked,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  Session copyWith({
    String? id,
    String? timeSlotId,
    String? staffId,
    bool? isBooked,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Session(
      id: id ?? this.id,
      timeSlotId: timeSlotId ?? this.timeSlotId,
      staffId: staffId ?? this.staffId,
      isBooked: isBooked ?? this.isBooked,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
    id,
    timeSlotId,
    staffId,
    isBooked,
    createdAt,
    updatedAt,
  ];
}
