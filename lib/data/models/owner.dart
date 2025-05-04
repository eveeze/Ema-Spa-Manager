// lib/data/models/owner.dart
import 'package:equatable/equatable.dart';

class Owner extends Equatable {
  final String id;
  final String name;
  final String email;
  final String phoneNumber;

  const Owner({
    required this.id,
    required this.name,
    required this.email,
    required this.phoneNumber,
  });

  factory Owner.fromJson(Map<String, dynamic> json) {
    return Owner(
      id: json['id'],
      name: json['name'],
      email: json['email'],
      phoneNumber: json['phoneNumber'],
    );
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'name': name, 'email': email, 'phoneNumber': phoneNumber};
  }

  Owner copyWith({
    String? id,
    String? name,
    String? email,
    String? phoneNumber,
  }) {
    return Owner(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      phoneNumber: phoneNumber ?? this.phoneNumber,
    );
  }

  @override
  List<Object?> get props => [id, name, email, phoneNumber];
}
