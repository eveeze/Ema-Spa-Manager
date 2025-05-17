// lib/data/providers/scheduler_provider.dart
import 'package:get/get.dart' hide Response;
import 'package:emababyspa/data/api/api_client.dart';
import 'package:emababyspa/data/api/api_endpoints.dart';
import 'package:emababyspa/data/models/scheduler.dart';
import 'package:emababyspa/common/constants/app_constants.dart';

class SchedulerProvider {
  final ApiClient _apiClient = Get.find<ApiClient>();

  /// Generate full schedule (operating schedules, time slots, and sessions)
  Future<ScheduleGenerationResult> generateSchedule({
    String? startDate,
    int? days,
    List<String>? holidayDates,
    TimeConfig? timeConfig,
    int? timeZoneOffset,
  }) async {
    try {
      final Map<String, dynamic> data = {};

      if (startDate != null) data['startDate'] = startDate;
      if (days != null) data['days'] = days;
      if (holidayDates != null) data['holidayDates'] = holidayDates;
      if (timeConfig != null) data['timeConfig'] = timeConfig.toJson();
      if (timeZoneOffset != null) data['timeZoneOffset'] = timeZoneOffset;

      final result = await _apiClient.postValidated(
        ApiEndpoints.generateSchedule,
        data: data,
      );

      return ScheduleGenerationResult.fromJson(result);
    } catch (e) {
      rethrow;
    }
  }

  /// Generate specific schedule components (operating schedules, time slots, or sessions)
  Future<ComponentGenerationResult> generateScheduleComponents({
    required String component,
    List<String>? scheduleIds,
    String? startDate,
    int? days,
    List<String>? holidayDates,
    TimeConfig? timeConfig,
    int? timeZoneOffset,
    Map<String, List<String>>? timeSlotsBySchedule,
  }) async {
    try {
      final Map<String, dynamic> data = {'component': component};

      if (scheduleIds != null) data['scheduleIds'] = scheduleIds;
      if (startDate != null) data['startDate'] = startDate;
      if (days != null) data['days'] = days;
      if (holidayDates != null) data['holidayDates'] = holidayDates;
      if (timeConfig != null) data['timeConfig'] = timeConfig.toJson();
      if (timeZoneOffset != null) data['timeZoneOffset'] = timeZoneOffset;
      if (timeSlotsBySchedule != null) {
        data['timeSlotsBySchedule'] = timeSlotsBySchedule;
      }

      final result = await _apiClient.postValidated(
        ApiEndpoints.generateScheduleComponents,
        data: data,
      );

      return ComponentGenerationResult.fromJson(result);
    } catch (e) {
      rethrow;
    }
  }

  /// Run scheduled generation manually
  Future<ScheduleGenerationResult> runScheduledGeneration() async {
    try {
      // You may need to add a secret key if required by your API
      final secret =
          AppConstants
              .schedulerSecret; // If you have a secret key in local storage, get it here

      final result = await _apiClient.getValidated(
        ApiEndpoints.cronScheduleGeneration,
        queryParameters: secret.isNotEmpty ? {'secret': secret} : null,
      );

      return ScheduleGenerationResult.fromJson(result);
    } catch (e) {
      rethrow;
    }
  }
}
