// lib/data/models/rating.dart
import 'package:equatable/equatable.dart';
import 'service.dart';
import 'customer.dart';

class Rating extends Equatable {
  final String id;
  final double rating;
  final String? comment;
  final String serviceId;
  final Service? service;
  final String customerId;
  final Customer? customer;
  final DateTime createdAt;

  const Rating({
    required this.id,
    required this.rating,
    this.comment,
    required this.serviceId,
    this.service,
    required this.customerId,
    this.customer,
    required this.createdAt,
  });

  factory Rating.fromJson(Map<String, dynamic> json) {
    return Rating(
      id: json['id'],
      rating: json['rating'].toDouble(),
      comment: json['comment'],
      serviceId: json['serviceId'],
      service:
          json['service'] != null ? Service.fromJson(json['service']) : null,
      customerId: json['customerId'],
      customer:
          json['customer'] != null ? Customer.fromJson(json['customer']) : null,
      createdAt: DateTime.parse(json['createdAt']),
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {
      'id': id,
      'rating': rating,
      'serviceId': serviceId,
      'customerId': customerId,
      'createdAt': createdAt.toIso8601String(),
    };

    if (comment != null) data['comment'] = comment;
    if (service != null) data['service'] = service!.toJson();
    if (customer != null) data['customer'] = customer!.toJson();

    return data;
  }

  Rating copyWith({
    String? id,
    double? rating,
    String? comment,
    String? serviceId,
    Service? service,
    String? customerId,
    Customer? customer,
    DateTime? createdAt,
  }) {
    return Rating(
      id: id ?? this.id,
      rating: rating ?? this.rating,
      comment: comment ?? this.comment,
      serviceId: serviceId ?? this.serviceId,
      service: service ?? this.service,
      customerId: customerId ?? this.customerId,
      customer: customer ?? this.customer,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  List<Object?> get props => [
    id,
    rating,
    comment,
    serviceId,
    service,
    customerId,
    customer,
    createdAt,
  ];
}
