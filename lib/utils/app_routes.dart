//utils/app_routes.dart
import 'package:emababyspa/features/service/views/service_edit_view.dart';
import 'package:emababyspa/features/service/views/service_form_view.dart';
import 'package:emababyspa/features/service/views/service_manage_view.dart';
import 'package:emababyspa/features/service_category/views/service_category_form_view.dart';
import 'package:get/get.dart';
import 'package:emababyspa/features/splash/views/splash_view.dart';
import 'package:emababyspa/features/splash/bindings/splash_bindings.dart';
import 'package:emababyspa/features/authentication/bindings/auth_bindings.dart';
import 'package:emababyspa/features/authentication/views/login/login_view.dart';
import 'package:emababyspa/features/dashboard/views/dashboard_view.dart';
import 'package:emababyspa/features/dashboard/bindings/dashboard_bindings.dart';
import 'package:emababyspa/features/service/views/service_view.dart';
import 'package:emababyspa/features/service/bindings/service_bindings.dart';
import 'package:emababyspa/features/staff/views/staff_view.dart';
import 'package:emababyspa/features/staff/views/staff_form_view.dart';
import 'package:emababyspa/features/staff/views/staff_edit_view.dart';
import 'package:emababyspa/features/staff/bindings/staff_bindings.dart';
import 'package:emababyspa/features/service_category/views/service_category_view.dart';
import 'package:emababyspa/features/service_category/bindings/service_category_bindings.dart';
import 'package:emababyspa/features/service_category/views/service_category_edit_view.dart';

class AppRoutes {
  static const String splash = '/splash';
  static const String login = '/login';
  static const String forgotPassword = '/forgotPassword';
  static const String dashboard = '/dashboard';
  static const String services = '/services';
  static const String staffList = '/staffs';
  static const String staffDetail = '/staffs/:id';
  static const String staffForm = '/staffs/form';
  static const String staffEdit = '/staffs/edit/:id';
  static const String serviceCategoryList = '/service-categories';
  static const String serviceCategoryForm = '/service-categories/form';
  static const String serviceCategoryEdit = '/service-categories/edit/:id';
  static const String serviceList = '/services';
  static const String serviceManage = '/services/manage';
  static const String serviceDetail = '/services/:id';
  static const String serviceForm = '/services/form';
  static const String serviceEdit = '/services/edit/:id';
  static const String operatingScheduleList = '/operating-schedules';
  static const String operatingScheduleDetail = '/operating-schedules/:id';
  static const String operatingScheduleForm = '/operating-schedules/form';
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
    GetPage(
      name: dashboard,
      page: () => DashboardView(),
      binding: DashboardBinding(),
    ),

    GetPage(
      name: services,
      page: () => ServiceView(),
      binding: ServiceBindings(),
    ),

    GetPage(
      name: serviceManage,
      page: () => ServiceManageView(),
      binding: ServiceBindings(),
    ),
    GetPage(
      name: serviceForm,
      page: () => ServiceFormView(),
      binding: ServiceBindings(),
    ),
    GetPage(
      name: serviceEdit,
      page: () => ServiceEditView(),
      binding: ServiceBindings(),
    ),

    // Staff routes
    GetPage(name: staffList, page: () => StaffView(), binding: StaffBindings()),
    GetPage(
      name: staffForm,
      page: () => StaffFormView(),
      binding: StaffBindings(),
    ),
    GetPage(
      name: staffEdit,
      page: () => StaffEditView(),
      binding: StaffBindings(),
    ),
    // service category routes
    GetPage(
      name: serviceCategoryList,
      page: () => ServiceCategoryView(),
      binding: ServiceCategoryBindings(),
    ),
    GetPage(
      name: serviceCategoryForm,
      page: () => ServiceCategoryFormView(),
      binding: ServiceCategoryBindings(),
    ),

    GetPage(
      name: serviceCategoryEdit,
      page: () => ServiceCategoryEditView(),
      binding: ServiceCategoryBindings(),
    ),

    // schedule routes

    // Rute detail dan form akan ditambahkan disini
  ];
}
