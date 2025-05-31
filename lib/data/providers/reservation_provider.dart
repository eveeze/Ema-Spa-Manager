// lib/data/providers/reservation_provider.dart
import 'dart:io';
import 'package:emababyspa/data/api/api_client.dart';
import 'package:emababyspa/data/api/api_endpoints.dart';
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
        if (startDate != null) 'startDate': startDate.toIso8601String(),
        if (endDate != null) 'endDate': endDate.toIso8601String(),
        if (staffId != null) 'staffId': staffId,
      };

      return await _apiClient.getValidated(
        ApiEndpoints.reservationsOwner,
        queryParameters: queryParams,
      );
    } catch (e) {
      _logger.error('Error getting filtered reservations: $e');
      rethrow;
    }
  }

  // Get reservation by ID
  Future<Map<String, dynamic>> getReservationById(String id) async {
    try {
      return await _apiClient.getValidated('${ApiEndpoints.reservations}/$id');
    } catch (e) {
      _logger.error('Error getting reservation by id: $e');
      rethrow;
    }
  }

  // Update reservation status
  Future<Map<String, dynamic>> updateReservationStatus(
    String id,
    String status,
  ) async {
    try {
      final currentReservation = await getReservationById(id);

      return await _apiClient.putValidated(
        '${ApiEndpoints.reservations}/$id/status',
        data: {
          'status': status,
          'currentStatus': currentReservation['status'], // Tambahkan
        },
      );
    } catch (e) {
      _logger.error('Error updating reservation status: $e');
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
      FormData formData = FormData.fromMap({
        'customerName': customerName,
        'customerPhone': customerPhone,
        if (parentNames != null) 'parentNames': parentNames,

        if (customerAddress != null) 'customerAddress': customerAddress,
        if (customerInstagram != null) 'customerInstagram': customerInstagram,
        'babyName': babyName,
        'babyAge': babyAge.toString(),
        if (parentNames != null) 'parentNames': parentNames,
        'serviceId': serviceId,
        'sessionId': sessionId,
        if (priceTierId != null) 'priceTierId': priceTierId,
        if (notes != null) 'notes': notes,
        'paymentMethod': paymentMethod,
        'isPaid': isPaid.toString(),
        if (paymentNotes != null) 'paymentNotes': paymentNotes,
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

      return await _apiClient.postMultipartValidated(
        ApiEndpoints.manualReservations,
        data: formData,
      );
    } on DioException catch (e) {
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
      String fileName = path.basename(paymentProofFile.path);
      final endpoint =
          '${ApiEndpoints.manualReservations}/$reservationId/payment-proof';
      FormData formData = FormData.fromMap({
        if (notes != null) 'paymentNotes': notes,
        'paymentProof': await MultipartFile.fromFile(
          paymentProofFile.path,
          filename: fileName,
          contentType: MediaType.parse(_getContentType(fileName)),
        ),
      });

      return await _apiClient.postMultipartValidated(endpoint, data: formData);
    } catch (e) {
      _logger.error('Error uploading payment proof: $e');
      rethrow;
    }
  }

  // Verify manual payment
  Future<Map<String, dynamic>> verifyManualPayment(
    String paymentId,
    bool isVerified,
  ) async {
    try {
      return await _apiClient.putValidated(
        '${ApiEndpoints.ownerPayment}/$paymentId/verify',
        data: {'isVerified': isVerified},
      );
    } catch (e) {
      _logger.error('Error verifying manual payment: $e');
      rethrow;
    }
  }

  // Get reservation analytics
  Future<Map<String, dynamic>> getReservationAnalytics(
    DateTime startDate,
    DateTime endDate,
  ) async {
    try {
      return await _apiClient.getValidated(
        ApiEndpoints.reservationsAnalytics,
        queryParameters: {
          'startDate': startDate.toIso8601String(),
          'endDate': endDate.toIso8601String(),
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
        return 'application/octet-stream';
    }
  }
}
