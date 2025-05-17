// lib/features/time_slot/bindings/time_slot_binding.dart
import 'package:get/get.dart';
import 'package:emababyspa/data/providers/time_slot_provider.dart';
import 'package:emababyspa/data/repository/time_slot_repository.dart';
import 'package:emababyspa/features/time_slot/controllers/time_slot_controller.dart';

class TimeSlotBinding implements Bindings {
  @override
  void dependencies() {
    Get.lazyPut<TimeSlotProvider>(() => TimeSlotProvider());

    Get.lazyPut<TimeSlotRepository>(
      () => TimeSlotRepository(provider: Get.find<TimeSlotProvider>()),
    );

    Get.lazyPut<TimeSlotController>(
      () => TimeSlotController(repository: Get.find<TimeSlotRepository>()),
    );
  }
}
