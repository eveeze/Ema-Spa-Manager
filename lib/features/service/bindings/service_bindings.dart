// lib/features/service/bindings/service_bindings.dart
import 'package:get/get.dart';
import 'package:emababyspa/data/providers/service_provider.dart';
import 'package:emababyspa/data/repository/service_repository.dart';
import 'package:emababyspa/features/service/controllers/service_controller.dart';

class ServiceBindings extends Bindings {
  @override
  void dependencies() {
    if (!Get.isRegistered<ServiceProvider>()) {
      Get.put(ServiceProvider());
    }

    // Register the service repository
    Get.lazyPut(() => ServiceRepository(provider: Get.find<ServiceProvider>()));

    // Register the service controller
    Get.lazyPut(
      () => ServiceController(serviceRepository: Get.find<ServiceRepository>()),
    );
  }
}
