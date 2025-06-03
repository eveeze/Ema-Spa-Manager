// lib/data/repository/reservation_repository.dart
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:emababyspa/data/models/reservation.dart';
import 'package:emababyspa/data/models/payment.dart';
import 'package:emababyspa/data/models/payment_method.dart';
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
      _logger.info('Repository: Getting filtered reservations (Owner).');
      final response = await _reservationProvider.getFilteredReservations(
        status: status,
        startDate: startDate,
        endDate: endDate,
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
      _logger.error(
        'Repository error getting filtered reservations (Owner): $e',
      );
      rethrow;
    }
  }

  // Get upcoming reservations for Owner
  Future<Map<String, dynamic>> getUpcomingReservations({
    String? staffId,
    int page = 1,
    int limit = 10,
  }) async {
    try {
      _logger.info('Repository: Getting upcoming reservations (Owner).');
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
      _logger.error(
        'Repository: Error getting upcoming reservations (Owner): $e',
      );
      rethrow;
    }
  }

  // Get upcoming reservations for a specific day for Owner
  Future<Map<String, dynamic>> getUpcomingReservationsForDay({
    required DateTime date,
    int page = 1,
    int limit = 10,
  }) async {
    try {
      _logger.info(
        'Repository: Getting upcoming reservations for day $date (Owner).',
      );
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
        'Repository: Error getting upcoming reservations for day $date (Owner): $e',
      );
      rethrow;
    }
  }

  // Get reservation by ID for Owner
  Future<Reservation> getReservationById(String id) async {
    try {
      _logger.info('Repository: Getting reservation by ID $id (Owner).');
      // _reservationProvider.getReservationById(id) already returns the content of the 'data' field
      // from the API response due to the use of _apiClient.getValidated in the provider.
      final Map<String, dynamic> reservationDataMap = await _reservationProvider
          .getReservationById(id);

      // Directly parse the reservationDataMap as it's already the correct object
      return Reservation.fromJson(reservationDataMap);
    } catch (e) {
      _logger.error(
        'Repository error getting reservation by id $id (Owner): $e',
      );
      rethrow; // Rethrow the error to be handled by the controller
    }
  }

  // Update reservation status for Owner
  Future<Reservation> updateReservationStatus(String id, String status) async {
    try {
      _logger.info(
        'Repository: Updating reservation $id status to $status (Owner).',
      );
      final responseMap = await _reservationProvider.updateReservationStatus(
        id,
        status,
      );
      return Reservation.fromJson(responseMap['data'] as Map<String, dynamic>);
    } catch (e) {
      _logger.error(
        'Repository error updating reservation $id status (Owner): $e',
      );
      rethrow;
    }
  }

  // Create manual reservation by Owner
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
        'Repository: Creating manual reservation for $customerName (Owner).',
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
      if (response['data'] != null &&
          response['data'] is Map<String, dynamic>) {
        final responseData = response['data'] as Map<String, dynamic>;
        return {
          'reservation': Reservation.fromJson(
            responseData['reservation'] as Map<String, dynamic>,
          ),
          'payment': Payment.fromJson(
            responseData['payment'] as Map<String, dynamic>,
          ),
          'customer': responseData['customer'],
        };
      }
      _logger.warning(
        'Repository: createManualReservation response structure not as expected: $response (Owner)',
      );
      return response;
    } on DioException catch (e) {
      _logger.error(
        'Repository DioException creating manual reservation: ${e.message} (Owner)',
      );
      final errorMessage = e.response?.data?['message']?.toString();
      if (e.response?.statusCode == 400 &&
          errorMessage != null &&
          errorMessage.contains('Session is already booked')) {
        _logger.error(
          "Repository: Session is already booked. Client should handle this. (Owner)",
        );
        throw Exception(
          "Session is already booked. Please select an available session.",
        );
      }
      if (e.response?.statusCode == 409) {
        _logger.error(
          "Repository: Session is already booked by another customer (409). (Owner)",
        );
        throw Exception(
          "Session is no longer available. Please select another session.",
        );
      }
      rethrow;
    } catch (e) {
      _logger.error('Repository error creating manual reservation: $e (Owner)');
      rethrow;
    }
  }

  // Upload payment proof for manual reservation by Owner
  Future<Payment> uploadManualPaymentProof(
    String reservationId,
    File paymentProofFile, {
    String? notes,
  }) async {
    try {
      _logger.info(
        'Repository: Uploading manual payment proof for reservation $reservationId (Owner).',
      );
      final response = await _reservationProvider.uploadManualPaymentProof(
        reservationId,
        paymentProofFile,
        notes: notes,
      );
      final paymentData = response['data']?['payment'];
      if (paymentData != null && paymentData is Map<String, dynamic>) {
        return Payment.fromJson(paymentData);
      }
      throw Exception('Failed to parse payment proof upload response (Owner)');
    } catch (e) {
      _logger.error(
        'Repository error uploading payment proof for $reservationId (Owner): $e',
      );
      rethrow;
    }
  }

  // Verify manual payment by Owner
  Future<Payment> verifyManualPayment(String paymentId, bool isVerified) async {
    try {
      _logger.info(
        'Repository: Verifying manual payment $paymentId, isVerified: $isVerified (Owner).',
      );
      final response = await _reservationProvider.verifyManualPayment(
        paymentId,
        isVerified,
      );
      final paymentData = response['data']?['payment'];
      if (paymentData != null && paymentData is Map<String, dynamic>) {
        return Payment.fromJson(paymentData);
      }
      throw Exception('Failed to parse verify manual payment response (Owner)');
    } catch (e) {
      _logger.error(
        'Repository error verifying payment $paymentId (Owner): $e',
      );
      rethrow;
    }
  }

  // Get reservation analytics for Owner
  Future<Map<String, dynamic>> getReservationAnalytics(
    DateTime startDate,
    DateTime endDate,
  ) async {
    try {
      _logger.info('Repository: Getting reservation analytics (Owner).');
      final response = await _reservationProvider.getReservationAnalytics(
        startDate,
        endDate,
      );
      return response['data'] as Map<String, dynamic>;
    } catch (e) {
      _logger.error('Repository error getting analytics: $e (Owner)');
      rethrow;
    }
  }

  // ADDED: Get Payment Methods for Owner
  Future<List<PaymentMethodModel>> getOwnerPaymentMethods() async {
    try {
      _logger.info('Repository: Getting payment methods (Owner).');
      final response = await _reservationProvider.getOwnerPaymentMethods();
      // Backend returns { data: formattedChannels }
      // formattedChannels is a list of maps
      List<PaymentMethodModel> methods =
          (response['data'] as List)
              .map(
                (item) =>
                    PaymentMethodModel.fromJson(item as Map<String, dynamic>),
              )
              .toList();
      return methods;
    } catch (e) {
      _logger.error('Repository: Error getting payment methods (Owner): $e');
      rethrow;
    }
  }

  Future<Map<String, dynamic>> getOwnerPaymentDetails(
    String reservationId,
  ) async {
    try {
      _logger.info(
        'Repository: Getting payment details for reservation $reservationId (Owner).',
      );
      // apiResponseData will be { "payment": {...}, "reservation": {...} }
      // as _apiClient.getValidated in the provider extracts the "data" field from the raw API response.
      final Map<String, dynamic> apiResponseData = await _reservationProvider
          .getOwnerPaymentDetails(reservationId);

      // Directly check for 'payment' and 'reservation' keys in apiResponseData
      if (apiResponseData['payment'] != null &&
          apiResponseData['payment'] is Map<String, dynamic> &&
          apiResponseData['reservation'] != null &&
          apiResponseData['reservation'] is Map<String, dynamic>) {
        return {
          'payment': Payment.fromJson(
            apiResponseData['payment'] as Map<String, dynamic>,
          ),
          'reservation': Reservation.fromJson(
            apiResponseData['reservation'] as Map<String, dynamic>,
          ),
        };
      } else {
        // This case means the expected "payment" or "reservation" fields are missing
        // from the content of the "data" field of the API response.
        _logger.warning(
          'Repository: getOwnerPaymentDetails - "payment" or "reservation" field missing or invalid in API data: $apiResponseData (Owner)',
        );
        throw Exception(
          'Payment or reservation data missing or invalid in API response data.',
        );
      }
    } catch (e) {
      _logger.error(
        'Repository: Error getting payment details for $reservationId (Owner): $e',
      );
      rethrow;
    }
  }

  // ADDED: Update Manual Reservation Payment Status by Owner
  // Returns a simple success message map or throws error
  Future<Map<String, dynamic>> updateManualReservationPaymentStatus(
    String reservationId, {
    String paymentMethod = 'CASH',
    String? notes,
  }) async {
    try {
      _logger.info(
        'Repository: Updating manual reservation $reservationId payment status (Owner).',
      );
      // The provider method already returns a Map<String, dynamic> which usually contains { success: true, message: "..." }
      return await _reservationProvider.updateManualReservationPaymentStatus(
        reservationId,
        paymentMethod: paymentMethod,
        notes: notes,
      );
    } catch (e) {
      _logger.error(
        'Repository: Error updating manual reservation $reservationId payment (Owner): $e',
      );
      rethrow;
    }
  }
}
