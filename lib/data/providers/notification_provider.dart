// lib/data/providers/notification_provider.dart

import 'package:emababyspa/data/api/api_client.dart';
import 'package:emababyspa/data/api/api_endpoints.dart';
import 'package:emababyspa/utils/logger_utils.dart';
import 'package:get/get.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';

class NotificationProvider extends GetxService {
  final ApiClient _apiClient;
  final LoggerUtils _logger;

  NotificationProvider({
    required ApiClient apiClient,
    required LoggerUtils logger,
  }) : _apiClient = apiClient,
       _logger = logger;

  // Fungsi untuk mengirim playerId ke backend setelah login
  Future<void> syncPlayerId() async {
    // ApiClient Anda sudah otomatis menangani token melalui AuthInterceptor

    // Cara mendapatkan Player ID (Subscription ID) yang benar untuk OneSignal SDK v5+
    final String? playerId = OneSignal.User.pushSubscription.id;

    if (playerId == null) {
      _logger.warning(
        "Player ID belum tersedia, mungkin perlu ditunggu sesaat.",
      );
      return;
    }

    try {
      // Gunakan postValidated dari ApiClient Anda, sama seperti di AuthProvider
      await _apiClient.postValidated(
        ApiEndpoints.updateOwnerPlayerId,
        data: {'playerId': playerId},
      );
      _logger.info("Player ID Owner berhasil disinkronkan: $playerId");
    } catch (e) {
      _logger.error("Error saat sinkronisasi Player ID: $e");
      // Tidak perlu rethrow agar tidak menghentikan alur aplikasi jika gagal
    }
  }

  // --- Tambahan: Logika untuk Notifikasi In-App ---

  // Fungsi untuk mengambil daftar notifikasi dari backend
  Future<List<dynamic>> getNotifications() async {
    try {
      _logger.info('Provider: Fetching notifications for owner.');
      final response = await _apiClient.getValidated(
        ApiEndpoints.notifications,
      );
      // getValidated sudah mengekstrak field 'data' yang berisi List
      return response as List<dynamic>;
    } catch (e) {
      _logger.error('Provider: Error fetching notifications: $e');
      rethrow;
    }
  }

  // Fungsi untuk menandai notifikasi sebagai sudah dibaca
  Future<void> markNotificationAsRead(String notificationId) async {
    try {
      _logger.info('Provider: Marking notification $notificationId as read.');
      await _apiClient.patchValidated(
        ApiEndpoints.notificationMarkRead,
        pathParams: {'id': notificationId},
      );
    } catch (e) {
      _logger.error('Provider: Error marking notification as read: $e');
      rethrow;
    }
  }
}
