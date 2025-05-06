// lib/features/staff/controllers/staff_controller.dart
import 'package:get/get.dart';
import 'dart:io';
import 'package:emababyspa/data/models/staff.dart';
import 'package:emababyspa/data/repository/staff_repository.dart';
import 'package:emababyspa/utils/app_routes.dart';
import 'package:emababyspa/common/theme/color_theme.dart';
import 'package:emababyspa/utils/logger_utils.dart';

class StaffController extends GetxController {
  final StaffRepository _staffRepository;
  final LoggerUtils _logger = LoggerUtils();
  StaffController({required StaffRepository staffRepository})
    : _staffRepository = staffRepository;
  // Observable state
  final RxList<Staff> staffList = <Staff>[].obs;
  final RxBool isLoading = false.obs;
  final RxBool isFormSubmitting = false.obs;
  final RxString errorMessage = ''.obs;

  @override
  void onInit() {
    super.onInit();
    fetchAllStaffs();
  }

  // Fetch all staff members
  Future<void> fetchAllStaffs() async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      final staffs = await _staffRepository.getAllStaffs();
      staffList.value = staffs;
    } catch (e) {
      errorMessage.value = 'Failed to load staff members. Please try again.';
      _logger.error('Error fetching staffs: $e');
    } finally {
      isLoading.value = false;
    }
  }

  // Refresh data
  void refreshData() {
    fetchAllStaffs();
  }

  // Navigate to add staff screen
  void navigateToAddStaff() {
    Get.toNamed(AppRoutes.staffForm);
  }

  // Navigate to edit staff screen
  void navigateToEditStaff(String id) {
    // FIXED: Proper parameter handling for dynamic route
    Get.toNamed('/staffs/edit/$id');

    // Debug log to verify the ID is being passed
    print('Navigating to edit staff with ID: $id');
  }

  // Add new staff member
  Future<void> addStaff({
    required String name,
    required String email,
    required String phoneNumber,
    String? address,
    File? profilePicture,
  }) async {
    try {
      isFormSubmitting.value = true;

      final staff = await _staffRepository.createStaff(
        name: name,
        email: email,
        phoneNumber: phoneNumber,
        address: address,
        profilePicture: profilePicture,
      );

      if (staff != null) {
        // Add to list if successful
        staffList.add(staff);

        // Show success message
        Get.snackbar(
          'Success',
          'Staff member added successfully',
          backgroundColor: ColorTheme.success.withOpacity(0.1),
          colorText: ColorTheme.success,
        );

        // Navigate back
        Get.back();
      }
    } catch (e) {
      // Show error message
      Get.snackbar(
        'Error',
        'Failed to add staff member',
        backgroundColor: ColorTheme.error.withOpacity(0.1),
        colorText: ColorTheme.error,
      );
      _logger.error('Error adding staff: $e');
    } finally {
      isFormSubmitting.value = false;
    }
  }

  // Update staff member
  Future<void> updateStaff({
    required String id,
    required String name,
    required String email,
    required String phoneNumber,
    String? address,
    required bool isActive,
    File? profilePicture,
  }) async {
    try {
      isFormSubmitting.value = true;

      final staff = await _staffRepository.updateStaff(
        id: id,
        name: name,
        email: email,
        phoneNumber: phoneNumber,
        address: address,
        isActive: isActive,
        profilePicture: profilePicture,
      );

      if (staff != null) {
        // Update list item if successful
        final index = staffList.indexWhere((s) => s.id == id);
        if (index != -1) {
          staffList[index] = staff;
          staffList.refresh();
        }

        // Show success message
        Get.snackbar(
          'Success',
          'Staff member updated successfully',
          backgroundColor: ColorTheme.success.withOpacity(0.1),
          colorText: ColorTheme.success,
        );

        // Navigate back
        Get.back();
      }
    } catch (e) {
      // Show error message
      Get.snackbar(
        'Error',
        'Failed to update staff member',
        backgroundColor: ColorTheme.error.withOpacity(0.1),
        colorText: ColorTheme.error,
      );
      _logger.error('Error updating staff: $e');
    } finally {
      isFormSubmitting.value = false;
    }
  }

  // Toggle staff active status
  Future<void> toggleStaffStatus(Staff staff) async {
    try {
      final updatedStaff = await _staffRepository.updateStaffStatus(
        id: staff.id,
        isActive: !staff.isActive,
      );

      if (updatedStaff != null) {
        // Update list item if successful
        final index = staffList.indexWhere((s) => s.id == staff.id);
        if (index != -1) {
          staffList[index] = updatedStaff;
          staffList.refresh();
        }

        // Show success message
        Get.snackbar(
          'Success',
          'Staff status updated successfully',
          backgroundColor: ColorTheme.success.withOpacity(0.1),
          colorText: ColorTheme.success,
        );
      }
    } catch (e) {
      // Show error message
      Get.snackbar(
        'Error',
        'Failed to update staff status',
        backgroundColor: ColorTheme.error.withOpacity(0.1),
        colorText: ColorTheme.error,
      );
      _logger.error('Error toggling staff status: $e');
    }
  }

  // Delete staff member
  Future<void> deleteStaff(String id) async {
    try {
      final isDeleted = await _staffRepository.deleteStaff(id);

      if (isDeleted) {
        // Remove from list if successful
        staffList.removeWhere((staff) => staff.id == id);

        // Show success message
        Get.snackbar(
          'Success',
          'Staff member deleted successfully',
          backgroundColor: ColorTheme.success.withOpacity(0.1),
          colorText: ColorTheme.success,
        );
      }
    } catch (e) {
      // Show error message
      Get.snackbar(
        'Error',
        'Failed to delete staff member',
        backgroundColor: ColorTheme.error.withOpacity(0.1),
        colorText: ColorTheme.error,
      );
      _logger.error('Error deleting staff: $e');
    }
  }

  Future<Staff?> fetchStaffById(String id) async {
    try {
      isLoading.value = true;

      // Validate id
      if (id.isEmpty) {
        throw Exception("Staff ID is required");
      }

      // Example API call to fetch staff by ID
      final response = await _staffRepository.getStaffById(id);

      // Debug log
      print('Fetched staff with ID: $id - ${response?.name ?? "Not found"}');

      return response;
    } catch (e) {
      errorMessage.value = 'Failed to fetch staff: ${e.toString()}';
      return null;
    } finally {
      isLoading.value = false;
    }
  }
}
