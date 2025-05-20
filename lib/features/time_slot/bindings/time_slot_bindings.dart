// lib/features/time_slot/bindings/time_slot_binding.dart
import 'package:emababyspa/data/providers/staff_provider.dart';
import 'package:emababyspa/data/repository/operating_schedule_repository.dart';
import 'package:emababyspa/data/repository/staff_repository.dart';
import 'package:emababyspa/features/operating_schedule/controllers/operating_schedule_controller.dart';
import 'package:emababyspa/features/staff/controllers/staff_controller.dart';
import 'package:get/get.dart';
import 'package:emababyspa/data/providers/time_slot_provider.dart';
import 'package:emababyspa/data/repository/time_slot_repository.dart';
import 'package:emababyspa/features/time_slot/controllers/time_slot_controller.dart';

class TimeSlotBinding implements Bindings {
  @override
  void dependencies() {
    // Staff dependencies
    if (!Get.isRegistered<StaffProvider>()) {
      Get.put(StaffProvider());
    }

    if (!Get.isRegistered<StaffRepository>()) {
      Get.lazyPut(
        () => StaffRepository(staffProvider: Get.find<StaffProvider>()),
        fenix: true, // Keep alive when navigating
      );
    }

    if (!Get.isRegistered<StaffController>()) {
      Get.lazyPut(
        () => StaffController(staffRepository: Get.find<StaffRepository>()),
        fenix: true, // Keep alive when navigating
      );
    }

    // TimeSlot dependencies
    if (!Get.isRegistered<TimeSlotProvider>()) {
      Get.lazyPut(() => TimeSlotProvider(), fenix: true);
    }

    if (!Get.isRegistered<TimeSlotRepository>()) {
      Get.lazyPut(
        () => TimeSlotRepository(provider: Get.find<TimeSlotProvider>()),
        fenix: true,
      );
    }

    // OperatingSchedule dependency
    if (!Get.isRegistered<OperatingScheduleController>()) {
      Get.lazyPut(
        () => OperatingScheduleController(
          operatingScheduleRepository: Get.find<OperatingScheduleRepository>(),
        ),
        fenix: true,
      );
    }

    // TimeSlotController
    if (!Get.isRegistered<TimeSlotController>()) {
      Get.lazyPut<TimeSlotController>(
        () => TimeSlotController(repository: Get.find<TimeSlotRepository>()),
        fenix: true,
      );
    }
  }
}
