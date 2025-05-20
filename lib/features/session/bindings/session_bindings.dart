// lib/features/session/bindings/session_bindings.dart
import 'package:get/get.dart';
import 'package:emababyspa/data/providers/session_provider.dart';
import 'package:emababyspa/data/repository/session_repository.dart';
import 'package:emababyspa/features/session/controllers/session_controller.dart';
import 'package:emababyspa/data/providers/staff_provider.dart';
import 'package:emababyspa/data/repository/staff_repository.dart';
import 'package:emababyspa/features/staff/controllers/staff_controller.dart';

class SessionBindings extends Bindings {
  @override
  void dependencies() {
    // Initialize session provider if not already done
    if (!Get.isRegistered<SessionProvider>()) {
      Get.put(SessionProvider());
    }

    // Initialize session repository
    Get.lazyPut<SessionRepository>(
      () => SessionRepository(provider: Get.find<SessionProvider>()),
      fenix: true, // Keep alive when navigating
    );

    // Initialize session controller
    Get.lazyPut<SessionController>(
      () => SessionController(repository: Get.find<SessionRepository>()),
      fenix: true, // Keep alive when navigating
    );

    // Ensure staff dependencies are also registered
    if (!Get.isRegistered<StaffProvider>()) {
      Get.put(StaffProvider());
    }

    if (!Get.isRegistered<StaffRepository>()) {
      Get.lazyPut(
        () => StaffRepository(staffProvider: Get.find<StaffProvider>()),
        fenix: true,
      );
    }

    if (!Get.isRegistered<StaffController>()) {
      Get.lazyPut(
        () => StaffController(staffRepository: Get.find<StaffRepository>()),
        fenix: true,
      );
    }
  }
}
