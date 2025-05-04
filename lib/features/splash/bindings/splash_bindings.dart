// lib/features/splash/bindings/splash_bindings.dart

import 'package:get/get.dart';
import 'package:emababyspa/features/splash/controllers/splash_controller.dart';
import 'package:emababyspa/utils/storage_utils.dart';

class SplashBindings extends Bindings {
  @override
  void dependencies() {
    // Ensure StorageUtils is registered first if it's not already
    if (!Get.isRegistered<StorageUtils>()) {
      Get.put(StorageUtils());
    }

    // Register the SplashController
    Get.put(SplashController());
  }
}
