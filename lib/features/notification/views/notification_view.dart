// lib/features/notification/views/notification_view.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:emababyspa/features/notification/controllers/notification_controller.dart';
import 'package:emababyspa/data/models/notification.dart' as model;
import 'package:emababyspa/utils/app_routes.dart';
import 'package:emababyspa/utils/timezone_utils.dart';
import 'package:emababyspa/features/theme/controllers/theme_controller.dart';
import 'package:timeago/timeago.dart' as timeago;

import 'package:emababyspa/common/theme/app_theme.dart';
import 'package:emababyspa/common/theme/semantic_colors.dart';

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

  Widget _buildEmptyState(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final colorScheme = theme.colorScheme;
    final spacing = theme.extension<AppSpacing>() ?? const AppSpacing();

    final double iconSize =
        (textTheme.displaySmall?.fontSize ??
            textTheme.headlineLarge?.fontSize ??
            56) *
        1.2;

    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: spacing.xl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              height: iconSize + spacing.md,
              width: iconSize + spacing.md,
              decoration: BoxDecoration(
                color: colorScheme.surfaceContainerHighest.withValues(
                  alpha: 0.55,
                ),
                borderRadius: BorderRadius.circular(AppRadii.xl),
                border: Border.all(
                  color: colorScheme.outlineVariant.withValues(alpha: 0.70),
                ),
              ),
              alignment: Alignment.center,
              child: Icon(
                Icons.notifications_off_outlined,
                size: iconSize,
                color: colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
              ),
            ),
            SizedBox(height: spacing.lg),
            Text(
              'Belum Ada Notifikasi',
              style: textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w900,
                color: colorScheme.onSurface,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: spacing.sm),
            Text(
              'Notifikasi terbaru dari pelanggan maupun sistem akan tampil di sini.',
              style: textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
                fontWeight: FontWeight.w600,
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
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;
    final spacing = theme.extension<AppSpacing>() ?? const AppSpacing();

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          'Notifikasi',
          style:
              theme.appBarTheme.titleTextStyle ??
              textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900),
        ),
        centerTitle: true,
        backgroundColor: colorScheme.surface,
        surfaceTintColor: colorScheme.surface,
        scrolledUnderElevation: 0,
        actions: [
          Obx(() {
            if (controller.unreadCount.value > 0) {
              return Padding(
                padding: EdgeInsets.only(right: spacing.xs),
                child: TextButton.icon(
                  onPressed: controller.markAllAsRead,
                  icon: Icon(
                    Icons.done_all_rounded,
                    color: colorScheme.primary,
                  ),
                  label: Text(
                    'Tandai Semua',
                    style: textTheme.labelLarge?.copyWith(
                      color: colorScheme.primary,
                      fontWeight: FontWeight.w800,
                    ),
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
          return Center(
            child: CircularProgressIndicator(color: colorScheme.primary),
          );
        }

        if (controller.notifications.isEmpty) {
          return _buildEmptyState(context);
        }

        return RefreshIndicator(
          onRefresh: () => controller.fetchNotifications(isRefresh: true),
          color: colorScheme.primary,
          backgroundColor: colorScheme.surface,
          child: ListView.builder(
            controller: _scrollController,
            padding: EdgeInsets.symmetric(
              horizontal: spacing.lg,
              vertical: spacing.md,
            ),
            itemCount:
                controller.notifications.length +
                (controller.isLoadingMore.value ? 1 : 0),
            itemBuilder: (context, index) {
              if (index == controller.notifications.length) {
                return Padding(
                  padding: EdgeInsets.symmetric(vertical: spacing.lg),
                  child: Center(
                    child: CircularProgressIndicator(
                      color: colorScheme.primary,
                    ),
                  ),
                );
              }
              final notification = controller.notifications[index];
              return Padding(
                padding: EdgeInsets.only(bottom: spacing.md),
                child: _buildNotificationItem(context, notification),
              );
            },
          ),
        );
      }),
    );
  }

  Widget _buildNotificationItem(
    BuildContext context,
    model.Notification notification,
  ) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final colorScheme = theme.colorScheme;
    final spacing = theme.extension<AppSpacing>() ?? const AppSpacing();
    final semantic = theme.extension<AppSemanticColors>();

    final localTime = TimeZoneUtil.toIndonesiaTime(notification.createdAt);
    final timeAgoString = timeago.format(localTime, locale: 'id');
    final bool isUnread = !notification.isRead;

    final Color accent = colorScheme.primary;
    final Color unreadBg = colorScheme.primaryContainer.withValues(alpha: 0.18);
    final Color cardBg = colorScheme.surface;
    final Color border = colorScheme.outlineVariant.withValues(alpha: 0.70);

    final Color badgeColor = (semantic?.info ?? accent).withValues(alpha: 0.12);

    final IconData leadingIcon =
        notification.type == 'reservation'
            ? Icons.event_available_rounded
            : Icons.notifications_active_rounded;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(AppRadii.xl),
        onTap: () {
          controller.markAsRead(notification.id);
          if (notification.type == 'reservation' &&
              notification.referenceId != null) {
            Get.toNamed(
              '${AppRoutes.reservationList}/${notification.referenceId}',
            );
          }
        },
        child: Ink(
          decoration: BoxDecoration(
            color: isUnread ? unreadBg : cardBg,
            borderRadius: BorderRadius.circular(AppRadii.xl),
            border: Border.all(color: border),
          ),
          child: Padding(
            padding: EdgeInsets.all(spacing.lg),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // leading
                Container(
                  height: spacing.xxl,
                  width: spacing.xxl,
                  decoration: BoxDecoration(
                    color: badgeColor,
                    borderRadius: BorderRadius.circular(AppRadii.lg),
                    border: Border.all(color: accent.withValues(alpha: 0.18)),
                  ),
                  alignment: Alignment.center,
                  child: Icon(
                    leadingIcon,
                    color: accent,
                    size: textTheme.titleLarge?.fontSize ?? 20,
                  ),
                ),
                SizedBox(width: spacing.md),

                // content
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // title row + dot
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Text(
                              notification.title,
                              style: textTheme.titleMedium?.copyWith(
                                fontWeight:
                                    isUnread
                                        ? FontWeight.w900
                                        : FontWeight.w700,
                                color: colorScheme.onSurface,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (isUnread) ...[
                            SizedBox(width: spacing.sm),
                            Container(
                              margin: EdgeInsets.only(top: spacing.xxs),
                              height: spacing.xs,
                              width: spacing.xs,
                              decoration: BoxDecoration(
                                color: accent,
                                shape: BoxShape.circle,
                              ),
                            ),
                          ],
                        ],
                      ),

                      SizedBox(height: spacing.xs),
                      Text(
                        notification.message,
                        style: textTheme.bodyMedium?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                      ),

                      SizedBox(height: spacing.sm),
                      Row(
                        children: [
                          Icon(
                            Icons.schedule_rounded,
                            size: textTheme.bodySmall?.fontSize ?? 12,
                            color: colorScheme.onSurfaceVariant,
                          ),
                          SizedBox(width: spacing.xs),
                          Text(
                            timeAgoString,
                            style: textTheme.bodySmall?.copyWith(
                              color: colorScheme.onSurfaceVariant,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
