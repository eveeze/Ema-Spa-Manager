import 'package:emababyspa/data/models/notification.dart';
import 'package:emababyspa/data/providers/notification_provider.dart';
import 'package:emababyspa/utils/logger_utils.dart';

class NotificationRepository {
  final NotificationProvider _provider;
  final LoggerUtils _logger;

  NotificationRepository({
    required NotificationProvider provider,
    required LoggerUtils logger,
  }) : _provider = provider,
       _logger = logger;

  Future<void> syncPlayerId() async {
    await _provider.syncPlayerId();
  }

  Future<List<Notification>> getNotifications() async {
    try {
      _logger.info('Repository: Fetching notifications.');
      final rawData = await _provider.getNotifications();
      final notifications =
          rawData
              .map(
                (json) => Notification.fromJson(json as Map<String, dynamic>),
              )
              .toList();
      return notifications;
    } catch (e) {
      _logger.error('Repository: Error fetching notifications: $e');
      rethrow;
    }
  }

  Future<void> markNotificationAsRead(String notificationId) async {
    try {
      _logger.info('Repository: Marking notification $notificationId as read.');
      await _provider.markNotificationAsRead(notificationId);
    } catch (e) {
      _logger.error('Repository: Error marking notification as read: $e');
      rethrow;
    }
  }
}
