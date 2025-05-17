// lib/data/models/session.dart
import 'package:equatable/equatable.dart';
import 'package:emababyspa/data/models/time_slot.dart';
import 'package:emababyspa/data/models/staff.dart';
import 'package:emababyspa/data/models/reservation.dart';

class Session extends Equatable {
  final String id;
  final String timeSlotId;
  final String staffId;
  final bool isBooked;
  final DateTime createdAt;
  final DateTime updatedAt;

  // Relasi objek (opsional, diisi saat dibutuhkan)
  final TimeSlot? timeSlot;
  final Staff? staff;
  final Reservation? reservation;

  const Session({
    required this.id,
    required this.timeSlotId,
    required this.staffId,
    required this.isBooked,
    required this.createdAt,
    required this.updatedAt,
    this.timeSlot,
    this.staff,
    this.reservation,
  });

  factory Session.fromJson(Map<String, dynamic> json) {
    return Session(
      id: json['id'],
      timeSlotId: json['timeSlotId'],
      staffId: json['staffId'],
      isBooked: json['isBooked'] ?? false,
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
      // Handle nested objects if they exist in response
      timeSlot:
          json['timeSlot'] != null ? TimeSlot.fromJson(json['timeSlot']) : null,
      staff: json['staff'] != null ? Staff.fromJson(json['staff']) : null,
      reservation:
          json['reservation'] != null
              ? Reservation.fromJson(json['reservation'])
              : null,
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {
      'id': id,
      'timeSlotId': timeSlotId,
      'staffId': staffId,
      'isBooked': isBooked,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };

    // Only include related objects if they exist
    if (timeSlot != null) {
      data['timeSlot'] = timeSlot!.toJson();
    }
    if (staff != null) {
      data['staff'] = staff!.toJson();
    }
    if (reservation != null) {
      data['reservation'] = reservation!.toJson();
    }

    return data;
  }

  Session copyWith({
    String? id,
    String? timeSlotId,
    String? staffId,
    bool? isBooked,
    DateTime? createdAt,
    DateTime? updatedAt,
    TimeSlot? timeSlot,
    Staff? staff,
    Reservation? reservation,
  }) {
    return Session(
      id: id ?? this.id,
      timeSlotId: timeSlotId ?? this.timeSlotId,
      staffId: staffId ?? this.staffId,
      isBooked: isBooked ?? this.isBooked,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      timeSlot: timeSlot ?? this.timeSlot,
      staff: staff ?? this.staff,
      reservation: reservation ?? this.reservation,
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
    // Don't include the optional relationship objects in equality comparison
    // since they might not always be loaded
  ];
}
