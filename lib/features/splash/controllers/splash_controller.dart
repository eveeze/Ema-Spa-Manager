import 'dart:async';
import 'package:get/get.dart';
import 'package:emababyspa/utils/app_routes.dart';
import 'package:emababyspa/utils/storage_utils.dart';

class SplashController extends GetxController {
  final StorageUtils _storageUtils = Get.find<StorageUtils>();

  @override
  void onInit() {
    super.onInit();
    _initSplash();
  }

  void _initSplash() async {
    await Future.delayed(const Duration(seconds: 3));

    // Cek apakah user sudah login (memiliki token yang valid)
    final bool hasToken = await _storageUtils.hasToken();
    final bool isTokenExpired = await _storageUtils.isTokenExpired();
    final bool isLoggedIn = hasToken && !isTokenExpired;

    if (isLoggedIn) {
      Get.offAllNamed(AppRoutes.dashboard);
    } else {
      Get.offAllNamed(AppRoutes.login);
    }
  }
}
