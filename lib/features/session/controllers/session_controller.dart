// lib/features/session/controllers/session_controller.dart
import 'package:get/get.dart';
import 'package:emababyspa/data/repository/session_repository.dart';
import 'package:emababyspa/data/models/session.dart';
import 'package:emababyspa/data/api/api_exception.dart';
import 'package:emababyspa/utils/logger_utils.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:emababyspa/common/theme/color_theme.dart';

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

  // Current context tracking - untuk mengetahui data mana yang sedang aktif
  String? _currentTimeSlotId;
  String? _currentContext; // 'schedule', 'timeslot', 'staff', etc.
  Map<String, dynamic> _lastFetchParams = {};

  // Data change listeners - untuk notifikasi antar views
  final RxBool dataChanged = false.obs;
  final RxString lastChangedOperation = ''.obs;
  final sessionsMap = <String, List<Session>>{}.obs;

  SessionController({required this.repository});

  @override
  void onInit() {
    super.onInit();
    // Initial data load
    _setContext('schedule');
    fetchSessions();
  }

  // Set current context for better data management
  void _setContext(String context, {String? timeSlotId}) {
    _currentContext = context;
    _currentTimeSlotId = timeSlotId;
  }

  // Format date to ISO string (YYYY-MM-DD)
  String _formatDate(DateTime date) {
    return DateFormat('yyyy-MM-dd').format(date);
  }

  // Notify data change untuk reactive updates
  void _notifyDataChange(String operation) {
    dataChanged.value = !dataChanged.value; // Toggle untuk trigger reaktif
    lastChangedOperation.value = operation;
    update(['sessions', 'schedule', 'timeslot']); // Update specific widgets
  }

  // Set selected date
  void setDate(DateTime date) {
    selectedDate.value = date;
    // Refresh data based on current context
    _refreshCurrentContext();
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
    _refreshCurrentContext();
  }

  // Set booking status filter
  void setBookingStatusFilter(bool? isBooked) {
    filterIsBooked.value = isBooked;
    // Reload sessions with booking status filter
    _refreshCurrentContext();
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

  // Store last fetch parameters for smart refresh
  void _storeFetchParams({
    bool? isBooked,
    String? staffId,
    String? timeSlotId,
    String? date,
  }) {
    _lastFetchParams = {
      'isBooked': isBooked ?? filterIsBooked.value,
      'staffId':
          staffId ??
          (selectedStaffId.value.isNotEmpty ? selectedStaffId.value : null),
      'timeSlotId': timeSlotId ?? _currentTimeSlotId,
      'date': date ?? _formatDate(selectedDate.value),
    };
  }

  // Refresh current context data
  Future<void> _refreshCurrentContext() async {
    switch (_currentContext) {
      case 'timeslot':
        if (_currentTimeSlotId != null) {
          await fetchSessionsByTimeSlot(_currentTimeSlotId!);
        }
        break;
      case 'staff':
        if (selectedStaffId.value.isNotEmpty) {
          await fetchSessionsByStaff(selectedStaffId.value);
        }
        break;
      case 'schedule':
      default:
        await fetchSessions();
        break;
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

      // Store parameters for future refreshes
      _storeFetchParams(
        isBooked: isBooked,
        staffId: staffId,
        timeSlotId: timeSlotId,
        date: date,
      );

      // Use filters from parameters or stored filter values
      final sessionsList = await repository.getAllSessions(
        isBooked: isBooked ?? filterIsBooked.value,
        staffId:
            staffId ??
            (selectedStaffId.value.isNotEmpty ? selectedStaffId.value : null),
        timeSlotId: timeSlotId ?? _currentTimeSlotId,
        date: date ?? _formatDate(selectedDate.value),
      );

      sessions.value = sessionsList;
      _notifyDataChange('fetch');
    } catch (e) {
      _handleError(e, 'Gagal mengambil data sesi');
    } finally {
      isLoading.value = false;
    }
  }

  // Fetch sessions by specific timeSlot (untuk timeslot view)
  Future<void> fetchSessionsByTimeSlot(String timeSlotId) async {
    _setContext('timeslot', timeSlotId: timeSlotId);
    await fetchSessions(timeSlotId: timeSlotId);
  }

  // Smart refresh - gunakan parameter yang tersimpan
  Future<bool> refreshData({String? specificTimeSlotId}) async {
    try {
      isLoading.value = true;
      clearError();

      // Update timeSlotId if specified
      if (specificTimeSlotId != null) {
        _currentTimeSlotId = specificTimeSlotId;
        _lastFetchParams['timeSlotId'] = specificTimeSlotId;
      }

      // Refresh with stored parameters
      await repository
          .getAllSessions(
            isBooked: _lastFetchParams['isBooked'],
            staffId: _lastFetchParams['staffId'],
            timeSlotId: _lastFetchParams['timeSlotId'],
            date: _lastFetchParams['date'],
          )
          .then((sessionsList) {
            sessions.value = sessionsList;
            _notifyDataChange('refresh');
          });

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
    }
  }

  // Universal refresh method - akan refresh data berdasarkan context saat ini
  Future<void> universalRefresh() async {
    await _refreshCurrentContext();
  }

  // Refresh sessions dengan timeSlotId tertentu
  Future<void> refreshSessions(String timeSlotId) async {
    try {
      isLoading.value = true;
      _currentTimeSlotId = timeSlotId;
      await fetchSessions(timeSlotId: timeSlotId);
    } catch (e) {
      _handleError(e, 'Gagal menyegarkan sesi');
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

      // Add to current list if it matches current filters
      if (_matchesCurrentFilters(session)) {
        sessions.add(session);
      }

      // Update current session and context
      currentSession.value = session;
      _currentTimeSlotId = timeSlotId;

      // Refresh data to ensure consistency
      await _refreshCurrentContext();

      _showSuccessSnackbar('Sesi berhasil dibuat');
      _notifyDataChange('create');
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

    // Check timeSlot filter
    if (_currentTimeSlotId != null &&
        session.timeSlotId != _currentTimeSlotId) {
      return false;
    }

    return true;
  }

  // Create multiple sessions at once
  Future<bool> createManySessions({
    required List<Map<String, dynamic>> sessionsList,
  }) async {
    try {
      isSubmitting.value = true;
      clearError();

      // Extract timeSlotId from first session if available
      if (sessionsList.isNotEmpty &&
          sessionsList[0].containsKey('timeSlotId')) {
        _currentTimeSlotId = sessionsList[0]['timeSlotId'];
      }

      await repository.createManySessions(sessions: sessionsList);

      // Refresh current context to get updated data
      await _refreshCurrentContext();

      _showSuccessSnackbar('Semua sesi berhasil dibuat');
      _notifyDataChange('create_many');
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
      _notifyDataChange('get_detail');
    } catch (e) {
      _handleError(e, 'Terjadi kesalahan saat mengambil detail sesi');
    } finally {
      isLoading.value = false;
    }
  }

  // Update session in the list - improved version
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

      // Update in current list
      _updateSessionInList(updatedSession);

      // Update context if timeSlotId changed
      if (timeSlotId != null) {
        _currentTimeSlotId = timeSlotId;
      }

      _showSuccessSnackbar('Sesi berhasil diperbarui');
      _notifyDataChange('update');
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

      // Update in current list
      _updateSessionInList(updatedSession);

      _showSuccessSnackbar(
        isBooked ? 'Sesi berhasil dipesan' : 'Sesi berhasil dibatalkan',
      );
      _notifyDataChange('update_booking');
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
        // Remove from current list
        sessions.removeWhere((session) => session.id == id);

        // Clear current session if it's the deleted one
        if (currentSession.value?.id == id) {
          currentSession.value = null;
        }

        Get.snackbar(
          'Berhasil',
          'Sesi berhasil dihapus',
          backgroundColor: ColorTheme.success.withValues(alpha: 0.1),
          colorText: ColorTheme.success,
        );

        _notifyDataChange('delete');
      }
      return success;
    } catch (e) {
      _handleError(e, 'Gagal menghapus sesi');
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
      _notifyDataChange('fetch_available');
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

      _setContext('staff');
      selectedStaffId.value = staffId;

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

      sessions.value = result;
      _notifyDataChange('fetch_by_staff');
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

      _setContext('schedule');
      selectedDate.value = date;

      final formattedDate = _formatDate(date);
      final result = await repository.getAllSessions(
        date: formattedDate,
        staffId:
            selectedStaffId.value.isNotEmpty ? selectedStaffId.value : null,
        isBooked: filterIsBooked.value,
        timeSlotId: _currentTimeSlotId,
      );

      sessions.value = result;
      _notifyDataChange('fetch_by_date');
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
    _currentTimeSlotId = null;
    _currentContext = 'schedule';
    _lastFetchParams.clear();
    fetchSessions();
  }

  // Method untuk dipanggil saat kembali ke schedule view
  Future<void> onReturnToSchedule() async {
    _setContext('schedule');
    await universalRefresh();
  }

  // Method untuk dipanggil saat masuk ke timeslot view
  void onEnterTimeSlotView(String timeSlotId) {
    _setContext('timeslot', timeSlotId: timeSlotId);
  }

  // Method untuk memastikan data selalu sinkron
  Future<void> ensureDataSync({String? forTimeSlotId}) async {
    if (forTimeSlotId != null) {
      _currentTimeSlotId = forTimeSlotId;
    }
    await universalRefresh();
  }

  // Getter untuk mengetahui apakah ada data yang berubah
  bool get hasDataChanged => dataChanged.value;

  // Getter untuk context saat ini
  String? get currentContext => _currentContext;
  String? get currentTimeSlotId => _currentTimeSlotId;
}
