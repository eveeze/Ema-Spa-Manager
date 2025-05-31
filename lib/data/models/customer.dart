// lib/data/models/customer.dart (Owner App)
import 'package:equatable/equatable.dart';
import 'reservation.dart';
import 'rating.dart';

class Customer extends Equatable {
  final String id;
  final String name;
  final String email;
  final String phoneNumber;
  final bool isVerified;
  final bool isManualCustomer; // Penting untuk owner mengetahui customer manual
  final String? address; // Berguna untuk owner mengetahui lokasi customer
  final String? instagramHandle; // Berguna untuk marketing/customer service
  final DateTime createdAt;
  final DateTime updatedAt;
  final List<Reservation>? reservations; // Untuk melihat riwayat booking
  final List<Rating>? ratings; // Untuk melihat feedback customer

  const Customer({
    required this.id,
    required this.name,
    required this.email,
    required this.phoneNumber,
    required this.isVerified,
    required this.isManualCustomer,
    this.address,
    this.instagramHandle,
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
      isManualCustomer: json['isManualCustomer'] ?? false,
      address: json['address'],
      instagramHandle: json['instagramHandle'],
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
      'isManualCustomer': isManualCustomer,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };

    if (address != null) data['address'] = address;
    if (instagramHandle != null) data['instagramHandle'] = instagramHandle;
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
    bool? isManualCustomer,
    String? address,
    String? instagramHandle,
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
      isManualCustomer: isManualCustomer ?? this.isManualCustomer,
      address: address ?? this.address,
      instagramHandle: instagramHandle ?? this.instagramHandle,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      reservations: reservations ?? this.reservations,
      ratings: ratings ?? this.ratings,
    );
  }

  // Helper methods khusus untuk owner app
  String get displayName => name;

  String get contactInfo {
    final parts = <String>[phoneNumber];
    if (instagramHandle != null) {
      parts.add('@$instagramHandle');
    }
    return parts.join(' • ');
  }

  bool get hasRecentActivity {
    if (reservations == null || reservations!.isEmpty) return false;
    final thirtyDaysAgo = DateTime.now().subtract(const Duration(days: 30));
    return reservations!.any((r) => r.createdAt.isAfter(thirtyDaysAgo));
  }

  int get totalReservations => reservations?.length ?? 0;

  double get averageRating {
    if (ratings == null || ratings!.isEmpty) return 0.0;
    final total = ratings!.fold<double>(
      0.0,
      (sum, rating) => sum + rating.rating,
    );
    return total / ratings!.length;
  }

  @override
  List<Object?> get props => [
    id,
    name,
    email,
    phoneNumber,
    isVerified,
    isManualCustomer,
    address,
    instagramHandle,
    createdAt,
    updatedAt,
    reservations,
    ratings,
  ];
}
