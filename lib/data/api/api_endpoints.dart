// lib/data/api/api_endpoints.dart

class ApiEndpoints {
  // Base URL
  // base url andorid studio
  //static const String baseUrl = 'http://10.0.2.2:3000/api';
  // base url real device
  static const String baseUrl = 'https://0f53d77f21e9.ngrok-free.app/api';

  // Auth
  static const String login = '/owner/login';
  static const String profile = '/owner/profile';
  static const String updateOwnerPlayerId = '/owner/update-player-id';

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
  static const String reservationsOwnerById = '$reservationsOwner/{id}';
  static const String reservationsOwnerStatusById =
      '$reservationsOwner/{id}/status'; // Matches route: /owner/{id}/status
  static const String manualReservations = '$reservationsOwner/manual';
  static const String reservationsAnalytics = '$reservations/analytics';
  static const String ownerPayment = '$reservationsOwner/payment';
  static const String reservationsOwnerUpcoming = '$reservationsOwner/upcoming';
  static const String reservationsOwnerDashboardUpcomingByDay =
      '$reservationsOwner/dashboard/upcoming-by-day';
  static const String ownerSpecificPaymentMethods =
      '$reservations/owner/payment-methods'; // Matches route: /owner/payment-methods
  static const String manualReservationsPaymentProofById =
      '$manualReservations/{id}/payment-proof'; // Matches route: /manual/{id}/payment-proof
  static const String ownerPaymentVerifyById =
      '$reservationsOwner/payment/{id}/verify';
  static const String reservationsOwnerPaymentDetailsById =
      '$reservationsOwner/payment/{id}';
  static const String manualReservationsPaymentUpdateById =
      '$manualReservations/{id}/payment'; // Matches route: /manual/{id}/payment
  static const String reservationsOwnerUpdateDetailsById =
      '/reservations/owner/details/{id}'; // Perbaiki ini
  static const String reservationsOwnerUpdatePaymentProofById =
      '/reservations/owner/payment-proof/{id}'; // Tambahkan ini
  static const String reservationsOwnerConfirmWithProof =
      '/reservations/owner/manual/{id}/confirm-with-proof';

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

  // notifications
  static const String notifications = '/notifications';
  static const String notificationMarkRead = '/notifications/{id}/read';
}
