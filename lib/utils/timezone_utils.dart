// lib/utils/timezone_utils.dart
import 'package:intl/intl.dart';

class TimeZoneUtil {
  // Convert UTC time to Indonesia time (UTC+7)
  static DateTime toIndonesiaTime(DateTime utcTime) {
    return utcTime.add(const Duration(hours: 7));
  }

  // Format time in Indonesia timezone
  static String formatIndonesiaTime(
    DateTime utcTime, {
    String format = 'HH:mm',
  }) {
    final indonesiaTime = toIndonesiaTime(utcTime);
    return DateFormat(format).format(indonesiaTime);
  }

  // Parse ISO string to DateTime and convert to Indonesia time
  static String formatISOToIndonesiaTime(
    String isoTimeString, {
    String format = 'HH:mm',
  }) {
    try {
      final utcTime = DateTime.parse(isoTimeString);
      return formatIndonesiaTime(utcTime, format: format);
    } catch (e) {
      return isoTimeString;
    }
  }

  // Get Indonesia time now
  static DateTime getNow() {
    return toIndonesiaTime(DateTime.now().toUtc());
  }

  // Format a date to Indonesia format with timezone adjustment
  static String formatDate(DateTime utcDate, {String format = 'dd MMMM yyyy'}) {
    final indonesiaDate = toIndonesiaTime(utcDate);
    return DateFormat(format).format(indonesiaDate);
  }
}
