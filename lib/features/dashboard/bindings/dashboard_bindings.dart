// lib/features/dashboard/bindings/dashboard_bindings.dart
import 'package:emababyspa/features/reservation/bindings/reservation_bindings.dart'; // Import ReservationBindings
import 'package:get/get.dart';
import 'package:emababyspa/features/dashboard/controllers/dashboard_controller.dart';
// Import ReservationController hanya jika Anda perlu mereferensikan tipenya secara eksplisit di sini,
// namun untuk Get.find() di DashboardController, ini tidak diperlukan jika sudah di-bind dengan benar.
// import 'package:emababyspa/features/reservation/controllers/reservation_controller.dart';

class DashboardBinding implements Bindings {
  @override
  void dependencies() {
    // 1. Pastikan semua dependensi dari fitur reservasi sudah terdaftar.
    // Ini akan mendaftarkan ApiClient, LoggerUtils, ReservationProvider,
    // ReservationRepository, dan ReservationController.
    ReservationBindings().dependencies();

    // 2. Inisialisasi DashboardController.
    // DashboardController pada onInit-nya akan memanggil Get.find<ReservationController>(),
    // yang sekarang seharusnya sudah tersedia berkat pemanggilan ReservationBindings().dependencies() di atas.
    Get.lazyPut<DashboardController>(() => DashboardController(), fenix: true);

    // Komentar di bawah ini menunjukkan bahwa Anda TIDAK PERLU lagi secara eksplisit
    // mendaftarkan ReservationController di sini jika ReservationBindings sudah melakukannya.
    // Pemanggilan Get.find<ReservationRepository>() di dalam konstruktor ReservationController
    // yang dipanggil oleh ReservationBindings juga akan berhasil karena ReservationBindings
    // mendaftarkan ReservationRepository terlebih dahulu.

    // // TIDAK PERLU LAGI jika ReservationBindings().dependencies() dipanggil:
    // if (!Get.isRegistered<ReservationController>()) {
    //   Get.lazyPut<ReservationController>(
    //     () => ReservationController(
    //       // Get.find<ReservationRepository>() di sini akan berhasil
    //       // karena ReservationBindings().dependencies() juga telah mendaftarkannya.
    //       reservationRepository: Get.find<ReservationRepository>(),
    //     ),
    //     fenix: true,
    //   );
    // }

    // Anda masih bisa mendaftarkan controller lain yang spesifik untuk dashboard di sini
    // contoh:
    // Get.lazyPut<ProfileController>(() => ProfileController());
  }
}
