import 'package:get/get.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:emababyspa/data/models/notification.dart' as model;
import 'package:emababyspa/data/repository/notification_repository.dart';

class NotificationController extends GetxController {
  final NotificationRepository _repository = Get.find<NotificationRepository>();

  final RxList<model.Notification> notifications = <model.Notification>[].obs;
  final RxBool isLoading = false.obs;
  final RxInt unreadCount = 0.obs;

  @override
  void onInit() {
    super.onInit();
    fetchNotifications();

    OneSignal.Notifications.addClickListener((event) {
      _handleNotificationClick(event.notification);
    });
  }

  void onLoginSuccess() {
    _repository.syncPlayerId();
  }

  Future<void> fetchNotifications() async {
    try {
      isLoading.value = true;
      final result = await _repository.getNotifications();
      notifications.assignAll(result);
      _calculateUnreadCount();
    } catch (e) {
      print("Error fetching notifications: $e");
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> markAsRead(String notificationId) async {
    final index = notifications.indexWhere((n) => n.id == notificationId);
    if (index != -1 && !notifications[index].isRead) {
      final oldNotification = notifications[index];
      notifications[index] = model.Notification(
        id: oldNotification.id,
        title: oldNotification.title,
        message: oldNotification.message,
        createdAt: oldNotification.createdAt,
        referenceId: oldNotification.referenceId,
        isRead: true,
        recipientType: oldNotification.recipientType,
        type: oldNotification.type,
      );
      notifications.refresh();
      _calculateUnreadCount();
    }

    try {
      await _repository.markNotificationAsRead(notificationId);
    } catch (e) {
      print("Failed to mark as read on server: $e");
    }
  }

  void _handleNotificationClick(OSNotification notification) {
    print('NOTIFICATION CLICKED: ${notification.jsonRepresentation()}');
    fetchNotifications();

    final String? reservationId = notification.additionalData?['reservationId'];
    if (reservationId != null) {
      Get.toNamed('/dashboard/reservation/$reservationId');
    }
  }

  void _calculateUnreadCount() {
    unreadCount.value = notifications.where((n) => !n.isRead).length;
  }
}
