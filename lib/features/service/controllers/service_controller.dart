import 'package:emababyspa/data/repository/staff_repository.dart';
import 'package:get/get.dart';
import 'package:emababyspa/data/repository/service_repository.dart';
import 'package:emababyspa/data/models/service.dart';
import 'package:emababyspa/data/repository/service_category_repository.dart';
import 'package:emababyspa/utils/logger_utils.dart';
import 'package:emababyspa/data/models/service_category.dart';
import 'package:emababyspa/data/models/staff.dart';

class ServiceController extends GetxController {
  final ServiceRepository _serviceRepository;
  late ServiceCategoryRepository _serviceCategoryRepository;
  late StaffRepository _staffRepository;
  final LoggerUtils _logger = LoggerUtils();

  // Observable variables
  final RxList<Service> services = <Service>[].obs;
  final RxList<ServiceCategory> serviceCategories = <ServiceCategory>[].obs;
  final RxList<Staff> staff = <Staff>[].obs;
  final RxBool isLoading = false.obs;

  // Add individual loading state variables for each resource type
  final RxBool isLoadingServices = false.obs;
  final RxBool isLoadingStaff = false.obs;
  final RxBool isLoadingCategories = false.obs;

  final RxString errorMessage = ''.obs;
  final RxString serviceError = ''.obs;
  final RxString categoryError = ''.obs;
  final RxString staffError = ''.obs;

  // dashboard counter
  final RxInt serviceCount = 0.obs;
  final RxInt staffCount = 0.obs;
  final RxInt categoryCount = 0.obs;

  ServiceController({required ServiceRepository serviceRepository})
    : _serviceRepository = serviceRepository {
    _serviceCategoryRepository = Get.find<ServiceCategoryRepository>();
    _staffRepository = Get.find<StaffRepository>();
  }

  @override
  void onInit() {
    super.onInit();
    fetchAllData();
  }

  Future<void> fetchAllData() async {
    isLoading.value = true;
    errorMessage.value = '';
    await fetchServices();
    await fetchCategories();
    await fetchStaff();
    isLoading.value = false;
  }

  // Navigate to service management page
  void navigateToManageServices() {
    // This will be implemented to navigate to the service management page
    Get.toNamed('/services/manage');
  }

  // Navigate to staff management page
  void navigateToManageStaff() {
    // Navigate to staff management view
    Get.toNamed('/staffs');
  }

  // Navigate to category management page
  void navigateToManageCategories() {
    // This will be implemented to navigate to the category management page
    Get.toNamed('/service-categories');
  }

  // Fetch services
  Future<void> fetchServices() async {
    try {
      isLoadingServices.value = true;
      serviceError.value = '';

      final fetchedServices = await _serviceRepository.getAllServices(
        isActive: true,
      );

      services.value = fetchedServices;
      serviceCount.value = fetchedServices.length;
    } catch (e) {
      serviceError.value = e.toString();
      _logger.error('Error fetching services: $e');
    } finally {
      isLoadingServices.value = false;
    }
  }

  // Fetch categories
  Future<void> fetchCategories() async {
    try {
      isLoadingCategories.value = true;
      categoryError.value = '';

      final categories = await _serviceCategoryRepository.getAllCategories();
      serviceCategories.value = categories;
      categoryCount.value = categories.length;
    } catch (e) {
      categoryError.value = e.toString();
      _logger.error('Error fetching service categories: $e');
    } finally {
      isLoadingCategories.value = false;
    }
  }

  // Fetch Staff
  Future<void> fetchStaff() async {
    try {
      isLoadingStaff.value = true;
      staffError.value = '';

      final staffMembers = await _staffRepository.getAllStaffs(isActive: true);
      staff.value = staffMembers;
      staffCount.value = staffMembers.length;
    } catch (e) {
      staffError.value = e.toString();
      _logger.error('Error fetching staff: $e');
    } finally {
      isLoadingStaff.value = false;
    }
  }

  // Refresh the dashboard data
  Future<void> refreshServices() async {
    await fetchServices();
  }

  Future<void> refreshCategories() async {
    await fetchCategories();
  }

  Future<void> refreshStaff() async {
    await fetchStaff();
  }

  Future<void> refreshData() async {
    await fetchAllData();
  }
}
