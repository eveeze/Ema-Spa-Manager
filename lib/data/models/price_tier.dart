// lib/data/models/price_tier.dart
import 'package:equatable/equatable.dart';
import 'service.dart';

class PriceTier extends Equatable {
  final String id;
  final String serviceId;
  final Service? service;
  final String tierName;
  final int minBabyAge;
  final int maxBabyAge;
  final double price;
  final DateTime createdAt;
  final DateTime updatedAt;

  const PriceTier({
    required this.id,
    required this.serviceId,
    this.service,
    required this.tierName,
    required this.minBabyAge,
    required this.maxBabyAge,
    required this.price,
    required this.createdAt,
    required this.updatedAt,
  });

  factory PriceTier.fromJson(Map<String, dynamic> json) {
    return PriceTier(
      id: json['id'],
      serviceId: json['serviceId'],
      service:
          json['service'] != null ? Service.fromJson(json['service']) : null,
      tierName: json['tierName'],
      minBabyAge: json['minBabyAge'],
      maxBabyAge: json['maxBabyAge'],
      price: json['price'].toDouble(),
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {
      'id': id,
      'serviceId': serviceId,
      'tierName': tierName,
      'minBabyAge': minBabyAge,
      'maxBabyAge': maxBabyAge,
      'price': price,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };

    if (service != null) data['service'] = service!.toJson();

    return data;
  }

  PriceTier copyWith({
    String? id,
    String? serviceId,
    Service? service,
    String? tierName,
    int? minBabyAge,
    int? maxBabyAge,
    double? price,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return PriceTier(
      id: id ?? this.id,
      serviceId: serviceId ?? this.serviceId,
      service: service ?? this.service,
      tierName: tierName ?? this.tierName,
      minBabyAge: minBabyAge ?? this.minBabyAge,
      maxBabyAge: maxBabyAge ?? this.maxBabyAge,
      price: price ?? this.price,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
    id,
    serviceId,
    service,
    tierName,
    minBabyAge,
    maxBabyAge,
    price,
    createdAt,
    updatedAt,
  ];
}
