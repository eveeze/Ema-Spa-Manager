// lib/data/models/staff.dart
import 'package:equatable/equatable.dart';
import 'session.dart';
import 'reservation.dart';

class Staff extends Equatable {
  final String id;
  final String name;
  final String email;
  final String phoneNumber;
  final String? address;
  final String? profilePicture;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;
  final List<Session>? sessions;
  final List<Reservation>? reservations;

  const Staff({
    required this.id,
    required this.name,
    required this.email,
    required this.phoneNumber,
    this.address,
    this.profilePicture,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
    this.sessions,
    this.reservations,
  });

  factory Staff.fromJson(Map<String, dynamic> json) {
    return Staff(
      id: json['id'],
      name: json['name'],
      email: json['email'],
      phoneNumber: json['phoneNumber'],
      address: json['address'],
      profilePicture: json['profilePicture'],
      isActive: json['isActive'] ?? true,
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
      sessions:
          json['sessions'] != null
              ? (json['sessions'] as List)
                  .map((e) => Session.fromJson(e))
                  .toList()
              : null,
      reservations:
          json['reservations'] != null
              ? (json['reservations'] as List)
                  .map((e) => Reservation.fromJson(e))
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
      'isActive': isActive,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };

    if (address != null) data['address'] = address;
    if (profilePicture != null) data['profilePicture'] = profilePicture;
    if (sessions != null) {
      data['sessions'] = sessions!.map((e) => e.toJson()).toList();
    }
    if (reservations != null) {
      data['reservations'] = reservations!.map((e) => e.toJson()).toList();
    }

    return data;
  }

  Staff copyWith({
    String? id,
    String? name,
    String? email,
    String? phoneNumber,
    String? address,
    String? profilePicture,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
    List<Session>? sessions,
    List<Reservation>? reservations,
  }) {
    return Staff(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      address: address ?? this.address,
      profilePicture: profilePicture ?? this.profilePicture,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      sessions: sessions ?? this.sessions,
      reservations: reservations ?? this.reservations,
    );
  }

  @override
  List<Object?> get props => [
    id,
    name,
    email,
    phoneNumber,
    address,
    profilePicture,
    isActive,
    createdAt,
    updatedAt,
    sessions,
    reservations,
  ];
}
