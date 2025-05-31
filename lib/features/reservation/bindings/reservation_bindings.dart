// lib/features/reservation/bindings/reservation_bindings.dart
import 'package:emababyspa/data/providers/service_category_provider.dart';
import 'package:emababyspa/data/providers/service_provider.dart';
import 'package:emababyspa/data/repository/service_category_repository.dart';
import 'package:emababyspa/data/repository/service_repository.dart';
import 'package:emababyspa/features/service/controllers/service_controller.dart';
import 'package:get/get.dart';
import 'package:emababyspa/data/providers/reservation_provider.dart';
import 'package:emababyspa/data/repository/reservation_repository.dart';
import 'package:emababyspa/features/reservation/controllers/reservation_controller.dart';
import 'package:emababyspa/data/api/api_client.dart';
import 'package:emababyspa/utils/logger_utils.dart';

class ReservationBindings extends Bindings {
  @override
  void dependencies() {
    // Register LoggerUtils first if not already registered
    if (!Get.isRegistered<LoggerUtils>()) {
      Get.put(LoggerUtils(), permanent: true);
    }

    // Register ApiClient if not already registered
    if (!Get.isRegistered<ApiClient>()) {
      Get.put(ApiClient(), permanent: true);
    }
    if (!Get.isRegistered<ServiceCategoryProvider>()) {
      Get.put(ServiceCategoryProvider());
    }
    // Register ReservationProvider
    if (!Get.isRegistered<ReservationProvider>()) {
      Get.put(
        ReservationProvider(
          apiClient: Get.find<ApiClient>(),
          logger: Get.find<LoggerUtils>(),
        ),
        permanent: true,
      );
    }
    if (!Get.isRegistered<ServiceProvider>()) {
      Get.put(ServiceProvider());
    }
    // Register ReservationRepository
    if (!Get.isRegistered<ReservationRepository>()) {
      Get.lazyPut(
        () => ReservationRepository(
          reservationProvider: Get.find<ReservationProvider>(),
          logger: Get.find<LoggerUtils>(),
        ),
        fenix: true,
      );
    }
    Get.lazyPut(() => ServiceCategoryRepository());

    // Register ReservationRepository
    if (!Get.isRegistered<ServiceRepository>()) {
      Get.lazyPut(
        () => ServiceRepository(provider: Get.find<ServiceProvider>()),
      );
    }
    Get.lazyPut(
      () => ServiceController(serviceRepository: Get.find<ServiceRepository>()),
    );
    // Register ReservationController
    Get.lazyPut(
      () => ReservationController(
        reservationRepository: Get.find<ReservationRepository>(),
      ),
      fenix: true,
    );
  }
}
