// lib/data/models/payment_method.dart
import 'package:equatable/equatable.dart';

class PaymentMethodFee extends Equatable {
  final num flat;
  final num percent;

  const PaymentMethodFee({required this.flat, required this.percent});

  factory PaymentMethodFee.fromJson(Map<String, dynamic> json) {
    return PaymentMethodFee(
      flat: json['flat'] ?? 0,
      percent: json['percent'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {'flat': flat, 'percent': percent};
  }

  @override
  List<Object?> get props => [flat, percent];
}

class PaymentMethodModel extends Equatable {
  final String code;
  final String name;
  final String type;
  final PaymentMethodFee fee;
  final String iconUrl;
  final num minimumAmount;
  final num? maximumAmount;

  const PaymentMethodModel({
    required this.code,
    required this.name,
    required this.type,
    required this.fee,
    required this.iconUrl,
    required this.minimumAmount,
    this.maximumAmount,
  });

  factory PaymentMethodModel.fromJson(Map<String, dynamic> json) {
    return PaymentMethodModel(
      code: json['code'] ?? '',
      name: json['name'] ?? '',
      type: json['type'] ?? '',
      fee: PaymentMethodFee.fromJson(
        json['fee'] as Map<String, dynamic>? ?? {},
      ),
      iconUrl: json['iconUrl'] ?? '',
      minimumAmount: json['minimumAmount'] ?? 0,
      maximumAmount: json['maximumAmount'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'code': code,
      'name': name,
      'type': type,
      'fee': fee.toJson(),
      'iconUrl': iconUrl,
      'minimumAmount': minimumAmount,
      'maximumAmount': maximumAmount,
    };
  }

  @override
  List<Object?> get props => [
    code,
    name,
    type,
    fee,
    iconUrl,
    minimumAmount,
    maximumAmount,
  ];
}
