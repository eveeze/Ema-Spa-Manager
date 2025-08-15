// lib/data/models/notification.dart
import 'package:equatable/equatable.dart';

class Notification extends Equatable {
  final String id;
  final String recipientType; // <-- TAMBAHAN
  final String title;
  final String message;
  final bool isRead;
  final String type; // <-- TAMBAHAN
  final DateTime createdAt;
  final String? referenceId;

  const Notification({
    required this.id,
    required this.recipientType, // <-- TAMBAHAN
    required this.title,
    required this.message,
    required this.isRead,
    required this.type, // <-- TAMBAHAN
    required this.createdAt,
    this.referenceId,
  });

  factory Notification.fromJson(Map<String, dynamic> json) {
    return Notification(
      id: json['id'],
      recipientType: json['recipientType'], // <-- TAMBAHAN
      title: json['title'],
      message: json['message'],
      isRead: json['isRead'] ?? false,
      type: json['type'], // <-- TAMBAHAN
      createdAt: DateTime.parse(json['createdAt']),
      referenceId: json['referenceId'],
    );
  }

  @override
  List<Object?> get props => [
    id,
    recipientType, // <-- TAMBAHAN
    title,
    message,
    isRead,
    type, // <-- TAMBAHAN
    createdAt,
    referenceId,
  ];
}
