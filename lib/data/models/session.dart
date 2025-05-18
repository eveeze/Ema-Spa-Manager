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
    // Handle semua kemungkinan null
    return Session(
      id: json['id'] as String? ?? 'invalid_id',
      timeSlotId: json['timeSlotId'] as String? ?? 'invalid_timeSlotId',
      staffId: json['staffId'] as String? ?? 'invalid_staffId',
      isBooked: json['isBooked'] as bool? ?? false,
      createdAt: _parseDateTime(json['createdAt']),
      updatedAt: _parseDateTime(json['updatedAt']),
      timeSlot:
          json['timeSlot'] != null
              ? TimeSlot.fromJson(json['timeSlot'] as Map<String, dynamic>)
              : null,
      staff:
          json['staff'] != null
              ? Staff.fromJson(json['staff'] as Map<String, dynamic>)
              : null,
      reservation:
          json['reservation'] != null
              ? Reservation.fromJson(
                json['reservation'] as Map<String, dynamic>,
              )
              : null,
    );
  }
  static DateTime _parseDateTime(dynamic date) {
    if (date == null) return DateTime.now();
    try {
      return DateTime.parse(date as String);
    } catch (_) {
      return DateTime.now();
    }
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
    bool clearTimeSlot = false,
    bool clearStaff = false,
    bool clearReservation = false,
  }) {
    return Session(
      id: id ?? this.id,
      timeSlotId: timeSlotId ?? this.timeSlotId,
      staffId: staffId ?? this.staffId,
      isBooked: isBooked ?? this.isBooked,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      timeSlot: clearTimeSlot ? null : timeSlot ?? this.timeSlot,
      staff: clearStaff ? null : staff ?? this.staff,
      reservation: clearReservation ? null : reservation ?? this.reservation,
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

  @override
  String toString() {
    return 'Session{id: $id, timeSlotId: $timeSlotId, staffId: $staffId, '
        'isBooked: $isBooked, hasTimeSlot: ${timeSlot != null}, '
        'hasStaff: ${staff != null}, hasReservation: ${reservation != null}}';
  }
}
