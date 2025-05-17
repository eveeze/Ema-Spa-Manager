// lib/features/schedule/bindings/schedule_bindings.dart
import 'package:get/get.dart';
import 'package:emababyspa/data/providers/scheduler_provider.dart';
import 'package:emababyspa/data/repository/scheduler_repository.dart';
import 'package:emababyspa/features/schedule/controllers/schedule_controller.dart';
import 'package:emababyspa/features/operating_schedule/controllers/operating_schedule_controller.dart';
import 'package:emababyspa/features/time_slot/controllers/time_slot_controller.dart';
import 'package:emababyspa/features/session/controllers/session_controller.dart';
import 'package:emababyspa/data/repository/operating_schedule_repository.dart';
import 'package:emababyspa/data/repository/time_slot_repository.dart';
import 'package:emababyspa/data/repository/session_repository.dart';
import 'package:emababyspa/data/providers/operating_schedule_provider.dart';
import 'package:emababyspa/data/providers/time_slot_provider.dart';
import 'package:emababyspa/data/providers/session_provider.dart';

class ScheduleBindings extends Bindings {
  @override
  void dependencies() {
    // Register providers if not already registered
    if (!Get.isRegistered<SchedulerProvider>()) {
      Get.lazyPut<SchedulerProvider>(() => SchedulerProvider());
    }

    if (!Get.isRegistered<OperatingScheduleProvider>()) {
      Get.lazyPut<OperatingScheduleProvider>(() => OperatingScheduleProvider());
    }

    if (!Get.isRegistered<TimeSlotProvider>()) {
      Get.lazyPut<TimeSlotProvider>(() => TimeSlotProvider());
    }

    if (!Get.isRegistered<SessionProvider>()) {
      Get.lazyPut<SessionProvider>(() => SessionProvider());
    }

    // Register repositories if not already registered
    if (!Get.isRegistered<SchedulerRepository>()) {
      Get.lazyPut<SchedulerRepository>(
        () => SchedulerRepository(provider: Get.find<SchedulerProvider>()),
      );
    }

    if (!Get.isRegistered<OperatingScheduleRepository>()) {
      Get.lazyPut<OperatingScheduleRepository>(
        () => OperatingScheduleRepository(
          provider: Get.find<OperatingScheduleProvider>(),
        ),
      );
    }

    if (!Get.isRegistered<TimeSlotRepository>()) {
      Get.lazyPut<TimeSlotRepository>(
        () => TimeSlotRepository(provider: Get.find<TimeSlotProvider>()),
      );
    }

    if (!Get.isRegistered<SessionRepository>()) {
      Get.lazyPut<SessionRepository>(
        () => SessionRepository(provider: Get.find<SessionProvider>()),
      );
    }

    // Register dependent controllers if not already registered
    if (!Get.isRegistered<OperatingScheduleController>()) {
      Get.lazyPut<OperatingScheduleController>(
        () => OperatingScheduleController(
          operatingScheduleRepository: Get.find<OperatingScheduleRepository>(),
        ),
      );
    }

    if (!Get.isRegistered<TimeSlotController>()) {
      Get.lazyPut<TimeSlotController>(
        () => TimeSlotController(repository: Get.find<TimeSlotRepository>()),
      );
    }

    if (!Get.isRegistered<SessionController>()) {
      Get.lazyPut<SessionController>(
        () => SessionController(repository: Get.find<SessionRepository>()),
      );
    }

    // Register main controller with dependencies
    Get.lazyPut<ScheduleController>(
      () => ScheduleController(
        schedulerRepository: Get.find<SchedulerRepository>(),
        operatingScheduleController: Get.find<OperatingScheduleController>(),
        timeSlotController: Get.find<TimeSlotController>(),
        sessionController: Get.find<SessionController>(),
        operatingScheduleRepository: Get.find<OperatingScheduleRepository>(),
      ),
    );
  }
}
