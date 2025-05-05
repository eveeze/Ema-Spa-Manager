// lib/features/staff/controllers/staff_controller.dart
import 'package:get/get.dart';
import 'package:emababyspa/data/repository/staff_repository.dart';
import 'package:emababyspa/data/models/staff.dart';
import 'package:emababyspa/utils/logger_utils.dart';

class StaffController extends GetxController {
  final StaffRepository staffRepository;
  final LoggerUtils _logger = LoggerUtils();

  // Observable variables
  final RxList<Staff> staffList = <Staff>[].obs;
  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;
  final RxBool isFormSubmitting = false.obs;

  StaffController({required this.staffRepository});

  @override
  void onInit() {
    super.onInit();
    fetchAllStaff();
  }

  // Fetch all staff members
  Future<void> fetchAllStaff() async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      final fetchedStaff = await staffRepository.getAllStaffs();
      staffList.value = fetchedStaff;
    } catch (e) {
      _logger.error('Error fetching staff: $e');
      errorMessage.value = 'Failed to load staff members. Please try again.';
    } finally {
      isLoading.value = false;
    }
  }

  // Add a new staff member
  Future<bool> addStaff({
    required String name,
    required String email,
    required String phoneNumber,
    String? address,
  }) async {
    try {
      isFormSubmitting.value = true;

      final createdStaff = await staffRepository.createStaff(
        name: name,
        email: email,
        phoneNumber: phoneNumber,
        address: address,
      );

      if (createdStaff != null) {
        staffList.add(createdStaff);
        Get.back();
        Get.snackbar('Success', 'Staff member added successfully');
        return true;
      }
      return false;
    } catch (e) {
      _logger.error('Error adding staff: $e');
      Get.snackbar('Error', 'Failed to add staff member');
      return false;
    } finally {
      isFormSubmitting.value = false;
    }
  }

  // Update an existing staff member
  Future<bool> updateStaff({
    required String id,
    required String name,
    required String email,
    required String phoneNumber,
    String? address,
    required bool isActive,
  }) async {
    try {
      isFormSubmitting.value = true;

      final updatedStaff = await staffRepository.updateStaff(
        id: id,
        name: name,
        email: email,
        phoneNumber: phoneNumber,
        address: address,
        isActive: isActive,
      );

      if (updatedStaff != null) {
        // Update the list with the modified staff member
        final index = staffList.indexWhere((staff) => staff.id == id);
        if (index != -1) {
          staffList[index] = updatedStaff;
          staffList.refresh();
        }

        Get.back();
        Get.snackbar('Success', 'Staff member updated successfully');
        return true;
      }
      return false;
    } catch (e) {
      _logger.error('Error updating staff: $e');
      Get.snackbar('Error', 'Failed to update staff member');
      return false;
    } finally {
      isFormSubmitting.value = false;
    }
  }

  // Toggle staff active status
  Future<void> toggleStaffStatus(Staff staff) async {
    try {
      final updatedStaff = await staffRepository.updateStaffStatus(
        id: staff.id,
        isActive: !staff.isActive,
      );

      if (updatedStaff != null) {
        // Update the list with the modified staff member
        final index = staffList.indexWhere((s) => s.id == staff.id);
        if (index != -1) {
          staffList[index] = updatedStaff;
          staffList.refresh();
        }

        Get.snackbar(
          'Success',
          'Staff status updated to ${updatedStaff.isActive ? 'active' : 'inactive'}',
        );
      }
    } catch (e) {
      _logger.error('Error toggling staff status: $e');
      Get.snackbar('Error', 'Failed to update staff status');
    }
  }

  // Delete a staff member
  Future<void> deleteStaff(String staffId) async {
    try {
      final success = await staffRepository.deleteStaff(staffId);

      if (success) {
        // Remove the staff member from the list
        staffList.removeWhere((staff) => staff.id == staffId);
        Get.snackbar('Success', 'Staff member deleted successfully');
      } else {
        Get.snackbar('Error', 'Failed to delete staff member');
      }
    } catch (e) {
      _logger.error('Error deleting staff: $e');
      Get.snackbar('Error', 'Failed to delete staff member');
    }
  }

  // Navigate to add staff form
  void navigateToAddStaff() {
    Get.toNamed('/staffs/form');
  }

  // Navigate to edit staff form
  void navigateToEditStaff(String staffId) {
    Get.toNamed('/staffs/edit/$staffId');
  }

  // Refresh staff data
  void refreshData() {
    fetchAllStaff();
  }
}
