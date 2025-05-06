// lib/utils/file_utils.dart
import 'dart:io';
import 'dart:math';
import 'package:path/path.dart' as path;

class FileUtils {
  /// Checks if a file has an allowed image extension (jpg, jpeg, png)
  ///
  /// Returns true if the file extension is allowed, false otherwise
  static bool isAllowedImageType(File file) {
    final extension = path.extension(file.path).toLowerCase();
    return ['.jpg', '.jpeg', '.png'].contains(extension);
  }

  /// Gets the formatted file size in KB or MB
  ///
  /// Returns a string representation of the file size
  static String getFileSize(File file, {int decimals = 1}) {
    final bytes = file.lengthSync();
    if (bytes <= 0) return '0 B';

    const suffixes = ['B', 'KB', 'MB', 'GB'];
    var i = (bytes > 0 ? (log(bytes) / log(1024)).floor() : 0);
    i = i < suffixes.length ? i : suffixes.length - 1;

    return '${(bytes / pow(1024, i)).toStringAsFixed(decimals)} ${suffixes[i]}';
  }

  /// Checks if file size is within limit
  ///
  /// Returns true if the file size is less than or equal to the limit (in MB)
  static bool isFileSizeWithinLimit(File file, double limitInMB) {
    final bytes = file.lengthSync();
    final fileSizeInMB = bytes / (1024 * 1024);
    return fileSizeInMB <= limitInMB;
  }
}

// Note: You'll need to add the following import to your pubspec.yaml:
// path: ^1.8.0
// 
// Also, 'log' and 'pow' functions require:
// import 'dart:math';