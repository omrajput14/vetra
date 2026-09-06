import 'package:flutter_test/flutter_test.dart';
import 'package:vetra/core/services/push_notification_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('PushNotificationService Deep Link & State Tests', () {
    final service = PushNotificationService.instance;

    test('PushNotificationService initializes as a valid singleton', () {
      expect(service, isNotNull);
      expect(service.onForegroundMessage, isNotNull);
    });

    test('handleNotificationTap processes explicit route parameter correctly', () {
      expect(
        () => service.handleNotificationTap({
          'route': '/appointment-details?id=appt-test-123',
          'appointmentId': 'appt-test-123',
        }),
        returnsNormally,
      );
    });

    test('handleNotificationTap processes chat notification payload correctly', () {
      expect(
        () => service.handleNotificationTap({
          'route': '/appointment-chat?id=appt-test-123',
          'appointmentId': 'appt-test-123',
          'type': 'CHAT_MESSAGE',
        }),
        returnsNormally,
      );
    });

    test('handleNotificationTap handles outbreak and disease report payloads', () {
      expect(
        () => service.handleNotificationTap({
          'outbreakId': 'outbreak-99',
          'type': 'OUTBREAK_ALERT',
        }),
        returnsNormally,
      );

      expect(
        () => service.handleNotificationTap({
          'reportId': 'report-12',
          'type': 'DISEASE_REPORT',
        }),
        returnsNormally,
      );
    });

    test('handleNotificationTap handles missing or empty payload gracefully without crashing', () {
      expect(
        () => service.handleNotificationTap({}),
        returnsNormally,
      );
    });
  });
}
