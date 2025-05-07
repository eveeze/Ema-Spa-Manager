// lib/features/service_category/bindings/service_category_bindings.dart

import 'package:get/get.dart';
import 'package:emababyspa/data/providers/service_category_provider.dart';
import 'package:emababyspa/data/repository/service_category_repository.dart';
import 'package:emababyspa/features/service_category/controllers/service_category_controller.dart';

class ServiceCategoryBindings extends Bindings {
  @override
  void dependencies() {
    // Register the service category provider if not already registered
    if (!Get.isRegistered<ServiceCategoryProvider>()) {
      Get.put(ServiceCategoryProvider());
    }

    // Register the service category repository
    if (!Get.isRegistered<ServiceCategoryRepository>()) {
      Get.lazyPut(() => ServiceCategoryRepository());
    }

    // Register the service category controller
    Get.lazyPut(
      () => ServiceCategoryController(
        serviceCategoryRepository: Get.find<ServiceCategoryRepository>(),
      ),
    );
  }
}
