import 'package:dio/dio.dart';
import 'package:emababyspa/data/api/api_exception.dart';

class ErrorInterceptor extends Interceptor {
  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    switch (err.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        throw ApiException(
          message: 'Koneksi timeout. Silakan coba lagi nanti.',
          code: err.response?.statusCode,
        );
      case DioExceptionType.badResponse:
        switch (err.response?.statusCode) {
          case 400:
            throw ApiException(
              message: err.response?.data['message'] ?? 'Bad request',
              code: err.response?.statusCode,
            );
          case 401:
            throw ApiException(
              message: 'Sesi Anda telah berakhir. Silakan login kembali.',
              code: err.response?.statusCode,
            );
          case 403:
            throw ApiException(
              message: 'Anda tidak memiliki akses ke halaman ini.',
              code: err.response?.statusCode,
            );
          case 404:
            throw ApiException(
              message: 'Data tidak ditemukan.',
              code: err.response?.statusCode,
            );
          case 500:
          case 501:
          case 502:
          case 503:
            throw ApiException(
              message: 'Terjadi kesalahan pada server. Silakan coba lagi nanti.',
              code: err.response?.statusCode,
            );
          default:
            throw ApiException(
              message: err.response?.data['message'] ?? 'Terjadi kesalahan. Silakan coba lagi nanti.',
              code: err.response?.statusCode,
            );
        }
      case DioExceptionType.cancel:
        throw ApiException(
          message: 'Permintaan dibatalkan',
          code: err.response?.statusCode,
        );
      default:
        throw ApiException(
          message: 'Tidak dapat terhubung ke server. Silakan periksa koneksi internet Anda.',
          code: err.response?.statusCode,
        );
    }
  }
}
