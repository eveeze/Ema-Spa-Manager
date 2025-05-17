// lib/features/session/controllers/session_controller.dart
import 'package:get/get.dart';
import 'package:emababyspa/data/repository/session_repository.dart';
import 'package:emababyspa/data/models/session.dart';
import 'package:emababyspa/data/api/api_exception.dart';
import 'package:emababyspa/utils/logger_utils.dart';
import 'package:flutter/material.dart';

class SessionController extends GetxController {
  final SessionRepository repository;
  final LoggerUtils _logger = LoggerUtils();

  // Observable variables
  final RxBool isLoading = false.obs;
  final RxBool isSubmitting = false.obs;
  final RxString errorMessage = ''.obs;
  final RxList<Session> sessions = <Session>[].obs;
  final Rx<Session?> currentSession = Rx<Session?>(null);
  final RxList<dynamic> availableSessions = <dynamic>[].obs;

  // Date selection
  final Rx<DateTime> selectedDate = DateTime.now().obs;

  // Service duration in minutes (if applicable)
  final RxInt serviceDuration = 0.obs;

  SessionController({required this.repository});

  @override
  void onInit() {
    super.onInit();
    // Initial data load
    fetchSessions();
  }

  // Set selected date
  void setDate(DateTime date) {
    selectedDate.value = date;
    fetchAvailableSessions();
  }

  // Set service duration
  void setServiceDuration(int duration) {
    serviceDuration.value = duration;
    fetchAvailableSessions();
  }

  // Clear error message
  void clearError() {
    errorMessage.value = '';
  }

  // CRUD Operations

  // Fetch all sessions
  Future<void> fetchSessions({
    bool? isBooked,
    String? staffId,
    String? timeSlotId,
    String? date,
  }) async {
    try {
      isLoading.value = true;
      clearError();

      final result = await repository.getAllSessions(
        isBooked: isBooked,
        staffId: staffId,
        timeSlotId: timeSlotId,
        date: date,
      );

      sessions.value = result;
    } on ApiException catch (e) {
      errorMessage.value = e.message;
      _logger.error('Failed to fetch sessions: ${e.message}');
    } catch (e) {
      errorMessage.value = 'Terjadi kesalahan saat mengambil data sesi';
      _logger.error('Unexpected error fetching sessions: $e');
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

      sessions.add(session);
      currentSession.value = session;
      Get.snackbar(
        'Berhasil',
        'Sesi berhasil dibuat',
        backgroundColor: Colors.green,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
      return true;
    } on ApiException catch (e) {
      errorMessage.value = e.message;
      _logger.error('Failed to create session: ${e.message}');
      Get.snackbar(
        'Gagal',
        e.message,
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
      return false;
    } catch (e) {
      errorMessage.value = 'Terjadi kesalahan saat membuat sesi';
      _logger.error('Unexpected error creating session: $e');
      Get.snackbar(
        'Gagal',
        'Terjadi kesalahan saat membuat sesi',
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
      return false;
    } finally {
      isSubmitting.value = false;
    }
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

      sessions.addAll(newSessions);
      Get.snackbar(
        'Berhasil',
        'Semua sesi berhasil dibuat',
        backgroundColor: Colors.green,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
      return true;
    } on ApiException catch (e) {
      errorMessage.value = e.message;
      _logger.error('Failed to create multiple sessions: ${e.message}');
      Get.snackbar(
        'Gagal',
        e.message,
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
      return false;
    } catch (e) {
      errorMessage.value = 'Terjadi kesalahan saat membuat beberapa sesi';
      _logger.error('Unexpected error creating multiple sessions: $e');
      Get.snackbar(
        'Gagal',
        'Terjadi kesalahan saat membuat beberapa sesi',
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
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
    } on ApiException catch (e) {
      errorMessage.value = e.message;
      _logger.error('Failed to get session: ${e.message}');
    } catch (e) {
      errorMessage.value = 'Terjadi kesalahan saat mengambil detail sesi';
      _logger.error('Unexpected error getting session: $e');
    } finally {
      isLoading.value = false;
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

      // Update the session in the list
      final index = sessions.indexWhere((s) => s.id == id);
      if (index != -1) {
        sessions[index] = updatedSession;
      }

      currentSession.value = updatedSession;
      Get.snackbar(
        'Berhasil',
        'Sesi berhasil diperbarui',
        backgroundColor: Colors.green,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
      return true;
    } on ApiException catch (e) {
      errorMessage.value = e.message;
      _logger.error('Failed to update session: ${e.message}');
      Get.snackbar(
        'Gagal',
        e.message,
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
      return false;
    } catch (e) {
      errorMessage.value = 'Terjadi kesalahan saat memperbarui sesi';
      _logger.error('Unexpected error updating session: $e');
      Get.snackbar(
        'Gagal',
        'Terjadi kesalahan saat memperbarui sesi',
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
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

      // Update the session in the list
      final index = sessions.indexWhere((s) => s.id == id);
      if (index != -1) {
        sessions[index] = updatedSession;
      }

      currentSession.value = updatedSession;
      Get.snackbar(
        'Berhasil',
        isBooked ? 'Sesi berhasil dipesan' : 'Sesi berhasil dibatalkan',
        backgroundColor: Colors.green,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
      return true;
    } on ApiException catch (e) {
      errorMessage.value = e.message;
      _logger.error('Failed to update session booking status: ${e.message}');
      Get.snackbar(
        'Gagal',
        e.message,
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
      return false;
    } catch (e) {
      errorMessage.value =
          'Terjadi kesalahan saat memperbarui status pemesanan';
      _logger.error('Unexpected error updating booking status: $e');
      Get.snackbar(
        'Gagal',
        'Terjadi kesalahan saat memperbarui status pemesanan',
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
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
        sessions.removeWhere((s) => s.id == id);
        if (currentSession.value?.id == id) {
          currentSession.value = null;
        }
        Get.snackbar(
          'Berhasil',
          'Sesi berhasil dihapus',
          backgroundColor: Colors.green,
          colorText: Colors.white,
          snackPosition: SnackPosition.BOTTOM,
        );
      }
      return success;
    } on ApiException catch (e) {
      errorMessage.value = e.message;
      _logger.error('Failed to delete session: ${e.message}');
      Get.snackbar(
        'Gagal',
        e.message,
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
      return false;
    } catch (e) {
      errorMessage.value = 'Terjadi kesalahan saat menghapus sesi';
      _logger.error('Unexpected error deleting session: $e');
      Get.snackbar(
        'Gagal',
        'Terjadi kesalahan saat menghapus sesi',
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
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

      final formattedDate =
          "${selectedDate.value.year}-${selectedDate.value.month.toString().padLeft(2, '0')}-${selectedDate.value.day.toString().padLeft(2, '0')}";

      final result = await repository.getAvailableSessions(
        date: formattedDate,
        duration: serviceDuration.value > 0 ? serviceDuration.value : null,
      );

      availableSessions.value = result;
    } on ApiException catch (e) {
      errorMessage.value = e.message;
      _logger.error('Failed to fetch available sessions: ${e.message}');
    } catch (e) {
      errorMessage.value =
          'Terjadi kesalahan saat mengambil sesi yang tersedia';
      _logger.error('Unexpected error fetching available sessions: $e');
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
        formattedStartDate =
            "${startDate.year}-${startDate.month.toString().padLeft(2, '0')}-${startDate.day.toString().padLeft(2, '0')}";
      }

      if (endDate != null) {
        formattedEndDate =
            "${endDate.year}-${endDate.month.toString().padLeft(2, '0')}-${endDate.day.toString().padLeft(2, '0')}";
      }

      final result = await repository.getSessionsByStaff(
        staffId,
        startDate: formattedStartDate,
        endDate: formattedEndDate,
      );

      // Convert dynamic list to Session list if possible
      try {
        sessions.value =
            (result)
                .map((item) => Session.fromJson(item as Map<String, dynamic>))
                .toList();
      } catch (e) {
        _logger.error('Error converting staff sessions: $e');
        sessions.value = [];
      }
    } on ApiException catch (e) {
      errorMessage.value = e.message;
      _logger.error('Failed to fetch staff sessions: ${e.message}');
    } catch (e) {
      errorMessage.value = 'Terjadi kesalahan saat mengambil jadwal staf';
      _logger.error('Unexpected error fetching staff sessions: $e');
    } finally {
      isLoading.value = false;
    }
  }
}
