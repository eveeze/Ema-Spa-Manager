// lib/data/models/payment.dart
import 'package:equatable/equatable.dart';

class Payment extends Equatable {
  final String id;
  final String? reservationId; // Made nullable since it's not always present
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
    this.reservationId, // Made optional since it's nullable
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
    return Payment(
      id: json['id'] as String,
      reservationId: json['reservationId'] as String?, // Safe null handling
      amount: (json['amount'] as num).toDouble(),
      paymentMethod: json['paymentMethod'] as String,
      paymentStatus: json['status'] as String,
      transactionId: json['transactionId'] as String?,
      tripayPaymentUrl: json['paymentUrl'] as String?,
      paymentProof: json['paymentProof'] as String?,
      paymentDate:
          json['paymentDate'] != null
              ? DateTime.parse(json['paymentDate'] as String)
              : null,
      merchantFee:
          json['merchantFee'] != null
              ? (json['merchantFee'] as num).toDouble()
              : null,
      expiryDate:
          json['expiryDate'] != null
              ? DateTime.parse(json['expiryDate'] as String)
              : null,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'reservationId': reservationId,
      'amount': amount,
      'paymentMethod': paymentMethod,
      'status': paymentStatus,
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
