// lib/features/reservation/controllers/reservation_controller.dart
import 'package:get/get.dart';
import 'dart:io';
import 'package:emababyspa/data/models/reservation.dart';
import 'package:emababyspa/data/models/payment.dart';
import 'package:emababyspa/data/repository/reservation_repository.dart';
import 'package:emababyspa/common/theme/color_theme.dart';
import 'package:emababyspa/utils/logger_utils.dart';
import 'package:dio/dio.dart';

class ReservationController extends GetxController {
  final ReservationRepository _reservationRepository;
  final LoggerUtils _logger = LoggerUtils();

  ReservationController({required ReservationRepository reservationRepository})
    : _reservationRepository = reservationRepository;

  // Observable state
  final RxList<dynamic> reservationList = <dynamic>[].obs;
  final RxBool isLoading = false.obs;
  final RxBool isFormSubmitting = false.obs;
  final RxBool isStatusUpdating = false.obs;
  final RxBool isPaymentUploading = false.obs;
  final RxString errorMessage = ''.obs;
  final Rx<Reservation?> selectedReservation = Rx<Reservation?>(null);
  final RxMap<String, dynamic> reservationAnalytics = <String, dynamic>{}.obs;

  // Filter state
  final RxString selectedStatus = ''.obs;
  final Rx<DateTime?> selectedStartDate = Rx<DateTime?>(null);
  final Rx<DateTime?> selectedEndDate = Rx<DateTime?>(null);
  final RxString selectedStaffId = ''.obs;
  final RxInt currentPage = 1.obs;
  final RxInt totalPages = 1.obs;
  final RxInt totalItems = 0.obs;
  final RxBool hasMoreData = true.obs;

  @override
  void onInit() {
    super.onInit();
    fetchFilteredReservations();
  }

  // Fetch filtered reservations for owner
  Future<void> fetchFilteredReservations({
    bool isRefresh = false,
    int limit = 10,
  }) async {
    try {
      if (isRefresh) {
        currentPage.value = 1;
        hasMoreData.value = true;
      }

      if (!hasMoreData.value && !isRefresh) return;

      isLoading.value = true;
      errorMessage.value = '';

      final response = await _reservationRepository.getFilteredReservations(
        status: selectedStatus.value.isEmpty ? null : selectedStatus.value,
        startDate: selectedStartDate.value,
        endDate: selectedEndDate.value,
        staffId: selectedStaffId.value.isEmpty ? null : selectedStaffId.value,
        page: currentPage.value,
        limit: limit,
      );

      if (response['data'] != null) {
        final List<dynamic> newReservations = response['data'] as List<dynamic>;

        if (isRefresh || currentPage.value == 1) {
          reservationList.value = newReservations;
        } else {
          reservationList.addAll(newReservations);
        }

        // Update pagination info
        totalPages.value = response['pagination']?['totalPages'] ?? 1;
        totalItems.value = response['pagination']?['totalItems'] ?? 0;
        hasMoreData.value = currentPage.value < totalPages.value;
      }
    } catch (e) {
      errorMessage.value = 'Failed to load reservations. Please try again.';
      _logger.error('Error fetching reservations: $e');
    } finally {
      isLoading.value = false;
    }
  }

  // Load more reservations (pagination)
  Future<void> loadMoreReservations() async {
    if (hasMoreData.value && !isLoading.value) {
      currentPage.value++;
      await fetchFilteredReservations();
    }
  }

  // Refresh data
  Future<void> refreshData() async {
    await fetchFilteredReservations(isRefresh: true);
  }

  // Apply filters
  Future<void> applyFilters({
    String? status,
    DateTime? startDate,
    DateTime? endDate,
    String? staffId,
  }) async {
    selectedStatus.value = status ?? '';
    selectedStartDate.value = startDate;
    selectedEndDate.value = endDate;
    selectedStaffId.value = staffId ?? '';

    await fetchFilteredReservations(isRefresh: true);
  }

  // Clear filters
  Future<void> clearFilters() async {
    selectedStatus.value = '';
    selectedStartDate.value = null;
    selectedEndDate.value = null;
    selectedStaffId.value = '';

    await fetchFilteredReservations(isRefresh: true);
  }

  // Get reservation by ID
  Future<void> fetchReservationById(String id) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      if (id.isEmpty) {
        throw Exception("Reservation ID is required");
      }

      final reservation = await _reservationRepository.getReservationById(id);
      selectedReservation.value = reservation;
    } catch (e) {
      errorMessage.value =
          'Failed to fetch reservation details: ${e.toString()}';
      _logger.error('Error fetching reservation by ID: $e');
    } finally {
      isLoading.value = false;
    }
  }

  // Update reservation status
  Future<void> updateReservationStatus(String id, String status) async {
    try {
      isStatusUpdating.value = true;

      final updatedReservation = await _reservationRepository
          .updateReservationStatus(id, status);

      // Update the reservation in the list
      final index = reservationList.indexWhere((item) {
        if (item is Map<String, dynamic>) {
          return item['id'] == id;
        }
        return false;
      });

      if (index != -1) {
        reservationList[index] = updatedReservation.toJson();
        reservationList.refresh();
      }

      // Update selected reservation if it's the same
      if (selectedReservation.value?.id == id) {
        selectedReservation.value = updatedReservation;
      }

      // Show success message
      Get.snackbar(
        'Success',
        'Reservation status updated successfully',
        backgroundColor: ColorTheme.success.withValues(alpha: 0.1),
        colorText: ColorTheme.success,
      );
    } catch (e) {
      // Show error message
      Get.snackbar(
        'Error',
        'Failed to update reservation status',
        backgroundColor: ColorTheme.error.withValues(alpha: 0.1),
        colorText: ColorTheme.error,
      );
      _logger.error('Error updating reservation status: $e');
    } finally {
      isStatusUpdating.value = false;
    }
  }

  // Create manual reservation
  Future<void> createManualReservation({
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
      isFormSubmitting.value = true;

      final response = await _reservationRepository.createManualReservation(
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

      if (response['reservation'] != null) {
        // Add to beginning of list if successful
        reservationList.insert(0, response['reservation']);
        totalItems.value++;

        // Show success message
        Get.snackbar(
          'Success',
          'Manual reservation created successfully',
          backgroundColor: ColorTheme.success.withValues(alpha: 0.1),
          colorText: ColorTheme.success,
        );

        // Navigate back
        Get.back();
      }
    } on DioException catch (e) {
      String errorMsg = 'Failed to create manual reservation';

      if (e.response?.statusCode == 409) {
        errorMsg = 'Session has already been booked by someone else';
      } else if (e.response?.data != null &&
          e.response!.data['message'] != null) {
        errorMsg = e.response!.data['message'];
      }

      // Show error message
      Get.snackbar(
        'Error',
        errorMsg,
        backgroundColor: ColorTheme.error.withValues(alpha: 0.1),
        colorText: ColorTheme.error,
      );
      _logger.error('Error creating manual reservation: $e');
    } catch (e) {
      // Show error message
      Get.snackbar(
        'Error',
        'Failed to create manual reservation',
        backgroundColor: ColorTheme.error.withValues(alpha: 0.1),
        colorText: ColorTheme.error,
      );
      _logger.error('Error creating manual reservation: $e');
    } finally {
      isFormSubmitting.value = false;
    }
  }

  // Upload payment proof for manual reservation
  Future<void> uploadManualPaymentProof(
    String reservationId,
    File paymentProofFile, {
    String? notes,
  }) async {
    try {
      isPaymentUploading.value = true;

      final payment = await _reservationRepository.uploadManualPaymentProof(
        reservationId,
        paymentProofFile,
        notes: notes,
      );

      // Refresh the reservation list to show updated payment info
      await refreshData();

      // Show success message
      Get.snackbar(
        'Success',
        'Payment proof uploaded successfully',
        backgroundColor: ColorTheme.success.withValues(alpha: 0.1),
        colorText: ColorTheme.success,
      );
    } catch (e) {
      // Show error message
      Get.snackbar(
        'Error',
        'Failed to upload payment proof',
        backgroundColor: ColorTheme.error.withValues(alpha: 0.1),
        colorText: ColorTheme.error,
      );
      _logger.error('Error uploading payment proof: $e');
    } finally {
      isPaymentUploading.value = false;
    }
  }

  // Verify manual payment
  Future<void> verifyManualPayment(String paymentId, bool isVerified) async {
    try {
      final payment = await _reservationRepository.verifyManualPayment(
        paymentId,
        isVerified,
      );

      // Refresh the reservation list to show updated payment status
      await refreshData();

      // Show success message
      Get.snackbar(
        'Success',
        isVerified
            ? 'Payment verified successfully'
            : 'Payment verification removed',
        backgroundColor: ColorTheme.success.withValues(alpha: 0.1),
        colorText: ColorTheme.success,
      );
    } catch (e) {
      // Show error message
      Get.snackbar(
        'Error',
        'Failed to verify payment',
        backgroundColor: ColorTheme.error.withValues(alpha: 0.1),
        colorText: ColorTheme.error,
      );
      _logger.error('Error verifying payment: $e');
    }
  }

  // Get reservation analytics
  Future<void> fetchReservationAnalytics(
    DateTime startDate,
    DateTime endDate,
  ) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      final analytics = await _reservationRepository.getReservationAnalytics(
        startDate,
        endDate,
      );

      reservationAnalytics.value = analytics;
    } catch (e) {
      errorMessage.value = 'Failed to load reservation analytics.';
      _logger.error('Error fetching reservation analytics: $e');
    } finally {
      isLoading.value = false;
    }
  }

  // Helper methods for UI
  String getStatusDisplayName(String status) {
    switch (status.toUpperCase()) {
      case 'PENDING':
        return 'Pending';
      case 'CONFIRMED':
        return 'Confirmed';
      case 'IN_PROGRESS':
        return 'In Progress';
      case 'COMPLETED':
        return 'Completed';
      case 'CANCELLED':
        return 'Cancelled';
      case 'EXPIRED':
        return 'Expired';
      default:
        return status;
    }
  }

  bool canUpdateStatus(String currentStatus, String newStatus) {
    // Define allowed status transitions
    final allowedTransitions = <String, List<String>>{
      'PENDING': ['CONFIRMED', 'CANCELLED'],
      'CONFIRMED': ['IN_PROGRESS', 'CANCELLED'],
      'IN_PROGRESS': ['COMPLETED', 'CANCELLED'],
      'COMPLETED': <String>[], // Cannot change from completed
      'CANCELLED': <String>[], // Cannot change from cancelled
      'EXPIRED': <String>[], // Cannot change from expired
    };

    return allowedTransitions[currentStatus.toUpperCase()]?.contains(
          newStatus.toUpperCase(),
        ) ??
        false;
  }

  List<String> getAvailableStatusTransitions(String currentStatus) {
    final allowedTransitions = <String, List<String>>{
      'PENDING': ['CONFIRMED', 'CANCELLED'],
      'CONFIRMED': ['IN_PROGRESS', 'CANCELLED'],
      'IN_PROGRESS': ['COMPLETED', 'CANCELLED'],
      'COMPLETED': <String>[],
      'CANCELLED': <String>[],
      'EXPIRED': <String>[],
    };

    return allowedTransitions[currentStatus.toUpperCase()] ?? <String>[];
  }

  // Clear selected reservation
  void clearSelectedReservation() {
    selectedReservation.value = null;
  }

  // Dispose method
  @override
  void onClose() {
    // Clear all observables
    reservationList.clear();
    selectedReservation.value = null;
    reservationAnalytics.clear();
    super.onClose();
  }
}
