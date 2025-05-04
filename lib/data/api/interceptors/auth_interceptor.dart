import 'package:dio/dio.dart';
import 'package:get/get.dart';
import 'package:emababyspa/utils/storage_utils.dart';
import 'package:emababyspa/utils/app_routes.dart';

class AuthInterceptor extends Interceptor {
  @override
  Future<void> onRequest(RequestOptions options, RequestInterceptorHandler handler) async {
    final StorageUtils storageUtils = Get.find<StorageUtils>();
    final String? token = await storageUtils.getToken();

    if (token != null) {
      options.headers['Authorization'] = 'Bearer $token';
    }

    options.headers['Accept'] = 'application/json';
    options.headers['Content-Type'] = 'application/json';

    return handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    if (err.response?.statusCode == 401) {
      // Token mungkin sudah kadaluarsa, hapus token dan arahkan ke halaman login
      final StorageUtils storageUtils = Get.find<StorageUtils>();
      storageUtils.clearToken();
      storageUtils.clearOwner();

      // Redirect to login page
      Get.offAllNamed(AppRoutes.login);

      return handler.next(err);
    }

    return handler.next(err);
  }
}
