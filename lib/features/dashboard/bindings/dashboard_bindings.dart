// lib/features/dashboard/bindings/dashboard_bindings.dart
import 'package:get/get.dart';
import 'package:emababyspa/features/dashboard/controllers/dashboard_controller.dart';

class DashboardBinding implements Bindings {
  @override
  void dependencies() {
    // Initialize the DashboardController
    Get.lazyPut<DashboardController>(() => DashboardController());

    // Here you can also initialize other controllers that might be needed
    // for the dashboard and its child pages

    // For example:
    // Get.lazyPut<HomeController>(() => HomeController());
    // Get.lazyPut<AppointmentsController>(() => AppointmentsController());
    // Get.lazyPut<ClientsController>(() => ClientsController());
    // Get.lazyPut<ProfileController>(() => ProfileController());
  }
}
