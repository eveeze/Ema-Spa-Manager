// lib/data/providers/reservation_provider.dart
import 'dart:io';
import 'package:emababyspa/data/api/api_client.dart';
import 'package:emababyspa/data/api/api_endpoints.dart';
import 'package:emababyspa/utils/logger_utils.dart';
import 'package:http_parser/http_parser.dart';
import 'package:path/path.dart' as path;
import 'package:dio/dio.dart'; // Ensure Dio is imported if not already

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
          'startDate': startDate.toIso8601String().split('T')[0], // YYYY-MM-DD
        if (endDate != null)
          'endDate': endDate.toIso8601String().split('T')[0], // YYYY-MM-DD
        if (staffId != null) 'staffId': staffId,
      };
      _logger.info('Getting filtered reservations with params: $queryParams');
      return await _apiClient.getValidated(
        ApiEndpoints.reservationsOwner,
        queryParameters: queryParams,
      );
    } catch (e) {
      _logger.error('Error getting filtered reservations: $e');
      rethrow;
    }
  }

  // NEW: Get upcoming reservations for owner
  Future<Map<String, dynamic>> getUpcomingReservations({
    String? staffId, // Optional: if owner wants to filter by a specific staff
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
        ApiEndpoints.reservationsOwnerUpcoming, // Use the new endpoint
        queryParameters: queryParams,
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
        'date': date.toIso8601String().split('T')[0], // Format as YYYY-MM-DD
        'page': page.toString(),
        'limit': limit.toString(),
      };
      _logger.info(
        'Getting upcoming reservations for day with params: $queryParams',
      );
      return await _apiClient.getValidated(
        ApiEndpoints
            .reservationsOwnerDashboardUpcomingByDay, // Use the new endpoint
        queryParameters: queryParams,
      );
    } catch (e) {
      _logger.error('Error getting upcoming reservations for day: $e');
      rethrow;
    }
  }

  // Get reservation by ID
  Future<Map<String, dynamic>> getReservationById(String id) async {
    try {
      _logger.info('Getting reservation by ID: $id');
      // Assuming your backend endpoint for a single reservation might be different for owner vs customer
      // For owner, it might be something like:
      // return await _apiClient.getValidated('${ApiEndpoints.reservationsOwner}/$id');
      // Or if it's a general one:
      return await _apiClient.getValidated(
        '${ApiEndpoints.reservations}/owner/$id',
      ); // Adjusted based on your routes for owner
    } catch (e) {
      _logger.error('Error getting reservation by id $id: $e');
      rethrow;
    }
  }

  // Update reservation status
  Future<Map<String, dynamic>> updateReservationStatus(
    String id,
    String status,
  ) async {
    try {
      _logger.info('Updating reservation $id status to: $status');
      // No need to fetch currentReservation here, backend handles validation
      return await _apiClient.putValidated(
        '${ApiEndpoints.reservationsOwner}/$id/status', // Adjusted for owner route
        data: {'status': status},
      );
    } catch (e) {
      _logger.error('Error updating reservation $id status: $e');
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
    bool isPaid = false, // Backend expects boolean or string that converts
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
        'babyAge':
            babyAge
                .toString(), // Backend expects string or number, ensure consistency
        'serviceId': serviceId,
        'sessionId': sessionId,
        if (priceTierId != null && priceTierId.isNotEmpty)
          'priceTierId': priceTierId,
        if (notes != null && notes.isNotEmpty) 'notes': notes,
        'paymentMethod': paymentMethod,
        'isPaid': isPaid.toString(), // Send as string 'true' or 'false'
        if (paymentNotes != null && paymentNotes.isNotEmpty)
          'paymentNotes': paymentNotes,
      });

      if (paymentProofFile != null) {
        String fileName = path.basename(paymentProofFile.path);
        formData.files.add(
          MapEntry(
            'paymentProof', // This key must match your backend middleware (paymentProofUploadMiddleware expects 'paymentProof')
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
        ApiEndpoints.manualReservations,
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

  // Upload payment proof for manual reservation
  Future<Map<String, dynamic>> uploadManualPaymentProof(
    String reservationId,
    File paymentProofFile, {
    String? notes,
  }) async {
    try {
      _logger.info(
        'Uploading manual payment proof for reservation $reservationId',
      );
      String fileName = path.basename(paymentProofFile.path);
      final endpoint =
          '${ApiEndpoints.manualReservations}/$reservationId/payment-proof'; // Correct endpoint from routes
      FormData formData = FormData.fromMap({
        if (notes != null)
          'paymentNotes': notes, // Ensure backend expects 'paymentNotes'
        'paymentProof': await MultipartFile.fromFile(
          // This key must match your backend middleware
          paymentProofFile.path,
          filename: fileName,
          contentType: MediaType.parse(_getContentType(fileName)),
        ),
      });
      _logger.info('Uploading payment proof FormData: ${formData.fields}');
      return await _apiClient.postMultipartValidated(endpoint, data: formData);
    } catch (e) {
      _logger.error('Error uploading payment proof for $reservationId: $e');
      rethrow;
    }
  }

  // Verify manual payment
  Future<Map<String, dynamic>> verifyManualPayment(
    String paymentId,
    bool isVerified,
  ) async {
    try {
      _logger.info(
        'Verifying manual payment $paymentId, isVerified: $isVerified',
      );
      return await _apiClient.putValidated(
        '${ApiEndpoints.ownerPayment}/$paymentId/verify', // Correct endpoint
        data: {'isVerified': isVerified},
      );
    } catch (e) {
      _logger.error('Error verifying manual payment $paymentId: $e');
      rethrow;
    }
  }

  // Get reservation analytics
  Future<Map<String, dynamic>> getReservationAnalytics(
    DateTime startDate,
    DateTime endDate,
  ) async {
    try {
      final String formattedStartDate =
          startDate.toIso8601String().split('T')[0];
      final String formattedEndDate = endDate.toIso8601String().split('T')[0];
      _logger.info(
        'Getting reservation analytics from $formattedStartDate to $formattedEndDate',
      );
      return await _apiClient.getValidated(
        ApiEndpoints.reservationsAnalytics,
        queryParameters: {
          'startDate': formattedStartDate,
          'endDate': formattedEndDate,
        },
      );
    } catch (e) {
      _logger.error('Error getting reservation analytics: $e');
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
        return 'application/octet-stream'; // A common default
    }
  }
}
