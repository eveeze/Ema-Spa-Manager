// lib/features/dashboard/bindings/dashboard_bindings.dart
import 'package:emababyspa/data/providers/analytics_provider.dart';
import 'package:emababyspa/data/repository/analytics_repository.dart';
import 'package:emababyspa/features/reservation/bindings/reservation_bindings.dart';
import 'package:get/get.dart';
import 'package:emababyspa/features/dashboard/controllers/dashboard_controller.dart';

class DashboardBinding implements Bindings {
  @override
  void dependencies() {
    // Daftarkan dependensi untuk fitur lain yang dibutuhkan dashboard
    ReservationBindings().dependencies();

    // BARU: Daftarkan dependensi untuk Analytics agar bisa di-inject
    // ke DashboardController.
    Get.lazyPut<AnalyticsProvider>(() => AnalyticsProvider());
    Get.lazyPut<AnalyticsRepository>(
      () => AnalyticsRepository(analyticsProvider: Get.find()),
    );

    // DIUBAH: Inject AnalyticsRepository ke dalam DashboardController
    Get.lazyPut<DashboardController>(
      () => DashboardController(analyticsRepository: Get.find()),
      fenix: true,
    );
  }
}
