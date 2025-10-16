// lib/bindings/app_bindings.dart
import 'package:emababyspa/data/providers/notification_provider.dart';
import 'package:emababyspa/data/repository/notification_repository.dart';
import 'package:emababyspa/features/notification/controllers/notification_controller.dart';
import 'package:emababyspa/features/theme/controllers/theme_controller.dart';
import 'package:get/get.dart';
import 'package:emababyspa/data/api/api_client.dart';
import 'package:emababyspa/utils/storage_utils.dart';
import 'package:emababyspa/data/providers/auth_provider.dart';
import 'package:emababyspa/data/repository/auth_repository.dart';
import 'package:emababyspa/utils/logger_utils.dart';

class AppBindings extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ApiClient>(() => ApiClient(), fenix: true);
    Get.lazyPut<StorageUtils>(() => StorageUtils(), fenix: true);
    Get.lazyPut<AuthProvider>(() => AuthProvider(), fenix: true);
    Get.lazyPut<NotificationProvider>(
      () => NotificationProvider(apiClient: Get.find(), logger: Get.find()),
    );
    Get.lazyPut<AuthRepository>(
      () => AuthRepository(provider: Get.find<AuthProvider>()),
      fenix: true,
    );
    Get.lazyPut<NotificationRepository>(
      () => NotificationRepository(provider: Get.find(), logger: Get.find()),
      fenix: true,
    );
    Get.lazyPut<NotificationController>(
      () => NotificationController(),
      fenix: true,
    );

    Get.put(ThemeController(), permanent: true);

    if (!Get.isRegistered<LoggerUtils>()) {
      Get.put(LoggerUtils(), permanent: true);
    }
  }
}
