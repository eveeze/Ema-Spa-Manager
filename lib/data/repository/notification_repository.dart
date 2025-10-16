import 'package:emababyspa/data/models/notification.dart';
import 'package:emababyspa/data/providers/notification_provider.dart';
import 'package:emababyspa/utils/logger_utils.dart';
import 'package:emababyspa/data/models/paginated_response.dart';

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

  Future<PaginatedResponse<Notification>> getNotifications({
    required int page,
  }) async {
    try {
      _logger.info('Repository: Fetching notifications page $page.');
      final rawResponse = await _provider.getNotifications(page: page);

      // Parsing data list
      final List<dynamic> rawDataList = rawResponse['data'] as List<dynamic>;
      final notifications =
          rawDataList
              .map(
                (json) => Notification.fromJson(json as Map<String, dynamic>),
              )
              .toList();

      // Parsing meta
      final meta = Meta.fromJson(rawResponse['meta'] as Map<String, dynamic>);

      return PaginatedResponse(data: notifications, meta: meta);
    } catch (e) {
      _logger.error('Repository: Error fetching notifications: $e');
      rethrow;
    }
  }

  Future<void> markAllNotificationsAsRead() async {
    try {
      _logger.info('Repository: Marking all notifications as read.');
      await _provider.markAllNotificationsAsRead();
    } catch (e) {
      _logger.error('Repository: Error marking all as read: $e');
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
