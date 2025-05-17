// lib/data/models/scheduler.dart
import 'package:equatable/equatable.dart';

class ScheduleGenerationRequest extends Equatable {
  final String? startDate;
  final int? days;
  final List<String>? holidayDates;
  final TimeConfig? timeConfig;
  final int? timeZoneOffset;

  const ScheduleGenerationRequest({
    this.startDate,
    this.days = 7,
    this.holidayDates,
    this.timeConfig,
    this.timeZoneOffset,
  });

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};

    if (startDate != null) data['startDate'] = startDate;
    if (days != null) data['days'] = days;
    if (holidayDates != null) data['holidayDates'] = holidayDates;
    if (timeConfig != null) data['timeConfig'] = timeConfig!.toJson();
    if (timeZoneOffset != null) data['timeZoneOffset'] = timeZoneOffset;

    return data;
  }

  factory ScheduleGenerationRequest.fromJson(Map<String, dynamic> json) {
    return ScheduleGenerationRequest(
      startDate: json['startDate'],
      days: json['days'],
      holidayDates:
          json['holidayDates'] != null
              ? List<String>.from(json['holidayDates'])
              : null,
      timeConfig:
          json['timeConfig'] != null
              ? TimeConfig.fromJson(json['timeConfig'])
              : null,
      timeZoneOffset: json['timeZoneOffset'],
    );
  }

  @override
  List<Object?> get props => [
    startDate,
    days,
    holidayDates,
    timeConfig,
    timeZoneOffset,
  ];
}

class ComponentGenerationRequest extends Equatable {
  final String component;
  final List<String>? scheduleIds;
  final String? startDate;
  final int? days;
  final List<String>? holidayDates;
  final TimeConfig? timeConfig;
  final int? timeZoneOffset;
  final Map<String, List<String>>? timeSlotsBySchedule;

  const ComponentGenerationRequest({
    required this.component,
    this.scheduleIds,
    this.startDate,
    this.days = 7,
    this.holidayDates,
    this.timeConfig,
    this.timeZoneOffset,
    this.timeSlotsBySchedule,
  });

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};

    data['component'] = component;
    if (scheduleIds != null) data['scheduleIds'] = scheduleIds;
    if (startDate != null) data['startDate'] = startDate;
    if (days != null) data['days'] = days;
    if (holidayDates != null) data['holidayDates'] = holidayDates;
    if (timeConfig != null) data['timeConfig'] = timeConfig!.toJson();
    if (timeZoneOffset != null) data['timeZoneOffset'] = timeZoneOffset;
    if (timeSlotsBySchedule != null) {
      data['timeSlotsBySchedule'] = timeSlotsBySchedule;
    }

    return data;
  }

  factory ComponentGenerationRequest.fromJson(Map<String, dynamic> json) {
    return ComponentGenerationRequest(
      component: json['component'],
      scheduleIds:
          json['scheduleIds'] != null
              ? List<String>.from(json['scheduleIds'])
              : null,
      startDate: json['startDate'],
      days: json['days'],
      holidayDates:
          json['holidayDates'] != null
              ? List<String>.from(json['holidayDates'])
              : null,
      timeConfig:
          json['timeConfig'] != null
              ? TimeConfig.fromJson(json['timeConfig'])
              : null,
      timeZoneOffset: json['timeZoneOffset'],
      timeSlotsBySchedule:
          json['timeSlotsBySchedule'] != null
              ? Map<String, List<String>>.from(json['timeSlotsBySchedule'])
              : null,
    );
  }

  @override
  List<Object?> get props => [
    component,
    scheduleIds,
    startDate,
    days,
    holidayDates,
    timeConfig,
    timeZoneOffset,
    timeSlotsBySchedule,
  ];
}

class TimeConfig extends Equatable {
  final int startHour;
  final int endHour;
  final int slotDurationMinutes;

  const TimeConfig({
    required this.startHour,
    required this.endHour,
    required this.slotDurationMinutes,
  });

  Map<String, dynamic> toJson() {
    return {
      'startHour': startHour,
      'endHour': endHour,
      'slotDurationMinutes': slotDurationMinutes,
    };
  }

  factory TimeConfig.fromJson(Map<String, dynamic> json) {
    return TimeConfig(
      startHour: json['startHour'],
      endHour: json['endHour'],
      slotDurationMinutes: json['slotDurationMinutes'],
    );
  }

  @override
  List<Object?> get props => [startHour, endHour, slotDurationMinutes];
}

class ScheduleGenerationResult extends Equatable {
  final bool success;
  final String message;
  final GenerationData? data;

  const ScheduleGenerationResult({
    required this.success,
    required this.message,
    this.data,
  });

  factory ScheduleGenerationResult.fromJson(Map<String, dynamic> json) {
    return ScheduleGenerationResult(
      success: json['success'],
      message: json['message'],
      data: json['data'] != null ? GenerationData.fromJson(json['data']) : null,
    );
  }

  @override
  List<Object?> get props => [success, message, data];
}

class GenerationData extends Equatable {
  final int schedulesCreated;
  final int timeSlotsCreated;
  final int sessionsCreated;

  const GenerationData({
    required this.schedulesCreated,
    required this.timeSlotsCreated,
    required this.sessionsCreated,
  });

  factory GenerationData.fromJson(Map<String, dynamic> json) {
    return GenerationData(
      schedulesCreated: json['schedulesCreated'],
      timeSlotsCreated: json['timeSlotsCreated'],
      sessionsCreated: json['sessionsCreated'],
    );
  }

  @override
  List<Object?> get props => [
    schedulesCreated,
    timeSlotsCreated,
    sessionsCreated,
  ];
}

class ComponentGenerationResult extends Equatable {
  final bool success;
  final String message;
  final dynamic data;

  const ComponentGenerationResult({
    required this.success,
    required this.message,
    this.data,
  });

  factory ComponentGenerationResult.fromJson(Map<String, dynamic> json) {
    return ComponentGenerationResult(
      success: json['success'],
      message: json['message'],
      data: json['data'],
    );
  }

  @override
  List<Object?> get props => [success, message, data];
}
