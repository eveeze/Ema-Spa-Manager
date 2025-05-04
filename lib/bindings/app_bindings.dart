// lib/bindings/app_bindings.dart
import 'package:get/get.dart';
import 'package:emababyspa/data/api/api_client.dart';
import 'package:emababyspa/utils/storage_utils.dart';
import 'package:emababyspa/data/providers/auth_provider.dart';
import 'package:emababyspa/data/repository/auth_repository.dart';

class AppBindings extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ApiClient>(() => ApiClient(), fenix: true);
    Get.lazyPut<StorageUtils>(() => StorageUtils(), fenix: true);
    Get.lazyPut<AuthProvider>(() => AuthProvider(), fenix: true);
    Get.lazyPut<AuthRepository>(
      () => AuthRepository(provider: Get.find<AuthProvider>()),
      fenix: true,
    );
  }
}
