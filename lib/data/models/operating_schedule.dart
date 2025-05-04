// lib/data/models/operating_schedule.dart
import 'package:equatable/equatable.dart';
import 'time_slot.dart';

class OperatingSchedule extends Equatable {
  final String id;
  final DateTime date;
  final bool isHoliday;
  final String? notes;
  final DateTime createdAt;
  final DateTime updatedAt;
  final List<TimeSlot>? timeSlots;

  const OperatingSchedule({
    required this.id,
    required this.date,
    required this.isHoliday,
    this.notes,
    required this.createdAt,
    required this.updatedAt,
    this.timeSlots,
  });

  factory OperatingSchedule.fromJson(Map<String, dynamic> json) {
    return OperatingSchedule(
      id: json['id'],
      date: DateTime.parse(json['date']),
      isHoliday: json['isHoliday'] ?? false,
      notes: json['notes'],
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
      timeSlots: json['timeSlots'] != null
          ? (json['timeSlots'] as List)
              .map((e) => TimeSlot.fromJson(e))
              .toList()
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {
      'id': id,
      'date': date.toIso8601String(),
      'isHoliday': isHoliday,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };

    if (notes != null) data['notes'] = notes;
    if (timeSlots != null) {
      data['timeSlots'] = timeSlots!.map((e) => e.toJson()).toList();
    }

    return data;
  }

  OperatingSchedule copyWith({
    String? id,
    DateTime? date,
    bool? isHoliday,
    String? notes,
    DateTime? createdAt,
    DateTime? updatedAt,
    List<TimeSlot>? timeSlots,
  }) {
    return OperatingSchedule(
      id: id ?? this.id,
      date: date ?? this.date,
      isHoliday: isHoliday ?? this.isHoliday,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      timeSlots: timeSlots ?? this.timeSlots,
    );
  }

  @override
  List<Object?> get props =>
      [id, date, isHoliday, notes, createdAt, updatedAt, timeSlots];
}

