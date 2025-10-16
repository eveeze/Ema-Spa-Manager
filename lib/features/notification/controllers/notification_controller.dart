// lib/feeatures/notificaiton/controllers/notificaiton_controller.dart
import 'package:get/get.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:emababyspa/data/models/notification.dart' as model;
import 'package:emababyspa/data/repository/notification_repository.dart';

class NotificationController extends GetxController {
  final NotificationRepository _repository = Get.find<NotificationRepository>();

  // --- STATE MANAGEMENT ---
  final RxList<model.Notification> notifications = <model.Notification>[].obs;
  final RxBool isLoading = true.obs;
  final RxBool isLoadingMore = false.obs;
  final RxInt unreadCount = 0.obs;

  // --- Paginasi ---
  int _currentPage = 1;
  bool _hasMore = true;

  @override
  void onInit() {
    super.onInit();
    // Panggil saat controller pertama kali diinisialisasi
    fetchNotifications(isRefresh: true);

    // Listener untuk menangani klik pada push notification
    OneSignal.Notifications.addClickListener((event) {
      _handleNotificationClick(event.notification);
    });
  }

  /// Panggil fungsi ini setelah pengguna berhasil login.
  void onLoginSuccess() {
    _repository.syncPlayerId();
  }

  /// Mengambil notifikasi dari server dengan logika pagination.
  /// [isRefresh] bernilai true jika dipanggil oleh pull-to-refresh.
  Future<void> fetchNotifications({bool isRefresh = false}) async {
    // Hentikan jika sedang memuat atau sudah tidak ada data lagi (kecuali jika refresh)
    if (isLoadingMore.value || (!_hasMore && !isRefresh)) return;

    if (isRefresh) {
      _currentPage = 1;
      _hasMore = true;
      isLoading.value = true; // Tampilkan loading utama
    } else {
      isLoadingMore.value = true; // Tampilkan loading di bagian bawah list
    }

    try {
      final result = await _repository.getNotifications(page: _currentPage);

      if (isRefresh) {
        notifications.clear();
      }

      notifications.addAll(result.data);

      // Perbarui status _hasMore berdasarkan metadata dari API
      _hasMore = _currentPage < result.meta.totalPages;

      // Naikkan nomor halaman jika masih ada data untuk diambil selanjutnya
      if (_hasMore) {
        _currentPage++;
      }

      _calculateUnreadCount();
    } catch (e) {
      print("[FETCH_NOTIFICATIONS_ERROR] $e");
      Get.snackbar(
        'Error',
        'Gagal memuat notifikasi. Silakan coba lagi.',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
      isLoadingMore.value = false;
    }
  }

  /// Menandai satu notifikasi sebagai sudah dibaca.
  Future<void> markAsRead(String notificationId) async {
    final index = notifications.indexWhere((n) => n.id == notificationId);
    // Hentikan jika notifikasi tidak ditemukan atau sudah dibaca
    if (index == -1 || notifications[index].isRead) return;

    final oldNotification = notifications[index];

    // Optimistic UI Update: Langsung ubah UI tanpa menunggu server
    notifications[index] = model.Notification(
      id: oldNotification.id,
      title: oldNotification.title,
      message: oldNotification.message,
      createdAt: oldNotification.createdAt,
      referenceId: oldNotification.referenceId,
      isRead: true, // Ubah status
      recipientType: oldNotification.recipientType,
      type: oldNotification.type,
    );
    _calculateUnreadCount();

    try {
      await _repository.markNotificationAsRead(notificationId);
    } catch (e) {
      print("[MARK_AS_READ_ERROR] Failed to mark as read on server: $e");
      // Rollback: Kembalikan ke state semula jika API gagal
      notifications[index] = oldNotification;
      _calculateUnreadCount();
      Get.snackbar(
        'Error',
        'Gagal menandai notifikasi.',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  /// Menandai SEMUA notifikasi sebagai sudah dibaca.
  Future<void> markAllAsRead() async {
    // Cek dulu apakah ada notifikasi yang belum dibaca
    if (unreadCount.value == 0) return;

    // Optimistic UI Update
    final List<model.Notification> updatedList =
        notifications.map((n) {
          return model.Notification(
            id: n.id,
            title: n.title,
            message: n.message,
            createdAt: n.createdAt,
            referenceId: n.referenceId,
            isRead: true,
            recipientType: n.recipientType,
            type: n.type,
          );
        }).toList();

    notifications.assignAll(updatedList);
    _calculateUnreadCount();

    try {
      await _repository.markAllNotificationsAsRead();
    } catch (e) {
      print("[MARK_ALL_AS_READ_ERROR] $e");
      // Jika gagal, sinkronkan ulang dengan data dari server
      fetchNotifications(isRefresh: true);
      Get.snackbar('Error', 'Gagal menandai semua notifikasi.');
    }
  }

  /// Menghitung jumlah notifikasi yang belum dibaca.
  void _calculateUnreadCount() {
    unreadCount.value = notifications.where((n) => !n.isRead).length;
  }

  /// Menangani aksi saat push notification di-klik.
  void _handleNotificationClick(OSNotification notification) {
    print('NOTIFICATION CLICKED: ${notification.jsonRepresentation()}');
    // Segarkan daftar notifikasi di background
    fetchNotifications(isRefresh: true);

    // Navigasi jika ada data tambahan (misalnya ID reservasi)
    final String? reservationId = notification.additionalData?['reservationId'];
    if (reservationId != null) {
      Get.toNamed('/dashboard/reservation/$reservationId');
    }
  }
}
