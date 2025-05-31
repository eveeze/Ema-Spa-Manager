// lib/data/api/api_endpoints.dart

class ApiEndpoints {
  // Base URL
  static const String baseUrl = 'http://10.0.2.2:3000/api';

  // Auth
  static const String login = '/owner/login';
  static const String profile = '/owner/profile';

  // Staff
  static const String staffs = '/staff';
  static const String staffDetail = '/staff/{id}';

  // Services Category
  static const String serviceCategories = '/service-category';
  static const String serviceCategoryDetail = '/service-category/{id}';

  // Services
  static const String services = '/service';
  static const String serviceDetail = '/service/{id}';
  static const String serviceByCategory = '/service/category/{categoryId}';

  // Customers
  static const String customers = '/customers';
  static const String customerDetail = '/customers/{id}';

  // Reservations
  static const String reservations = '/reservations';
  static const String reservationsOwner = '$reservations/owner';
  static const String manualReservations = '$reservationsOwner/manual';
  static const String reservationsAnalytics = '$reservations/analytics';
  static const String ownerPayment = '$reservationsOwner/payment';
  // Payments
  static const String payments = '/payments';
  static const String paymentDetail = '/payments/{id}';
  static const String updatePaymentStatus = '/payments/{id}/status';

  // Operating Schedule
  static const String operatingSchedules = '/operating-schedule';
  static const String operatingScheduleDetail = '/operating-schedule/{id}';
  static const String operatingScheduleByDate =
      '/operating-schedule/date/{date}';
  // Time Slots
  static const String timeSlots = '/time-slot';
  static const String timeSlotDetail = '/time-slot/{id}';
  // session
  static const String sessions = '/session';

  // scheduler
  static const String generateSchedule = '/api/scheduler/generate';
  static const String generateScheduleComponents =
      '/api/scheduler/generate/components';
  static const String cronScheduleGeneration = '/api/scheduler/cron';
}
