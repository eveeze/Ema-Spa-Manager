// lib/data/repository/staff_repository.dart
import 'dart:io';
import 'package:emababyspa/data/models/staff.dart';
import 'package:emababyspa/data/providers/staff_provider.dart';
import 'package:emababyspa/utils/file_utils.dart'; // Import the new FileUtils
import 'package:emababyspa/utils/logger_utils.dart';

class StaffRepository {
  final StaffProvider _staffProvider;
  final LoggerUtils _logger = LoggerUtils();

  StaffRepository({required StaffProvider staffProvider})
    : _staffProvider = staffProvider;

  /// Create a new staff member
  ///
  /// Returns the created staff or null if an error occurs
  Future<Staff?> createStaff({
    required String name,
    required String email,
    required String phoneNumber,
    String? address,
    File? profilePicture,
  }) async {
    try {
      // Validate the profile picture if provided
      if (profilePicture != null) {
        if (!FileUtils.isAllowedImageType(profilePicture)) {
          throw Exception('Only JPG, JPEG and PNG images are allowed');
        }

        if (!FileUtils.isFileSizeWithinLimit(profilePicture, 5.0)) {
          throw Exception('Image size must be less than 5MB');
        }
      }

      final Map<String, dynamic> staffData = await _staffProvider.createStaff(
        name: name,
        email: email,
        phoneNumber: phoneNumber,
        address: address,
        profilePicture: profilePicture,
      );

      return Staff.fromJson(staffData);
    } catch (e) {
      rethrow;
    }
  }

  /// Get all staff members
  ///
  /// Returns a list of all staff or an empty list if an error occurs
  Future<List<Staff>> getAllStaffs({bool? isActive}) async {
    try {
      final List<dynamic> staffsData = await _staffProvider.getAllStaffs(
        isActive: isActive,
      );
      return staffsData.map((staff) => Staff.fromJson(staff)).toList();
    } catch (e) {
      rethrow;
    }
  }

  /// Get a staff member by ID
  /// repository
  /// Returns the staff or null if an error occurs
  Future<Staff?> getStaffById(String id) async {
    try {
      final Map<String, dynamic> staffData = await _staffProvider.getStaffById(
        id,
      );
      _logger.debug('staff data : $staffData');
      return Staff.fromJson(staffData);
    } catch (e) {
      rethrow;
    }
  }

  /// Update a staff member
  ///
  /// Returns the updated staff or null if an error occurs
  Future<Staff?> updateStaff({
    required String id,
    required String name,
    required String email,
    required String phoneNumber,
    String? address,
    required bool isActive,
    File? profilePicture,
  }) async {
    try {
      // Validate the profile picture if provided
      if (profilePicture != null) {
        if (!FileUtils.isAllowedImageType(profilePicture)) {
          throw Exception('Only JPG, JPEG and PNG images are allowed');
        }

        if (!FileUtils.isFileSizeWithinLimit(profilePicture, 5.0)) {
          throw Exception('Image size must be less than 5MB');
        }
      }

      final Map<String, dynamic> staffData = await _staffProvider.updateStaff(
        id: id,
        name: name,
        email: email,
        phoneNumber: phoneNumber,
        address: address,
        isActive: isActive,
        profilePicture: profilePicture,
      );

      return Staff.fromJson(staffData);
    } catch (e) {
      rethrow;
    }
  }

  /// Update staff active status
  ///
  /// Returns the updated staff or null if an error occurs
  Future<Staff?> updateStaffStatus({
    required String id,
    required bool isActive,
  }) async {
    try {
      final Map<String, dynamic> staffData = await _staffProvider
          .updateStaffStatus(id: id, isActive: isActive);

      return Staff.fromJson(staffData);
    } catch (e) {
      rethrow;
    }
  }

  /// Delete a staff member
  ///
  /// Returns true if deletion was successful or false if an error occurs
  Future<bool> deleteStaff(String id) async {
    try {
      return await _staffProvider.deleteStaff(id);
    } catch (e) {
      rethrow;
    }
  }
}
