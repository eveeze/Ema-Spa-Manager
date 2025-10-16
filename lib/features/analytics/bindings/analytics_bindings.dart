// lib/features/analytics/bindings/analytics_bindings.dart
import 'package:get/get.dart';
import 'package:emababyspa/data/providers/analytics_provider.dart';
import 'package:emababyspa/data/repository/analytics_repository.dart';
import 'package:emababyspa/features/analytics/controllers/analytics_controller.dart';

class AnalyticsBinding implements Bindings {
  @override
  void dependencies() {
    // Mendaftarkan Provider, yang bertanggung jawab untuk panggilan API mentah.
    // Dibuat sekali saat dibutuhkan.
    Get.lazyPut<AnalyticsProvider>(() => AnalyticsProvider());

    // Mendaftarkan Repository, yang menggunakan Provider untuk mengambil
    // dan mem-parsing data menjadi model Dart yang kuat.
    Get.lazyPut<AnalyticsRepository>(
      () => AnalyticsRepository(analyticsProvider: Get.find()),
    );

    // Mendaftarkan Controller, yang akan digunakan oleh AnalyticsView.
    // Controller ini mengambil data dari Repository dan mengelola state UI.
    Get.lazyPut<AnalyticsController>(
      () => AnalyticsController(analyticsRepository: Get.find()),
    );
  }
}
