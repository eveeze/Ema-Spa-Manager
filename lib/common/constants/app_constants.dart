class AppConstants {
  // App Information
  static const String appName = 'Ema Baby Spa';
  static const String appVersion = '1.0.0';
  static const String appBuildNumber = '1';
  static const String appPackageName = 'com.emababyspa.app';

  // Navigation Routes
  static const String routeSplash = '/splash';
  static const String routeOnboarding = '/onboarding';
  static const String routeLogin = '/login';
  static const String routeRegister = '/register';
  static const String routeForgotPassword = '/forgot-password';
  static const String routeHome = '/home';
  static const String routeProfile = '/profile';
  static const String routeSettings = '/settings';
  static const String routeAppointments = '/appointments';
  static const String routeServices = '/services';
  static const String routeServiceDetails = '/service-details';
  static const String routeBooking = '/booking';
  static const String routeNotifications = '/notifications';

  // Animation Durations
  static const int splashDuration = 2000; // milliseconds
  static const int shortAnimationDuration = 300; // milliseconds
  static const int mediumAnimationDuration = 500; // milliseconds
  static const int longAnimationDuration = 800; // milliseconds

  // Pagination
  static const int paginationDefaultLimit = 10;

  // Default Values
  static const double defaultPadding = 16.0;
  static const double defaultBorderRadius = 8.0;
  static const double defaultSpacing = 8.0;

  // Date Formats
  static const String dateFormatDisplay = 'MMM dd, yyyy';
  static const String timeFormatDisplay = 'hh:mm a';
  static const String dateTimeFormatDisplay = 'MMM dd, yyyy hh:mm a';
  static const String dateFormatApi = 'yyyy-MM-dd';
  static const String timeFormatApi = 'HH:mm:ss';
  static const String dateTimeFormatApi = 'yyyy-MM-dd\'T\'HH:mm:ss';
}
