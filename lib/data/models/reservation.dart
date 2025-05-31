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
}

enum ReservationType { ONLINE, MANUAL }

class Reservation extends Equatable {
  final String id;
  final ReservationType reservationType;
  final String customerId;
  final String serviceId;
  final String staffId;
  final String sessionId;
  final String? notes;
  final String? parentNames; // NEW: Parent names for manual reservations
  final String babyName;
  final int babyAge;
  final String? priceTierId;
  final double totalPrice;
  final ReservationStatus status;
  final bool createdByOwner;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Reservation({
    required this.id,
    required this.reservationType,
    required this.customerId,
    required this.serviceId,
    required this.staffId,
    required this.sessionId,
    this.notes,
    this.parentNames, // NEW: Optional parent names
    required this.babyName,
    required this.babyAge,
    this.priceTierId,
    required this.totalPrice,
    required this.status,
    required this.createdByOwner,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Reservation.fromJson(Map<String, dynamic> json) {
    return Reservation(
      id: json['id'] ?? '',
      reservationType: ReservationType.values.firstWhere(
        (e) => e.toString() == 'ReservationType.${json['reservationType']}',
        orElse: () => ReservationType.ONLINE,
      ),
      customerId: json['customerId'] ?? '',
      serviceId: json['serviceId'] ?? '',
      staffId: json['staffId'] ?? '',
      sessionId: json['sessionId'] ?? '',
      notes: json['notes'],
      parentNames: json['parentNames'], // NEW: Parse parent names
      babyName: json['babyName'] ?? '',
      babyAge: json['babyAge'] ?? 0,
      priceTierId: json['priceTierId'],
      totalPrice: (json['totalPrice'] ?? 0.0).toDouble(),
      status: ReservationStatus.values.firstWhere(
        (e) => e.toString() == 'ReservationStatus.${json['status']}',
        orElse: () => ReservationStatus.PENDING,
      ),
      createdByOwner: json['createdByOwner'] ?? false,
      createdAt:
          json['createdAt'] != null
              ? DateTime.parse(json['createdAt'])
              : DateTime.now(),
      updatedAt:
          json['updatedAt'] != null
              ? DateTime.parse(json['updatedAt'])
              : DateTime.now(),
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
      'parentNames': parentNames, // NEW: Include parent names in JSON
      'babyName': babyName,
      'babyAge': babyAge,
      'priceTierId': priceTierId,
      'totalPrice': totalPrice,
      'status': status.toString().split('.').last,
      'createdByOwner': createdByOwner,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
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
    String? parentNames, // NEW: Include in copyWith
    String? babyName,
    int? babyAge,
    String? priceTierId,
    double? totalPrice,
    ReservationStatus? status,
    bool? createdByOwner,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Reservation(
      id: id ?? this.id,
      reservationType: reservationType ?? this.reservationType,
      customerId: customerId ?? this.customerId,
      serviceId: serviceId ?? this.serviceId,
      staffId: staffId ?? this.staffId,
      sessionId: sessionId ?? this.sessionId,
      notes: notes ?? this.notes,
      parentNames:
          parentNames ??
          this.parentNames, // NEW: Use provided value or existing
      babyName: babyName ?? this.babyName,
      babyAge: babyAge ?? this.babyAge,
      priceTierId: priceTierId ?? this.priceTierId,
      totalPrice: totalPrice ?? this.totalPrice,
      status: status ?? this.status,
      createdByOwner: createdByOwner ?? this.createdByOwner,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
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
    parentNames, // NEW: Include in props for equality comparison
    babyName,
    babyAge,
    priceTierId,
    totalPrice,
    status,
    createdByOwner,
    createdAt,
    updatedAt,
  ];

  @override
  String toString() {
    return 'Reservation{id: $id, reservationType: $reservationType, '
        'customerId: $customerId, serviceId: $serviceId, '
        'staffId: $staffId, sessionId: $sessionId, '
        'babyName: $babyName, babyAge: $babyAge, '
        'status: $status, totalPrice: $totalPrice}';
  }
}
