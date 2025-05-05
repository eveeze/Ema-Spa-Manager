import 'package:get/get.dart';
import 'package:emababyspa/data/repository/auth_repository.dart';
import 'package:emababyspa/data/models/owner.dart';
import 'package:emababyspa/utils/storage_utils.dart';

class AuthController extends GetxController {
  final AuthRepository _repository;
  final StorageUtils _storage = StorageUtils();

  final Rx<Owner?> owner = Rx<Owner?>(null);
  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;
  final RxBool isAuthenticated = false.obs;

  AuthController({required AuthRepository repository})
    : _repository = repository;

  @override
  void onInit() {
    super.onInit();
    checkAuthStatus();
  }

  Future<void> checkAuthStatus() async {
    final hasToken = await _storage.hasToken();

    if (hasToken) {
      // Check if token is expired
      final isExpired = await _storage.isTokenExpired();

      if (isExpired) {
        // Token expired, logout user
        await logout();
        return;
      }

      isAuthenticated.value = true;

      // Try to load owner from storage first
      final storedOwner = _storage.getOwner();
      if (storedOwner != null) {
        owner.value = storedOwner;
      }

      // Refresh owner profile from server
      getOwnerProfile();
    }
  }

  // Login function
  Future<bool> login(String email, String password) async {
    isLoading.value = true;
    errorMessage.value = '';

    try {
      final result = await _repository.login(email: email, password: password);

      // Save token and owner data
      await _storage.setToken(result['token']);
      owner.value = result['owner'];
      await _storage.setOwner(result['owner']);
      isAuthenticated.value = true;

      isLoading.value = false;
      return true;
    } catch (e) {
      isLoading.value = false;
      errorMessage.value = e.toString();
      return false;
    }
  }

  // Get owner profile
  Future<void> getOwnerProfile() async {
    final hasToken = await _storage.hasToken();
    if (!hasToken) return;

    isLoading.value = true;
    errorMessage.value = '';

    try {
      final ownerData = await _repository.getProfile();
      owner.value = ownerData;
      await _storage.setOwner(ownerData);
      isLoading.value = false;
    } catch (e) {
      isLoading.value = false;
      errorMessage.value = e.toString();

      // If unauthorized error, handle logout
      if (e.toString().contains('unauthorized') ||
          e.toString().contains('forbidden')) {
        await logout();
      }
    }
  }

  // Logout function
  Future<void> logout() async {
    // Clear all auth data
    await _storage.clearToken();
    await _storage.clearOwner();
    owner.value = null;
    isAuthenticated.value = false;

    // Navigate to login page
    Get.offAllNamed('/login');
  }

  // Method to check token validity periodically
  Future<bool> validateToken() async {
    final hasToken = await _storage.hasToken();
    if (!hasToken) {
      isAuthenticated.value = false;
      return false;
    }

    final isExpired = await _storage.isTokenExpired();
    if (isExpired) {
      await logout();
      return false;
    }

    return true;
  }
}
