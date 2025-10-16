// lib/features/notification/views/notification_view.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:emababyspa/features/notification/controllers/notification_controller.dart';
import 'package:emababyspa/data/models/notification.dart' as model;
import 'package:emababyspa/utils/app_routes.dart';
import 'package:emababyspa/utils/timezone_utils.dart';
import 'package:emababyspa/features/theme/controllers/theme_controller.dart';
import 'package:timeago/timeago.dart' as timeago;

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  final NotificationController controller = Get.find<NotificationController>();
  final ThemeController themeController = Get.find<ThemeController>();
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    timeago.setLocaleMessages('id', timeago.IdMessages());

    _scrollController.addListener(() {
      if (_scrollController.position.pixels >=
          _scrollController.position.maxScrollExtent - 200) {
        controller.fetchNotifications();
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  /// Widget untuk tampilan kosong
  Widget _buildEmptyState(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.notifications_off_outlined,
              size: 80,
              // Menggunakan warna dari theme
              color: colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
            ),
            const SizedBox(height: 24),
            Text(
              'Tidak Ada Notifikasi',
              // Menggunakan style dari theme
              style: textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(
              'Semua notifikasi baru dari pelanggan dan sistem akan muncul di sini.',
              // Menggunakan style dari theme
              style: textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Mengambil color scheme dan text theme dari context
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        // Warna AppBar sudah diatur oleh AppTheme
        title: const Text('Notifikasi'),
        centerTitle: true,
        actions: [
          Obx(() {
            if (controller.unreadCount.value > 0) {
              return TextButton(
                onPressed: controller.markAllAsRead,
                child: Text(
                  'Tandai Semua',
                  style: TextStyle(
                    // Menggunakan warna onPrimary agar kontras dengan AppBar
                    color: colorScheme.onPrimary,
                  ),
                ),
              );
            }
            return const SizedBox.shrink();
          }),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        if (controller.notifications.isEmpty) {
          return _buildEmptyState(context);
        }

        return RefreshIndicator(
          onRefresh: () => controller.fetchNotifications(isRefresh: true),
          // Menggunakan warna dari theme
          color: colorScheme.primary,
          backgroundColor: colorScheme.surface,
          child: ListView.builder(
            controller: _scrollController,
            itemCount:
                controller.notifications.length +
                (controller.isLoadingMore.value ? 1 : 0),
            itemBuilder: (context, index) {
              if (index == controller.notifications.length) {
                return const Center(
                  child: Padding(
                    padding: EdgeInsets.all(16.0),
                    child: CircularProgressIndicator(),
                  ),
                );
              }
              final notification = controller.notifications[index];
              return _buildNotificationItem(context, notification);
            },
          ),
        );
      }),
    );
  }

  /// Widget untuk satu item notifikasi
  Widget _buildNotificationItem(
    BuildContext context,
    model.Notification notification,
  ) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    final localTime = TimeZoneUtil.toIndonesiaTime(notification.createdAt);
    final timeAgoString = timeago.format(localTime, locale: 'id');
    final bool isUnread = !notification.isRead;

    return Material(
      // Memberi highlight pada notifikasi yang belum dibaca menggunakan warna dari theme
      color:
          isUnread
              ? colorScheme.primaryContainer.withValues(alpha: 0.3)
              : Colors.transparent,
      child: InkWell(
        onTap: () {
          controller.markAsRead(notification.id);
          if (notification.type == 'reservation' &&
              notification.referenceId != null) {
            // Menggunakan rute yang sesuai dari app_routes.dart
            Get.toNamed(
              '${AppRoutes.reservationList}/${notification.referenceId}',
            );
          }
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Indikator titik
              SizedBox(
                width: 24,
                child:
                    isUnread
                        ? Align(
                          alignment: Alignment.topCenter,
                          child: Container(
                            margin: const EdgeInsets.only(top: 6),
                            height: 8,
                            width: 8,
                            decoration: BoxDecoration(
                              // Menggunakan warna primary dari theme
                              color: colorScheme.primary,
                              shape: BoxShape.circle,
                            ),
                          ),
                        )
                        : null,
              ),
              // Konten notifikasi
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      notification.title,
                      // Menggunakan text style dari theme
                      style: textTheme.titleMedium?.copyWith(
                        fontWeight:
                            isUnread ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      notification.message,
                      style: textTheme.bodyMedium?.copyWith(
                        // Menggunakan warna sekunder agar tidak terlalu menonjol
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      timeAgoString,
                      // Menggunakan text style kecil dari theme
                      style: textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
