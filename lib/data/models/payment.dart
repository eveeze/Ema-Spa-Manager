// lib/data/models/payment.dart
import 'package:equatable/equatable.dart';

class Payment extends Equatable {
  final String id;
  final String? reservationId;
  final double amount;
  final String paymentMethod;
  final String paymentStatus;
  final String? transactionId;
  final String? tripayPaymentUrl;
  final String? paymentProof;
  final DateTime? paymentDate;
  final double? merchantFee;
  final DateTime? expiryDate;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Payment({
    required this.id,
    this.reservationId,
    required this.amount,
    required this.paymentMethod,
    required this.paymentStatus,
    this.transactionId,
    this.tripayPaymentUrl,
    this.paymentProof,
    this.paymentDate,
    this.merchantFee,
    this.expiryDate,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Payment.fromJson(Map<String, dynamic> json) {
    // Helper untuk memastikan nilai string tidak null
    String asString(dynamic value, [String fallback = '']) =>
        value as String? ?? fallback;

    // Helper untuk memastikan nilai angka tidak null
    double asDouble(dynamic value, [double fallback = 0.0]) =>
        (value as num?)?.toDouble() ?? fallback;

    return Payment(
      id: asString(json['id']),
      reservationId: asString(json['reservationId']),
      amount: asDouble(json['amount']),
      paymentMethod: asString(json['paymentMethod']),

      // === PERBAIKAN UTAMA DI SINI ===
      // Baca 'paymentStatus' atau 'status' sebagai fallback
      paymentStatus: asString(
        json['paymentStatus'] ?? json['status'],
        'PENDING',
      ),

      transactionId: asString(json['transactionId']),
      tripayPaymentUrl: asString(json['paymentUrl']),
      paymentProof: asString(json['paymentProof']),
      paymentDate:
          json['paymentDate'] != null
              ? DateTime.tryParse(asString(json['paymentDate']))
              : null,
      merchantFee:
          json['merchantFee'] != null ? asDouble(json['merchantFee']) : null,
      expiryDate:
          json['expiryDate'] != null
              ? DateTime.tryParse(asString(json['expiryDate']))
              : null,
      createdAt:
          json['createdAt'] != null
              ? DateTime.parse(asString(json['createdAt']))
              : DateTime.now(),
      updatedAt:
          json['updatedAt'] != null
              ? DateTime.parse(asString(json['updatedAt']))
              : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'reservationId': reservationId,
      'amount': amount,
      'paymentMethod': paymentMethod,
      'paymentStatus': paymentStatus, // Kirim sebagai 'paymentStatus'
      'transactionId': transactionId,
      'paymentUrl': tripayPaymentUrl,
      'paymentProof': paymentProof,
      'paymentDate': paymentDate?.toIso8601String(),
      'merchantFee': merchantFee,
      'expiryDate': expiryDate?.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  @override
  List<Object?> get props => [
    id,
    reservationId,
    amount,
    paymentMethod,
    paymentStatus,
    transactionId,
    tripayPaymentUrl,
    paymentProof,
    paymentDate,
    merchantFee,
    expiryDate,
    createdAt,
    updatedAt,
  ];
}
