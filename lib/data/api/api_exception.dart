class ApiException implements Exception {
  final String message;
  final int? code;
  final dynamic data;

  ApiException({
    required this.message,
    this.code,
    this.data,
  });

  @override
  String toString() {
    return 'ApiException: $message (Code: $code)';
  }
}
