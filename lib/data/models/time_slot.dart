// lib/data/models/time_slot.dart
import 'package:equatable/equatable.dart';
import 'operating_schedule.dart';
import 'session.dart';

class TimeSlot extends Equatable {
  final String id;
  final String operatingScheduleId;
  final OperatingSchedule? operatingSchedule;
  final DateTime startTime;
  final DateTime endTime;
  final DateTime createdAt;
  final DateTime updatedAt;
  final List<Session>? sessions;

  const TimeSlot({
    required this.id,
    required this.operatingScheduleId,
    this.operatingSchedule,
    required this.startTime,
    required this.endTime,
    required this.createdAt,
    required this.updatedAt,
    this.sessions,
  });

  factory TimeSlot.fromJson(Map<String, dynamic> json) {
    return TimeSlot(
      id: json['id'],
      operatingScheduleId: json['operatingScheduleId'],
      operatingSchedule:
          json['operatingSchedule'] != null
              ? OperatingSchedule.fromJson(json['operatingSchedule'])
              : null,
      startTime: DateTime.parse(json['startTime']),
      endTime: DateTime.parse(json['endTime']),
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
      sessions:
          json['sessions'] != null
              ? (json['sessions'] as List)
                  .map((e) => Session.fromJson(e))
                  .toList()
              : null,
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {
      'id': id,
      'operatingScheduleId': operatingScheduleId,
      'startTime': startTime.toIso8601String(),
      'endTime': endTime.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };

    if (operatingSchedule != null) {
      data['operatingSchedule'] = operatingSchedule!.toJson();
    }
    if (sessions != null) {
      data['sessions'] = sessions!.map((e) => e.toJson()).toList();
    }

    return data;
  }

  TimeSlot copyWith({
    String? id,
    String? operatingScheduleId,
    OperatingSchedule? operatingSchedule,
    DateTime? startTime,
    DateTime? endTime,
    DateTime? createdAt,
    DateTime? updatedAt,
    List<Session>? sessions,
  }) {
    return TimeSlot(
      id: id ?? this.id,
      operatingScheduleId: operatingScheduleId ?? this.operatingScheduleId,
      operatingSchedule: operatingSchedule ?? this.operatingSchedule,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      sessions: sessions ?? this.sessions,
    );
  }

  @override
  List<Object?> get props => [
    id,
    operatingScheduleId,
    operatingSchedule,
    startTime,
    endTime,
    createdAt,
    updatedAt,
    sessions,
  ];
}
