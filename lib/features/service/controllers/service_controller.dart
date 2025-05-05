// lib/features/service/controllers/service_controller.dart
import 'package:get/get.dart';
import 'package:emababyspa/data/repository/service_repository.dart';
import 'package:emababyspa/data/models/service.dart';

class ServiceController extends GetxController {
  final ServiceRepository _serviceRepository;

  // Observable variables
  final RxList<Service> services = <Service>[].obs;
  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;

  // Dummy counters for dashboard - these will be replaced with actual data later
  final RxInt serviceCount = 0.obs;
  final RxInt staffCount = 0.obs;
  final RxInt categoryCount = 0.obs;

  ServiceController({required ServiceRepository serviceRepository})
    : _serviceRepository = serviceRepository;

  @override
  void onInit() {
    super.onInit();
    fetchServices();
    // Initialize with dummy data for now
    _loadDummyData();
  }

  // Load dummy data for the dashboard metrics
  void _loadDummyData() {
    serviceCount.value = 15;
    staffCount.value = 8;
    categoryCount.value = 5;
  }

  // Navigate to service management page
  void navigateToManageServices() {
    // This will be implemented to navigate to the service management page
    Get.toNamed('/services/manage');
  }

  // Navigate to staff management page
  void navigateToManageStaff() {
    // This will be implemented to navigate to the staff management page
    Get.toNamed('/staff/manage');
  }

  // Navigate to category management page
  void navigateToManageCategories() {
    // This will be implemented to navigate to the category management page
    Get.toNamed('/categories/manage');
  }

  // Fetch services
  Future<void> fetchServices() async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      final fetchedServices = await _serviceRepository.getAllServices(
        isActive: true,
      );

      services.value = fetchedServices;
      serviceCount.value = fetchedServices.length;
    } catch (e) {
      errorMessage.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }

  // Refresh the dashboard data
  void refreshData() {
    fetchServices();
    // In the future, add methods to fetch staff and category counts
  }
}
