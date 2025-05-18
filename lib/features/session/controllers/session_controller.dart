// lib/features/session/controllers/session_controller.dart
import 'package:get/get.dart';
import 'package:emababyspa/data/repository/session_repository.dart';
import 'package:emababyspa/data/models/session.dart';
import 'package:emababyspa/data/api/api_exception.dart';
import 'package:emababyspa/utils/logger_utils.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class SessionController extends GetxController {
  final SessionRepository repository;
  final LoggerUtils _logger = LoggerUtils();

  // Observable variables
  final RxBool isLoading = false.obs;
  final RxBool isSubmitting = false.obs;
  final RxString errorMessage = ''.obs;
  final RxList<Session> sessions = <Session>[].obs;
  final Rx<Session?> currentSession = Rx<Session?>(null);
  final RxList<Session> availableSessions = <Session>[].obs;

  // Date selection
  final Rx<DateTime> selectedDate = DateTime.now().obs;

  // Service duration in minutes (if applicable)
  final RxInt serviceDuration = 0.obs;

  // Staff filter
  final RxString selectedStaffId = ''.obs;

  // Booking status filter - use Rx<bool?> for nullable boolean
  final Rx<bool?> filterIsBooked = Rx<bool?>(null);

  SessionController({required this.repository});

  @override
  void onInit() {
    super.onInit();
    // Initial data load
    fetchSessions();
  }

  // Format date to ISO string (YYYY-MM-DD)
  String _formatDate(DateTime date) {
    return DateFormat('yyyy-MM-dd').format(date);
  }

  // Set selected date
  void setDate(DateTime date) {
    selectedDate.value = date;
    // Refresh data based on new date
    fetchAvailableSessions();
  }

  // Set service duration
  void setServiceDuration(int duration) {
    serviceDuration.value = duration;
    // Refresh available sessions with new duration
    fetchAvailableSessions();
  }

  // Set staff filter
  void setStaffFilter(String staffId) {
    selectedStaffId.value = staffId;
    // Reload sessions with staff filter
    fetchSessions();
  }

  // Set booking status filter
  void setBookingStatusFilter(bool? isBooked) {
    filterIsBooked.value = isBooked;
    // Reload sessions with booking status filter
    fetchSessions();
  }

  // Clear error message
  void clearError() {
    errorMessage.value = '';
  }

  // Error handling helper
  void _handleError(dynamic error, String defaultMessage) {
    if (error is ApiException) {
      errorMessage.value = error.message;
      _logger.error('$defaultMessage: ${error.message}');
      Get.snackbar(
        'Gagal',
        error.message,
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
    } else {
      errorMessage.value = defaultMessage;
      _logger.error('Unexpected error: $error');
      Get.snackbar(
        'Gagal',
        defaultMessage,
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  // CRUD Operations

  // Fetch all sessions with optional filters
  Future<void> fetchSessions({
    bool? isBooked,
    String? staffId,
    String? timeSlotId,
    String? date,
  }) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      // Use filters from parameters or stored filter values
      final sessionsList = await repository.getAllSessions(
        isBooked: isBooked ?? filterIsBooked.value,
        staffId:
            staffId ??
            (selectedStaffId.value.isNotEmpty ? selectedStaffId.value : null),
        timeSlotId: timeSlotId,
        date: date ?? _formatDate(selectedDate.value),
      );

      sessions.value = sessionsList;
    } catch (e) {
      _handleError(e, 'Gagal mengambil data sesi');
    } finally {
      isLoading.value = false;
    }
  }

  // Create a new session
  Future<bool> createSession({
    required String timeSlotId,
    required String staffId,
    bool isBooked = false,
  }) async {
    try {
      isSubmitting.value = true;
      clearError();

      final session = await repository.createSession(
        timeSlotId: timeSlotId,
        staffId: staffId,
        isBooked: isBooked,
      );

      // Add to list if it matches current filters
      if (_matchesCurrentFilters(session)) {
        sessions.add(session);
      }

      currentSession.value = session;
      _showSuccessSnackbar('Sesi berhasil dibuat');
      return true;
    } catch (e) {
      _handleError(e, 'Terjadi kesalahan saat membuat sesi');
      return false;
    } finally {
      isSubmitting.value = false;
    }
  }

  // Helper for success messages
  void _showSuccessSnackbar(String message) {
    Get.snackbar(
      'Berhasil',
      message,
      backgroundColor: Colors.green,
      colorText: Colors.white,
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  // Check if session matches current filters
  bool _matchesCurrentFilters(Session session) {
    // Check staff filter
    if (selectedStaffId.value.isNotEmpty &&
        session.staffId != selectedStaffId.value) {
      return false;
    }

    // Check booking status filter
    if (filterIsBooked.value != null &&
        session.isBooked != filterIsBooked.value) {
      return false;
    }

    // Could add more filters like date, etc.
    return true;
  }

  // Create multiple sessions at once
  Future<bool> createManySessions({
    required List<Map<String, dynamic>> sessionsList,
  }) async {
    try {
      isSubmitting.value = true;
      clearError();

      final newSessions = await repository.createManySessions(
        sessions: sessionsList,
      );

      // Add matching sessions to the current list
      final matchingSessions =
          newSessions.where(_matchesCurrentFilters).toList();
      if (matchingSessions.isNotEmpty) {
        sessions.addAll(matchingSessions);
      }

      _showSuccessSnackbar('Semua sesi berhasil dibuat');
      return true;
    } catch (e) {
      _handleError(e, 'Terjadi kesalahan saat membuat beberapa sesi');
      return false;
    } finally {
      isSubmitting.value = false;
    }
  }

  // Get session by ID
  Future<void> getSessionById(String id) async {
    try {
      isLoading.value = true;
      clearError();

      final session = await repository.getSessionById(id);
      currentSession.value = session;
    } catch (e) {
      _handleError(e, 'Terjadi kesalahan saat mengambil detail sesi');
    } finally {
      isLoading.value = false;
    }
  }

  // Update session in the list
  void _updateSessionInList(Session updatedSession) {
    final index = sessions.indexWhere((s) => s.id == updatedSession.id);
    if (index != -1) {
      if (_matchesCurrentFilters(updatedSession)) {
        sessions[index] = updatedSession;
      } else {
        // Remove if it no longer matches filters
        sessions.removeAt(index);
      }
    } else if (_matchesCurrentFilters(updatedSession)) {
      // Add if it now matches filters
      sessions.add(updatedSession);
    }

    // Update current session if it's the one being viewed
    if (currentSession.value?.id == updatedSession.id) {
      currentSession.value = updatedSession;
    }
  }

  // Update a session
  Future<bool> updateSession({
    required String id,
    String? timeSlotId,
    String? staffId,
    bool? isBooked,
  }) async {
    try {
      isSubmitting.value = true;
      clearError();

      final updatedSession = await repository.updateSession(
        id: id,
        timeSlotId: timeSlotId,
        staffId: staffId,
        isBooked: isBooked,
      );

      _updateSessionInList(updatedSession);
      _showSuccessSnackbar('Sesi berhasil diperbarui');
      return true;
    } catch (e) {
      _handleError(e, 'Terjadi kesalahan saat memperbarui sesi');
      return false;
    } finally {
      isSubmitting.value = false;
    }
  }

  // Update session booking status
  Future<bool> updateSessionBookingStatus(String id, bool isBooked) async {
    try {
      isSubmitting.value = true;
      clearError();

      final updatedSession = await repository.updateSessionBookingStatus(
        id,
        isBooked,
      );

      _updateSessionInList(updatedSession);
      _showSuccessSnackbar(
        isBooked ? 'Sesi berhasil dipesan' : 'Sesi berhasil dibatalkan',
      );
      return true;
    } catch (e) {
      _handleError(e, 'Terjadi kesalahan saat memperbarui status pemesanan');
      return false;
    } finally {
      isSubmitting.value = false;
    }
  }

  // Delete a session
  Future<bool> deleteSession(String id) async {
    try {
      isSubmitting.value = true;
      clearError();

      final success = await repository.deleteSession(id);

      if (success) {
        // Remove from the sessions list
        sessions.removeWhere((s) => s.id == id);

        // Clear current session if it was the one deleted
        if (currentSession.value?.id == id) {
          currentSession.value = null;
        }

        _showSuccessSnackbar('Sesi berhasil dihapus');
      }
      return success;
    } catch (e) {
      _handleError(e, 'Terjadi kesalahan saat menghapus sesi');
      return false;
    } finally {
      isSubmitting.value = false;
    }
  }

  // Get available sessions for a specific date and service duration
  Future<void> fetchAvailableSessions() async {
    try {
      isLoading.value = true;
      clearError();

      final formattedDate = _formatDate(selectedDate.value);
      final result = await repository.getAvailableSessions(
        date: formattedDate,
        duration: serviceDuration.value > 0 ? serviceDuration.value : null,
      );

      availableSessions.value = result;
    } catch (e) {
      _handleError(e, 'Terjadi kesalahan saat mengambil sesi yang tersedia');
    } finally {
      isLoading.value = false;
    }
  }

  // Get sessions by staff ID with optional date range
  Future<void> fetchSessionsByStaff(
    String staffId, {
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      isLoading.value = true;
      clearError();

      String? formattedStartDate;
      String? formattedEndDate;

      if (startDate != null) {
        formattedStartDate = _formatDate(startDate);
      }

      if (endDate != null) {
        formattedEndDate = _formatDate(endDate);
      }

      final result = await repository.getSessionsByStaff(
        staffId,
        startDate: formattedStartDate,
        endDate: formattedEndDate,
      );

      // Update the selected staff ID for filtering
      selectedStaffId.value = staffId;
      sessions.value = result;
    } catch (e) {
      _handleError(e, 'Terjadi kesalahan saat mengambil jadwal staf');
    } finally {
      isLoading.value = false;
    }
  }

  // Get sessions for a specific date
  Future<void> fetchSessionsByDate(DateTime date) async {
    try {
      isLoading.value = true;
      clearError();

      final formattedDate = _formatDate(date);
      selectedDate.value = date; // Update selected date first

      final result = await repository.getAllSessions(
        date: formattedDate,
        staffId:
            selectedStaffId.value.isNotEmpty ? selectedStaffId.value : null,
        isBooked: filterIsBooked.value,
      );

      sessions.value = result;
    } catch (e) {
      _handleError(
        e,
        'Terjadi kesalahan saat mengambil sesi untuk tanggal tersebut',
      );
    } finally {
      isLoading.value = false;
    }
  }

  // Reset all filters
  void resetFilters() {
    selectedStaffId.value = '';
    filterIsBooked.value = null;
    selectedDate.value = DateTime.now();
    fetchSessions();
  }
}
