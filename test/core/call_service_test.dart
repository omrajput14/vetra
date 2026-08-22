import 'package:flutter_test/flutter_test.dart';
import 'package:vetra/core/services/call_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('CallService Validation and Cleaning Tests', () {
    test('cleanPhoneNumber formats standard Indian mobile numbers', () {
      expect(CallService.cleanPhoneNumber('+919876543210'), '+919876543210');
      expect(CallService.cleanPhoneNumber('  +91 98765 43210  '), '+919876543210');
      expect(CallService.cleanPhoneNumber('09876543210'), '09876543210');
      expect(CallService.cleanPhoneNumber('+91-9876-543210'), '+919876543210');
    });

    test('cleanPhoneNumber handles empty or null inputs', () {
      expect(CallService.cleanPhoneNumber(null), isNull);
      expect(CallService.cleanPhoneNumber(''), isNull);
      expect(CallService.cleanPhoneNumber('   '), isNull);
      expect(CallService.cleanPhoneNumber('abc'), isNull);
    });

    test('isValidPhoneNumber validates properly', () {
      expect(CallService.isValidPhoneNumber('+919876543210'), isTrue);
      expect(CallService.isValidPhoneNumber('9876543210'), isTrue);
      expect(CallService.isValidPhoneNumber('100'), isTrue); // Emergency short code
      expect(CallService.isValidPhoneNumber('112'), isTrue); // Emergency short code
      expect(CallService.isValidPhoneNumber(''), isFalse);
      expect(CallService.isValidPhoneNumber(null), isFalse);
      expect(CallService.isValidPhoneNumber('12'), isFalse); // Too short
      expect(CallService.isValidPhoneNumber('12345678901234567890'), isFalse); // Too long
    });

    test('makePhoneCall returns missingNumber when phoneNumber is null or empty', () async {
      final callService = CallService.instance;
      expect(await callService.makePhoneCall(null), CallResult.missingNumber);
      expect(await callService.makePhoneCall(''), CallResult.missingNumber);
      expect(await callService.makePhoneCall('   '), CallResult.missingNumber);
    });

    test('makePhoneCall returns invalidNumber when phoneNumber is invalid format', () async {
      final callService = CallService.instance;
      expect(await callService.makePhoneCall('no-phone-here'), CallResult.invalidNumber);
      expect(await callService.makePhoneCall('12'), CallResult.invalidNumber);
    });
  });
}
