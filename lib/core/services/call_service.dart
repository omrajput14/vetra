import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../l10n/app_localizations.dart';
import '../design_system/app_colors.dart';

/// Represents the status outcome of a phone dialing attempt.
enum CallResult {
  success,
  missingNumber,
  invalidNumber,
  dialerUnavailable,
  error,
}

/// Abstract contract for call invocation.
abstract class BaseCallService {
  Future<CallResult> makePhoneCall(String? phoneNumber);
  Future<bool> handleCall(BuildContext context, String? phoneNumber, {AppLocalizations? l10n});
}

/// Service handling native phone dialer intent invocation and contact validation.
class CallService implements BaseCallService {
  static final CallService _instance = CallService._internal();
  static CallService get instance => _instance;
  CallService._internal();

  /// Clean and format raw phone number for tel: URI.
  static String? cleanPhoneNumber(String? rawPhone) {
    if (rawPhone == null) return null;
    final trimmed = rawPhone.trim();
    if (trimmed.isEmpty) return null;

    final hasPlus = trimmed.startsWith('+');
    final digits = trimmed.replaceAll(RegExp(r'[^\d]'), '');
    if (digits.isEmpty) return null;

    return hasPlus ? '+$digits' : digits;
  }

  /// Validates phone number format (between 3 and 16 digits).
  static bool isValidPhoneNumber(String? rawPhone) {
    final cleaned = cleanPhoneNumber(rawPhone);
    if (cleaned == null) return false;
    final digitsOnly = cleaned.replaceAll(RegExp(r'[^\d]'), '');
    return digitsOnly.length >= 3 && digitsOnly.length <= 16;
  }

  @override
  Future<CallResult> makePhoneCall(String? phoneNumber) async {
    if (phoneNumber == null || phoneNumber.trim().isEmpty) {
      return CallResult.missingNumber;
    }

    final cleaned = cleanPhoneNumber(phoneNumber);
    if (cleaned == null || !isValidPhoneNumber(cleaned)) {
      return CallResult.invalidNumber;
    }

    final Uri launchUri = Uri(
      scheme: 'tel',
      path: cleaned,
    );

    try {
      final canLaunch = await canLaunchUrl(launchUri);
      if (!canLaunch) {
        final launched = await launchUrl(
          launchUri,
          mode: LaunchMode.externalApplication,
        );
        return launched ? CallResult.success : CallResult.dialerUnavailable;
      }

      final launched = await launchUrl(
        launchUri,
        mode: LaunchMode.externalApplication,
      );
      return launched ? CallResult.success : CallResult.dialerUnavailable;
    } catch (e) {
      return CallResult.error;
    }
  }

  @override
  Future<bool> handleCall(
    BuildContext context,
    String? phoneNumber, {
    AppLocalizations? l10n,
  }) async {
    final result = await makePhoneCall(phoneNumber);

    if (result == CallResult.success) {
      return true;
    }

    if (context.mounted) {
      final message = _getErrorMessage(result, l10n);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: AppColors.alertCritical,
          duration: const Duration(seconds: 3),
        ),
      );
    }

    return false;
  }

  String _getErrorMessage(CallResult result, AppLocalizations? l10n) {
    switch (result) {
      case CallResult.missingNumber:
      case CallResult.invalidNumber:
      case CallResult.dialerUnavailable:
      case CallResult.error:
        return l10n?.contactUnavailable ?? 'Contact unavailable';
      case CallResult.success:
        return '';
    }
  }
}
