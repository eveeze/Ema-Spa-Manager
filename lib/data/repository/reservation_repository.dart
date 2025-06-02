// lib/data/repository/reservation_repository.dart
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:emababyspa/data/models/reservation.dart';
import 'package:emababyspa/data/models/payment.dart'; // Ensure Payment model is defined
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
  // Returns a map with 'data' (List<Reservation>) and 'pagination' (Map<String, dynamic>)
  Future<Map<String, dynamic>> getFilteredReservations({
    String? status,
    DateTime? startDate,
    DateTime? endDate,
    String? staffId,
    int page = 1,
    int limit = 10,
  }) async {
    try {
      _logger.info('Repository: Getting filtered reservations.');
      final response = await _reservationProvider.getFilteredReservations(
        status: status,
        startDate: startDate,
        endDate: endDate,
        staffId: staffId,
        page: page,
        limit: limit,
      );
      // Assuming response['data'] is a List<dynamic> of reservation maps
      List<Reservation> reservations =
          (response['data'] as List)
              .map((item) => Reservation.fromJson(item as Map<String, dynamic>))
              .toList();
      return {'data': reservations, 'pagination': response['pagination'] ?? {}};
    } catch (e) {
      _logger.error('Repository error getting filtered reservations: $e');
      rethrow;
    }
  }

  // NEW: Get upcoming reservations
  // Returns a map with 'data' (List<Reservation>) and 'pagination' (Map<String, dynamic>)
  Future<Map<String, dynamic>> getUpcomingReservations({
    String? staffId,
    int page = 1,
    int limit = 10,
  }) async {
    try {
      _logger.info('Repository: Getting upcoming reservations.');
      final response = await _reservationProvider.getUpcomingReservations(
        staffId: staffId,
        page: page,
        limit: limit,
      );
      List<Reservation> reservations =
          (response['data'] as List)
              .map((item) => Reservation.fromJson(item as Map<String, dynamic>))
              .toList();
      return {'data': reservations, 'pagination': response['pagination'] ?? {}};
    } catch (e) {
      _logger.error('Repository: Error getting upcoming reservations: $e');
      rethrow;
    }
  }

  // NEW: Get upcoming reservations for a specific day
  // Returns a map with 'data' (List<Reservation>) and 'pagination' (Map<String, dynamic>)
  Future<Map<String, dynamic>> getUpcomingReservationsForDay({
    required DateTime date,
    int page = 1,
    int limit = 10,
  }) async {
    try {
      _logger.info('Repository: Getting upcoming reservations for day $date.');
      final response = await _reservationProvider.getUpcomingReservationsForDay(
        date: date,
        page: page,
        limit: limit,
      );
      List<Reservation> reservations =
          (response['data'] as List)
              .map((item) => Reservation.fromJson(item as Map<String, dynamic>))
              .toList();
      return {'data': reservations, 'pagination': response['pagination'] ?? {}};
    } catch (e) {
      _logger.error(
        'Repository: Error getting upcoming reservations for day $date: $e',
      );
      rethrow;
    }
  }

  // Get reservation by ID
  Future<Reservation> getReservationById(String id) async {
    try {
      _logger.info('Repository: Getting reservation by ID $id.');
      final responseMap = await _reservationProvider.getReservationById(id);
      // The backend directly returns the reservation object in 'data' field for this specific endpoint
      if (responseMap['data'] != null &&
          responseMap['data'] is Map<String, dynamic>) {
        return Reservation.fromJson(
          responseMap['data'] as Map<String, dynamic>,
        );
      }
      // Fallback if the structure is flat (though your controller suggests it's nested under 'data')
      return Reservation.fromJson(responseMap);
    } catch (e) {
      _logger.error('Repository error getting reservation by id $id: $e');
      rethrow;
    }
  }

  // Update reservation status
  Future<Reservation> updateReservationStatus(String id, String status) async {
    try {
      _logger.info('Repository: Updating reservation $id status to $status.');
      final responseMap = await _reservationProvider.updateReservationStatus(
        id,
        status,
      );
      // Backend returns the updated reservation in 'data'
      return Reservation.fromJson(responseMap['data'] as Map<String, dynamic>);
    } catch (e) {
      _logger.error('Repository error updating reservation $id status: $e');
      rethrow;
    }
  }

  // Create manual reservation
  // Returns a map containing the created reservation and payment details
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
      _logger.info(
        'Repository: Creating manual reservation for $customerName.',
      );
      final response = await _reservationProvider.createManualReservation(
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
      // Assuming the backend returns a structure like: { data: { reservation: {...}, payment: {...}, customer: {...} } }
      // Adjust parsing based on actual backend response structure for this endpoint
      if (response['data'] != null &&
          response['data'] is Map<String, dynamic>) {
        final responseData = response['data'] as Map<String, dynamic>;
        return {
          'reservation': Reservation.fromJson(
            responseData['reservation'] as Map<String, dynamic>,
          ),
          'payment': Payment.fromJson(
            responseData['payment'] as Map<String, dynamic>,
          ), // Ensure Payment.fromJson exists
          'customer':
              responseData['customer'], // Or parse into a Customer model
        };
      }
      _logger.warning(
        'Repository: createManualReservation response structure might not be as expected: $response',
      );
      // Fallback if the structure is different or if you want to return the raw map
      return response; // Or parse into a more specific model if needed
    } on DioException catch (e) {
      _logger.error(
        'Repository DioException creating manual reservation: ${e.message}',
      );
      final errorMessage = e.response?.data?['message']?.toString();
      if (e.response?.statusCode == 400 &&
          errorMessage != null &&
          errorMessage.contains('Session is already booked')) {
        _logger.error(
          "Repository: Session is already booked. Client should handle this.",
        );
        // You might want to throw a custom exception here that the UI can catch specifically
        throw Exception(
          "Session is already booked. Please select an available session.",
        );
      }
      if (e.response?.statusCode == 409) {
        // Conflict, session already booked
        _logger.error(
          "Repository: Session is already booked by another customer (409).",
        );
        throw Exception(
          "Session is no longer available. Please select another session.",
        );
      }
      rethrow;
    } catch (e) {
      _logger.error('Repository error creating manual reservation: $e');
      rethrow;
    }
  }

  // Upload payment proof for manual reservation
  // Assuming it returns the updated Payment object nested under 'data': { 'data': { 'payment': {...} } }
  Future<Payment> uploadManualPaymentProof(
    String reservationId,
    File paymentProofFile, {
    String? notes,
  }) async {
    try {
      _logger.info(
        'Repository: Uploading manual payment proof for reservation $reservationId.',
      );
      final response = await _reservationProvider.uploadManualPaymentProof(
        reservationId,
        paymentProofFile,
        notes: notes,
      );
      // Adjust based on the actual structure returned by your backend
      // Your controller returns { data: { payment: {...}, reservation: {...} } }
      final paymentData = response['data']?['payment'];
      if (paymentData != null && paymentData is Map<String, dynamic>) {
        return Payment.fromJson(paymentData);
      }
      throw Exception('Failed to parse payment proof upload response');
    } catch (e) {
      _logger.error(
        'Repository error uploading payment proof for $reservationId: $e',
      );
      rethrow;
    }
  }

  // Verify manual payment
  // Assuming it returns the updated Payment object nested under 'data': { 'data': { 'payment': {...} } }
  Future<Payment> verifyManualPayment(String paymentId, bool isVerified) async {
    try {
      _logger.info(
        'Repository: Verifying manual payment $paymentId, isVerified: $isVerified.',
      );
      final response = await _reservationProvider.verifyManualPayment(
        paymentId,
        isVerified,
      );
      // Your controller returns { data: { payment: {...}, reservation: {...} } }
      final paymentData = response['data']?['payment'];
      if (paymentData != null && paymentData is Map<String, dynamic>) {
        return Payment.fromJson(paymentData);
      }
      throw Exception('Failed to parse verify manual payment response');
    } catch (e) {
      _logger.error('Repository error verifying payment $paymentId: $e');
      rethrow;
    }
  }

  // Get reservation analytics
  Future<Map<String, dynamic>> getReservationAnalytics(
    DateTime startDate,
    DateTime endDate,
  ) async {
    try {
      _logger.info('Repository: Getting reservation analytics.');
      // The provider already returns the data directly, assuming it's the analytics map.
      // The backend controller returns { data: analytics }
      final response = await _reservationProvider.getReservationAnalytics(
        startDate,
        endDate,
      );
      return response['data'] as Map<String, dynamic>;
    } catch (e) {
      _logger.error('Repository error getting analytics: $e');
      rethrow;
    }
  }
}
