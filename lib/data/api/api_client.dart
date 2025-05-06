// lib/data/api/api_client.dart - Fixed path parameter handling
import 'package:dio/dio.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';
import 'package:emababyspa/data/api/api_endpoints.dart';
import 'package:emababyspa/data/api/interceptors/auth_interceptor.dart';
import 'package:emababyspa/data/api/interceptors/error_interceptor.dart';
import 'package:emababyspa/utils/network_utils.dart';
import 'package:emababyspa/utils/logger_utils.dart';

class ApiClient {
  late Dio _dio;
  final NetworkUtils _networkUtils = NetworkUtils();
  final LoggerUtils _logger = LoggerUtils();

  ApiClient() {
    _init();
  }

  void _init() {
    _dio = Dio(
      BaseOptions(
        baseUrl: ApiEndpoints.baseUrl,
        connectTimeout: const Duration(seconds: 15),
        receiveTimeout: const Duration(seconds: 15),
        responseType: ResponseType.json,
      ),
    );

    // Add interceptors
    _dio.interceptors.add(AuthInterceptor());
    _dio.interceptors.add(ErrorInterceptor());

    // Add pretty logger in debug mode
    _dio.interceptors.add(
      PrettyDioLogger(
        requestHeader: true,
        requestBody: true,
        responseHeader: true,
        responseBody: true,
        error: true,
        compact: true,
      ),
    );
  }

  /// Validates API response and extracts data
  ///
  /// This method checks if the response contains {'success': true}
  /// - If successful: returns the data field from the response
  /// - If not successful: throws a DioException with the error message
  ///
  /// Parameters:
  /// - [response]: The Response object returned from Dio
  /// - [dataField]: The field name to extract from response (defaults to 'data')
  /// - [messageField]: The field name for error message (defaults to 'message')
  ///
  /// Returns: The data from the response
  /// Throws: DioException if the response is not successful
  dynamic validateResponse(
    Response response, {
    String dataField = 'data',
    String messageField = 'message',
    bool throwOnError = true,
  }) {
    try {
      // Check if response has data and is a Map
      if (response.data == null || response.data is! Map) {
        if (throwOnError) {
          throw DioException(
            requestOptions: response.requestOptions,
            error: 'Invalid response format',
            type: DioExceptionType.badResponse,
          );
        }
        return null;
      }

      // Check if response has success field and is true
      final Map responseMap = response.data as Map;
      final bool isSuccess = responseMap['success'] == true;

      if (!isSuccess) {
        final String errorMessage =
            responseMap[messageField]?.toString() ?? 'Unknown error occurred';

        if (throwOnError) {
          throw DioException(
            requestOptions: response.requestOptions,
            error: errorMessage,
            response: response,
            type: DioExceptionType.badResponse,
          );
        }
        return null;
      }

      // Return data field if it exists
      return responseMap.containsKey(dataField)
          ? responseMap[dataField]
          : responseMap;
    } catch (e) {
      _logger.error('Response validation failed: $e');
      if (throwOnError) rethrow;
      return null;
    }
  }

  /// Process API response with validation
  ///
  /// This is a convenience method to directly get validated data from response
  Future<T?> processResponse<T>(
    Future<Response> responseFuture, {
    String dataField = 'data',
    String messageField = 'message',
    bool throwOnError = true,
  }) async {
    try {
      final response = await responseFuture;
      return validateResponse(
            response,
            dataField: dataField,
            messageField: messageField,
            throwOnError: throwOnError,
          )
          as T?;
    } catch (e) {
      _logger.error('Process response failed: $e');
      if (throwOnError) rethrow;
      return null;
    }
  }

  // POST request with multipart form data and validation
  Future<T?> postMultipartValidated<T>(
    String path, {
    required FormData data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    Map<String, dynamic>? pathParams,
    bool checkInternet = true,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
    String dataField = 'data',
    String messageField = 'message',
    bool throwOnError = true,
  }) async {
    final responseFuture = post<T>(
      path,
      data: data,
      queryParameters: queryParameters,
      options: (options ?? Options()).copyWith(
        contentType: 'multipart/form-data',
      ),
      pathParams: pathParams,
      checkInternet: checkInternet,
      onSendProgress: onSendProgress,
      onReceiveProgress: onReceiveProgress,
    );

    return processResponse<T>(
      responseFuture,
      dataField: dataField,
      messageField: messageField,
      throwOnError: throwOnError,
    );
  }

  // PUT request with multipart form data and validation
  Future<T?> putMultipartValidated<T>(
    String path, {
    required FormData data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    Map<String, dynamic>? pathParams,
    bool checkInternet = true,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
    String dataField = 'data',
    String messageField = 'message',
    bool throwOnError = true,
  }) async {
    final responseFuture = put<T>(
      path,
      data: data,
      queryParameters: queryParameters,
      options: (options ?? Options()).copyWith(
        contentType: 'multipart/form-data',
      ),
      pathParams: pathParams,
      checkInternet: checkInternet,
      onSendProgress: onSendProgress,
      onReceiveProgress: onReceiveProgress,
    );

    return processResponse<T>(
      responseFuture,
      dataField: dataField,
      messageField: messageField,
      throwOnError: throwOnError,
    );
  }

  // GET request with network check
  Future<Response<T>> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
    Map<String, dynamic>? pathParams,
    bool checkInternet = true,
  }) async {
    // Replace path parameters if provided
    final resolvedPath =
        pathParams != null
            ? _networkUtils.replacePathParams(path, pathParams)
            : path;

    // Check internet connectivity if required
    if (checkInternet && !(await _networkUtils.checkInternetConnection())) {
      _networkUtils.showNoInternetError();
      throw DioException(
        requestOptions: RequestOptions(path: resolvedPath),
        error: 'No internet connection',
        type: DioExceptionType.connectionError,
      );
    }

    try {
      // Log the actual URL being called for debugging
      _logger.debug('Making GET request to: $resolvedPath');

      return await _dio.get<T>(
        resolvedPath,
        queryParameters: queryParameters,
        options: options,
      );
    } catch (e) {
      _logger.error('GET request failed: $e');
      rethrow;
    }
  }

  // GET request with validation - returns processed data directly
  Future<T?> getValidated<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
    Map<String, dynamic>? pathParams,
    bool checkInternet = true,
    String dataField = 'data',
    String messageField = 'message',
    bool throwOnError = true,
  }) async {
    final responseFuture = get(
      path,
      queryParameters: queryParameters,
      options: options,
      pathParams: pathParams,
      checkInternet: checkInternet,
    );

    return processResponse<T>(
      responseFuture,
      dataField: dataField,
      messageField: messageField,
      throwOnError: throwOnError,
    );
  }

  // POST request with network check
  Future<Response<T>> post<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    Map<String, dynamic>? pathParams,
    bool checkInternet = true,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  }) async {
    // Replace path parameters if provided
    final resolvedPath =
        pathParams != null
            ? _networkUtils.replacePathParams(path, pathParams)
            : path;

    // Check internet connectivity if required
    if (checkInternet && !(await _networkUtils.checkInternetConnection())) {
      _networkUtils.showNoInternetError();
      throw DioException(
        requestOptions: RequestOptions(path: resolvedPath),
        error: 'No internet connection',
        type: DioExceptionType.connectionError,
      );
    }

    try {
      return await _dio.post<T>(
        resolvedPath,
        data: data,
        queryParameters: queryParameters,
        options: options,
        onSendProgress: onSendProgress,
        onReceiveProgress: onReceiveProgress,
      );
    } catch (e) {
      _logger.error('POST request failed: $e');
      rethrow;
    }
  }

  // POST request with validation - returns processed data directly
  Future<T?> postValidated<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    Map<String, dynamic>? pathParams,
    bool checkInternet = true,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
    String dataField = 'data',
    String messageField = 'message',
    bool throwOnError = true,
  }) async {
    final responseFuture = post(
      path,
      data: data,
      queryParameters: queryParameters,
      options: options,
      pathParams: pathParams,
      checkInternet: checkInternet,
      onSendProgress: onSendProgress,
      onReceiveProgress: onReceiveProgress,
    );

    return processResponse<T>(
      responseFuture,
      dataField: dataField,
      messageField: messageField,
      throwOnError: throwOnError,
    );
  }

  // PUT request with network check
  Future<Response<T>> put<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    Map<String, dynamic>? pathParams,
    bool checkInternet = true,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  }) async {
    // Replace path parameters if provided
    final resolvedPath =
        pathParams != null
            ? _networkUtils.replacePathParams(path, pathParams)
            : path;

    // Check internet connectivity if required
    if (checkInternet && !(await _networkUtils.checkInternetConnection())) {
      _networkUtils.showNoInternetError();
      throw DioException(
        requestOptions: RequestOptions(path: resolvedPath),
        error: 'No internet connection',
        type: DioExceptionType.connectionError,
      );
    }

    try {
      return await _dio.put<T>(
        resolvedPath,
        data: data,
        queryParameters: queryParameters,
        options: options,
        onSendProgress: onSendProgress,
        onReceiveProgress: onReceiveProgress,
      );
    } catch (e) {
      _logger.error('PUT request failed: $e');
      rethrow;
    }
  }

  // PUT request with validation - returns processed data directly
  Future<T?> putValidated<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    Map<String, dynamic>? pathParams,
    bool checkInternet = true,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
    String dataField = 'data',
    String messageField = 'message',
    bool throwOnError = true,
  }) async {
    final responseFuture = put(
      path,
      data: data,
      queryParameters: queryParameters,
      options: options,
      pathParams: pathParams,
      checkInternet: checkInternet,
      onSendProgress: onSendProgress,
      onReceiveProgress: onReceiveProgress,
    );

    return processResponse<T>(
      responseFuture,
      dataField: dataField,
      messageField: messageField,
      throwOnError: throwOnError,
    );
  }

  // DELETE request with network check
  Future<Response<T>> delete<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    Map<String, dynamic>? pathParams,
    bool checkInternet = true,
  }) async {
    // Replace path parameters if provided
    final resolvedPath =
        pathParams != null
            ? _networkUtils.replacePathParams(path, pathParams)
            : path;

    // Check internet connectivity if required
    if (checkInternet && !(await _networkUtils.checkInternetConnection())) {
      _networkUtils.showNoInternetError();
      throw DioException(
        requestOptions: RequestOptions(path: resolvedPath),
        error: 'No internet connection',
        type: DioExceptionType.connectionError,
      );
    }

    try {
      return await _dio.delete<T>(
        resolvedPath,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
    } catch (e) {
      _logger.error('DELETE request failed: $e');
      rethrow;
    }
  }

  // DELETE request with validation - returns processed data directly
  Future<T?> deleteValidated<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    Map<String, dynamic>? pathParams,
    bool checkInternet = true,
    String dataField = 'data',
    String messageField = 'message',
    bool throwOnError = true,
  }) async {
    final responseFuture = delete(
      path,
      data: data,
      queryParameters: queryParameters,
      options: options,
      pathParams: pathParams,
      checkInternet: checkInternet,
    );

    return processResponse<T>(
      responseFuture,
      dataField: dataField,
      messageField: messageField,
      throwOnError: throwOnError,
    );
  }

  // PATCH request with network check
  Future<Response<T>> patch<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    Map<String, dynamic>? pathParams,
    bool checkInternet = true,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  }) async {
    // Replace path parameters if provided
    final resolvedPath =
        pathParams != null
            ? _networkUtils.replacePathParams(path, pathParams)
            : path;

    // Check internet connectivity if required
    if (checkInternet && !(await _networkUtils.checkInternetConnection())) {
      _networkUtils.showNoInternetError();
      throw DioException(
        requestOptions: RequestOptions(path: resolvedPath),
        error: 'No internet connection',
        type: DioExceptionType.connectionError,
      );
    }

    try {
      return await _dio.patch<T>(
        resolvedPath,
        data: data,
        queryParameters: queryParameters,
        options: options,
        onSendProgress: onSendProgress,
        onReceiveProgress: onReceiveProgress,
      );
    } catch (e) {
      _logger.error('PATCH request failed: $e');
      rethrow;
    }
  }

  // PATCH request with validation - returns processed data directly
  Future<T?> patchValidated<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    Map<String, dynamic>? pathParams,
    bool checkInternet = true,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
    String dataField = 'data',
    String messageField = 'message',
    bool throwOnError = true,
  }) async {
    final responseFuture = patch(
      path,
      data: data,
      queryParameters: queryParameters,
      options: options,
      pathParams: pathParams,
      checkInternet: checkInternet,
      onSendProgress: onSendProgress,
      onReceiveProgress: onReceiveProgress,
    );

    return processResponse<T>(
      responseFuture,
      dataField: dataField,
      messageField: messageField,
      throwOnError: throwOnError,
    );
  }
}
