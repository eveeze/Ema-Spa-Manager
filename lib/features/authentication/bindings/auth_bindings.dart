// lib/features/authentication/bindings/auth_bindings.dart
import 'package:get/get.dart';
import 'package:emababyspa/features/authentication/controllers/auth_controller.dart';

class AuthBindings extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<AuthController>(
      () => AuthController(repository: Get.find()),
      fenix: true,
    );
  }
}
