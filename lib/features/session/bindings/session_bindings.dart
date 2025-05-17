// lib/session/bindings/session_bindings.dart
import 'package:get/get.dart';
import 'package:emababyspa/data/providers/session_provider.dart';
import 'package:emababyspa/data/repository/session_repository.dart';
import 'package:emababyspa/features/session/controllers/session_controller.dart';

class SessionBindings extends Bindings {
  @override
  void dependencies() {
    // Initialize provider if not already done
    if (!Get.isRegistered<SessionProvider>()) {
      Get.put(SessionProvider());
    }

    // Initialize repository
    Get.lazyPut<SessionRepository>(
      () => SessionRepository(provider: Get.find<SessionProvider>()),
    );

    // Initialize controller
    Get.lazyPut<SessionController>(
      () => SessionController(repository: Get.find<SessionRepository>()),
    );
  }
}
