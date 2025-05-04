// lib/data/repositories/auth_repository.dart
import 'package:emababyspa/data/api/api_exception.dart';
import 'package:emababyspa/data/providers/auth_provider.dart';
import 'package:emababyspa/data/models/owner.dart';

class AuthRepository {
  final AuthProvider _provider;

  AuthRepository({required AuthProvider provider}) : _provider = provider;

  /// Login user with email and password
  ///
  /// Returns a Map containing:
  /// - token: The authentication token
  /// - owner: The Owner model object
  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    try {
      final responseData = await _provider.login(
        email: email,
        password: password,
      );
      return {
        'token': responseData?['token'],
        'owner': Owner.fromJson(responseData?['owner']),
      };
    } catch (e) {
      // Convert DioException to ApiException with a user-friendly message
      throw ApiException(
        message: 'Login gagal. Silakan periksa email dan password Anda.',
      );
    }
  }

  /// Get authenticated user profile
  ///
  /// Returns the Owner model object
  Future<Owner> getProfile() async {
    try {
      final profileData = await _provider.getProfile();

      // profileData already validated by ApiClient and contains only the data field
      return Owner.fromJson(profileData!);
    } catch (e) {
      // Convert DioException to ApiException with a user-friendly message
      throw ApiException(
        message: 'Gagal mengambil profil. Silakan coba lagi nanti.',
      );
    }
  }
}
