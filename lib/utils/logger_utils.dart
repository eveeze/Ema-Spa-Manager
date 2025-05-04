import 'package:flutter/foundation.dart';
import 'package:logger/logger.dart';

/// A utility class to handle logging in the app
class LoggerUtils {
  static final LoggerUtils _instance = LoggerUtils._internal();
  factory LoggerUtils() => _instance;
  LoggerUtils._internal() {
    _initLogger();
  }

  late final Logger _logger;

  /// Whether to enable file logging
  final bool _enableFileLogging = false;

  /// Initialize the logger
  void _initLogger() {
    // Custom logger output that includes timestamp
    final output =
        _enableFileLogging
            ? MultiOutput([ConsoleOutput(), FileOutput()])
            : ConsoleOutput();

    _logger = Logger(
      filter: _AppLogFilter(),
      printer: PrettyPrinter(
        methodCount: 2,
        errorMethodCount: 8,
        lineLength: 120,
        colors: true,
        printEmojis: true,
        dateTimeFormat: DateTimeFormat.onlyTimeAndSinceStart,
      ),
      output: output,
    );
  }

  /// Log a verbose message
  void verbose(dynamic message, [dynamic error, StackTrace? stackTrace]) {
    if (kDebugMode) {
      _logger.t(message, error: error, stackTrace: stackTrace);
    }
  }

  /// Log a debug message
  void debug(dynamic message, [dynamic error, StackTrace? stackTrace]) {
    if (kDebugMode) {
      _logger.d(message, error: error, stackTrace: stackTrace);
    }
  }

  /// Log an info message
  void info(dynamic message, [dynamic error, StackTrace? stackTrace]) {
    if (kDebugMode) {
      _logger.i(message, error: error, stackTrace: stackTrace);
    }
  }

  /// Log a warning message
  void warning(dynamic message, [dynamic error, StackTrace? stackTrace]) {
    if (kDebugMode) {
      _logger.w(message, error: error, stackTrace: stackTrace);
    }
  }

  /// Log an error message
  void error(dynamic message, [dynamic error, StackTrace? stackTrace]) {
    _logger.e(message, error: error, stackTrace: stackTrace);
  }

  /// Log a critical message
  void critical(dynamic message, [dynamic error, StackTrace? stackTrace]) {
    _logger.f(message, error: error, stackTrace: stackTrace);
  }

  /// Log an API request
  void logApiRequest({
    required String method,
    required String endpoint,
    dynamic headers,
    dynamic body,
  }) {
    if (kDebugMode) {
      _logger.i(
        'API Request: $method $endpoint',
        error: {'headers': headers, 'body': body},
      );
    }
  }

  /// Log an API response
  void logApiResponse({
    required String method,
    required String endpoint,
    required int statusCode,
    dynamic headers,
    dynamic body,
    Duration? responseTime,
  }) {
    if (kDebugMode) {
      _logger.i(
        'API Response: $method $endpoint - Status: $statusCode ${responseTime != null ? '(${responseTime.inMilliseconds}ms)' : ''}',
        error: {'headers': headers, 'body': body},
      );
    }
  }

  /// Log user activity
  void logUserActivity(String activity, {Map<String, dynamic>? details}) {
    if (kDebugMode) {
      _logger.i('User Activity: $activity', error: details);
    }
  }

  /// Log an exception
  void logException(
    dynamic exception, {
    StackTrace? stackTrace,
    String? context,
  }) {
    String message = 'Exception';
    if (context != null) {
      message = 'Exception in $context';
    }
    _logger.e(message, error: exception, stackTrace: stackTrace);
  }

  /// Dispose the logger
  void dispose() {
    _logger.close();
  }
}

/// Custom log filter that only shows logs in debug mode for verbose, debug, info, and warning levels
class _AppLogFilter extends LogFilter {
  @override
  bool shouldLog(LogEvent event) {
    var shouldLog = false;

    // Always log error and wtf (critical) levels in all modes
    if (event.level == Level.error || event.level == Level.fatal) {
      shouldLog = true;
    }
    // Log verbose, debug, info, and warning only in debug mode
    else if (kDebugMode) {
      shouldLog = true;
    }

    return shouldLog;
  }
}

/// Custom file output for logging
class FileOutput extends LogOutput {
  @override
  void output(OutputEvent event) {
    // In a real app, you would implement file logging here
    // For now, this is just a placeholder
    for (var line in event.lines) {
      // Write to file
      debugPrint('FILE: $line');
    }
  }
}
