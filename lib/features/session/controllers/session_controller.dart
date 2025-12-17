// lib/features/session/controllers/session_controller.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import 'package:emababyspa/common/theme/color_theme.dart';
import 'package:emababyspa/data/api/api_exception.dart';
import 'package:emababyspa/data/models/session.dart';
import 'package:emababyspa/data/repository/session_repository.dart';
import 'package:emababyspa/utils/logger_utils.dart';

enum _SessionContext { idle, schedule, timeslot, staff }

class SessionController extends GetxController {
  final SessionRepository repository;
  final LoggerUtils _logger = LoggerUtils();

  // Observable state
  final RxBool isLoading = false.obs;
  final RxBool isSubmitting = false.obs;
  final RxString errorMessage = ''.obs;

  final RxList<Session> sessions = <Session>[].obs;
  final Rx<Session?> currentSession = Rx<Session?>(null);
  final RxList<Session> availableSessions = <Session>[].obs;

  // Operation tracking
  final RxString _lastOperationDetails = ''.obs;
  String get lastOperationDetails => _lastOperationDetails.value;

  // Date selection
  final Rx<DateTime> selectedDate = DateTime.now().obs;

  // Service duration in minutes (if applicable)
  final RxInt serviceDuration = 0.obs;

  // Staff filter
  final RxString selectedStaffId = ''.obs;

  // Booking status filter
  final Rx<bool?> filterIsBooked = Rx<bool?>(null);

  // Current context tracking
  String? _currentTimeSlotId;
  _SessionContext _context = _SessionContext.idle;

  // Store last fetch parameters for smart refresh
  Map<String, dynamic> _lastFetchParams = {};

  // Data change listeners (untuk notifikasi antar views)
  final RxBool dataChanged = false.obs;
  final RxString lastChangedOperation = ''.obs;

  // (Legacy) masih ada di kode kamu, tetap disediakan agar tidak breaking
  final sessionsMap = <String, List<Session>>{}.obs;

  SessionController({required this.repository});

  @override
  void onInit() {
    super.onInit();
    // Best practice: jangan auto-fetch di sini.
    // Fetch dipanggil explicit dari ScheduleController/TimeSlotView.
    _setContext(_SessionContext.idle);
  }

  // =========================
  // Public helpers
  // =========================

  void resetSessionState() {
    sessions.clear();
    currentSession.value = null;
    availableSessions.clear();
    errorMessage.value = '';
  }

  // Getter untuk kompatibilitas UI lama (kalau ada yang baca string)
  String? get currentContext {
    switch (_context) {
      case _SessionContext.idle:
        return 'idle';
      case _SessionContext.schedule:
        return 'schedule';
      case _SessionContext.timeslot:
        return 'timeslot';
      case _SessionContext.staff:
        return 'staff';
    }
  }

  String? get currentTimeSlotId => _currentTimeSlotId;

  bool get hasDataChanged => dataChanged.value;

  // =========================
  // Internal utils
  // =========================

  void _setContext(_SessionContext context, {String? timeSlotId}) {
    _context = context;
    _currentTimeSlotId = timeSlotId;
  }

  void notifyDataChange(String operation, String timeSlotId) {
    _lastOperationDetails.value = '$operation:$timeSlotId';
  }

  String _formatDate(DateTime date) => DateFormat('yyyy-MM-dd').format(date);

  void clearError() => errorMessage.value = '';

  void _notifyDataChange(String operation) {
    // Toggle untuk trigger reaktif
    dataChanged.value = !dataChanged.value;
    lastChangedOperation.value = operation;
  }

  void _showErrorSnackbar(String message) {
    final ctx = Get.context;
    final bg =
        ctx != null
            ? Theme.of(ctx).colorScheme.error
            : ColorTheme.error; // fallback
    final fg =
        ctx != null
            ? Theme.of(ctx).colorScheme.onError
            : Colors.white; // fallback

    Get.snackbar(
      'Gagal',
      message,
      backgroundColor: bg,
      colorText: fg,
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  void _showSuccessSnackbar(String message) {
    // konsisten dengan ColorTheme (kamu sudah pakai di tempat lain)
    Get.snackbar(
      'Berhasil',
      message,
      backgroundColor: ColorTheme.success.withValues(alpha: 0.10),
      colorText: ColorTheme.success,
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  void _handleError(dynamic error, String defaultMessage) {
    if (error is ApiException) {
      errorMessage.value = error.message;
      _logger.error('$defaultMessage: ${error.message}');
      _showErrorSnackbar(error.message);
      return;
    }

    errorMessage.value = defaultMessage;
    _logger.error('Unexpected error: $error');
    _showErrorSnackbar(defaultMessage);
  }

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

  Future<void> _refreshCurrentContext() async {
    switch (_context) {
      case _SessionContext.timeslot:
        if (_currentTimeSlotId != null) {
          await fetchSessionsByTimeSlot(_currentTimeSlotId!);
        }
        break;
      case _SessionContext.staff:
        if (selectedStaffId.value.isNotEmpty) {
          await fetchSessionsByStaff(selectedStaffId.value);
        }
        break;
      case _SessionContext.schedule:
        await fetchSessions();
        break;
      case _SessionContext.idle:
        // no-op
        break;
    }
  }

  bool _matchesCurrentFilters(Session session) {
    if (selectedStaffId.value.isNotEmpty &&
        session.staffId != selectedStaffId.value) {
      return false;
    }

    if (filterIsBooked.value != null &&
        session.isBooked != filterIsBooked.value) {
      return false;
    }

    if (_currentTimeSlotId != null &&
        session.timeSlotId != _currentTimeSlotId) {
      return false;
    }

    return true;
  }

  void _updateSessionInList(Session updatedSession) {
    final index = sessions.indexWhere((s) => s.id == updatedSession.id);

    if (index != -1) {
      if (_matchesCurrentFilters(updatedSession)) {
        sessions[index] = updatedSession;
      } else {
        sessions.removeAt(index);
      }
    } else if (_matchesCurrentFilters(updatedSession)) {
      sessions.add(updatedSession);
    }

    if (currentSession.value?.id == updatedSession.id) {
      currentSession.value = updatedSession;
    }
  }

  // =========================
  // Filters / setters
  // =========================

  void setDate(DateTime date) {
    selectedDate.value = date;
    _refreshCurrentContext();
  }

  void setServiceDuration(int duration) {
    serviceDuration.value = duration;
    fetchAvailableSessions();
  }

  void setStaffFilter(String staffId) {
    selectedStaffId.value = staffId;
    _refreshCurrentContext();
  }

  void setBookingStatusFilter(bool? isBooked) {
    filterIsBooked.value = isBooked;
    _refreshCurrentContext();
  }

  void resetFilters() {
    selectedStaffId.value = '';
    filterIsBooked.value = null;
    selectedDate.value = DateTime.now();
    _currentTimeSlotId = null;
    _setContext(_SessionContext.schedule);
    _lastFetchParams.clear();

    // Tidak auto-fetch di onInit, tapi resetFilters biasanya memang user action → fetch boleh
    fetchSessions();
  }

  // =========================
  // Fetch methods (kontrak repository tetap)
  // =========================

  Future<void> fetchSessions({
    bool? isBooked,
    String? staffId,
    String? timeSlotId,
    String? date,
  }) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      _storeFetchParams(
        isBooked: isBooked,
        staffId: staffId,
        timeSlotId: timeSlotId,
        date: date,
      );

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

  Future<void> fetchSessionsByTimeSlot(String timeSlotId) async {
    _setContext(_SessionContext.timeslot, timeSlotId: timeSlotId);
    await fetchSessions(timeSlotId: timeSlotId);
  }

  Future<void> fetchSessionsByDate(DateTime date) async {
    try {
      isLoading.value = true;
      clearError();
      sessions.clear();

      _setContext(_SessionContext.schedule);
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

  Future<void> fetchSessionsByStaff(
    String staffId, {
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      isLoading.value = true;
      clearError();

      _setContext(_SessionContext.staff);
      selectedStaffId.value = staffId;

      String? formattedStartDate;
      String? formattedEndDate;

      if (startDate != null) formattedStartDate = _formatDate(startDate);
      if (endDate != null) formattedEndDate = _formatDate(endDate);

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

  // =========================
  // Refresh helpers
  // =========================

  Future<bool> refreshData({String? specificTimeSlotId}) async {
    try {
      isLoading.value = true;
      clearError();

      if (specificTimeSlotId != null) {
        _currentTimeSlotId = specificTimeSlotId;
        _lastFetchParams['timeSlotId'] = specificTimeSlotId;
      }

      final sessionsList = await repository.getAllSessions(
        isBooked: _lastFetchParams['isBooked'],
        staffId: _lastFetchParams['staffId'],
        timeSlotId: _lastFetchParams['timeSlotId'],
        date: _lastFetchParams['date'],
      );

      sessions.value = sessionsList;
      _notifyDataChange('refresh');

      Get.snackbar(
        'Berhasil',
        'Data berhasil disegarkan',
        backgroundColor: ColorTheme.success.withValues(alpha: 0.10),
        colorText: ColorTheme.success,
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

  Future<void> universalRefresh() async => _refreshCurrentContext();

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

  Future<void> ensureDataSync({String? forTimeSlotId}) async {
    if (forTimeSlotId != null) _currentTimeSlotId = forTimeSlotId;
    await universalRefresh();
  }

  Future<void> onReturnToSchedule() async {
    _setContext(_SessionContext.schedule);
    await universalRefresh();
  }

  void onEnterTimeSlotView(String timeSlotId) {
    _setContext(_SessionContext.timeslot, timeSlotId: timeSlotId);
  }

  // =========================
  // CRUD methods (kontrak repository tetap)
  // =========================

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

      if (_matchesCurrentFilters(session)) {
        sessions.add(session);
      }

      currentSession.value = session;
      _currentTimeSlotId = timeSlotId;

      await _refreshCurrentContext();

      _showSuccessSnackbar('Sesi berhasil dibuat');
      notifyDataChange('create', timeSlotId);
      _notifyDataChange('create');
      return true;
    } catch (e) {
      _handleError(e, 'Terjadi kesalahan saat membuat sesi');
      return false;
    } finally {
      isSubmitting.value = false;
    }
  }

  Future<bool> createManySessions({
    required List<Map<String, dynamic>> sessionsList,
  }) async {
    try {
      isSubmitting.value = true;
      clearError();

      if (sessionsList.isNotEmpty &&
          sessionsList[0].containsKey('timeSlotId')) {
        _currentTimeSlotId = sessionsList[0]['timeSlotId']?.toString();
      }

      await repository.createManySessions(sessions: sessionsList);

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

      if (timeSlotId != null) {
        _currentTimeSlotId = timeSlotId;
      }

      _showSuccessSnackbar('Sesi berhasil diperbarui');

      // FIX: jangan pakai timeSlotId! (bisa null)
      notifyDataChange('update', timeSlotId ?? _currentTimeSlotId ?? '');
      _notifyDataChange('update');
      return true;
    } catch (e) {
      _handleError(e, 'Terjadi kesalahan saat memperbarui sesi');
      return false;
    } finally {
      isSubmitting.value = false;
    }
  }

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
      _notifyDataChange('update_booking');
      return true;
    } catch (e) {
      _handleError(e, 'Terjadi kesalahan saat memperbarui status pemesanan');
      return false;
    } finally {
      isSubmitting.value = false;
    }
  }

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
          backgroundColor: ColorTheme.success.withValues(alpha: 0.10),
          colorText: ColorTheme.success,
          snackPosition: SnackPosition.BOTTOM,
        );

        notifyDataChange('delete', _currentTimeSlotId ?? '');
        _notifyDataChange('delete');
        return true;
      }

      return false;
    } catch (e) {
      _handleError(e, 'Gagal menghapus sesi');
      return false;
    } finally {
      isSubmitting.value = false;
    }
  }
}
