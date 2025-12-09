// lib/utils/timezone_utils.dart
import 'package:intl/intl.dart';

class TimeZoneUtil {
  // Convert UTC time to Indonesia time (UTC+7)
  static DateTime toIndonesiaTime(DateTime utcTime) {
    // Pastikan input adalah UTC
    if (!utcTime.isUtc) {
      utcTime = utcTime.toUtc();
    }
    return utcTime.add(const Duration(hours: 7));
  }

  // Format time in Indonesia timezone
  static String formatIndonesiaTime(
    DateTime utcTime, {
    String format = 'HH:mm',
  }) {
    // Jika waktu sudah dalam timezone lokal, langsung format
    if (!utcTime.isUtc) {
      return DateFormat(format).format(utcTime);
    }

    final indonesiaTime = toIndonesiaTime(utcTime);
    return DateFormat(format).format(indonesiaTime);
  }

  // Parse ISO string to DateTime and convert to Indonesia time
  static String formatISOToIndonesiaTime(
    String isoTimeString, {
    String format = 'HH:mm',
  }) {
    try {
      final dateTime = DateTime.parse(isoTimeString);

      // Jika sudah UTC, convert ke Indonesia time
      // Jika sudah lokal time, langsung format
      if (dateTime.isUtc) {
        return formatIndonesiaTime(dateTime, format: format);
      } else {
        return DateFormat(format).format(dateTime);
      }
    } catch (e) {
      return isoTimeString;
    }
  }

  // Get Indonesia time now
  static DateTime getNow() {
    return toIndonesiaTime(DateTime.now().toUtc());
  }

  // Format a date to Indonesia format with timezone adjustment
  static String formatDate(DateTime date, {String format = 'dd MMMM yyyy'}) {
    // Jika waktu sudah dalam timezone lokal, langsung format
    if (!date.isUtc) {
      return DateFormat(format).format(date);
    }

    final indonesiaDate = toIndonesiaTime(date);
    return DateFormat(format).format(indonesiaDate);
  }

  // Format DateTime to Indonesia day and date format (e.g., "Monday, 15 January 2024")
  static String formatDateTimeToIndonesiaDayDate(DateTime dateTime) {
    try {
      // Jika waktu sudah dalam timezone lokal, langsung format
      DateTime indonesiaTime;
      if (dateTime.isUtc) {
        indonesiaTime = toIndonesiaTime(dateTime);
      } else {
        indonesiaTime = dateTime;
      }

      return DateFormat('EEEE, dd MMMM yyyy', 'id_ID').format(indonesiaTime);
    } catch (e) {
      // Fallback to English format if Indonesian locale is not available
      DateTime indonesiaTime;
      if (dateTime.isUtc) {
        indonesiaTime = toIndonesiaTime(dateTime);
      } else {
        indonesiaTime = dateTime;
      }
      return DateFormat('EEEE, dd MMMM yyyy').format(indonesiaTime);
    }
  }

  // Format ISO string to local date time with full format (e.g., "Monday, 15 January 2024 14:30")
  static String formatISOToLocalDateTimeFull(String isoString) {
    try {
      final dateTime = DateTime.parse(isoString);

      // Jika sudah UTC, convert ke Indonesia time
      // Jika sudah lokal time, langsung format
      DateTime indonesiaTime;
      if (dateTime.isUtc) {
        indonesiaTime = toIndonesiaTime(dateTime);
      } else {
        indonesiaTime = dateTime;
      }

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

  // Helper: Parse string dan kembalikan DateTime dalam local time (Indonesia)
  static DateTime parseToLocal(String isoString) {
    try {
      final dateTime = DateTime.parse(isoString);
      if (dateTime.isUtc) {
        return toIndonesiaTime(dateTime);
      }
      return dateTime;
    } catch (e) {
      return DateTime.now();
    }
  }
}
