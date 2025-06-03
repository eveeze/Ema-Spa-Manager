// lib/data/models/reservation.dart
// ignore_for_file: constant_identifier_names

import 'package:equatable/equatable.dart';

enum ReservationStatus {
  PENDING,
  CONFIRMED,
  IN_PROGRESS,
  COMPLETED,
  CANCELLED,
  EXPIRED,
  PENDING_PAYMENT, // Added based on backend response in createNewReservation
}

enum ReservationType { ONLINE, MANUAL }

class Reservation extends Equatable {
  final String id;
  final ReservationType reservationType;
  final String customerId;
  // final Customer? customer; // Consider adding full Customer object if needed
  final String serviceId;
  // final Service? service; // Consider adding full Service object if needed
  final String staffId;
  // final Staff? staff; // Consider adding full Staff object if needed
  final String sessionId;
  // final Session? session; // Consider adding full Session object with its nested details
  final String? notes;
  final String? parentNames;
  final String babyName;
  final int babyAge;
  final String? priceTierId;
  final double totalPrice;
  final ReservationStatus status;
  final bool createdByOwner;
  final DateTime createdAt;
  final DateTime updatedAt;

  // NEW: Added based on the structure your backend might return for upcoming reservations
  final String? customerName;
  final String? serviceName;
  final String? staffName;
  final DateTime? sessionDate; // Stores the date part of the session
  final String?
  sessionTime; // Stores the time part (can be pre-formatted or ISO for later parsing)

  const Reservation({
    required this.id,
    required this.reservationType,
    required this.customerId,
    required this.serviceId,
    required this.staffId,
    required this.sessionId,
    this.notes,
    this.parentNames,
    required this.babyName,
    required this.babyAge,
    this.priceTierId,
    required this.totalPrice,
    required this.status,
    required this.createdByOwner,
    required this.createdAt,
    required this.updatedAt,
    // NEW
    this.customerName,
    this.serviceName,
    this.staffName,
    this.sessionDate,
    this.sessionTime,
  });

  factory Reservation.fromJson(Map<String, dynamic> json) {
    // Helper to parse status robustly
    ReservationStatus parseStatus(String? statusStr) {
      if (statusStr == null) return ReservationStatus.PENDING;
      try {
        return ReservationStatus.values.firstWhere(
          (e) => e.toString() == 'ReservationStatus.$statusStr',
        );
      } catch (e) {
        // Fallback for potentially different casing or unknown status
        if (statusStr.toUpperCase() == 'PENDING_PAYMENT') {
          return ReservationStatus.PENDING_PAYMENT;
        }
        return ReservationStatus.PENDING; // Default fallback
      }
    }

    // Extract nested data if present (common in detailed views)
    final customerData = json['customer'];
    final serviceData = json['service'];
    final staffData = json['staff'];
    final sessionData = json['session'];
    final timeSlotData = sessionData?['timeSlot'];
    final operatingScheduleData = timeSlotData?['operatingSchedule'];

    String?
    extractedSessionTime; // For cases where API might send separate startTime and endTime at root
    // This specific 'extractedSessionTime' is from root keys, not the nested ones.
    // The nested startTime/endTime are handled later in the sessionTime assignment.
    if (json['startTime'] != null && json['endTime'] != null) {
      // Check root level startTime/endTime
      try {
        final startTime = DateTime.parse(json['startTime']);
        final endTime = DateTime.parse(json['endTime']);
        final sh = startTime.hour.toString().padLeft(2, '0');
        final sm = startTime.minute.toString().padLeft(2, '0');
        final eh = endTime.hour.toString().padLeft(2, '0');
        final em = endTime.minute.toString().padLeft(2, '0');
        extractedSessionTime = '$sh:$sm - $eh:$em';
      } catch (e) {
        // ignore: avoid_print
        print(
          'Error parsing root startTime/endTime for extractedSessionTime: $e',
        );
      }
    }

    DateTime? parsedSessionDate;
    if (operatingScheduleData?['date'] != null) {
      parsedSessionDate = DateTime.tryParse(operatingScheduleData['date']);
    } else if (timeSlotData?['startTime'] != null) {
      // Fallback: try to get date from timeSlot's startTime if operatingSchedule date is missing
      parsedSessionDate = DateTime.tryParse(timeSlotData['startTime']);
    }

    return Reservation(
      id: json['id'] ?? '',
      reservationType: ReservationType.values.firstWhere(
        (e) => e.toString() == 'ReservationType.${json['reservationType']}',
        orElse: () => ReservationType.ONLINE,
      ),
      customerId: json['customerId'] ?? (customerData?['id'] ?? ''),
      serviceId: json['serviceId'] ?? (serviceData?['id'] ?? ''),
      staffId: json['staffId'] ?? (staffData?['id'] ?? ''),
      sessionId: json['sessionId'] ?? (sessionData?['id'] ?? ''),
      notes: json['notes'],
      parentNames: json['parentNames'],
      babyName: json['babyName'] ?? '',
      babyAge:
          (json['babyAge'] is String)
              ? (int.tryParse(json['babyAge']) ?? 0)
              : (json['babyAge'] ?? 0),
      priceTierId: json['priceTierId'],
      totalPrice: (json['totalPrice'] ?? 0.0).toDouble(),
      status: parseStatus(json['status']),
      createdByOwner: json['createdByOwner'] ?? false,
      createdAt:
          json['createdAt'] != null
              ? DateTime.parse(json['createdAt'])
              : DateTime.now(),
      updatedAt:
          json['updatedAt'] != null
              ? DateTime.parse(json['updatedAt'])
              : DateTime.now(),
      // Populate from potentially nested data or direct fields
      customerName: json['customerName'] ?? customerData?['name'],
      serviceName: json['serviceName'] ?? serviceData?['name'],
      staffName: json['staffName'] ?? staffData?['name'],
      sessionDate: parsedSessionDate, // Use the parsed date
      // Order of preference for sessionTime:
      // 1. Direct 'sessionTime' from JSON (could be pre-formatted by API for lists).
      // 2. 'extractedSessionTime' (if API provides 'startTime' and 'endTime' at root).
      // 3. Raw 'startTime' from nested 'timeSlot' (this will be an ISO string for later formatting).
      sessionTime:
          json['sessionTime'] ??
          extractedSessionTime ??
          timeSlotData?['startTime'], // Correctly uses timeSlotData from above
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'reservationType': reservationType.toString().split('.').last,
      'customerId': customerId,
      'serviceId': serviceId,
      'staffId': staffId,
      'sessionId': sessionId,
      'notes': notes,
      'parentNames': parentNames,
      'babyName': babyName,
      'babyAge': babyAge,
      'priceTierId': priceTierId,
      'totalPrice': totalPrice,
      'status': status.toString().split('.').last,
      'createdByOwner': createdByOwner,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      // NEW - only include if you intend to send these back, otherwise remove
      'customerName': customerName,
      'serviceName': serviceName,
      'staffName': staffName,
      'sessionDate': sessionDate?.toIso8601String(),
      'sessionTime': sessionTime,
    };
  }

  Reservation copyWith({
    String? id,
    ReservationType? reservationType,
    String? customerId,
    String? serviceId,
    String? staffId,
    String? sessionId,
    String? notes,
    String? parentNames,
    String? babyName,
    int? babyAge,
    String? priceTierId,
    double? totalPrice,
    ReservationStatus? status,
    bool? createdByOwner,
    DateTime? createdAt,
    DateTime? updatedAt,
    // NEW
    String? customerName,
    String? serviceName,
    String? staffName,
    DateTime? sessionDate,
    String? sessionTime,
  }) {
    return Reservation(
      id: id ?? this.id,
      reservationType: reservationType ?? this.reservationType,
      customerId: customerId ?? this.customerId,
      serviceId: serviceId ?? this.serviceId,
      staffId: staffId ?? this.staffId,
      sessionId: sessionId ?? this.sessionId,
      notes: notes ?? this.notes,
      parentNames: parentNames ?? this.parentNames,
      babyName: babyName ?? this.babyName,
      babyAge: babyAge ?? this.babyAge,
      priceTierId: priceTierId ?? this.priceTierId,
      totalPrice: totalPrice ?? this.totalPrice,
      status: status ?? this.status,
      createdByOwner: createdByOwner ?? this.createdByOwner,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      // NEW
      customerName: customerName ?? this.customerName,
      serviceName: serviceName ?? this.serviceName,
      staffName: staffName ?? this.staffName,
      sessionDate: sessionDate ?? this.sessionDate,
      sessionTime: sessionTime ?? this.sessionTime,
    );
  }

  @override
  List<Object?> get props => [
    id,
    reservationType,
    customerId,
    serviceId,
    staffId,
    sessionId,
    notes,
    parentNames,
    babyName,
    babyAge,
    priceTierId,
    totalPrice,
    status,
    createdByOwner,
    createdAt,
    updatedAt,
    // NEW
    customerName,
    serviceName,
    staffName,
    sessionDate,
    sessionTime,
  ];

  @override
  String toString() {
    return 'Reservation{id: $id, reservationType: $reservationType, '
        'customerId: $customerId, serviceId: $serviceId, '
        'staffId: $staffId, sessionId: $sessionId, '
        'babyName: $babyName, babyAge: $babyAge, '
        'status: $status, totalPrice: $totalPrice, '
        'customerName: $customerName, serviceName: $serviceName, staffName: $staffName, sessionDate: $sessionDate, sessionTime: $sessionTime}';
  }
}
