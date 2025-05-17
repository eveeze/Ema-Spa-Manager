// lib/common/utils/date_utils.dart
import 'package:intl/intl.dart';
import 'package:emababyspa/common/constants/app_constants.dart';

class DateUtils {
  /// Format a DateTime object to a display-friendly date string
  static String formatDate(DateTime date) {
    return DateFormat(AppConstants.dateFormatDisplay).format(date);
  }

  /// Format a DateTime object to a display-friendly time string
  static String formatTime(DateTime time) {
    return DateFormat(AppConstants.timeFormatDisplay).format(time);
  }

  /// Format a DateTime object to a display-friendly date and time string
  static String formatDateTime(DateTime dateTime) {
    return DateFormat(AppConstants.dateTimeFormatDisplay).format(dateTime);
  }

  /// Format a DateTime object to a date string for API requests
  static String formatDateForApi(DateTime date) {
    return DateFormat(AppConstants.dateFormatApi).format(date);
  }

  /// Format a DateTime object to a time string for API requests
  static String formatTimeForApi(DateTime time) {
    return DateFormat(AppConstants.timeFormatApi).format(time);
  }

  /// Format a DateTime object to a date and time string for API requests
  static String formatDateTimeForApi(DateTime dateTime) {
    return DateFormat(AppConstants.dateTimeFormatApi).format(dateTime);
  }

  /// Parse a date string from API to a DateTime object
  static DateTime parseDateFromApi(String dateString) {
    return DateFormat(AppConstants.dateFormatApi).parse(dateString);
  }

  /// Parse a time string from API to a DateTime object
  static DateTime parseTimeFromApi(String timeString) {
    return DateFormat(AppConstants.timeFormatApi).parse(timeString);
  }

  /// Parse a date and time string from API to a DateTime object
  static DateTime parseDateTimeFromApi(String dateTimeString) {
    return DateFormat(AppConstants.dateTimeFormatApi).parse(dateTimeString);
  }

  /// Get the current date (with time set to 00:00:00)
  static DateTime getCurrentDate() {
    final now = DateTime.now();
    return DateTime(now.year, now.month, now.day);
  }

  /// Get the current date and time
  static DateTime getCurrentDateTime() {
    return DateTime.now();
  }

  /// Check if a date is today
  static bool isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year &&
        date.month == now.month &&
        date.day == now.day;
  }

  /// Check if a date is tomorrow
  static bool isTomorrow(DateTime date) {
    final tomorrow = DateTime.now().add(const Duration(days: 1));
    return date.year == tomorrow.year &&
        date.month == tomorrow.month &&
        date.day == tomorrow.day;
  }

  /// Check if a date is yesterday
  static bool isYesterday(DateTime date) {
    final yesterday = DateTime.now().subtract(const Duration(days: 1));
    return date.year == yesterday.year &&
        date.month == yesterday.month &&
        date.day == yesterday.day;
  }

  /// Get the day name (e.g., Monday, Tuesday, etc.)
  static String getDayName(DateTime date) {
    return DateFormat('EEEE').format(date);
  }

  /// Get the short day name (e.g., Mon, Tue, etc.)
  static String getShortDayName(DateTime date) {
    return DateFormat('E').format(date);
  }

  /// Get the month name (e.g., January, February, etc.)
  static String getMonthName(DateTime date) {
    return DateFormat('MMMM').format(date);
  }

  /// Get the short month name (e.g., Jan, Feb, etc.)
  static String getShortMonthName(DateTime date) {
    return DateFormat('MMM').format(date);
  }

  /// Get the age from a birthdate
  static int getAge(DateTime birthDate) {
    final now = DateTime.now();
    int age = now.year - birthDate.year;

    // Check if the birthday has occurred this year
    if (now.month < birthDate.month ||
        (now.month == birthDate.month && now.day < birthDate.day)) {
      age--;
    }

    return age;
  }

  /// Get the difference between two dates in days
  static int getDayDifference(DateTime date1, DateTime date2) {
    return date1.difference(date2).inDays.abs();
  }

  /// Get a list of DateTime objects between two dates (inclusive)
  static List<DateTime> getDatesBetween(DateTime startDate, DateTime endDate) {
    List<DateTime> dates = [];
    DateTime currentDate = startDate;

    while (currentDate.isBefore(endDate) ||
        currentDate.isAtSameMomentAs(endDate)) {
      dates.add(currentDate);
      currentDate = currentDate.add(const Duration(days: 1));
    }

    return dates;
  }

  /// Get the first day of the month
  static DateTime getFirstDayOfMonth(DateTime date) {
    return DateTime(date.year, date.month, 1);
  }

  /// Get the last day of the month
  static DateTime getLastDayOfMonth(DateTime date) {
    return DateTime(date.year, date.month + 1, 0);
  }

  /// Add days to a date
  static DateTime addDays(DateTime date, int days) {
    return date.add(Duration(days: days));
  }

  /// Add months to a date
  static DateTime addMonths(DateTime date, int months) {
    return DateTime(date.year, date.month + months, date.day);
  }

  /// Format a duration in hours and minutes
  static String formatDuration(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes % 60;

    if (hours > 0) {
      return '$hours h ${minutes > 0 ? '$minutes min' : ''}';
    } else {
      return '$minutes min';
    }
  }

  /// Get relative time (e.g., "2 hours ago", "5 minutes ago", etc.)
  static String getRelativeTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays > 365) {
      return '${(difference.inDays / 365).floor()} ${(difference.inDays / 365).floor() == 1 ? 'year' : 'years'} ago';
    } else if (difference.inDays > 30) {
      return '${(difference.inDays / 30).floor()} ${(difference.inDays / 30).floor() == 1 ? 'month' : 'months'} ago';
    } else if (difference.inDays > 0) {
      return '${difference.inDays} ${difference.inDays == 1 ? 'day' : 'days'} ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} ${difference.inHours == 1 ? 'hour' : 'hours'} ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} ${difference.inMinutes == 1 ? 'minute' : 'minutes'} ago';
    } else {
      return 'just now';
    }
  }
}
