// lib/features/reservation/controllers/reservation_controller.dart
import 'package:get/get.dart';
import 'dart:io';
import 'package:emababyspa/data/models/reservation.dart';
import 'package:emababyspa/data/models/payment.dart'; // Added for type hinting
import 'package:emababyspa/data/models/payment_method.dart'; // Added
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
  final RxList<dynamic> reservationList =
      <dynamic>[].obs; // Existing: Stays dynamic for now
  final RxBool isLoading = false.obs;
  final RxBool isFormSubmitting = false.obs;
  final RxBool isStatusUpdating = false.obs;
  final RxBool isPaymentUploading = false.obs;
  final RxString errorMessage = ''.obs;
  final Rx<Reservation?> selectedReservation = Rx<Reservation?>(null);
  final RxMap<String, dynamic> reservationAnalytics = <String, dynamic>{}.obs;

  // Filter state for fetchFilteredReservations
  final RxString selectedStatus = ''.obs;
  final Rx<DateTime?> selectedStartDate = Rx<DateTime?>(null);
  final Rx<DateTime?> selectedEndDate = Rx<DateTime?>(null);
  final RxString selectedStaffId = ''.obs;
  final RxInt currentPage = 1.obs;
  final RxInt totalPages = 1.obs;
  final RxInt totalItems = 0.obs;
  final RxBool hasMoreData = true.obs;

  // --- NEW: State for Upcoming Reservations (General) ---
  final RxList<Reservation> upcomingReservationList = <Reservation>[].obs;
  final RxBool isLoadingUpcoming = false.obs;
  final RxString upcomingErrorMessage = ''.obs;
  final RxInt upcomingCurrentPage = 1.obs;
  final RxInt upcomingTotalPages = 1.obs;
  final RxInt upcomingTotalItems = 0.obs;
  final RxBool upcomingHasMoreData = true.obs;
  final RxString upcomingSelectedStaffId =
      ''.obs; // If filtering by staff is needed for this view

  // --- NEW: State for Upcoming Reservations (For a Specific Day) ---
  final RxList<Reservation> upcomingDayReservationList = <Reservation>[].obs;
  final RxBool isLoadingUpcomingDay = false.obs;
  final RxString upcomingDayErrorMessage = ''.obs;
  final RxInt upcomingDayCurrentPage = 1.obs;
  final RxInt upcomingDayTotalPages = 1.obs;
  final RxInt upcomingDayTotalItems = 0.obs;
  final RxBool upcomingDayHasMoreData = true.obs;

  // --- NEW: State for Owner Payment Methods ---
  final RxList<PaymentMethodModel> ownerPaymentMethods =
      <PaymentMethodModel>[].obs;
  final RxBool isLoadingPaymentMethods = false.obs;
  final RxString paymentMethodsErrorMessage = ''.obs;

  // --- NEW: State for Owner Payment Details of a Reservation ---
  final Rx<Payment?> selectedPaymentDetails = Rx<Payment?>(null);
  final Rx<Reservation?> reservationForPaymentDetails = Rx<Reservation?>(null);
  final RxBool isLoadingPaymentDetails = false.obs;
  final RxString paymentDetailsErrorMessage = ''.obs;

  // --- NEW: State for Updating Manual Reservation Payment Status ---
  final RxBool isUpdatingManualPayment = false.obs;

  // Fetch filtered reservations for owner
  Future<void> fetchFilteredReservations({
    bool isRefresh = false,
    int limit = 10,
  }) async {
    try {
      if (isRefresh) {
        currentPage.value = 1;
        hasMoreData.value = true;
        reservationList.clear(); // Clear list on refresh
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

      // Assuming response['data'] is List<Reservation> from repository
      final List<Reservation> newReservations =
          response['data'] as List<Reservation>;

      if (isRefresh || currentPage.value == 1) {
        // Convert to JSON if reservationList remains dynamic, or assign directly if it becomes RxList<Reservation>
        reservationList.value = newReservations.map((r) => r.toJson()).toList();
      } else {
        reservationList.addAll(newReservations.map((r) => r.toJson()).toList());
      }

      totalPages.value = response['pagination']?['totalPages'] ?? 1;
      totalItems.value = response['pagination']?['totalItems'] ?? 0;
      hasMoreData.value = currentPage.value < totalPages.value;
    } catch (e) {
      errorMessage.value = 'Failed to load reservations. Please try again.';
      _logger.error('Error fetching filtered reservations: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> loadMoreReservations() async {
    if (hasMoreData.value && !isLoading.value) {
      currentPage.value++;
      await fetchFilteredReservations();
    }
  }

  Future<void> refreshData() async {
    await fetchFilteredReservations(isRefresh: true);
  }

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

  Future<void> clearFilters() async {
    selectedStatus.value = '';
    selectedStartDate.value = null;
    selectedEndDate.value = null;
    selectedStaffId.value = '';
    await fetchFilteredReservations(isRefresh: true);
  }

  Future<void> fetchReservationById(String id) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      selectedReservation.value = null;
      selectedPaymentDetails.value = null;

      if (id.isEmpty) {
        throw Exception("Reservation ID is required");
      }

      // 1. CUKUP SATU PANGGILAN API INI SAJA
      final reservation = await _reservationRepository.getReservationById(id);

      // 2. ATUR KEDUA STATE DARI SATU SUMBER
      selectedReservation.value = reservation;
      selectedPaymentDetails.value = reservation.payment;
    } catch (e) {
      errorMessage.value =
          'Failed to fetch reservation details: ${e.toString()}';
      _logger.error('Error fetching reservation by ID: $e');
      selectedReservation.value = null;
      selectedPaymentDetails.value = null;
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> updateReservationStatus(String id, String status) async {
    try {
      isStatusUpdating.value = true;
      final updatedReservation = await _reservationRepository
          .updateReservationStatus(id, status);

      final index = reservationList.indexWhere((item) {
        if (item is Map<String, dynamic>) return item['id'] == id;
        if (item is Reservation) {
          return item.id == id; // Handle if list becomes typed
        }
        return false;
      });

      if (index != -1) {
        reservationList[index] =
            updatedReservation
                .toJson(); // Assuming it needs to be map for dynamic list
        reservationList.refresh();
      }

      if (selectedReservation.value?.id == id) {
        selectedReservation.value = updatedReservation;
      }
      Get.snackbar(
        'Success',
        'Reservation status updated successfully',
        backgroundColor: ColorTheme.success.withValues(alpha: 0.1),
        colorText: ColorTheme.success,
      );
    } catch (e) {
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

      final Map<String, dynamic> response = await _reservationRepository
          .createManualReservation(
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

      // Validate the structure of response
      if (response['reservation'] != null &&
          response['reservation'] is Reservation &&
          response['payment'] != null &&
          response['payment'] is Payment &&
          response['customer'] != null) {
        // Directly use the objects without re-parsing them.
        final Reservation reservation = response['reservation'];
        final Payment payment = response['payment'];

        Get.snackbar(
          'Success',
          'Manual reservation created successfully',
          backgroundColor: ColorTheme.success.withValues(alpha: 0.1),
          colorText: ColorTheme.success,
        );

        // Return the map with the correct object types.
        return {
          'reservation': reservation,
          'payment': payment,
          'customer': response['customer'],
        };
      } else {
        // If the structure from the provider isn't what we expect
        _logger.error(
          'Repository: createManualReservation - provider response structure not as expected: $response (Owner)',
        );
        throw Exception(
          'Failed to parse reservation creation response from server. Unexpected structure.',
        );
      }
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
      rethrow; // Rethrow the original DioException if not specifically handled
    } catch (e) {
      _logger.error('Repository error creating manual reservation: $e (Owner)');
      // Rethrow the caught exception (could be the custom one from above or others)
      rethrow;
    }
  }

  Future<void> uploadManualPaymentProof(
    String reservationId,
    File paymentProofFile, {
    String? notes,
  }) async {
    try {
      isPaymentUploading.value = true;
      // The repository now returns a Payment object.
      // We might not directly use the returned Payment object here unless we want to update a specific part of the UI immediately with it.
      await _reservationRepository.uploadManualPaymentProof(
        reservationId,
        paymentProofFile,
        notes: notes,
      );
      await refreshData(); // Refresh the main list to show changes
      // If the selectedReservation is the one affected, you might want to re-fetch it specifically
      if (selectedReservation.value?.id == reservationId) {
        await fetchReservationById(reservationId);
      }
      Get.snackbar(
        'Success',
        'Payment proof uploaded successfully',
        backgroundColor: ColorTheme.success.withValues(alpha: 0.1),
        colorText: ColorTheme.success,
      );
    } catch (e) {
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

  Future<void> updateExistingPaymentProof(
    String reservationId,
    File paymentProofFile,
  ) async {
    try {
      isPaymentUploading.value = true;
      await _reservationRepository.updateManualPaymentProof(
        reservationId,
        paymentProofFile,
      );
      await fetchReservationById(reservationId); // Refresh data
      Get.snackbar(
        'Success',
        'Payment proof updated successfully. Please verify again.',
        backgroundColor: ColorTheme.success.withValues(alpha: 0.1),
        colorText: ColorTheme.success,
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to update payment proof: ${e.toString()}',
        backgroundColor: ColorTheme.error.withValues(alpha: 0.1),
        colorText: ColorTheme.error,
      );
      _logger.error('Error updating payment proof: $e');
    } finally {
      isPaymentUploading.value = false;
    }
  }

  Future<void> verifyManualPayment(String paymentId, bool isVerified) async {
    try {
      isStatusUpdating.value = true;
      await _reservationRepository.verifyManualPayment(paymentId, isVerified);

      // Refresh the details of the currently selected reservation
      if (selectedReservation.value != null) {
        await fetchReservationById(selectedReservation.value!.id);
      }
      await refreshData(); // Also refresh the main list

      Get.snackbar(
        'Success',
        isVerified
            ? 'Payment verified successfully and reservation confirmed.'
            : 'Payment rejected and reservation cancelled.',
        backgroundColor: ColorTheme.success.withAlpha(25),
        colorText: ColorTheme.success,
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to verify payment. Please try again. Error: $e',
        backgroundColor: ColorTheme.error.withAlpha(25),
        colorText: ColorTheme.error,
      );
      _logger.error('Error verifying payment: $e');
    } finally {
      isStatusUpdating.value = false;
    }
  }

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
      reservationAnalytics.clear();
    } finally {
      isLoading.value = false;
    }
  }

  // Get upcoming reservations for Owner
  Future<void> fetchUpcomingReservations({
    String? staffId,
    bool isRefresh = false,
    int limit = 10,
  }) async {
    try {
      if (isRefresh) {
        upcomingCurrentPage.value = 1;
        upcomingHasMoreData.value = true;
        upcomingReservationList.clear();
      }

      if (!upcomingHasMoreData.value && !isRefresh) return;

      isLoadingUpcoming.value = true;
      upcomingErrorMessage.value = '';

      final response = await _reservationRepository.getUpcomingReservations(
        staffId:
            staffId ??
            (upcomingSelectedStaffId.value.isEmpty
                ? null
                : upcomingSelectedStaffId.value),
        page: upcomingCurrentPage.value,
        limit: limit,
      );

      final List<Reservation> newReservations =
          response['data'] as List<Reservation>;
      if (isRefresh || upcomingCurrentPage.value == 1) {
        upcomingReservationList.assignAll(newReservations);
      } else {
        upcomingReservationList.addAll(newReservations);
      }

      upcomingTotalPages.value = response['pagination']?['totalPages'] ?? 1;
      upcomingTotalItems.value = response['pagination']?['totalItems'] ?? 0;
      upcomingHasMoreData.value =
          upcomingCurrentPage.value < upcomingTotalPages.value;
    } catch (e) {
      upcomingErrorMessage.value = 'Failed to load upcoming reservations.';
      _logger.error('Error fetching upcoming reservations: $e');
    } finally {
      isLoadingUpcoming.value = false;
    }
  }

  Future<void> loadMoreUpcomingReservations({String? staffId}) async {
    if (upcomingHasMoreData.value && !isLoadingUpcoming.value) {
      upcomingCurrentPage.value++;
      await fetchUpcomingReservations(staffId: staffId);
    }
  }

  Future<void> refreshUpcomingReservations({String? staffId}) async {
    upcomingSelectedStaffId.value = staffId ?? '';
    await fetchUpcomingReservations(staffId: staffId, isRefresh: true);
  }

  // Get upcoming reservations for a specific day for Owner Dashboard
  Future<void> fetchUpcomingReservationsForDay({
    required DateTime date,
    bool isRefresh = false,
    int limit = 10,
  }) async {
    try {
      if (isRefresh) {
        upcomingDayCurrentPage.value = 1;
        upcomingDayHasMoreData.value = true;
        upcomingDayReservationList.clear();
      }

      if (!upcomingDayHasMoreData.value && !isRefresh) return;

      isLoadingUpcomingDay.value = true;
      upcomingDayErrorMessage.value = '';

      final response = await _reservationRepository
          .getUpcomingReservationsForDay(
            date: date,
            page: upcomingDayCurrentPage.value,
            limit: limit,
          );

      final List<Reservation> newReservations =
          response['data'] as List<Reservation>;
      if (isRefresh || upcomingDayCurrentPage.value == 1) {
        upcomingDayReservationList.assignAll(newReservations);
      } else {
        upcomingDayReservationList.addAll(newReservations);
      }

      upcomingDayTotalPages.value = response['pagination']?['totalPages'] ?? 1;
      upcomingDayTotalItems.value = response['pagination']?['totalItems'] ?? 0;
      upcomingDayHasMoreData.value =
          upcomingDayCurrentPage.value < upcomingDayTotalPages.value;
    } catch (e) {
      upcomingDayErrorMessage.value =
          'Failed to load reservations for the day.';
      _logger.error('Error fetching upcoming reservations for day $date: $e');
    } finally {
      isLoadingUpcomingDay.value = false;
    }
  }

  Future<void> loadMoreUpcomingReservationsForDay({
    required DateTime date,
  }) async {
    if (upcomingDayHasMoreData.value && !isLoadingUpcomingDay.value) {
      upcomingDayCurrentPage.value++;
      await fetchUpcomingReservationsForDay(date: date);
    }
  }

  Future<void> refreshUpcomingReservationsForDay({
    required DateTime date,
  }) async {
    await fetchUpcomingReservationsForDay(date: date, isRefresh: true);
  }

  // Get Payment Methods for Owner
  Future<void> fetchOwnerPaymentMethods() async {
    try {
      isLoadingPaymentMethods.value = true;
      paymentMethodsErrorMessage.value = '';
      ownerPaymentMethods.value =
          await _reservationRepository.getOwnerPaymentMethods();
    } catch (e) {
      paymentMethodsErrorMessage.value = 'Failed to load payment methods.';
      _logger.error('Error fetching owner payment methods: $e');
      ownerPaymentMethods.clear();
    } finally {
      isLoadingPaymentMethods.value = false;
    }
  }

  Future<void> updateReservationDetails({
    required String id,
    required String customerName,
    required String babyName,
    required int babyAge,
    required String parentNames,
    required String notes,
  }) async {
    try {
      isFormSubmitting.value = true;
      errorMessage.value = '';

      final Map<String, dynamic> updateData = {
        'customerName': customerName,
        'babyName': babyName,
        'babyAge': babyAge,
        'parentNames': parentNames,
        'notes': notes,
      };

      final updatedReservation = await _reservationRepository
          .updateReservationDetails(id, updateData);

      // Update state lokal
      selectedReservation.value = updatedReservation;

      // Refresh daftar utama jika perlu
      final index = reservationList.indexWhere((item) => item['id'] == id);
      if (index != -1) {
        reservationList[index] = updatedReservation.toJson();
        reservationList.refresh();
      }

      Get.back(); // Kembali ke halaman detail setelah sukses
      Get.snackbar(
        'Success',
        'Reservation details updated successfully.',
        backgroundColor: ColorTheme.success.withValues(alpha: 0.1),
        colorText: ColorTheme.success,
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to update reservation: ${e.toString()}',
        backgroundColor: ColorTheme.error.withValues(alpha: 0.1),
        colorText: ColorTheme.error,
      );
      _logger.error('Error updating reservation details: $e');
    } finally {
      isFormSubmitting.value = false;
    }
  }

  Future<void> confirmManualReservationWithProof(
    String reservationId,
    File paymentProofFile,
  ) async {
    try {
      isPaymentUploading.value = true;
      await _reservationRepository.confirmManualWithProof(
        reservationId,
        paymentProofFile,
      );
      await fetchReservationById(reservationId); // Langsung refresh data
      Get.snackbar(
        'Success',
        'Reservation has been confirmed successfully.',
        backgroundColor: ColorTheme.success.withValues(alpha: 0.1),
        colorText: ColorTheme.success,
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to confirm reservation: ${e.toString()}',
        backgroundColor: ColorTheme.error.withValues(alpha: 0.1),
        colorText: ColorTheme.error,
      );
      _logger.error('Error confirming reservation with proof: $e');
    } finally {
      isPaymentUploading.value = false;
    }
  }

  // Update Manual Reservation Payment Status by Owner
  Future<bool> updateManualReservationPaymentStatus(
    String reservationId, {
    String paymentMethod = 'CASH',
    String? notes,
  }) async {
    try {
      isUpdatingManualPayment.value = true;
      final response = await _reservationRepository
          .updateManualReservationPaymentStatus(
            reservationId,
            paymentMethod: paymentMethod,
            notes: notes,
          );

      Get.snackbar(
        'Success',
        response['message'] as String? ??
            'Payment status updated successfully!',
        backgroundColor: ColorTheme.success.withAlpha(25),
        colorText: ColorTheme.success,
      );

      // Refresh data
      await fetchReservationById(reservationId); // Refresh details
      await refreshData(); // Refresh the main list

      return true;
    } catch (e) {
      String errorMessage = 'Failed to update payment status.';
      if (e is DioException && e.response?.data is Map) {
        errorMessage = e.response?.data['message'] ?? errorMessage;
      } else if (e is Exception) {
        errorMessage = e.toString().replaceFirst("Exception: ", "");
      }
      Get.snackbar(
        'Error',
        errorMessage,
        backgroundColor: ColorTheme.error.withAlpha(25),
        colorText: ColorTheme.error,
      );
      _logger.error(
        'Error updating manual reservation payment status for $reservationId: $e',
      );
      return false;
    } finally {
      isUpdatingManualPayment.value = false;
    }
  }

  // --- NEW METHODS END HERE ---

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
    final allowedTransitions = <String, List<String>>{
      'PENDING': ['CONFIRMED', 'CANCELLED'],
      'CONFIRMED': ['IN_PROGRESS', 'CANCELLED'],
      'IN_PROGRESS': ['COMPLETED', 'CANCELLED'],
      'COMPLETED': <String>[],
      'CANCELLED': <String>[],
      'EXPIRED': <String>[],
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

  void clearSelectedReservation() {
    selectedReservation.value = null;
  }

  void clearSelectedPaymentDetails() {
    selectedPaymentDetails.value = null;
    reservationForPaymentDetails.value = null;
  }

  @override
  void onClose() {
    // Clear existing observables
    reservationList.clear();
    selectedReservation.value = null;
    reservationAnalytics.clear();

    // Clear new observables
    upcomingReservationList.clear();
    upcomingDayReservationList.clear();
    ownerPaymentMethods.clear();
    selectedPaymentDetails.value = null;
    reservationForPaymentDetails.value = null;

    // Clear filter/pagination states
    selectedStatus.value = '';
    selectedStartDate.value = null;
    selectedEndDate.value = null;
    selectedStaffId.value = '';
    currentPage.value = 1;
    totalPages.value = 1;
    totalItems.value = 0;
    hasMoreData.value = true;

    upcomingCurrentPage.value = 1;
    upcomingTotalPages.value = 1;
    upcomingTotalItems.value = 0;
    upcomingHasMoreData.value = true;
    upcomingSelectedStaffId.value = '';

    upcomingDayCurrentPage.value = 1;
    upcomingDayTotalPages.value = 1;
    upcomingDayTotalItems.value = 0;
    upcomingDayHasMoreData.value = true;

    super.onClose();
  }
}
