// lib/data/repositories/staff_repository.dart
import 'package:dio/dio.dart';
import 'package:get/get.dart';
import 'package:emababyspa/data/providers/staff_provider.dart';
import 'package:emababyspa/data/models/staff.dart';
import 'package:emababyspa/utils/logger_utils.dart';

class StaffRepository {
  final StaffProvider _staffProvider = Get.find<StaffProvider>();
  final LoggerUtils _logger = LoggerUtils();

  /// Create a new staff member
  Future<Staff?> createStaff({
    required String name,
    required String email,
    required String phoneNumber,
    String? address,
  }) async {
    try {
      final data = await _staffProvider.createStaff(
        name: name,
        email: email,
        phoneNumber: phoneNumber,
        address: address,
      );

      return Staff.fromJson(data);
    } on DioException catch (e) {
      _logger.error('Failed to create staff: ${e.message}');
      rethrow;
    } catch (e) {
      _logger.error('Failed to create staff: $e');
      rethrow;
    }
  }

  /// Get all staff members
  Future<List<Staff>> getAllStaffs() async {
    try {
      final dataList = await _staffProvider.getAllStaffs();

      return dataList
          .map((data) => Staff.fromJson(data as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      _logger.error('Failed to get all staffs: ${e.message}');
      rethrow;
    } catch (e) {
      _logger.error('Failed to get all staffs: $e');
      rethrow;
    }
  }

  /// Get a staff member by ID
  Future<Staff?> getStaffById(String id) async {
    try {
      final data = await _staffProvider.getStaffById(id);

      return Staff.fromJson(data);
    } on DioException catch (e) {
      _logger.error('Failed to get staff by id: ${e.message}');
      rethrow;
    } catch (e) {
      _logger.error('Failed to get staff by id: $e');
      rethrow;
    }
  }

  /// Update a staff member
  Future<Staff?> updateStaff({
    required String id,
    required String name,
    required String email,
    required String phoneNumber,
    String? address,
    required bool isActive,
  }) async {
    try {
      final data = await _staffProvider.updateStaff(
        id: id,
        name: name,
        email: email,
        phoneNumber: phoneNumber,
        address: address,
        isActive: isActive,
      );

      return Staff.fromJson(data);
    } on DioException catch (e) {
      _logger.error('Failed to update staff: ${e.message}');
      rethrow;
    } catch (e) {
      _logger.error('Failed to update staff: $e');
      rethrow;
    }
  }

  /// Update staff active status
  Future<Staff?> updateStaffStatus({
    required String id,
    required bool isActive,
  }) async {
    try {
      final data = await _staffProvider.updateStaffStatus(
        id: id,
        isActive: isActive,
      );

      return Staff.fromJson(data);
    } on DioException catch (e) {
      _logger.error('Failed to update staff status: ${e.message}');
      rethrow;
    } catch (e) {
      _logger.error('Failed to update staff status: $e');
      rethrow;
    }
  }

  /// Delete a staff member
  Future<bool> deleteStaff(String id) async {
    try {
      return await _staffProvider.deleteStaff(id);
    } on DioException catch (e) {
      _logger.error('Failed to delete staff: ${e.message}');
      rethrow;
    } catch (e) {
      _logger.error('Failed to delete staff: $e');
      rethrow;
    }
  }
}
