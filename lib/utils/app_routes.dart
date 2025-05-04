//utils/app_routes.dart
import 'package:get/get.dart';
import 'package:emababyspa/common/constants/app_constants.dart';
import 'package:emababyspa/features/splash/view/splash_view.dart';
import 'package:emababyspa/features/splash/bindings/splash_bindings.dart';
import 'package:emababyspa/features/authentication/bindings/auth_bindings.dart';
import 'package:emababyspa/features/authentication/views/login/login_view.dart';
// import 'package:emababyspa/features/auth/bindings/auth_binding.dart';
// import 'package:emababyspa/features/dashboard/views/dashboard_view.dart';
// import 'package:emababyspa/features/dashboard/bindings/dashboard_binding.dart';
// import 'package:emababyspa/features/splash/bindings/splash_binding.dart';
// import 'package:emababyspa/features/staffs/views/staff_list_view.dart';
// import 'package:emababyspa/features/staffs/bindings/staff_binding.dart';
// import 'package:emababyspa/features/services/views/service_list_view.dart';
// import 'package:emababyspa/features/services/bindings/service_binding.dart';
// import 'package:emababyspa/features/customers/views/customer_list_view.dart';
// import 'package:emababyspa/features/customers/bindings/customer_binding.dart';
// import 'package:emababyspa/features/reservations/views/reservation_list_view.dart';
// import 'package:emababyspa/features/reservations/bindings/reservation_binding.dart';
// import 'package:emababyspa/features/payments/views/payment_list_view.dart';
// import 'package:emababyspa/features/payments/bindings/payment_binding.dart';
// import 'package:emababyspa/features/schedule/views/schedule_view.dart';
// import 'package:emababyspa/features/schedule/bindings/schedule_binding.dart';
// import 'package:emababyspa/features/analytics/views/analytics_view.dart';
// import 'package:emababyspa/features/analytics/bindings/analytics_binding.dart';

class AppRoutes {
  static const String splash = AppConstants.routeSplash;
  static const String login = AppConstants.routeLogin;
  static const String forgotPassword = '/forgotPassword';
  static const String dashboard = '/dashboard';
  static const String staffList = '/staffs';
  static const String staffDetail = '/staffs/:id';
  static const String staffForm = '/staffs/form';
  static const String staffEdit = '/staffs/edit/:id';
  static const String serviceList = '/services';
  static const String serviceDetail = '/services/:id';
  static const String serviceForm = '/services/form';
  static const String serviceEdit = '/services/edit/:id';
  static const String customerList = '/customers';
  static const String customerDetail = '/customers/:id';
  static const String reservationList = '/reservations';
  static const String reservationDetail = '/reservations/:id';
  static const String reservationForm = '/reservations/form';
  static const String paymentList = '/payments';
  static const String paymentDetail = '/payments/:id';
  static const String schedule = '/schedule';
  static const String analytics = '/analytics';

  static final List<GetPage> pages = [
    GetPage(
      name: splash,
      page: () => SplashScreen(),
      binding: SplashBindings(),
    ),
    GetPage(name: login, page: () => LoginView(), binding: AuthBindings()),
    // GetPage(
    //   name: dashboard,
    //   page: () => DashboardView(),
    //   binding: DashboardBinding(),
    // ),
    // GetPage(
    //   name: staffList,
    //   page: () => StaffListView(),
    //   binding: StaffBinding(),
    // ),
    // GetPage(
    //   name: serviceList,
    //   page: () => ServiceListView(),
    //   binding: ServiceBinding(),
    // ),
    // GetPage(
    //   name: customerList,
    //   page: () => CustomerListView(),
    //   binding: CustomerBinding(),
    // ),
    // GetPage(
    //   name: reservationList,
    //   page: () => ReservationListView(),
    //   binding: ReservationBinding(),
    // ),
    // GetPage(
    //   name: paymentList,
    //   page: () => PaymentListView(),
    //   binding: PaymentBinding(),
    // ),
    // GetPage(
    //   name: schedule,
    //   page: () => ScheduleView(),
    //   binding: ScheduleBinding(),
    // ),
    // GetPage(
    //   name: analytics,
    //   page: () => AnalyticsView(),
    //   binding: AnalyticsBinding(),
    // ),
    // Rute detail dan form akan ditambahkan disini
  ];
}
