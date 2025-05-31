// lib/data/repository/reservation_repository.dart
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:emababyspa/data/models/reservation.dart';
import 'package:emababyspa/data/models/payment.dart';
import 'package:emababyspa/data/providers/reservation_provider.dart';
import 'package:emababyspa/utils/logger_utils.dart';

class ReservationRepository {
  final ReservationProvider _reservationProvider;
  final LoggerUtils _logger;

  ReservationRepository({
    required ReservationProvider reservationProvider,
    required LoggerUtils logger,
  }) : _reservationProvider = reservationProvider,
       _logger = logger;

  // Get filtered reservations for owner
  Future<Map<String, dynamic>> getFilteredReservations({
    String? status,
    DateTime? startDate,
    DateTime? endDate,
    String? staffId,
    int page = 1,
    int limit = 10,
  }) async {
    try {
      return await _reservationProvider.getFilteredReservations(
        status: status,
        startDate: startDate,
        endDate: endDate,
        staffId: staffId,
        page: page,
        limit: limit,
      );
    } catch (e) {
      _logger.error('Repository error getting reservations: $e');
      rethrow;
    }
  }

  // Get reservation by ID
  Future<Reservation> getReservationById(String id) async {
    try {
      final response = await _reservationProvider.getReservationById(id);
      return Reservation.fromJson(response);
    } catch (e) {
      _logger.error('Repository error getting reservation: $e');
      rethrow;
    }
  }

  // Update reservation status
  Future<Reservation> updateReservationStatus(String id, String status) async {
    try {
      final response = await _reservationProvider.updateReservationStatus(
        id,
        status,
      );
      return Reservation.fromJson(response);
    } catch (e) {
      _logger.error('Repository error updating reservation status: $e');
      rethrow;
    }
  }

  // Create manual reservation
  Future<Map<String, dynamic>> createManualReservation({
    required String customerName,
    required String customerPhone,
    String? customerAddress,
    String? customerInstagram,
    required String babyName,
    required int babyAge,
    String? parentNames,
    required String serviceId,
    required String sessionId,
    String? priceTierId,
    String? notes,
    String paymentMethod = 'CASH',
    bool isPaid = false,
    String? paymentNotes,
    File? paymentProofFile,
  }) async {
    try {
      return await _reservationProvider.createManualReservation(
        customerName: customerName,
        customerPhone: customerPhone,
        customerAddress: customerAddress,
        customerInstagram: customerInstagram,
        babyName: babyName,
        babyAge: babyAge,
        parentNames: parentNames,
        serviceId: serviceId,
        sessionId: sessionId,
        priceTierId: priceTierId,
        notes: notes,
        paymentMethod: paymentMethod,
        isPaid: isPaid,
        paymentNotes: paymentNotes,
        paymentProofFile: paymentProofFile,
      );
    } on DioException catch (e) {
      if (e.response?.statusCode == 409) {
        _logger.error("Sesi sudah dipesan terlebih dahulu oleh yang lain");
      }
      _logger.error('Repository error creating manual reservation: $e');
      rethrow;
    }
  }

  // Upload payment proof for manual reservation
  Future<Payment> uploadManualPaymentProof(
    String reservationId,
    File paymentProofFile, {
    String? notes,
  }) async {
    try {
      final response = await _reservationProvider.uploadManualPaymentProof(
        reservationId,
        paymentProofFile,
        notes: notes,
      );
      return Payment.fromJson(response['payment']);
    } catch (e) {
      _logger.error('Repository error uploading payment proof: $e');
      rethrow;
    }
  }

  // Verify manual payment
  Future<Payment> verifyManualPayment(String paymentId, bool isVerified) async {
    try {
      final response = await _reservationProvider.verifyManualPayment(
        paymentId,
        isVerified,
      );
      return Payment.fromJson(response['payment']);
    } catch (e) {
      _logger.error('Repository error verifying payment: $e');
      rethrow;
    }
  }

  // Get reservation analytics
  Future<Map<String, dynamic>> getReservationAnalytics(
    DateTime startDate,
    DateTime endDate,
  ) async {
    try {
      return await _reservationProvider.getReservationAnalytics(
        startDate,
        endDate,
      );
    } catch (e) {
      _logger.error('Repository error getting analytics: $e');
      rethrow;
    }
  }
}
