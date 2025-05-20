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

  // Last used timeSlotId - for easier refreshing
  String? _lastTimeSlotId;

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

      // Store the timeSlotId for potential refreshes later
      if (timeSlotId != null) {
        _lastTimeSlotId = timeSlotId;
      }

      // Use filters from parameters or stored filter values
      final sessionsList = await repository.getAllSessions(
        isBooked: isBooked ?? filterIsBooked.value,
        staffId:
            staffId ??
            (selectedStaffId.value.isNotEmpty ? selectedStaffId.value : null),
        timeSlotId: timeSlotId ?? _lastTimeSlotId,
        date: date ?? _formatDate(selectedDate.value),
      );

      sessions.value = sessionsList;
      update(); // Ensure UI updates
    } catch (e) {
      _handleError(e, 'Gagal mengambil data sesi');
    } finally {
      isLoading.value = false;
    }
  }

  // Refresh data based on last used parameters
  Future<bool> refreshData({String? specificTimeSlotId}) async {
    try {
      isLoading.value = true;
      clearError();

      // Use specified timeSlotId or fallback to last used
      final timeSlotId = specificTimeSlotId ?? _lastTimeSlotId;

      // Refresh sessions data - this is the primary functionality we need
      await fetchSessions(
        timeSlotId: timeSlotId,
        staffId:
            selectedStaffId.value.isNotEmpty ? selectedStaffId.value : null,
        isBooked: filterIsBooked.value,
        date: _formatDate(selectedDate.value),
      );

      // Signal success
      Get.snackbar(
        'Berhasil',
        'Data berhasil disegarkan',
        backgroundColor: Colors.green.shade100,
        colorText: Colors.green.shade900,
        snackPosition: SnackPosition.TOP,
        duration: const Duration(seconds: 1),
      );

      return true;
    } catch (e) {
      _handleError(e, 'Gagal menyegarkan data');
      return false;
    } finally {
      isLoading.value = false;
      update(); // Force UI refresh
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

      // Store timeSlotId for future refreshes
      _lastTimeSlotId = timeSlotId;

      final session = await repository.createSession(
        timeSlotId: timeSlotId,
        staffId: staffId,
        isBooked: isBooked,
      );

      // Refresh all the data to ensure UI consistency
      await fetchSessions(timeSlotId: timeSlotId);

      currentSession.value = session;
      _showSuccessSnackbar('Sesi berhasil dibuat');
      update(); // Force UI update
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

      // Extract timeSlotId from first session if available (for future refreshes)
      if (sessionsList.isNotEmpty &&
          sessionsList[0].containsKey('timeSlotId')) {
        _lastTimeSlotId = sessionsList[0]['timeSlotId'];
      }

      // Refresh data completely rather than just adding to the list
      if (_lastTimeSlotId != null) {
        await fetchSessions(timeSlotId: _lastTimeSlotId);
      } else {
        await fetchSessions();
      }

      _showSuccessSnackbar('Semua sesi berhasil dibuat');
      update(); // Force UI update
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
      update(); // Force UI update
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

    update(); // Force UI update
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

      // Store timeSlotId for future refreshes if provided
      if (timeSlotId != null) {
        _lastTimeSlotId = timeSlotId;
      }

      final updatedSession = await repository.updateSession(
        id: id,
        timeSlotId: timeSlotId,
        staffId: staffId,
        isBooked: isBooked,
      );

      // Instead of just updating in the list, refresh all data if needed
      if (_lastTimeSlotId != null) {
        await fetchSessions(timeSlotId: _lastTimeSlotId);
      } else {
        _updateSessionInList(updatedSession);
      }

      _showSuccessSnackbar('Sesi berhasil diperbarui');
      update(); // Force UI update
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

      // If we know the timeSlotId, refresh all sessions for that timeslot
      if (_lastTimeSlotId != null) {
        await fetchSessions(timeSlotId: _lastTimeSlotId);
      } else {
        _updateSessionInList(updatedSession);
      }

      _showSuccessSnackbar(
        isBooked ? 'Sesi berhasil dipesan' : 'Sesi berhasil dibatalkan',
      );
      update(); // Force UI update
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

        // Refresh all sessions if needed
        if (_lastTimeSlotId != null) {
          await fetchSessions(timeSlotId: _lastTimeSlotId);
        }

        _showSuccessSnackbar('Sesi berhasil dihapus');
        update(); // Force UI update
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
      update(); // Force UI update
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
      update(); // Force UI update
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
        timeSlotId: _lastTimeSlotId,
      );

      sessions.value = result;
      update(); // Force UI update
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
    _lastTimeSlotId = null;
    fetchSessions();
  }
}
