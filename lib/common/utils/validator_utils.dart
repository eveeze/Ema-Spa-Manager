// lib/common/utils/validator_utils.dart
import 'package:emababyspa/common/constants/text_constants.dart';

class ValidatorUtils {
  /// Validate if a string is a valid email address
  static bool isValidEmail(String? email) {
    if (email == null || email.isEmpty) return false;

    // Regular expression for email validation
    final emailRegex = RegExp(
      r'^[a-zA-Z0-9.!#$%&*+/=?^_`{|}~-]+@[a-zA-Z0-9-]+(?:\.[a-zA-Z0-9-]+)*$',
    );

    return emailRegex.hasMatch(email);
  }

  /// Validate email and return an error message if invalid
  static String? validateEmail(String? email) {
    if (email == null || email.isEmpty) {
      return TextConstants.errorEmailEmpty;
    }

    if (!isValidEmail(email)) {
      return TextConstants.errorEmailInvalid;
    }

    return null; // Valid email
  }

  /// Validate if a string is a valid password (minimum 8 characters)
  static bool isValidPassword(String? password) {
    return password != null && password.length >= 8;
  }

  /// Validate password and return an error message if invalid
  static String? validatePassword(String? password) {
    if (password == null || password.isEmpty) {
      return TextConstants.errorPasswordEmpty;
    }

    if (password.length < 8) {
      return TextConstants.errorPasswordLength;
    }

    return null; // Valid password
  }

  /// Validate password confirmation
  static String? validateConfirmPassword(
    String? password,
    String? confirmPassword,
  ) {
    if (confirmPassword == null || confirmPassword.isEmpty) {
      return TextConstants.errorPasswordEmpty;
    }

    if (password != confirmPassword) {
      return TextConstants.errorPasswordMatch;
    }

    return null; // Valid confirmation
  }

  /// Validate if a string is a valid name (not empty)
  static String? validateName(String? name) {
    if (name == null || name.trim().isEmpty) {
      return TextConstants.errorNameEmpty;
    }

    return null; // Valid name
  }

  /// Validate if a string is a valid Indonesian phone number
  static bool isValidIndonesianPhoneNumber(String? phone) {
    if (phone == null || phone.isEmpty) return false;

    // Remove all non-digit characters
    String digitsOnly = phone.replaceAll(RegExp(r'\D'), '');

    // Check if it's an Indonesian number (starts with 08, +62, or 62)
    bool startsWithValidPrefix = false;
    if (digitsOnly.startsWith('08')) {
      startsWithValidPrefix = true;
      // Remove leading 0
      digitsOnly = digitsOnly.substring(1);
    } else if (digitsOnly.startsWith('62')) {
      startsWithValidPrefix = true;
    } else if (phone.startsWith('+62')) {
      startsWithValidPrefix = true;
      // Remove the '+' sign for length check
      digitsOnly = digitsOnly.substring(1);
    }

    // Check if the length is valid (Indonesian numbers are typically 10-13 digits)
    bool hasValidLength = digitsOnly.length >= 10 && digitsOnly.length <= 14;

    return startsWithValidPrefix && hasValidLength;
  }

  /// Validate phone number and return an error message if invalid
  static String? validatePhone(String? phone) {
    if (phone == null || phone.isEmpty) {
      return TextConstants.errorPhoneEmpty;
    }

    if (!isValidIndonesianPhoneNumber(phone)) {
      return TextConstants.errorPhoneInvalid;
    }

    return null; // Valid phone number
  }

  /// Validate if a string is not empty
  static String? validateNotEmpty(String? value, {String? errorMessage}) {
    if (value == null || value.trim().isEmpty) {
      return errorMessage ?? TextConstants.errorFieldRequired;
    }

    return null; // Valid value
  }

  /// Validate if a number is within a specified range
  static String? validateNumberRange(
    String? value, {
    required double min,
    required double max,
    String? errorMessage,
  }) {
    if (value == null || value.isEmpty) {
      return TextConstants.errorFieldRequired;
    }

    try {
      double numValue = double.parse(value);
      if (numValue < min || numValue > max) {
        return errorMessage ?? 'Value must be between $min and $max';
      }
      return null; // Valid number
    } catch (e) {
      return 'Please enter a valid number';
    }
  }

  /// Validate if a date is in the future
  static String? validateFutureDate(DateTime? date, {String? errorMessage}) {
    if (date == null) {
      return TextConstants.errorFieldRequired;
    }

    if (date.isBefore(DateTime.now())) {
      return errorMessage ?? 'Date must be in the future';
    }

    return null; // Valid date
  }

  /// Validate if a date is in the past
  static String? validatePastDate(DateTime? date, {String? errorMessage}) {
    if (date == null) {
      return TextConstants.errorFieldRequired;
    }

    if (date.isAfter(DateTime.now())) {
      return errorMessage ?? 'Date must be in the past';
    }

    return null; // Valid date
  }

  /// Validate if a string contains only alphabetic characters
  static bool isAlpha(String? value) {
    if (value == null || value.isEmpty) return false;

    final alphaRegex = RegExp(r'^[a-zA-Z]+$');
    return alphaRegex.hasMatch(value);
  }

  /// Validate if a string contains only numeric characters
  static bool isNumeric(String? value) {
    if (value == null || value.isEmpty) return false;

    return double.tryParse(value) != null;
  }

  /// Validate if a string contains only alphanumeric characters
  static bool isAlphanumeric(String? value) {
    if (value == null || value.isEmpty) return false;

    final alphanumericRegex = RegExp(r'^[a-zA-Z0-9]+$');
    return alphanumericRegex.hasMatch(value);
  }

  /// Validate if a string is a valid URL
  static bool isValidUrl(String? url) {
    if (url == null || url.isEmpty) return false;

    final urlRegex = RegExp(
      r'^(http|https)://[a-zA-Z0-9-]+(\.[a-zA-Z0-9-]+)+(:[0-9]+)?(/[a-zA-Z0-9-._~:/?#[\]@!$&()*+,;=]*)?$',
    );

    return urlRegex.hasMatch(url);
  }

  /// Validate if a string is a valid date in format YYYY-MM-DD
  static bool isValidDate(String? date) {
    if (date == null || date.isEmpty) return false;

    try {
      final parts = date.split('-');
      if (parts.length != 3) return false;

      final year = int.parse(parts[0]);
      final month = int.parse(parts[1]);
      final day = int.parse(parts[2]);

      if (year < 1900 || year > 2100) return false;
      if (month < 1 || month > 12) return false;
      if (day < 1 || day > 31) return false;

      // Check if the date is valid (e.g., not February 30)
      final dateTime = DateTime(year, month, day);
      return dateTime.year == year &&
          dateTime.month == month &&
          dateTime.day == day;
    } catch (e) {
      return false;
    }
  }

  /// Validate Indonesian NIK (National Identity Number)
  static bool isValidNIK(String? nik) {
    if (nik == null || nik.isEmpty) return false;

    // NIK should be 16 digits
    final nikRegex = RegExp(r'^[0-9]{16}$');
    return nikRegex.hasMatch(nik);
  }

  /// Validate Indonesian postal code
  static bool isValidPostalCode(String? postalCode) {
    if (postalCode == null || postalCode.isEmpty) return false;

    // Indonesian postal code is 5 digits
    final postalCodeRegex = RegExp(r'^[0-9]{5}$');
    return postalCodeRegex.hasMatch(postalCode);
  }

  /// Validate if a string has minimum length
  static String? validateMinLength(
    String? value,
    int minLength, {
    String? errorMessage,
  }) {
    if (value == null || value.isEmpty) {
      return TextConstants.errorFieldRequired;
    }

    if (value.length < minLength) {
      return errorMessage ?? 'Must be at least $minLength characters';
    }

    return null; // Valid value
  }

  /// Validate if a string has maximum length
  static String? validateMaxLength(
    String? value,
    int maxLength, {
    String? errorMessage,
  }) {
    if (value == null || value.isEmpty) {
      return TextConstants.errorFieldRequired;
    }

    if (value.length > maxLength) {
      return errorMessage ?? 'Must not exceed $maxLength characters';
    }

    return null; // Valid value
  }
}
