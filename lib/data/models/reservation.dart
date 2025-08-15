// lib/data/models/reservation.dart

// ===== LANGKAH 1: Import TimeZoneUtil =====
import 'package:emababyspa/utils/timezone_utils.dart'; // Pastikan path ini benar
// ===========================================

import 'package:emababyspa/data/models/payment.dart';
import 'package:equatable/equatable.dart';

enum ReservationStatus {
  PENDING,
  CONFIRMED,
  IN_PROGRESS,
  COMPLETED,
  CANCELLED,
  EXPIRED,
  PENDING_PAYMENT,
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
  final String? parentNames;
  final String babyName;
  final int babyAge;
  final String? priceTierId;
  final double totalPrice;
  final ReservationStatus status;
  final bool createdByOwner;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? customerName;
  final String? serviceName;
  final String? staffName;
  final DateTime? sessionDate;
  final String? sessionTime;
  final Payment? payment;

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
    this.customerName,
    this.serviceName,
    this.staffName,
    this.sessionDate,
    this.sessionTime,
    this.payment,
  });

  factory Reservation.fromJson(Map<String, dynamic> json) {
    ReservationStatus parseStatus(String? statusStr) {
      if (statusStr == null) return ReservationStatus.PENDING;
      try {
        return ReservationStatus.values.firstWhere(
          (e) => e.name.toUpperCase() == statusStr.toUpperCase(),
        );
      } catch (e) {
        return ReservationStatus.PENDING;
      }
    }

    final customerData = json['customer'];
    final serviceData = json['service'];
    final staffData = json['staff'];
    final sessionData = json['session'];
    final timeSlotData = sessionData?['timeSlot'];
    final operatingScheduleData = timeSlotData?['operatingSchedule'];

    String? extractedSessionTime;
    if (timeSlotData?['startTime'] != null &&
        timeSlotData?['endTime'] != null) {
      // ===== LANGKAH 2: GUNAKAN TimeZoneUtil UNTUK KONVERSI WAKTU =====
      try {
        // Parse string menjadi objek DateTime dalam UTC
        final startTimeUTC = DateTime.parse(timeSlotData['startTime']);
        final endTimeUTC = DateTime.parse(timeSlotData['endTime']);

        // Konversi dari UTC ke Waktu Indonesia (WIB / UTC+7)
        final startTimeWIB = TimeZoneUtil.toIndonesiaTime(startTimeUTC);
        final endTimeWIB = TimeZoneUtil.toIndonesiaTime(endTimeUTC);

        // Format string waktu menggunakan objek DateTime yang sudah dikonversi ke WIB
        final sh = startTimeWIB.hour.toString().padLeft(2, '0');
        final sm = startTimeWIB.minute.toString().padLeft(2, '0');
        final eh = endTimeWIB.hour.toString().padLeft(2, '0');
        final em = endTimeWIB.minute.toString().padLeft(2, '0');
        extractedSessionTime = '$sh:$sm - $eh:$em';
      } catch (e) {
        // Jika terjadi error, biarkan kosong agar tidak crash
        /* ignore */
      }
      // =================================================================
    }

    DateTime? parsedSessionDate;
    if (operatingScheduleData?['date'] != null) {
      parsedSessionDate = DateTime.tryParse(operatingScheduleData['date']);
    }

    return Reservation(
      id: json['id'] ?? '',
      reservationType: ReservationType.values.firstWhere(
        (e) => e.name.toUpperCase() == json['reservationType']?.toUpperCase(),
        orElse: () => ReservationType.ONLINE,
      ),
      customerId: json['customerId'] ?? (customerData?['id'] ?? ''),
      serviceId: json['serviceId'] ?? (serviceData?['id'] ?? ''),
      staffId: json['staffId'] ?? (staffData?['id'] ?? ''),
      sessionId: json['sessionId'] ?? (sessionData?['id'] ?? ''),
      notes: json['notes'],
      parentNames: json['parentNames'],
      babyName: json['babyName'] ?? '',
      babyAge: (json['babyAge'] as num?)?.toInt() ?? 0,
      priceTierId: json['priceTierId'],
      totalPrice: (json['totalPrice'] as num?)?.toDouble() ?? 0.0,
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
      customerName: json['customerName'] ?? customerData?['name'],
      serviceName: json['serviceName'] ?? serviceData?['name'],
      staffName: json['staffName'] ?? staffData?['name'],
      sessionDate: parsedSessionDate,
      sessionTime:
          json['sessionTime'] ??
          extractedSessionTime, // Tetap gunakan hasil ekstraksi
      payment:
          json['payment'] != null && json['payment'] is Map<String, dynamic>
              ? Payment.fromJson(json['payment'])
              : null,
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
    customerName,
    serviceName,
    staffName,
    sessionDate,
    sessionTime,
    payment,
  ];

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
      'customerName': customerName,
      'serviceName': serviceName,
      'staffName': staffName,
      'sessionDate': sessionDate?.toIso8601String(),
      'sessionTime': sessionTime,
      'payment': payment?.toJson(),
    };
  }
}
