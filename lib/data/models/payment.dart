// lib/data/models/payment.dart
import 'package:equatable/equatable.dart';

class Payment extends Equatable {
  final String id;
  final String reservationId;
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
    required this.reservationId,
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
      id: json['id'],
      reservationId: json['reservationId'],
      amount: json['amount'].toDouble(),
      paymentMethod: json['paymentMethod'],
      paymentStatus: json['paymentStatus'],
      transactionId: json['transactionId'],
      tripayPaymentUrl: json['tripayPaymentUrl'],
      paymentProof: json['paymentProof'],
      paymentDate:
          json['paymentDate'] != null
              ? DateTime.parse(json['paymentDate'])
              : null,
      merchantFee: json['merchantFee']?.toDouble(),

      expiryDate:
          json['expiryDate'] != null
              ? DateTime.parse(json['expiryDate'])
              : null,
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
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
