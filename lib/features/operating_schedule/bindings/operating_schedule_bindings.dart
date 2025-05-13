// lib/features/operating_schedule/bindings/operating_schedule_bindings.dart
import 'package:get/get.dart';
import 'package:emababyspa/data/providers/operating_schedule_provider.dart';
import 'package:emababyspa/data/repository/operating_schedule_repository.dart';
import 'package:emababyspa/features/operating_schedule/controllers/operating_schedule_controller.dart';

class OperatingScheduleBindings extends Bindings {
  @override
  void dependencies() {
    // Register provider
    Get.lazyPut<OperatingScheduleProvider>(() => OperatingScheduleProvider());

    // Register repository
    Get.lazyPut<OperatingScheduleRepository>(
      () => OperatingScheduleRepository(
        provider: Get.find<OperatingScheduleProvider>(),
      ),
    );

    // Register controller
    Get.lazyPut<OperatingScheduleController>(
      () => OperatingScheduleController(
        operatingScheduleRepository: Get.find<OperatingScheduleRepository>(),
      ),
    );
  }
}
