// lib/features/staff/bindings/staff_bindings.dart
import 'package:get/get.dart';
import 'package:emababyspa/data/providers/staff_provider.dart';
import 'package:emababyspa/data/repository/staff_repository.dart';
import 'package:emababyspa/features/staff/controllers/staff_controller.dart';

class StaffBindings extends Bindings {
  @override
  void dependencies() {
    // Register the staff provider if not already registered
    if (!Get.isRegistered<StaffProvider>()) {
      Get.put(StaffProvider());
    }

    // Register the staff repository
    if (!Get.isRegistered<StaffRepository>()) {
      Get.lazyPut(() => StaffRepository());
    }

    // Register the staff controller
    Get.lazyPut(
      () => StaffController(staffRepository: Get.find<StaffRepository>()),
    );
  }
}
