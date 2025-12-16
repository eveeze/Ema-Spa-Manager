import 'dart:io';

import 'package:emababyspa/data/models/staff.dart';
import 'package:emababyspa/data/repository/staff_repository.dart';
import 'package:emababyspa/utils/app_routes.dart';
import 'package:emababyspa/utils/logger_utils.dart';
import 'package:get/get.dart';

class StaffController extends GetxController {
  final StaffRepository _staffRepository;
  final LoggerUtils _logger = LoggerUtils();

  StaffController({required StaffRepository staffRepository})
    : _staffRepository = staffRepository;

  final RxList<Staff> staffList = <Staff>[].obs;
  final RxBool isLoading = false.obs;
  final RxBool isFormSubmitting = false.obs;
  final RxString errorMessage = ''.obs;

  @override
  void onInit() {
    super.onInit();
    fetchAllStaffs();
  }

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

  void refreshData() => fetchAllStaffs();

  /// ✅ DIUBAH: kembalikan result supaya StaffView bisa show snackbar
  Future<bool> navigateToAddStaff() async {
    final result = await Get.toNamed(AppRoutes.staffForm);
    return result == true;
  }

  void navigateToEditStaff(String id) {
    Get.toNamed('/staffs/edit/$id');
  }

  /// Controller tidak show snackbar / tidak Get.back().
  Future<Staff> addStaff({
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

      if (staff == null) {
        throw Exception('Create staff returned null');
      }

      staffList.add(staff);
      return staff;
    } catch (e) {
      _logger.error('Error adding staff: $e');
      rethrow;
    } finally {
      isFormSubmitting.value = false;
    }
  }

  Future<Staff> updateStaff({
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

      if (staff == null) {
        throw Exception('Update staff returned null');
      }

      final index = staffList.indexWhere((s) => s.id == id);
      if (index != -1) {
        staffList[index] = staff;
        staffList.refresh();
      }

      return staff;
    } catch (e) {
      _logger.error('Error updating staff: $e');
      rethrow;
    } finally {
      isFormSubmitting.value = false;
    }
  }

  Future<void> toggleStaffStatus(Staff staff) async {
    try {
      final updatedStaff = await _staffRepository.updateStaffStatus(
        id: staff.id,
        isActive: !staff.isActive,
      );

      if (updatedStaff != null) {
        final index = staffList.indexWhere((s) => s.id == staff.id);
        if (index != -1) {
          staffList[index] = updatedStaff;
          staffList.refresh();
        }
      }
    } catch (e) {
      _logger.error('Error toggling staff status: $e');
      rethrow;
    }
  }

  Future<void> deleteStaff(String id) async {
    try {
      final isDeleted = await _staffRepository.deleteStaff(id);
      if (isDeleted) {
        staffList.removeWhere((staff) => staff.id == id);
      }
    } catch (e) {
      _logger.error('Error deleting staff: $e');
      rethrow;
    }
  }

  Future<Staff?> fetchStaffById(String id) async {
    try {
      isLoading.value = true;

      if (id.isEmpty) {
        throw Exception("Staff ID is required");
      }

      final response = await _staffRepository.getStaffById(id);
      return response;
    } catch (e) {
      errorMessage.value = 'Failed to fetch staff: ${e.toString()}';
      return null;
    } finally {
      isLoading.value = false;
    }
  }
}
