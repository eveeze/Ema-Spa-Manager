import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'logger_utils.dart';

/// A utility class to handle permissions in the app
class PermissionUtils {
  static final PermissionUtils _instance = PermissionUtils._internal();
  factory PermissionUtils() => _instance;
  PermissionUtils._internal();

  final LoggerUtils _logger = LoggerUtils();

  /// Opens app settings
  Future<void> openAppSettings() async {
    try {
      if (Platform.isAndroid || Platform.isIOS) {
        await launchAppSettings();
      }
    } catch (e) {
      _logger.error('Error opening app settings: $e');
      showToast('Could not open app settings');
    }
  }

  /// Launch app settings based on platform
  Future<void> launchAppSettings() async {
    try {
      if (Platform.isAndroid) {
        // Get the actual package name dynamically
        final packageInfo = await PackageInfo.fromPlatform();
        final packageName = packageInfo.packageName;

        final uri = Uri.parse('package:$packageName');
        final canLaunch = await canLaunchUrl(uri);

        if (canLaunch) {
          await launchUrl(uri, mode: LaunchMode.externalApplication);
        } else {
          _logger.error('Cannot launch app settings for package: $packageName');
          // Fallback to Android settings
          final settingsUri = Uri.parse('android-app://com.android.settings');
          await launchUrl(settingsUri, mode: LaunchMode.externalApplication);
        }
      } else if (Platform.isIOS) {
        // iOS: Open app settings
        final uri = Uri.parse('app-settings:');
        if (await canLaunchUrl(uri)) {
          await launchUrl(uri, mode: LaunchMode.externalApplication);
        } else {
          _logger.error('Cannot launch iOS app settings');
        }
      }
    } catch (e) {
      _logger.error('Error launching app settings: $e');
    }
  }

  /// Show permission dialog with options to open settings or cancel
  void showPermissionDialog({
    required String title,
    required String message,
    String? cancelButtonText,
    String? settingsButtonText,
    VoidCallback? onCancel,
  }) {
    Get.dialog(
      AlertDialog(
        title: Text(title, style: const TextStyle(fontFamily: 'JosefinSans')),
        content: Text(
          message,
          style: const TextStyle(fontFamily: 'JosefinSans'),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Get.back();
              if (onCancel != null) {
                onCancel();
              }
            },
            child: Text(
              cancelButtonText ?? 'Cancel',
              style: const TextStyle(fontFamily: 'JosefinSans'),
            ),
          ),
          TextButton(
            onPressed: () {
              Get.back();
              openAppSettings();
            },
            child: Text(
              settingsButtonText ?? 'Settings',
              style: const TextStyle(fontFamily: 'JosefinSans'),
            ),
          ),
        ],
      ),
      barrierDismissible: false,
    );
  }

  /// Show a toast message
  void showToast(String message) {
    Get.snackbar(
      'Permission',
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.black54,
      colorText: Colors.white,
      margin: const EdgeInsets.all(16),
      duration: const Duration(seconds: 3),
    );
  }

  /// Check if a URL can be launched
  Future<bool> canLaunchUrlCheck(Uri url) async {
    try {
      return await canLaunchUrl(url);
    } catch (e) {
      _logger.error('Error checking if URL can be launched: $e');
      return false;
    }
  }

  /// Launch URL with error handling
  Future<bool> launchUrlWithErrorHandling(Uri url) async {
    try {
      if (await canLaunchUrlCheck(url)) {
        return await launchUrl(url);
      } else {
        _logger.error('Could not launch URL: $url');
        showToast('Could not launch URL');
        return false;
      }
    } catch (e) {
      _logger.error('Error launching URL: $e');
      showToast('Error launching URL');
      return false;
    }
  }

  /// Launch phone call with error handling
  Future<bool> launchPhoneCall(String phoneNumber) {
    final Uri phoneCallUri = Uri(scheme: 'tel', path: phoneNumber);
    return launchUrlWithErrorHandling(phoneCallUri);
  }

  /// Launch email with error handling
  Future<bool> launchEmail({
    required String email,
    String? subject,
    String? body,
  }) {
    final Uri emailUri = Uri(
      scheme: 'mailto',
      path: email,
      queryParameters: <String, String>{
        if (subject != null) 'subject': subject,
        if (body != null) 'body': body,
      },
    );
    return launchUrlWithErrorHandling(emailUri);
  }

  /// Launch SMS with error handling
  Future<bool> launchSms(String phoneNumber, {String? message}) {
    final Uri smsUri = Uri(
      scheme: 'sms',
      path: phoneNumber,
      queryParameters: <String, String>{if (message != null) 'body': message},
    );
    return launchUrlWithErrorHandling(smsUri);
  }

  /// Launch WhatsApp with error handling
  Future<bool> launchWhatsApp(String phoneNumber, {String? message}) {
    String whatsappUrl = "https://wa.me/$phoneNumber";
    if (message != null) {
      whatsappUrl += "?text=${Uri.encodeComponent(message)}";
    }
    final Uri whatsappUri = Uri.parse(whatsappUrl);
    return launchUrlWithErrorHandling(whatsappUri);
  }

  /// Launch Google Maps with coordinates
  Future<bool> launchGoogleMaps(
    double latitude,
    double longitude, {
    String? label,
  }) {
    final Uri mapsUri = Uri.parse(
      'https://www.google.com/maps/search/?api=1&query=$latitude,$longitude${label != null ? '&query_place_id=$label' : ''}',
    );
    return launchUrlWithErrorHandling(mapsUri);
  }
}
