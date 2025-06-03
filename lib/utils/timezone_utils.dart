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

  // Format DateTime to Indonesia day and date format (e.g., "Monday, 15 January 2024")
  static String formatDateTimeToIndonesiaDayDate(DateTime dateTime) {
    try {
      final indonesiaTime = toIndonesiaTime(dateTime);
      return DateFormat('EEEE, dd MMMM yyyy', 'id_ID').format(indonesiaTime);
    } catch (e) {
      // Fallback to English format if Indonesian locale is not available
      final indonesiaTime = toIndonesiaTime(dateTime);
      return DateFormat('EEEE, dd MMMM yyyy').format(indonesiaTime);
    }
  }

  // Format ISO string to local date time with full format (e.g., "Monday, 15 January 2024 14:30")
  static String formatISOToLocalDateTimeFull(String isoString) {
    try {
      final utcTime = DateTime.parse(isoString);
      final indonesiaTime = toIndonesiaTime(utcTime);

      try {
        // Try Indonesian locale first
        return DateFormat(
          'EEEE, dd MMMM yyyy HH:mm',
          'id_ID',
        ).format(indonesiaTime);
      } catch (e) {
        // Fallback to English format if Indonesian locale is not available
        return DateFormat('EEEE, dd MMMM yyyy HH:mm').format(indonesiaTime);
      }
    } catch (e) {
      return isoString; // Return original string if parsing fails
    }
  }
}
