// lib/data/providers/reservation_provider.dart
import 'dart:io';
import 'package:emababyspa/data/api/api_client.dart';
import 'package:emababyspa/data/api/api_endpoints.dart'; // Pastikan endpoint baru didefinisikan di sini
import 'package:emababyspa/utils/logger_utils.dart';
import 'package:http_parser/http_parser.dart';
import 'package:path/path.dart' as path;
import 'package:dio/dio.dart';

class ReservationProvider {
  final ApiClient _apiClient;
  final LoggerUtils _logger;

  ReservationProvider({
    required ApiClient apiClient,
    required LoggerUtils logger,
  }) : _apiClient = apiClient,
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
      final Map<String, dynamic> queryParams = {
        'page': page.toString(),
        'limit': limit.toString(),
        if (status != null) 'status': status,
        if (startDate != null)
          'startDate': startDate.toIso8601String().split('T')[0],
        if (endDate != null) 'endDate': endDate.toIso8601String().split('T')[0],
        if (staffId != null) 'staffId': staffId,
      };
      _logger.info('Getting filtered reservations with params: $queryParams');
      return await _apiClient.getValidated(
        ApiEndpoints
            .reservationsOwner, // Endpoint untuk daftar (tanpa ID di path)
        queryParameters: queryParams,
        dataField: 'reservations', // Field yang berisi daftar reservasi
      );
    } catch (e) {
      _logger.error('Error getting filtered reservations: $e');
      rethrow;
    }
  }

  // NEW: Get upcoming reservations for owner
  Future<Map<String, dynamic>> getUpcomingReservations({
    String? staffId,
    int page = 1,
    int limit = 10,
  }) async {
    try {
      final Map<String, dynamic> queryParams = {
        'page': page.toString(),
        'limit': limit.toString(),
        if (staffId != null) 'staffId': staffId,
      };
      _logger.info('Getting upcoming reservations with params: $queryParams');
      return await _apiClient.getValidated(
        ApiEndpoints.reservationsOwnerUpcoming,
        queryParameters: queryParams,
        dataField: 'reservations', // Field yang berisi daftar reservasi
      );
    } catch (e) {
      _logger.error('Error getting upcoming reservations: $e');
      rethrow;
    }
  }

  // NEW: Get upcoming reservations for a specific day for the dashboard
  Future<Map<String, dynamic>> getUpcomingReservationsForDay({
    required DateTime date,
    int page = 1,
    int limit = 10,
  }) async {
    try {
      final Map<String, dynamic> queryParams = {
        'date': date.toIso8601String().split('T')[0],
        'page': page.toString(),
        'limit': limit.toString(),
      };
      _logger.info(
        'Getting upcoming reservations for day with params: $queryParams',
      );
      return await _apiClient.getValidated(
        ApiEndpoints.reservationsOwnerDashboardUpcomingByDay,
        queryParameters: queryParams,
        dataField: 'reservations',
      );
    } catch (e) {
      _logger.error('Error getting upcoming reservations for day: $e');
      rethrow;
    }
  }

  // Get reservation by ID for Owner
  Future<Map<String, dynamic>> getReservationById(String id) async {
    try {
      _logger.info('Getting reservation by ID (Owner): $id');
      // Asumsikan ApiEndpoints.reservationsOwnerById = '/owner/reservations/{id}'
      return await _apiClient.getValidated(
        ApiEndpoints.reservationsOwnerById, // Ganti dengan endpoint yang sesuai
        pathParams: {'id': id},
      );
    } catch (e) {
      _logger.error('Error getting reservation by id $id (Owner): $e');
      rethrow;
    }
  }

  // Update reservation status for Owner
  Future<Map<String, dynamic>> updateReservationStatus(
    String id,
    String status,
  ) async {
    try {
      _logger.info('Updating reservation $id status to: $status (Owner)');
      // Asumsikan ApiEndpoints.reservationsOwnerStatusById = '/owner/reservations/{id}/status'
      return await _apiClient.putValidated(
        ApiEndpoints
            .reservationsOwnerStatusById, // Ganti dengan endpoint yang sesuai
        pathParams: {'id': id},
        data: {'status': status},
      );
    } catch (e) {
      _logger.error('Error updating reservation $id status (Owner): $e');
      rethrow;
    }
  }

  Future<Map<String, dynamic>> updateReservation(
    String id,
    Map<String, dynamic> data,
  ) async {
    try {
      _logger.info('Provider: Updating reservation $id (Owner)');
      // PERBAIKI ENDPOINT DI SINI
      return await _apiClient.putValidated(
        ApiEndpoints.reservationsOwnerUpdateDetailsById,
        pathParams: {'id': id},
        data: data,
      );
    } catch (e) {
      _logger.error('Provider: Error updating reservation $id (Owner): $e');
      rethrow;
    }
  }

  // TAMBAHKAN FUNGSI BARU INI
  Future<Map<String, dynamic>> updateManualPaymentProof(
    String reservationId,
    File paymentProofFile,
  ) async {
    try {
      _logger.info(
        'Provider: Updating manual payment proof for reservation $reservationId (Owner)',
      );
      String fileName = path.basename(paymentProofFile.path);
      FormData formData = FormData.fromMap({
        'paymentProof': await MultipartFile.fromFile(
          paymentProofFile.path,
          filename: fileName,
          contentType: MediaType.parse(_getContentType(fileName)),
        ),
      });

      return await _apiClient.putMultipartValidated(
        ApiEndpoints.reservationsOwnerUpdatePaymentProofById, // Endpoint baru
        pathParams: {'reservationId': reservationId}, // <-- BENAR
        data: formData,
      );
    } catch (e) {
      _logger.error(
        'Provider: Error updating payment proof for $reservationId (Owner): $e',
      );
      rethrow;
    }
  }

  Future<Map<String, dynamic>> confirmManualWithProof(
    String reservationId,
    File paymentProofFile,
  ) async {
    try {
      _logger.info(
        'Provider: Confirming manual reservation $reservationId with proof.',
      );
      String fileName = path.basename(paymentProofFile.path);
      FormData formData = FormData.fromMap({
        'paymentProof': await MultipartFile.fromFile(
          paymentProofFile.path,
          filename: fileName,
          contentType: MediaType.parse(_getContentType(fileName)),
        ),
      });

      return await _apiClient.postMultipartValidated(
        ApiEndpoints.reservationsOwnerConfirmWithProof, // Endpoint baru
        pathParams: {'reservationId': reservationId},
        data: formData,
      );
    } catch (e) {
      _logger.error('Provider: Error confirming reservation with proof: $e');
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
        'Creating manual reservation for $customerName, baby $babyName, service $serviceId, session $sessionId. isPaid: $isPaid',
      );
      FormData formData = FormData.fromMap({
        'customerName': customerName,
        'customerPhone': customerPhone,
        if (parentNames != null && parentNames.isNotEmpty)
          'parentNames': parentNames,
        if (customerAddress != null && customerAddress.isNotEmpty)
          'customerAddress': customerAddress,
        if (customerInstagram != null && customerInstagram.isNotEmpty)
          'customerInstagram': customerInstagram,
        'babyName': babyName,
        'babyAge': babyAge.toString(),
        'serviceId': serviceId,
        'sessionId': sessionId,
        if (priceTierId != null && priceTierId.isNotEmpty)
          'priceTierId': priceTierId,
        if (notes != null && notes.isNotEmpty) 'notes': notes,
        'paymentMethod': paymentMethod,
        'isPaid': isPaid.toString(),
        if (paymentNotes != null && paymentNotes.isNotEmpty)
          'paymentNotes': paymentNotes,
      });

      if (paymentProofFile != null) {
        String fileName = path.basename(paymentProofFile.path);
        formData.files.add(
          MapEntry(
            'paymentProof',
            await MultipartFile.fromFile(
              paymentProofFile.path,
              filename: fileName,
              contentType: MediaType.parse(_getContentType(fileName)),
            ),
          ),
        );
      }
      _logger.info(
        'Manual reservation FormData: ${formData.fields}, files: ${formData.files.map((e) => e.key)}',
      );
      return await _apiClient.postMultipartValidated(
        ApiEndpoints
            .manualReservations, // Endpoint untuk membuat (tanpa ID di path)
        data: formData,
      );
    } on DioException catch (dioError) {
      _logger.error(
        'DioError creating manual reservation: ${dioError.message}',
      );
      if (dioError.response != null) {
        _logger.error('DioError response data: ${dioError.response?.data}');
        _logger.error(
          'DioError response headers: ${dioError.response?.headers}',
        );
      }
      rethrow;
    } catch (e) {
      _logger.error('Error creating manual reservation: $e');
      rethrow;
    }
  }

  // Upload payment proof for manual reservation by Owner
  Future<Map<String, dynamic>> uploadManualPaymentProof(
    String reservationId,
    File paymentProofFile, {
    String? notes,
  }) async {
    try {
      _logger.info(
        'Uploading manual payment proof for reservation $reservationId (Owner)',
      );
      String fileName = path.basename(paymentProofFile.path);
      // Asumsikan ApiEndpoints.manualReservationsPaymentProofById = '/manual-reservations/{id}/payment-proof'
      FormData formData = FormData.fromMap({
        if (notes != null) 'paymentNotes': notes,
        'paymentProof': await MultipartFile.fromFile(
          paymentProofFile.path,
          filename: fileName,
          contentType: MediaType.parse(_getContentType(fileName)),
        ),
      });
      _logger.info('Uploading payment proof FormData: ${formData.fields}');
      return await _apiClient.postMultipartValidated(
        ApiEndpoints
            .manualReservationsPaymentProofById, // Ganti dengan endpoint yang sesuai
        pathParams: {'reservationId': reservationId}, // <-- BENAR
        data: formData,
      );
    } catch (e) {
      _logger.error(
        'Error uploading payment proof for $reservationId (Owner): $e',
      );
      rethrow;
    }
  }

  // Verify manual payment by Owner
  Future<Map<String, dynamic>> verifyManualPayment(
    String paymentId, // Ini adalah paymentId, bukan reservationId
    bool isVerified,
  ) async {
    try {
      _logger.info(
        'Verifying manual payment $paymentId, isVerified: $isVerified (Owner)',
      );
      // Asumsikan ApiEndpoints.ownerPaymentVerifyById = '/owner/payments/{id}/verify'
      return await _apiClient.putValidated(
        ApiEndpoints
            .ownerPaymentVerifyById, // Ganti dengan endpoint yang sesuai
        pathParams: {'paymentId': paymentId}, // <-- BENAR
        data: {'isVerified': isVerified},
      );
    } catch (e) {
      _logger.error('Error verifying manual payment $paymentId (Owner): $e');
      rethrow;
    }
  }

  // Get Payment Methods for Owner
  Future<Map<String, dynamic>> getOwnerPaymentMethods() async {
    try {
      _logger.info('Getting payment methods (Owner)');
      return await _apiClient.getValidated(
        ApiEndpoints.ownerSpecificPaymentMethods,
      );
    } catch (e) {
      _logger.error('Error getting payment methods (Owner): $e');
      rethrow;
    }
  }

  // Get Payment Details for a Reservation by Owner
  Future<Map<String, dynamic>> getOwnerPaymentDetails(
    String reservationId,
  ) async {
    try {
      _logger.info(
        'Getting payment details for reservation $reservationId (Owner)',
      );
      // Asumsikan ApiEndpoints.reservationsOwnerPaymentDetailsById = '/owner/reservations/payment/{id}'
      return await _apiClient.getValidated(
        ApiEndpoints
            .reservationsOwnerPaymentDetailsById, // Ganti dengan endpoint yang sesuai
        pathParams: {'id': reservationId},
      );
    } catch (e) {
      _logger.error(
        'Error getting payment details for $reservationId (Owner): $e',
      );
      rethrow;
    }
  }

  Future<Map<String, dynamic>> rescheduleReservation(
    String reservationId,
    String newSessionId,
  ) async {
    try {
      _logger.info(
        'Provider: Rescheduling reservation $reservationId to new session $newSessionId',
      );
      return await _apiClient.putValidated(
        ApiEndpoints.reservationsOwnerRescheduleById,
        pathParams: {'id': reservationId},
        data: {'newSessionId': newSessionId},
      );
    } catch (e) {
      _logger.error(
        'Provider: Error rescheduling reservation $reservationId: $e',
      );
      rethrow;
    }
  }

  // Update Manual Reservation Payment Status by Owner
  Future<Map<String, dynamic>> updateManualReservationPaymentStatus(
    String reservationId, {
    String paymentMethod = 'CASH',
    String? notes,
  }) async {
    try {
      _logger.info(
        'Updating manual reservation $reservationId payment status to PAID (Owner)',
      );
      final Map<String, dynamic> data = {
        'paymentMethod': paymentMethod.toUpperCase(),
      };
      if (notes != null) {
        data['notes'] = notes;
      }
      // Asumsikan ApiEndpoints.manualReservationsPaymentUpdateById = '/manual-reservations/{id}/payment'
      return await _apiClient.putValidated(
        ApiEndpoints
            .manualReservationsPaymentUpdateById, // Ganti dengan endpoint yang sesuai
        pathParams: {'id': reservationId},
        data: data,
      );
    } catch (e) {
      _logger.error(
        'Error updating manual reservation $reservationId payment (Owner): $e',
      );
      rethrow;
    }
  }

  // Helper method to determine content type
  String _getContentType(String fileName) {
    final ext = path.extension(fileName).toLowerCase();
    switch (ext) {
      case '.jpg':
      case '.jpeg':
        return 'image/jpeg';
      case '.png':
        return 'image/png';
      default:
        return 'application/octet-stream';
    }
  }
}
