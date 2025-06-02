// lib/data/models/customer.dart
import 'package:equatable/equatable.dart';
import 'reservation.dart';
import 'rating.dart';

class Customer extends Equatable {
  final String id;
  final String name;
  final String email;
  final String phoneNumber;
  final bool isVerified;
  final bool isResetPasswordVerified;
  final String? verificationOtp;
  final DateTime? verificationOtpCreatedAt;
  final String? resetPasswordOtp;
  final DateTime? resetOtpCreatedAt;
  final DateTime createdAt;
  final DateTime updatedAt;
  final List<Reservation>? reservations;
  final List<Rating>? ratings;

  const Customer({
    required this.id,
    required this.name,
    required this.email,
    required this.phoneNumber,
    required this.isVerified,
    required this.isResetPasswordVerified,
    this.verificationOtp,
    this.verificationOtpCreatedAt,
    this.resetPasswordOtp,
    this.resetOtpCreatedAt,
    required this.createdAt,
    required this.updatedAt,
    this.reservations,
    this.ratings,
  });

  factory Customer.fromJson(Map<String, dynamic> json) {
    return Customer(
      id: json['id'],
      name: json['name'],
      email: json['email'],
      phoneNumber: json['phoneNumber'],
      isVerified: json['isVerified'] ?? false,
      isResetPasswordVerified: json['isResetPasswordVerified'] ?? false,
      verificationOtp: json['verificationOtp'],
      verificationOtpCreatedAt:
          json['verificationOtpCreatedAt'] != null
              ? DateTime.parse(json['verificationOtpCreatedAt'])
              : null,
      resetPasswordOtp: json['resetPasswordOtp'],
      resetOtpCreatedAt:
          json['resetOtpCreatedAt'] != null
              ? DateTime.parse(json['resetOtpCreatedAt'])
              : null,
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
      reservations:
          json['reservations'] != null
              ? (json['reservations'] as List)
                  .map((e) => Reservation.fromJson(e))
                  .toList()
              : null,
      ratings:
          json['ratings'] != null
              ? (json['ratings'] as List)
                  .map((e) => Rating.fromJson(e))
                  .toList()
              : null,
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {
      'id': id,
      'name': name,
      'email': email,
      'phoneNumber': phoneNumber,
      'isVerified': isVerified,
      'isResetPasswordVerified': isResetPasswordVerified,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };

    if (verificationOtp != null) data['verificationOtp'] = verificationOtp;
    if (verificationOtpCreatedAt != null) {
      data['verificationOtpCreatedAt'] =
          verificationOtpCreatedAt!.toIso8601String();
    }
    if (resetPasswordOtp != null) data['resetPasswordOtp'] = resetPasswordOtp;
    if (resetOtpCreatedAt != null) {
      data['resetOtpCreatedAt'] = resetOtpCreatedAt!.toIso8601String();
    }
    if (reservations != null) {
      data['reservations'] = reservations!.map((e) => e.toJson()).toList();
    }
    if (ratings != null) {
      data['ratings'] = ratings!.map((e) => e.toJson()).toList();
    }

    return data;
  }

  Customer copyWith({
    String? id,
    String? name,
    String? email,
    String? phoneNumber,
    bool? isVerified,
    bool? isResetPasswordVerified,
    String? verificationOtp,
    DateTime? verificationOtpCreatedAt,
    String? resetPasswordOtp,
    DateTime? resetOtpCreatedAt,
    DateTime? createdAt,
    DateTime? updatedAt,
    List<Reservation>? reservations,
    List<Rating>? ratings,
  }) {
    return Customer(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      isVerified: isVerified ?? this.isVerified,
      isResetPasswordVerified:
          isResetPasswordVerified ?? this.isResetPasswordVerified,
      verificationOtp: verificationOtp ?? this.verificationOtp,
      verificationOtpCreatedAt:
          verificationOtpCreatedAt ?? this.verificationOtpCreatedAt,
      resetPasswordOtp: resetPasswordOtp ?? this.resetPasswordOtp,
      resetOtpCreatedAt: resetOtpCreatedAt ?? this.resetOtpCreatedAt,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      reservations: reservations ?? this.reservations,
      ratings: ratings ?? this.ratings,
    );
  }

  @override
  List<Object?> get props => [
    id,
    name,
    email,
    phoneNumber,
    isVerified,
    isResetPasswordVerified,
    verificationOtp,
    verificationOtpCreatedAt,
    resetPasswordOtp,
    resetOtpCreatedAt,
    createdAt,
    updatedAt,
    reservations,
    ratings,
  ];
}
