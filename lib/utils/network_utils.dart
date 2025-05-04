import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dio/dio.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'logger_utils.dart';

/// A utility class for network-related operations
class NetworkUtils {
  static final NetworkUtils _instance = NetworkUtils._internal();
  factory NetworkUtils() => _instance;
  NetworkUtils._internal();

  final LoggerUtils _logger = LoggerUtils();
  final Dio _connectivityDio = Dio(); // Only used for connectivity testing

  /// Check if the device has an active internet connection
  Future<bool> checkInternetConnection() async {
    try {
      final connectivityResult = await Connectivity().checkConnectivity();
      if (connectivityResult.first == ConnectivityResult.none) {
        return false;
      }

      // Additional check by trying to reach a reliable server
      try {
        final response = await _connectivityDio.get(
          'https://www.google.com',
          options: Options(
            sendTimeout: const Duration(seconds: 5),
            receiveTimeout: const Duration(seconds: 5),
          ),
        );
        return response.statusCode == 200;
      } on DioException {
        return false;
      }
    } catch (e) {
      _logger.error('Error checking internet connection: $e');
      return false;
    }
  }

  /// Show a network error message
  void showNetworkError({
    String title = 'Network Error',
    required String message,
  }) {
    Get.snackbar(
      title,
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: const Color(0xFFFEE4E2),
      colorText: const Color(0xFFD92D20),
      duration: const Duration(seconds: 4),
    );
  }

  /// Show a no internet connection message
  void showNoInternetError() {
    showNetworkError(
      title: 'No Internet Connection',
      message: 'Please check your internet connection and try again.',
    );
  }

  /// Replace path parameters in an endpoint URL
  String replacePathParams(String endpoint, Map<String, dynamic> pathParams) {
    String result = endpoint;
    pathParams.forEach((key, value) {
      result = result.replaceAll('{$key}', value.toString());
    });
    return result;
  }

  /// Check if the device has internet connection and show an error if not
  /// Returns true if internet is available, false otherwise
  Future<bool> ensureInternetConnection() async {
    final hasInternet = await checkInternetConnection();
    if (!hasInternet) {
      showNoInternetError();
    }
    return hasInternet;
  }

  /// Format errors from DioExceptions for display
  String formatDioError(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return 'Connection timeout. Please try again.';
      case DioExceptionType.badCertificate:
        return 'Secure connection failed. Please contact support.';
      case DioExceptionType.badResponse:
        // Try to extract error message from response
        if (error.response?.data is Map &&
            error.response?.data['message'] != null) {
          return error.response?.data['message'];
        }

        // Default messages based on status code
        switch (error.response?.statusCode) {
          case 400:
            return 'Bad request. Please check your input.';
          case 401:
            return 'Unauthorized. Please login again.';
          case 403:
            return 'Access denied. You don\'t have permission.';
          case 404:
            return 'The requested resource was not found.';
          case 500:
          case 501:
          case 502:
          case 503:
            return 'Server error. Please try again later.';
          default:
            return 'Error ${error.response?.statusCode}. Please try again.';
        }
      case DioExceptionType.cancel:
        return 'Request cancelled.';
      case DioExceptionType.connectionError:
        return 'Connection failed. Please check your internet.';
      default:
        return 'An unexpected error occurred. Please try again.';
    }
  }

  /// Stream that emits connectivity status changes
  Stream<ConnectivityResult> get connectivityStream =>
      Connectivity().onConnectivityChanged.map((list) => list.first);

  /// Get the current connectivity status
  Future<ConnectivityResult> get connectivityStatus async =>
      (await Connectivity().checkConnectivity()).first;

  /// Determine if the current connectivity type is wifi
  Future<bool> get isWifi async {
    final connectivityResult = await connectivityStatus;
    return connectivityResult == ConnectivityResult.wifi;
  }

  /// Determine if the current connectivity type is mobile data
  Future<bool> get isMobileData async {
    final connectivityResult = await connectivityStatus;
    return connectivityResult == ConnectivityResult.mobile;
  }
}
