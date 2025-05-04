// lib/data/repository/session_repository.dart
import 'package:emababyspa/data/api/api_exception.dart';
import 'package:emababyspa/data/providers/session_provider.dart';
import 'package:emababyspa/data/models/session.dart';
import 'package:dio/dio.dart';

class SessionRepository {
  final SessionProvider _provider;

  SessionRepository({required SessionProvider provider}) : _provider = provider;

  /// Create a new session
  Future<Session> createSession({
    required String timeSlotId,
    required String staffId,
    bool isBooked = false,
  }) async {
    try {
      final data = await _provider.createSession(
        timeSlotId: timeSlotId,
        staffId: staffId,
        isBooked: isBooked,
      );

      return Session.fromJson(data);
    } on DioException catch (e) {
      throw ApiException(
        message: e.error?.toString() ?? 'Failed to create session',
      );
    } catch (e) {
      throw ApiException(
        message: 'Gagal membuat sesi baru. Silakan coba lagi nanti.',
      );
    }
  }

  /// Create multiple sessions at once
  Future<List<Session>> createManySessions({
    required List<Map<String, dynamic>> sessions,
  }) async {
    try {
      final List<dynamic> sessionsData = await _provider.createManySessions(
        sessions: sessions,
      );

      return sessionsData.map((json) => Session.fromJson(json)).toList();
    } on DioException catch (e) {
      throw ApiException(
        message: e.error?.toString() ?? 'Failed to create sessions',
      );
    } catch (e) {
      throw ApiException(
        message: 'Gagal membuat beberapa sesi. Silakan coba lagi nanti.',
      );
    }
  }

  /// Get all sessions with optional filtering
  Future<List<Session>> getAllSessions({
    bool? isBooked,
    String? staffId,
    String? timeSlotId,
    String? date,
  }) async {
    try {
      final List<dynamic> sessionsData = await _provider.getAllSessions(
        isBooked: isBooked,
        staffId: staffId,
        timeSlotId: timeSlotId,
        date: date,
      );

      return sessionsData.map((json) => Session.fromJson(json)).toList();
    } on DioException catch (e) {
      throw ApiException(
        message: e.error?.toString() ?? 'Failed to retrieve sessions',
      );
    } catch (e) {
      throw ApiException(
        message: 'Gagal mengambil data sesi. Silakan coba lagi nanti.',
      );
    }
  }

  /// Get session details by ID
  Future<Session> getSessionById(String id) async {
    try {
      final data = await _provider.getSessionById(id);

      return Session.fromJson(data);
    } on DioException catch (e) {
      throw ApiException(message: e.error?.toString() ?? 'Session not found');
    } catch (e) {
      throw ApiException(
        message: 'Gagal mengambil detail sesi. Silakan coba lagi nanti.',
      );
    }
  }

  /// Update an existing session
  Future<Session> updateSession({
    required String id,
    String? timeSlotId,
    String? staffId,
    bool? isBooked,
  }) async {
    try {
      final data = await _provider.updateSession(
        id: id,
        timeSlotId: timeSlotId,
        staffId: staffId,
        isBooked: isBooked,
      );

      return Session.fromJson(data);
    } on DioException catch (e) {
      throw ApiException(
        message: e.error?.toString() ?? 'Failed to update session',
      );
    } catch (e) {
      throw ApiException(
        message: 'Gagal memperbarui sesi. Silakan coba lagi nanti.',
      );
    }
  }

  /// Delete a session
  Future<bool> deleteSession(String id) async {
    try {
      await _provider.deleteSession(id);
      return true;
    } on DioException catch (e) {
      throw ApiException(
        message: e.error?.toString() ?? 'Failed to delete session',
      );
    } catch (e) {
      throw ApiException(
        message: 'Gagal menghapus sesi. Silakan coba lagi nanti.',
      );
    }
  }

  /// Get available sessions for a specific date and service duration
  Future<List<dynamic>> getAvailableSessions({
    required String date,
    int? duration,
  }) async {
    try {
      return await _provider.getAvailableSessions(
        date: date,
        duration: duration,
      );
    } on DioException catch (e) {
      throw ApiException(
        message: e.error?.toString() ?? 'Failed to retrieve available sessions',
      );
    } catch (e) {
      throw ApiException(
        message: 'Gagal mengambil sesi yang tersedia. Silakan coba lagi nanti.',
      );
    }
  }

  /// Update session booking status
  Future<Session> updateSessionBookingStatus(String id, bool isBooked) async {
    try {
      final data = await _provider.updateSessionBookingStatus(id, isBooked);

      return Session.fromJson(data);
    } on DioException catch (e) {
      throw ApiException(
        message:
            e.error?.toString() ?? 'Failed to update session booking status',
      );
    } catch (e) {
      throw ApiException(
        message:
            'Gagal memperbarui status pemesanan sesi. Silakan coba lagi nanti.',
      );
    }
  }

  /// Get sessions by staff ID with optional date range
  Future<List<dynamic>> getSessionsByStaff(
    String staffId, {
    String? startDate,
    String? endDate,
  }) async {
    try {
      return await _provider.getSessionsByStaff(
        staffId,
        startDate: startDate,
        endDate: endDate,
      );
    } on DioException catch (e) {
      throw ApiException(
        message: e.error?.toString() ?? 'Failed to retrieve staff sessions',
      );
    } catch (e) {
      throw ApiException(
        message: 'Gagal mengambil jadwal staf. Silakan coba lagi nanti.',
      );
    }
  }
}
