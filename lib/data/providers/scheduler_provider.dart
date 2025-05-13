import 'package:get/get.dart' hide Response;
import 'package:emababyspa/data/api/api_client.dart';
import 'package:emababyspa/data/api/api_endpoints.dart';

class SchedulerProvider {
  final ApiClient _apiClient = Get.find<ApiClient>();

  /// Generate a complete schedule (operating schedules, time slots, and sessions)
  Future<dynamic> generateSchedule({
    String? startDate,
    int? days,
    List<String>? holidayDates,
    Map<String, dynamic>? timeConfig,
    int? timeZoneOffset,
  }) async {
    try {
      Map<String, dynamic> data = {};

      if (startDate != null) data['startDate'] = startDate;
      if (days != null) data['days'] = days;
      if (holidayDates != null) data['holidayDates'] = holidayDates;
      if (timeConfig != null) data['timeConfig'] = timeConfig;
      if (timeZoneOffset != null) data['timeZoneOffset'] = timeZoneOffset;

      return await _apiClient.postValidated(
        ApiEndpoints.scheduleGenerate,
        data: data,
      );
    } catch (e) {
      rethrow;
    }
  }

  /// Generate specific schedule components (operating schedules, time slots, or sessions)
  Future<dynamic> generateScheduleComponents({
    required String component,
    List<String>? scheduleIds,
    String? startDate,
    int? days,
    List<String>? holidayDates,
    Map<String, dynamic>? timeConfig,
    int? timeZoneOffset,
    Map<String, List<dynamic>>? timeSlotsBySchedule,
  }) async {
    try {
      Map<String, dynamic> data = {'component': component};

      if (scheduleIds != null) data['scheduleIds'] = scheduleIds;
      if (startDate != null) data['startDate'] = startDate;
      if (days != null) data['days'] = days;
      if (holidayDates != null) data['holidayDates'] = holidayDates;
      if (timeConfig != null) data['timeConfig'] = timeConfig;
      if (timeZoneOffset != null) data['timeZoneOffset'] = timeZoneOffset;
      if (timeSlotsBySchedule != null) {
        data['timeSlotsBySchedule'] = timeSlotsBySchedule;
      }

      return await _apiClient.postValidated(
        ApiEndpoints.scheduleGenerateComponents,
        data: data,
      );
    } catch (e) {
      rethrow;
    }
  }

  /// Trigger a scheduled generation (usually called by a cron job)
  Future<dynamic> runScheduledGeneration({String? secret}) async {
    try {
      Map<String, dynamic> queryParameters = {};

      if (secret != null) {
        queryParameters['secret'] = secret;
      }

      return await _apiClient.getValidated(
        ApiEndpoints.scheduleCron,
        queryParameters: queryParameters,
      );
    } catch (e) {
      rethrow;
    }
  }
}
