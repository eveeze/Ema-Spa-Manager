// lib/data/models/service.dart
import 'package:equatable/equatable.dart';
import 'price_tier.dart';
import 'rating.dart';
import 'reservation.dart';
import 'service_category.dart';

class Service extends Equatable {
  final String id;
  final String name;
  final String description;
  final int duration;
  final String? imageUrl;
  final bool isActive;
  final String categoryId;
  final bool hasPriceTiers;
  final double? price;
  final int? minBabyAge;
  final int? maxBabyAge;
  final ServiceCategory? category;
  final List<PriceTier>? priceTiers;
  final DateTime createdAt;
  final DateTime updatedAt;
  final List<Reservation>? reservations;
  final List<Rating>? ratings;
  final double? averageRating;

  const Service({
    required this.id,
    required this.name,
    required this.description,
    required this.duration,
    this.imageUrl,
    required this.isActive,
    required this.categoryId,
    required this.hasPriceTiers,
    this.price,
    this.minBabyAge,
    this.maxBabyAge,
    this.category,
    this.priceTiers,
    required this.createdAt,
    required this.updatedAt,
    this.reservations,
    this.ratings,
    this.averageRating,
  });

  factory Service.fromJson(Map<String, dynamic> json) {
    return Service(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      duration: json['duration'],
      imageUrl: json['imageUrl'],
      isActive: json['isActive'] ?? true,
      categoryId: json['categoryId'],
      hasPriceTiers: json['hasPriceTiers'] ?? false,
      price: json['price']?.toDouble(),
      minBabyAge: json['minBabyAge'],
      maxBabyAge: json['maxBabyAge'],
      category:
          json['category'] != null
              ? ServiceCategory.fromJson(json['category'])
              : null,
      priceTiers:
          json['priceTiers'] != null
              ? (json['priceTiers'] as List)
                  .map((e) => PriceTier.fromJson(e))
                  .toList()
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
      averageRating: json['averageRating']?.toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {
      'id': id,
      'name': name,
      'description': description,
      'duration': duration,
      'isActive': isActive,
      'categoryId': categoryId,
      'hasPriceTiers': hasPriceTiers,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };

    if (imageUrl != null) data['imageUrl'] = imageUrl;
    if (price != null) data['price'] = price;
    if (minBabyAge != null) data['minBabyAge'] = minBabyAge;
    if (maxBabyAge != null) data['maxBabyAge'] = maxBabyAge;
    if (category != null) data['category'] = category!.toJson();
    if (priceTiers != null) {
      data['priceTiers'] = priceTiers!.map((e) => e.toJson()).toList();
    }
    if (reservations != null) {
      data['reservations'] = reservations!.map((e) => e.toJson()).toList();
    }
    if (ratings != null) {
      data['ratings'] = ratings!.map((e) => e.toJson()).toList();
    }
    if (averageRating != null) data['averageRating'] = averageRating;

    return data;
  }

  Service copyWith({
    String? id,
    String? name,
    String? description,
    int? duration,
    String? imageUrl,
    bool? isActive,
    String? categoryId,
    bool? hasPriceTiers,
    double? price,
    int? minBabyAge,
    int? maxBabyAge,
    ServiceCategory? category,
    List<PriceTier>? priceTiers,
    DateTime? createdAt,
    DateTime? updatedAt,
    List<Reservation>? reservations,
    List<Rating>? ratings,
    double? averageRating,
  }) {
    return Service(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      duration: duration ?? this.duration,
      imageUrl: imageUrl ?? this.imageUrl,
      isActive: isActive ?? this.isActive,
      categoryId: categoryId ?? this.categoryId,
      hasPriceTiers: hasPriceTiers ?? this.hasPriceTiers,
      price: price ?? this.price,
      minBabyAge: minBabyAge ?? this.minBabyAge,
      maxBabyAge: maxBabyAge ?? this.maxBabyAge,
      category: category ?? this.category,
      priceTiers: priceTiers ?? this.priceTiers,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      reservations: reservations ?? this.reservations,
      ratings: ratings ?? this.ratings,
      averageRating: averageRating ?? this.averageRating,
    );
  }

  @override
  List<Object?> get props => [
    id,
    name,
    description,
    duration,
    imageUrl,
    isActive,
    categoryId,
    hasPriceTiers,
    price,
    minBabyAge,
    maxBabyAge,
    category,
    priceTiers,
    createdAt,
    updatedAt,
    reservations,
    ratings,
    averageRating,
  ];
}
