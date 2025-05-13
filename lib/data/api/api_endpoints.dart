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
  static const String reservationDetail = '/reservations/{id}';
  static const String createReservation = '/reservations/create';
  static const String updateReservationStatus = '/reservations/{id}/status';

  // Payments
  static const String payments = '/payments';
  static const String paymentDetail = '/payments/{id}';
  static const String updatePaymentStatus = '/payments/{id}/status';

  // Operating Schedule
  static const String operatingSchedules = '/operating-schedules';
  static const String operatingScheduleDetail = '/operating-schedules/{id}';
  static const String operatingScheduleByDate =
      '/operating-schedules/date/{date}';
  // Time Slots
  static const String timeSlots = '/time-slots';
  static const String sessions = '/sessions';
  // scheduler
  static const String scheduleGenerate = '/scheduler/generate';
  static const String scheduleGenerateComponents =
      '/scheduler/generate/components';
  static const String scheduleCron = '/scheduler/cron';
  // Analytics
  static const String analytics = '/analytics';
  static const String dailyAnalytics = '/analytics/daily';
  static const String monthlyAnalytics = '/analytics/monthly';

  // Notifications
  static const String notifications = '/notifications';
  static const String markNotificationRead = '/notifications/{id}/read';
}
