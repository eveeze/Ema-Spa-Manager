// lib/features/service/bindings/service_bindings.dart
import 'package:get/get.dart';
import 'package:emababyspa/data/providers/service_provider.dart';
import 'package:emababyspa/data/repository/service_repository.dart';
import 'package:emababyspa/features/service/controllers/service_controller.dart';
import 'package:emababyspa/data/providers/service_category_provider.dart';
import 'package:emababyspa/data/repository/service_category_repository.dart';
import 'package:emababyspa/data/providers/staff_provider.dart';
import 'package:emababyspa/data/repository/staff_repository.dart';

class ServiceBindings extends Bindings {
  @override
  void dependencies() {
    if (!Get.isRegistered<ServiceProvider>()) {
      Get.put(ServiceProvider());
    }

    if (!Get.isRegistered<ServiceCategoryProvider>()) {
      Get.put(ServiceCategoryProvider());
    }

    if (!Get.isRegistered<StaffProvider>()) {
      Get.put(StaffProvider());
    }

    // Register the  repository
    Get.lazyPut(() => ServiceRepository(provider: Get.find<ServiceProvider>()));
    Get.lazyPut(() => ServiceCategoryRepository());
    Get.lazyPut(
      () => StaffRepository(staffProvider: Get.find<StaffProvider>()),
    );
    // Register the service controller
    Get.lazyPut(
      () => ServiceController(serviceRepository: Get.find<ServiceRepository>()),
    );
  }
}
